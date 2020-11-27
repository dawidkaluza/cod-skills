#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/ammo>

native cod_get_user_coins(id);
native cod_set_user_coins(id, value);

new g_healthBonus[MAX_PLAYERS + 1][COD_SKILLS];
new g_curHealthBonus[MAX_PLAYERS + 1];

new g_expBonus[MAX_PLAYERS + 1][COD_SKILLS];
new g_curExpBonus[MAX_PLAYERS + 1];

new g_coinsBonus[MAX_PLAYERS + 1][COD_SKILLS];
new g_curCoinsBonus[MAX_PLAYERS + 1];

new Float:g_ammoBonus[MAX_PLAYERS + 1][COD_SKILLS];
new Float:g_curAmmoBonus[MAX_PLAYERS + 1];

public plugin_init() {
    register_plugin("Cod Skill - Kill bonuses", "1.0", "d0naciak.pl");
    RegisterHam(Ham_Killed, "player", "fw_Killed_Post", 1);
}

public fw_Killed_Post(id, att, shGb) {
    if (!is_user_alive(att) || get_user_team(id) == get_user_team(att)) {
        return HAM_IGNORED;
    }

    if(g_curHealthBonus[att]) {
        fm_set_user_health(
            att, min(cod_get_user_health(att) + 100, get_user_health(att) + g_curHealthBonus[att])
        );
    }

    if(g_curExpBonus[att]) {
        cod_set_user_xp(att, cod_get_user_xp(att) + g_curExpBonus[att]);
    }

    if(g_curCoinsBonus[att]) {
        cod_set_user_coins(att, cod_get_user_coins(att) + g_curCoinsBonus[att]);
    }

    if(g_curAmmoBonus[att]) {
        new clip;
        new weapon = get_user_weapon(att, clip);
        if(MAX_CLIP[weapon] > 2) {
            SetPlayerClip(
                att, 
                min(clip + floatround(MAX_CLIP[weapon] * g_curAmmoBonus[att]), MAX_CLIP[weapon])
            );
        }
    }

    return HAM_IGNORED;
}

public plugin_natives() {
    register_library("cod_skill_killBonuses");

    register_native("Cod_SetPlayerHealthBonusForKill", "Native_SetPlayerHealthBonusForKill");
    register_native("Cod_GetPlayerHealthBonusForKill", "Native_GetPlayerHealthBonusForKill");

    register_native("Cod_SetPlayerExpBonusForKill", "Native_SetPlayerExpBonusForKill");
    register_native("Cod_GetPlayerExpBonusForKill", "Native_GetPlayerExpBonusForKill");

    register_native("Cod_SetPlayerCoinsBonusForKill", "Native_SetPlayerCoinsBonusForKill");
    register_native("Cod_GetPlayerCoinsBonusForKill", "Native_GetPlayerCoinsBonusForKill");

    register_native("Cod_SetPlayerAmmoBonusForKill", "Native_SetPlayerAmmoBonusForKill");
    register_native("Cod_GetPlayerAmmoBonusForKill", "Native_GetPlayerAmmoBonusForKill");
}

//Natives
public Native_SetPlayerHealthBonusForKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_healthBonus[id][skill] = get_param(3);
    g_curHealthBonus[id] = SumValues(g_healthBonus[id], COD_SKILLS);
}

public Native_GetPlayerHealthBonusForKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_healthBonus[id][skill];
}

public Native_SetPlayerExpBonusForKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_expBonus[id][skill] = get_param(3);
    g_curExpBonus[id] = SumValues(g_expBonus[id], COD_SKILLS);
}

public Native_GetPlayerExpBonusForKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_expBonus[id][skill];
}

public Native_SetPlayerCoinsBonusForKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_coinsBonus[id][skill] = get_param(3);
    g_curCoinsBonus[id] = SumValues(g_coinsBonus[id], COD_SKILLS);
}

public Native_GetPlayerCoinsBonusForKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_coinsBonus[id][skill];
}

public Native_SetPlayerAmmoBonusForKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_ammoBonus[id][skill] = get_param_f(3);
    new bestId = FindHighestFloatValueIfExist(g_ammoBonus[id], COD_SKILLS);
    if (bestId == -1) {
        g_curAmmoBonus[id] = 0.0;
    } else {
        g_curAmmoBonus[id] = g_ammoBonus[id][bestId];
    }
}

public Float:Native_GetPlayerAmmoBonusForKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_ammoBonus[id][skill];
}