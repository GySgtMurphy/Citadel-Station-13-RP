/obj/machinery/vending/trader/research
	name = "Research Specialty Items Incorporated"
	desc = "A vending machine selling things related to all manner of scientific pursuits, at a wholesale cost."
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"
	icon_deny = "generic-deny"
	icon_vend = "generic-vend"
	product_slogans = "My suits will protect you from space !"
	product_ads = "Please buy my suits !; I just wanted this orange one, but I had to buy the full bundle ! Help me !; Look ! Those voidsuit are Fleeexible !"

	products_auto_init = list(
		/obj/item/clothing/suit/space/emergency = 5,
		/obj/item/clothing/head/helmet/space/emergency = 5,
		/obj/item/clothing/suit/space/traveler = 2,
		/obj/item/clothing/suit/space/traveler/blue = 2,
		/obj/item/clothing/suit/space/traveler/green/dark = 2,
		/obj/item/clothing/suit/space/traveler/green = 2,
		/obj/item/clothing/suit/space/traveler/black = 2,
		/obj/item/clothing/head/helmet/space/traveler = 2,
		/obj/item/clothing/head/helmet/space/traveler/blue = 2,
		/obj/item/clothing/head/helmet/space/traveler/green/dark = 2,
		/obj/item/clothing/head/helmet/space/traveler/green = 2,
		/obj/item/clothing/head/helmet/space/traveler/black = 2,
		/obj/item/clothing/head/helmet/space/void/explorer = 3,
		/obj/item/clothing/suit/space/void/explorer = 3,
		/obj/item/tank/emergency/oxygen = 10,
		/obj/item/tank/emergency/oxygen/double = 2,
		/obj/item/clothing/mask/gas/clear = 10,
	)

	prices = list(
		/obj/item/clothing/suit/space/emergency = 10,
		/obj/item/clothing/head/helmet/space/emergency = 10,
		/obj/item/clothing/suit/space/traveler = 150,
		/obj/item/clothing/suit/space/traveler/blue = 150,
		/obj/item/clothing/suit/space/traveler/green/dark = 150,
		/obj/item/clothing/suit/space/traveler/green = 150,
		/obj/item/clothing/suit/space/traveler/black = 150,
		/obj/item/clothing/head/helmet/space/traveler = 150,
		/obj/item/clothing/head/helmet/space/traveler/blue = 150,
		/obj/item/clothing/head/helmet/space/traveler/green/dark = 150,
		/obj/item/clothing/head/helmet/space/traveler/green = 150,
		/obj/item/clothing/head/helmet/space/traveler/black = 150,
		/obj/item/clothing/head/helmet/space/void/explorer = 125,
		/obj/item/clothing/suit/space/void/explorer = 125,
		/obj/item/tank/emergency/oxygen = 5,
		/obj/item/tank/emergency/oxygen/double = 30,
		/obj/item/clothing/mask/gas/clear = 5,
	)
