package AbyssalDescent.enchantmod.mixin;

import AbyssalDescent.enchantmod.enchant.Enchant;

import it.unimi.dsi.fastutil.objects.ObjectArrayList;

import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.enchantment.EnchantmentHelper;
import net.minecraft.world.level.storage.loot.LootContext;
import net.minecraft.world.level.storage.loot.LootTable;
import net.minecraft.world.level.storage.loot.parameters.LootContextParams;
import net.minecraft.world.item.enchantment.EnchantmentHelper;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(LootTable.class)
public class LootTableMixin {
	@Inject(method = "getRandomItems(Lnet/minecraft/world/level/storage/loot/LootContext;)Lit/unimi/dsi/fastutil/objects/ObjectArrayList;", at = @At("RETURN"), cancellable = true)
	private void get_random_items(LootContext ctx, CallbackInfoReturnable<ObjectArrayList<ItemStack>> cir) {
		var stack = ctx.getParamOrNull(LootContextParams.TOOL);
		if (stack == null || stack.isEmpty()) return;

		var entity = ctx.getParamOrNull(LootContextParams.THIS_ENTITY);
		if (!(entity instanceof LivingEntity)) return;

		var level = ctx.getLevel();
		var mul = 1.0F;

		for (var enchant : EnchantmentHelper.getEnchantments(stack).keySet()) {
			var behaviour = Enchant.get(enchant);
			if (behaviour == null) continue;
			mul *= behaviour.loot_mul(level, stack);
		}

		if (mul == 1.0F) return;
		var drops = cir.getReturnValue();

		if (mul <= 0.0) {
			drops.clear();
			return;
		}

		for (var drop : drops)
			drop.setCount(Math.round(drop.getCount() * mul));
	}
}
