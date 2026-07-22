package AbyssalDescent.adresources;

import net.minecraft.world.level.GameRules;

import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.event.server.ServerStartedEvent;

@Mod.EventBusSubscriber(modid = ADResources.MODID)
public class InitialGameRule {
	@SubscribeEvent
	public static void onServerStartup(ServerStartedEvent e) {
		e.getServer().overworld().getGameRules()
			.getRule(GameRules.RULE_DOINSOMNIA)
			.set(false, e.getServer());
	}
}
