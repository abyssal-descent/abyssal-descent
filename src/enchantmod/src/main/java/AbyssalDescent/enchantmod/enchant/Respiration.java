package AbyssalDescent.enchantmod.enchant;

import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.entity.EquipmentSlot;
import net.minecraft.world.item.ArmorItem;

public class Respiration implements Enchant.Behaviour {
	@Override
	public String get_tooltip() {
		return "Allows breathing underwater";
	}

	@Override
	public boolean can_enchant(ItemStack stack) {
		return stack.getItem() instanceof ArmorItem armor &&
			armor.getEquipmentSlot() == EquipmentSlot.HEAD;
	}

	@Override
	public void on_tick(LivingEntity entity, ItemStack stack) {
		if (!entity.isUnderWater()) return;
		entity.setAirSupply(entity.getMaxAirSupply());
	}
}
