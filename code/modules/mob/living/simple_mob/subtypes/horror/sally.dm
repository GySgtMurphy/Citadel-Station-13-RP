/datum/category_item/catalogue/fauna/horror/Sally
	name = "*@!!EARS*OF#@$$$JOY"
	desc = "%WARNING% PROCESSING FAILURE! RETURN SCANNER TO A CENTRAL \
	ADMINISTRATOR FOR IMMEDIATE MAINTENANCE! %ERROR%"
	value = CATALOGUER_REWARD_TRIVIAL

/mob/living/simple_mob/horror/Sally
	name = "???"
	desc = "A mass of tentacles hold up a large head, graced with one of the grandest smiles in the galaxy. It's a shame about the constant oil leaking from its eyes."

	icon_state = "Sally"
	icon_living = "Sally"
	icon_dead = "ws_head"
	icon_rest = "Sally"
	icon = 'icons/mob/horror_show/widehorror.dmi'
	icon_gib = "generic_gib"
	catalogue_data = list(/datum/category_item/catalogue/fauna/horror/Sally)

	attack_sound = 'sound/h_sounds/sampler.ogg'

	maxHealth = 200
	health = 200

	legacy_melee_damage_lower = 30
	legacy_melee_damage_upper = 40
	grab_resist = 100

	response_help = "pets the"
	response_disarm = "bops the"
	response_harm = "hits the"
	attacktext = list("smashes")
	friendly = list("nuzzles", "boops", "headbumps against", "leans on")


	say_list_type = /datum/say_list/Sally
	ai_holder_type = /datum/ai_holder/polaris/simple_mob/horror

	hide_amount = 10
	exotic_amount = 5

/mob/living/simple_mob/horror/Sally/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/horror_aura)

/mob/living/simple_mob/horror/Sally/death()
	playsound(src, 'sound/h_sounds/lynx.ogg', 50, 1)
	..()

/mob/living/simple_mob/horror/Sally/on_bullet_act(obj/projectile/proj, impact_flags, list/bullet_act_args)
	. = ..()
	playsound(src, 'sound/h_sounds/holla.ogg', 50, 1)

/mob/living/simple_mob/horror/Sally/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	playsound(src, 'sound/h_sounds/holla.ogg', 50, 1)
	..()

/mob/living/simple_mob/horror/Sally/throw_impacted(atom/movable/AM, datum/thrownthing/TT)
	. = ..()
	playsound(src, 'sound/h_sounds/holla.ogg', 50, 1)

/mob/living/simple_mob/horror/Sally/attackby()
	playsound(src, 'sound/h_sounds/holla.ogg', 50, 1)
	..()

/datum/say_list/Sally
	speak = list("Yeeeeee?","Haaah! Gashuuuuuh!", "Gahgahgahgah...")
	emote_hear = list("shrieks", "groans in pain", "breathes heavily", "gnashes its teeth")
	emote_see = list("wiggles its head", "shakes violently", "stares aggressively")
	say_maybe_target = list("Uuurrgghhh?")
	say_got_target = list("AAAHHHHH!")
