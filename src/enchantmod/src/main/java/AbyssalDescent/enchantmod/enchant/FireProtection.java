package AbyssalDescent.enchantmod.enchant;

import net.minecraft.ChatFormatting;
import net.minecraft.world.damagesource.DamageSource;
import net.minecraft.world.damagesource.DamageTypes;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.ArmorItem;
import net.minecraft.world.item.ItemStack;

public class FireProtection implements Enchant.Behaviour {
	@Override
	public ChatFormatting get_format() {
		return ChatFormatting.RED;
	}

	@Override
	public boolean can_enchant(ItemStack stack) {
		return stack.getItem() instanceof ArmorItem;
	}

	@Override
	public float damage_taken_mul(ItemStack stack, DamageSource source, LivingEntity entity) {
		if (source.is(DamageTypes.HOT_FLOOR)
			|| source.is(DamageTypes.IN_FIRE)
			|| source.is(DamageTypes.ON_FIRE)) return 0.0F;

		return (source.is(DamageTypes.LAVA)) ? 0.6F : 1.0F;
	}

	@Override
	public boolean can_burn(ItemStack stack) { return false; }
}
