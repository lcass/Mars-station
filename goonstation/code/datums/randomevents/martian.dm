proc/pick_size(var/list/data , var/num)
	var/list/output = list()
	for(var/i = 0, i < num , i++)
		var/item = pick(data)
		if(!item)
			return output
		output += item
		data -= item
	return output
/obj/machinery/mars_machine//literally just does this
	name = "Martian clock"
	desc = "Announces the time for all to hear"
	icon = 'icons/obj/machines/nuclear.dmi'
	icon_state = "neutinj"
	var/current_state = 0//day or night?
	var/day_time = 18000
	var/processing = 0
	var/night_time = 16000//total time of 34 minutes
	New()//gah I feel bad for even doing this
		update_state()
	proc/update_state()
		if(current_state)//day
			command_alert("Night has come , have a good night crew.")
			current_state = 0
			for(var/area/marsoutpost/duststorm/mars in world)
				mars.luminosity = 0
			spawn(night_time)
				update_state()
			return
		else
			command_alert("Mars is entering it's day phase , please be productive")
			current_state = 1
			for(var/area/marsoutpost/duststorm/mars in world)
				mars.luminosity = 1
			spawn(day_time)
				update_state()
			return
	proc/process_dust(var/processing)
		src.processing = processing
		if(src.processing)
			processing_items.Add(src)
		else
			processing_items.Remove(src)
	process()
		for(var/area/marsoutpost/duststorm/tile in world)
			tile.process()

/obj/newmeteor/dust
	name = "martian dust"
	desc = "A dense wad of high velocity dust , you should be running."
	//needs an icon
	hits = 2

	Bump(atom/A)
		spawn(0)
			if (A)
				//A.meteorhit(src)
				if(istype(A,/obj/window)&&prob(0.2))//need to add martian shutters to the station
					var/obj/window/window = A
					window.smash()
				else if(istype(A,/obj/machinery) && prob(0.1))
					//var/obj/machinery/machine = A
					//A.stat |= BROKEN //oh noes is broken , need to add something that can fix this
					qdel(A)
				else if(istype(A,/mob/living/carbon))
					var/mob/living/carbon/C = A
					C.weakened = 2//knock them down
					C.TakeDamage(pick("chest","head","l_arm","r_arm","l_leg","r_leg"),rand(3,15), 0, 0, DAMAGE_STAB)
					C.TakeDamage(pick("chest","head","l_arm","r_arm","l_leg","r_leg"),rand(3,15), 0, 0, DAMAGE_STAB)
					C.visible_message("<span class='danger'>[C.name] is shredded by the [src.name]!</span>")
					if(istype(C,/mob/living/carbon/human)&&prob(0.2))
						var/mob/living/carbon/human/H = C
						if(H.wear_suit)
							H.visible_message("<span class='danger'>The [H.wear_suit.name] is ripped off of [H.name]!</span>")
							H.u_equip(H.wear_suit)

				if (sound_impact)
					playsound(src.loc, sound_impact, 40, 1)
			if (--src.hits <= 0)
				if(istype(A, /obj/forcefield)) src.explodes = 0
				shatter()

		return
/obj/newmeteor/dust/heavy
	//needs an icon
	hits = 4
	Bump(atom/A)
		spawn(0)
			if (A)
				//A.meteorhit(src)
				if(istype(A,/obj/window))//need to add martian shutters to the station
					var/obj/window/window = A
					window.smash()
				else if(istype(A,/obj/machinery) && prob(0.7))
					//var/obj/machinery/machine = A
					//A.stat |= BROKEN //oh noes is broken , need to add something that can fix this
					qdel(A)
				/*else if(istype(A,/turf/wall))
					if(prob(0.4))
						qdel(A)*/
				else if(istype(A,/mob/living/carbon))
					var/mob/living/carbon/C = A
					C.weakened = 2//knock them down
					C.TakeDamage(pick("chest","head","l_arm","r_arm","l_leg","r_leg"),rand(15,45), 0, 0, DAMAGE_STAB)
					C.TakeDamage(pick("chest","head","l_arm","r_arm","l_leg","r_leg"),rand(15,45), 0, 0, DAMAGE_STAB)
					C.visible_message("<span class='danger'>[C.name] is shredded by the [src.name]!</span>")
					if(istype(C,/mob/living/carbon/human)&&prob(0.2))
						var/mob/living/carbon/human/H = C
						if(H.wear_suit)
							H.visible_message("<span class='danger'>The [H.wear_suit.name] is ripped off of [H.name]!</span>")
							H.u_equip(H.wear_suit)

				if (sound_impact)
					playsound(src.loc, sound_impact, 40, 1)
			if (--src.hits <= 0)
				if(istype(A, /obj/forcefield)) src.explodes = 0
				shatter()

/datum/random_event/dust_storm
	name = "Dust Storm"
	// centcom message handled modularly here
	required_elapsed_round_time = 6000 // 10m
	var/time = 3000//5 minutes
	var/map_boundary = 25
	event_effect(var/source)
		..()
		time = pick(3000,4000,5000,6000)
		var/direction = rand(1,4)
		var/amount = rand(50,200)//shred that bastard
		var/delay = rand(2,20)
		var/warning_time = 3000
		var/speed = rand(5,25)
		var/heavy_sand = 0
		var/comdir = "unknown direction"
		var/obj/machinery/mars_machine/processor = locate(/obj/machinery/mars_machine) in world
		var/ac_dir = NORTH
		switch(direction)
			if(1)
				comdir = "the north"
				ac_dir = NORTH
			if(2)
				comdir = "the south"
				ac_dir = SOUTH
			if(3)
				comdir = "the east"
				ac_dir = EAST
			if(4)
				comdir = "the west"
				ac_dir = WEST

		var/comsev = "Indeterminable"
		switch(amount)
			if(150 to INFINITY)
				comsev = "Catastrophic"
				heavy_sand = rand(5,50)//sand that can do severe damage to station equipment , blows people up
			if(125 to 150)
				comsev = "Major"
				heavy_sand = rand(5,20)
			if(100 to 125) comsev = "Significant"
			if(50 to 100) comsev = "Minor"
		if (random_events.announce_events)
			command_alert("[comsev] sand storm approaching from [comdir]. Arrival in [warning_time] seconds.", "Weather alert")
			world << 'sound/machines/engine_alert2.ogg'
		spawn(warning_time)
			for(var/area/marsoutpost/duststorm/tile in world)
				tile.set_winds(1,ac_dir)
			processor.process_dust(1)
			if (random_events.announce_events)
				command_alert("The sand storm has reached the station. Brace for impact.", "Meteor Alert")
				world << 'sound/machines/engine_alert1.ogg'
			var/start_x
			var/start_y
			var/targ_x
			var/targ_y

			while(amount> 0)
				amount--

				switch(direction)
					if(1) // north
						start_y = world.maxy-map_boundary
						targ_y = map_boundary
						start_x = rand(map_boundary, world.maxx-map_boundary)
						targ_x = start_x
					if(2) // south
						start_y = map_boundary
						targ_y = world.maxy-map_boundary
						start_x = rand(map_boundary, world.maxx-map_boundary)
						targ_x = start_x
					if(3) // east
						start_y = rand(map_boundary,world.maxy-map_boundary)
						targ_y = start_y
						start_x = world.maxx-map_boundary
						targ_x = map_boundary
					if(4) // west
						start_y = rand(map_boundary, world.maxy-map_boundary)
						targ_y = start_y
						start_x = map_boundary
						targ_x = world.maxx-map_boundary
					else // anywhere
						if(prob(50))
							start_y = pick(map_boundary,world.maxy-map_boundary)
							start_x = rand(map_boundary, world.maxx-map_boundary)
						else
							start_y = rand(map_boundary, world.maxy-map_boundary)
							start_x = pick(map_boundary,world.maxx-map_boundary)
				var/turf/pickedstart = locate(start_x, start_y, 1)
				var/target = locate(targ_x, targ_y, 1)
				if(prob(heavy_sand/amount))
					var/obj/newmeteor/dust/heavy/M = new /obj/newmeteor/dust/heavy(pickedstart,target)
					M.pix_speed = speed + rand(0 - rand(1,3),rand(1,3))
				sleep(delay)
			command_alert("The meteor shower has ended , please fix damaged systems and return to your work stations.", "Meteor Alert")
			processor.process_dust(0)
			for(var/area/marsoutpost/duststorm/tile in world)
				tile.set_winds(0,0)
//add a special heavy wind event
/area/marsoutpost/duststorm
	name = "Barren Planet"
	icon_state = "yellow"
	requires_power = 0
	luminosity = 1
	RL_Lighting = 0
	var/winds = 0
	var/winds_dir = 1
	var/obj/machine/mars_machine/processor
	New()
		..()
		//overlays += image(icon = 'icons/turf/areas.dmi', icon_state = "dustverlay", layer = EFFECTS_LAYER_BASE)
	proc/set_winds(var/windy , var/wind_dir)
		winds = windy
		winds_dir = wind_dir
		if(winds)
			overlays += image(icon='icons/turf/areas.dmi', icon_state = "dustverlay" , layer = EFFECTS_LAYER_BASE)
			return
		else
			overlays = list()
			return
	process()
		for(var/mob/living/M in get_turf(src))
			if(prob(0.1))
				if (M.stat != 2)
					if((istype(M:wear_suit, /obj/item/clothing/suit/armor/mars))&&(istype(M:head, /obj/item/clothing/head/helmet/mars))) return
					M.TakeDamage(pick("chest","head","l_arm","r_arm","l_leg","r_leg"),rand(5,15), 0, 0, DAMAGE_STAB)
					M.weakened = 5
					M<<"<span class='danger'>The winds knock you over!</span>"
					step(M,winds_dir)
					if(prob(50))
						playsound(src.loc, 'sound/effects/bloody_stabOLD.ogg', 50, 1)
						boutput(M, pick("Dust gets caught in your eyes!","The wind blows you off course!","Debris pierces through your skin!"))



//shuttle areas
var/list/pirate_start = list()
/area/shuttle/pirate
	name = "Prison Shuttle"

/area/shuttle/pirate/space
	icon_state = "shuttle"

/area/shuttle/pirate/cargo
	icon_state = "shuttle2"

/area/shuttle/pirate/research
	icon_state = "shuttle2"

/datum/random_event/pirate
	name = "Pirate boarding"
	centcom_headline = "Un-autherised vessel landing"
	centcom_message = "An unknown shuttle is attempting to land at the colony."
	var/active = 0

	event_effect()
		..()
		if(active == 1)
			return //This is to prevent admins from fucking up the shuttle arrival/departures by spamming this event.
		event = 1
		var/mob/dead/observer/list/pirates = list()
		var/mob/dead/observer/list/avail_ghosts = list()
		for(var/mob/dead/observer/ghost in mobs)
			if(ghost.client)
				avail_ghosts += ghost
		pirates = pick(avail_ghosts,pick(2,3))
		for(var/mob/dead/observer/pirate_mind in pirates)
			var/start = pick(pirate_start)
			var/mob/living/carbon/human/pirate = new /mob/living/carbon/human(start)
			pirate_mind.mind.transfer_to(pirate_mind)
			qdel(pirate_mind)
			boutput(pirate, "<span style=\"color:red\">You are a space pirate , yarg! Plunder the colony for dubloons.</span>")
			boutput(pirate, "<span style=\"color:red\">1 minute to landing so gear up and prepare to board!</span>")
			pirate.equip_if_possible(new /obj/item/device/radio/headset/civilian(pirate), pirate.slot_ears)
			pirate.equip_if_possible(new /obj/item/clothing/under/suit(pirate), pirate.slot_w_uniform)
			pirate.equip_if_possible(new /obj/item/clothing/shoes/black(pirate), pirate.slot_shoes)
			pirate.equip_if_possible(new /obj/item/clothing/suit/armor/vest(pirate), pirate.slot_wear_suit)
			pirate.equip_if_possible(new /obj/item/clothing/gloves/black(pirate), pirate.slot_gloves)
			pirate.equip_if_possible(new /obj/item/clothing/head/helmet/swat(pirate), pirate.slot_head)
			pirate.equip_if_possible(new /obj/item/storage/backpack(pirate), pirate.slot_back)
			pirate.name = pick("Rick Yargson","Le Petit Tickler","Corny Greenwalsh","Cyd Swashbuckle","David Joneson", "Sam Arli","Jacket","Morty Yargson","Tim 'blast' Swish","Pete the drunk","Jimmy Twister","Belt 'Buckle' Davies")
			//pirate.equip_if_possible(new /obj/item/ammo/bullets/a357(pirate), pirate.slot_in_backpack)
			//pirate.equip_if_possible(new /obj/item/gun/kinetic/revolver(pirate), pirate.slot_belt)
		sleep(600)//1 minute to prepare

		command_alert("The vessel has landed at the colony.", "Landing craft arrival")

		var/shuttle = pick("research","cargo");
		var/area/start_location = null
		var/area/end_location = null
		start_location = locate(/area/shuttle/pirate/space)
		if(shuttle == "cargo")
			end_location = locate(/area/shuttle/pirate/cargo)
		else
			end_location = locate(/area/shuttle/pirate/research)
		var/list/dstturfs = list()
		var/throwy = world.maxy

		for(var/atom/A as obj|mob in end_location)
			spawn(0)
				A.ex_act(1)

		for(var/turf/T in end_location)
			dstturfs += T
			if(T.y < throwy)
				throwy = T.y

		// hey you, get out of the way!
		for(var/turf/T in dstturfs)
			// find the turf to move things to
			var/turf/D = locate(T.x, throwy - 1, 1)
			//var/turf/E = get_step(D, SOUTH)
			for(var/atom/movable/AM as mob|obj in T)
				if(istype(AM, /mob/dead))
					continue
				AM.Move(D)
			if(istype(T, /turf/simulated))
				qdel(T)

		start_location.move_contents_to(end_location)

		sleep(rand(6000,9000))//10 to 15 minutes

		command_alert("The vessel is preparing to undock, please stand clear.", "Landing craft departure")

		sleep(600)//1 minute to leave

		// hey you, get out of my shuttle! I ain't taking you back to centcom!
		var/area/teleport_to_location = locate(/area/station/hallway/secondary/construction) //TODO: Make this go to the closest station area, so that this doesn't break on future maps.

		for(var/turf/T in dstturfs)
			for(var/mob/AM in T)
				if(istype(AM, /mob/dead))
					continue
				showswirl(AM)
				AM.set_loc(pick(get_area_turfs(teleport_to_location, 1)))
				showswirl(AM)
			for (var/obj/O in T)
				get_hiding_jerk(O)
				/*
				for (var/mob/AM in O.contents)
					boutput(AM, "<span style=\"color:red\"><b>Your body is destroyed as the merchant shuttle passes [pick("an eldritch decomposure field", "a life negation ward", "a telekinetic assimilation plant", "a swarm of matter devouring nanomachines", "an angry Greek god", "a burnt-out coder", "a death ray fired millenia ago from a galaxy far, far away")].</b></span>")
					AM.gib()
				*/

		end_location.move_contents_to(start_location)
		active = 0

//containment breach

/obj/machinery/breachbutton
	name = "Containment Breach Button"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "party"
	desc = "Activates the outpost warhead and is clearly labelled for ages 8 and up only."
	var/pressed = 0
	var/cont = 1
	var/done = 0
	var/delay = 0
	anchored = 1.0
	mats = 5

/obj/machinery/breachbutton/attack_hand(mob/user as mob)
	if(user.stat)
		return
	if(done || delay)
		boutput(user,"Click...")
	if(!pressed)
		command_alert("Containment breach detected , please stay in your departments.", "Outpost Alert")
		world << 'sound/machines/engine_alert2.ogg'
		activate()
		pressed = 1
	else
		if(cont)
			pressed = 0
			cont = 0
			command_alert("Containment breach averted , normal proceedures reinstated.", "Outpost Alert")
			delay = 1
			spawn(3000)//so that you can't just spam these messages
				delay = 0

/obj/machinery/breachbutton/proc/activate()
	sleep(300)//30 seconds to revoke the call
	if(!cont)
		return
	done = 1
	command_alert("Containment breach confirmed. Warhead activated and martial law enstated , stay within your departments.", "Outpost Alert")
	world << 'sound/machines/engine_alert2.ogg'
	var/obj/machinery/explosive/outpost_charge/boom
	for(var/obj/machinery/explosive/outpost_charge/charge in world)
		boom = charge
		break//cheeky but meh it gets called once every now and then
	boom.start()//once it starts it don't stop

/obj/machinery/explosive
	name = "Explosive Charge"
	anchored = 1
	density = 1
	icon = 'icons/obj/networked.dmi'
	icon_state = "net_nuke0"
	desc = "An explosive charge covered in scary stickers , this one reads 5 KT."
	var/time = 60
	var/active = 0
	var/message = "Explosive Charge"
	var/power = 40//booooomm
	var/shatter_coeff = 1.5


	proc/start()
		if(active)
			return
		active = 1
		sleep(time * 10)
		command_alert("Warhead detonation triggered.", message)
		world << 'sound/machines/firealarm.ogg'
		explosion_new(src, get_turf(src), power , shatter_coeff)

/obj/machinery/explosive/outpost_charge
	desc = "An explosive charge covered in scary stickers , this one reads 7.5 KT."
	time = 90
	message = "Outpost Warhead Detonation"
	power = 60//booooomm
	shatter_coeff = 2.3