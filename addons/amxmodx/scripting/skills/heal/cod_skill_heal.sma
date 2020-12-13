#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>

new g_chanceToHeal[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToHeal[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Heal", "1.0", "d0naciak.pl");
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1);
}

public plugin_natives() {
    register_library("cod_skill_heal");

    register_native("Cod_SetPlayerChanceToHeal", "Native_SetPlayerChanceToHeal");
    register_native("Cod_GetPlayerChanceToHeal", "Native_GetPlayerChanceToHeal");
}

public fw_TakeDamage_Post(id, ent, att, Float:damage, damageBits) {
    if (!is_user_connected(att) || get_user_team(id) == get_user_team(att) || !(damageBits & (1<<1))) {
        return HAM_IGNORED;
    }

    if (g_curChanceToHeal[att] && !random(g_curChanceToHeal[att])) {
        set_pev(att, pev_health, float(cod_get_user_health(att) + 100));
    }

    return HAM_IGNORED;
}

//Natives
public Native_SetPlayerChanceToHeal(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToHeal[id][skill] = get_param(3);
    new bestId = FindLowestValueIfExist(g_chanceToHeal[id], skill);
    if (bestId == -1) {
        g_curChanceToHeal[id] = 0;
    } else {
        g_curChanceToHeal[id] = g_chanceToHeal[id][bestId];
    }
}

public Native_GetPlayerChanceToHeal(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToHeal[id][skill];
}