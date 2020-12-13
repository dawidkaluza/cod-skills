#include <amxmodx>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>

new g_chanceToSwitchToKnife[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToSwitchToKnife[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Switch weapon", "1.0", "d0naciak.pl");
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1);
}

public plugin_natives() {
    register_library("cod_skill_switchWeapon");

    register_native("Cod_SetPlayerChanceToSwitchToKnife", "Native_SetPlayerChanceToSwitchToKnife");
    register_native("Cod_GetPlayerChanceToSwitchToKnife", "Native_GetPlayerChanceToSwitchToKnife");
}

public fw_TakeDamage_Post(id, ent, att, Float:damage, damageBits) {
    if (!is_user_connected(att) || get_user_team(id) == get_user_team(att) || !(damageBits & (1<<1))) {
        return HAM_IGNORED;
    }

    if (g_curChanceToSwitchToKnife[att] && !random(g_curChanceToSwitchToKnife[att])) {
        engclient_cmd(id, "weapon_knife");
    }

    return HAM_IGNORED;
}

//Natives
public Native_SetPlayerChanceToSwitchToKnife(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToSwitchToKnife[id][skill] = get_param(3);
    new bestId = FindLowestValueIfExist(g_chanceToSwitchToKnife[id], skill);
    if (bestId == -1) {
        g_curChanceToSwitchToKnife[id] = 0;
    } else {
        g_curChanceToSwitchToKnife[id] = g_chanceToSwitchToKnife[id][bestId];
    }
}

public Native_GetPlayerChanceToSwitchToKnife(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToSwitchToKnife[id][skill];
}