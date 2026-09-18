package AbyssalDescent.enchantmod.enchant;

import net.minecraft.ChatFormatting;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.EntityType;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;

public class Smite implements Enchant.Behaviour {
	private static final int COOLDOWN = 40;

	@Override
	public ChatFormatting get_format() {
		return ChatFormatting.BLUE;
	}

	@Override
	public void on_attack(ServerLevel level, LivingEntity attacker, LivingEntity target, ItemStack stack) {
		if (attacker instanceof Player player
			&& player.getCooldowns().isOnCooldown(stack.getItem()))
			return;

		var lighting = EntityType.LIGHTNING_BOLT.create(level);
		lighting.moveTo(target.position());
		level.addFreshEntity(lighting);

		if (attacker instanceof Player player)
			player.getCooldowns().addCooldown(stack.getItem(), COOLDOWN);
	}
}
