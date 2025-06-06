/obj/item/paper/talisman
	icon_state = "paper_talisman"
	origin_tech = list(TECH_ARCANE = 4)
	var/imbue = null
	var/uses = 0
	info = "<center><img src='talisman.png'></center><br/><br/>"

/obj/item/paper/talisman/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(iscultist(user))
		var/delete = 1
		// who the hell thought this was a good idea :(
		switch(imbue)
			if("newtome")
				call(TYPE_PROC_REF(/obj/effect/rune, tomesummon))()
			if("armor")
				call(TYPE_PROC_REF(/obj/effect/rune, armor))()
			if("emp")
				call(TYPE_PROC_REF(/obj/effect/rune, emp))(usr.loc,3)
			if("conceal")
				call(TYPE_PROC_REF(/obj/effect/rune, obscure))(2)
			if("revealrunes")
				call(TYPE_PROC_REF(/obj/effect/rune, revealrunes))(src)
			if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
				call(TYPE_PROC_REF(/obj/effect/rune, teleport))(imbue)
			if("communicate")
				//If the user cancels the talisman this var will be set to 0
				delete = call(TYPE_PROC_REF(/obj/effect/rune, communicate))()
			if("deafen")
				call(TYPE_PROC_REF(/obj/effect/rune, deafen))()
			if("blind")
				call(TYPE_PROC_REF(/obj/effect/rune, blind))()
			if("runestun")
				to_chat(user, "<span class='warning'>To use this talisman, attack your target directly.</span>")
				return
			if("supply")
				supply()
		var/mob/living/carbon/human/H = ishuman(user)? user : null
		H?.take_random_targeted_damage(brute = 5, burn = 0)
		if(src && src.imbue!="supply" && src.imbue!="runestun")
			if(delete)
				qdel(src)
		return
	else
		to_chat(user, "You see strange symbols on the paper. Are they supposed to mean something?")

/obj/item/paper/talisman/legacy_mob_melee_hook(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	if(isliving(user) && iscultist(user))
		var/mob/living/L = user
		if(imbue == "runestun")
			L.take_random_targeted_damage(brute = 5, burn = 0)
			call(TYPE_PROC_REF(/obj/effect/rune, runestun))(target)
			qdel(src)
			return CLICKCHAIN_DO_NOT_PROPAGATE
	return ..()


/obj/item/paper/talisman/proc/supply(key)
	if (!src.uses)
		qdel(src)
		return

	var/dat = "<B>There are [src.uses] bloody runes on the parchment.</B><BR>"
	dat += "Please choose the chant to be imbued into the fabric of reality.<BR>"
	dat += "<HR>"
	dat += "<A href='?src=\ref[src];rune=newtome'>N'ath reth sh'yro eth d'raggathnor!</A> - Allows you to summon a new arcane tome.<BR>"
	dat += "<A href='?src=\ref[src];rune=teleport'>Sas'so c'arta forbici!</A> - Allows you to move to a rune with the same last word.<BR>"
	dat += "<A href='?src=\ref[src];rune=emp'>Ta'gh fara'qha fel d'amar det!</A> - Allows you to destroy technology in a short range.<BR>"
	dat += "<A href='?src=\ref[src];rune=conceal'>Kla'atu barada nikt'o!</A> - Allows you to conceal the runes you placed on the floor.<BR>"
	dat += "<A href='?src=\ref[src];rune=communicate'>O bidai nabora se'sma!</A> - Allows you to coordinate with others of your cult.<BR>"
	dat += "<A href='?src=\ref[src];rune=runestun'>Fuu ma'jin</A> - Allows you to stun a person by attacking them with the talisman.<BR>"
	dat += "<A href='?src=\ref[src];rune=armor'>Sa tatha najin</A> - Allows you to summon armoured robes and an unholy blade<BR>"
	dat += "<A href='?src=\ref[src];rune=soulstone'>Kal om neth</A> - Summons a soul stone<BR>"
	dat += "<A href='?src=\ref[src];rune=construct'>Da A'ig Osk</A> - Summons a construct shell for use with captured souls. It is too large to carry on your person.<BR>"
	usr << browse(HTML_SKELETON(dat), "window=id_com;size=350x200")
	return


/obj/item/paper/talisman/Topic(href, href_list)
	if(!src)
		return
	if (usr.stat || usr.restrained() || !in_range(src, usr))
		return

	if (href_list["rune"])
		switch(href_list["rune"])
			if("newtome")
				var/obj/item/paper/talisman/T = new /obj/item/paper/talisman(get_turf(usr))
				T.imbue = "newtome"
			if("teleport")
				var/obj/item/paper/talisman/T = new /obj/item/paper/talisman(get_turf(usr))
				T.imbue = "[pick("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri", "orkan", "allaq")]"
				T.info = "[T.imbue]"
			if("emp")
				var/obj/item/paper/talisman/T = new /obj/item/paper/talisman(get_turf(usr))
				T.imbue = "emp"
			if("conceal")
				var/obj/item/paper/talisman/T = new /obj/item/paper/talisman(get_turf(usr))
				T.imbue = "conceal"
			if("communicate")
				var/obj/item/paper/talisman/T = new /obj/item/paper/talisman(get_turf(usr))
				T.imbue = "communicate"
			if("runestun")
				var/obj/item/paper/talisman/T = new /obj/item/paper/talisman(get_turf(usr))
				T.imbue = "runestun"
			if("armor")
				var/obj/item/paper/talisman/T = new /obj/item/paper/talisman(get_turf(usr))
				T.imbue = "armor"
			if("soulstone")
				new /obj/item/soulstone(get_turf(usr))
			if("construct")
				new /obj/structure/constructshell/cult(get_turf(usr))
		src.uses--
		supply()
	return


/obj/item/paper/talisman/supply
	imbue = "supply"
	uses = 5
