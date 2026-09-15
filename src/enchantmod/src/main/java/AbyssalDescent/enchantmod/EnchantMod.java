package AbyssalDescent.enchantmod;

import AbyssalDescent.enchantmod.enchant.Enchant;

import net.minecraft.ChatFormatting;
import net.minecraft.network.chat.Component;
import net.minecraft.tags.TagKey;
import net.minecraft.core.registries.Registries;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.BlockItem;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.entity.BlockEntityType;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.item.crafting.RecipeSerializer;
import net.minecraft.world.item.crafting.RecipeType;
import net.minecraft.world.item.enchantment.EnchantmentHelper;

import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;
import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.RegistryObject;
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.event.AnvilUpdateEvent;
import net.minecraftforge.event.level.BlockEvent;
import net.minecraftforge.event.entity.player.ItemTooltipEvent;


@Mod(EnchantMod.MODID)
public class EnchantMod {
	public static final String MODID = "enchantmod";

	public static final DeferredRegister<RecipeType<?>> RECIPE_TYPES =
		DeferredRegister.create(ForgeRegistries.RECIPE_TYPES, MODID);

	public static final DeferredRegister<RecipeSerializer<?>> RECIPE_SERIALIZERS =
		DeferredRegister.create(ForgeRegistries.RECIPE_SERIALIZERS, MODID);

	public static final DeferredRegister<BlockEntityType<?>> BLOCK_ENTITY_TYPES =
		DeferredRegister.create(ForgeRegistries.BLOCK_ENTITY_TYPES, MODID);

	public static final DeferredRegister<Item> ITEMS =
		DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

	public static final DeferredRegister<Block> BLOCKS =
		DeferredRegister.create(ForgeRegistries.BLOCKS, MODID);


	public static final RegistryObject<PedestalBlock> PEDESTAL =
		BLOCKS.register("pedestal", PedestalBlock::new);

	public static final RegistryObject<Item> PEDESTAL_ITEM =
		ITEMS.register("pedestal", () -> new BlockItem(PEDESTAL.get(), new Item.Properties()));

	public static final RegistryObject<RecipeType<EnchantRecipe>> ENCHANT_RECIPE =
		RECIPE_TYPES.register("enchant", () -> new RecipeType<>() {});

	public static final RegistryObject<RecipeSerializer<EnchantRecipe>> ENCHANT_SERIALIZER =
		RECIPE_SERIALIZERS.register("enchant", EnchantRecipe.Serializer::new);

	public static final RegistryObject<BlockEntityType<EnchantBE>> ENCHANTBE =
		BLOCK_ENTITY_TYPES.register("enchant", () -> BlockEntityType.Builder.of(
			EnchantBE::new, Blocks.ENCHANTING_TABLE).build(null));

	public static final RegistryObject<BlockEntityType<PedestalBlock.PedestalBE>> PEDESTALBE =
		BLOCK_ENTITY_TYPES.register("pedestal", () -> BlockEntityType.Builder.of(
			PedestalBlock.PedestalBE::new, PEDESTAL.get()).build(null));


	public static final TagKey<Item> RUNES = TagKey.create(
		Registries.ITEM, new ResourceLocation(MODID, "runes"));

	public static final RegistryObject<Item> FIRE_RUNE =
		ITEMS.register("fire_rune", () -> new Item(new Item.Properties()));


	public EnchantMod() {
		var bus = FMLJavaModLoadingContext.get().getModEventBus();
		ITEMS.register(bus);
		BLOCKS.register(bus);
		RECIPE_TYPES.register(bus);
		RECIPE_SERIALIZERS.register(bus);
		BLOCK_ENTITY_TYPES.register(bus);
	}


	@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.FORGE)
	public class Events {
		@SubscribeEvent
		public void on_break(BlockEvent.BreakEvent event) {
			var level = event.getLevel();
			var pos   = event.getPos();

			if (!(level instanceof ServerLevel server)) return;
			if (!(level.getBlockEntity(pos) instanceof ItemHolderBE entity)) return;
			
			entity.drop_content(server);
		}

		@SubscribeEvent
		public static void on_anvil_update(AnvilUpdateEvent e) {
			e.setCost(0);
		}

		@SubscribeEvent
		public static void itemTooltip(ItemTooltipEvent e) {
			for (var enchant : EnchantmentHelper.getEnchantments(e.getItemStack()).keySet()) {
				var behaviour = Enchant.get(enchant);
				if (behaviour == null) continue;

				e.getToolTip().add(Component.literal(behaviour.get_tooltip())
					.withStyle(ChatFormatting.GRAY, ChatFormatting.ITALIC));
			}
		}
	}
}
