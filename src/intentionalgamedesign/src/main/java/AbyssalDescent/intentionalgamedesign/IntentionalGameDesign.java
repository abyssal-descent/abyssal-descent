package AbyssalDescent.intentionalgamedesign;

import net.minecraft.world.level.Level;
import net.minecraft.server.level.ServerLevel;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.event.level.BlockEvent;

@Mod(IntentionalGameDesign.MODID)
public class IntentionalGameDesign {
	public static final String MODID = "intentionalgamedesign";

	public IntentionalGameDesign() {
		MinecraftForge.EVENT_BUS.register(this);
	}

	@SubscribeEvent
	public void onPortalSpawn(BlockEvent.PortalSpawnEvent e) {
		if (!(e.getLevel() instanceof ServerLevel server)) return;

		var pos = e.getPos();

		server.explode(null,
			pos.getX() + 0.5, pos.getY() + 0.5, pos.getZ() + 0.5,
			5.0F, true, Level.ExplosionInteraction.BLOCK);

		e.setCanceled(true);
	}
}
