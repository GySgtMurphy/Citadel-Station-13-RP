//I still dont think this should be a closet but whatever
/obj/structure/closet/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	var/obj/item/material/twohanded/fireaxe/fireaxe
	icon_state = "fireaxe1000"
	icon_closed = "fireaxe1000"
	icon_opened = "fireaxe1100"
	anchored = 1
	density = 0
	var/localopened = 0 //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = 1
	var/hitstaken = 0
	var/smashed = 0

/obj/structure/closet/fireaxecabinet/legacy_spawn_contents()
	. = ..()
	fireaxe = new /obj/item/material/twohanded/fireaxe(src)

/obj/structure/closet/fireaxecabinet/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	//..() //That's very useful, Erro

	// This could stand to be put further in, made better, etc. but fuck you. Fuck whoever
	// wrote this code. Fuck everything about this object. I hope you step on a Lego.
	user.setClickCooldownLegacy(10)
	// Seriously why the fuck is this even a closet aghasjdhasd I hate you

	var/hasaxe = 0       //gonna come in handy later~ // FUCK YOUR TILDES.
	if(fireaxe)
		hasaxe = 1

	if (isrobot(usr) || src.locked)
		if(istype(O, /obj/item/multitool))
			to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
			playsound(user, 'sound/machines/lockreset.ogg', 50, 1)
			if(do_after(user, 20 * O.tool_speed))
				src.locked = 0
				to_chat(user, SPAN_CAUTION("You disable the locking modules."))
				update_icon()
			return
		else if(istype(O, /obj/item))
			var/obj/item/W = O
			if(src.smashed || src.localopened)
				if(localopened)
					localopened = 0
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10)
						update_icon()
				return
			else
				playsound(user, 'sound/effects/Glasshit.ogg', 100, 1) //We don't want this playing every time
			if(W.damage_force < 15)
				to_chat(user, "<span class='notice'>The cabinet's protective glass glances off the hit.</span>")
			else
				src.hitstaken++
				if(src.hitstaken == 4)
					playsound(user, 'sound/effects/Glassbr3.ogg', 100, 1) //Break cabinet, receive goodies. Cabinet's fucked for life after that.
					src.smashed = 1
					src.locked = 0
					src.localopened = 1
			update_icon()
		return
	if (istype(O, /obj/item/material/twohanded/fireaxe) && src.localopened)
		if(!fireaxe)
			if(!user.attempt_insert_item_for_installation(O, src))
				return
			fireaxe = O
			to_chat(user, "<span class='notice'>You place the fire axe back in the [src.name].</span>")
			update_icon()
		else
			if(src.smashed)
				return
			else
				localopened = !localopened
				if(localopened)
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
					spawn(10) update_icon()
				else
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10) update_icon()
	else
		if(src.smashed)
			return
		if(istype(O, /obj/item/multitool))
			if(localopened)
				localopened = 0
				icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
				spawn(10) update_icon()
				return
			else
				to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
				playsound(user, 'sound/machines/lockenable.ogg', 50, 1)
				if(do_after(user,20 * O.tool_speed))
					src.locked = 1
					to_chat(user, SPAN_CAUTION("You re-enable the locking modules."))
				return
		else
			localopened = !localopened
			if(localopened)
				icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
				spawn(10)
					update_icon()
			else
				icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
				spawn(10)
					update_icon()


/obj/structure/closet/fireaxecabinet/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	var/hasaxe = 0
	if(fireaxe)
		hasaxe = 1

	if(src.locked)
		to_chat(user, "<span class='warning'>The cabinet won't budge!</span>")
		return

	if(localopened)
		if(fireaxe)
			user.put_in_hands(fireaxe)
			fireaxe = null
			to_chat (user, "<span class='notice'>You take the fire axe from the [name].</span>")
			src.add_fingerprint(user)
			update_icon()
		else
			if(src.smashed)
				return
			else
				localopened = !localopened
				if(localopened)
					src.icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
					spawn(10)
						update_icon()
				else
					src.icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10)
						update_icon()

	else
		localopened = !localopened //I'm pretty sure we don't need an if(src.smashed) in here. In case I'm wrong and it fucks up teh cabinet, **MARKER**. -Agouri
		if(localopened)
			src.icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
			spawn(10)
				update_icon()
		else
			src.icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
			spawn(10)
				update_icon()

/obj/structure/closet/fireaxecabinet/attack_tk(mob/user as mob)
	if(localopened && fireaxe)
		fireaxe.forceMove(loc)
		to_chat(user, "<span class='notice'>You telekinetically remove the fire axe.</span>")
		fireaxe = null
		update_icon()
		return
	attack_hand(user)

/obj/structure/closet/fireaxecabinet/verb/toggle_openness() //nice name, huh? HUH?! -Erro //YEAH -Agouri
	set name = "Open/Close"
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)

	if (isrobot(usr) || src.locked || src.smashed)
		if(src.locked)
			to_chat(usr, "<span class='warning'>The cabinet won't budge!</span>")
		else if(src.smashed)
			to_chat(usr, "<span class='notice'>The protective glass is broken!</span>")
		return

	localopened = !localopened
	update_icon()

/obj/structure/closet/fireaxecabinet/verb/remove_fire_axe()
	set name = "Remove Fire Axe"
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)

	if (isrobot(usr))
		return

	if (localopened)
		if(fireaxe)
			usr.put_in_hands(fireaxe)
			fireaxe = null
			to_chat(usr, "<span class='notice'>You take the Fire axe from the [name].</span>")
		else
			to_chat(usr, "<span class='notice'>The [src.name] is empty.</span>")
	else
		to_chat(usr, "<span class='notice'>The [src.name] is closed.</span>")
	update_icon()

/obj/structure/closet/fireaxecabinet/attack_ai(mob/user as mob)
	if(src.smashed)
		to_chat(user, "<span class='warning'>The security of the cabinet is compromised.</span>")
		return
	else
		locked = !locked
		if(locked)
			to_chat(user, "<span class='warning'>Cabinet locked.</span>")
		else
			to_chat(user, "<span class='notice'>Cabinet unlocked.</span>")
		return

/obj/structure/closet/fireaxecabinet/update_icon() //Template: fireaxe[has fireaxe][is opened][hits taken][is smashed]. If you want the opening or closing animations, add "opening" or "closing" right after the numbers
	var/hasaxe = 0
	if(fireaxe)
		hasaxe = 1
	icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]"

/obj/structure/closet/fireaxecabinet/open()
	return

/obj/structure/closet/fireaxecabinet/close()
	return
