// PDA

/datum/prototype/design/science/general/pda
	design_name = "PDA"
	desc = "Cheaper than whiny non-digital assistants."
	id = "pda"
	req_tech = list(TECH_ENGINEERING = 2, TECH_POWER = 3)
	materials_base = list(MAT_STEEL = 50, MAT_GLASS = 50)
	build_path = /obj/item/pda

// Cartridges

/datum/prototype/design/science/pda_cartridge
	abstract_type = /datum/prototype/design/science/pda_cartridge
	req_tech = list(TECH_ENGINEERING = 2, TECH_POWER = 3)
	materials_base = list(MAT_STEEL = 50, MAT_GLASS = 50)

/datum/prototype/design/science/pda_cartridge/generate_name(template)
	return "PDA cartridge ([..()])"

/datum/prototype/design/science/pda_cartridge/cart_basic
	id = "cart_basic"
	build_path = /obj/item/cartridge

/datum/prototype/design/science/pda_cartridge/engineering
	id = "cart_engineering"
	build_path = /obj/item/cartridge/engineering

/datum/prototype/design/science/pda_cartridge/atmos
	id = "cart_atmos"
	build_path = /obj/item/cartridge/atmos

/datum/prototype/design/science/pda_cartridge/medical
	id = "cart_medical"
	build_path = /obj/item/cartridge/medical

/datum/prototype/design/science/pda_cartridge/chemistry
	id = "cart_chemistry"
	build_path = /obj/item/cartridge/chemistry

/datum/prototype/design/science/pda_cartridge/security
	id = "cart_security"
	build_path = /obj/item/cartridge/security

/datum/prototype/design/science/pda_cartridge/janitor
	id = "cart_janitor"
	build_path = /obj/item/cartridge/janitor

/datum/prototype/design/science/pda_cartridge/science
	id = "cart_science"
	build_path = /obj/item/cartridge/signal/science

/datum/prototype/design/science/pda_cartridge/quartermaster
	id = "cart_quartermaster"
	build_path = /obj/item/cartridge/quartermaster

/datum/prototype/design/science/pda_cartridge/head
	id = "cart_head"
	build_path = /obj/item/cartridge/head

/datum/prototype/design/science/pda_cartridge/hop
	id = "cart_hop"
	build_path = /obj/item/cartridge/hop

/datum/prototype/design/science/pda_cartridge/hos
	id = "cart_hos"
	build_path = /obj/item/cartridge/hos

/datum/prototype/design/science/pda_cartridge/ce
	id = "cart_ce"
	build_path = /obj/item/cartridge/ce

/datum/prototype/design/science/pda_cartridge/cmo
	id = "cart_cmo"
	build_path = /obj/item/cartridge/cmo

/datum/prototype/design/science/pda_cartridge/rd
	id = "cart_rd"
	build_path = /obj/item/cartridge/rd

/datum/prototype/design/science/pda_cartridge/captain
	id = "cart_captain"
	build_path = /obj/item/cartridge/captain
