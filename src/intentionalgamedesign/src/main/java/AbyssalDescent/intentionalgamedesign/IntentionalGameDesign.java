package AbyssalDescent.intentionalgamedesign;

import net.minecraft.world.level.Level;
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
		if (!(e.getLevel() instanceof Level level)) return;

		var pos = e.getPos();

		level.explode(null,
			pos.getX() + 0.5, pos.getY() + 0.5, pos.getZ() + 0.5,
			5.0F, Level.ExplosionInteraction.BLOCK);

		e.setCanceled(true);
	}
}
