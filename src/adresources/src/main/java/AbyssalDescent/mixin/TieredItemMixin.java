package AbyssalDescent.adresources.mixin;

import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.world.item.Tier;
import net.minecraft.world.item.crafting.Ingredient;
import net.minecraft.world.item.TieredItem;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.util.Optional;

@Mixin(TieredItem.class)
public abstract class TieredItemMixin {
	@Inject(method = "getTier", at = @At("RETURN"), cancellable = true)
	private void getTier(CallbackInfoReturnable<Tier> cir) {
		var self = (TieredItem) (Object) this;

		var lvl = toolid_to_lvl(BuiltInRegistries.ITEM.getKey(self).toString());
		if (lvl.isEmpty()) return;

		var tier = cir.getReturnValue();

		cir.setReturnValue(new Tier() {
			@Override public int getUses() { return tier.getUses(); }
			@Override public float getSpeed() { return tier.getSpeed(); }
			@Override public float getAttackDamageBonus() { return tier.getAttackDamageBonus(); }
			@Override public int getEnchantmentValue() { return tier.getEnchantmentValue(); }
			@Override public Ingredient getRepairIngredient() { return tier.getRepairIngredient(); }
			@Override public int getLevel() { return lvl.get(); }
		});
	}

	private static Optional<Integer> toolid_to_lvl(String rid) {
		return switch (rid) {
			case
				"minecraft:golden_pickaxe",
				"caverns_and_chasms:silver_pickaxe"
				-> Optional.of(2);
			default -> Optional.empty();
		};
	}
}
