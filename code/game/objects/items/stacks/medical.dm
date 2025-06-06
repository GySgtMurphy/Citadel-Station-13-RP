/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/items/stacks/medical.dmi'
	use_new_icon_update = TRUE
	skip_legacy_icon_update = TRUE
	amount = 10
	max_amount = 10
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 20
	var/heal_brute = 0
	var/heal_burn = 0
	var/apply_sounds
	drop_sound = 'sound/items/drop/cardboardbox.ogg'
	pickup_sound = 'sound/items/pickup/cardboardbox.ogg'

	var/upgrade_to	// The type path this stack can be upgraded to.

/obj/item/stack/medical/legacy_mob_melee_hook(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	if(user.a_intent == INTENT_HARM)
		return ..()
	checked_application(target, user)

/obj/item/stack/medical/proc/checked_application(mob/M, mob/user)
	var/mob/living/carbon/C = M
	if(!istype(C))
		to_chat(user, "<span class='warning'>\The [src] cannot be applied to [M]!</span>")
		return FALSE

	if ( !user.IsAdvancedToolUser() )
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(!affecting)
			to_chat(user, "<span class='warning'>No body part there to work on!</span>")
			return FALSE

		if(affecting.behaviour_flags & BODYPART_NO_HEAL)
			to_chat(user, "<span class='warning'>You aren't able to apply the [src] to [affecting]!")
			return FALSE

		if(affecting.organ_tag == BP_HEAD)
			if(H.head && istype(H.head,/obj/item/clothing/head/helmet/space))
				to_chat(user, "<span class='warning'>You can't apply [src] through [H.head]!</span>")
				return FALSE
		else
			if(istype(H.inventory.get_slot_single(/datum/inventory_slot/inventory/suit), /obj/item/clothing/suit/space))
				to_chat(user, "<span class='warning'>You can't apply [src] through [H.wear_suit]!</span>")
				return FALSE

		if(affecting.robotic == ORGAN_ROBOT)
			to_chat(user, "<span class='warning'>This isn't useful at all on a robotic limb.</span>")
			return FALSE

		if(affecting.robotic >= ORGAN_LIFELIKE)
			to_chat(user, "<span class='warning'>You apply the [src], but it seems to have no effect...</span>")
			use(1)
			return FALSE
		H.update_damage_overlay()
	else
		C.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))
		user.visible_message( \
			"<span class='notice'>[M] has been applied with [src] by [user].</span>", \
			"<span class='notice'>You apply \the [src] to [M].</span>" \
		)
		use(1)
		. = FALSE // already did so
	C.update_health()
	return TRUE

/obj/item/stack/medical/proc/upgrade_stack(var/upgrade_amount)
	. = FALSE

	var/turf/T = get_turf(src)

	if(ispath(upgrade_to) && use(upgrade_amount))
		var/obj/item/stack/medical/M = new upgrade_to(T, upgrade_amount)
		return M

	return .

/obj/item/stack/medical/crude_pack
	name = "crude bandage"
	singular_name = "crude bandage length"
	desc = "Some bandages to wrap around bloody stumps."
	icon_state = "bandage"
	icon_state_count = 3
	base_icon_state = "bandage"
	origin_tech = list(TECH_BIO = 1)
	no_variants = FALSE
	apply_sounds = list('sound/effects/rip1.ogg','sound/effects/rip2.ogg')
	drop_sound = 'sound/items/drop/gloves.ogg'
	pickup_sound = 'sound/items/pickup/gloves.ogg'

	upgrade_to = /obj/item/stack/medical/bruise_pack

/obj/item/stack/medical/crude_pack/checked_application(mob/M, mob/user)
	if(!(. = ..()))
		return

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open)
			to_chat(user, "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>")
			return

		if(affecting.is_bandaged())
			to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been bandaged.</span>")
			return
		else
			user.visible_message("<span class='notice'>\The [user] starts bandaging [M]'s [affecting.name].</span>", \
					             "<span class='notice'>You start bandaging [M]'s [affecting.name].</span>" )
			var/used = 0
			for (var/datum/wound/W as anything in affecting.wounds)
				if (W.internal)
					continue
				if(W.bandaged)
					continue
				if(used == amount)
					break
				if(!do_mob(user, M, W.damage/3))
					to_chat(user, "<span class='notice'>You must stand still to bandage wounds.</span>")
					break

				if(affecting.is_bandaged()) // We do a second check after the delay, in case it was bandaged after the first check.
					to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been bandaged.</span>")
					return

				if (W.current_stage <= W.max_bleeding_stage)
					user.visible_message("<span class='notice'>\The [user] bandages \a [W.desc] on [M]'s [affecting.name].</span>", \
					                              "<span class='notice'>You bandage \a [W.desc] on [M]'s [affecting.name].</span>" )
				else
					user.visible_message("<span class='notice'>\The [user] places a bandage over \a [W.desc] on [M]'s [affecting.name].</span>", \
					                              "<span class='notice'>You place a bandage over \a [W.desc] on [M]'s [affecting.name].</span>" )
				W.bandage()
				playsound(src, pick(apply_sounds), 25)
				used++
			affecting.update_damages()
			if(used == amount)
				if(affecting.is_bandaged())
					to_chat(user, "<span class='warning'>\The [src] is used up.</span>")
				else
					to_chat(user, "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [affecting.name].</span>")
			use(used)

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	icon_state = "gauze"
	icon_state_count = 3
	base_icon_state = "gauze"
	desc = "Some sterile gauze to wrap around bloody stumps."
	origin_tech = list(TECH_BIO = 1)
	no_variants = FALSE
	apply_sounds = list('sound/effects/rip1.ogg','sound/effects/rip2.ogg')

	upgrade_to = /obj/item/stack/medical/advanced/bruise_pack

/obj/item/stack/medical/bruise_pack/checked_application(mob/M, mob/user)
	if(!(. = ..()))
		return

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open)
			to_chat(user, "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>")
			return

		if(affecting.is_bandaged())
			to_chat(user, "<span class='warning'>The wounds on [H]'s [affecting.name] have already been bandaged.</span>")
			return
		else
			user.visible_message("<span class='notice'>\The [user] starts treating [H]'s [affecting.name].</span>", \
					             "<span class='notice'>You start treating [H]'s [affecting.name].</span>" )
			var/used = 0
			for (var/datum/wound/W as anything in affecting.wounds)
				if (W.internal)
					continue
				if(W.bandaged)
					continue
				if(used == amount)
					break
				if(!do_mob(user, H, W.damage/5))
					to_chat(user, "<span class='notice'>You must stand still to bandage wounds.</span>")
					break

				if(affecting.is_bandaged()) // We do a second check after the delay, in case it was bandaged after the first check.
					to_chat(user, "<span class='warning'>The wounds on [H]'s [affecting.name] have already been bandaged.</span>")
					return

				if (W.current_stage <= W.max_bleeding_stage)
					user.visible_message("<span class='notice'>\The [user] bandages \a [W.desc] on [H]'s [affecting.name].</span>", \
					                              "<span class='notice'>You bandage \a [W.desc] on [H]'s [affecting.name].</span>" )
					//H.add_side_effect("Itch")
				else if (W.wound_type == WOUND_TYPE_BRUISE)
					user.visible_message("<span class='notice'>\The [user] places a bruise patch over \a [W.desc] on [H]'s [affecting.name].</span>", \
					                              "<span class='notice'>You place a bruise patch over \a [W.desc] on [H]'s [affecting.name].</span>" )
				else
					user.visible_message("<span class='notice'>\The [user] places a bandaid over \a [W.desc] on [H]'s [affecting.name].</span>", \
					                              "<span class='notice'>You place a bandaid over \a [W.desc] on [H]'s [affecting.name].</span>" )
				W.bandage()
				playsound(src, pick(apply_sounds), 25)
				used++
				H.bitten = 0
			affecting.update_damages()
			if(used == amount)
				if(affecting.is_bandaged())
					to_chat(user, "<span class='warning'>\The [src] is used up.</span>")
				else
					to_chat(user, "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [affecting.name].</span>")
			use(used)

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	icon_state_count = 3
	base_icon_state = "ointment"
	heal_burn = 1
	origin_tech = list(TECH_BIO = 1)
	no_variants = FALSE
	apply_sounds = list('sound/effects/ointment.ogg')
	drop_sound = 'sound/items/drop/herb.ogg'
	pickup_sound = 'sound/items/pickup/herb.ogg'

/obj/item/stack/medical/ointment/checked_application(mob/M, mob/user)
	if(!(. = ..()))
		return

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open)
			to_chat(user, "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>")
			return

		if(affecting.is_salved())
			to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been salved.</span>")
			return
		else
			user.visible_message("<span class='notice'>\The [user] starts salving wounds on [M]'s [affecting.name].</span>", \
					             "<span class='notice'>You start salving the wounds on [M]'s [affecting.name].</span>" )
			if(!do_mob(user, M, 10))
				to_chat(user, "<span class='notice'>You must stand still to salve wounds.</span>")
				return
			if(affecting.is_salved()) // We do a second check after the delay, in case it was bandaged after the first check.
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been salved.</span>")
				return
			user.visible_message("<span class='notice'>[user] salved wounds on [M]'s [affecting.name].</span>", \
			                         "<span class='notice'>You salved wounds on [M]'s [affecting.name].</span>" )
			use(1)
			affecting.salve()
			playsound(src, pick(apply_sounds), 25)

/obj/item/stack/medical/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "brute_adv"
	icon_state_count = 6
	base_icon_state = "brute_adv"
	heal_brute = 7
	origin_tech = list(TECH_BIO = 1)
	apply_sounds = list('sound/effects/rip1.ogg','sound/effects/rip2.ogg','sound/effects/tape.ogg')

/obj/item/stack/medical/advanced/bruise_pack/checked_application(mob/M, mob/user)
	if(!(. = ..()))
		return

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open)
			to_chat(user, "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>")
			return

		if(affecting.is_bandaged() && affecting.is_disinfected())
			to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been treated.</span>")
			return
		else
			user.visible_message("<span class='notice'>\The [user] starts treating [M]'s [affecting.name].</span>", \
					             "<span class='notice'>You start treating [M]'s [affecting.name].</span>" )
			var/used = 0
			for (var/datum/wound/W as anything in affecting.wounds)
				if (W.internal)
					continue
				if (W.bandaged && W.disinfected)
					continue
				if(!do_mob(user, M, W.damage/5))
					to_chat(user, "<span class='notice'>You must stand still to bandage wounds.</span>")
					break
				if(affecting.is_bandaged() && affecting.is_disinfected()) // We do a second check after the delay, in case it was bandaged after the first check.
					to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been bandaged.</span>")
					return
				if (W.current_stage <= W.max_bleeding_stage)
					user.visible_message("<span class='notice'>\The [user] cleans \a [W.desc] on [M]'s [affecting.name] and seals the edges with bioglue.</span>", \
					                     "<span class='notice'>You clean and seal \a [W.desc] on [M]'s [affecting.name].</span>" )
				else if (W.wound_type == WOUND_TYPE_BRUISE)
					user.visible_message("<span class='notice'>\The [user] places a medical patch over \a [W.desc] on [M]'s [affecting.name].</span>", \
					                              "<span class='notice'>You place a medical patch over \a [W.desc] on [M]'s [affecting.name].</span>" )
				else
					user.visible_message("<span class='notice'>\The [user] smears some bioglue over \a [W.desc] on [M]'s [affecting.name].</span>", \
					                              "<span class='notice'>You smear some bioglue over \a [W.desc] on [M]'s [affecting.name].</span>" )
				W.bandage()
				W.disinfect()
				W.heal_damage(heal_brute)
				playsound(src, pick(apply_sounds), 25)
				used = 1
				update_icon() //  Support for stack icons
			affecting.update_damages()
			if(used == amount)
				if(affecting.is_bandaged())
					to_chat(user, "<span class='warning'>\The [src] is used up.</span>")
				else
					to_chat(user, "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [affecting.name].</span>")
			use(used)

/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burn_adv"
	icon_state_count = 6
	base_icon_state = "burn_adv"
	heal_burn = 7
	origin_tech = list(TECH_BIO = 1)
	apply_sounds = list('sound/effects/ointment.ogg')

/obj/item/stack/medical/advanced/ointment/checked_application(mob/M, mob/user)
	if(!(. = ..()))
		return

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open)
			to_chat(user, "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>")

		if(affecting.is_salved())
			to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been salved.</span>")
			return
		else
			user.visible_message("<span class='notice'>\The [user] starts salving wounds on [M]'s [affecting.name].</span>", \
					             "<span class='notice'>You start salving the wounds on [M]'s [affecting.name].</span>" )
			if(!do_mob(user, M, 10))
				to_chat(user, "<span class='notice'>You must stand still to salve wounds.</span>")
				return
			if(affecting.is_salved()) // We do a second check after the delay, in case it was bandaged after the first check.
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been salved.</span>")
				return
			user.visible_message( 	"<span class='notice'>[user] covers wounds on [M]'s [affecting.name] with regenerative membrane.</span>", \
									"<span class='notice'>You cover wounds on [M]'s [affecting.name] with regenerative membrane.</span>" )
			affecting.heal_damage(0,heal_burn)
			use(1)
			affecting.salve()
			playsound(src, pick(apply_sounds), 25)
			update_icon() // Support for stack icons

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	desc = "Modular splints capable of supporting and immobilizing bones in all areas of the body."
	icon_state = "splint"
	base_icon_state = "splint"
	amount = 5
	max_amount = 5
	drop_sound = 'sound/items/drop/hat.ogg'
	pickup_sound = 'sound/items/pickup/hat.ogg'

	var/list/splintable_organs = list(BP_HEAD, BP_L_HAND, BP_R_HAND, BP_L_ARM, BP_R_ARM, BP_L_FOOT, BP_R_FOOT, BP_L_LEG, BP_R_LEG, BP_GROIN, BP_TORSO)	//List of organs you can splint, natch.

/obj/item/stack/medical/splint/checked_application(mob/M, mob/user)
	if(!(. = ..()))
		return

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)
		var/limb = affecting.name
		if(!(affecting.organ_tag in splintable_organs))
			to_chat(user, "<span class='danger'>You can't use \the [src] to apply a splint there!</span>")
			return
		if(affecting.splinted)
			to_chat(user, "<span class='danger'>[M]'s [limb] is already splinted!</span>")
			return
		if (M != user)
			user.visible_message("<span class='danger'>[user] starts to apply \the [src] to [M]'s [limb].</span>", "<span class='danger'>You start to apply \the [src] to [M]'s [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
		else
			if(( !(H.active_hand % 2) && (affecting.organ_tag in list(BP_R_ARM, BP_R_HAND)) || \
				(H.active_hand % 2) && (affecting.organ_tag in list(BP_L_ARM, BP_L_HAND)) ))
				to_chat(user, "<span class='danger'>You can't apply a splint to the arm you're using!</span>")
				return
			user.visible_message("<span class='danger'>[user] starts to apply \the [src] to their [limb].</span>", "<span class='danger'>You start to apply \the [src] to your [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
		if(do_after(user, 50, M))
			if(affecting.splinted)
				to_chat(user, "<span class='danger'>[M]'s [limb] is already splinted!</span>")
				return
			if(M == user && prob(75))
				user.visible_message("<span class='danger'>\The [user] fumbles [src].</span>", "<span class='danger'>You fumble [src].</span>", "<span class='danger'>You hear something being wrapped.</span>")
				return
			if(ishuman(user))
				var/obj/item/stack/medical/splint/S = split(1, user)
				if(S)
					if(affecting.apply_splint(S))
						S.forceMove(affecting)
						if (M != user)
							user.visible_message("<span class='danger'>\The [user] finishes applying [src] to [M]'s [limb].</span>", "<span class='danger'>You finish applying \the [src] to [M]'s [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
						else
							user.visible_message("<span class='danger'>\The [user] successfully applies [src] to their [limb].</span>", "<span class='danger'>You successfully apply \the [src] to your [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
						return
					S.dropInto(src.loc) //didn't get applied, so just drop it
			if(isrobot(user))
				var/obj/item/stack/medical/splint/B = src
				if(B)
					if(affecting.apply_splint(B))
						B.forceMove(affecting)
						user.visible_message("<span class='danger'>\The [user] finishes applying [src] to [M]'s [limb].</span>", "<span class='danger'>You finish applying \the [src] to [M]'s [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
						B.use(1)
						return
			user.visible_message("<span class='danger'>\The [user] fails to apply [src].</span>", "<span class='danger'>You fail to apply [src].</span>", "<span class='danger'>You hear something being wrapped.</span>")

/obj/item/stack/medical/splint/ghetto
	name = "makeshift splints"
	singular_name = "makeshift splint"
	desc = "For holding your limbs in place with duct tape and scrap metal."
	icon_state = "splint_tape"
	base_icon_state = "splint_tape"
	amount = 1
	splintable_organs = list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/obj/item/stack/medical/splint/primitive
	name = "primitive splints"
	singular_name = "makeshift splint"
	desc = "For holding your limbs in place with hide and sinew."
	icon_state = "splint_primitive"
	base_icon_state = "splint_primitive"
	amount = 5

// todo: kick ashlander crap to ashlander faction or something, why is this here?

//Ashlander Poultices - They basically use the same stack system as ointment and bruise packs. Gotta dupe some of the code since bruise pack/ointment chat messages are too specific.
/obj/item/stack/medical/poultice_brute
	name = "poultice (juhtak)"
	singular_name = "poultice (juhtak)"
	desc = "A damp mush made from the pulp of a juhtak. It is used to treat flesh injuries."
	icon_state = "brute_poultice"
	apply_sounds = list('sound/effects/ointment.ogg')
	drop_sound = 'sound/items/drop/herb.ogg'
	pickup_sound = 'sound/items/pickup/herb.ogg'

/obj/item/stack/medical/poultice_brute/checked_application(mob/M, mob/user)
	if(!(. = ..()))
		return

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open)
			to_chat(user, "<span class='notice'>The [affecting.name] is cut open, you'll need more than a salve!</span>")
			return

		if(affecting.is_bandaged())
			to_chat(user, "<span class='warning'>The wounds on [H]'s [affecting.name] have already been covered.</span>")
			return
		else
			user.visible_message("<span class='notice'>\The [user] starts treating [H]'s [affecting.name].</span>", \
					             "<span class='notice'>You start treating [H]'s [affecting.name].</span>" )
			var/used = 0
			for (var/datum/wound/W as anything in affecting.wounds)
				if (W.internal)
					continue
				if(W.bandaged)
					continue
				if(used == amount)
					break
				if(!do_mob(user, H, W.damage/5))
					to_chat(user, "<span class='notice'>You must stand still to cover wounds.</span>")
					break

				if(affecting.is_bandaged())
					to_chat(user, "<span class='warning'>The wounds on [H]'s [affecting.name] have already been covered.</span>")
					return

				if (W.current_stage <= W.max_bleeding_stage)
					user.visible_message("<span class='notice'>\The [user] covers \a [W.desc] on [H]'s [affecting.name].</span>", \
					                              "<span class='notice'>You cover \a [W.desc] on [H]'s [affecting.name].</span>" )
					//H.add_side_effect("Itch")
				else if (W.wound_type == WOUND_TYPE_BRUISE)
					user.visible_message("<span class='notice'>\The [user] spreads the poultice over \a [W.desc] on [H]'s [affecting.name].</span>", \
					                              "<span class='notice'>You spread the poultice over \a [W.desc] on [H]'s [affecting.name].</span>" )
				else
					user.visible_message("<span class='notice'>\The [user] spreads the poultice over \a [W.desc] on [H]'s [affecting.name].</span>", \
					                              "<span class='notice'>You spread the poultice over \a [W.desc] on [H]'s [affecting.name].</span>" )
				W.bandage()
				playsound(src, pick(apply_sounds), 25)
				used++
				H.bitten = 0
			affecting.update_damages()
			if(used == amount)
				if(affecting.is_bandaged())
					to_chat(user, "<span class='warning'>\The [src] is used up.</span>")
				else
					to_chat(user, "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [affecting.name].</span>")
			use(used)

/obj/item/stack/medical/poultice_burn
	name = "poultice (pyrrhlea)"
	desc = "A damp mush infused with pyrrhlea petals. It is used to treat burns."
	gender = PLURAL
	singular_name = "poultice (pyrrhlea)"
	icon_state = "burn_poultice"
	heal_burn = 1
	no_variants = TRUE
	apply_sounds = list('sound/effects/ointment.ogg')
	drop_sound = 'sound/items/drop/herb.ogg'
	pickup_sound = 'sound/items/pickup/herb.ogg'

/obj/item/stack/medical/poultice_burn/checked_application(mob/M, mob/user)
	if(!(. = ..()))
		return

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open)
			to_chat(user, "<span class='notice'>The [affecting.name] is cut open, you'll need more than a salve!</span>")
			return

		if(affecting.is_salved())
			to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been covered.</span>")
			return
		else
			user.visible_message("<span class='notice'>\The [user] starts covering wounds on [M]'s [affecting.name].</span>", \
					             "<span class='notice'>You start covering the wounds on [M]'s [affecting.name].</span>" )
			if(!do_mob(user, M, 10))
				to_chat(user, "<span class='notice'>You must stand still to cover wounds.</span>")
				return
			if(affecting.is_salved()) // We do a second check after the delay, in case it was bandaged after the first check.
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been covered.</span>")
				return
			user.visible_message("<span class='notice'>[user] covered wounds on [M]'s [affecting.name].</span>", \
			                         "<span class='notice'>You covered wounds on [M]'s [affecting.name].</span>" )
			use(1)
			affecting.salve()
			playsound(src, pick(apply_sounds), 25)
