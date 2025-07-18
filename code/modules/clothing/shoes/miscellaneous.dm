/obj/item/clothing/shoes/syndigaloshes
	desc = "A pair of brown shoes. They seem to have extra grip."
	name = "brown shoes"
	icon_state = "brown"
	permeability_coefficient = 0.05
	clothing_flags = NOSLIP
	origin_tech = list(TECH_ILLEGAL = 3)
	var/list/clothing_choices = list()
	siemens_coefficient = 0.8
	species_restricted = null
	step_volume_mod = 0.5
	drop_sound = 'sound/items/drop/rubber.ogg'
	pickup_sound = 'sound/items/pickup/rubber.ogg'

/obj/item/clothing/shoes/mime
	name = "mime shoes"
	icon_state = "white"
	step_volume_mod = 0	//It's a mime

/obj/item/clothing/shoes/galoshes
	desc = "Rubber boots"
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	siemens_coefficient = 0 //They're thick rubber boots! Of course they won't conduct electricity!
	clothing_flags = NOSLIP
	encumbrance = ITEM_ENCUMBRANCE_SHOES_GALOSHES
	flat_encumbrance = ITEM_FLAT_ENCUMBRANCE_GALOSHES
	species_restricted = null
	drop_sound = 'sound/items/drop/rubber.ogg'
	pickup_sound = 'sound/items/pickup/rubber.ogg'

/obj/item/clothing/shoes/dress
	name = "dress shoes"
	desc = "Sharp looking low quarters, perfect for a formal uniform."
	icon_state = "laceups"

/obj/item/clothing/shoes/dress/white
	name = "white dress shoes"
	desc = "Brilliantly white low quarters, not a spot on them."
	icon_state = "whitedress"

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	species_restricted = null
	body_cover_flags = 0

	wizard_garb = 1

/obj/item/clothing/shoes/sandal/clogs
	name = "plastic clogs"
	desc = "A pair of plastic clog shoes."
	icon_state = "clogs"

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic, black shoes."
	name = "magic shoes"
	icon_state = "black"
	body_cover_flags = FEET
	origin_tech = list(TECH_BLUESPACE = 3, TECH_ARCANE = 5)

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge!"
	name = "clown shoes"
	icon_state = "clown"
	encumbrance = ITEM_ENCUMBRANCE_SHOES_CLOWN
	flat_encumbrance = ITEM_FLAT_ENCUMBRANCE_SHOES_CLOWN
	damage_force = 0
	var/footstep = 1	//used for squeeks whilst walking
	species_restricted = null

/obj/item/clothing/shoes/clown_shoes/handle_movement(var/turf/walking, var/running)
	if(running)
		if(footstep >= 2)
			footstep = 0
			playsound(src, "clownstep", 50, 1) // this will get annoying very fast.
		else
			footstep++
	else
		playsound(src, "clownstep", 20, 1)

/obj/item/clothing/shoes/cult
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "cult", SLOT_ID_LEFT_HAND = "cult")
	damage_force = 2
	siemens_coefficient = 0.7
	origin_tech = list(TECH_ARCANE = 2)

	cold_protection_cover = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection_cover = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = null

/obj/item/clothing/shoes/cult/cultify()
	return

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume"
	icon_state = "boots"

/obj/item/clothing/shoes/slippers
	name = "bunny slippers"
	desc = "Fluffy!"
	icon_state = "slippers"
	species_restricted = null
	drop_sound = 'sound/items/drop/clothing.ogg'
	pickup_sound = 'sound/items/pickup/cloth.ogg'

/obj/item/clothing/shoes/slippers_worn
	name = "worn bunny slippers"
	desc = "Fluffy..."
	icon_state = "slippers_worn"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "slippers", SLOT_ID_LEFT_HAND = "slippers")
	damage_force = 0
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/shoes/laceup
	name = "black oxford  shoes"
	icon_state = "oxford_black"

/obj/item/clothing/shoes/laceup/grey
	name = "grey oxford shoes"
	icon_state = "oxford_grey"

/obj/item/clothing/shoes/laceup/brown
	name = "brown oxford shoes"
	icon_state = "oxford_brown"

/obj/item/clothing/shoes/swimmingfins
	desc = "Help you swim good."
	name = "swimming fins"
	icon_state = "flippers"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "galoshes", SLOT_ID_LEFT_HAND = "galoshes")
	clothing_flags = NOSLIP
	encumbrance = ITEM_ENCUMBRANCE_SHOES_FINS
	flat_encumbrance = ITEM_FLAT_ENCUMBRANCE_SHOES_FINS
	species_restricted = null
	water_speed = -3

/obj/item/clothing/shoes/flipflop
	name = "flip flops"
	desc = "A pair of foam flip flops. For those not afraid to show a little ankle."
	icon_state = "thongsandal"
	addblends = "thongsandal_a"

/obj/item/clothing/shoes/athletic
	name = "athletic shoes"
	desc = "A pair of sleek atheletic shoes. Made by and for the sporty types."
	icon_state = "sportshoe"
	addblends = "sportshoe_a"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "sportheld", SLOT_ID_LEFT_HAND = "sportheld")

/obj/item/clothing/shoes/skater
	name = "skater shoes"
	desc = "A pair of wide shoes with thick soles.  Designed for skating."
	icon_state = "skatershoe"
	addblends = "skatershoe_a"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "skaterheld", SLOT_ID_LEFT_HAND = "skaterheld")

/obj/item/clothing/shoes/heels
	name = "high heels"
	desc = "A pair of high-heeled shoes. Fancy!"
	icon_state = "heels"
	addblends = "heels_a"

/obj/item/clothing/shoes/footwraps
	name = "cloth footwraps"
	desc = "A roll of treated canvas used for wrapping claws or paws"
	icon_state = "clothwrap"
	item_state = "clothwrap"
	damage_force = 0
	w_class = WEIGHT_CLASS_SMALL
	species_restricted = null
	drop_sound = 'sound/items/drop/clothing.ogg'
	pickup_sound = 'sound/items/pickup/cloth.ogg'

/obj/item/clothing/shoes/boots/ranger
	var/bootcolor = "white"
	name = "ranger boots"
	desc = "The Rangers special lightweight hybrid magboots-jetboots perfect for EVA. If only these functions were so easy to copy in reality.\
	 These ones are just a well-made pair of boots in appropriate colours."
	icon = 'icons/obj/clothing/ranger.dmi'
	icon_state = "ranger_boots"

/obj/item/clothing/shoes/boots/ranger/Initialize(mapload)
	. = ..()
	if(icon_state == "ranger_boots")
		name = "[bootcolor] ranger boots"
		icon_state = "[bootcolor]_ranger_boots"

/obj/item/clothing/shoes/boots/ranger/black
	bootcolor = "black"

/obj/item/clothing/shoes/boots/ranger/pink
	bootcolor = "pink"

/obj/item/clothing/shoes/boots/ranger/green
	bootcolor = "green"

/obj/item/clothing/shoes/boots/ranger/cyan
	bootcolor = "cyan"

/obj/item/clothing/shoes/boots/ranger/orange
	bootcolor = "orange"

/obj/item/clothing/shoes/boots/ranger/yellow
	bootcolor = "yellow"

/obj/item/clothing/shoes/roman
	name = "Roman Caligae"
	desc = "Hardy leather sandles capable of holding up for many miles."
	icon_state = "roman"

/obj/item/clothing/shoes/ashwalker
	name = "ashen sandals"
	desc = "Hardy leather sandles capable of withstanding harsh conditions."
	icon_state = "roman"

/obj/item/clothing/shoes/boots/bsing
	name = "blue performer's boots"
	desc = "Dancing in these makes you feel lighter than air."
	icon_state = "bsing"

/obj/item/clothing/shoes/boots/ysing
	name = "yellow performer's boots"
	desc = "Dance down the path laid out by your predecessor."
	icon_state = "ysing"

/obj/item/clothing/shoes/santa
	name = "santa boots"
	desc = "If you smack these boots, a cloud of fine coal will sometimes puff out."
	icon_state = "santaboots"

/obj/item/clothing/shoes/holiday
	name = "holiday shoes"
	desc = "These red, fur lined boots keep you warm inside and out."
	icon_state = "christmasbootsr"

/obj/item/clothing/shoes/holiday/green
	name = "green holiday shoes"
	desc = "The tips of these fur lined boots curl slightly, lending them a whimsical flair."
	icon_state = "christmasbootsg"

/obj/item/clothing/shoes/bountyskin
	name = "bounty hunter skinsuit (heels)"
	desc = "The original skinsuit featured agility-boosting heels. These replicas grant no assistance, but look just as stylish."
	icon_state = "bountyskin"

/obj/item/clothing/shoes/antediluvian
	name = "Antediluvian legwraps"
	desc = "These thigh-high legwraps are designed to cling tightly to the body. Secured to the feet by stirrups, it is unknown whether shoes were meant to be worn over these."
	icon_state = "antediluvian"

/obj/item/clothing/shoes/antediluvian/heels
	name = "Antediluvian heels"
	desc = "A pair of black-gold heels based on an unknown design. The inside of the shoe has an odd texture, and snugly covers the whole foot."
	icon_state = "ante"
	icon = 'icons/clothing/shoes/ante.dmi'
	worn_render_flags = WORN_RENDER_SLOT_ONE_FOR_ALL

/obj/item/clothing/shoes/antediluvian/heels/aziru
	name = "Antediluvian exposed heels"
	desc = "A pair of a set of heels recovered with an odd design. This version has toes exposed, granting the wearer elegance, or unsightliness."
	icon_state = "aziru_heels"
	icon = 'icons/clothing/shoes/ante_aziru.dmi'

/obj/item/clothing/shoes/antediluvian/heels/aziru/alt
	name = "Antediluvian exposed heels alt"
	desc = "A pair of a set of heels recovered with an odd design. This version has toes exposed, granting the wearer elegance, or unsightliness. This one has extra gold trimming."
	icon_state = "aziru_heels_alt"

// The things folks do for fashion...
/obj/item/clothing/shoes/galoshes/black
	name = "black galoshes"
	desc = "A black rubber boots."
	icon_state = "galoshes_black"

/obj/item/clothing/shoes/galoshes/starcon
	name = "dark-purple semi-galoshes"
	desc = "A dark-purple rubber boots. They obviously don't smell like a cotton candy, roses and fresh roasted peanuts."
	icon_state = "galoshes_sc"
	encumbrance = ITEM_ENCUMBRANCE_BASELINE

//More Warhammer Fun
/obj/item/clothing/shoes/utilitarian
	name = "utilitarian shoes"
	desc = "These shoes seem to have been designed for a cloven foot. They're honestly pretty uncomfortable to wear."
	icon = 'icons/clothing/suit/armor/utilitarian.dmi'
	icon_state = "taushoe"
	worn_render_flags = WORN_RENDER_SLOT_ONE_FOR_ALL

/obj/item/clothing/shoes/ballet
	name = "Antheia pointe shoes"
	desc = "These shoes feature long lace straps and flattened off toes. They originate from the Old Earth art of ballet, which featured many acrobatic and technical moves assisted by these shoes."
	icon = 'icons/clothing/shoes/ballet.dmi'
	icon_state = "ballet"
	worn_render_flags = WORN_RENDER_SLOT_ONE_FOR_ALL

/obj/item/clothing/shoes/socksandals
	name = "socks and sandals"
	desc = "These broken in leather sandals go great with a brand new pair of white socks. The ultimate in comfort for a wandering sightseer."
	icon = 'icons/clothing/shoes/tourist.dmi'
	icon_state = "touristsandal"
	worn_render_flags = WORN_RENDER_SLOT_ONE_FOR_ALL
