package AbyssalDescent.adresources;

import net.minecraft.ChatFormatting;
import net.minecraft.network.chat.Component;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.world.food.FoodProperties;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.TooltipFlag;
import net.minecraft.world.effect.MobEffect;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.level.Level;

import java.util.List;

public class CureItem extends Item {
	public static final FoodProperties FOOD = new FoodProperties.Builder()
		.nutrition(2).saturationMod(0.3F).alwaysEat().build();

	public static final MobEffect BLOODLUST = 
		BuiltInRegistries.MOB_EFFECT.get(new ResourceLocation("species", "bloodlust"));

	public CureItem(Item.Properties p) {
		super(p.food(FOOD));
	}

	@Override
	public ItemStack finishUsingItem(ItemStack stack, Level level, LivingEntity entity) {
		if (!level.isClientSide()) {
			entity.removeEffect(this.BLOODLUST);
		}

		return super.finishUsingItem(stack, level, entity);
	}
	
	@Override
	public void appendHoverText(ItemStack stack, Level level, List<Component> tt, TooltipFlag f) {
		tt.add(Component.literal("used by cave shamans to cure bloodlust")
			.withStyle(ChatFormatting.GRAY).withStyle(ChatFormatting.ITALIC));
	}
}
