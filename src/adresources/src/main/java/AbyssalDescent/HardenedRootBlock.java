package AbyssalDescent.adresources;

import net.minecraft.core.BlockPos;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.world.InteractionResult;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.state.BlockBehaviour;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.entity.player.Player;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.sounds.SoundSource;

public class HardenedRootBlock extends Block {
	public HardenedRootBlock() { 
		super(BlockBehaviour.Properties.copy(Blocks.BEDROCK)); 
	}

	@Override
	public InteractionResult use(BlockState state, Level level, BlockPos pos, Player player, InteractionHand hand, BlockHitResult hit) {
		var stack = player.getItemInHand(hand);

		if (!(level instanceof ServerLevel server)) return InteractionResult.PASS;
		if (stack.getItem() != Registry.ACID_BOTTLE.get()) return InteractionResult.PASS;

		stack.hurtAndBreak(1, player, p -> p.broadcastBreakEvent(hand));
		level.setBlock(pos, Registry.BEDROCK3.get().defaultBlockState(), 3);
		level.playSound(null, pos, SoundEvents.LAVA_EXTINGUISH, SoundSource.BLOCKS, 0.6f, 1.0f);
		server.sendParticles(
			ParticleTypes.SPIT,
			pos.getX() + 0.5, pos.getY() + 0.5, pos.getZ() + 0.5,
			12, 0.5, 0.5, 0.5, 0.06
		);

		return InteractionResult.sidedSuccess(false);
	}
}
