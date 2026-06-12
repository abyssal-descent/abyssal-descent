package AbyssalDescent.durabilitytooltip;

import net.minecraft.network.chat.Component;
import net.minecraft.ChatFormatting;

import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.event.entity.player.ItemTooltipEvent;
import net.minecraftforge.eventbus.api.EventPriority;
import net.minecraftforge.fml.ModLoadingContext;
import net.minecraftforge.fml.IExtensionPoint;
import net.minecraftforge.api.distmarker.Dist;

@Mod(DurabilityTooltip.MODID)
public class DurabilityTooltip {
	public static final String MODID = "durabilitytooltip";

	public DurabilityTooltip() {
		ModLoadingContext.get().registerExtensionPoint(
			IExtensionPoint.DisplayTest.class,
			() -> new IExtensionPoint.DisplayTest(() -> IExtensionPoint.DisplayTest.IGNORESERVERONLY, (a, b) -> true));
	}

	@Mod.EventBusSubscriber(value = Dist.CLIENT, bus = Mod.EventBusSubscriber.Bus.FORGE)
	public static class DurabilityEvent {
		@SubscribeEvent(priority = EventPriority.LOW)
		public static void onTooltip(ItemTooltipEvent e) {
			var stack = e.getItemStack();

			if (!stack.isDamageableItem()) return;
			if (e.getFlags().isAdvanced() && stack.isDamaged()) return;

			var max = stack.getMaxDamage();

			if (!stack.isDamaged()) {
				e.getToolTip().add(Component.translatable("durabilitytooltip.max_durability",
					Component.literal(Integer.toString(max)).withStyle(ChatFormatting.GOLD)));
				return;
			}

			var cur = max - stack.getDamageValue();
			e.getToolTip().add(Component.translatable("durabilitytooltip.durability",
				Component.literal(Integer.toString(cur)).withStyle(ChatFormatting.GOLD),
				Component.literal(Integer.toString(max)).withStyle(ChatFormatting.GOLD)));
		}
	}
}
