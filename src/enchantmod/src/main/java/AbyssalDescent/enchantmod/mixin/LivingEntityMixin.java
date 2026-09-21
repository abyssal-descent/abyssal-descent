package AbyssalDescent.enchantmod.mixin;

import AbyssalDescent.enchantmod.enchant.Enchant;

import net.minecraft.world.entity.EquipmentSlot;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.enchantment.EnchantmentHelper;
import net.minecraft.world.damagesource.DamageSource;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.ModifyVariable;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(LivingEntity.class)
public class LivingEntityMixin {
	@Inject(method = "baseTick", at = @At("HEAD"))
	private void base_tick(CallbackInfo ci) {
		var entity = (LivingEntity) (Object) this;

		for (var slot : EquipmentSlot.values()) {
			var stack = entity.getItemBySlot(slot);
			if (stack.isEmpty()) continue;

			for (var enchant : EnchantmentHelper.getEnchantments(stack).keySet()) {
				var behaviour = Enchant.get(enchant);
				if (behaviour == null) continue;
				behaviour.on_tick(entity, stack);
			}
		}
	}

	@ModifyVariable(method = "hurt", at = @At("HEAD"), argsOnly = true, ordinal = 0)
	private float hurt(float amount, DamageSource source) {
		var entity = (LivingEntity) (Object) this;

		for (var slot : EquipmentSlot.values()) {
			var stack = entity.getItemBySlot(slot);
			if (stack.isEmpty()) continue;

			for (var enchant : EnchantmentHelper.getEnchantments(stack).keySet()) {
				var behaviour = Enchant.get(enchant);
				if (behaviour == null) continue;
				amount *= behaviour.damage_taken_mul(stack, source, amount, entity);
			}
		}

		return amount;
	}
}
