/**
 * Species Datums
 *
 * They are **not** singletons, however, they are globally cached as a static set
 * for use in preferences to determine default properties/whatever
 *
 * todo: make them singletons
 *
 * ? Someday we'll rework this. Someday. I believe.
 *
 * Mob set_species supports either a datum or a typepath. Mobs, upon receiving a typepath, will make their own copy for modification.
 *
 * Mob species var should **never** be the global copy.
 *
 * Unfortunately, until we decide how we want to refactor species and humans proper,
 * we're stuck doing the following:
 * - Species procs will all be static with the template of (H, ...) where H is the human it's ticking on
 * - **New species are allowed to have instance variables, like proteans using this for storage**, since species are no longer actually static cached copies
 * - **New species are allowed to use these instance variables.** TODO: unified tgui for species ability control, ability datums/actions
 * - A global cache of species by typepath will still be maintained for "static" usages of these datums, like for preferences rendering.
 */
/datum/species
	abstract_type = /datum/species

	//? Intrinsic Information

	/// todo: rename to id to prep for /datum/prototype conversion
	/// uid - **must be unique** - Identifies the exact species you are using
	var/uid
	/// todo: this shouldn't really be needed, anything
	///       requiring species checks should move to species tag system or something
	/// id usually identical to uid, if we are a subspecies we use the parent species id/uid here
	var/id
	// TODO: ref species by id in code, so we can rename as needed
	/// is a subspecies?
	//  todo: this is autodetected, and only here for legacy support
	var/is_subspecies
	/// our superspecies id if we are a subspecies
	//  todo: this is autodetected, and only here for legacy support
	var/superspecies_id

	/// Species real name.
	// TODO: STOP USING THIS. This is being phased out for species IDs.
	var/name
	/// Pluralized name (since "[name]s" is not always valid)
	var/name_plural
	/// Category in character setup
	var/category = "Miscellaneous"
	/// default bodytype to use for clothing rendering
	var/default_bodytype = BODYTYPE_DEFAULT
	///Used for metabolizing reagents.
	var/reagent_tag

	//* Traits / Physiology *//
	/// Intrinsic datum traits to apply to the mob
	var/list/mob_traits
	/// physiology modifier to add - path or instance
	var/datum/physiology_modifier/mob_physiology_modifier

	//* Sprite Accessories *//
	/// default sprite accessories for each slot; will render onto mobs if they don't have one specifically set.
	/// set to id/typepath to have it resolved during init.
	var/list/sprite_accessory_defaults = list()

	// todo: old code below

	//? Additional info
	/// what you see on tooltip/examine
	var/examine_name
	/// what you see on health analyzers/IC
	var/display_name
	/// A brief lore summary for use in the chargen screen.
	var/blurb = "A completely nondescript species."
	/// link to wiki page for species
	var/wikilink = null
	/// A list of /datum/category_item/catalogue datums, for the cataloguer, or null.
	var/list/catalogue_data = null
	/// descriptors - Bay's height and fitness difference system
	var/list/descriptors = list()

	//? Gender stuff
	var/list/genders = list(MALE, FEMALE)
	/// If true, people examining a member of this species whom are not also the same species will see them as gender neutral.	Because aliens.
	var/ambiguous_genders = FALSE
	/// Organ tag where they are located if they can be kicked for increased pain.
	var/sexybits_location = BP_GROIN // Come on... You know it's there for most of them.

	//? HUD
	var/datum/hud_data/hud
	var/hud_type
	/// This modifies how intensely the health hud is colored.
	var/health_hud_intensity = 1
	/// do we have a species statpanel?
	var/species_statpanel = FALSE

	//* IFF *//

	/// Inherent IFF factions
	///
	/// * This isn't the best way to do this, but it works.
	var/list/iff_factions_inherent

	//? Icons
	/// Normal icon set.
	var/icobase      = 'icons/mob/species/human/body.dmi'
	/// Mutated icon set.
	var/deform       = 'icons/mob/species/human/deformed_body.dmi'
	/// Preview icon used in species selection.
	var/preview_icon = 'icons/mob/species/human/preview.dmi'
	/// Species-specific husk sprite if applicable.
	var/husk_icon    = 'icons/mob/species/default_husk.dmi'
	/// Used for mob icon generation for non-32x32 species.
	var/icon_template = 'icons/mob/species/template.dmi'
	/// Makes the icon wider/thinner.
	var/icon_scale_x = 1
	/// Makes the icon taller/shorter.
	var/icon_scale_y = 1
	/// Used for offsetting large icons.
	var/pixel_offset_x = 0
	/// Used for offsetting large icons.
	var/pixel_offset_y = 0

	//* Inventory *//

	/// Available inventory slots IDs
	///
	/// * associate to list for remapping; use INVENTORY_SLOT_REMAP_* keys
	var/list/inventory_slots = list(
		/datum/inventory_slot/inventory/back::id,
		/datum/inventory_slot/inventory/suit::id,
		/datum/inventory_slot/inventory/suit_storage::id,
		/datum/inventory_slot/inventory/uniform::id,
		/datum/inventory_slot/inventory/ears/left::id,
		/datum/inventory_slot/inventory/ears/right::id,
		/datum/inventory_slot/inventory/glasses::id,
		/datum/inventory_slot/inventory/gloves::id,
		/datum/inventory_slot/inventory/mask::id,
		/datum/inventory_slot/inventory/shoes::id,
		/datum/inventory_slot/inventory/pocket/left::id,
		/datum/inventory_slot/inventory/pocket/right::id,
		/datum/inventory_slot/inventory/belt::id,
		/datum/inventory_slot/inventory/id::id,
		/datum/inventory_slot/inventory/head::id,
	)

	//? Overlays
	/// Used by changelings. Should also be used for icon previews.
	var/base_color
	/// This is used in character setup preview generation (prefences_setup.dm) and human mob rendering (update_icons.dm)
	var/color_mult = 0
	/// force non greyscale icons to greyscale before multiplying? WARNING :CITADEL JANK, REPLACE ASAP
	var/color_force_greyscale = FALSE
	var/damage_overlays = 'icons/mob/species/human/damage_overlay.dmi'
	var/damage_mask     = 'icons/mob/species/human/damage_mask.dmi'
	var/blood_mask      = 'icons/mob/species/human/blood_mask.dmi'
	/// The icon_state used inside OnFire.dmi for when on fire.
	var/fire_icon_state = "humanoid"
	/// Icons used for worn items in suit storage slot.
	var/suit_storage_icon = 'icons/mob/clothing/belt_mirror.dmi'

	//? Alternate appearance
	/// The basic skin colours this species uses.
	var/list/base_skin_colours


	//? Organs
	/// Determines the organs that the species spawns with and which required-organ checks are conducted.
	var/list/has_organ = list(
		O_HEART     = /obj/item/organ/internal/heart,
		O_LUNGS     = /obj/item/organ/internal/lungs,
		O_VOICE     = /obj/item/organ/internal/voicebox,
		O_LIVER     = /obj/item/organ/internal/liver,
		O_KIDNEYS   = /obj/item/organ/internal/kidneys,
		O_BRAIN     = /obj/item/organ/internal/brain,
		O_APPENDIX  = /obj/item/organ/internal/appendix,
		O_EYES      = /obj/item/organ/internal/eyes,
		O_STOMACH   = /obj/item/organ/internal/stomach,
		O_INTESTINE = /obj/item/organ/internal/intestine,
	)
	var/list/has_limbs = list(
		BP_TORSO  = list("path" = /obj/item/organ/external/chest),
		BP_GROIN  = list("path" = /obj/item/organ/external/groin),
		BP_HEAD   = list("path" = /obj/item/organ/external/head),
		BP_L_ARM  = list("path" = /obj/item/organ/external/arm),
		BP_R_ARM  = list("path" = /obj/item/organ/external/arm/right),
		BP_L_LEG  = list("path" = /obj/item/organ/external/leg),
		BP_R_LEG  = list("path" = /obj/item/organ/external/leg/right),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right)
	)

	//? Speech
	/// Part of icon_state to use for speech bubbles when talking.	See talk.dmi for available icons.
	var/speech_bubble_appearance = "normal"

	//? Sounds
	var/scream_verb = "screams"
	var/male_scream_sound   = list('sound/voice/screams/sound_voice_scream_scream_m1.ogg', 'sound/voice/screams/sound_voice_scream_scream_m2.ogg')
	var/female_scream_sound = list('sound/voice/screams/sound_voice_scream_scream_f1.ogg', 'sound/voice/screams/sound_voice_scream_scream_f2.ogg', 'sound/voice/screams/sound_voice_scream_scream_f3.ogg')
	var/male_cough_sounds   = list('sound/effects/mob_effects/m_cougha.ogg','sound/effects/mob_effects/m_coughb.ogg', 'sound/effects/mob_effects/m_coughc.ogg')
	var/female_cough_sounds = list('sound/effects/mob_effects/f_cougha.ogg','sound/effects/mob_effects/f_coughb.ogg')
	var/male_sneeze_sound   = 'sound/effects/mob_effects/sneeze.ogg'
	var/female_sneeze_sound = 'sound/effects/mob_effects/f_sneeze.ogg'

	/// A list of sounds to potentially play when speaking.
	var/list/speech_sounds = list()
	/// The likelihood of a speech sound playing.
	var/list/speech_chance = list()

	//? Age
	/// The minimum age a species is allowed to be played as. For our purposes, this is global.
	var/min_age = 18
	/// The maximum age a species is allowed to be played as. This is generally determined by lifespan.
	var/max_age = 70

	//? Languages
	/// default language used when speaking - typepaths are allowed
	var/default_language = LANGUAGE_ID_COMMON
	/// do we have galactic common? this is so common we just have this as a var
	var/galactic_language = TRUE
	/// intrinsic species languages - list() or singular language or null - typepaths are allowed
	// todo: linter check for language default being in here
	var/list/intrinsic_languages
	/// language our name is in - used for namegen; null to force stock ss13 namegen instead - typepaths are allowed
	// todo: language for namegen is questionaable
	var/name_language = LANGUAGE_ID_COMMON
	/// languages we are always allowed to learn (overridden by intrinsic languages) even if restricted - list() or singular language - typepaths are allowed
	var/list/whitelist_languages
	/// additional languages we can learn (ONTOP OF INTRINSIC AND CULTURE)
	var/max_additional_languages = 3
	/// The languages the species can't speak without an assisted organ.
	/// This list is a guess at things that no one other than the parent species should be able to speak
	var/list/assisted_langs = list(LANGUAGE_EAL, LANGUAGE_SKRELLIAN, LANGUAGE_SKRELLIANFAR, LANGUAGE_ROOTLOCAL, LANGUAGE_ROOTGLOBAL, LANGUAGE_VOX, LANGUAGE_PROMETHEAN)

	//? Cultures
	/// default origin
	var/default_origin = /datum/lore/character_background/origin/custom
	/// default citizenship
	var/default_citizenship = /datum/lore/character_background/citizenship/custom
	/// default faction
	var/default_faction = /datum/lore/character_background/faction/nanotrasen
	/// default religion
	var/default_religion = /datum/lore/character_background/religion/custom
	/// default culture
	var/default_culture = /datum/lore/character_background/culture/custom

	//? Flags
	/// Various specific features.
	var/species_flags = NONE
	/// Flags that specify who can spawn as this species
	var/species_spawn_flags = NONE
	/// Appearance/display related features.
	var/species_appearance_flags = NONE
	/// Whether the eyes can be shown above other icons
	var/has_floating_eyes = FALSE
	/// Whether the eyes are shown above all lighting
	var/has_glowing_eyes = FALSE

	/// fluff flags
	var/species_fluff_flags = NONE

	/// Same flags as glasses.
	var/vision_flags = SIGHT_FLAGS_DEFAULT
	/// What are we considered to be when bumped?
	var/bump_flag = HUMAN
	/// What can we push?
	var/push_flags = ~HEAVY
	/// What can we swap place with?
	var/swap_flags = ~HEAVY

	var/pass_flags = 0

	//? Stats
	/// Total health the mob has
	var/total_health = 100
	/// Point at which the mob will die
	var/death_health = MOB_MINIMUM_HEALTH
	/// Point at which the mob will enter crit
	var/crit_health = MOB_CRITICAL_HEALTH
	/// Point at which the mob will enter soft crit
	var/soft_crit_health = MOB_SOFT_CRITICAL_HEALTH
	/// Physical damage multiplier.
	var/brute_mod = 1
	/// Burn damage multiplier.
	var/burn_mod = 1
	/// Oxyloss modifier
	var/oxy_mod = 1
	/// Toxloss modifier
	var/toxins_mod = 1
	/// Radiation modifier
	var/radiation_mod = 1
	/// Stun from blindness modifier.
	var/flash_mod = 1
	/// how much damage to take from being flashed if light hypersensitive
	var/flash_burn = 0
	/// Stun from sounds, I.E. flashbangs.
	var/sound_mod = 1
	/// Damage modifier for overdose
	var/chemOD_mod = 1
	/// The lower, the thicker the skin and better the insulation.
	var/siemens_coefficient = 1
	var/virus_immune

	//? Blood
	/// What marks are left when walking
	var/obj/effect/debris/cleanable/blood/tracks/move_trail = /obj/effect/debris/cleanable/blood/tracks/footprints

	/// Name for the species' blood.
	var/blood_name = "blood"
	/// The color of the species blood.
	var/blood_color = "#A10808"
	/// Initial blood volume.
	/// TODO: Put this on living so this is moreso an override. @Zandario
	var/blood_volume = 560
	/// Multiplier for how fast a species bleeds out. Higher = Faster
	var/bloodloss_rate = 1
	/// "Safe" blood level; above this, you're OK.
	var/blood_level_safe = 0.85
	/// "Warning" blood level; above this, you're a bit woozy and will have low-level oxydamage. (no more than 20, or 15 with inap)
	var/blood_level_warning = 0.75
	/// "Danger" blood level; above this, you'll rapidly take up to 50 oxyloss, and it will then steadily accumulate at a lower rate.
	var/blood_level_danger = 0.6
	/// "Fatal" blood level; below this, you take extremely high oxydamage.
	var/blood_level_fatal = 0.4

	/// Hunger and Metabolism
	/// How sensitive the species is to minute tastes.
	var/taste_sensitivity = TASTE_NORMAL
	/// Multiplier for hunger.
	var/hunger_factor = 0.05
	var/metabolism = 0.0015
	var/metabolic_rate = 1
	/// max nutrition - i hate myself for haphazardly throwing this in but sue me
	var/max_nutrition = 450
	/// Multiplier for thirst.
	var/thirst_factor = DEFAULT_THIRST_FACTOR
	/// Can eat some mobs. 1 for mice, 2 for monkeys, 3 for people.
	var/gluttonous

	//? Sight
	/// darksight datum - set to typepath, initialized at init
	var/datum/vision/baseline/vision_innate = /datum/vision/baseline/species_tier_0
	/// Permanent weldervision.
	var/short_sighted
	/// If set, this organ is required for vision. Defaults to "eyes" if the species has them.
	var/vision_organ
	/// If set, the species will be affected by flashbangs regardless if they have eyes or not, as they see in large areas.
	var/dispersed_eyes

	//? Attacks
	/// Possible unarmed attacks that the mob will use in combat,
	var/list/unarmed_types = list(
		/datum/unarmed_attack,
		/datum/unarmed_attack/bite,
	)
	/// For empty hand harm-intent attack
	var/list/unarmed_attacks = null

	//? Abilities + Legacy Verbs / Spells
	/// abilities - typepaths, new'd on init.
	var/list/datum/ability/abilities
	/// Species-specific verbs.
	var/list/inherent_verbs = list()
	/// Species-specific spells.
	var/list/inherent_spells = list()

	//* Movement *//
	/// Base movespeed in tiles / second
	var/movement_base_speed = 5

	//? Movement - old
	/// How much faster or slower the species is in water
	var/water_movement = 0
	/// How much faster or slower the species is on snow
	var/snow_movement = 0
	/// How affected by item slowdown the species is.
	var/item_slowdown_mod = 1
	/// How affected by light the species is. Positive values slow down, negative speed up.
	/// Values are a maximum slowdown / speedup based on amount of light or lack thereof.
	var/light_slowdown = 0
	var/dark_slowdown = 0


	//? Special condition
	/// Multiplier for 'Regenerate' power speed, in human_powers.dm
	var/active_regen_mult = 1
	/// If set, mob will be damaged in light over this value and heal in light below its negative.
	var/light_dam

	//? Special Traits
	var/is_vampire = FALSE // If this is set to true, the person can't get nutrition from food.
	var/is_cyberpsycho = FALSE // If you turn this to true, the person's capacity stat decreases. (aka - Their symptoms worsen)

	//? Breath
	/// Non-oxygen gas breathed, if any.
	var/breath_type = GAS_ID_OXYGEN
	/// Poisonous air.
	var/poison_type = GAS_ID_PHORON
	/// Exhaled gas type.
	var/exhale_type = GAS_ID_CARBON_DIOXIDE

	/// Species will try to stabilize at this temperature. (also affects temperature processing)
	/// Null to disable natural stabilization.
	//  todo: shoo, needs to be organ/biology based
	var/body_temperature = 310.15
	/// Species will gain this much temperature every second
	//  todo: shoo, needs to be organ/biology based
	var/passive_temp_gain = 0

	//? Cold Air
	/// Cold damage level 1 below this point.
	var/cold_level_1 = 260
	/// Cold damage level 2 below this point.
	var/cold_level_2 = 200
	/// Cold damage level 3 below this point.
	var/cold_level_3 = 120

	/// Cold gas damage level 1 below this point.
	var/breath_cold_level_1 = 240
	/// Cold gas damage level 2 below this point.
	var/breath_cold_level_2 = 180
	/// Cold gas damage level 3 below this point.
	var/breath_cold_level_3 = 100

	/// Aesthetic messages about feeling chilly.
	var/cold_discomfort_level = 285
	var/list/cold_discomfort_strings = list(
		"You feel chilly.",
		"You shiver suddenly.",
		"Your chilly flesh stands out in goosebumps."
	)

	//? Hot Air
	/// Heat damage level 1 above this point.
	var/heat_level_1 = 360
	/// Heat damage level 2 above this point.
	var/heat_level_2 = 400
	/// Heat damage level 3 above this point.
	var/heat_level_3 = 1000

	/// Heat gas damage level 1 below this point.
	var/breath_heat_level_1 = 380
	/// Heat gas damage level 2 below this point.
	var/breath_heat_level_2 = 450
	/// Heat gas damage level 3 below this point.
	var/breath_heat_level_3 = 1250

	/// Aesthetic messages about feeling warm.
	var/heat_discomfort_level = 315
	var/list/heat_discomfort_strings = list(
		"You feel sweat drip down your neck.",
		"You feel uncomfortably warm.",
		"Your skin prickles in the heat."
	)

	//? Pressure
	/// Dangerously high pressure.
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE
	/// High pressure warning.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE

	var/safe_pressure = ONE_ATMOSPHERE
	/// Low pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE
	/// Dangerously low pressure.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE


	/// Minimum required pressure for breath, in kPa
	var/minimum_breath_pressure = 16

	//? Custom species stuff
	var/lightweight = FALSE //Oof! Nonhelpful bump stumbles.
	var/trashcan = FALSE //It's always sunny in the wrestling ring.
	var/base_species = null // Unused outside of a few species
	var/selects_bodytype = FALSE // Allows the species to choose from body types intead of being forced to be just one.
	/// override for bodytype
	var/override_worn_legacy_bodytype
	/// traits
	var/list/traits = list()

	//? Misc
	var/mob_size = MOB_MEDIUM
	var/show_ssd = "fast asleep"
	/// This allows you to pick up crew
	var/holder_type = /obj/item/holder/micro
	var/custom_ability_handler

	//? on death drops
	/// The color of the species flesh.
	var/flesh_color = "#FFC896"
	var/meat_type = /obj/item/reagent_containers/food/snacks/meat/human
	var/bone_type = /obj/item/stack/material/bone
	var/hide_type = /obj/item/stack/animalhide/human
	var/exotic_type = /obj/item/stack/sinew
	var/remains_type = /obj/effect/decal/remains/xeno

	//? Dying
	var/gibbed_anim = "gibbed-h"
	var/dusted_anim = "dust-h"
	var/death_sound
	var/death_message = "seizes up and falls limp, their eyes dead and lifeless..."
	var/knockout_message = "has been knocked unconscious!"
	var/cloning_modifier = /datum/modifier/cloning_sickness

	//? Primitive species
	/// Lesser form, if any (ie. monkey for humans)
	var/primitive_form
	/// Greater form, if any, ie. human for monkeys.
	var/greater_form
	/// Can use small items.
	var/has_fine_manipulation = TRUE

	//? OLD Vars
	/// Whether the species can infect wounds, only works with claws / bites
	var/infect_wounds = 0
	//How quickly the species can fly up z-levels (0 is instant, 1 is 7 seconds, 0.5 is ~3.5 seconds)
	var/flight_mod = 1

	// Alpha values
	var/minimum_hair_alpha = 255
	var/maximum_hair_alpha = 255
	var/minimum_body_alpha = 255
	var/maximum_body_alpha = 255

	// Actions to grant when species is applied / remove when species is removed
	var/list/actions_to_apply = list()
	var/list/actions_applied = list()

	// How much hunger slows us down
	var/hunger_slowdown_multiplier = 1

/datum/species/New()
	//! LEGACY
	is_subspecies = id != uid
	superspecies_id = id
	if(!id)
		id = uid
	if(!uid)
		uid = id

	if(hud_type)
		hud = new hud_type()
	else
		hud = new()

	// Prep the descriptors for the species
	if(LAZYLEN(descriptors))
		var/list/descriptor_datums = list()
		for(var/desctype in descriptors)
			var/datum/mob_descriptor/descriptor = new desctype
			descriptor.comparison_offset = descriptors[desctype]
			descriptor_datums[descriptor.name] = descriptor
		descriptors = descriptor_datums

	unarmed_attacks = list()
	for(var/u_type in unarmed_types)
		unarmed_attacks += new u_type()

	if(gluttonous)
		if(!inherent_verbs)
			inherent_verbs = list()
		inherent_verbs |= /mob/living/carbon/human/proc/regurgitate

	//! END

	if(abilities)
		var/list/built = list()
		for(var/path in abilities)
			if(istype(path, /datum/ability))
				built += path
			else if(!ispath(path))
				continue
			built += new path
		abilities = built

	sprite_accessory_defaults = resolve_sprite_accessory_key_list_inplace(sprite_accessory_defaults)

/**
 * called when we apply to a mob
 *
 * **this does not create organs**
 *
 * handle_post_spawn() and create_organs() should be called manually if you are applying a species to a human being instantiated!
 */
/datum/species/proc/on_apply(mob/living/carbon/human/H)
	// todo: language sources and holder
	for(var/id in get_intrinsic_language_ids())
		H.add_language(id)
	if(galactic_language)
		H.add_language(LANGUAGE_ID_COMMON)

	if(holder_type)
		H.holder_type = holder_type

	if(!(H.gender in genders))
		H.gender = genders[1]

	H.maxHealth = total_health
	H.minHealth = death_health
	H.critHealth = crit_health
	H.softCritHealth = soft_crit_health

	if(!isnull(mob_physiology_modifier))
		H.add_physiology_modifier(mob_physiology_modifier)

	add_inherent_verbs(H)

	for(var/name in traits)
		var/datum/trait/T = all_traits[name]
		T.apply(src, H)

	for(var/trait in mob_traits)
		ADD_TRAIT(H, trait, SPECIES_TRAIT)

	for(var/datum/ability/ability as anything in abilities)
		ability.associate(H)

	for(var/faction in iff_factions_inherent)
		H.add_iff_faction(faction)

	for(var/path in actions_to_apply)
		var/datum/action/A = new path(H)
		A.grant(H.actions_innate)
		actions_applied += A

/**
 * called when we are removed from a mob
 */
/datum/species/proc/on_remove(mob/living/carbon/human/H)
	// todo: language sources and holder
	for(var/id in get_intrinsic_language_ids())
		H.remove_language(id)
	if(galactic_language)
		H.remove_language(LANGUAGE_ID_COMMON)

	remove_inherent_spells(H)
	remove_inherent_verbs(H)
	H.holder_type = null

	if(!isnull(mob_physiology_modifier))
		H.remove_physiology_modifier(mob_physiology_modifier)

	for(var/name in traits)
		var/datum/trait/T = all_traits[name]
		T.remove(src, H)

	for(var/trait in mob_traits)
		REMOVE_TRAIT(H, trait, SPECIES_TRAIT)

	for(var/datum/ability/ability as anything in abilities)
		ability.disassociate(H)

	for(var/faction in iff_factions_inherent)
		H.remove_iff_faction(faction)

	for(var/datum/action/A in actions_applied)
		A.revoke(H.actions_controlled)

/datum/species/proc/sanitize_species_name(var/name)
	return sanitizeName(name, MAX_NAME_LEN)

GLOBAL_LIST_INIT(species_oxygen_tank_by_gas, list(
	GAS_ID_OXYGEN = /obj/item/tank/emergency/oxygen,
	GAS_ID_NITROGEN = /obj/item/tank/emergency/nitrogen,
	GAS_ID_PHORON = /obj/item/tank/emergency/phoron,
	GAS_ID_CARBON_DIOXIDE = /obj/item/tank/emergency/carbon_dioxide
))

/**
 * Injects spawn descriptors into `into_box` and `into_inv` lists. Both must be provided.
 *
 * Descriptors can be;
 * * a typepath
 * * an anonymous type
 *
 * Notes:
 * * The `into_box` and `into_inv` lists should always be added to via `?.Add()`, incase they are null.
 * * Returned lists **must** be handled. If you aren't equipping anything, properly qdel() any spawned items, or
 *   a memory leak will result.
 *
 * @params
 * * for_target - (optional) person who is getting survival gear. if this is not provided, default
 *                survival gear that would go on them through inventory calls should be put into `into_inv`.
 * * into_box - things to put into their survival kit. do not put anything large in here.
 * * into_inv - things to make sure they have somewhere on, or near them. anything large can be put in here.
 *              things will not necessarily be put in their backpack, as an example a wheelchair would be put under them.
 */
/datum/species/proc/apply_racial_gear(mob/living/carbon/for_target, list/into_box, list/into_inv)
	return

/**
 * Injects spawn descriptors into `into_box` and `into_inv` lists. Both must be provided.
 *
 * Descriptors can be;
 * * a typepath
 * * an anonymous type
 *
 * Notes:
 * * The `into_box` and `into_inv` lists should always be added to via `?.Add()`, incase they are null.
 * * Returned lists **must** be handled. If you aren't equipping anything, properly qdel() any spawned items, or
 *   a memory leak will result.
 *
 * @params
 * * for_target - (optional) person who is getting survival gear. if this is not provided, default
 *                survival gear that would go on them through inventory calls should be put into `into_inv`.
 * * into_box - things to put into their survival kit. do not put anything large in here.
 * * into_inv - things to make sure they have somewhere on, or near them. anything large can be put in here.
 *              things will not necessarily be put in their backpack, as an example a wheelchair would be put under them.
 */
/datum/species/proc/apply_survival_gear(mob/living/carbon/for_target, list/into_box, list/into_inv)
	into_box?.Add(/obj/item/tool/prybar/red)

	// todo: crank flashlight + prybar combo?
	into_box?.Add(/obj/item/flashlight/flare/survival)

	if(for_target.isSynthetic())
		into_box?.Add(/obj/item/fbp_backup_cell)
	else
		into_box?.Add(
			/obj/item/clothing/mask/breath,
			/obj/item/stack/medical/bruise_pack,
			/obj/item/reagent_containers/hypospray/autoinjector,
			/obj/item/reagent_containers/food/snacks/wrapped/proteinbar,
			/obj/item/clothing/glasses/goggles,
		)

		if(breath_type)
			var/given_path = GLOB.species_oxygen_tank_by_gas[breath_type]
			var/tankpath

			// always extended now!
			// if(extendedtank)
			tankpath = text2path("[given_path]" + "/engi")
			if(!tankpath) //Is it just that there's no /engi?
				tankpath = text2path("[given_path]" + "/double")

			if(!tankpath)
				tankpath = given_path

			if(tankpath)
				into_box?.Add(tankpath)
			else
				stack_trace("Could not find a tank path for breath type [breath_type], given path was [given_path].")

/**
 * called to ensure organs are consistent with our species's
 * this is a destructive operation and will erase old organs!
 */
/datum/species/proc/create_organs(var/mob/living/carbon/human/H, var/delete_nif = FALSE) //Handles creation of mob organs.
	H.mob_size = mob_size

	// if we have a NIF, unimplant it before it gets wiped
	var/obj/item/nif/our_nif = H.nif
	if(H.nif)
		H.nif.unimplant(H)

	// store the markings for each limb we have so we can apply them to our new limbs
	var/list/temporary_marking_store = list()
	for(var/limb_type in has_limbs)
		var/obj/item/organ/external/existing_limb = H.organs_by_name[limb_type]
		if(existing_limb && istype(existing_limb))
			temporary_marking_store[limb_type] = existing_limb.markings

	for(var/obj/item/organ/organ in H.contents)
		if((organ in H.organs) || (organ in H.internal_organs))
			qdel(organ)

	if(H.organs)									H.organs.Cut()
	if(H.internal_organs)				 H.internal_organs.Cut()
	if(H.organs_by_name)					H.organs_by_name.Cut()
	if(H.internal_organs_by_name) H.internal_organs_by_name.Cut()

	H.organs = list()
	H.internal_organs = list()
	H.organs_by_name = list()
	H.internal_organs_by_name = list()

	for(var/limb_type in has_limbs)
		var/list/organ_data = has_limbs[limb_type]
		var/limb_path = organ_data["path"]
		var/obj/item/organ/O = new limb_path(H)
		organ_data["descriptor"] = O.name
		if(O.parent_organ)
			organ_data = has_limbs[O.parent_organ]
			organ_data["has_children"] = organ_data["has_children"]+1

		// check if we had an old limb of the same type that had markings
		var/obj/item/organ/external/limb = O
		var/markings_for_limb = temporary_marking_store[limb_type]
		if(istype(O) && markings_for_limb)
			limb.markings = markings_for_limb

	for(var/organ_tag in has_organ)
		var/organ_type = has_organ[organ_tag]
		var/obj/item/organ/O = new organ_type(H,1)
		if(organ_tag != O.organ_tag)
			warning("[O.type] has a default organ tag \"[O.organ_tag]\" that differs from the species' organ tag \"[organ_tag]\". Updating organ_tag to match.")
			O.organ_tag = organ_tag
		H.internal_organs_by_name[organ_tag] = O

	// if we had a NIF, decide if we want to delete it, or put it back
	if(our_nif)
		if(delete_nif)
			QDEL_NULL(our_nif)
		else
			our_nif.quick_implant(H)

	if(base_color)
		H.r_skin = hex2num(copytext(base_color,2,4))
		H.g_skin = hex2num(copytext(base_color,4,6))
		H.b_skin = hex2num(copytext(base_color,6,8))
	else
		H.r_skin = 0
		H.g_skin = 0
		H.b_skin = 0

/**
 * called to ensure blood is consistent
 * this is a destructive proc and will erase incompatible blood.
 */
/datum/species/proc/create_blood(mob/living/carbon/human/H)
	if(species_flags & NO_BLOOD)
	else
		H.create_blood()

/datum/species/proc/hug(var/mob/living/carbon/human/H, var/mob/living/target)

	var/t_him = "them"
	if(ishuman(target))
		var/mob/living/carbon/human/T = target
		if(!T.species.ambiguous_genders || (T.species.ambiguous_genders && H.species == T.species))
			switch(T.identifying_gender)
				if(MALE)
					t_him = "him"
				if(FEMALE)
					t_him = "her"
		else
			t_him = "them"
	else
		switch(target.gender)
			if(MALE)
				t_him = "him"
			if(FEMALE)
				t_him = "her"
	if(H.zone_sel.selecting == "head") // Headpats and Handshakes!
		H.visible_message( \
			"<span class='notice'>[H] pats [target] on the head.</span>", \
			"<span class='notice'>You pat [target] on the head.</span>", )
	else if(H.zone_sel.selecting == "r_hand" || H.zone_sel.selecting == "l_hand")
		H.visible_message( \
			"<span class='notice'>[H] shakes [target]'s hand.</span>", \
			"<span class='notice'>You shake [target]'s hand.</span>", )
	//Ports nose booping
	else if(H.zone_sel.selecting == "mouth")
		H.visible_message( \
			"<span class='notice'>[H] boops [target]'s nose.</span>", \
			"<span class='notice'>You boop [target] on the nose.</span>", )
	else H.visible_message("<span class='notice'>[H] hugs [target] to make [t_him] feel better!</span>", \
					"<span class='notice'>You hug [target] to make [t_him] feel better!</span>")

/datum/species/proc/remove_inherent_verbs(var/mob/living/carbon/human/H)
	if(!inherent_verbs)
		return
	remove_verb(H, inherent_verbs)

/datum/species/proc/add_inherent_verbs(var/mob/living/carbon/human/H)
	add_verb(H, inherent_verbs)

/datum/species/proc/add_inherent_spells(var/mob/living/carbon/human/H)
	if(inherent_spells)
		for(var/spell_to_add in inherent_spells)
			var/spell/S = new spell_to_add(H)
			H.add_spell(S)

/datum/species/proc/remove_inherent_spells(var/mob/living/carbon/human/H)
	H.spellremove()

/**
 * called after a mob is **fully** spawned
 */
/datum/species/proc/handle_post_spawn(var/mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	H.mob_bump_flag = bump_flag
	H.mob_swap_flags = swap_flags
	H.mob_push_flags = push_flags
	H.pass_flags = pass_flags

/datum/species/proc/handle_death(var/mob/living/carbon/human/H, gibbed = FALSE) //Handles any species-specific death events (such as dionaea nymph spawns).
	return

// Only used for alien plasma weeds atm, but could be used for Dionaea later.
/datum/species/proc/handle_environment_special(mob/living/carbon/human/H, datum/gas_mixture/environment, dt)
	return

// Used to update alien icons for aliens.
/datum/species/proc/handle_login_special(var/mob/living/carbon/human/H)
	return

// As above.
/datum/species/proc/handle_logout_special(var/mob/living/carbon/human/H)
	return

// Builds the HUD using species-specific icons and usable slots.
/datum/species/proc/build_hud(var/mob/living/carbon/human/H)
	return

//Used by xenos understanding larvae and dionaea understanding nymphs.
/datum/species/proc/can_understand(var/mob/other)
	return

// Called when using the shredding behavior.
/datum/species/proc/can_shred(var/mob/living/carbon/human/H, var/ignore_intent)

	if(!ignore_intent && H.a_intent != INTENT_HARM)
		return 0

	for(var/datum/unarmed_attack/attack in unarmed_attacks)
		if(!attack.is_usable(H))
			continue
		if(attack.damage_mode & DAMAGE_MODE_SHRED)
			return 1

	return 0

// Called in life() when the mob has no client.
/datum/species/proc/handle_npc(var/mob/living/carbon/human/H)
	if(H.stat == CONSCIOUS && H.ai_holder)
		if(H.resting)
			H.set_intentionally_resting(FALSE)

// Called when lying down on a water tile.
/datum/species/proc/can_breathe_water()
	return FALSE

// Impliments different trails for species depending on if they're wearing shoes.
/datum/species/proc/get_move_trail(var/mob/living/carbon/human/H)
	if( H.is_avoiding_ground() )
		return /obj/effect/debris/cleanable/blood/tracks/flying
	if( H.shoes || ( H.wear_suit && (H.wear_suit.body_cover_flags & FEET) ) )
		return /obj/effect/debris/cleanable/blood/tracks/footprints
	else
		return move_trail

/datum/species/proc/update_skin(var/mob/living/carbon/human/H)
	return

/datum/species/proc/get_eyes(var/mob/living/carbon/human/H)
	return

/datum/species/proc/can_overcome_gravity(var/mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/handle_fall_special(var/mob/living/carbon/human/H, var/turf/landing)
	return FALSE

// Used for any extra behaviour when falling and to see if a species will fall at all.
/datum/species/proc/can_fall(var/mob/living/carbon/human/H)
	return TRUE

// Used to find a special target for falling on, such as pouncing on someone from above.
/datum/species/proc/find_fall_target_special(src, landing)
	return FALSE

// Used to override normal fall behaviour. Use only when the species does fall down a level.
/datum/species/proc/fall_impact_special(var/mob/living/carbon/human/H, var/atom/A)
	return FALSE

// Allow species to display interesting information in the human stat panels
/datum/species/proc/statpanel_status(client/C, mob/living/carbon/human/H)
	return list()

/datum/species/proc/update_attack_types()
	unarmed_attacks = list()
	for(var/u_type in unarmed_types)
		unarmed_attacks += new u_type()

/datum/species/proc/give_numbing_bite() //Holy SHIT this is hacky, but it works. Updating a mob's attacks mid game is insane.
	unarmed_attacks = list()
	unarmed_types += /datum/unarmed_attack/bite/sharp/numbing
	for(var/u_type in unarmed_types)
		unarmed_attacks += new u_type()

/datum/species/proc/handle_falling(mob/living/carbon/human/H, atom/hit_atom, damage_min, damage_max, silent, planetary)
	return FALSE

/datum/species/proc/get_default_origin_id()
	return SScharacters.resolve_origin(default_origin).id

/datum/species/proc/get_default_citizenship_id()
	return SScharacters.resolve_citizenship(default_citizenship).id

/datum/species/proc/get_default_faction_id()
	return SScharacters.resolve_faction(default_faction).id

/datum/species/proc/get_default_religion_id()
	return SScharacters.resolve_religion(default_religion).id

/datum/species/proc/get_default_culture_id()
	return SScharacters.resolve_culture(default_culture).id

/**
 * clones us into a new datum
 */
/datum/species/clone()
	var/datum/species/created = new type
	created.copy_from(src)
	return created

/**
 * completely clones us from another species, updating the provided human in the process
 *
 * @params
 * to_copy - species copy
 * traits - traits to add
 * H - update this human
 */
/datum/species/proc/copy_from(datum/species/to_copy, list/traits = list(), mob/living/carbon/human/H)
	ASSERT(to_copy)

	if(ispath(to_copy))
		to_copy = SScharacters.resolve_species_path(to_copy)
	if(istext(to_copy))
		to_copy = SScharacters.resolve_species_name(to_copy)

	//Initials so it works with a simple path passed, or an instance
	base_species = to_copy.name
	icobase = to_copy.icobase
	deform = to_copy.deform
	sprite_accessory_defaults = to_copy.sprite_accessory_defaults.Copy()
	color_mult = to_copy.color_mult
	primitive_form = to_copy.primitive_form
	species_appearance_flags = to_copy.species_appearance_flags
	flesh_color = to_copy.flesh_color
	base_color = to_copy.base_color
	blood_mask = to_copy.blood_mask
	damage_mask = to_copy.damage_mask
	damage_overlays = to_copy.damage_overlays
	move_trail = move_trail
	has_floating_eyes = has_floating_eyes


	//Set up the mob provided
	if(H)
		// If you had traits, apply them
		// but also make sure the human's species is actually us
		ASSERT(H.species == src)

		var/list/adding = traits - src.traits
		var/list/removing = src.traits - traits
		for(var/name in adding)
			var/datum/trait/T = all_traits[name]
			T.apply(src, H)
		for(var/name in removing)
			var/datum/trait/T = all_traits[name]
			T.remove(src, H)
		src.traits = traits

		//H.icon_state = lowertext(get_bodytype_legacy())

		if(holder_type)
			H.holder_type = holder_type

		if(H.dna)
			H.dna.ready_dna(H)
	else
		src.traits = traits

//? Darksight

/**
 * Makes sure innate darksight is there
 */
/datum/species/proc/assert_innate_vision()
	if(ispath(vision_innate))
		vision_innate = new vision_innate

/**
 * Handle specific job outfit stuff if applicable
 */
/datum/species/proc/handle_species_job_outfit(var/mob/living/carbon/human/H, var/datum/outfit/outfit)
  return
