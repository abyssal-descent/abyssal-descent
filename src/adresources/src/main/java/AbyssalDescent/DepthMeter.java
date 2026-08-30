package AbyssalDescent.adresources;

import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.Font;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.components.EditBox;
import net.minecraft.client.gui.components.Button;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.network.chat.Component;
import net.minecraft.network.chat.CommonComponents;

import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.client.event.CustomizeGuiOverlayEvent;
import net.minecraftforge.common.ForgeConfigSpec;

import java.util.function.Function;

@Mod.EventBusSubscriber
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

		public static class ConfigScreen extends Screen {
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

				this.x_box = new EditBoxWithLabel(font,
					this.width / 2 - 50 - font.width("X Offset:  "), (this.height / 2 - 10) + offset,
					100, 20, Component.literal("X Offset:  "), String.valueOf(Config.OVERLAY_X.get()),
					(str) -> {
						try { Integer.parseInt(str); } 
						catch (NumberFormatException e) { return false; }
						return true;
					}
				);
				this.addRenderableWidget(x_box);

				offset += 30;
				this.y_box = new EditBoxWithLabel(font,
					this.width / 2 - 50 - font.width("Y Offset:  "), (this.height / 2 - 10) + offset,
					100, 20, Component.literal("Y Offset:  "), String.valueOf(Config.OVERLAY_Y.get()),
					(str) -> {
						try { Integer.parseInt(str); } 
						catch (NumberFormatException e) { return false; }
						return true;
					}
				);
				this.addRenderableWidget(y_box);

				offset += 20;
				this.addRenderableWidget(
					new Button.Builder(CommonComponents.GUI_DONE, p -> this.onClose())
						.pos(this.width / 2 - 100, this.height / 2 + offset)
						.size(200, 20).build());
			}

			@Override
			public void render(GuiGraphics context, int mouseX, int mouseY, float ticks) {
				this.renderDirtBackground(context);
				context.drawCenteredString(this.font, this.title, this.width / 2, 15, DepthMeter.COLOUR);
				super.render(context, mouseX, mouseY, ticks);
			}

			@Override
			public void onClose() {
				Config.OVERLAY_X.set(Integer.valueOf(x_box.getValue()));
				Config.OVERLAY_Y.set(Integer.valueOf(y_box.getValue()));

				if (minecraft != null && parent != null) {
					minecraft.setScreen(parent);
					return;
				}

				super.onClose();
			}
		}

		public static class EditBoxWithLabel extends EditBox {
			private final Component label;
			private final Font font;
			private final Function<String, Boolean> verify;

			public EditBoxWithLabel(Font font, int x, int y, int with, int height, Component label, String value, Function<String, Boolean> verify) {
				super(font, x, y, with, height, label);
				this.label = label;
				this.font = font;
				this.setValue(value);
				this.verify = verify;
			}

			@Override
			public void render(GuiGraphics context, int mouseX, int mouseY, float ticks) {
				var width = font.width(label.getString());
				context.drawString(font, label.getString(), this.getX(), this.getY() + height / 2 - font.lineHeight / 2, DepthMeter.COLOUR);
				this.setX(this.getX() + width + 2);
				super.render(context, mouseX, mouseY, ticks);
				this.setX(this.getX() - width - 2);
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
}
