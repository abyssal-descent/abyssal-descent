package AbyssalDescent.enchantmod.enchant;

import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.enchantment.Enchantment;
import net.minecraft.world.item.enchantment.Enchantments;

import java.util.*;

public class Enchant {
	private static final Map<Enchantment, Behaviour> BEHAVIOURS = Map.of(
		Enchantments.SMITE,       new Smite(),
		Enchantments.RESPIRATION, new Respiration(),
		Enchantments.UNBREAKING,  new Unbreaking()
	);

	public interface Behaviour {
		String get_tooltip();
		default boolean can_enchant(ItemStack stack) { return true; }
		default boolean on_hurt(ItemStack stack, int amount, LivingEntity entity) { return false; }
		default void on_attack(ServerLevel level, LivingEntity attacker, LivingEntity target, ItemStack stack) {}
		default void on_tick(LivingEntity entity, ItemStack stack) {}
	}

	public static Behaviour get(Enchantment enchant) {
		return BEHAVIOURS.get(enchant);
	}
}
