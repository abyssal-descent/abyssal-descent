package AbyssalDescent.adresources;

import net.minecraft.core.BlockPos;
import net.minecraft.world.item.PickaxeItem;
import net.minecraft.world.level.BlockGetter;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.entity.player.Player;

public class SemaphoreBlock extends Block {
	private int tier;

	public SemaphoreBlock(Properties properties, int tier) {
		super(properties);
		this.tier = tier;
	}

	@Override @SuppressWarnings("deprecation")
	public float getDestroyProgress(BlockState state, Player player, BlockGetter level, BlockPos pos) {
		return player.getInventory().getSelected().getItem() instanceof PickaxeItem item 
			&& item.getTier().getLevel() >= this.tier ? 0.02F : 0F;
	}
}
