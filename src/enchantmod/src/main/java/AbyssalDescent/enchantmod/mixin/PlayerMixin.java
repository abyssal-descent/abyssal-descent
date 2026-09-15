package AbyssalDescent.enchantmod.mixin;

import AbyssalDescent.enchantmod.enchant.Enchant;

import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.enchantment.EnchantmentHelper;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(Player.class)
public class PlayerMixin {
	@Inject(method = "attack", at = @At("TAIL"))
	private void attack(Entity target, CallbackInfo ci) {
		var player = (Player) (Object) this;

		if (!(player.level() instanceof ServerLevel server)) return;
		if (!(target instanceof LivingEntity target_l)) return;

		var stack = player.getMainHandItem();
		if (stack.isEmpty()) return;

		for (var enchant : EnchantmentHelper.getEnchantments(stack).keySet()) {
			var behaviour = Enchant.get(enchant);
			if (behaviour == null) continue;
			behaviour.on_attack(server, player, target_l, stack);
		}
	}
}
