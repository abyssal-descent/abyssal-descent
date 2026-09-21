package AbyssalDescent.adresources;

import com.mojang.math.Axis;

import net.minecraft.util.Mth;
import net.minecraft.core.BlockPos;
import net.minecraft.client.Minecraft;
import net.minecraft.client.renderer.LevelRenderer;
import net.minecraft.client.renderer.texture.OverlayTexture;
import net.minecraft.world.item.Items;
import net.minecraft.world.item.ItemDisplayContext;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.enchantment.Enchantments;
import net.minecraft.world.item.enchantment.EnchantmentHelper;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.resources.ResourceLocation;

import net.minecraftforge.api.distmarker.Dist;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.client.event.RenderPlayerEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.eventbus.api.EventPriority;

import java.util.*;
import java.net.URI;
import java.net.http.*;

@Mod.EventBusSubscriber(modid = ADResources.MODID, value = Dist.CLIENT)
public class PlayerHeadItem {
	private static final Map<UUID, ItemStack> ITEMS = new HashMap<>();

	static {
		load_from("https://raw.githubusercontent.com/abyssal-descent/abyssal-descent/refs/heads/master/donors.csv");
	}

	private static void load_from(String url) {
		try {
			var client = HttpClient.newHttpClient();
			var req = HttpRequest.newBuilder().uri(URI.create(url)).build();
			
			client.sendAsync(req, HttpResponse.BodyHandlers.ofString())
				.thenAccept(r -> {
					if (r.statusCode() != 200)
						throw new RuntimeException("Failed to load PlayerHeadItems: HTTP " + r.statusCode());

					for (var line : r.body().split("\\R")) {
						line = line.trim();
						if (line.isEmpty() || line.startsWith("#")) continue;

						var parts = line.split(",", 4);
						if (parts.length < 3) continue;

						var uuid = UUID.fromString(parts[1].trim());
						var stack = new ItemStack(BuiltInRegistries.ITEM.get(
							ResourceLocation.tryParse(parts[2].trim())));

						if (parts.length == 4 && parts[3].trim().equals("enchanted"))
							EnchantmentHelper.setEnchantments(Map.of(Enchantments.UNBREAKING, 1), stack);

						ITEMS.put(uuid, stack);
					}
				})
				.exceptionally(e -> {
					ADResources.LOGGER.error("{}", e);
					return null;
				});
		} catch (Exception e) {
			ADResources.LOGGER.error("{}", e);
		}
	}

	@SubscribeEvent(priority = EventPriority.HIGHEST)
	public static void render(RenderPlayerEvent.Post e) {
		var player = e.getEntity();
		var stack = ITEMS.get(player.getUUID());

		if (stack == null || stack.isEmpty()) return;

		var mc = Minecraft.getInstance();
		var level = player.level();
		var t = player.tickCount + e.getPartialTick();

		var light = e.getPackedLight();
		var ps = e.getPoseStack();
		var buf = e.getMultiBufferSource();

		ps.pushPose();
		ps.translate(0.0, player.getBbHeight() + 0.35 + Mth.sin(t * 0.1f) * 0.05f, 0.0);
		ps.mulPose(Axis.YP.rotationDegrees(t * 2.0f));

		mc.getItemRenderer().renderStatic(stack, ItemDisplayContext.GROUND,
			light, OverlayTexture.NO_OVERLAY, ps, buf, level, 0);

		ps.popPose();
	}
}
