package AbyssalDescent.enchantmod;

import net.minecraft.core.BlockPos;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.core.particles.ItemParticleOption;
import net.minecraft.nbt.CompoundTag;
import net.minecraft.world.Containers;
import net.minecraft.world.SimpleContainer;
import net.minecraft.world.phys.Vec3;
import net.minecraft.world.entity.EntityType;
import net.minecraft.world.entity.projectile.SmallFireball;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.alchemy.Potions;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.levelgen.Heightmap;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.entity.BlockEntity;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.network.protocol.Packet;
import net.minecraft.network.protocol.game.ClientboundBlockEntityDataPacket;
import net.minecraft.network.protocol.game.ClientGamePacketListener;

import java.util.*;
import java.util.function.Consumer;

public class EnchantBE extends ItemHolderBE {
	private static final int PROCESS_DELAY = 40;
	private static final List<Consumer<EnchantBE>> FAIL_EFFECTS = List.of(
		be -> {
			var level = be.getLevel();

			for (var i = 0; i < 5; i++) {
				var entity = EntityType.WITHER_SKELETON.create(level);
				entity.moveTo(be.rand_pos_within(4.0), level.random.nextFloat() * 360, 0);
				level.addFreshEntity(entity);
			}
		},
		be -> {
			var level = be.getLevel();

			for (var i = 0; i < 12; i++) {
				var entity = EntityType.LIGHTNING_BOLT.create(level);

				var pos_t = be.rand_pos_within(10.0);
				var pos = pos_t.atY(level.getHeight(Heightmap.Types.MOTION_BLOCKING, (int)pos_t.getX(), (int)pos_t.getZ()));

				entity.moveTo(pos, level.random.nextFloat() * 360, 0);
				level.addFreshEntity(entity);
			}

			if (level instanceof ServerLevel server)
				server.setWeatherParameters(0, 600, true, true);
		},
		be -> {
			var level = be.getLevel();

			for (var i = 0; i < 12; i++) {
				var entity = EntityType.PUFFERFISH.create(level);
				entity.moveTo(be.rand_pos_within(5.0), level.random.nextFloat() * 360, 0);
				level.addFreshEntity(entity);
			}
		},
		be -> {
			var level = be.getLevel();
			var pos = be.getBlockPos();
			var entity = EntityType.AREA_EFFECT_CLOUD.create(level);

			entity.moveTo(pos.getX() + 0.5, pos.getY() + 0.5, pos.getZ() + 0.5);
			entity.setRadius(4.0F);
			entity.setDuration(200);
			entity.setPotion(Potions.POISON);

			level.addFreshEntity(entity);
		},
		be -> {
			var pos = be.getBlockPos();
			be.getLevel().explode(null,
				pos.getX() + 0.5, pos.getY() + 1.5, pos.getZ() + 0.5,
				1.5F, true, Level.ExplosionInteraction.BLOCK);
		}
	);

	public EnchantBE(BlockPos pos, BlockState state) {
		super(EnchantMod.ENCHANTBE.get(), pos, state);
	}

	public Optional<List<ItemStack>> get_ingredients(List<PedestalBlock.PedestalBE> pedestals) {
		var ingredients = new ArrayList<ItemStack>();

		for (var pedestal : pedestals) {
			var item_p = pedestal.get();
			if (item_p.isEmpty())
				return Optional.empty();

			ingredients.add(item_p);
		}

		return Optional.of(ingredients);
	}

	public Optional<List<PedestalBlock.PedestalBE>> get_pedestals(ServerLevel server, BlockPos pos) {
		BlockPos[] directions = {pos.north(3), pos.south(3), pos.east(3), pos.west(3)};
		var pedestals = new ArrayList<PedestalBlock.PedestalBE>();
		for (var dir : directions) {
			if (!(server.getBlockEntity(dir) instanceof PedestalBlock.PedestalBE pedestal))
				return Optional.empty();
			pedestals.add(pedestal);
		}

		return Optional.of(pedestals);
	}

	public boolean test_structure_complete(ServerLevel server, BlockPos pos) {
		var pedestals = this.get_pedestals(server, pos);
		if (pedestals.isEmpty()) return false;
		return !this.get_ingredients(pedestals.get()).isEmpty();
	}

	private BlockPos rand_pos_within(double r) {
		var rand = this.level.random;
		return this.getBlockPos().offset(
			(int)(0.5 + (rand.nextDouble() - 0.5) * r), 1,
			(int)(0.5 + (rand.nextDouble() - 0.5) * r));
	}

	public static void tick(Level level, BlockPos pos, BlockState state, EnchantBE entity) {
		if (!(level instanceof ServerLevel server)) return;

		var item = entity.get();
		if (item.isEmpty()) return;

		if (entity.process_t == 0) {
			var pedestals = entity.get_pedestals(server, pos);
			if (pedestals.isEmpty()) return;
			var ingredients = entity.get_ingredients(pedestals.get());
			if (ingredients.isEmpty()) return;

			for (var pedestal : pedestals.get()) 
				pedestal.frozen = true;
		}

		var rand = server.getRandom();

		if (entity.process_t < PROCESS_DELAY) {
			entity.process_t = entity.process_t + 1;

			for (int i = 0; i < 2; i++) {
				var angle = rand.nextDouble() * Math.PI * 2.0;

				var radius = 1.5 + rand.nextDouble() * 1.5;

				var x = pos.getX() + 0.5 + Math.cos(angle) * radius;
				var y = pos.getY() + 0.5 + rand.nextDouble() * 1.5;
				var z = pos.getZ() + 0.5 + Math.sin(angle) * radius;

				var dx = (pos.getX() + 0.5 - x) * -0.1;
				var dy = (pos.getY() + 1.0 - y) * -0.1;
				var dz = (pos.getZ() + 0.5 - z) * -0.1;

				server.sendParticles(ParticleTypes.ENCHANT, x, y, z, 1, dx, dy, dz, 1.0);
			}

			return;
		}

		var pedestals = entity.get_pedestals(server, pos);
		if (pedestals.isEmpty()) return;
		var ingredients = entity.get_ingredients(pedestals.get());

		double x = pos.getX() + 0.5, y = pos.getY() + 1.0, z = pos.getZ() + 0.5;

		var recipe = server.getRecipeManager()
			.getAllRecipesFor(EnchantMod.ENCHANT_RECIPE.get()).stream()
			.filter(r -> r.matches_ingredients(ingredients.get()) && r.matches_blocks(server, pos))
			.findFirst();

		if (recipe.isEmpty() || item.isEnchanted() || !recipe.get().enchant.canEnchant(item)) {
			server.sendParticles(ParticleTypes.SMOKE, x, y, z, 55, 1, 0.6, 1, 0.001);
			FAIL_EFFECTS.get(rand.nextInt(FAIL_EFFECTS.size())).accept(entity);
			entity.drop_content(server);
			for (var pedestal : pedestals.get())
				pedestal.frozen = false;
			return;
		}

		server.sendParticles(ParticleTypes.HAPPY_VILLAGER, x, y, z, 6, 0.4, 0.1, 0.4, 0.5);
		entity.process_t = 0;

		item.enchant(recipe.get().enchant, 1);
		entity.set(item);
		entity.drop_content(server);

		for (var pedestal : pedestals.get()) {
			var pos_p = pedestal.getBlockPos();
			server.sendParticles(
				new ItemParticleOption(ParticleTypes.ITEM, pedestal.get()),
				pos_p.getX() + 0.5, pos_p.getY() + 1.0, pos_p.getZ() + 0.5,
				12, 0.15, 0.15, 0.15, 0.05);

			if (!pedestal.get().is(EnchantMod.RUNES))
				pedestal.clear();

			pedestal.frozen = false;
		}
	}
}
