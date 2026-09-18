package AbyssalDescent.enchantmod.enchant;

import net.minecraft.ChatFormatting;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.world.effect.MobEffects;

public class Impaling implements Enchant.Behaviour {
	@Override
	public ChatFormatting get_format() {
		return ChatFormatting.WHITE;
	}

	@Override
	public void on_attack(ServerLevel level, LivingEntity attacker, LivingEntity target, ItemStack stack) {
		target.addEffect(new MobEffectInstance(MobEffects.MOVEMENT_SLOWDOWN, 100, 0));
		target.addEffect(new MobEffectInstance(MobEffects.WEAKNESS, 100, 1));
	}
}
