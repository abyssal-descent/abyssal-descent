package AbyssalDescent.enchantmod.enchant;

import net.minecraft.ChatFormatting;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.EntityType;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.entity.MobType;

public class Unbreaking implements Enchant.Behaviour {
	@Override
	public ChatFormatting get_format() {
		return ChatFormatting.WHITE;
	}

	@Override
	public boolean can_enchant(ItemStack stack) {
		return stack.isDamageableItem();
	}

	@Override
	public boolean on_hurt(ItemStack stack, int amount, LivingEntity entity) {
		var damage = Math.min(
			stack.getDamageValue() + amount,
			stack.getMaxDamage());

		stack.setDamageValue(damage);
		return true;
	}

	@Override
	public float damage_bonus(ItemStack stack, MobType mob_type) {
		return (stack.getDamageValue() >= stack.getMaxDamage()) ? -1000.0F : 1.0F;
	}

	@Override
	public float mining_speed_mul(ItemStack stack) { 
		return (stack.getDamageValue() >= stack.getMaxDamage()) ? 0.0F : 1.0F;
	}
}
