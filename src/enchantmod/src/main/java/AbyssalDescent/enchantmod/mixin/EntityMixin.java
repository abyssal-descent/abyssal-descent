package AbyssalDescent.enchantmod.mixin;

import AbyssalDescent.enchantmod.enchant.Enchant;

import net.minecraft.world.entity.EquipmentSlot;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.enchantment.EnchantmentHelper;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(Entity.class)
public class EntityMixin {
	@Inject(method = "setSecondsOnFire", at = @At("HEAD"), cancellable = true)
	private void set_seconds_on_fire(int seconds, CallbackInfo ci) {
		var entity_t = (Entity) (Object) this;
		if (!(entity_t instanceof LivingEntity entity)) return;

		for (var slot : EquipmentSlot.values()) {
			var stack = entity.getItemBySlot(slot);
			if (stack.isEmpty()) continue;

			for (var enchant : EnchantmentHelper.getEnchantments(stack).keySet()) {
				var behaviour = Enchant.get(enchant);
				if (behaviour == null) continue;
				if (!behaviour.can_burn(stack)) {
					entity.setRemainingFireTicks(0);
					ci.cancel();
					return;
				}
			}
		}
	}
}
