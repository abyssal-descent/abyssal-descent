package AbyssalDescent.enchantmod;

import net.minecraft.core.BlockPos;
import net.minecraft.world.InteractionResult;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.item.Items;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.world.phys.shapes.CollisionContext;
import net.minecraft.world.phys.shapes.Shapes;
import net.minecraft.world.phys.shapes.VoxelShape;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.BlockGetter;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.EntityBlock;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.state.BlockBehaviour;
import net.minecraft.world.level.block.entity.BlockEntity;
import net.minecraft.server.level.ServerLevel;


public class PedestalBlock extends Block implements EntityBlock {
	public PedestalBlock() {
		super(BlockBehaviour.Properties.copy(Blocks.OBSIDIAN));
	}

	public static class PedestalBE extends ItemHolderBE {
		public PedestalBE(BlockPos pos, BlockState state) {
			super(EnchantMod.PEDESTALBE.get(), pos, state);
		}
	}

	@Override
	public BlockEntity newBlockEntity(BlockPos pos, BlockState state) {
		return new PedestalBE(pos, state);
	}

	@Override
	public InteractionResult use(BlockState p1, Level level, BlockPos pos,
		Player player, InteractionHand hand, BlockHitResult p5) {
		if (!(level instanceof ServerLevel server)) return InteractionResult.SUCCESS;
		if (!(server.getBlockEntity(pos) instanceof PedestalBE entity)) throw new RuntimeException("pedestal not PedestalBE");

		if (entity.frozen) return InteractionResult.PASS;
		if (!entity.get().isEmpty()) {
			entity.drop_content(server);
			return InteractionResult.SUCCESS;
		}

		if (hand != InteractionHand.MAIN_HAND) return InteractionResult.SUCCESS;
		var held = player.getItemInHand(hand);

		if (held.getItem() == Items.AIR) return InteractionResult.SUCCESS;

		var item = held.copy();
		item.setCount(1);
		entity.set(item);
		held.shrink(1);

		return InteractionResult.SUCCESS;
	}

	@Override
	public VoxelShape getShape(BlockState state, BlockGetter level, BlockPos pos, CollisionContext context) {
		return Shapes.or(
			Block.box(2, 0, 2, 14, 2, 14),
			Block.box(5, 2, 5, 11, 10, 11),
			Block.box(2, 10, 2, 14, 12, 14));
	}
}
