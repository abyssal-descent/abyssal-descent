package AbyssalDescent.adresources;

import AbyssalDescent.adresources.Registry;

import net.minecraftforge.fml.ModList;
import net.minecraftforge.fml.ModLoadingException;
import net.minecraftforge.fml.ModLoadingStage;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;

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
}
