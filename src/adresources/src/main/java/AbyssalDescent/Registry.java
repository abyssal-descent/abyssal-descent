package AbyssalDescent.adresources;

import net.minecraft.world.item.BlockItem;
import net.minecraft.world.item.Item;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.state.BlockBehaviour;
import net.minecraft.world.level.material.MapColor;

import net.minecraftforge.eventbus.api.IEventBus;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.RegistryObject;

import java.util.function.Supplier;

public class Registry {
	public static final DeferredRegister<Block> BLOCKS = 
		DeferredRegister.create(ForgeRegistries.BLOCKS, ADResources.MODID);
	public static final DeferredRegister<Item> ITEMS = 
		DeferredRegister.create(ForgeRegistries.ITEMS, ADResources.MODID);

	public Registry(IEventBus bus) {
		BLOCKS.register(bus);
		ITEMS.register(bus);
	}

	public static final RegistryObject<SemaphoreBlock> BEDROCK1 = register_semaphore_block("bedrock1", 2);
	public static final RegistryObject<SemaphoreBlock> BEDROCK2 = register_semaphore_block("bedrock2", 3);
	public static final RegistryObject<SemaphoreBlock> BEDROCK3 = register_semaphore_block("bedrock3", 4);
	public static final RegistryObject<SemaphoreBlock> BEDROCK4 = register_semaphore_block("bedrock4", 5);
	public static final RegistryObject<SemaphoreBlock> BEDROCK5 = register_semaphore_block("bedrock5", 6);

	public static final RegistryObject<Block> RED_DEEPSTONE_IRON_ORE =
		register_block_with("reddeepstoneironore", () ->
			new Block(BlockBehaviour.Properties.copy(Blocks.DEEPSLATE_IRON_ORE).strength(6.0f)));
	public static final RegistryObject<Block> HARDENED_ROOT_BLOCK =
		register_block_with("hardened_root_block", () -> new HardenedRootBlock());

	public static final RegistryObject<Item> EMPTY_FORGOTTEN_BOTTLE =
		ITEMS.register("empty_forgotten_bottle", () -> new Item(new Item.Properties().fireResistant()));
	public static final RegistryObject<Item> ACID_BOTTLE =
		ITEMS.register("acid_bottle", () -> new Item(new Item.Properties().fireResistant().durability(32)));


	private static RegistryObject<Block> register_block_with(String name, Supplier<Block> fn) {
		var block = BLOCKS.register(name, fn);
		ITEMS.register(name, () -> new BlockItem(block.get(), new Item.Properties()));
		return block;
	}

	private static RegistryObject<SemaphoreBlock> register_semaphore_block(String name, int level) {
		var block = BLOCKS.register(name, () -> new SemaphoreBlock(
			BlockBehaviour.Properties.of()
				.mapColor(MapColor.STONE)
				.strength(50F, 36000F), level
		));
		ITEMS.register(name, () -> new BlockItem(block.get(), new Item.Properties()));
		return block;
	}
}
