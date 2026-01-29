package AbyssalDescent.adresources;

import net.minecraft.ChatFormatting;
import net.minecraft.network.chat.Component;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.world.InteractionResultHolder;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.TooltipFlag;
import net.minecraft.world.item.UseAnim;
import net.minecraft.world.effect.MobEffect;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.level.Level;
import net.minecraft.server.level.ServerLevel;

import java.util.List;

public class CureItem extends Item {
	public static final MobEffect BLOODLUST = 
		BuiltInRegistries.MOB_EFFECT.get(new ResourceLocation("species", "bloodlust"));

	public CureItem(Item.Properties p) { super(p); }

	@Override
	public int getUseDuration(ItemStack stack) { return 32; }
	
	@Override 
	public UseAnim getUseAnimation(ItemStack stack) { return UseAnim.EAT; }

	@Override
	public ItemStack finishUsingItem(ItemStack stack, Level level, LivingEntity entity) {
		if (!(level instanceof ServerLevel server)) return stack;

		var pos = entity.getEyePosition();

		stack.shrink(1);
		entity.removeEffect(this.BLOODLUST);
		server.sendParticles(
			ParticleTypes.COMPOSTER, pos.x, pos.y, pos.z,
			20, 1, 1, 1, 1);

		return stack;
	}

	@Override
	public InteractionResultHolder<ItemStack> use(Level level, Player player, InteractionHand hand) {
		player.startUsingItem(hand);
		return InteractionResultHolder.consume(player.getItemInHand(hand));
	}

	@Override
	public void appendHoverText(ItemStack stack, Level level, List<Component> tt, TooltipFlag f) {
		tt.add(Component.literal("used by cave shamans to cure bloodlust")
			.withStyle(ChatFormatting.GRAY).withStyle(ChatFormatting.ITALIC));
	}
}
