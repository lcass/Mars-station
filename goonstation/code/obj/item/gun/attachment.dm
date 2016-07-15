/obj/item/attachment
	name = "attachment"
	icon = 'icons/obj/gun_mod.dmi'
	desc = "You shouldn't see this"
	icon_state = "mod-grip"
	var/attach_type = "muzzle"
	var/accuracy = 0//+- to change the accuracy , + 5 is basically a sniper - 5 is like firing a shotgun by holding it with your pinky
	var/damage = 0//+- to change the damage , changes the actual damage of the bullet so + 100 will kill on hit
	var/recoil = 0//+- , + increases recoil
	var/penetration = 0//+ only , means that the bullet passes through more things
	var/delay = 0//+ only , increases the delay between each shot
	var/supress = 0//+- , makes the weapon quieter or louder
	New()
		return
	proc/effect()//only works on magazine weapons , called when special function is enacted
		return
	proc/on_fire()
		return 0

//barrel attachments
/obj/item/attachment/extend
	name = "extended barrel"
	desc = "A barrel extender , it's a muzzle attachment"
	attach_type = "muzzle"
	accuracy = 1
	damage = 4
	recoil = 2
	supress = 1
/obj/item/attachment/extend_sniper
	name = "sniper barrel"
	desc = "A heavy and long steel barrel , it's a muzzle attachment"
	attach_type = "muzzle"
	accuracy = 3
	damage = 10
	recoil = 4
	penetration = 1
	delay = 3
	supress = -2
/obj/item/attachment/charger//not stolen at all
	name = "velocity booster"
	desc = "A velocity booster , it is a muzzle attachment"
	attach_type = "muzzle"
	accuracy = -2
	damage = 15//boosh
	recoil = 2
	delay = 2
	supress = -1
/obj/item/attachment/supressor
	name = "supressor"
	desc = "A medium sized supressor , it's a muzzle attachment"
	attach_type = "muzzle"
	accuracy = 1
	supress = 2
//underbarrel
/obj/item/attachment/foregrip
	name = "foregrip"
	desc = "A foregrip for reducing recoil , it's an underbarrel attachment"
	attach_type = "underbarrel"
	accuracy = 2
	recoil = -1
/obj/item/attachment/potatogrip
	name = "Potoato grip"
	desc = "A foregrip designed to greatly improve accuracy , it's an underbarrel attachment"
	attach_type = "underbarrel"
	accuracy = 3
	recoil = 2
/obj/item/attachment/flashlight
	name = "flashlight"
	attach_type = "underbarrel"
	desc = "A small underbarrel flashlight , it can be toggled"
	var/datum/light/light
	var/active = 0
	New()
		light = new/datum/light/point
		light.set_brightness(0.7)
		light.set_color(0.6,0.9,0.7)//blueish
		light.attach(src)
		light.disable()
	effect()
		if(active)
			light.disable()
		else
			light.enable()
		active = !active
/obj/item/attachment/bipod
	name = "bipod"
	desc = "An underbarrel attachment that will only work when standing still , it can be toggled"
	var/turf/start_loc = null
	var/setup = 0
	attach_type = "underbarrel"
	effect()
		if(setup)
			accuracy = -1
			recoil = 1
			delay = 0
		else
			start_loc = get_turf(src)
			accuracy = 3
			recoil = -1
			delay = 1
		setup = !setup
	on_fire()
		if(setup)
			if(get_turf(src) != start_loc)
				effect()
		return 0
/obj/item/attachment/boom
	name = "foregrip"
	desc = "Looks like a foregip and can be set to detonate on the next shot , standard issue for colony police."
	var/turf/start_loc = null
	var/active = 0
	attach_type = "underbarrel"
	effect()
		active = !active
	on_fire()
		if(active)
			src.visible_message("click... click... click...")
			spawn(2)
				//boom
				explosion_new(src, get_turf(src), 2 , 0.2)
				return 1
		return 0
//rail attachments
/obj/item/attachment/rds
	name = "red dot sight"
	desc = "A small rail attached reticle , can be used to improve accuracy"
	var/turf/start_loc = null
	var/active = 0
	attach_type = "rail"
	effect()
		if(active)
			accuracy = 0
		else
			accuracy = 2
			start_loc = get_turf(src)
		active = !active
	on_fire()
		if(active)
			if(get_turf(src) != start_loc)
				effect()
				return 0
		return 0
/obj/item/attachment/holo
	name = "Holographic sight"
	desc = "A holographic sight that greatly improves accuracy, it is a rail attachment"
	var/turf/start_loc = null
	var/active = 0
	attach_type = "rail"
	effect()
		if(active)
			accuracy = 0
			delay = 0
		else
			accuracy = 4
			delay = 2
			start_loc = get_turf(src)
		active = !active
	on_fire()
		if(active)
			if(get_turf(src) != start_loc)
				effect()
				return 0
		return 0
/obj/item/attachment/rapid
	name = "Rapid fire adapter"
	desc = "A small device that speeds up the chambering process , it is a rail attachment"
	attach_type = "rail"
	recoil = 2
	accuracy = -1
	delay = -5