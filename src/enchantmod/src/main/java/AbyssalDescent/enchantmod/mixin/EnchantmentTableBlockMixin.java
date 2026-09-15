package AbyssalDescent.enchantmod.mixin;

import AbyssalDescent.enchantmod.EnchantBE;
import AbyssalDescent.enchantmod.EnchantMod;

import net.minecraft.core.BlockPos;
import net.minecraft.world.InteractionResult;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.Items;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.EnchantmentTableBlock;
import net.minecraft.world.level.block.BaseEntityBlock;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.entity.BlockEntity;
import net.minecraft.world.level.block.entity.BlockEntityTicker;
import net.minecraft.world.level.block.entity.BlockEntityType;
import net.minecraft.server.level.ServerLevel;

import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Overwrite;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

import java.util.*;

@Mixin(EnchantmentTableBlock.class)
public class EnchantmentTableBlockMixin extends BaseEntityBlock {
	protected EnchantmentTableBlockMixin(Properties p) {
		super(p);
	}

	/**
	 * @author slab
	 * @reason replace enchant table BE with ours
	 */
	@Overwrite
	public BlockEntity newBlockEntity(BlockPos pos, BlockState state) {
		return new EnchantBE(pos, state);
	}

	@Override
	public <T extends BlockEntity> BlockEntityTicker<T> getTicker(Level level, BlockState state, BlockEntityType<T> type) {
		return createTickerHelper(type, EnchantMod.ENCHANTBE.get(), EnchantBE::tick);
	}

	/**
	 * @author slab
	 * @reason Remove enchant table gui
	 */
	@Overwrite
	public InteractionResult use(BlockState p1, Level level, BlockPos pos,
		Player player, InteractionHand hand, BlockHitResult p5
	) {
		if (!(level instanceof ServerLevel server)) return InteractionResult.SUCCESS;
		if (!(server.getBlockEntity(pos) instanceof EnchantBE entity)) throw new RuntimeException("enchant table not EnchantBE");

		if (!entity.test_structure_complete(server, pos)) return InteractionResult.PASS;
		if (entity.frozen) return InteractionResult.PASS;
		if (!entity.get().isEmpty()) {
			entity.drop_content(server);
			var pedestals = entity.get_pedestals(server, pos);
			if (pedestals.isEmpty()) return InteractionResult.SUCCESS;
			for (var pedestal : pedestals.get())
				pedestal.frozen = false;
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

}
