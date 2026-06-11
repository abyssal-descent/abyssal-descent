package AbyssalDescent.adhammers;

import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.resources.ResourceLocation;

public class Resolve {
	public static Item item(String rid) {
		return BuiltInRegistries.ITEM.get(new ResourceLocation(rid));
	}

	public static ItemStack itemstack(String rid, int count) {
		return new ItemStack(BuiltInRegistries.ITEM.get(new ResourceLocation(rid)), count);
	}
}
