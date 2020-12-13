#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/damage>

new g_chanceToAvoidBullet[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToAvoidBullet[MAX_PLAYERS + 1];

new g_chanceToAvoidHeadshot[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToAvoidHeadshot[MAX_PLAYERS + 1];

new g_chanceToAvoidGrenade[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToAvoidGrenade[MAX_PLAYERS + 1];

new g_bulletsNumToAvoid[MAX_PLAYERS + 1][COD_SKILLS];
new g_curPlayerBulletsNumToAvoidSkill[MAX_PLAYERS + 1];
new g_curBulletsNumToAvoid[MAX_PLAYERS + 1];

new bool:g_avoidDamageByWeapon[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1][COD_SKILLS];
new bool:g_curAvoidDamageByWeapon[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1];
public plugin_init() {
    register_plugin("Cod Skill - Avoid damage", "1.0", "d0naciak.pl");
    register_logevent("ev_RoundStart", 2, "1=Round_Start");
}

public plugin_natives() {
    register_library("cod_skill_avoidDamage");

    register_native("Cod_SetPlayerChanceToAvoidBullet", "Native_SetPlayerChanceToAvoidBullet");
    register_native("Cod_GetPlayerChanceToAvoidBullet", "Native_SetPlayerChanceToAvoidBullet");
    
    register_native("Cod_SetPlayerChanceToAvoidHeadshot", "Native_SetPlayerChanceToAvoidHeadshot");
    register_native("Cod_GetPlayerChanceToAvoidHeadshot", "Native_GetPlayerChanceToAvoidHeadshot");

    register_native("Cod_SetPlayerChanceToAvoidGrenade", "Native_SetPlayerChanceToAvoidGrenade");
    register_native("Cod_GetPlayerChanceToAvoidGrenade", "Native_GetPlayerChanceToAvoidGrenade");
    
    register_native("Cod_SetPlayerBulletsNumToAvoid", "Native_SetPlayerBulletsNumToAvoid");
    register_native("Cod_GetPlayerBulletsNumToAvoid", "Native_GetPlayerBulletsNumToAvoid");
    
    register_native("Cod_SetPlayerAvoidDamageByWeapon", "Native_SetPlayerAvoidDamageByWeapon");
    register_native("Cod_GetPlayerAvoidDamageByWeapon", "Native_GetPlayerAvoidDamageByWeapon");
}

public ev_RoundStart() {
    new skill;
    for (new i = 1; i <= MaxClients; i++) {
        if (!is_user_connected(i)) {
            continue;
        }

        skill = g_curPlayerBulletsNumToAvoidSkill[i];
        if (skill != -1) {
            g_curBulletsNumToAvoid[i] = g_bulletsNumToAvoid[i][skill];
        }
    }
}

public Cod_OnTakeDamage(id, att, ent, Float:damage, damageBits) {
    if (damageBits & (1<<1)) {
        new weapon = get_user_weapon(att);
        if (weapon && g_curAvoidDamageByWeapon[id][weapon]) {
            return CODDMG_AVOID;
        }

        if (g_curBulletsNumToAvoid[id]) {
            g_curBulletsNumToAvoid[id] --;
            return CODDMG_AVOID;
        }

        if (g_curChanceToAvoidBullet[id] && !random(g_curChanceToAvoidBullet[id])) {
            return CODDMG_AVOID;
        }

        if (get_pdata_int(id, 75, 5) == HIT_HEAD && g_curChanceToAvoidHeadshot[id] && !random(g_curChanceToAvoidHeadshot[id])) {
            return CODDMG_AVOID;
        }
    } else if (damageBits & (1<<24)) {
        if (g_curAvoidDamageByWeapon[id][CSW_HEGRENADE]) {
            return CODDMG_AVOID;
        }
        
        if (g_curChanceToAvoidGrenade[id] && !random(g_curChanceToAvoidGrenade[id])) {
            return CODDMG_AVOID;
        }
    }

    return CODDMG_IGNORE;
}

//Natives
public Native_SetPlayerChanceToAvoidBullet(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToAvoidBullet[id][skill] = get_param(3);
    new bestId = FindLowestValueIfExist(g_chanceToAvoidBullet[id], COD_SKILLS);
    if (bestId == -1) {
        g_curChanceToAvoidBullet[id] = 0;
    } else {
        g_curChanceToAvoidBullet[id] = g_chanceToAvoidBullet[id][bestId];
    }
}

public Native_GetPlayerChanceToAvoidBullet(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToAvoidBullet[id][skill];
}

public Native_SetPlayerChanceToAvoidHeadshot(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToAvoidHeadshot[id][skill] = get_param(3);
    new bestId = FindLowestValueIfExist(g_chanceToAvoidHeadshot[id], COD_SKILLS);
    if (bestId == -1) {
        g_curChanceToAvoidHeadshot[id] = 0;
    } else {
        g_curChanceToAvoidHeadshot[id] = g_chanceToAvoidHeadshot[id][bestId];
    }
}

public Native_GetPlayerChanceToAvoidHeadshot(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToAvoidHeadshot[id][skill];
}

public Native_SetPlayerChanceToAvoidGrenade(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToAvoidGrenade[id][skill] = get_param(3);
    new bestId = FindLowestValueIfExist(g_chanceToAvoidGrenade[id], COD_SKILLS);
    if (bestId == -1) {
        g_curChanceToAvoidGrenade[id] = 0;
    } else {
        g_curChanceToAvoidGrenade[id] = g_chanceToAvoidGrenade[id][bestId];
    }
}

public Native_GetPlayerChanceToAvoidGrenade(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToAvoidGrenade[id][skill];
}

public Native_SetPlayerBulletsNumToAvoid(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_bulletsNumToAvoid[id][skill] = get_param(3);
    g_curPlayerBulletsNumToAvoidSkill[id] = FindHighestValueIfExist(g_bulletsNumToAvoid[id], COD_SKILLS);
}

public Native_GetPlayerBulletsNumToAvoid(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_bulletsNumToAvoid[id][skill];
}

public Native_SetPlayerAvoidDamageByWeapon(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new weapon = get_param(3);
    g_avoidDamageByWeapon[id][weapon][skill] = bool:get_param(4);
    g_curAvoidDamageByWeapon[id][weapon] = FindTrueBooleanIfExist(g_avoidDamageByWeapon[id][weapon], COD_SKILLS);
}

public Native_GetPlayerAvoidDamageByWeapon(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new weapon = get_param(3);
    return g_avoidDamageByWeapon[id][weapon][skill];
}