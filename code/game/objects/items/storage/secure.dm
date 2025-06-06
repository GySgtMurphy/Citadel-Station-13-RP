/*
 *	Absorbs /obj/item/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/storage/secure
	name = "secstorage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/locked = 1
	var/code = ""
	var/l_code = null
	var/l_set = 0
	var/l_setshort = 0
	var/l_hacking = 0
	var/emagged = 0
	var/open = 0
	w_class = WEIGHT_CLASS_NORMAL
	max_single_weight_class = WEIGHT_CLASS_SMALL
	max_combined_volume = WEIGHT_CLASS_SMALL * 7

/obj/item/storage/secure/examine(mob/user, dist)
	. = ..()
	. += "The service panel is [src.open ? "open" : "closed"]."

/obj/item/storage/secure/attackby(obj/item/W as obj, mob/user as mob)
	if(locked)
		if (istype(W, /obj/item/melee/ninja_energy_blade) && emag_act(INFINITY, user, "You slice through the lock of \the [src]"))
			var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(src.loc, /datum/soundbyte/sparks, 50, 1)
			return
		if (W.is_screwdriver())
			if (do_after(user, 20 * W.tool_speed))
				src.open =! src.open
				playsound(src, W.tool_sound, 50, 1)
				user.show_message(SPAN_NOTICE("You [(open ? "open" : "close")] the service panel."))
			return
		if (istype(W, /obj/item/multitool) && (src.open == 1)&& (!src.l_hacking))
			user.show_message("<span class='notice'>Now attempting to reset internal memory, please hold.</span>", 1)
			src.l_hacking = 1
			if (do_after(usr, 100))
				if (prob(40))
					src.l_setshort = 1
					src.l_set = 0
					user.show_message("<span class='notice'>Internal memory reset. Please give it a few seconds to reinitialize.</span>", 1)
					sleep(80)
					src.l_setshort = 0
					src.l_hacking = 0
				else
					user.show_message("<span class='warning'>Unable to reset internal memory.</span>", 1)
					src.l_hacking = 0
			else	src.l_hacking = 0
			return
		//At this point you have exhausted all the special things to do when locked
		// ... but it's still locked.
		return

		// -> storage/attackby() what with handle insertion, etc
	..()


/obj/item/storage/secure/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	user.set_machine(src)
	var/dat = "<TT><B>[src]</B><BR>\n\nLock Status: [(locked ? "LOCKED" : "UNLOCKED")]"
	var/message = "Code"
	if ((src.l_set == 0) && (!src.emagged) && (!src.l_setshort))
		dat += "<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>"
	if (src.emagged)
		dat += "<p>\n<font color=red><b>LOCKING SYSTEM ERROR - 1701</b></font>"
	if (src.l_setshort)
		dat += "<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>"
	message = code
	if (!src.locked)
		message = "*****"
	dat += "<HR>\n>[message]<BR>\n<A href='?src=\ref[src];type=1'>1</A>-<A href='?src=\ref[src];type=2'>2</A>-<A href='?src=\ref[src];type=3'>3</A><BR>\n<A href='?src=\ref[src];type=4'>4</A>-<A href='?src=\ref[src];type=5'>5</A>-<A href='?src=\ref[src];type=6'>6</A><BR>\n<A href='?src=\ref[src];type=7'>7</A>-<A href='?src=\ref[src];type=8'>8</A>-<A href='?src=\ref[src];type=9'>9</A><BR>\n<A href='?src=\ref[src];type=R'>R</A>-<A href='?src=\ref[src];type=0'>0</A>-<A href='?src=\ref[src];type=E'>E</A><BR>\n</TT>"
	user << browse(HTML_SKELETON(dat), "window=caselock;size=300x280")

/obj/item/storage/secure/Topic(href, href_list)
	if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return ..()

	if (href_list["type"])
		if (href_list["type"] == "E")
			if ((l_set == 0) && (length(code) == 5) && (!l_setshort) && (code != "ERROR"))
				l_code = code
				l_set = 1
			else if ((code == l_code) && (emagged == 0) && (l_set == 1))
				locked = 0
				obj_storage.set_locked(FALSE)
				set_overlays(icon_opened)
				code = null
			else
				code = "ERROR"
		else
			if ((href_list["type"] == "R") && (emagged == 0) && (!l_setshort))
				locked = 1
				cut_overlays()
				obj_storage.set_locked(TRUE)
				code = null
			else
				code += href_list["type"]
				if (length(src.code) > 5)
					code = "ERROR"

		for(var/mob/M in viewers(1, loc))
			if ((M.client && M.machine == src))
				attack_self(M)
			return
	return

/obj/item/storage/secure/emag_act(remaining_charges, mob/user, feedback)
	if(!emagged)
		emagged = 1
		add_overlay(icon_sparking)
		compile_overlays()
		sleep(6)
		set_overlays(icon_locking)
		locked = 0
		obj_storage.set_locked(FALSE)
		to_chat(user, (feedback ? feedback : "You short out the lock of \the [src]."))
		return 1

// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "case", SLOT_ID_LEFT_HAND = "case")
	desc = "A large briefcase with a digital locking system."
	damage_force = 8.0
	throw_speed = 1
	throw_range = 4
	max_single_weight_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_BULKY
	max_combined_volume = WEIGHT_VOLUME_NORMAL * 4

//LOADOUT ITEM
/obj/item/storage/secure/briefcase/portable
	name = "Portable Secure Briefcase"
	desc = "A not-so large briefcase with a digital locking system. Holds less, but fits into more."
	w_class = WEIGHT_CLASS_NORMAL

	starts_with = list(
		/obj/item/paper,
		/obj/item/pen
	)
//DONATOR ITEM

/obj/item/storage/secure/briefcase/vicase
	name = "VI's Secure Briefpack"
	w_class = WEIGHT_CLASS_BULKY
	max_single_weight_class = WEIGHT_CLASS_BULKY
	max_combined_volume = STORAGE_VOLUME_BACKPACK
	slot_flags = SLOT_BACK
	icon = 'icons/obj/clothing/backpack.dmi'
	icon_state = "securev"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "securev", SLOT_ID_LEFT_HAND = "securev")
	desc = "A large briefcase with a digital locking system and a magnetic attachment system."
	damage_force = 0
	throw_speed = 1
	throw_range = 4

// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	damage_force = 8.0
	w_class = WEIGHT_CLASS_HUGE
	max_single_weight_class = WEIGHT_CLASS_BULKY // This was 8 previously...
	anchored = 1.0
	density = 0
	insertion_blacklist = list(/obj/item/storage/secure/briefcase)
	starts_with = list(
		/obj/item/paper,
		/obj/item/pen
	)

/obj/item/storage/secure/safe/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	return attack_self(user)
