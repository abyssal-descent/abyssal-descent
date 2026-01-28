package AbyssalDescent.adresources;

import AbyssalDescent.adresources.Registry;

import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;

@Mod(ADResources.MODID)
public class ADResources {
	public static final String MODID = "adresources";
	public static Registry REGISTRY = null;

	public ADResources() {
		this.REGISTRY = new Registry(FMLJavaModLoadingContext.get().getModEventBus());
	}
}
