#define MESA_ATTACHMENTS list(/obj/item/attachment/silencer, /obj/item/attachment/laser_sight, /obj/item/attachment/rail_light, /obj/item/attachment/bayonet, /obj/item/attachment/energy_bayonet, /obj/item/attachment/ammo_counter,/obj/item/attachment/gun)
#define MESA_ATTACH_SLOTS list(ATTACHMENT_SLOT_MUZZLE = 1, ATTACHMENT_SLOT_SCOPE = 1, ATTACHMENT_SLOT_RAIL = 1)

//########### RIFLES ###########//
/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle
	name = "AR-2 \"Pulse Rifle\""
	desc = "The Overwatch Standard Issue Pulse Rifle, also simply known as the Pulse Rifle or AR-2. Nobody is entirely sure on the mechanisms of any part for this weapon."

	icon = 'icons/obj/guns/manufacturer/black_mesa/48x32.dmi'
	lefthand_file = 'icons/obj/guns/manufacturer/black_mesa/lefthand.dmi'
	righthand_file = 'icons/obj/guns/manufacturer/black_mesa/righthand.dmi'
	mob_overlay_icon = 'icons/obj/guns/manufacturer/black_mesa/onmob.dmi'
	icon_state = "pulserifle"
	item_state = "pulserifle"
	muzzleflash_iconstate = "muzzle_flash_pulse"

	default_ammo_type = /obj/item/ammo_box/magazine/ar2_pulse_rifle
	allowed_ammo_types = list(
		/obj/item/ammo_box/magazine/ar2_pulse_rifle,
	)
	var/obj/item/gun/energy/laser/ar2_pulse_rifle_secondary/secondary

	gun_firenames = list(FIREMODE_FULLAUTO = "full auto", FIREMODE_OTHER = "alternate fire")
	gun_firemodes = list(FIREMODE_FULLAUTO, FIREMODE_OTHER)
	default_firemode = FIREMODE_FULLAUTO
	show_magazine_on_sprite = TRUE
	doesnt_keep_bullet = TRUE

	load_sound = 'sound/weapons/gun/blackmesa/ar2_reload.ogg'
	load_empty_sound = 'sound/weapons/gun/blackmesa/ar2_reload.ogg'
	eject_sound = 'sound/weapons/gun/blackmesa/ar2_reload_push.ogg'
	eject_empty_sound = 'sound/weapons/gun/blackmesa/ar2_reload_rotate.ogg'

	fire_sound = 'sound/weapons/gun/blackmesa/fire1.ogg'
	manufacturer = MANUFACTURER_COMBINE_OVERWATCH

	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE

	burst_size = 3
	burst_delay = 0.1 SECONDS
	fire_delay = 0.14 SECONDS
	spread = 1
	spread_unwielded = 8
	wield_slowdown = LIGHT_RIFLE_SLOWDOWN

	valid_attachments = MESA_ATTACHMENTS
	slot_available = MESA_ATTACH_SLOTS
	slot_offsets = list(
		ATTACHMENT_SLOT_MUZZLE = list(
			"x" = 42,
			"y" = 17,
		),
		ATTACHMENT_SLOT_SCOPE = list(
			"x" = 21,
			"y" = 24,
		),
		ATTACHMENT_SLOT_RAIL = list(
			"x" = 30,
			"y" = 15,
		)
	)

NO_MAG_GUN_HELPER(automatic/assault/ar2_pulse_rifle)

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/Initialize()
	. = ..()
	secondary = new /obj/item/gun/energy/laser/ar2_pulse_rifle_secondary(src)
	RegisterSignal(secondary, COMSIG_ATOM_UPDATE_ICON, PROC_REF(secondary_update_icon))
	SEND_SIGNAL(secondary, COMSIG_GUN_DISABLE_AUTOFIRE)
	update_appearance()

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/do_autofire(datum/source, atom/target, mob/living/shooter, params)
	var/current_firemode = gun_firemodes[firemode_index]
	if(current_firemode != FIREMODE_OTHER)
		return ..()
	return secondary.do_autofire(source, target, shooter, params)

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/do_autofire_shot(datum/source, atom/target, mob/living/shooter, params)
	var/current_firemode = gun_firemodes[firemode_index]
	if(current_firemode != FIREMODE_OTHER)
		return ..()
	return secondary.do_autofire_shot(source, target, shooter, params)

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	var/current_firemode = gun_firemodes[firemode_index]
	if(current_firemode != FIREMODE_OTHER)
		if(!secondary.latch_closed && secondary.cell && prob(65))
			to_chat(user, span_warning("[src]'s cell falls out!"))
			secondary.eject_cell()
		return ..()
	return secondary.process_fire(target, user, message, params, zone_override, bonus_spread)

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/can_shoot()
	var/current_firemode = gun_firemodes[firemode_index]
	if(current_firemode != FIREMODE_OTHER)
		return ..()
	return secondary.can_shoot()

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/afterattack(atom/target, mob/living/user, flag, params)
	var/current_firemode = gun_firemodes[firemode_index]
	if(current_firemode != FIREMODE_OTHER)
		return ..()
	return secondary.afterattack(target, user, flag, params)

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/attackby(obj/item/attack_obj, mob/user, params)
	if(istype(attack_obj, /obj/item/stock_parts/cell/gun))
		return secondary.attackby(attack_obj, user, params)
	return ..()

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/attack_hand(mob/user)
	var/current_firemode = gun_firemodes[firemode_index]
	if(current_firemode == FIREMODE_OTHER && loc == user && user.is_holding(src) && secondary.cell && !secondary.latch_closed)
		secondary.eject_cell(user)
		return
	if(current_firemode == FIREMODE_OTHER && loc == user && user.is_holding(src) && secondary.cell && secondary.latch_closed)
		to_chat(user, span_warning("The cell retainment clip is latched!"))
		return
	return ..()

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/unique_action(mob/living/user)
	var/current_firemode = gun_firemodes[firemode_index]
	if(current_firemode == FIREMODE_OTHER)
		if(secondary.latch_closed)
			to_chat(user, span_notice("You start to unlatch the [src]'s power cell retainment clip..."))
			if(do_after(user, secondary.latch_toggle_delay, src, IGNORE_USER_LOC_CHANGE))
				to_chat(user, span_notice("You unlatch [src]'s power cell retainment clip " + span_red("OPEN") + "."))
				playsound(src, 'sound/weapons/gun/blackmesa/ar2_reload_rotate.ogg', 50, FALSE)
				secondary.tac_reloads = TRUE
				secondary.latch_closed = FALSE
				update_appearance()
				return
		else
			to_chat(user, span_warning("You start to latch the [src]'s power cell retainment clip..."))
			if (do_after(user, secondary.latch_toggle_delay, src, IGNORE_USER_LOC_CHANGE))
				to_chat(user, span_notice("You latch [src]'s power cell retainment clip " + span_green("CLOSED") + "."))
				playsound(src, 'sound/weapons/gun/blackmesa/ar2_reload_push.ogg', 50, FALSE)
				secondary.tac_reloads = FALSE
				secondary.latch_closed = TRUE
				update_appearance()
				return
	else
		return ..()

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/on_wield(obj/item/source, mob/user)
	wielded = TRUE
	secondary.wielded = TRUE
	INVOKE_ASYNC(src, PROC_REF(do_wield), user)

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/do_wield(mob/user)
	. = ..()
	secondary.wielded_fully = wielded_fully

/// triggered on unwield of two handed item
/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/on_unwield(obj/item/source, mob/user)
	. = ..()
	secondary.wielded_fully = FALSE
	secondary.wielded = FALSE

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/proc/secondary_update_icon()
	update_appearance()

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/process_other(atom/target, mob/living/user, message = TRUE, flag, params = null, zone_override = "", bonus_spread = 0)
	secondary.pre_fire(target, user, message, flag, params, zone_override, bonus_spread)


/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/get_cell()
	return secondary.get_cell()

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/update_overlays()
	. = ..()
	//handle laser gunn overlays
	if(!secondary)
		return
	var/ratio = secondary.get_charge_ratio()
	if(ratio == 0)
		. += "[icon_state]_chargeempty"
	else
		. += "[icon_state]_charge[ratio]"
	if(secondary.cell)
		. += "[icon_state]_cell"
	if(ismob(loc))
		var/mutable_appearance/latch_overlay
		latch_overlay = mutable_appearance('icons/obj/guns/cell_latch.dmi')
		if(secondary.latch_closed)
			if(secondary.cell)
				latch_overlay.icon_state = "latch-on-full"
			else
				latch_overlay.icon_state = "latch-on-empty"
		else
			if(secondary.cell)
				latch_overlay.icon_state = "latch-off-full"
			else
				latch_overlay.icon_state = "latch-off-empty"
		. += latch_overlay


/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/toggle_safety(mob/user, silent=FALSE)
	. = ..()
	secondary.safety = safety

/obj/item/gun/ballistic/automatic/assault/ar2_pulse_rifle/examine(mob/user)
	. = ..()
	if(!secondary.internal_magazine)
		. += "The cell retainment latch is [secondary.latch_closed ? span_green("CLOSED") : span_red("OPEN")]. Use the Unique Action Key to toggle the latch while on laser mode. By default, this is <b>space</b>."
	var/obj/item/ammo_casing/energy/shot = secondary.ammo_type[select]
	if(secondary.cell)
		. += "\The [name]'s cell has [secondary.cell.percent()]% charge remaining."
		. += "\The [name] has [round(secondary.cell.charge/shot.e_cost)] shots remaining on <b>[shot.select_name]</b> mode."
	else
		. += span_notice("\The [name] doesn't seem to have a cell!")


/obj/item/ammo_box/magazine/ar2_pulse_rifle
	name = "Pulse Rifle magazine (Pulse Round)"
	desc = "A large, strangely complex but surprisingly light magazine. Capable of holding up to thirty liquid-energy cells."
	icon_state = "pulserifle_mag"
	base_icon_state = "pulserifle_mag"
	ammo_type = /obj/item/ammo_casing/caseless/pulse_round
	caliber = "pulse round"
	max_ammo = 30

// energy ball
/obj/item/gun/energy/laser/ar2_pulse_rifle_secondary
	name = "secondary pulse rifle gun"
	desc = "You shouldn't see this."
	fire_sound = 'sound/weapons/gun/blackmesa/alternate_fire.ogg'
	muzzleflash_iconstate = "muzzle_flash"
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/laser/energyball)
	default_ammo_type = list(/obj/item/stock_parts/cell/gun/darkmatter)
	allowed_ammo_types = list(/obj/item/stock_parts/cell/gun/darkmatter)
	fire_delay = 2 SECONDS
	gun_firemodes = list(FIREMODE_SEMIAUTO)
	default_firemode = FIREMODE_SEMIAUTO
	latch_toggle_delay = 0.6 SECONDS
	valid_attachments = list()

	spread_unwielded = 20

/obj/item/ammo_casing/energy/laser/energyball
	projectile_type = /obj/projectile/beam/laser/energyball
	select_name = "kill"
	e_cost = 50000
	delay = 1 SECONDS

/obj/projectile/beam/laser/energyball
	name = "energy orb"
	icon_state = "energy_orb"
	bullet_identifier = "energy orb"

	hitsound = 'sound/weapons/gun/blackmesa/energy_disintegrate4.ogg'
	hitsound_non_living = 'sound/weapons/gun/blackmesa/energy_disintegrate4.ogg'
	hitsound_glass = 'sound/weapons/gun/blackmesa/energy_disintegrate4.ogg'
	hitsound_stone = 'sound/weapons/gun/blackmesa/energy_disintegrate4.ogg'
	hitsound_metal = 'sound/weapons/gun/blackmesa/energy_disintegrate4.ogg'
	hitsound_wood = 'sound/weapons/gun/blackmesa/energy_disintegrate4.ogg'
	hitsound_snow = 'sound/weapons/gun/blackmesa/energy_disintegrate4.ogg'

	near_miss_sound = 'sound/weapons/gun/blackmesa/energy_sing_flyby1.ogg'
	ricochet_sound = 'sound/weapons/gun/blackmesa/energy_bounce1.ogg'

	ricochet_chance = 100
	ricochet_decay_chance = 1
	ricochet_decay_damage = 1
	ricochet_incidence_leeway = 0
	pass_flags = PASSTABLE //does not go through glass

/obj/projectile/beam/laser/energyball/on_hit(atom/target, blocked = FALSE)
	..()
	if(isliving(target))
		var/mob/living/M = target
		M.dust()

/obj/item/stock_parts/cell/gun/darkmatter
	name = "Overwatch Darkmatter Cell"
	icon_state = "overwatch-cell"
	maxcharge = 50000
	custom_materials = list(/datum/material/glass=1000)
	chargerate = 5000
	w_class = WEIGHT_CLASS_NORMAL
