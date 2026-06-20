package AbyssalDescent.adresources.mixin;

import net.minecraft.world.item.BundleItem;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.Constant;
import org.spongepowered.asm.mixin.injection.ModifyConstant;

@Mixin(BundleItem.class)
public class BundleItemMixin {
	@ModifyConstant(method = "*", constant = @Constant(intValue = 64))
	private static int capacity(int size) { return 80; }
}
