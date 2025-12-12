## Universal
+ Pathouli
	- grappling hook essential
	- make a mention of bedrock1 being breakable only with iron
	- name book item "We're sorry but you'll need this :)"
+ Alloying mod
+ QOL Mods
	- Skin Layers 3d
	- sounds
	- backpack mod
+ Textures for layer seperator blocks
+ Create low, medium, high and ultra shader presets while keeping the current shader settings and look intact
	- update complementary+euphoriapatches
	- we kinda have low already (mellow)
	- drop high and just have med+ultra?
+ Update mods that need to be updated
+ Custom Main menu
+ To make plates place an ingot on anvil and hit with hammer. Plates required to make armor.
+ Make an in-house hammer mod
+ Make an in-house copper tools mod
+ Potentially remove wooden armour
+ disable mobs - mammutilation
+ keepinventory only keep: curios, armour, pickaxe, grappling hook
+ disable random hammer and excavator variants for playtest
- fix kobold trades, add modded ones perhaps
- fix coal emmision being white, NatureX L
- possibly move NatureX to a submodule

## Polish
+ Disable Aether tips
+ fix a million pop ups upon world creation
- Stop the alex's mobs book being given upon world creation
+ Block Bench traveler's titles for every dimension
+ fix a million pop ups upon world creation
- ensure stone pickaxe is not viewable in rei or whatever

## Sequence Breaks
- make iron golem drop nuggets so its not worth killing

## ongoing WIP
+ further adjust biome size/frequency in custom dimensions

---

## Overworld
+ improve overworld cave gen with mod (yungs caves? WF's cave overhaul?)
+ replace bedrock with adresources:bedrock1 without using block swap mod (not required for MVP)
+ Potentially descrease spawn rate of slimes?
- make villages and loot related structures not spawn near 0,0

## Delver's Beginning
+ add crafting recipe for Elytra using phantom membrane (obtained from pink salt dungeon)
+ make sure pink salt shrines loot pool doesnt have stuff it shouldn't
+ add more structures - species spectre sword in stone thing
+ Change default blocks for biomes if possible. Ideally less deepslate fills this layer.
+ lower coal ore gen
+ make small bioshrooms only generate on the right block
- fix species sword structure so it generates underground

## The Undergarden
+ Add unbreakable block called Hardened root and set it as the new bedrock floor block
+ Add new block called weakened root block, only mineable by forgotten pickaxe harvest level

1. Beat Forgotten Guardians by raiding catacombs structure
- Drops forgotten nuggets

2. Beat Void Blossom
- Drops Acid

3. Trade with stoneborn
- Give crystal fruit + void thorn to get acid bottle
- Give 1 Cloggrum axe + 1 Forgotten Ingot to get the forgotten axe (also add other forgotten tools to the list but the axe is what you need for progression)

4. Mining into Infernal Crossing 
 - Right click hardened root block with acid bottle. 
 - hardened root block turns into weakened root block
- Mine weakened root block with forgotten axe
- Continue mining into Infernal Crossing

## Infernal Crossing
+ sprinkle in some spelunkers Charm 2 Cave features into bottom part of layer.
+ add more ores and things to mine
+ add structures
+ balance mob spawn rates based on playtesting

---

## Balance

## Sound
- Add audio to play alongside traveler's titles

## Textures

## Visual
- add deeper darker plants to shader block.properties for shader side advanced colored lighting

## Progression

## Aesthetic
- Improve the vanilla non shader skybox for layers with vanilla skybox
- Remove clouds from the Aether.

## Worldgen
- Drastically increase end island size and height variation
- Recreate ceilands dimension to make it end themed

## Mobs
+ Add wandering soul to ice layer

## Other
- create a jeresources preset for new ore generation
- remove the spelunkery dimensional tears from the bottom of the end
- rewrite current in-house mods to kotlin or clojure (hopefully clojure :L)

## High Priority Slab stuff (in order)
+ add the following hammers
	- 1. Copper Hammer
	- 2. Iron Hammer
	- 3. Silver Hammer
	- 4. Gold Hammer
	- 5. Diamond Hammer
	- 6. Cloggrum Hammer
	- 7. Froststeel Hammer
	- 8. Utherium Hammer
- add a plate making system
+ find a way to edit the void blossom structure. it has no .nbt data and cannot be edited by data pack. it is hard coded.
	- 1. replace minecraft:moss_block with undergarden:depthrock
	- 2. replace minecraft:cave_vine with undergarden:droopvine_plant
	- 3. replace minecraft:stone with undergarden:depthrock
	- 4. replace minecraft:budding_amethyst with geode_plus:budding_deepslate_diamond
	- 5. replace minecraft:amethyst with 50 % minecraft:deepslate 40% deepslate diamond ore and 10% geode_plus:diamond_crystal_block
	- 6. if you can just get me the structures NBT data I can doo all of this myself but you will need to reinject it with a mixin or something. 
