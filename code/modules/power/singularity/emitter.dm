///used to transfer power to containment field generators
#define EMITTER_DAMAGE_POWER_TRANSFER 500
// todo: emitters shouldn't be part of the singularity / power module
/obj/machinery/power/emitter
	name = "emitter"
	desc = "It is a heavy duty industrial laser."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = 0
	density = 1
	req_access = list(ACCESS_ENGINEERING_ENGINE)
	armor_type = /datum/armor/object/medium

	worth_intrinsic = 350
	var/id = null

	use_power = USE_POWER_OFF	//uses powernet power, not APC power
	active_power_usage = 30000	//30 kW laser. I guess that means 30 kJ per shot.

	var/active = 0
	var/powered = 0
	var/fire_delay = 100
	var/max_burst_delay = 100
	var/min_burst_delay = 20
	var/burst_shots = 3
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = 0

	var/burst_delay = 2
	var/initial_fire_delay = 100

/obj/machinery/power/emitter/verb/rotate_clockwise()
	set name = "Rotate Emitter Clockwise"
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)

	if (src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.setDir(turn(src.dir, 270))
	return 1

/obj/machinery/power/emitter/Initialize(mapload)
	. = ..()
	if(state == 2 && anchored)
		connect_to_network()

/obj/machinery/power/emitter/Destroy()
	message_admins("Emitter deleted at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	log_game("EMITTER([x],[y],[z]) Destroyed/deleted.")
	investigate_log("<font color='red'>deleted</font> at ([x],[y],[z])","singulo")
	..()

/obj/machinery/power/emitter/update_icon()
	if (active && powernet && avail(active_power_usage * 0.001))
		icon_state = "emitter_+a"
	else
		icon_state = "emitter"

/obj/machinery/power/emitter/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	src.add_fingerprint(user)
	activate(user)

/obj/machinery/power/emitter/proc/activate(mob/user as mob)
	if(state == 2)
		if(!powernet)
			to_chat(user, "\The [src] isn't connected to a wire.")
			return 1
		if(!src.locked)
			if(src.active==1)
				src.active = 0
				to_chat(user, "You turn off [src].")
				message_admins("Emitter turned off by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("EMITTER([x],[y],[z]) OFF by [key_name(user)]")
				investigate_log("turned <font color='red'>off</font> by [user.key]","singulo")
			else
				src.active = 1
				to_chat(user, "You turn on [src].")
				src.shot_number = 0
				src.fire_delay = get_initial_fire_delay()
				message_admins("Emitter turned on by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("EMITTER([x],[y],[z]) ON by [key_name(user)]")
				investigate_log("turned <font color='green'>on</font> by [user.key]","singulo")
			update_icon()
		else
			to_chat(user, "<span class='warning'>The controls are locked!</span>")
	else
		to_chat(user, "<span class='warning'>\The [src] needs to be firmly secured to the floor first.</span>")
		return 1


/obj/machinery/power/emitter/emp_act(var/severity)//Emitters are hardened but still might have issues
//	add_load(1000)
/*	if((severity == 1)&&prob(1)&&prob(1))
		if(src.active)
			src.active = 0
			src.use_power = 1	*/
	return 1

/obj/machinery/power/emitter/process(delta_time)
	if(machine_stat & (BROKEN))
		return
	if(src.state != 2 || (!powernet && active_power_usage))
		src.active = 0
		update_icon()
		return
	if(((src.last_shot + src.fire_delay) <= world.time) && (src.active == 1))

		var/actual_load = draw_power(active_power_usage * 0.001) * 1000
		if(actual_load >= active_power_usage) //does the laser have enough power to shoot?
			if(!powered)
				powered = 1
				update_icon()
				log_game("EMITTER([x],[y],[z]) Regained power and is ON.")
				investigate_log("regained power and turned <font color='green'>on</font>","singulo")
		else
			if(powered)
				powered = 0
				update_icon()
				log_game("EMITTER([x],[y],[z]) Lost power and was ON.")
				investigate_log("lost power and turned <font color='red'>off</font>","singulo")
			return

		src.last_shot = world.time
		if(src.shot_number < burst_shots)
			src.fire_delay = get_burst_delay() //R-UST port
			src.shot_number ++
		else
			src.fire_delay = get_rand_burst_delay() //R-UST port
			src.shot_number = 0

		//need to calculate the power per shot as the emitter doesn't fire continuously.
		var/burst_time = (min_burst_delay + max_burst_delay)/2 + 2*(burst_shots-1)
		var/power_per_shot = active_power_usage * (burst_time/10) / burst_shots

		playsound(src.loc, 'sound/weapons/emitter.ogg', 25, 1)
		if(prob(35))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(5, 1, src)
			s.start()

		var/obj/projectile/beam/emitter/A = get_emitter_beam()
		A.damage_force = round(power_per_shot/EMITTER_DAMAGE_POWER_TRANSFER)
		A.firer = src
		A.fire(dir2angle(dir))

/obj/machinery/power/emitter/attackby(obj/item/W, mob/user)

	if(W.is_wrench())
		if(active)
			to_chat(user, "Turn off [src] first.")
			return
		switch(state)
			if(0)
				state = 1
				playsound(src, W.tool_sound, 75, 1)
				user.visible_message("[user.name] secures [src] to the floor.", \
					"You secure the external reinforcing bolts to the floor.", \
					"You hear a ratchet.")
				src.anchored = 1
			if(1)
				state = 0
				playsound(src, W.tool_sound, 75, 1)
				user.visible_message("[user.name] unsecures [src] reinforcing bolts from the floor.", \
					"You undo the external reinforcing bolts.", \
					"You hear a ratchet.")
				src.anchored = 0
				disconnect_from_network()
			if(2)
				to_chat(user, "<span class='warning'>\The [src] needs to be unwelded from the floor.</span>")
		return

	if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W
		if(active)
			to_chat(user, "Turn off [src] first.")
			return
		switch(state)
			if(0)
				to_chat(user, "<span class='warning'>\The [src] needs to be wrenched to the floor.</span>")
			if(1)
				if (WT.remove_fuel(0,user))
					playsound(loc, WT.tool_sound, 50, 1)
					user.visible_message("[user.name] starts to weld [src] to the floor.", \
						"You start to weld [src] to the floor.", \
						"You hear welding")
					if (do_after(user,20 * WT.tool_speed))
						if(!src || !WT.isOn()) return
						state = 2
						to_chat(user, "You weld [src] to the floor.")
						connect_to_network()
				else
					to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			if(2)
				if (WT.remove_fuel(0,user))
					playsound(loc, WT.tool_sound, 50, 1)
					user.visible_message("[user.name] starts to cut [src] free from the floor.", \
						"You start to cut [src] free from the floor.", \
						"You hear welding")
					if (do_after(user,20 * WT.tool_speed))
						if(!src || !WT.isOn()) return
						state = 1
						to_chat(user, "You cut [src] free from the floor.")
						disconnect_from_network()
				else
					to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
		return

	if(W.is_material_stack_of(/datum/prototype/material/steel))
		var/amt = CEILING(( initial(integrity) - integrity)/10, 1)
		if(!amt)
			to_chat(user, "<span class='notice'>\The [src] is already fully repaired.</span>")
			return
		var/obj/item/stack/P = W
		if(P.amount < amt)
			to_chat(user, "<span class='warning'>You don't have enough sheets to repair this! You need at least [amt] sheets.</span>")
			return
		to_chat(user, "<span class='notice'>You begin repairing \the [src]...</span>")
		if(do_after(user, 30))
			if(P.use(amt))
				to_chat(user, "<span class='notice'>You have repaired \the [src].</span>")
				set_integrity(integrity_max)
				return
			else
				to_chat(user, "<span class='warning'>You don't have enough sheets to repair this! You need at least [amt] sheets.</span>")
				return

	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/pda))
		if(emagged)
			to_chat(user, "<span class='warning'>The lock seems to be broken.</span>")
			return
		if(src.allowed(user))
			src.locked = !src.locked
			to_chat(user, "The controls are now [src.locked ? "locked." : "unlocked."]")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	..()
	return

/obj/machinery/power/emitter/emag_act(var/remaining_charges, var/mob/user)
	if(!emagged)
		locked = 0
		emagged = 1
		user.visible_message("[user.name] emags [src].","<span class='warning'>You short out the lock.</span>")
		return 1

//R-UST port
/obj/machinery/power/emitter/proc/get_initial_fire_delay()
	return initial_fire_delay

/obj/machinery/power/emitter/proc/get_rand_burst_delay()
	return rand(min_burst_delay, max_burst_delay)

/obj/machinery/power/emitter/proc/get_burst_delay()
	return burst_delay

/obj/machinery/power/emitter/proc/get_emitter_beam()
	return new /obj/projectile/beam/emitter(get_turf(src))
