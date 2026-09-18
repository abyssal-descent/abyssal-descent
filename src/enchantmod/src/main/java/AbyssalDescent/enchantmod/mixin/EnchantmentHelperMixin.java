package AbyssalDescent.enchantmod.mixin;

import AbyssalDescent.enchantmod.enchant.Enchant;

import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.MobType;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.enchantment.EnchantmentHelper;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(EnchantmentHelper.class)
public class EnchantmentHelperMixin {
	@Inject(method = "getDamageBonus", at = @At("RETURN"), cancellable = true)
	private static void getDamageBonus(ItemStack stack, MobType mob_type, CallbackInfoReturnable<Float> cir) {
		var damage = cir.getReturnValue();

		for (var enchant : EnchantmentHelper.getEnchantments(stack).keySet()) {
			var behavior = Enchant.get(enchant);
			if (behavior == null) continue;
			damage += behavior.damage_bonus(stack, mob_type);
		}

		cir.setReturnValue(damage);
	}
}
