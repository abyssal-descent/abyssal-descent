package AbyssalDescent.adresources.mixin;

import com.google.gson.JsonElement;

import net.minecraft.resources.ResourceLocation;
import net.minecraft.server.ServerAdvancementManager;
import net.minecraft.server.packs.resources.ResourceManager;
import net.minecraft.util.profiling.ProfilerFiller;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

import java.util.Map;
import java.util.Set;

@Mixin(ServerAdvancementManager.class)
public class ServerAdvancementManagerMixin {
	private static final Set<String> WHITELIST = Set.of(
		"adresources"
	);

	@Inject(method = "apply", at = @At("HEAD"))
	private void atApply(Map<ResourceLocation, JsonElement> map, ResourceManager rm, ProfilerFiller pf, CallbackInfo ci) {
		map.entrySet().removeIf(e -> !WHITELIST.contains(e.getKey().getNamespace()));
	}
}
