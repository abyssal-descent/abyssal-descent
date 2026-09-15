package AbyssalDescent.enchantmod;

import com.mojang.blaze3d.vertex.PoseStack;
import com.mojang.math.Axis;

import net.minecraft.client.renderer.MultiBufferSource;
import net.minecraft.client.renderer.blockentity.BlockEntityRenderer;
import net.minecraft.client.renderer.blockentity.BlockEntityRendererProvider;
import net.minecraft.client.renderer.entity.ItemRenderer;
import net.minecraft.world.item.ItemDisplayContext;
import net.minecraft.world.item.ItemStack;

import net.minecraftforge.api.distmarker.Dist;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.client.event.EntityRenderersEvent;

@Mod.EventBusSubscriber(value = Dist.CLIENT, modid = EnchantMod.MODID, bus = Mod.EventBusSubscriber.Bus.MOD)
public class EnchantRenderer {
	@SubscribeEvent
	public static void register_ber(EntityRenderersEvent.RegisterRenderers event) {
		event.registerBlockEntityRenderer(EnchantMod.ENCHANTBE.get(), ItemHolderBER::new);
		event.registerBlockEntityRenderer(EnchantMod.PEDESTALBE.get(), ItemHolderBER::new);
	}

	public static class ItemHolderBER implements BlockEntityRenderer<ItemHolderBE> {
		private final BlockEntityRendererProvider.Context ctx;

		public ItemHolderBER(BlockEntityRendererProvider.Context ctx) {
			this.ctx = ctx;
		}

		@Override
		public void render(ItemHolderBE entity, float pt, PoseStack ps, MultiBufferSource buf, int light, int overlay) {
			var item = entity.get();
			var item_renderer = ctx.getItemRenderer();

			if (item.isEmpty()) return;

			ps.pushPose();
			ps.translate(0.5, 1.0, 0.5);
			var r = (entity.getLevel().getGameTime() + pt) * 2.0F;
			ps.mulPose(Axis.YP.rotationDegrees(r));
			item_renderer.renderStatic(item, ItemDisplayContext.GROUND, 
				light, overlay, ps, buf, entity.getLevel(), 0);
			ps.popPose();
		}
	}
}

