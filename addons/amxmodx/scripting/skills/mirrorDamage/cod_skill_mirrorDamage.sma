#include <amxmodx>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/damage>

//Chance to mirror damage
new g_chanceToMirrorDamage[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToMirrorDamage[MAX_PLAYERS + 1];

//Damage mirrors
new g_damageMirrorsNum[MAX_PLAYERS + 1][COD_SKILLS];
new g_curDamageMirrorsSkill[MAX_PLAYERS + 1];
new g_curDamageMirrorsNum[MAX_PLAYERS + 1];

public plugin_init() {
    register_plugin("Cod Skill - Mirror damage", "1.0", "d0naciak.pl");

    register_event("HLTV", "ev_NewRound", "a", "1=0", "2=0");
}


public plugin_natives() {
    register_library("cod_skill_mirrorDamage");

    register_native("Cod_SetPlayerChanceToMirrorDamage", "Native_SetPlayerChanceToMirrorDamage");
    register_native("Cod_GetPlayerChanceToMirrorDamage", "Native_GetPlayerChanceToMirrorDamage");

    register_native("Cod_SetPlayerDamageMirrors", "Native_SetPlayerDamageMirrors");
    register_native("Cod_GetPlayerDamageMirrors", "Native_GetPlayerDamageMirrors");
}

public ev_NewRound() {
    for (new i = 1; i <= MaxClients; i++) {
        new curSkill = g_curDamageMirrorsSkill[i];
        if (curSkill != -1) {
            g_curDamageMirrorsNum[i] = g_damageMirrorsNum[i][curSkill];
        }
    }
}

public Cod_OnTakeDamage(id, att, ent, Float:damage, damageBits) {
    if (!(damageBits & (1<<1)) || get_user_weapon(att) == CSW_KNIFE) {
        return CODDMG_IGNORE;
    }

    if (g_curDamageMirrorsNum[id]) {
        g_curDamageMirrorsNum[id] --;
        return CODDMG_MIRROR;
    }

    if (g_curChanceToMirrorDamage[id] && !random(g_curChanceToMirrorDamage[id])) {
        return CODDMG_MIRROR;
    }

    return CODDMG_IGNORE;
}

public Native_SetPlayerChanceToMirrorDamage(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToMirrorDamage[id][skill] = get_param(3);
    new bestId = FindLowestValueIfExist(g_chanceToMirrorDamage[id], COD_SKILLS);
    if (bestId == -1) {
        g_curChanceToMirrorDamage[id] = 0;
    } else {
        g_curChanceToMirrorDamage[id] = g_chanceToMirrorDamage[id][bestId];
    }
}

public Native_GetPlayerChanceToMirrorDamage(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToMirrorDamage[id][skill];
}

public Native_SetPlayerDamageMirrors(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_damageMirrorsNum[id][skill] = get_param(3);
    new bestId = FindHighestValueIfExist(g_damageMirrorsNum[id], COD_SKILLS);
    if (bestId == -1) {
        g_curDamageMirrorsSkill[id] = -1;
        g_curDamageMirrorsNum[id] = 0;
    } else {
        g_curDamageMirrorsSkill[id] = bestId;
        g_curDamageMirrorsNum[id] = g_damageMirrorsNum[id][bestId];
    }
}

public Native_GetPlayerDamageMirrors(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_damageMirrorsNum[id][skill];
}