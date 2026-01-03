package AbyssalDescent.adhammers;

import net.minecraft.core.BlockPos;
import net.minecraft.nbt.CompoundTag;
import net.minecraft.network.protocol.Packet;
import net.minecraft.network.protocol.game.ClientboundBlockEntityDataPacket;
import net.minecraft.network.protocol.game.ClientGamePacketListener;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.Items;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.entity.BlockEntity;

import net.minecraftforge.items.ItemStackHandler;

import java.util.*;

public class AnvilBE extends BlockEntity {
	public static final int MAX_SIZE = 4;
	public static final int REQ_HITS = 3;

	public static Map<Map<Item, Integer>, ItemStack> RECIPES;

	final ItemStackHandler handler = new ItemStackHandler(MAX_SIZE) { 
		@Override
		protected void onContentsChanged(int slot) {
			setChanged();
			if (level.isClientSide()) return;
			level.sendBlockUpdated(getBlockPos(), getBlockState(), getBlockState(), 3);
		}
	};

	public int hits = 0;

	public AnvilBE(BlockPos pos, BlockState state) {
		super(ADHammers.ANVILBE.get(), pos, state);

		this.RECIPES = new HashMap<>() {{
			put(Map.of(Items.COPPER_INGOT,                                 1), new ItemStack(ADHammers.COPPER_PLATE.get()));
			put(Map.of(Items.IRON_INGOT,                                   1), new ItemStack(ADHammers.IRON_PLATE.get()));
			put(Map.of(Items.GOLD_INGOT,                                   1), new ItemStack(ADHammers.GOLD_PLATE.get()));
			put(Map.of(Items.DIAMOND,                                      1), new ItemStack(ADHammers.DIAMOND_PLATE.get()));
			put(Map.of(Items.NETHERITE_INGOT,                              1), new ItemStack(ADHammers.NETHERITE_PLATE.get()));
			put(Map.of(Resolve.item("caverns_and_chasms", "silver_ingot"), 1), new ItemStack(ADHammers.SILVER_PLATE.get()));
			put(Map.of(Resolve.item("undergarden",  "cloggrum_ingot"    ), 1), new ItemStack(ADHammers.CLOGGRUM_PLATE.get()));
			put(Map.of(Resolve.item("undergarden",  "froststeel_ingot"  ), 1), new ItemStack(ADHammers.FROSTSTEEL_PLATE.get()));
			put(Map.of(Resolve.item("undergarden",  "utherium_crystal"  ), 1), new ItemStack(ADHammers.UTHERIUM_PLATE.get()));
			put(Map.of(Resolve.item("betternether", "nether_ruby"       ), 1), new ItemStack(ADHammers.NETHER_RUBY_PLATE.get()));
			put(Map.of(Resolve.item("betternether", "cincinnasite_ingot"), 1), new ItemStack(ADHammers.CINCINNASITE_PLATE.get()));
		}};
	}

	private Optional<Integer> find_free_slot() {
		for (var i = 0; i < MAX_SIZE; i++) 
			if (handler.getStackInSlot(i).isEmpty()) return Optional.of(i);

		return Optional.empty();
	}

	public boolean push(Item item) {
		var i = find_free_slot();
		if (!i.isPresent()) return false;
		handler.setStackInSlot(i.get(), new ItemStack(item));
		return true;
	}

	public Optional<Item> pop() {
		var i = find_free_slot().orElse(MAX_SIZE) - 1;
		if (i == -1) return Optional.empty();
		
		var item = handler.getStackInSlot(i);
		handler.setStackInSlot(i, ItemStack.EMPTY);
		return Optional.of(item.getItem());
	}

	public void clear() {
		for (var i = 0; i < MAX_SIZE; i++)
			handler.setStackInSlot(i, ItemStack.EMPTY);
	}

	public List<Item> get_contents() {
		var list = new ArrayList<Item>();
		for (var i = 0; i < MAX_SIZE; i++) {
			var stack = handler.getStackInSlot(i);
			if (stack.isEmpty()) break;
			list.add(stack.getItem());
		}
		return list;
	}

	public Optional<ItemStack> try_craft() {
		var contents = new HashMap<Item, Integer>();
		for (var i = 0; i < MAX_SIZE; i++) {
			var stack = handler.getStackInSlot(i);
			if (stack.isEmpty()) break;
			contents.merge(stack.getItem(), 1, Integer::sum);
		}

		var out = RECIPES.get(contents);
		if (out == null) return Optional.empty();

		for (var i = 0; i < MAX_SIZE; i++) 
			handler.setStackInSlot(i, ItemStack.EMPTY);

		return Optional.of(out);
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
