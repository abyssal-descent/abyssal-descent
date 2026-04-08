package AbyssalDescent.depthmeter;

import com.mojang.logging.LogUtils;

import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.Font;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.components.EditBox;
import net.minecraft.client.gui.components.Button;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.network.chat.Component;
import net.minecraft.network.chat.CommonComponents;

import net.minecraftforge.fml.config.ModConfig;
import net.minecraftforge.fml.ModLoadingContext;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.client.event.CustomizeGuiOverlayEvent;
import net.minecraftforge.client.ConfigScreenHandler;
import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.common.ForgeConfigSpec;

import java.util.function.Function;

import org.slf4j.Logger;

@Mod(DepthMeter.MODID)
public class DepthMeter {
	public static final String MODID = "depthmeter";
	private static final Logger LOGGER = LogUtils.getLogger();

	public static final int COLOUR = 0xE0E0E0;

	public DepthMeter() {
		MinecraftForge.EVENT_BUS.register(this);
		ModLoadingContext.get().registerConfig(ModConfig.Type.CLIENT, Config.SPEC);

		ModLoadingContext.get().registerExtensionPoint(ConfigScreenHandler.ConfigScreenFactory.class,
			() -> new ConfigScreenHandler.ConfigScreenFactory((minecraft, screen) -> new ConfigScreen(screen))
		);
	}

	@Mod.EventBusSubscriber
	public static class PlayerEvents {
		@SubscribeEvent
		public static void renderGameOverlayEvent(CustomizeGuiOverlayEvent.DebugText event) {
			final var inst = Minecraft.getInstance();
			if (inst.options.renderDebug || inst.player == null) return;

			try {
				final var pos = inst.player.blockPosition();
				final var dim = inst.player.level().dimension().location().toString();

				event.getGuiGraphics().drawString(
					inst.font,
					String.format("X: %d, Y: %d, Z: %d", pos.getX(), pos.getY() - get_offset(dim), pos.getZ()),
					Config.OVERLAY_X.get(), Config.OVERLAY_Y.get(), DepthMeter.COLOUR
				);
			} catch (Exception ex) {
				LOGGER.error("Exception thrown: {}", ex.getMessage());
			}
		}

		static int get_offset(String dim) {
			return switch (dim) {
				case "aether:the_aether"       			-> -496;
				case "minecraft:overworld"     			-> 0;
				case "delverbegin:delversbeginnings"   	-> 64 + 128;
				case "undergarden:undergarden" 			-> 64 + 128 + 128;
				case "infernalcross:infernalcrossing" 	-> 64 + 128 + 128 + 64;
				case "minecraft:the_nether"    			-> 64 + 128 + 128 + (64 + 64) + 128;
				default                        			-> 0;
			};
		}
	}

	public class Config {
		private static final ForgeConfigSpec.Builder BUILDER = new ForgeConfigSpec.Builder();

		public static final ForgeConfigSpec.IntValue OVERLAY_X = BUILDER
			.comment("Overlay X offset")
			.defineInRange("offset_x", 5, 0, Integer.MAX_VALUE);

		public static final ForgeConfigSpec.IntValue OVERLAY_Y = BUILDER
			.comment("Overlay Y offset")
			.defineInRange("offset_y", 5, 0, Integer.MAX_VALUE);

		public static final ForgeConfigSpec SPEC = BUILDER.build();
	}

	public class ConfigScreen extends Screen {
		private final Screen parent;
		private EditBoxWithLabel x_box, y_box;

		public ConfigScreen(Screen parent) {
			super(Component.literal("Dim Overlay Config"));
			this.parent = parent;
		}

		@Override
		protected void init() {
			super.init();
			int offset = -135;

			x_box = new EditBoxWithLabel(font,
				this.width / 2 - 50 - font.width("X Offset:  "), (this.height / 2 - 10) + offset,
				100, 20, Component.literal("X Offset:  "), String.valueOf(Config.OVERLAY_X.get()),
				(str) -> {
					try { Integer.parseInt(str); } 
					catch (NumberFormatException e) { return false; }
					return true;
				}
			);
			addRenderableWidget(x_box);


			offset += 30;
			y_box = new EditBoxWithLabel(font,
				this.width / 2 - 50 - font.width("Y Offset:  "), (this.height / 2 - 10) + offset,
				100, 20, Component.literal("Y Offset:  "), String.valueOf(Config.OVERLAY_Y.get()),
				(str) -> {
					try { Integer.parseInt(str); } 
					catch (NumberFormatException e) { return false; }
					return true;
				}
			);
			addRenderableWidget(y_box);

			offset += 20;
			addRenderableWidget(
				new Button.Builder(CommonComponents.GUI_DONE, p -> onClose())
					.pos(this.width / 2 - 100, this.height / 2 + offset)
					.size(200, 20)
					.build()
			);
		}

		@Override
		public void render(GuiGraphics context, int mouseX, int mouseY, float ticks) {
			this.renderDirtBackground(context);
			context.drawCenteredString(this.font, this.title, this.width / 2, 15, DepthMeter.COLOUR);
			super.render(context, mouseX, mouseY, ticks);
		}

		@Override
		public void onClose() {
			try {
				Config.OVERLAY_X.set(Integer.valueOf(x_box.getValue()));
				Config.OVERLAY_Y.set(Integer.valueOf(y_box.getValue()));
			} catch (NumberFormatException e) {
				DepthMeter.LOGGER.error("Failed to set config: {}", e.getMessage());
			}

			if (minecraft != null && parent != null) minecraft.setScreen(parent);
			else super.onClose();
		}
	}

	public class EditBoxWithLabel extends EditBox {
		private final Component label;
		private final Font font;
		private final Function<String, Boolean> verify;

		public EditBoxWithLabel(Font font, int x, int y, int with, int height, Component label, String value, Function<String, Boolean> verify) {
			super(font, x, y, with, height, label);
			this.label = label;
			this.font = font;
			setValue(value);
			this.verify = verify;
		}

		@Override
		public void render(GuiGraphics context, int mouseX, int mouseY, float ticks) {
			var width = font.width(label.getString());
			context.drawString(font, label.getString(), this.getX(), this.getY() + height / 2 - font.lineHeight / 2, DepthMeter.COLOUR);
			setX(getX() + width + 2);
			super.render(context, mouseX, mouseY, ticks);
			setX(getX() - width - 2);
		}

		@Override
		public int getWidth() {
			return super.getWidth() + font.width(label.getString());
		}

		@Override
		public void insertText(String text) {
			if (this.verify.apply(text))
				super.insertText(text);
		}
	}
}
