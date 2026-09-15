package AbyssalDescent.enchantmod.mixin;

import AbyssalDescent.enchantmod.enchant.Enchant;

import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.enchantment.EnchantmentHelper;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

import java.util.function.Consumer;

@Mixin(ItemStack.class)
public class ItemStackMixin {
	@Inject(method = "hurtAndBreak", at = @At("HEAD"), cancellable = true)
	private <T extends LivingEntity> void hurt_and_break(
		int amount, T entity, Consumer<T> on_broken, CallbackInfo ci
	) {
		var stack = (ItemStack) (Object) this;

		for (var enchant : EnchantmentHelper.getEnchantments(stack).keySet()) {
			var behaviour = Enchant.get(enchant);
			if (behaviour != null && behaviour.on_hurt(stack, amount, entity))
				ci.cancel();
		}
	}
}
