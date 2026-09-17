package AbyssalDescent.enchantmod.mixin;

import AbyssalDescent.enchantmod.enchant.Enchant;

import net.minecraft.ChatFormatting;
import net.minecraft.network.chat.Component;
import net.minecraft.world.entity.MobType;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.enchantment.Enchantment;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(Enchantment.class)
public class EnchantmentMixin {
	@Inject(method = "getMinLevel", at = @At("HEAD"), cancellable = true)
	private void min_level(CallbackInfoReturnable<Integer> cir) {
		if (Enchant.get((Enchantment) (Object) this) == null) return;
		cir.setReturnValue(1);
		cir.cancel();
	}

	@Inject(method = "getMaxLevel", at = @At("HEAD"), cancellable = true)
	private void max_level(CallbackInfoReturnable<Integer> cir) {
		if (Enchant.get((Enchantment) (Object) this) == null) return;
		cir.setReturnValue(1);
		cir.cancel();
	}

	@Inject(method = "canEnchant", at = @At("HEAD"), cancellable = true)
	private void can_enchant(ItemStack stack, CallbackInfoReturnable<Boolean> cir) {
		var behaviour = Enchant.get((Enchantment) (Object) this);
		if (behaviour == null) return;
		cir.setReturnValue(behaviour.can_enchant(stack));
		cir.cancel();
	}

	@Inject(method = "getFullname", at = @At("HEAD"), cancellable = true)
	private void get_fullname(int level, CallbackInfoReturnable<Component> cir) {
		var enchant = (Enchantment) (Object) this;
		if (Enchant.get(enchant) == null) return;
		cir.setReturnValue(Component.translatable(enchant.getDescriptionId())
			.withStyle(ChatFormatting.GRAY));
		cir.cancel();
	}
}
