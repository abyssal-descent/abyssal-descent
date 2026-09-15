package AbyssalDescent.enchantmod;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;

import net.minecraft.core.BlockPos;
import net.minecraft.core.RegistryAccess;
import net.minecraft.core.Direction;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.network.FriendlyByteBuf;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.util.GsonHelper;
import net.minecraft.world.Container;
import net.minecraft.world.phys.Vec3;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.crafting.Ingredient;
import net.minecraft.world.item.crafting.Recipe;
import net.minecraft.world.item.crafting.RecipeSerializer;
import net.minecraft.world.item.crafting.RecipeType;
import net.minecraft.world.item.enchantment.Enchantment;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.ClipContext;
import net.minecraft.world.level.BlockGetter;
import net.minecraft.world.level.block.Block;

import java.util.*;

public class EnchantRecipe implements Recipe<Container> {
	public final ResourceLocation id;
	public final List<Ingredient> ingredients;
	public final List<BlockRequirement> blocks;
	public final Enchantment enchant;

	public record BlockRequirement(Block block, int count) {}

	private static final int INGREDIENT_SIZE = 4;
	private static final int RADIUS = 3;

	public EnchantRecipe(ResourceLocation id, List<Ingredient> ingredients,
		List<BlockRequirement> blocks, Enchantment enchant) {
		this.id = id;
		this.ingredients = ingredients;
		this.blocks = blocks;
		this.enchant = enchant;
	}

	public boolean matches_ingredients(List<ItemStack> input) {
		if (input.size() != this.ingredients.size() || input.size() != INGREDIENT_SIZE) return false;

		var input_sort = new ArrayList<ItemStack>(input);
		input_sort.sort(Comparator.comparing(s ->
			BuiltInRegistries.ITEM.getKey(s.getItem()).toString()));

		for (var i = 0; i < INGREDIENT_SIZE; i++)
			if (!this.ingredients.get(i).test(input_sort.get(i)))
				return false;

		return true;
	}

	public boolean matches_blocks(Level level, BlockPos center) {
		for (var req : this.blocks) {
			var found = 0;
			for (var pos : BlockPos.betweenClosed(
				center.offset(-RADIUS, -RADIUS, -RADIUS),
				center.offset(RADIUS, RADIUS, RADIUS))) {
				if (pos.equals(center)) continue;
				if (!level.getBlockState(pos).is(req.block())) continue;

				var ctx = new ClipContext(
					Vec3.atCenterOf(center), Vec3.atCenterOf(pos),
					ClipContext.Block.COLLIDER, ClipContext.Fluid.NONE, null);

				var hit = BlockGetter.traverseBlocks(ctx.getFrom(), ctx.getTo(), ctx, 
					(c, p) -> {
						if (p.equals(center)) return null;
						return c.getBlockShape(level.getBlockState(p), level, p)
							.clip(c.getFrom(), c.getTo(), p);
					},
					c -> {
						var dir = c.getTo().subtract(c.getFrom());
						return BlockHitResult.miss(c.getTo(),
							Direction.getNearest(dir.x, dir.y, dir.z),
							BlockPos.containing(c.getTo()));
					}
				);

				if (!hit.getBlockPos().equals(pos)) continue;

				found = found + 1;

				if (found >= req.count()) break;
			}

			if (found < req.count()) return false;
		}

		return true;
	}

	@Override
	public boolean matches(Container container, Level level) {
		return false;
	}

	// TODO show result as an enchanted book
	@Override
	public ItemStack assemble(Container container, RegistryAccess ra) {
		return ItemStack.EMPTY;
	}

	@Override
	public ItemStack getResultItem(RegistryAccess ra) {
		return ItemStack.EMPTY;
	}

	@Override
	public ResourceLocation getId() {
		return this.id;
	}

	@Override
	public RecipeSerializer<?> getSerializer() {
		return EnchantMod.ENCHANT_SERIALIZER.get();
	}

	@Override
	public RecipeType<?> getType() {
		return EnchantMod.ENCHANT_RECIPE.get();
	}

	@Override
	public boolean canCraftInDimensions(int width, int height) {
		return false;
	}

	public static class Serializer implements RecipeSerializer<EnchantRecipe> {
		@Override
		public EnchantRecipe fromJson(ResourceLocation id, JsonObject json) {
			var json_ingredients = GsonHelper.getAsJsonArray(json, "ingredients");
			if (json_ingredients.size() != INGREDIENT_SIZE) throw new JsonParseException("ingredients must be 4 length");

			var ingredients = new ArrayList<Ingredient>();
			for (var elem : json_ingredients)
				ingredients.add(Ingredient.fromJson(elem));
			ingredients.sort(Comparator.comparing(i ->
				BuiltInRegistries.ITEM.getKey(i.getItems()[0].getItem()).toString()));

			var enchant_id = new ResourceLocation(GsonHelper.getAsString(json, "enchant"));
			var enchant = BuiltInRegistries.ENCHANTMENT.get(enchant_id);
			if (enchant == null) throw new JsonParseException("Unknown enchant:" + enchant_id);

			var blocks = new ArrayList<BlockRequirement>();
			if (json.has("blocks")) {
				var json_blocks = GsonHelper.getAsJsonArray(json, "blocks");
				for (var elem_json : json_blocks) {
					var elem = elem_json.getAsJsonObject();
					var block_id = new ResourceLocation(GsonHelper.getAsString(elem, "id"));
					var block = BuiltInRegistries.BLOCK.get(block_id);
					if (block == null) throw new JsonParseException("unknown block: " + block_id);

					var count = GsonHelper.getAsInt(elem, "count");

					blocks.add(new BlockRequirement(block, count));
				}
			}

			return new EnchantRecipe(id, ingredients, blocks, enchant);
		}

		@Override
		public EnchantRecipe fromNetwork(ResourceLocation id, FriendlyByteBuf buf) {
			var ingredients = new ArrayList<Ingredient>();

			for (var i = 0; i < INGREDIENT_SIZE; i++)
				ingredients.add(Ingredient.fromNetwork(buf));

			var enchant = BuiltInRegistries.ENCHANTMENT.get(buf.readResourceLocation());

			var block_c = buf.readVarInt();
			var blocks = new ArrayList<BlockRequirement>(block_c);

			for (var i = 0; i < block_c; i++)
				blocks.add(new BlockRequirement(
					BuiltInRegistries.BLOCK.get(buf.readResourceLocation()),
					buf.readVarInt()));

			return new EnchantRecipe(id, ingredients, blocks, enchant);
		}

		@Override
		public void toNetwork(FriendlyByteBuf buf, EnchantRecipe recipe) {
			for (var i : recipe.ingredients) i.toNetwork(buf);

			buf.writeVarInt(recipe.blocks.size());
			for (var req : recipe.blocks) {
				buf.writeResourceLocation(BuiltInRegistries.BLOCK.getKey(req.block()));
				buf.writeVarInt(req.count());
			}

			buf.writeResourceLocation(BuiltInRegistries.ENCHANTMENT.getKey(recipe.enchant));
		}
	}
}
