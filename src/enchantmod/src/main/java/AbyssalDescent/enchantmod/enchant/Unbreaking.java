package AbyssalDescent.enchantmod.enchant;

import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.EntityType;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;

public class Unbreaking implements Enchant.Behaviour {
	@Override
	public String get_tooltip() {
		return "Shall never break";
	}

	@Override
	public boolean on_hurt(ItemStack stack, int amount, LivingEntity entity) {
		var damage = Math.min(
			stack.getDamageValue() + amount,
			stack.getMaxDamage());

		stack.setDamageValue(damage);
		return true;
	}
}
