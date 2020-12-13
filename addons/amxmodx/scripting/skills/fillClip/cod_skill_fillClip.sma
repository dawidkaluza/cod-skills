#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/ammo>

new g_chanceToFillClip[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToFillClip[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Fill clip", "1.0", "d0naciak.pl");
    RegisterHam(Ham_Killed, "player", "fw_Killed_Post", 1);
}

public plugin_natives() {
    register_library("cod_skill_fillClip");

    register_native("Cod_SetPlayerChanceToFillClip", "Native_SetPlayerChanceToFillClip");
    register_native("Cod_GetPlayerChanceToFillClip", "Native_GetPlayerChanceToFillClip");
}

public fw_Killed_Post(id, att, shGb) {
    if (!is_user_connected(att)) {
        return HAM_IGNORED;
    }

    new inflictor = pev(id, pev_dmg_inflictor);
    if (inflictor == att && g_curChanceToFillClip[att] && !random(g_curChanceToFillClip[att])) {
        new weapon = get_user_weapon(att);
        if (CSW_ALL_GUNS & (1<<weapon)) {
            SetPlayerClip(att, FILL_AMMO, weapon);
        }
    }

    return HAM_IGNORED;
}

//Natives
public Native_SetPlayerChanceToFillClip(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToFillClip[id][skill] = get_param(3);
    new bestId = FindLowestValueIfExist(g_chanceToFillClip[id], COD_SKILLS);
    if (bestId == -1) {
        g_curChanceToFillClip[id] = 0;
    } else {
        g_curChanceToFillClip[id] = g_chanceToFillClip[id][bestId];
    }
}

public Native_GetPlayerChanceToFillClip(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToFillClip[id][skill];
}