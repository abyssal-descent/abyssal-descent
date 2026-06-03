package AbyssalDescent.adresources;

import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.network.chat.Component;
import net.minecraft.ChatFormatting;

import net.minecraftforge.event.entity.player.ItemTooltipEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;

@Mod.EventBusSubscriber(modid = ADResources.MODID, bus = Mod.EventBusSubscriber.Bus.FORGE)
public class Tooltips {
	@SubscribeEvent
	public static void itemTooltip(ItemTooltipEvent e) {
		var rid = BuiltInRegistries.ITEM.getKey(e.getItemStack().getItem());
		var key = "tooltip." + rid.getNamespace() + "." + rid.getPath();

		var text = Component.translatable(key);

		if (!text.getString().equals(key)) {
			e.getToolTip().add(text.withStyle(ChatFormatting.ITALIC).withStyle(ChatFormatting.GRAY));
		}
	}
}
