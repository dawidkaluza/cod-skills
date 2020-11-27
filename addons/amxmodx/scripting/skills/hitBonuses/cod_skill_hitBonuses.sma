#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>

new g_healthBonus[MAX_PLAYERS + 1][COD_SKILLS];
new g_curHealthBonus[MAX_PLAYERS + 1];

new g_expBonus[MAX_PLAYERS + 1][COD_SKILLS];
new g_curExpBonus[MAX_PLAYERS + 1];

new g_headshotHealthBonus[MAX_PLAYERS + 1][COD_SKILLS];
new g_curHeadshotHealthBonus[MAX_PLAYERS + 1];

new g_headshotExpBonus[MAX_PLAYERS + 1][COD_SKILLS];
new g_curHeadshotExpBonus[MAX_PLAYERS + 1];

public plugin_init() {
    register_plugin("Cod Skill - Hit bonuses", "1.0", "d0naciak.pl");
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1);
}

public plugin_natives() {
    register_library("cod_skill_hitBonuses");

    register_native("Cod_SetPlayerHealthBonusForHitTarget", "Native_SetPlayerHealthBonusForHitTarget");
    register_native("Cod_GetPlayerHealthBonusForHitTarget", "Native_GetPlayerHealthBonusForHitTarget");

    register_native("Cod_SetPlayerExpBonusForHitTarget", "Native_SetPlayerExpBonusForHitTarget");
    register_native("Cod_SetPlayerExpBonusForHitTarget", "Native_GetPlayerExpBonusForHitTarget");

    register_native("Cod_SetPlayerHealthBonusForHeadshot", "Native_SetPlayerHealthBonusForHeadshot");
    register_native("Cod_GetPlayerHealthBonusForHeadshot", "Native_GetPlayerHealthBonusForHeadshot");

    register_native("Cod_SetPlayerExpBonusForHeadshot", "Native_SetPlayerExpBonusForHeadshot");
    register_native("Cod_GetPlayerExpBonusForHeadshot", "Native_GetPlayerExpBonusForHeadshot");
}

//Natives
public Native_SetPlayerHealthBonusForHitTarget(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_healthBonus[id][skill] = get_param(3);
    g_curHealthBonus[id] = SumValues(g_healthBonus[id], COD_SKILLS);
}

public Native_GetPlayerHealthBonusForHitTarget(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_healthBonus[id][skill];
}

public Native_SetPlayerExpBonusForHitTarget(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_expBonus[id][skill] = get_param(3);
    g_curExpBonus[id] = SumValues(g_expBonus[id], COD_SKILLS);
}

public Native_GetPlayerExpBonusForHitTarget(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_expBonus[id][skill];
}

public Native_SetPlayerHealthBonusForHeadshot(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_headshotHealthBonus[id][skill] = get_param(3);
    g_curHeadshotHealthBonus[id] = SumValues(g_headshotHealthBonus[id], COD_SKILLS);
}

public Native_GetPlayerHealthBonusForHeadshot(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_headshotHealthBonus[id][skill];
}

public Native_SetPlayerExpBonusForHeadshot(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_headshotExpBonus[id][skill] = get_param(3);
    g_curHeadshotExpBonus[id] = SumValues(g_headshotExpBonus[id], COD_SKILLS);
}

public Native_GetPlayerExpBonusForHeadshot(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_headshotExpBonus[id][skill];
}

public fw_TakeDamage_Post(id, ent, att, Float:damage, damageBits) {
    if (!is_user_connected(att) || get_user_team(id) == get_user_team(att)) {
        return HAM_IGNORED;
    }

    if (damageBits & (1<<1)) {
        if (g_curHealthBonus[att]) {
            fm_set_user_health(
                att, 
                min(cod_get_user_health(att) + 100, get_user_health(att) + g_curHealthBonus[att])
            );
        }

        if (g_curExpBonus[att]) {
            cod_set_user_xp(att, cod_get_user_xp(att) + g_curExpBonus[att]);
        }

        if (get_pdata_int(id, 75, 5) == HIT_HEAD) {
            if (g_curHeadshotHealthBonus[att]) {
                fm_set_user_health(
                    att, 
                    min(cod_get_user_health(att) + 100, get_user_health(att) + g_curHeadshotHealthBonus[att])
                );
            }

            if (g_curHeadshotExpBonus[att]) {
                cod_set_user_xp(att, cod_get_user_xp(att) + g_curHeadshotExpBonus[att]);
            }
        }
    }

    return HAM_IGNORED;
}