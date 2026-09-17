package AbyssalDescent.enchantmod.enchant;

import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.EntityType;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.entity.MobType;

public class Unbreaking implements Enchant.Behaviour {
	@Override
	public String get_tooltip() {
		return "Shall never break";
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
	public float map_damage_bonus(ItemStack stack, MobType mob_type, float bonus) {
		return (stack.getDamageValue() >= stack.getMaxDamage()) ? -1000.0F : bonus;
	}

	@Override
	public float map_mining_speed(ItemStack stack, float speed) { 
		return (stack.getDamageValue() >= stack.getMaxDamage()) ? 0.0F : speed;
	}
}
