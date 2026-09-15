package AbyssalDescent.enchantmod;

import net.minecraft.core.BlockPos;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.nbt.CompoundTag;
import net.minecraft.world.Containers;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.crafting.Ingredient;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.entity.BlockEntity;
import net.minecraft.world.level.block.entity.BlockEntityType;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.network.protocol.Packet;
import net.minecraft.network.protocol.game.ClientboundBlockEntityDataPacket;
import net.minecraft.network.protocol.game.ClientGamePacketListener;

import net.minecraftforge.items.ItemStackHandler;

public abstract class ItemHolderBE extends BlockEntity {
	protected int process_t = 0;
	public boolean frozen = false;

	final ItemStackHandler handler = new ItemStackHandler(1) { 
		@Override
		protected void onContentsChanged(int slot) {
			setChanged();
			if (level.isClientSide()) return;
			level.sendBlockUpdated(getBlockPos(), getBlockState(), getBlockState(), 3);
		}
	};

	public ItemHolderBE(BlockEntityType<? extends ItemHolderBE> be, BlockPos pos, BlockState state) {
		super(be, pos, state);
	}

	public void drop_content(ServerLevel server) {
		double x = this.worldPosition.getX() + 0.5, y = this.worldPosition.getY() + 1.0, z = this.worldPosition.getZ() + 0.5;
		var item = this.get();
		this.process_t = 0;

		if (!item.isEmpty()) {
			Containers.dropItemStack(server, x, y, z, item);
			server.sendParticles(ParticleTypes.ENCHANT, x, y, z, 8, 0.5, 0.5, 0.5, 0.6);
			handler.setStackInSlot(0, ItemStack.EMPTY);
			this.setChanged();
		}
	}

	public ItemStack get() {
		return handler.getStackInSlot(0);
	}

	public void set(ItemStack item) {
		handler.setStackInSlot(0, item);
			this.setChanged();
	}

	public void clear() {
		handler.setStackInSlot(0, ItemStack.EMPTY);
		this.setChanged();
	}

	@Override
	protected void saveAdditional(CompoundTag tag) {
		tag.put("inv", handler.serializeNBT());
		super.saveAdditional(tag);
	}

	@Override
	public void load(CompoundTag tag) {
		super.load(tag);
		handler.deserializeNBT(tag.getCompound("inv"));
	}

	@Override
	public Packet<ClientGamePacketListener> getUpdatePacket() {
		return ClientboundBlockEntityDataPacket.create(this);
	}

	@Override
	public CompoundTag getUpdateTag() {
		return saveWithoutMetadata();
	}
}
