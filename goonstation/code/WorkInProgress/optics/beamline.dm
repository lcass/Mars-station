//misc procs
proc/rad_gas(var/turf/T, var/m = 0)//m is moles , T is turf
	var/datum/gas/rad_particles/rad = new
	rad.moles = m
	if(!T:air:trace_gases)
		T:air:trace_gases = list()
	T:air:trace_gases += rad

/obj/beam/custom
	var/obj/item/lens/lens = null
	var/power = 1 // any value greater than 1 , when very high the beam becomes a particle
	limit = 10 // so people randomly spawning these don't make lag fest
	var/wavelength = 1//meters
	var/particle = 0//is it a particle wave or is it an electromagnetic wave (quantumish)
	layer = OBJ_LAYER - 0.1//we want it to be just underneath the machines
	icon_state = "h7beam1"
	New(location, newLimit, newPower, wavelength)//Lets not calculate the wavelength that would be painful , just do it normally.
		..()
		/*light = new /datum/light/point
		light.attach(src)
		light.set_color(0.28, 0.07, 0.58)
		light.set_brightness(src.power / 5)
		light.set_height(0.5)
		light.enable()*/
		if(wavelength != null)
			src.wavelength = wavelength
		if (newLimit != null)
			src.limit = newLimit
		if (newPower != null)
			src.power = newPower
		spawn(2)
			generate_next()
		return

	hit(atom/movable/AM as mob|obj)
		if(power/wavelength > 13) //very high energy (if the power is high and wavelength is low)
			particle = 1//make it a particle wave
		else
			particle = 0//nope no particles here
		if (istype(AM, /mob/living))
			var/mob/living/hitMob = AM
			//if it's a particle do random and high brute damage along with radiation , if it's a wave then do severe internal damage and radiation
			if(power >10 && particle)//very high power wave just gib the poor sod
				//gib
			if(particle)
				//do brute stuff
				hitMob.irradiate(power)//it's a constant hit so it will do a lot of damage
				return
			else
				//do slightly less radiation damage
				hitMob.irradiate(power/2)
				//do internal stuff
		else
			//do some stuff , make it glow etc
			if(istype(AM, /obj/machinery/networked/beamline))
				var/obj/machinery/networked/beamline/component = AM
				component.laser_act(wavelength,power,particle,limit)
				return
			if(istype(AM, /obj/machinery))
				explosion_new(src, get_turf(AM), power , 0.2)//machinery is instantly destroyed
				return
			if(istype(AM, /obj/item_holder))
				var/obj/item_holder/holder = AM
				var/obj/held = holder.held
				//make the thing do other things , I guess.
				if(istype(held ,/obj/item/gun/energy))
					//do stuff like boost damage
				if(istype(held ,/obj/item/fuel_pellet))
					//fusion related stuff goes ere , emit particles n what not
				if(istype(held ,/obj/item/lens))
					wavelength *= 0.68 //reduce the wavelength
					generate_next()

	generate_next()
		if (src.limit < 1)
			return

		var/turf/nextTurf = get_step(src, src.dir)
		if (istype(nextTurf))
			if (nextTurf.density)
				return

			src.next = new /obj/beam/custom(nextTurf, src.limit-1, src.power)
			next.dir = src.dir
			for (var/atom/movable/hitAtom in nextTurf)
				if (hitAtom.density && !hitAtom.anchored)
					src.hit(hitAtom)

				continue
		return

//the emitted neutrino beam
/obj/beam/neutrino
	var/obj/item/lens/lens = null
	var/power = 1 //power of the neutrino
	limit = 2 // so people randomly spawning these don't make lag fest
	layer = OBJ_LAYER - 0.1//we want it to be just underneath the machines
	var/penetration = 0.05//very low to start with
	var/datum/light/point/light
	var/limit_boost = 0
	icon_state = "h7beam1"
	var/limit_boost_prob = 0.1//chance for the limit to increase by 1
	New(location, newLimit, newPower)//Lets not calculate the wavelength that would be painful , just do it normally.
		..()
		limit = newLimit
		power = newPower

		light = new
		light.set_brightness(0.2)//gentle glow
		light.set_color(0.45, 00,0.86)//deep purple/blue
		light.set_height(2.4)
		light.attach(src)
		light.enable()
		if(power < 3)
		else if(power < 5)
			penetration = 0.15
		else if(power < 8)
			penetration = 0.3
		else if(power < 12)
			penetration = 0.7
		else
			penetration = 0.95
		spawn(1)//these move faster than the other beams
			generate_next()
		return

	hit(atom/movable/AM as mob|obj)
		light.disable()
		if(power < 3)//generate a small amount of power and do some minor stuff to mobs
			//
		else if(power < 5)//generate a bit more power , and have a chance to go through the person
			penetration = 0.15
		else if(power < 8)//do some nasty damage and maybe tear off a limb or two , high chance to go through people and objects
			penetration = 0.3
		//beyond this the particles are useless for power generation because they just explode people and objects
		else if(power < 12)//create a massive burst of radiation and a small explosion on impact , almost certainly continue through the person or object
			penetration = 0.7
		else//if the power is any higher cause cataclysmic damage to anything and everything , gib them on sight the cause large explosions , make huge amounts of radiation and cause large explosions
			penetration = 0.95
	generate_next()
		if (src.limit < 1)
			if(prob(limit_boost_prob))
				limit_boost = 1
			else
				on_limit()
				return
		var/turf/nextTurf = get_step(src, src.dir)
		if (istype(nextTurf))
			if (nextTurf.density && !prob(penetration))
				return
			src.next = new /obj/beam/custom(nextTurf, src.limit-1, src.power)
			next.dir = src.dir
			for (var/atom/movable/hitAtom in nextTurf)
				if (hitAtom.density && !hitAtom.anchored)
					src.hit(hitAtom)
					if(!prob(penetration))
						src.next.limit = 0
				continue
		return
	proc/on_limit()
		light.disable()
		//exploshuns n shiznicks
		if(power < 10)
			return
		if(power < 12)
			rad_gas(get_turf(src), 0.05)//small amount of radiation , lots of these are being produced to only small amounts
			return
		if(power < 15)
			rad_gas(get_turf(src), 0.1)//exploshuns
			if(prob(0.05))
				explosion(src, get_turf(src), 0, 0, 2, 2)
			return
		else
			rad_gas(get_turf(src),0.3)
			if(prob(0.15))
				explosion(src, get_turf(src), power/15, power/10, 3, 5)
//todo add a lead shield to prevent the radiation from
/obj/item_holder//this can hold lenses which aid in amplifying the wave
	name = "reinforced clamp"
	desc = "A heavily shielded clamp that looks like it could withstand a laser blast"
	icon = 'icons/obj/tripod.dmi'
	icon_state = "tripod"
	var/obj/held //the object the clamp is holding , this is what will be effected by the laser beam

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(!held)
			user.drop_item()
			O.loc = src
			held = O
			return
		else
			user<<"<span class='notice'>The [src.name] is already holding [src.held.name]"

	attack_hand(mob/user as mob)
		if(held)
			user<<"<span class='notice'>You remove the [src.held.name] from the [src.name]"
			held.loc = get_turf(src)
			held = 0
			return
		else
			user<<"You caress the [src.name] , it's cold to the touch and vibrates softly"

//fuel pellets

/obj/item/fuel_pellet
	name = "fuel pellet"
	desc = "a miscellaneous fuel pellet , probably just a piece of junk"
	icon = 'icons/obj/items.dmi'
	icon_state = "fuelpellet"
	var/radioactivity = 0.1//when blasted with the laser they become more and more radioactive
	var/mass = 10//total mass remaining
	var/starting_mass = 10//initial mass
	var/crit_e=10000//critical energy of the fuel pellet
	var/cur_e=0//current energy of the fuel pellet
	var/pow_mod = 1//modifies the power of the neutrinos going out  , only make very small changes
	var/dead = 0//if the fuel pellet is spent (when more than 3/4 of it's mass is used up)
	New()
		..()
		if (!(src in processing_items))
			processing_items.Add(src)

	proc/fuel_act(var/power , var/wavelength , var/particle)
		if(dead)
			return //meh , flavour text would get spammy and any effects would be unnecessary
		if(power/wavelength > cur_e)
			radioactivity*= ((power/wavelength)/max(1,cur_e))//on initial activation the wave will be very powerful
			cur_e += power/wavelength *0.8
			mass *= max(0.8,(1 - radioactivity)) //slowly reduces the mass , having less mass will reduce the power output and will increase the rate the material becomes radioactive
		else
			radioactivity*= ((power/wavelength)/max(1,cur_e))
			cur_e -= (cur_e - (power/wavelength))/2 //cause the current energy of the pellet to decay towards the power of the beam
			mass *= max(0.8 , (1 - radioactivity))
	process()
		if(dead)
			processing_items.Remove(src)
		effects()//call the effects for each individual type of fuel
		cur_e *= 0.9//reduce energy slowly
		mass *= min(0.95 , (1 - radioactivity)) //reduce mass slightly slower than with the beam
		radioactivity *= 0.8//radioactivity rapidly reduces
		if(cur_e > crit_e && prob(0.05))//It probably will happen but it stops insta death for the poor guy using it
			var/to_spawn = pick(7,8,9,10,15,20)//create a huge amount of these bastards , use all energy and destroy the pellet.
			for(var/a = 0 , a < to_spawn , a++)
				var/obj/beam/neutrino/out_beam = new /obj/beam/neutrino(get_turf(src),pick(9,11,14,14,14,15,18,25),(cur_e/60*to_spawn)*pow_mod)
				out_beam.dir = pick(NORTH,EAST,WEST,SOUTH)
			cur_e = 0
			//produce lots of radioactive gas
			rad_gas(get_turf(src),min(100,radioactivity*50))
			dead = 1
			processing_items.Remove(src)
			cur_e = 0
			radioactivity = 0
			mass = 0.25 * starting_mass
			return
		else if(cur_e > crit_e)
			if(prob(0.1))
				//eh pump out some radiation and start dropping off energy quickly
				cur_e *=0.8
				radioactivity*= 1.5
				rad_gas(get_turf(src),radioactivity * (cur_e/crit_e))//this will still produce neutrinos
		if(mass <= 0.25*starting_mass)
			dead = 1
			processing_items.Remove(src)//we know we are in processing items so no need to check
			cur_e = 0
			radioactivity = 0
			visible_message("[src.name] fizzles softly")
			return
		//we now want to create neutrino outputs in order to produce energy and also to have some funky effects
		//need to code neutrinos first though /:
		var/to_spawn = pick(2,3,5,7,9)
		for(var/a = 0 , a < to_spawn , a++)
			var/obj/beam/neutrino/out_beam = new /obj/beam/neutrino(get_turf(src),pick(2,3,3,3,4,4,4,5,5,6,7,9),(cur_e/(435*to_spawn))*pow_mod)
			out_beam.dir = pick(NORTH,EAST,WEST,SOUTH)
		if(prob(min(0.5,cur_e/crit_e)))//lots of rad = lots of bad.
			rad_gas(get_turf(src),radioactivity*min(0.2,cur_e/(30*crit_e)))
	proc/effects()
		return
/obj/item/fuel_pellet/gold
		name = "gold fuel pellet"
		desc = "A tiny lump of gold suitable for fusion experiments"
		crit_e = 20000
		starting_mass = 15// A good alrounder however if doesn't have any special effects
		mass = 15
/obj/item/fuel_pellet/uranium
		name = "uranium fuel pellet"
		desc = "Glowing and fissile , probably a good idea to whack this with a laser"
		pow_mod = 5
		crit_e = 2000//much lower critical energy so more dangerous to operate
		mass = 6//smaller mass
		starting_mass = 6
/obj/item/fuel_pellet/lithium
		name = "lithium fuel pellet"
		desc = "A small lump of lithium oxide , it shimmers"
		crit_e = 3000
		pow_mod = 1.2//has some special effects that occur when you use it.
// end of fuel pellets
//fuel pellet storage


/obj/item/pellet_storage
	name = "radioactive storage container"
	desc = "A patent pending radioactive storage container designed for holding radioactive materials"
	//needs icons

/obj/machinery/networked/laser_controller//means that you don't need 100000 network adapters , handles all the lasers and other connections.
	name = "networked laser controller"
	desc = "The Networked Laser Controller , adapting lasers to networks for years."
	icon = 'icons/obj/machines/fusion.dmi'
	icon_state = "cab1"
	var/range = 20//can be increased at the cost of more power usage and slower operation
	var/obj/machinery/networked/industrial_laser/list/lasers = list()
	var/obj/machinery/networked/beamline/list/beamline_components = list()
	var/disconnect = 0
	anchored = 1
	device_tag = "PNET_RESLAS_CONT"
	var/disconnect_position = 0
	var/disconnect_message = "command=disconnect"
	New()
		..()
		src.net_id = generate_net_id(src)

	receive_signal(datum/signal/signal)
		if(stat & (NOPOWER|BROKEN|MAINT) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return
		if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
			return
		var/target = signal.data["sender"]
		//They don't need to target us specifically to ping us.
		//Otherwise, if they aren't addressing us, ignore them
		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				spawn(5) //Send a reply for those curious jerks
					src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id)
					return
		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return
		switch(sigcommand)
			if("detect")
				update_connections()
				list_connected(target)
				return
			if("list")
				list_connected(target)
				return
			if("status")
				var/obj/machinery/networked/industrial_laser/laser = get_laser(signal.data["id"])
				if(laser)
					var/power = laser.setup_beam_power
					post_status(target,"command","status",data = "name=RES_LAS&value_name=Power&value=[power]")
				var/obj/machinery/networked/beamline/beamcomponent = get_beamline(signal.data["id"])
				if(beamcomponent)
					var/modifier = beamcomponent.modifier
					var/mod_name = beamcomponent
					post_status(target,"command","status",data="name=[mod_name]&value_name=Modifier&value=[modifier]")
				if(disconnect)
					disconnect = 0
					disconnect_position = 0
					var/list/alert_list = params2list(disconnect_message)
					if(alert_list["command"] == "disconnect")
						for(var/a = 0 , a < alert_list.len ,a++)
							if(alert_list["ls[a]"])
								post_status(target,"command","disconnect",alert_list["ls[a]"])
							else
								break
					disconnect_message = "command=disconnect"

			if("set")
				var/obj/machinery/networked/industrial_laser/laser = get_laser(signal.data["id"])
				if(laser)
					switch(laser.set_power(signal.data["value"]))
						if(0)
							post_status(target,"command","failure")
						if(1)
							return
						if(2)
							post_status(target,"command","limited")
				var/obj/machinery/networked/beamline/beamline = get_beamline(signal.data["id"])
				if(beamline)
					switch(beamline.set_modifier(signal.data["value"]))
						if(0)
							post_status(target,"command","failure")
							return
						if(1)
							return
						if(2)
							post_status(target,"command","limited")

	proc/update_connections()
		lasers = list()//clear that bastard
		beamline_components = list()//and that one
		for(var/obj/machinery/networked/industrial_laser/laser in range(range))
			lasers += laser
			laser.laser_control = src
		for(var/obj/machinery/networked/beamline/component in range(range))
			beamline_components += component
			component.laser_control = src

	proc/list_connected(var/target)
		var/message = ""
		var/iter = 0
		if(lasers)
			for(var/obj/machinery/networked/industrial_laser/laser in lasers)
				iter++
				if(iter==1)
					message += "ls1=[laser.id]"
					continue
				message += "&ls[iter]=[laser.id]"
		if(beamline_components)
			for(var/obj/machinery/networked/beamline/component in beamline_components)
				iter++
				if(iter==1)
					message += "ls1=[component.id]"
					continue
				message += "&ls[iter]=[component.id]"
		post_status(target,"command","list",data=message)

	proc/disconnect(var/id)
		disconnect_message += "&ls[disconnect_position]=[id]"
		disconnect_position ++
		disconnect = 1

	proc/get_laser(var/id)
		id = text2num(id)
		var/obj/machinery/networked/industrial_laser/ret_laser
		for(var/obj/machinery/networked/industrial_laser/laser in lasers)
			if(laser.id == id)
				ret_laser = laser
		return ret_laser

	proc/get_beamline(var/id)
		id = text2num(id)
		var/obj/machinery/networked/beamline/ret_component
		for(var/obj/machinery/networked/beamline/component in beamline_components)
			if(component.id == id)
				ret_component= component
		return ret_component
#define MAXPOWER 4
#define MINPOWER 1
#define LIMITED 2
#define OK 1
#define FAIL 0
/obj/machinery/networked/industrial_laser
	name = "industrial laser"
	desc = "An industrial laser beam emitter."
	icon = 'icons/obj/machines/fusion.dmi'
	icon_state = "laser-premade"
	var/obj/item/lens/lens = null
	var/obj/beam/custom/beam = null
	var/setup_beam_length = 48
	var/setup_beam_power = 2
	var/setup_beam_wavelength = 0.2
	var/id = 0
	var/obj/machinery/networked/laser_controller/laser_control
	New ()
		..()
		if (!src.lens)
			src.lens = new/obj/item/lens(src)
		id = beam_id
		beam_id++
		processing_items.Add(src)
	disposing()
		if (src.beam)
			src.beam.dispose()
			src.beam = null
		laser_control.disconnect(id)
		processing_items.Remove(src)
		..()

	process()
		if (stat & BROKEN)
			if (src.beam)
				src.beam.dispose()
			return
		power_usage = 1000
		..()
		if (stat & NOPOWER)
			if (src.beam)
				src.beam.dispose()
			return

		use_power(power_usage)

		if (!src.beam)
			var/turf/beamTurf = get_step(src, src.dir)
			if (!istype(beamTurf) || beamTurf.density)
				return
			src.beam = new /obj/beam/custom(beamTurf, setup_beam_length, setup_beam_power,setup_beam_wavelength)
			src.beam.dir = src.dir
			src.beam.lens = src.lens

			return

		return

	power_change()
		if(powered())
			stat &= ~NOPOWER
			src.update_icon()
		else
			spawn(rand(0, 15))
				stat |= NOPOWER
				src.update_icon()

	ex_act(severity)
		switch(severity)
			if(1.0)
				//dispose()
				src.dispose()
				return
			if(2.0)
				if (prob(50))
					src.stat |= BROKEN
					src.update_icon()
			if(3.0)
				if (prob(25))
					src.stat |= BROKEN
					src.update_icon()
			else
		return

	proc
		update_icon()
			if (stat & (NOPOWER|BROKEN))
				//src.icon_state = "heptemitter-p"
				if (src.beam)
					//qdel(src.beam)
					src.beam.dispose()
			//else
				//src.icon_state = "heptemitter[src.beam ? "1" : "0"]"
			return
	proc/set_power(var/power)
		if(!power)
			return FAIL
		setup_beam_power = power
		if(setup_beam_power > MAXPOWER)
			setup_beam_power = MAXPOWER
			return LIMITED
		if(setup_beam_power < MINPOWER)
			setup_beam_power = MINPOWER
			return LIMITED
		return OK
/obj/machinery/networked/beamline//uses a small amount of power in order to slowly increase range power and reduce wavelength
	name = "beamline component"
	desc = "Some sort of heavy machinery for use with a heavy laser setup."
	icon = 'icons/obj/machines/beamline64x32.dmi'
	icon_state = "beamline"
	layer = OBJ_LAYER
	var/obj/beam/beam
	var/id = 0
	var/modifier = 0
	var/modmax = 1
	var/modmin = 0
	var/obj/machinery/networked/laser_controller/laser_control
	New()
		..()
		id = beam_id//used for modifying beamline components
		beam_id++
	disposing()
		laser_control.disconnect(id)
		..()
	proc
		laser_act(wavelength , power  , particle,range)
			if(powered())
				use_power(power * (1/wavelength) * 20)//very small but using lots of them costs a lot
				src.beam = new /obj/beam/custom(get_turf(src), range * 1.05 , power , wavelength * 0.9)
				src.beam.dir = src.dir
			else
				src.beam = new /obj/beam/custom(get_turf(src), range * 0.9 , power - 1 , wavelength * 1.5)//no cheating
				src.beam.dir = src.dir
		set_modifier(var/modifier)
			if(!modifier)
				return FAIL
			src.modifier = modifier
			if(modifier>modmax)
				src.modifier = modmax
				return LIMITED
			if(modifier<modmin)
				src.modifier = modmin
				return LIMITED
			return OK

	power_change()
		if(powered())
			stat &= ~NOPOWER
			//src.update_icon()
		else
			spawn(rand(0, 15))
				stat |= NOPOWER
				//src.update_icon()
 //you can reduce the power and reduce the wavelength

//var for lasers and objects overall

var/beam_id = 1//starts at 1 , initiatlised at New() creation of beamline opbjects

/obj/machinery/networked/beamline/amplifier//this will also be networked but later
	name = "beamline amplifier"
	desc = "Supercharges lasers that pass through it."
	icon = 'icons/obj/machines/beamline64x32.dmi'
	icon_state = "amplifier-0"
	var/amplifying = 0
	var/prev_amp = 0
	modmax = 2.5
	modmin = 0.5
	modifier = 1//just make it do nothing until the value is set

	laser_act(wavelength,power,particle , range)//amplifies the wave at the cost of increasing the wavelength and reducing the range
		if(powered())
			use_power(modifier * (1/wavelength) * 150)//hefty amount if the wavelength is small and the power is high
			src.beam = new /obj/beam/custom(get_turf(src), range * 0.7 , power * src.modifier , wavelength * src.modifier)//reducing the range prevents you from stacking them together in a long line
			src.beam.dir = src.dir
		else
			src.beam = new /obj/beam/custom(get_turf(src), range * 0.9 , power - 1 , wavelength * 1.75)//no cheating
			src.beam.dir = src.dir
		amplifying = 1
	process()
		if(stat)
			amplifying = 0
			laser_control.disconnect(src.id)
		if(amplifying)
			icon_state = "amplifier-1"
		else
			icon_state = "amplifier-0"
		if(prev_amp != amplifying)
			prev_amp = amplifying
		amplifying = 0


/obj/machinery/networked/beamline/spectrometer// this will be networked
	name = "spectrometer"
	desc = "A huge mass spectrometer that works with laser setups."
	icon = 'icons/obj/machines/beamline64x32.dmi'
	icon_state = "spectrometer-0"

/obj/machinery/networked/beamline/concentrator// uses a lot of power to reduce the wavelength and increase the range
	name = "magnetic stabilizer"
	desc = "A concentrates laser beams that pass through it"
	icon = 'icons/obj/machines/beamline64x32.dmi'
	icon_state = "beam_concentrator"
	modmin = 0.1
	modmax = 1
	laser_act(wavelength , power  , particle,range)
		if(powered())
			use_power(power * (1/wavelength) * ((1/modifier)**2)*20)//uses lots of power
			src.beam = new /obj/beam/custom(get_turf(src), range * modifier , power , wavelength * modifier)
			src.beam.dir = src.dir
		else
			src.beam = new /obj/beam/custom(get_turf(src), range * 0.9 , power - 1 , wavelength * 1.5)//no cheating
			src.beam.dir = src.dir
/obj/machinery/networked/neutrino_detector//produces power and detects neutrinos emitted by the laser interacting with stuff.
// code for the laser driver
//laser
/datum/computer/file/mainframe_program/driver/laser
	name = "resles_cont"
	setup_processes = 1
	size = 8
	var/tmp/waiting_status = 0
	var/tmp/ret_string = ""//the string that returns info requested for the driver
	status = "NAN"
	disposing()
		..()

	New()
		..()

	initialize()
		if (..())
			return 1

	terminal_input(var/data, var/datum/computer/file/file)
		if (..() || !initialized)
			return
		var/list/datalist = params2list(data)
		switch(lowertext(datalist["command"]))
			if ("status")
				if(waiting_status)
					waiting_status = 0
					change_val(text2num(datalist["value"]),text2num(datalist["id"]))
					return
				else
					status = "Name:[datalist["name"]] [datalist["value_name"]]:[datalist["value"]]"
					ret_string = status
					return
			if ("disconnect")
				message_user("Component ID:[datalist["id"]] disconnected from the controller<br>")
				return
			if("list")
				var/found = 0
				ret_string += "Detected devices:<br>"
				for(var/i = 0 , i < datalist.len ,i++)
					if(datalist["ls[i]"])//I do love byond sometimes , this is a neat as fuck feature
						ret_string += "ID:[datalist["ls[i]"]]<br>"
						found = 1
				if(!found)
					ret_string += "<br>ERROR: No devices detected"
				ret_string += "END<br>"
			if("failure")
				ret_string += "<br>ERROR: Incorrect format"
			if("limited")
				ret_string += "<br>ERROR: Vale out of range"
		return

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..() || !data["command"])
			return FAIL
		if(!data["id"])
			return FAIL
		switch(data["command"])
			if("set")
				if(data["value"])
					message_device("command=set&value=[data["value"]]&id=data["id"]")
			if("increase")
				message_device("command=status&id=data["id"]")
				waiting_status = 1
			if("decrease")
				message_device("command=status&id=data["id"]")
				waiting_status = 1
			if("off")
				message_device("command=off&id=data["id"]")
			if("fetch_status")
				message_device("command=status&id=data["id"]")
			if("detect")
				message_device("commend=detect")//tells the controller to detect devices
			if("fetch_list")
				message_device("command=list")
			if("print_msg")
				var/ret_string = src.ret_string
				src.ret_string = ""
				return ret_string
			else
				return FAIL
			return OK
		return FAIL
	proc/change_val(var/value = 0,var/id)
		message_device("command=set&value=[value]&id=[id]")
/datum/computer/file/mainframe_program/laser_control
	name = "Laser Control"
	size = 8

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initparams || !initlist.len)
			message_user("No parameters , terminating program")
			mainframe_prog_exit
			return

		var/driver_id = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dtag"="reslad_cont"))
		if (!(driver_id & ESIG_DATABIT))
			message_user("ERROR: Could not detect laser driver.")
			mainframe_prog_exit
			return
		driver_id &= ~ESIG_DATABIT
		var/command = lowertext(initlist[1])
		switch(command)
			if ("status")
				if(!initlist[2])
					message_user("Missing ID parameter")
					mainframe_prog_exit
					return
				var/stat = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driver_id, "dcommand"="fetch_status","id"=initlist[2]))
				message_user("Fetching status...")
				spawn(6)//wait for the thing to respond
					if(!stat)
						message_user("Unable to get status")
						mainframe_prog_exit
						return
					else
						message_user(signal_program(1,list("command"=DWAINE_COMMAND_DMSG, "target"=driver_id, "dcommand"="print_msg")))
						mainframe_prog_exit
						return

			if ("increase","incr","+")
				if(initlist[2])
					signal_program(1,list("command"=DWAINE_COMMAND_DMSG,"target"=driver_id,"dcommand"="increase","id"=initlist[2]))
				else
					message_user("Please enter the component ID as the first parameter")
				return
			if ("decrease","decr","-")
				if(initlist[2])
					signal_program(1,list("command"=DWAINE_COMMAND_DMSG,"target"=driver_id,"dcommand"="decrease","id"=initlist[2]))
				else
					message_user("Please enter the component ID as the first parameter")
				return
			if ("list","ls")
				signal_program(1,list("command"=DWAINE_COMMAND_DMSG,"target"=driver_id,"dcommand"="fetch_list"))
				message_user("Fetching list...")
				spawn(6)
					message_user(signal_program(1,list("command"=DWAINE_COMMAND_DMSG,"target" = driver_id,"dcommand"="print_msg")))
					mainframe_prog_exit
					return
			if ("set")
				if(initlist[2] && initlist[3])
					signal_program(1,list("command"=DWAINE_COMMAND_DMSG,"target"= driver_id,"dcommand"="set","id"=initlist[2],"value"=initlist[3]))
				else
					message_user("Invalid paramters")
				mainframe_prog_exit
				return
			if("detect","det")
				signal_program(1,list("command"=DWAINE_COMMAND_DMSG,"target" = driver_id,"dcommand"="detect"))
				spawn(6)
					message_user(signal_program(1,list("command"=DWAINE_COMMAND_DMSG,"target"=driver_id,"dcommand"="print_msg")))
				mainframe_prog_exit
				return
			else
				message_user("Unknown command argument.")

		mainframe_prog_exit
		return

	input_text(var/text) //We're only going to see this if they are at a login prompt and type something else. Assumedly that is because they want to exit (Or had a typo)
		mainframe_prog_exit
		return


