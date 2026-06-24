package AbyssalDescent.adresources;

import AbyssalDescent.adresources.Registry;

import net.minecraft.world.level.block.Blocks;

import net.minecraftforge.fml.ModList;
import net.minecraftforge.fml.ModLoadingException;
import net.minecraftforge.fml.ModLoadingStage;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;
import net.minecraftforge.event.TickEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;

import java.util.Arrays;

@Mod(ADResources.MODID)
public class ADResources {
	public static final String MODID = "adresources";
	public static Registry REGISTRY = null;

	private static final String[] MOD_BLACKLIST = { 
		"essential"
	};

	public ADResources() {
		this.REGISTRY = new Registry(FMLJavaModLoadingContext.get().getModEventBus());

		Arrays.stream(MOD_BLACKLIST)
			.filter(id -> ModList.get().isLoaded(id))
			.findFirst().ifPresent(id -> {
				throw new ModLoadingException(
					ModList.get().getModContainerById(MODID).orElseThrow().getModInfo(),
					ModLoadingStage.CONSTRUCT,
					("\n   Abyssal Descent is INCOMPATIBLE with " + id).repeat(50),
					new IllegalStateException("incompatible mod"));
			});
	}

	@Mod.EventBusSubscriber(modid = MODID)
	public static class Events {
		@SubscribeEvent
		public static void onPlayerTick(TickEvent.PlayerTickEvent e) {
			if (e.phase != TickEvent.Phase.END) return;
			
			var level = e.player.level();
			if (level.isClientSide()) return;
			if (!level.getBlockState(e.player.blockPosition()).is(Blocks.STONECUTTER)) return;

			e.player.hurt(e.player.damageSources().generic(), 1.0F);
		}
	}
}
