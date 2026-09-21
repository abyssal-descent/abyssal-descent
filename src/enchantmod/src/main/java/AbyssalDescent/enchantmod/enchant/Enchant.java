package AbyssalDescent.enchantmod.enchant;

import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.enchantment.Enchantment;
import net.minecraft.world.item.enchantment.Enchantments;
import net.minecraft.world.damagesource.DamageSource;
import net.minecraft.world.entity.MobType;
import net.minecraft.ChatFormatting;

import java.util.*;

public class Enchant {
	private static final Map<Enchantment, Behaviour> BEHAVIOURS = Map.of(
		Enchantments.SMITE,            new Smite(),
		Enchantments.RESPIRATION,      new Respiration(),
		Enchantments.UNBREAKING,       new Unbreaking(),
		Enchantments.IMPALING,         new Impaling(),
		Enchantments.BLOCK_FORTUNE,    new Fortune(),
		Enchantments.BLAST_PROTECTION, new BlastProtection()
	);

	public interface Behaviour {
		default ChatFormatting get_format() { return ChatFormatting.GRAY; };
		default boolean can_enchant(ItemStack stack) { return true; }
		default boolean on_tool_damage(ItemStack stack, int amount, LivingEntity entity) { return false; }
		default void on_attack(ServerLevel level, LivingEntity attacker, LivingEntity target, ItemStack stack) {}
		default void on_tick(LivingEntity entity, ItemStack stack) {}
		default float damage_taken_mul(ItemStack stack, DamageSource source, float amount, LivingEntity entity) { return 1.0F; }
		default float damage_bonus(ItemStack stack, MobType mob_type) { return 1.0F; }
		default float mining_speed_mul(ItemStack stack) { return 1.0F; }
		default float loot_mul(ServerLevel level, ItemStack stack) { return 1.0F; }
	}

	public static Behaviour get(Enchantment enchant) {
		return BEHAVIOURS.get(enchant);
	}
}
