#if defined _cod_skills_basics_ammo_included
  #endinput
#endif
#define _cod_skills_basics_ammo_included

#include <amxmodx>
#include <fakemeta>

#define FILL_AMMO -1
new const MAX_CLIP[] = {
    -1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 
    10, 30, 100,  8, 30,  30, 20,  2,  7, 30, 30, -1,  50
};
new const MAX_BPAMMO[] = {
    -1, 52, 0, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 
    120, 200, 32, 90, 120, 90, 2, 35, 90, 90, 0, 100, -1, -1
};

stock SetPlayerClip(id, clip, weapon = 0) {
    if (!weapon) {
        weapon = get_user_weapon(id);
    }

    if (clip == FILL_AMMO) {
        clip = MAX_CLIP[weapon];
    }

    new weaponName[32], weaponEnt;
    get_weaponname(weapon, weaponName, charsmax(weaponName));
    while ((weaponEnt = engfunc(EngFunc_FindEntityByString, weaponEnt, "classname", weaponName)) != 0) {
        if (pev(weaponEnt, pev_owner) == id) {
            set_pdata_int(weaponEnt, 51, clip, 4);
            return 1;
        }
    }

    return -1;
}

stock GetPlayerClip(id, weapon = 0) {
    if (!weapon) {
        weapon = get_user_weapon(id);
    }
    
    new weaponName[32], weaponEnt;
    get_weaponname(weapon, weaponName, charsmax(weaponName));
    while ((weaponEnt = engfunc(EngFunc_FindEntityByString, weaponEnt, "classname", weaponName)) != 0) {
        if (pev(weaponEnt, pev_owner) == id) {
            return get_pdata_int(weaponEnt, 51, 4);
        }
    }

    return -1;
}