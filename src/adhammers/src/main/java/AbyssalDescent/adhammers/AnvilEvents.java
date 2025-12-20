package AbyssalDescent.adhammers;

import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.world.entity.item.ItemEntity;
import net.minecraft.world.Containers;
import net.minecraft.world.InteractionResult;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.AnvilBlock;
import net.minecraft.world.level.gameevent.GameEvent;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.sounds.SoundSource;

import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.eventbus.api.EventPriority;
import net.minecraftforge.event.entity.player.PlayerInteractEvent;
import net.minecraftforge.event.level.BlockEvent;

import java.util.*;

public class AnvilEvents {
	@SubscribeEvent
	public void on_break(BlockEvent.BreakEvent event) {
		var level = event.getLevel();
		var pos   = event.getPos();

		if (!(level instanceof ServerLevel server)) return;
		if (!(level.getBlockEntity(pos) instanceof AnvilBE entity)) return;
		for (var item : entity.get_contents())
			Containers.dropItemStack(server, 
				pos.getX() + 0.5, pos.getY() + 1.0, pos.getZ() + 0.5, 
				new ItemStack(item));
	}

	@SubscribeEvent(priority = EventPriority.HIGHEST)
	public void use(PlayerInteractEvent.RightClickBlock event) {
		var stack  = event.getItemStack();
		var level  = event.getLevel();
		var player = event.getEntity();
		var pos    = event.getPos();
		var state  = level.getBlockState(pos);

		if (!(level instanceof ServerLevel server)) return;
		if (event.getHand() != InteractionHand.MAIN_HAND) return;
		if (!player.isCrouching() && !player.isShiftKeyDown()) return;
		if (!(level.getBlockEntity(pos) instanceof AnvilBE entity)) return;

		event.setCanceled(true);
		event.setCancellationResult(InteractionResult.CONSUME); // CONSUME?

		if (stack.getItem() == Items.AIR) {
			entity.pop().ifPresent(i -> player.addItem(new ItemStack(i)));
			return;
		}

		if (stack.getItem() instanceof Hammer) {
			double x = pos.getX() + 0.5, y = pos.getY() + 1.1, z = pos.getZ() + 0.5;

			stack.hurtAndBreak(5, player, p -> {});
			player.swing(InteractionHand.MAIN_HAND, true);
			level.playSound(null, pos, SoundEvents.ANVIL_PLACE, SoundSource.BLOCKS, 0.5f, 1.0f);
			server.sendParticles(
				ParticleTypes.CRIT, x, y, z,
				12, 0.2, 0.1, 0.2, 0.05);

			entity.hits = entity.hits + 1;

			if (entity.hits < AnvilBE.REQ_HITS) return;

			if (state.getBlock() instanceof GraniteAnvilBlock anvil)
				anvil.try_damage(state, level, pos);
			
			entity.hits = 0;
			var out = entity.try_craft();
			if (!out.isPresent()) {
				server.sendParticles(
					ParticleTypes.SMOKE, x, y, z,
					25, 0.25, 0.2, 0.25, 0.02);

				for (var item : entity.get_contents())
					drop_stack(level, x, y, z, new ItemStack(item));

				entity.clear();
				
				return;
			}

			server.sendParticles(
				ParticleTypes.WAX_OFF, x, y, z,
				5, 0.15, 0.1, 0.15, 0.5);

			drop_stack(level, x, y, z, out.get().copy());
			
			return;
		}

		if (entity.push(stack.getItem())) {
			stack.shrink(1);
		}
	}

	private void drop_stack(Level level, double x, double y, double z, ItemStack stack) {
		var item_entity = new ItemEntity(level, x, y, z, stack);
		item_entity.setDeltaMovement(0, 0.1, 0);
		item_entity.setDefaultPickUpDelay();
		level.addFreshEntity(item_entity);
	}
}
