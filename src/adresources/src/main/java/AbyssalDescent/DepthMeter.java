package AbyssalDescent.adresources;

import net.minecraft.client.Minecraft;

import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.client.event.CustomizeGuiOverlayEvent;
import net.minecraftforge.common.ForgeConfigSpec;
import net.minecraftforge.api.distmarker.Dist;

@Mod.EventBusSubscriber(value = Dist.CLIENT)
public class DepthMeter {
	private static final int COLOUR = 0xE0E0E0;

	@SubscribeEvent
	public static void renderGameOverlayEvent(CustomizeGuiOverlayEvent.DebugText event) {
		final var inst = Minecraft.getInstance();
		if (inst.options.renderDebug || inst.player == null) return;

		final var pos = inst.player.blockPosition();
		final var dim = inst.player.level().dimension().location().toString();

		event.getGuiGraphics().drawString(
			inst.font,
			String.format("X: %d, Y: %d, Z: %d", pos.getX(), pos.getY() - get_offset(dim), pos.getZ()),
			Config.OVERLAY_X.get(), Config.OVERLAY_Y.get(), DepthMeter.COLOUR);
	}

	static int get_offset(String dim) {
		return switch (dim) {
			case "aether:the_aether"              -> -496;
			case "minecraft:overworld"            -> 0;
			case "delverbegin:delversbeginnings"  -> 64 + 128;
			case "undergarden:undergarden"        -> 64 + 128 + 128;
			case "infernalcross:infernalcrossing" -> 64 + 128 + 128 + 64;
			case "minecraft:the_nether"           -> 64 + 128 + 128 + (64 + 64) + 128;
			default                               -> 0;
		};
	}

	public static class Config {
		private static final ForgeConfigSpec.Builder BUILDER = new ForgeConfigSpec.Builder();

		public static final ForgeConfigSpec.IntValue OVERLAY_X = BUILDER
			.comment("Overlay X offset")
			.defineInRange("offset_x", 5, 0, Integer.MAX_VALUE);

		public static final ForgeConfigSpec.IntValue OVERLAY_Y = BUILDER
			.comment("Overlay Y offset")
			.defineInRange("offset_y", 5, 0, Integer.MAX_VALUE);

		public static final ForgeConfigSpec SPEC = BUILDER.build();
	}
}
