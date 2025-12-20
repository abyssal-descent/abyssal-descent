package AbyssalDescent.adhammers;

import net.minecraft.world.item.Item;
import net.minecraft.world.item.Items;
import net.minecraft.world.item.BlockItem;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.entity.BlockEntityType;

import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;
import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.RegistryObject;

import java.util.function.Supplier;

@Mod(ADHammers.MODID)
public class ADHammers {
	public static final String MODID = "adhammers";

	public static final DeferredRegister<Item> ITEMS = 
		DeferredRegister.create(ForgeRegistries.ITEMS, MODID);
	public static final DeferredRegister<Block> BLOCKS =
		DeferredRegister.create(ForgeRegistries.BLOCKS, MODID);
	public static final DeferredRegister<BlockEntityType<?>> BLOCK_ENTITY_TYPES =
		DeferredRegister.create(ForgeRegistries.BLOCK_ENTITY_TYPES, MODID);

	public static final RegistryObject<GraniteAnvilBlock> GRANITE_ANVIL =
		block("granite_anvil", () -> new GraniteAnvilBlock());

	public static final RegistryObject<BlockEntityType<AnvilBE>> ANVILBE =
		BLOCK_ENTITY_TYPES.register("anvilbe", () -> 
			BlockEntityType.Builder.of(AnvilBE::new, 
				Blocks.ANVIL, Blocks.CHIPPED_ANVIL, Blocks.DAMAGED_ANVIL, 
				GRANITE_ANVIL.get()).build(null));

	// duarability = pickaxe*5; mining_speed = pickaxe*0.5; damage = axe
	public static final RegistryObject<Hammer> COPPER_HAMMER = ITEMS.register("copper_hammer", () ->
		new Hammer(new Hammer.Material(1, 955, 2.5f, Items.COPPER_INGOT), 9.0f));
	public static final RegistryObject<Hammer> IRON_HAMMER = ITEMS.register("iron_hammer", () ->
		new Hammer(new Hammer.Material(2, 1250, 5.88f, Items.IRON_INGOT), 9.0f));
	public static final RegistryObject<Hammer> GOLD_HAMMER = ITEMS.register("gold_hammer", () ->
		new Hammer(new Hammer.Material(2, 375, 7.0f, Items.GOLD_INGOT), 7.0f)); // pickaxe*0.5+1.0 for this
	public static final RegistryObject<Hammer> SILVER_HAMMER = ITEMS.register("silver_hammer", () ->
		new Hammer(new Hammer.Material(2, 785, 4.5f, Resolve.item("caverns_and_chasms", "silver_ingot")), 6.0f));
	public static final RegistryObject<Hammer> DIAMOND_HAMMER = ITEMS.register("diamond_hammer", () ->
		new Hammer(new Hammer.Material(3, 7805, 4.0f, Items.DIAMOND), 9.0f));
	public static final RegistryObject<Hammer> UTHERIUM_HAMMER = ITEMS.register("utherium_hammer", () ->
		new Hammer(new Hammer.Material(3, 6395, 4.25f, Resolve.item("undergarden", "utherium_crystal")), 9.5f));
	public static final RegistryObject<Hammer> NETHERITE_HAMMER = ITEMS.register("netherite_hammer", () ->
		new Hammer(new Hammer.Material(4, 10155, 4.5f, Items.NETHERITE_INGOT), 10.0f));
	public static final RegistryObject<Hammer> CLOGGRUM_HAMMER = ITEMS.register("cloggrum_hammer", () ->
		new Hammer(new Hammer.Material(2, 1425, 3.0f, Resolve.item("undergarden", "cloggrum_ingot")), 9.0f));
	public static final RegistryObject<Hammer> FROSTSTEEL_HAMMER = ITEMS.register("froststeel_hammer", () ->
		new Hammer(new Hammer.Material(2, 2875, 3.5f, Resolve.item("undergarden", "frosteel_ingot")), 9.0f));

	public static final RegistryObject<Item> COPPER_PLATE       = item("copper_plate"      );
	public static final RegistryObject<Item> IRON_PLATE         = item("iron_plate"        );
	public static final RegistryObject<Item> GOLD_PLATE         = item("gold_plate"        );
	public static final RegistryObject<Item> SILVER_PLATE       = item("silver_plate"      );
	public static final RegistryObject<Item> DIAMOND_PLATE      = item("diamond_plate"     );
	public static final RegistryObject<Item> CLOGGRUM_PLATE     = item("cloggrum_plate"    );
	public static final RegistryObject<Item> FROSTSTEEL_PLATE   = item("froststeel_plate"  );
	public static final RegistryObject<Item> UTHERIUM_PLATE     = item("utherium_plate"    );
	public static final RegistryObject<Item> NETHERITE_PLATE    = item("netherite_plate"   );
	public static final RegistryObject<Item> NETHER_RUBY_PLATE  = item("nether_ruby_plate" );
	public static final RegistryObject<Item> CINCINNASITE_PLATE = item("cincinnasite_plate");


	private static <T extends Block> RegistryObject<T> block(String name, Supplier<T> fn) {
		var block = BLOCKS.register(name, fn);
		ITEMS.register(name, () -> new BlockItem(block.get(), new Item.Properties()));
		return block;
	}

	private static RegistryObject<Item> item(String name) {
		return ITEMS.register(name, () -> new Item(new Item.Properties()));
	}

	public ADHammers() {
		var bus = FMLJavaModLoadingContext.get().getModEventBus();
		MinecraftForge.EVENT_BUS.register(new AnvilEvents());
		ITEMS.register(bus);
		BLOCKS.register(bus);
		BLOCK_ENTITY_TYPES.register(bus);
	}
}
