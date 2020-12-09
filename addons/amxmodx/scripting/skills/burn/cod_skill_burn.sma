#include <amxmodx>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/burn>

//Chance to burn
new g_chanceToBurn[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToBurn[MAX_PLAYERS + 1];

//Invulnerability to blind
new bool:g_playerInvulnerabilityToBlind[MAX_PLAYERS + 1][COD_SKILLS];

enum _:CVARS {
    CVAR_DAMAGE,
    CVAR_BURNS_NUM,
    CVAR_PERIOD_TIME,
    CVAR_INT_MULTIPLIER
};
new g_pcvar[CVARS];

public plugin_init() {
    register_plugin("Cod Skill - Burn", "1.0", "d0naciak.pl");

    if (!LibraryExists("cod_basicSkill_burn", LibType_Library)) {
        set_fail_state("Cant load cod_basicSkill_burn library");
        return;
    }

    g_pcvar[CVAR_DAMAGE] = register_cvar("cod_skill_burn_damage", "5.0");
    g_pcvar[CVAR_BURNS_NUM] = register_cvar("cod_skill_burn_num", "10");
    g_pcvar[CVAR_PERIOD_TIME] = register_cvar("cod_skill_burn_period_time", "0.4");
    g_pcvar[CVAR_INT_MULTIPLIER] = register_cvar("cod_skill_burn_int_multiplier", "0.02");

    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1);
}

public plugin_natives() {
    register_library("cod_skill_burn");

    register_native("Cod_SetPlayerChanceToBurn", "Native_SetPlayerChanceToBurn");
    register_native("Cod_GetPlayerChanceToBurn", "Native_SetPlayerChanceToBurn");

    register_native("Cod_SetPlayerInvulnerabilityToBurn", "Native_SetPlayerInvulnerabilityToBurn");
    register_native("Cod_GetPlayerInvulnerabilityToBurn", "Native_GetPlayerInvulnerabilityToBurn");
}

public fw_TakeDamage_Post(id, ent, att, Float:damage, damageBits) {
    if (!is_user_connected(att) || get_user_team(id) == get_user_team(att)) {
        return HAM_IGNORED;
    }

    if (damageBits & (1<<1)) {
        if (g_curChanceToBurn[att] && !random(g_curChanceToBurn[att])) {
            Cod_BurnPlayer(
                att, id, 
                get_pcvar_float(g_pcvar[CVAR_PERIOD_TIME]), get_pcvar_num(g_pcvar[CVAR_BURNS_NUM]), 
                get_pcvar_float(g_pcvar[CVAR_DAMAGE]) + get_pcvar_float(g_pcvar[CVAR_INT_MULTIPLIER]) * cod_get_user_intelligence(att)
            );
        }
    }

    return HAM_IGNORED;
}

//Natives
public Native_SetPlayerChanceToBurn(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToBurn[id][skill] = get_param(3);
    new bestId = FindLowestValueIfExist(g_chanceToBurn[id], COD_SKILLS);
    if (bestId == -1) {
        g_curChanceToBurn[id] = 0;
    } else {
        g_curChanceToBurn[id] = g_chanceToBurn[id][skill];
    }
}

public Native_GetPlayerChanceToBurn(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToBurn[id][skill];
}

public Native_SetPlayerInvulnerabilityToBurn(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_playerInvulnerabilityToBlind[id][skill] = bool:get_param(3);
    Cod_SetPlayerInvulnerabilityToBurn(id, FindTrueBooleanIfExist(g_playerInvulnerabilityToBlind[id], COD_SKILLS));
}

public Native_GetPlayerInvulnerabilityToBurn(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_playerInvulnerabilityToBlind[id][skill];
}