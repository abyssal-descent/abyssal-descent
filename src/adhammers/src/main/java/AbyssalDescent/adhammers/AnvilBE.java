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

		this.RECIPES = new HashMap<>();

		record Pair<A, B>(A a, B b){}

		var plates = List.of(
			new Pair<>(Items.COPPER_INGOT,                                 ADHammers.COPPER_PLATE.get()      ),
			new Pair<>(Items.IRON_INGOT,                                   ADHammers.IRON_PLATE.get()        ),
			new Pair<>(Items.GOLD_INGOT,                                   ADHammers.GOLD_PLATE.get()        ),
			new Pair<>(Items.DIAMOND,                                      ADHammers.DIAMOND_PLATE.get()     ),
			new Pair<>(Items.NETHERITE_INGOT,                              ADHammers.NETHERITE_PLATE.get()   ),
			new Pair<>(Resolve.item("caverns_and_chasms", "silver_ingot"), ADHammers.SILVER_PLATE.get()      ),
			new Pair<>(Resolve.item("undergarden",  "cloggrum_ingot"    ), ADHammers.CLOGGRUM_PLATE.get()    ),
			new Pair<>(Resolve.item("undergarden",  "froststeel_ingot"  ), ADHammers.FROSTSTEEL_PLATE.get()  ),
			new Pair<>(Resolve.item("undergarden",  "utherium_crystal"  ), ADHammers.UTHERIUM_PLATE.get()    ),
			new Pair<>(Resolve.item("betternether", "nether_ruby"       ), ADHammers.NETHER_RUBY_PLATE.get() ),
			new Pair<>(Resolve.item("betternether", "cincinnasite_ingot"), ADHammers.CINCINNASITE_PLATE.get())
		);

		for (var plate : plates) {
			for (var i = 1; i <= 4; i++) {
				this.RECIPES.put(Map.of(plate.a, i), new ItemStack(plate.b, i));
			}
		}
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
