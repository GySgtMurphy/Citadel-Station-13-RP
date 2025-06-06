/**
 * smes
 *
 * base type of power storage unit
 *
 * storage values are measured in **kilowatt minutes** due to float precision.
 * flow values are measured in kilowatts.
 *
 * TODO: generalize to /obj/machinery/power/storage, and split into storage/smes and storage/batteryrack, etc
 */

GLOBAL_LIST_EMPTY(smeses)

/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	icon = 'icons/obj/power_vr.dmi'
	density = 1
	anchored = 1
	use_power = USE_POWER_OFF
	circuit = /obj/item/circuitboard/smes

	/// maximum charge in kW-m
	var/capacity = 5000
	/// current charge in kW-m
	var/charge = 1000

	var/input_attempt = 0 			// 1 = attempting to charge, 0 = not attempting to charge
	var/inputting = 0 				// 1 = actually inputting, 0 = not inputting
	/// attempt to charge with this much kw
	var/input_level = 50
	/// max charge rate
	var/input_level_max = 200

	var/output_attempt = 1 			// 1 = attempting to output, 0 = not attempting to output
	var/outputting = 1 				// 1 = actually outputting, 0 = not outputting
	/// attempt to output this much in kw
	var/output_level = 50
	/// max output in kw
	var/output_level_max = 200
	var/output_used = 0				// amount of power actually outputted. may be less than output_level if the powernet returns excess power

	//Holders for powerout event.
	var/powerout_holders_used = FALSE
	var/last_output_attempt	= 0
	var/last_input_attempt	= 0
	var/last_charge			= 0

	var/input_cut = 0
	var/input_pulsed = 0
	var/output_cut = 0
	var/output_pulsed = 0

	var/open_hatch = 0
	var/name_tag = null
	var/building_terminal = 0 		//Suggestions about how to avoid clickspam building several terminals accepted!
	var/obj/machinery/power/terminal/terminal = null
	var/should_be_mapped = 0 		// If this is set to 0 it will send out warning on New()
	var/grid_check = FALSE 			// If true, suspends all I/O.

/obj/machinery/power/smes/drain_energy(datum/actor, amount, flags)
	var/wanted = min(charge, KJ_TO_KWM(amount))
	charge -= wanted
	return KWM_TO_KJ(wanted)

/obj/machinery/power/smes/can_drain_energy(datum/actor, amount)
	return TRUE

/obj/machinery/power/smes/Initialize(mapload, newdir)
	. = ..()
	GLOB.smeses += src
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/power/smes/LateInitialize()
	if(!powernet)
		connect_to_network()

	dir_loop:
		for(var/d in GLOB.cardinal)
			var/turf/T = get_step(src, d)
			for(var/obj/machinery/power/terminal/term in T)
				if(term && term.dir == turn(d, 180))
					terminal = term
					break dir_loop
	if(!terminal)
		machine_stat |= BROKEN
		return
	terminal.master = src
	if(!terminal.powernet)
		terminal.connect_to_network()
	update_icon()
	if(!should_be_mapped)
		CRASH("Non-buildable or Non-magical SMES at: [audit_loc()].")

/obj/machinery/power/smes/Destroy()
	GLOB.smeses -= src
	return ..()

/obj/machinery/power/smes/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null
		return 1
	return 0

/obj/machinery/power/smes/update_icon()
	cut_overlays()
	if(machine_stat & BROKEN)
		return

	var/list/overlays_to_add = list()

	overlays_to_add += image(icon, "smes-op[outputting]")

	if(inputting == 2)
		overlays_to_add += image(icon, "smes-oc2")
	else if (inputting == 1)
		overlays_to_add += image(icon, "smes-oc1")
	else
		if(input_attempt)
			overlays_to_add += image(icon, "smes-oc0")

	var/clevel = chargedisplay()
	if(clevel>0)
		overlays_to_add += image(icon, "smes-og[clevel]")

	add_overlay(overlays_to_add)

	return


/obj/machinery/power/smes/proc/chargedisplay()
	return round(5.5*charge/(capacity ? capacity : 5e6))

/obj/machinery/power/smes/process(delta_time)
	if(machine_stat & BROKEN)
		return

	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = inputting
	var/last_onln = outputting

	//inputting
	if(input_attempt && (!input_pulsed && !input_cut) && !grid_check)
		var/target_load = min(KWM_TO_KW(capacity - charge, 1), input_level)	// charge at set rate, limited to spare capacity
		var/actual_load = draw_power(target_load)						// add the load to the terminal side network
		charge += KW_TO_KWM(actual_load, 1)								// increase the charge

		if (actual_load >= target_load) // Did we charge at full rate?
			inputting = 2
		else if (actual_load) // If not, did we charge at least partially?
			inputting = 1
		else // Or not at all?
			inputting = 0

	//outputting
	if(outputting && (!output_pulsed && !output_cut) && !grid_check)
		output_used = min(KWM_TO_KW(charge, 1), output_level)		//limit output to that stored
		charge -= KW_TO_KWM(output_used, 1)	// reduce the storage (may be recovered in /restore() if excessive)

		add_avail(output_used)				// add output to powernet (smes side)

		if(output_used < 0.0001)			// either from no charge or set to 0
			outputting(0)
			investigate_log("lost power and turned <font color='red'>off</font>","singulo")
			log_game("SMES([x],[y],[z]) Power depleted.")
	else if(output_attempt && output_level > 0)
		outputting = 1
	else
		output_used = 0

	// only update icon if state changed
	if(last_disp != chargedisplay() || last_chrg != inputting || last_onln != outputting)
		update_icon()

// called after all power processes are finished
// restores charge level to smes if there was excess this ptick
/obj/machinery/power/smes/proc/restore()
	if(machine_stat & BROKEN)
		return

	if(!outputting)
		output_used = 0
		return

	var/excess = powernet.netexcess		// this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(output_used, excess)				// clamp it to how much was actually output by this SMES last ptick
	excess = min(KWM_TO_KW(capacity - charge, 1), excess)	// for safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount
	var/clev = chargedisplay()

	charge += KW_TO_KWM(excess, 1)			// restore unused power
	powernet.netexcess -= excess		// remove the excess from the powernet, so later SMESes don't try to use it

	output_used -= excess

	if(clev != chargedisplay()) //if needed updates the icons overlay
		update_icon()

//Will return 1 on failure
/obj/machinery/power/smes/proc/make_terminal(const/mob/user)
	if (user.loc == loc)
		to_chat(user, "<span class='warning'>You must not be on the same tile as the [src].</span>")
		return 1

	//Direction the terminal will face to
	var/tempDir = get_dir(user, src)
	switch(tempDir)
		if (NORTHEAST, SOUTHEAST)
			tempDir = EAST
		if (NORTHWEST, SOUTHWEST)
			tempDir = WEST
	var/turf/tempLoc = get_step(src, global.reverse_dir[tempDir])
	if (istype(tempLoc, /turf/space))
		to_chat(user, "<span class='warning'>You can't build a terminal on space.</span>")
		return 1
	else if (istype(tempLoc))
		if(!tempLoc.is_plating())
			to_chat(user, "<span class='warning'>You must remove the floor plating first.</span>")
			return 1
	to_chat(user, "<span class='notice'>You start adding cable to the [src].</span>")
	if(do_after(user, 50))
		terminal = new /obj/machinery/power/terminal(tempLoc)
		terminal.setDir(tempDir)
		terminal.master = src
		terminal.connect_to_network()
		return 0
	return 1

/obj/machinery/power/smes/draw_power(var/amount)
	if(terminal && terminal.powernet)
		return terminal.powernet.draw_power(amount)
	return 0

/obj/machinery/power/smes/attack_ai(mob/user)
	add_hiddenprint(user)
	ui_interact(user)

/obj/machinery/power/smes/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/power/smes/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(W.is_screwdriver())
		if(!open_hatch)
			open_hatch = 1
			to_chat(user, "<span class='notice'>You open the maintenance hatch of [src].</span>")
			playsound(src, W.tool_sound, 50, 1)
			return 0
		else
			open_hatch = 0
			to_chat(user, "<span class='notice'>You close the maintenance hatch of [src].</span>")
			playsound(src, W.tool_sound, 50, 1)
			return 0

	if (!open_hatch)
		to_chat(user, "<span class='warning'>You need to open access hatch on [src] first!</span>")
		return 0

	if(istype(W, /obj/item/stack/cable_coil) && !terminal && !building_terminal)
		building_terminal = 1
		var/obj/item/stack/cable_coil/CC = W
		if (CC.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need more cables.</span>")
			building_terminal = 0
			return 0
		if (make_terminal(user))
			building_terminal = 0
			return 0
		building_terminal = 0
		CC.use(10)
		user.visible_message(\
				"<span class='notice'>[user.name] has added cables to the [src].</span>",\
				"<span class='notice'>You added cables to the [src].</span>")
		machine_stat = NONE
		return 0

	else if(W.is_wirecutter() && terminal && !building_terminal)
		building_terminal = 1
		var/turf/tempTDir = terminal.loc
		if (istype(tempTDir))
			if(!tempTDir.is_plating())
				to_chat(user, "<span class='warning'>You must remove the floor plating first.</span>")
			else
				to_chat(user, "<span class='notice'>You begin to cut the cables...</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, 50 * W.tool_speed))
					if (prob(50) && electrocute_mob(usr, terminal.powernet, terminal))
						var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
						s.set_up(5, 1, src)
						s.start()
						building_terminal = 0
						if(!CHECK_MOBILITY(usr, MOBILITY_CAN_USE))
							return 0
					new /obj/item/stack/cable_coil(loc,10)
					user.visible_message(\
						"<span class='notice'>[user.name] cut the cables and dismantled the power terminal.</span>",\
						"<span class='notice'>You cut the cables and dismantle the power terminal.</span>")
					qdel(terminal)
		building_terminal = 0
		return 0
	return 1

/obj/machinery/power/smes/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smes", name)
		ui.open()

/obj/machinery/power/smes/ui_data(mob/user, datum/tgui/ui)
	var/list/data = list(
		"capacity" = capacity,
		"capacityPercent" = round(100.0*charge/capacity, 0.1),
		"charge" = charge,
		"inputAttempt" = input_attempt,
		"inputting" = inputting,
		"inputLevel" = input_level,
		"inputLevelMax" = input_level_max,
		"inputAvailable" = getTerminalPower(),
		"outputAttempt" = output_attempt,
		"outputting" = outputting,
		"outputLevel" = round(output_level, 0.1),
		"outputLevelMax" = round(output_level_max),
		"outputUsed" = round(output_used, 0.1),
	)
	return data

/obj/machinery/power/smes/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return TRUE
	switch(action)
		if("tryinput")
			inputting(!input_attempt)
			update_icon()
			. = TRUE
		if("tryoutput")
			outputting(!output_attempt)
			update_icon()
			. = TRUE
		if("input")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = input_level_max
				. = TRUE
			else if(adjust)
				target = input_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				input_level = clamp(target, 0, input_level_max)
		if("output")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = output_level_max
				. = TRUE
			else if(adjust)
				target = output_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				output_level = clamp(target, 0, output_level_max)

/*
/obj/machinery/power/smes/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	if(machine_stat & BROKEN)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["nameTag"] = name_tag
	data["storedCapacity"] = round(100.0*charge/capacity, 0.1)
	data["storedCapacityAbs"] = round(charge/(1000*60), 0.1)
	data["storedCapacityMax"] = round(capacity/(1000*60))
	data["charging"] = inputting
	data["chargeMode"] = input_attempt
	data["chargeLevel"] = round(input_level/1000, 0.1)
	data["chargeMax"] = round(input_level_max/1000)
	if (terminal && terminal.powernet)
		data["chargeLoad"] = round(terminal.powernet.avail/1000, 0.1)
	else
		data["chargeLoad"] = 0
	data["outputOnline"] = output_attempt
	data["outputLevel"] = round(output_level/1000, 0.1)
	data["outputMax"] = round(output_level_max/1000)
	data["outputLoad"] = round(output_used/1000, 0.1)

	if(outputting)
		data["outputting"] = 2			// smes is outputting
	else if(!outputting && output_attempt)
		data["outputting"] = 1			// smes is online but not outputting because it's charge level is too low
	else
		data["outputting"] = 0			// smes is not outputting

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "smes.tmpl", "SMES Unit", 540, 380)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/smes/buildable/main/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	if (!ui)
		ui = new(user, src, ui_key, "smesmain.tmpl", "SMES Unit", 540, 405)
		ui.set_auto_update(1)
	..()
*/

/**
 * returns available terminal power in watts
 */
/obj/machinery/power/smes/proc/getTerminalPower()
	if (terminal && terminal.powernet)//checks if the SMES has a terminal, and if that terminal has a powernet.
		. = round(terminal.powernet.avail, 0.1)
	else
		. = 0
	return .

/obj/machinery/power/smes/proc/Percentage()
	return round(100.0*charge/capacity, 0.1)

/obj/machinery/power/smes/Topic(href, href_list)
	if(..())
		return 1

	if( href_list["cmode"] )
		inputting(!input_attempt)
		update_icon()

	else if( href_list["online"] )
		outputting(!output_attempt)
		update_icon()
	else if( href_list["input"] )
		switch( href_list["input"] )
			if("min")
				input_level = 0
			if("max")
				input_level = input_level_max
			if("set")
				input_level = (input(usr, "Enter new input level (0-[input_level_max/1000] kW)", "SMES Input Power Control", input_level/1000) as num) * 1000
		input_level = max(0, min(input_level_max, input_level))	// clamp to range

	else if( href_list["output"] )
		switch( href_list["output"] )
			if("min")
				output_level = 0
			if("max")
				output_level = output_level_max
			if("set")
				output_level = (input(usr, "Enter new output level (0-[output_level_max/1000] kW)", "SMES Output Power Control", output_level/1000) as num) * 1000
		output_level = max(0, min(output_level_max, output_level))	// clamp to range

	investigate_log("input/output; <font color='[input_level>output_level?"green":"red"][input_level]/[output_level]</font> | Output-mode: [output_attempt?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [input_attempt?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [usr.key]","singulo")
	log_game("SMES([x],[y],[z]) [key_name(usr)] changed settings: I:[input_level]([input_attempt]), O:[output_level]([output_attempt])")
	return 1


/obj/machinery/power/smes/proc/ion_act()
	if(src.z in (LEGACY_MAP_DATUM).station_levels)
		if(prob(1)) //explosion
			for(var/mob/M in viewers(src))
				M.show_message("<font color='red'>The [src.name] is making strange noises!</font>", 3, "<font color='red'>You hear sizzling electronics.</font>", 2)
			sleep(10*pick(4,5,6,7,10,14))
			var/datum/effect_system/smoke_spread/smoke = new /datum/effect_system/smoke_spread()
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()
			explosion(src.loc, -1, 0, 1, 3, 1, 0)
			qdel(src)
			return
		if(prob(15)) //Power drain
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			if(prob(25))
				emp_act(1)
			else if(prob(25))
				emp_act(2)
			else if(prob(25))
				emp_act(3)
			else
				emp_act(4)
		if(prob(5)) //smoke only
			var/datum/effect_system/smoke_spread/smoke = new /datum/effect_system/smoke_spread()
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()

/obj/machinery/power/smes/proc/inputting(var/do_input)
	input_attempt = do_input
	if(!input_attempt)
		inputting = 0

/obj/machinery/power/smes/proc/outputting(var/do_output)
	output_attempt = do_output
	if(!output_attempt)
		outputting = 0

/obj/machinery/power/smes/emp_act(severity)
	inputting(rand(0,1))
	outputting(rand(0,1))
	output_level = rand(0, output_level_max)
	input_level = rand(0, input_level_max)
	charge -= 1000/severity
	if (charge < 0)
		charge = 0
	update_icon()
	..()

/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."
	capacity = 5000
	output_level = 250
	should_be_mapped = 1

/obj/machinery/power/smes/magical/process(delta_time)
	charge = 5000
	..()

/obj/machinery/power/smes/buildable/main
	name = "main smes"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. This is the main one for facility power."
	charge = KWH_TO_KWM(SMES_COIL_STORAGE_BASIC * 4 * 0.8)
	input_level = 500
	output_level = 1000

/obj/machinery/power/smes/buildable/engine
	name = "engine smes"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. This is the one dedicated to the engine."
	charge = KWH_TO_KWM(SMES_COIL_STORAGE_BASIC * 1 * 0.8)
	input_level = 100
	output_level = 200

/obj/machinery/power/smes/buildable/tcomms
	name = "telecomms smes"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. This is the one dedicated to telecommunications."
	charge = KWH_TO_KWM(SMES_COIL_STORAGE_BASIC * 1 * 0.25)
	input_attempt = 1
	input_level = 100
	output_level = 200
	RCon_tag = "Telecomms"

#define SMES_UI_INPUT 1
#define SMES_UI_OUTPUT 2

/obj/machinery/power/smes/proc/ui_set_io(io, target, adjust)
	if(target == "min")
		target = 0
		. = TRUE
	else if(target == "max")
		target = output_level_max
		. = TRUE
	else if(adjust)
		target = output_level + adjust
		. = TRUE
	else if(text2num(target) != null)
		target = text2num(target)
		. = TRUE
	if(.)
		switch(io)
			if(SMES_UI_INPUT)
				set_input(target)
			if(SMES_UI_OUTPUT)
				set_output(target)
