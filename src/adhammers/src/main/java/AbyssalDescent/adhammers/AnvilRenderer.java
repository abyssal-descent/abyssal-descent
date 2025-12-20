package AbyssalDescent.adhammers;

import com.mojang.blaze3d.vertex.PoseStack;
import com.mojang.math.Axis;

import net.minecraft.core.BlockPos;
import net.minecraft.core.Direction;
import net.minecraft.client.renderer.LightTexture;
import net.minecraft.client.renderer.MultiBufferSource;
import net.minecraft.client.renderer.texture.OverlayTexture;
import net.minecraft.client.renderer.blockentity.BlockEntityRenderer;
import net.minecraft.client.renderer.blockentity.BlockEntityRendererProvider;
import net.minecraft.world.level.LightLayer;
import net.minecraft.world.level.block.HorizontalDirectionalBlock;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.ItemDisplayContext;

import net.minecraftforge.api.distmarker.Dist;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.client.event.EntityRenderersEvent;

@Mod.EventBusSubscriber(value = Dist.CLIENT, modid = ADHammers.MODID, bus = Mod.EventBusSubscriber.Bus.MOD)
public class AnvilRenderer {
	@SubscribeEvent
	public static void registerBERs(EntityRenderersEvent.RegisterRenderers event) {
		event.registerBlockEntityRenderer(ADHammers.ANVILBE.get(), AnvilBER::new);
	}

	public static class AnvilBER implements BlockEntityRenderer<AnvilBE> {
		private final BlockEntityRendererProvider.Context ctx;

		public AnvilBER(BlockEntityRendererProvider.Context ctx) { 
			this.ctx = ctx;
		}

		@Override
		public void render(AnvilBE entity, float pt, PoseStack ps, MultiBufferSource buf, int light, int overlay) {
			var renderer = ctx.getItemRenderer();
			var level = entity.getLevel();
			var pos   = entity.getBlockPos();
			var dir   = entity.getBlockState().getValue(HorizontalDirectionalBlock.FACING);

			var light_level = LightTexture.pack(
				level.getBrightness(LightLayer.BLOCK, pos),
				level.getBrightness(LightLayer.SKY, pos));

			var i = 0;
			for (var item : entity.get_contents()) {
				ps.pushPose();

				switch (dir) {
					case NORTH -> {
						ps.translate(0.5, 1.0 + (i * 0.01), 0.28 + (i * 0.15));
						ps.mulPose(Axis.YP.rotationDegrees(180.0f));
					}
					case SOUTH -> {
						ps.translate(0.5, 1.0 + (i * 0.01), 0.28 + (i * 0.15));
					}
					case WEST -> {
						ps.translate(0.28 + (i * 0.15), 1.0 + (i * 0.01), 0.5);
						ps.mulPose(Axis.YP.rotationDegrees(90.0f));
					}
					case EAST -> {
						ps.translate(0.28 + (i * 0.15), 1.0 + (i * 0.01), 0.5);
						ps.mulPose(Axis.YP.rotationDegrees(-90.0f));
					}
					default -> throw new RuntimeException("unreachable");
				}

				ps.mulPose(Axis.XP.rotationDegrees(90.0f));
				ps.scale(0.5f, 0.5f, 0.5f);
				renderer.renderStatic(new ItemStack(item), ItemDisplayContext.FIXED,
					light_level, OverlayTexture.NO_OVERLAY, ps, buf, level, 1);
				ps.popPose();
				i++;
			}
		}
	}
}
