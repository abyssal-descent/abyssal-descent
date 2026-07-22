package AbyssalDescent.adresources;

import net.minecraft.world.level.block.Blocks;

import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.event.TickEvent;

@Mod.EventBusSubscriber(modid = ADResources.MODID)
public class StoneCutterHurt {
	@SubscribeEvent
	public static void onPlayerTick(TickEvent.PlayerTickEvent e) {
		if (e.phase != TickEvent.Phase.END) return;
		
		var level = e.player.level();
		if (level.isClientSide()) return;
		if (!level.getBlockState(e.player.blockPosition()).is(Blocks.STONECUTTER)) return;

		e.player.hurt(e.player.damageSources().generic(), 1.0F);
	}
}
