//BATMAN! - Yeah - well not all of his powers or it'd be unfair...

/* CVARS - copy and paste to shconfig.cfg

//Batman
batman_level 0
batman_health 125		//default 125
batman_armor 125		//defualt 125

*/

/*
* v1.17 - JTP10181 - 07/23/04
*       - Fixed issue where you could get zoomed in on other primaries if combined with punisher
*
* 5/17 - Took out ammo give to test for a bug
*        + Punisher gets unlimited ammo - so this is desired not to make
*        batman so powerful.  Batman is split between Batman and Punisher
*/

#include <superheromod>

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Batman"
new bool:gHasBatman[SH_MAXSLOTS+1]
new gCurrentWeapon[SH_MAXSLOTS+1]
new gmsgSetFOV

#define giveTotal 8
new weapArray[giveTotal] = {
	CSW_FLASHBANG,
	CSW_SMOKEGRENADE,
	CSW_DEAGLE,
	CSW_MP5NAVY,
	CSW_XM1014,
	CSW_SG552,
	CSW_AWP,
	CSW_M4A1
}

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Batman", SH_VERSION_STR, "{HOJ} Batman/JTP10181")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel = register_cvar("batman_level", "0")
	new pcvarHealth = register_cvar("batman_health", "125")
	new pcvarArmor = register_cvar("batman_armor", "125")

	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Utility Belt", "Extra Weapons and HP/AP - Buy the Ammo or Use with Punisher")
	sh_set_hero_hpap(gHeroID, pcvarHealth, pcvarArmor)
	sh_set_hero_shield(gHeroID, true)

	// REGISTER EVENTS THIS HERO WILL RESPOND TO!
	register_event("CurWeapon", "change_weapon", "be", "1=1")

	gmsgSetFOV = get_user_msgid("SetFOV")
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	switch(mode) {
		case SH_HERO_ADD: {
			gHasBatman[id] = true
			batman_giveweapons(id)
		}
		case SH_HERO_DROP: {
			gHasBatman[id] = false
			batman_dropweapons(id)
		}
	}

	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if ( gHasBatman[id] ) {
		batman_giveweapons(id)
	}
}
//----------------------------------------------------------------------------------------------
batman_giveweapons(id)
{
	if ( !is_user_alive(id) ) return

	for ( new x = 0; x < giveTotal; x++ ) {
		sh_give_weapon(id, weapArray[x])
	}

	// Give CTs a Defuse Kit
	if ( cs_get_user_team(id) == CS_TEAM_CT ) sh_give_item(id, "item_thighpack")
}
//----------------------------------------------------------------------------------------------
batman_dropweapons(id)
{
	if ( !is_user_alive(id) ) return

	// Start at 2 since 0 and 1 are nades that can not be dropped
	for ( new x = 2; x < giveTotal; x++ ) {
		sh_drop_weapon(id, weapArray[x], true)
	}
}
//----------------------------------------------------------------------------------------------
public change_weapon(id)
{
	if ( !sh_is_active() || !gHasBatman[id] ) return

	new weaponid = read_data(2)

	if ( gCurrentWeapon[id] != weaponid ) {
		gCurrentWeapon[id] = weaponid
		// This avoids some issues with shotguns being zoomed, and maybe other weapons
		batman_zoomout(id)
	}
}
//----------------------------------------------------------------------------------------------
batman_zoomout(id)
{
	if ( !is_user_alive(id) ) return

	message_begin(MSG_ONE, gmsgSetFOV, _, id)
	write_byte(90)	//not Zooming
	message_end()
}
//----------------------------------------------------------------------------------------------
public client_connect(id)
{
	gHasBatman[id] = false
}
//----------------------------------------------------------------------------------------------