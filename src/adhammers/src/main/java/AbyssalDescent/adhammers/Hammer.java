package AbyssalDescent.adhammers;

import net.minecraft.core.BlockPos;
import net.minecraft.world.level.ClipContext;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.Tier;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.DiggerItem;
import net.minecraft.world.item.crafting.Ingredient;
import net.minecraft.world.phys.HitResult;
import net.minecraft.tags.BlockTags;
import net.minecraft.server.level.ServerPlayer;

import java.util.stream.*;
import java.util.*;

public class Hammer extends DiggerItem {
	public static final int RADIUS = 1;

	public Hammer(Tier tier, float damage) {
		super(damage, -3.5F, tier, BlockTags.MINEABLE_WITH_PICKAXE, new Item.Properties().stacksTo(1));
	}

	public static List<BlockPos> blocks_in_radius(BlockPos init, ServerPlayer player) {
		var trace = player.level().clip(new ClipContext(
			player.getEyePosition(1f),
			player.getEyePosition(1f).add(player.getViewVector(1f).scale(6f)),
			ClipContext.Block.COLLIDER, ClipContext.Fluid.NONE, player));

		if (trace.getType() == HitResult.Type.MISS) 
			return new ArrayList<>();

		return switch (trace.getDirection()) {
			case DOWN, UP ->
				iter_radius_grid((x, y) -> new BlockPos(init.getX() + x, init.getY(), init.getZ() + y));
			case NORTH, SOUTH ->
				iter_radius_grid((x, y) -> new BlockPos(init.getX() + x, init.getY() + y, init.getZ()));
			case EAST, WEST ->
				iter_radius_grid((x, y) -> new BlockPos(init.getX(), init.getY() + y, init.getZ() + x));
			default -> new ArrayList<>();
		};
	}

	private interface GridMapFn<T> { T apply(int x, int y); }
	private static <T> List<T> iter_radius_grid(GridMapFn<T> fn) {
		return IntStream.rangeClosed(-RADIUS, RADIUS).boxed()
			.flatMap(x -> IntStream.rangeClosed(-RADIUS, RADIUS)
				.mapToObj(y -> new int[] { x, y }))
			.map(p -> fn.apply(p[0], p[1]))
			.collect(Collectors.toList());
	}

	public static class Material implements Tier {
		private int level;
		private int durability;
		private float speed;
		private Ingredient repair;

		public Material(int level, int durability, float speed, Item repair_item) {
			this.level  = level;
			this.speed  = speed;
			this.repair = Ingredient.of(new ItemStack(repair_item, 3));
			this.durability = durability;
		}

		public int getUses() { return durability; }
		public float getSpeed() { return speed; }
		public int getLevel() { return level; }
		public int getEnchantmentValue() { return 15; }
		public float getAttackDamageBonus() { return 0F; }
		public Ingredient getRepairIngredient() { return repair; }
	}
}
