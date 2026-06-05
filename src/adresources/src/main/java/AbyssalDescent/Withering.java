package AbyssalDescent.adresources;

import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.entity.EquipmentSlot;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.world.effect.MobEffects;
import net.minecraft.world.item.enchantment.Enchantment;
import net.minecraft.world.item.enchantment.EnchantmentCategory;
import net.minecraft.world.item.enchantment.EnchantmentHelper;

import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.event.entity.living.LivingDamageEvent;

@Mod.EventBusSubscriber(modid = ADResources.MODID)
public class Withering {
	@SubscribeEvent
	public static void onAttack(LivingDamageEvent event) {
		if (!(event.getSource().getEntity() instanceof Player player))
			 return;

		var level = EnchantmentHelper.getItemEnchantmentLevel(
			Registry.WITHERING_ENCHANTMENT.get(),
			player.getMainHandItem()
		);

		if (level <= 0) return;

		event.getEntity().addEffect(new MobEffectInstance(MobEffects.WITHER, 40 * level, level - 1));
	}


	public static class WitheringEnchantment extends Enchantment {
		public WitheringEnchantment() {
			super(Enchantment.Rarity.RARE, EnchantmentCategory.WEAPON, new EquipmentSlot[] { EquipmentSlot.MAINHAND });
		}

		@Override
		public int getMaxLevel() { return 3; }

		@Override
		public int getMinCost(int lvl) { return 10 + 20 * (lvl - 1); }

		@Override
		public int getMaxCost(int lvl) { return getMinCost(lvl) + 50; }

		@Override
		public boolean isTreasureOnly() { return true; }
	}
}
