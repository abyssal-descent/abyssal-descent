package AbyssalDescent.adhammers;

import net.minecraft.core.BlockPos;
import net.minecraft.core.Direction;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.core.particles.BlockParticleOption;
import net.minecraft.world.item.context.BlockPlaceContext;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.EntityBlock;
import net.minecraft.world.level.block.HorizontalDirectionalBlock;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.state.StateDefinition;
import net.minecraft.world.level.block.state.BlockBehaviour;
import net.minecraft.world.level.block.state.properties.IntegerProperty;
import net.minecraft.world.level.block.state.properties.DirectionProperty;
import net.minecraft.world.level.block.entity.BlockEntity;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.sounds.SoundSource;

public class GraniteAnvilBlock extends Block implements EntityBlock {
	public static final IntegerProperty   DAMAGE = IntegerProperty.create("damage", 0, 2);
	public static final DirectionProperty FACING = HorizontalDirectionalBlock.FACING;

	public GraniteAnvilBlock() {
		super(BlockBehaviour.Properties.copy(Blocks.GRANITE));
	}

	@Override
	public BlockState getStateForPlacement(BlockPlaceContext ctx) {
		return this.defaultBlockState()
			.setValue(FACING, ctx.getHorizontalDirection().getClockWise());
	}

	@Override
	public BlockEntity newBlockEntity(BlockPos pos, BlockState state) {
		return new AnvilBE(pos, state);
	}

	@Override
	protected void createBlockStateDefinition(StateDefinition.Builder<Block, BlockState> b) {
		b.add(FACING);
		b.add(DAMAGE);
	}

	public void try_damage(BlockState state, Level level, BlockPos pos) {
		if (!(level instanceof ServerLevel server)) return;
		if (level.random.nextInt() % 5 != 0) return;

		var next = state.getValue(DAMAGE) + 1;
		if (next > 2) {
			level.destroyBlock(pos, false);
			level.playSound(null, pos, SoundEvents.ANVIL_BREAK, SoundSource.BLOCKS, 1.0f, 1.0f);
			level.levelEvent(2001, pos, Block.getId(Blocks.GRANITE.defaultBlockState()));
			// TODO: particles
			return;
		}

		server.sendParticles(
			new BlockParticleOption(ParticleTypes.BLOCK, Blocks.GRANITE.defaultBlockState()),
			pos.getX() + 0.5, pos.getY() + 0.5, pos.getZ() + 0.5, 20, 0.20, 0.20, 0.20, 0.08);

		level.setBlock(pos, state.setValue(DAMAGE, next), 3);
	}
}
