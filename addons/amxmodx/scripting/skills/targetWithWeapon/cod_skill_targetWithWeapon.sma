#include <amxmodx>
#include <cstrike>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/damage>

new g_chanceToKill[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1][COD_SKILLS];
new g_curChanceToKill[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1];
public plugin_init() {
    register_plugin("Cod Skill - Target with weapon", "1.0", "d0naciak.pl");
}

public plugin_natives() {
    register_library("cod_skill_targetWithWeapon");

    register_native("Cod_SetPlayerChanceToKillTargetWithWeapon", "Native_SetPlayerChanceToKillTargetWithWeapon");
    register_native("Cod_GetPlayerChanceToKillTargetWithWeapon", "Native_GetPlayerChanceToKillTargetWithWeapon");
}

public Cod_OnTakeDamage(id, att, ent, Float:damage, damageBits) {
    new weapon = get_user_weapon(id);
    if (g_curChanceToKill[att][weapon] && !random(g_curChanceToKill[att][weapon])) {
        return CODDMG_KILL;
    }

    return CODDMG_IGNORE;
}

//Natives
public Native_SetPlayerChanceToKillTargetWithWeapon(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new weapon = get_param(3);
    g_chanceToKill[id][weapon][skill] = get_param(4);
    new bestId = FindLowestValueIfExist(g_chanceToKill[id][weapon], COD_SKILLS);
    if (bestId == -1) {
        g_curChanceToKill[id][weapon] = 0;
    } else {
        g_curChanceToKill[id][weapon] = g_chanceToKill[id][weapon][bestId];
    }
}

public Native_GetPlayerChanceToKillTargetWithWeapon(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new weapon = get_param(3);
    return g_chanceToKill[id][weapon][skill];
}