package AbyssalDescent.enchantmod.mixin;

import AbyssalDescent.enchantmod.enchant.Enchant;

import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.enchantment.EnchantmentHelper;
import net.minecraft.world.level.block.state.BlockState;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

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

	@Inject(method = "getDestroySpeed", at = @At("RETURN"), cancellable = true)
	private void get_destroy_speed(BlockState state, CallbackInfoReturnable<Float> cir) {
		var stack = (ItemStack) (Object) this;
		var speed = cir.getReturnValue();

		for (var enchant : EnchantmentHelper.getEnchantments(stack).keySet()) {
			var behaviour = Enchant.get(enchant);
			if (behaviour == null) continue;
			speed *= behaviour.mining_speed_mul(stack);
		}

		cir.setReturnValue(speed);
	}
}
