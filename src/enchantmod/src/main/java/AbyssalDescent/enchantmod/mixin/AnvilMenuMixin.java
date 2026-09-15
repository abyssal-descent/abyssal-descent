package AbyssalDescent.enchantmod.mixin;

import net.minecraft.world.inventory.AnvilMenu;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.ModifyConstant;
import org.spongepowered.asm.mixin.injection.Constant;

@Mixin(AnvilMenu.class)
public abstract class AnvilMenuMixin {
	@ModifyConstant(method = "createResult", constant = @Constant(intValue = 40))
	private int removeTooExpensiveLimit(int value) {
		return Integer.MAX_VALUE;
	}
}
