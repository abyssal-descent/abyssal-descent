package AbyssalDescent.enchantmod.enchant;

import net.minecraft.ChatFormatting;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.EntityType;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.entity.MobType;

public class Fortune implements Enchant.Behaviour {
	private static final float MULTIPLIER = 2.0F;

	@Override
	public ChatFormatting get_format() {
		return ChatFormatting.GOLD;
	}

	@Override
	public float loot_mul(ServerLevel level, ItemStack stack) {
		return level.random.nextFloat() * MULTIPLIER;
	}
}
