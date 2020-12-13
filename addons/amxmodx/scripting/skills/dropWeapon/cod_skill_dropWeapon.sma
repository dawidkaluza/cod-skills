#include <amxmodx>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>

new const g_weaponSlots[] = {
    -1,
    2, //CSW_P228
    -1,
    1, //CSW_SCOUT
    4, //CSW_HEGRENADE
    1, //CSW_XM1014
    5, //CSW_C4
    1, //CSW_MAC10
    1, //CSW_AUG
    4, //CSW_SMOKEGRENADE
    2, //CSW_ELITE
    2, //CSW_FIVESEVEN
    1, //CSW_UMP45
    1, //CSW_SG550
    1, //CSW_GALIL
    1, //CSW_FAMAS
    2, //CSW_USP
    2, //CSW_GLOCK18
    1, //CSW_AWP
    1, //CSW_MP5NAVY
    1, //CSW_M249
    1, //CSW_M3
    1, //CSW_M4A1
    1, //CSW_TMP
    1, //CSW_G3SG1
    4, //CSW_FLASHBANG
    2, //CSW_DEAGLE
    1, //CSW_SG552
    1, //CSW_AK47
    3, //CSW_KNIFE
    1 //CSW_P90
}
new const DROPPEDWEAPON_CLASSNAME[] = "cod_droppedWeapon";

new g_chanceToDropWeapon[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToDropWeapon[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Drop weapon", "1.0", "d0naciak.pl");

    register_logevent("ev_RoundStart", 2, "1=Round_Start")
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1);
    RegisterHam(Ham_Touch, "info_target", "fw_Touch_Post", 1);
}

public plugin_natives() {
    register_library("cod_skill_dropWeapon");

    register_native("Cod_SetPlayerChanceToDropWeapon", "Native_SetPlayerChanceToDropWeapon");
    register_native("Cod_GetPlayerChanceToDropWeapon", "Native_GetPlayerChanceToDropWeapon");
}

public ev_RoundStart() {
    fm_remove_entity_name(DROPPEDWEAPON_CLASSNAME);
}

public fw_TakeDamage_Post(id, att, ent, Float:damage, damageBits) {
    if (!is_user_connected(att) || !is_user_alive(id) || get_user_team(id) == get_user_team(att)) {
        return HAM_IGNORED;
    }

    if (
        damageBits & (1<<1) && get_user_weapon(id) != CSW_KNIFE &&
        g_curChanceToDropWeapon[att] && !random(g_curChanceToDropWeapon[att])
    ) {
        DropWeapon(id);
    }

    return HAM_IGNORED;
}

public fw_Touch_Post(ent, id) {
    if(!pev_valid(ent) || !is_user_alive(id)) {
        return;
    }
    
    new classname[32]; 
    pev(ent, pev_classname, classname, charsmax(classname));
    if(!equal(classname, DROPPEDWEAPON_CLASSNAME) || pev(ent, pev_owner) != id) {
        return;
    }

    new weapon = pev(ent, pev_iuser1);
    new weaponsBitSum = pev(id, pev_weapons);
    if (weaponsBitSum & (1<<weapon)) {
        return;
    }

    new weaponName[32];
    get_weaponname(weapon, weaponName, charsmax(weaponName));
    new weaponEnt = fm_give_item(id, weaponName);
    if (pev_valid(weaponEnt)) {
        cs_set_weapon_ammo(weaponEnt, pev(ent, pev_iuser2));
        cs_set_user_bpammo(id, weapon, pev(ent, pev_iuser3));
    }

    fm_remove_entity(ent);
}

//Natives
public Native_SetPlayerChanceToDropWeapon(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToDropWeapon[id][skill] = get_param(3);
    new bestId = FindLowestValueIfExist(g_chanceToDropWeapon[id], COD_SKILLS);
    if (bestId == -1) {
        g_curChanceToDropWeapon[id] = 0;
    } else {
        g_curChanceToDropWeapon[id] = g_chanceToDropWeapon[id][bestId];
    }
}

public Native_GetPlayerChanceToDropWeapon(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToDropWeapon[id][skill];
}


stock DropWeapon(id) {
    new iClip, iAmmo, iWeapon;
    iWeapon = get_user_weapon(id, iClip, iAmmo);
    //Safetyyy
    if(!(1 <= iWeapon <= 30) || iWeapon == CSW_KNIFE || iWeapon == 2 || !user_has_weapon(id, iWeapon)) {
        return 0;
    }
    
    new Float:fVelocity[3], Float:fOrigin[3];
    pev(id, pev_origin, fOrigin);
    velocity_by_aim(id, 34, fVelocity);
    
    fOrigin[0] += fVelocity[0];
    fOrigin[1] += fVelocity[1];

    velocity_by_aim(id, 300, fVelocity);
    
    new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
    
    if(pev_valid(iEnt)) {
        new szModel[128], szWpnName[32];
        
        get_weaponname(iWeapon, szWpnName, 31);
        copy(szWpnName, 31, szWpnName[7]);
        replace(szWpnName, 31, "navy", "");
        formatex(szModel, 127, "models/w_%s.mdl", szWpnName);
        
        set_pev(iEnt, pev_classname, DROPPEDWEAPON_CLASSNAME);
        engfunc(EngFunc_SetModel, iEnt, szModel);
        engfunc(EngFunc_SetSize, iEnt, Float:{-2.5, -2.5, -1.5}, Float:{2.5, 2.5, 1.5});
        set_pev(iEnt, pev_movetype, MOVETYPE_TOSS);
        set_pev(iEnt, pev_solid, SOLID_TRIGGER);
        set_pev(iEnt, pev_owner, id);
        
        set_pev(iEnt, pev_origin, fOrigin);
        set_pev(iEnt, pev_velocity, fVelocity);
        
        set_pev(iEnt, pev_iuser1, iWeapon);
        set_pev(iEnt, pev_iuser2, iClip);
        set_pev(iEnt, pev_iuser3, iAmmo);
    }
    
    return ham_strip_user_weapon(id, iWeapon);
}

stock ham_strip_user_weapon(id, iCswId, iSlot = 0, bool:bSwitchIfActive = true)
{
    new iWeapon;
    if(!iSlot)
    {
        iSlot = g_weaponSlots[iCswId];
    }

    const XTRA_OFS_PLAYER = 5;
    const m_rgpPlayerItems_Slot0 = 367;

    iWeapon = get_pdata_cbase(id, m_rgpPlayerItems_Slot0 + iSlot, XTRA_OFS_PLAYER);

    const XTRA_OFS_WEAPON = 4;
    const m_pNext = 42;
    const m_iId = 43;

    while(iWeapon > 0)
    {
        if(get_pdata_int(iWeapon, m_iId, XTRA_OFS_WEAPON) == iCswId)
        {
            break;
        }
        iWeapon = get_pdata_cbase(iWeapon, m_pNext, XTRA_OFS_WEAPON);
    }
    if(iWeapon > 0)
    {
        const m_pActiveItem = 373;
        if(bSwitchIfActive && get_pdata_cbase(id, m_pActiveItem, XTRA_OFS_PLAYER) == iWeapon)
        {
            ExecuteHamB(Ham_Weapon_RetireWeapon, iWeapon);
        }
        if(ExecuteHamB(Ham_RemovePlayerItem, id, iWeapon))
        {
            user_has_weapon(id, iCswId, 0);
            ExecuteHamB(Ham_Item_Kill, iWeapon);
            return 1;
        }
    }
    return 0;
}