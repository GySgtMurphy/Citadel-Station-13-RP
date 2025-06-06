/obj/machinery/computer/curer
	name = "cure research machine"
	icon_keyboard = "med_key"
	icon_screen = "dna"
	circuit = /obj/item/circuitboard/curefab
	var/curing
	var/virusing

	var/obj/item/reagent_containers/container = null

/obj/machinery/computer/curer/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I,/obj/item/reagent_containers))
		. = CLICKCHAIN_DO_NOT_PROPAGATE
		if(!container)
			if(!user.attempt_insert_item_for_installation(I, src))
				return
			container = I
		return
	if(istype(I,/obj/item/virusdish))
		if(virusing)
			to_chat(user, "<b>The pathogen materializer is still recharging..</b>")
			return
		var/obj/item/reagent_containers/glass/beaker/product = new(src.loc)

		var/list/data = list("donor"=null,"blood_DNA"=null,"blood_type"=null, "trace_chem"=null,"virus2"=list(),"antibodies"=list())
		data["virus2"] |= I:virus2
		product.reagents.add_reagent("blood",30,data)

		virusing = 1
		spawn(1200) virusing = 0

		state("The [src.name] Buzzes", "blue")
		return CLICKCHAIN_DO_NOT_PROPAGATE
	return ..()

/obj/machinery/computer/curer/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/curer/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(..())
		return
	user.machine = src
	var/dat
	if(curing)
		dat = "Antibody production in progress"
	else if(virusing)
		dat = "Virus production in progress"
	else if(container)
		// see if there's any blood in the container
		var/datum/blood_mixture/mixture_data = container.reagents.get_reagent_data(/datum/reagent/blood)

		if(mixture_data)
			dat = "Blood sample inserted."
			dat += "<BR>Antibodies: [antigens2string(mixture_data.legacy_antibodies)]"
			dat += "<BR><A href='?src=\ref[src];antibody=1'>Begin antibody production</a>"
		else
			dat += "<BR>Please check container contents."
		dat += "<BR><A href='?src=\ref[src];eject=1'>Eject container</a>"
	else
		dat = "Please insert a container."

	user << browse(HTML_SKELETON(dat), "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/curer/process(delta_time)
	..()

	if(machine_stat & (NOPOWER|BROKEN))
		return
	use_power(500)

	if(curing)
		curing -= 1
		if(curing == 0)
			if(container)
				createcure(container)
	return

/obj/machinery/computer/curer/Topic(href, href_list)
	if(..())
		return 1
	usr.machine = src

	if (href_list["antibody"])
		curing = 10
	else if(href_list["eject"])
		container.loc = src.loc
		container = null

	src.updateUsrDialog()


/obj/machinery/computer/curer/proc/createcure(var/obj/item/reagent_containers/container)
	var/obj/item/reagent_containers/glass/beaker/product = new(src.loc)

	var/datum/blood_mixture/mixture_data = container.reagents.get_reagent_data(/datum/reagent/blood)

	var/list/data = list()
	data["antibodies"] = mixture_data.legacy_antibodies
	product.reagents.add_reagent("antibodies",30,data)

	state("\The [src.name] buzzes", "blue")
