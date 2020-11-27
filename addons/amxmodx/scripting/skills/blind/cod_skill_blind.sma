#include <amxmodx>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/blind>

//Chance to blind
new g_chanceToBlind[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToBlind[MAX_PLAYERS + 1];

//Mass blind
new g_massBlindsNum[MAX_PLAYERS + 1][COD_SKILLS];
new g_curMassBlindSkill[MAX_PLAYERS + 1];
new g_curMassBlindsNum[MAX_PLAYERS + 1];

//Invulnerability to blind
new bool:g_playerInvulnerabilityToBlind[MAX_PLAYERS + 1][COD_SKILLS];
public plugin_init() {
    register_plugin("Cod Skill - Blind", "1.0", "d0naciak.pl");

    if (!LibraryExists("cod_basicSkill_blind", LibType_Library)) {
        set_fail_state("Cant load cod_basicSkill_blind library");
        return;
    }

    register_event("HLTV", "ev_NewRound", "a", "1=0", "2=0");
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1);
}

public plugin_natives() {
    register_library("cod_skill_blind");
    
    register_native("Cod_SetPlayerChanceToBlind", "Native_SetPlayerChanceToBlind");
    register_native("Cod_GetPlayerChanceToBlind", "Native_GetPlayerChanceToBlind");
    
    register_native("Cod_SetPlayerMassBlinds", "Native_SetPlayerMassBlinds");
    register_native("Cod_GetCurPlayerMassBlinds", "Native_GetCurPlayerMassBlinds");
    register_native("Cod_UseMassBlind", "Native_UseMassBlind");
    register_native("Cod_WillGetAccessToMassBlind", "Native_WillGetAccessToMassBlind");
    
    register_native("Cod_SetPlayerInvulnerabilityToBlind", "Native_SetPlayerInvulnerabilityToBlind");
    register_native("Cod_GetPlayerInvulnerabilityToBlind", "Native_GetPlayerInvulnerabilityToBlind");
}

public ev_NewRound() {
    new skill;
    for (new i = 1; i <= MaxClients; i++) {
        skill = g_curMassBlindSkill[i];
        if (skill != -1) {
            g_curMassBlindsNum[i] = g_massBlindsNum[i][skill];
        }
    }
}

public fw_TakeDamage_Post(id, ent, att, Float:damage, damageBits) {
    if (!is_user_connected(att) || get_user_team(id) == get_user_team(att)) {
        return HAM_IGNORED;
    }

    if (damageBits & (1<<1) && g_curChanceToBlind[att] && !random(g_curChanceToBlind[att])) {
        Cod_BlindPlayer(id, 4);
    }

    return HAM_IGNORED;
}

//Natives
public Native_SetPlayerChanceToBlind(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToBlind[id][skill] = get_param(3);
    new bestId = FindLowestValueIfExist(g_chanceToBlind[id], COD_SKILLS);
    if (bestId == -1) {
        g_curChanceToBlind[id] = 0;
    } else {
        g_curChanceToBlind[id] = g_chanceToBlind[id][bestId];
    }
}

public Native_GetPlayerChanceToBlind(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToBlind[id][skill];
}

public Native_SetPlayerMassBlinds(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_massBlindsNum[id][skill] = get_param(3);
    
    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_massBlindsNum[id], hasSkill);
    g_curMassBlindSkill[id] = GetCurrentSkillByPriority(hasSkill);
}

public Native_GetCurPlayerMassBlinds(plugin, params) {
    new id = get_param(1);
    return g_curMassBlindSkill[id];
}

public Native_UseMassBlind(plugin, params) {
    new id = get_param(1);
    new curSkill = g_curMassBlindSkill[id];
    if (curSkill == -1) {
        NotifyNoAccessToSkill(id);
        return COD_SKILL_USE_FAIL;
    }

    new skill = get_param(2);
    if (skill != curSkill) {
        NotifyIsNotCurrentSkill(id, curSkill);
        return COD_SKILL_USE_FAIL;
    }

    if (!g_curMassBlindsNum[id]) {
        client_print(id, print_center, "Wykorzystałeś(aś) wszystkie oślepienia");
        return COD_SKILL_USE_FAIL;
    }

    new playerTeam = get_user_team(id);
    for (new i = 1; i <= MaxClients; i++) {
        if (!is_user_alive(i) || get_user_team(i) == playerTeam) {
            continue;
        }

        Cod_BlindPlayer(i, 3, 0, 0, 0, 255);
    }

    if (--g_curMassBlindsNum[id]) {
        return COD_SKILL_USE_AVAILABLE;
    }

    return COD_SKILL_USE_NAVAILABLE;
}

public bool:Native_WillGetAccessToMassBlind(plugin, params) {
    new id = get_param(1);
    new candidateSkill = get_param(2);
    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_massBlindsNum[id], hasSkill);
    return WillGetAccessToSkillByPriority(hasSkill, candidateSkill);
}

public Native_SetPlayerInvulnerabilityToBlind(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_playerInvulnerabilityToBlind[id][skill] = bool:get_param(3);
    Cod_SetPlayerInvulnerabilityToBlind(id, FindTrueBooleanIfExist(g_playerInvulnerabilityToBlind[id], COD_SKILLS));
}

public bool:Native_GetPlayerInvulnerabilityToBlind(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_playerInvulnerabilityToBlind[id][skill];
}