package AbyssalDescent.enchantmod.enchant;

import net.minecraft.ChatFormatting;
import net.minecraft.world.damagesource.DamageSource;
import net.minecraft.world.damagesource.DamageTypes;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.ArmorItem;
import net.minecraft.world.item.ItemStack;

public class BlastProtection implements Enchant.Behaviour {
	@Override
	public ChatFormatting get_format() {
		return ChatFormatting.DARK_GRAY;
	}

	@Override
	public boolean can_enchant(ItemStack stack) {
		return stack.getItem() instanceof ArmorItem;
	}

	@Override
	public float damage_taken_mul(ItemStack stack, DamageSource source, float amount, LivingEntity entity) {
		return (source.is(DamageTypes.EXPLOSION) || source.is(DamageTypes.PLAYER_EXPLOSION)) ? 0.4F : 1.0F;
	}
}
