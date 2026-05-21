package AbyssalDescent.adresources.mixin;

import net.minecraft.world.item.Item;
import net.minecraft.world.item.Items;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.PickaxeItem;
import net.minecraft.world.item.Tiers;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.resources.ResourceLocation;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.util.Optional;

@Mixin(ItemStack.class)
public abstract class ItemMixin {
	@Shadow
	private Item getItem() { return Items.AIR; }

	@Inject(method = "isCorrectToolForDrops", at = @At("HEAD"), cancellable = true)
	private void onIsCorrectToolForDrops(BlockState state, CallbackInfoReturnable<Boolean> ci) {
		var id = BuiltInRegistries.BLOCK.getKey(state.getBlock()).toString();

		map_id_level(id).ifPresent(level -> {
			if (this.getItem() instanceof PickaxeItem t && t.getTier().getLevel() >= level) {
				ci.setReturnValue(true);
				ci.cancel();
			}
		});
	}

	private static Optional<Integer> map_id_level(String id) {
		return switch (id) {
			case
				"minecraft:copper_ore",
				"spelunkery:granite_copper_ore"
				-> Optional.of(0);
			case
				"minecraft:deepslate",
				"minecraft:cobbled_deepslate",
				"minecraft:polished_deepslate",
				"minecraft:deepslate_bricks",
				"minecraft:cracked_deepslate_bricks",
				"minecraft:deepslate_tiles",
				"minecraft:cracked_deepslate_tiles",
				"minecraft:chiseled_deepslate",
				"minecraft:deepslate_coal_ore",
				"minecraft:deepslate_iron_ore",
				"minecraft:deepslate_copper_ore",
				"minecraft:deepslate_redstone_ore"
				-> Optional.of(1);
			case
				"minecraft:deepslate_gold_ore",
				"minecraft:deepslate_diamond_ore",
				"minecraft:deepslate_lapis_ore",
				"minecraft:deepslate_emerald_ore"
				-> Optional.of(2);
			default -> Optional.empty();
		};
	}
}
