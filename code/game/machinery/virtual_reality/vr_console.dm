/obj/machinery/vr_sleeper
	name = "virtual reality sleeper"
	desc = "A fancy bed with built-in sensory I/O ports and connectors to interface users' minds with their bodies in virtual reality."
	icon = 'icons/obj/medical/cryogenic2.dmi'
	icon_state = "syndipod_0"

	var/base_state = "syndipod_"

	density = 1
	anchored = 1
	circuit = /obj/item/circuitboard/vr_sleeper
	var/mob/living/carbon/human/occupant = null
	var/mob/living/carbon/human/avatar = null
	var/datum/mind/vr_mind = null
	var/datum/effect_system/smoke_spread/bad/smoke

	var/eject_dead = TRUE

	var/mirror_first_occupant = TRUE	// Do we force the newly produced body to look like the occupant?

	use_power = USE_POWER_IDLE
	idle_power_usage = 15
	active_power_usage = 200
	light_color = "#FF0000"

/obj/machinery/vr_sleeper/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/scanning_module(src)
	component_parts += new /obj/item/stack/material/glass/reinforced(src, 2)

	RefreshParts()

/obj/machinery/vr_sleeper/Initialize(mapload)
	. = ..()
	smoke = new
	update_icon()

/obj/machinery/vr_sleeper/Destroy()
	. = ..()
	go_out()

/obj/machinery/vr_sleeper/process(delta_time)
	if(machine_stat & (NOPOWER|BROKEN))
		if(occupant)
			go_out()
			visible_message("<span class='notice'>\The [src] emits a low droning sound, before the pod door clicks open.</span>")
		return
	else if(eject_dead && occupant && occupant.stat == DEAD) // If someone dies somehow while inside, spit them out.
		visible_message("<span class='warning'>\The [src] sounds an alarm, swinging its hatch open.</span>")
		go_out()

/obj/machinery/vr_sleeper/update_icon_state()
	icon_state = "[base_state][occupant ? "1" : "0"]"
	return ..()

/obj/machinery/vr_sleeper/Topic(href, href_list)
	if(..())
		return 1

	if(usr == occupant)
		to_chat(usr, "<span class='warning'>You can't reach the controls from the inside.</span>")
		return

	add_fingerprint(usr)

	if(href_list["eject"])
		go_out()

	return 1

/obj/machinery/vr_sleeper/attackby(var/obj/item/I, var/mob/user)
	add_fingerprint(user)

	if(occupant && (istype(I, /obj/item/healthanalyzer) || istype(I, /obj/item/robotanalyzer)))
		I.melee_interaction_chain(occupant, user)
		return

	if(default_deconstruction_screwdriver(user, I))
		return
	else if(default_deconstruction_crowbar(user, I))
		if(occupant && avatar)
			avatar.exit_vr()
			avatar = null
			go_out()
		return


/obj/machinery/vr_sleeper/MouseDroppedOnLegacy(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user)|| !isliving(target))
		return
	go_in(target, user)



/obj/machinery/sleeper/relaymove(var/mob/user)
	..()
	if(usr.incapacitated())
		return
	go_out()



/obj/machinery/vr_sleeper/emp_act(var/severity)
	if(machine_stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(occupant)
		// This will eject the user from VR
		// ### Fry the brain? Yes. Maybe.
		if(prob(15 / ( severity / 4 )) && occupant.species.has_organ[O_BRAIN] && occupant.internal_organs_by_name[O_BRAIN])
			var/obj/item/organ/O = occupant.internal_organs_by_name[O_BRAIN]
			O.take_damage(severity * 2)
			visible_message("<span class='danger'>\The [src]'s internal lighting flashes rapidly, before the hatch swings open with a cloud of smoke.</span>")
			smoke.set_up(severity, 0, src)
			smoke.start("#202020")
		INVOKE_ASYNC(src, PROC_REF(go_out))

	..(severity)

/obj/machinery/vr_sleeper/verb/eject()
	set src in view(1)
	set category = VERB_CATEGORY_OBJECT
	set name = "Eject VR Capsule"

	if(usr.incapacitated())
		return

	var/forced = FALSE

	if(machine_stat & (BROKEN|NOPOWER) || occupant && occupant.stat == DEAD)
		forced = TRUE

	go_out(forced)
	add_fingerprint(usr)

/obj/machinery/vr_sleeper/verb/climb_in()
	set src in oview(1)
	set category = VERB_CATEGORY_OBJECT
	set name = "Enter VR Capsule"

	if(usr.incapacitated())
		return
	go_in(usr, usr)
	add_fingerprint(usr)

/obj/machinery/vr_sleeper/relaymove(mob/user as mob)
	if(user.incapacitated())
		return 0 //maybe they should be able to get out with cuffs, but whatever
	go_out()

/obj/machinery/vr_sleeper/proc/go_in(mob/M, mob/user)
	if(!M)
		return
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(!ishuman(M))
		to_chat(user, "<span class='warning'>\The [src] rejects [M] with a sharp beep.</span>")
	if(occupant)
		to_chat(user, "<span class='warning'>\The [src] is already occupied.</span>")
		return

	if(M == user)
		visible_message("\The [user] starts climbing into \the [src].")
	else
		visible_message("\The [user] starts putting [M] into \the [src].")

	if(do_after(user, 20))
		if(occupant)
			to_chat(user, "<span class='warning'>\The [src] is already occupied.</span>")
			return
		M.stop_pulling()
		M.forceMove(src)
		M.update_perspective()
		update_use_power(USE_POWER_ACTIVE)
		occupant = M

		update_icon()

		enter_vr()
	return

/obj/machinery/vr_sleeper/proc/go_out(var/forced = TRUE)
	if(!occupant)
		return

	if(!forced && avatar && alert(avatar, "Someone wants to remove you from virtual reality. Do you want to leave?", "Leave VR?", "Yes", "No") == "No")
		return

	avatar.exit_vr()
	avatar = null

	occupant.forceMove(loc)
	occupant.reset_perspective()
	occupant = null
	for(var/atom/movable/A in src) // In case an object was dropped inside or something
		if(A == circuit)
			continue
		if(A in component_parts)
			continue
		A.loc = src.loc
	update_use_power(USE_POWER_IDLE)
	update_icon()

/obj/machinery/vr_sleeper/proc/enter_vr()

	// No mob to transfer a mind from
	if(!occupant)
		return

	// No mind to transfer
	if(!occupant.mind)
		return

	// Mob doesn't have an active consciousness to send/receive from
	if(occupant.stat == DEAD)
		return

	avatar = occupant.vr_link
	// If they've already enterred VR, and are reconnecting, prompt if they want a new body
	if(avatar && alert(occupant, "You already have a [avatar.stat == DEAD ? "" : "deceased "]Virtual Reality avatar. Would you like to use it?", "New avatar", "Yes", "No") == "No")
		// Delink the mob
		occupant.vr_link = null
		avatar = null

	if(!avatar)
		// Get the desired spawn location to put the body
		var/S = null
		var/list/vr_landmarks = list()
		for(var/obj/landmark/virtual_reality/sloc in GLOB.landmarks_list)
			vr_landmarks += sloc.name

		S = input(occupant, "Please select a location to spawn your avatar at:", "Spawn location") as null|anything in vr_landmarks
		if(!S)
			return 0

		for(var/obj/landmark/virtual_reality/i in GLOB.landmarks_list)
			if(i.name == S)
				S = i
				break

		avatar = new(S, SPECIES_VR)
		// If the user has a non-default (Human) bodyshape, make it match theirs.
		if(occupant.species.get_species_id() != SPECIES_ID_PROMETHEAN && occupant.species.get_species_id() != SPECIES_ID_HUMAN && mirror_first_occupant)
			avatar.shapeshifter_change_shape(occupant.species.name)
		avatar.forceMove(get_turf(S))			// Put the mob on the landmark, instead of inside it
		avatar.afflict_sleeping(20 * 1)

		occupant.enter_vr(avatar)

		// Prompt for username after they've enterred the body.
		var/newname = sanitize(input(avatar, "You are entering virtual reality. Your username is currently [src.name]. Would you like to change it to something else?", "Name change") as null|text, MAX_NAME_LEN)
		if (newname)
			avatar.real_name = newname

	else
		occupant.enter_vr(avatar)
