#include <amxmodx>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/gravity>

#define FL_ONGROUND2 (FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER | FL_CONVEYOR | FL_FLOAT | FL_FLY)

new g_playerPullDownPower[33][COD_SKILLS];
new Float:g_playerDamage[33][COD_SKILLS];
new Float:g_playerDamagePerInt[33][COD_SKILLS];
new g_curPlayerSkill[33];
new g_lastUsedPlayerSkill[33];
public plugin_init() {
    register_plugin("Cod Skill - Archangel wings", "1.0", "d0naciak.pl");

    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
    register_forward(FM_CmdStart, "fw_CmdStart");
    RegisterHam(Ham_Spawn, "player", "fw_Spawn_Post", 1);
    register_event("ResetHUD", "ev_ResetHUD", "b");
}

public plugin_natives() {
    register_library("cod_skill_archangelWings");
    
    register_native("Cod_SetPlayerArchangelWings", "Native_SetPlayerArchangelWings");
    register_native("Cod_GetCurPlayerArchangelWings", "Native_GetCurPlayerArchangelWings");
    register_native("Cod_UseArchangelWings", "Native_UseArchangelWings");
    register_native("Cod_WillGetAccessToArchangelWings", "Native_WillGetAccessToArchangelWings");
}

public client_connect(id) {
    g_lastUsedPlayerSkill[id] = -1;
}

public fw_TakeDamage(id, ent, att, Float:damage, damageBits) {
    if (!is_user_connected(id)) {
        return HAM_IGNORED;
    }

    if (g_lastUsedPlayerSkill[id] != -1 && damageBits & (1<<5)) {
        return HAM_SUPERCEDE;
    }

    return HAM_IGNORED;
}

public fw_CmdStart(id, uc) {
    if(!is_user_alive(id) || g_lastUsedPlayerSkill[id] == -1) {
        return FMRES_IGNORED;
    }

    if(pev(id, pev_flags) & FL_ONGROUND2) {
        Earthquake(id, g_lastUsedPlayerSkill[id]);
        g_lastUsedPlayerSkill[id] = -1;
    }

    return FMRES_IGNORED;
}

public fw_Spawn_Post(id) {
    g_lastUsedPlayerSkill[id] = -1;
}

//Natives
public Native_SetPlayerArchangelWings(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_playerPullDownPower[id][skill] = get_param(3);
    g_playerDamage[id][skill] = get_param_f(4);
    g_playerDamagePerInt[id][skill] = get_param_f(5);

    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_playerPullDownPower[id], hasSkill);
    g_curPlayerSkill[id] = GetCurrentSkillByPriority(hasSkill);
}

public Native_GetCurPlayerArchangelWings(plugin, params) {
    new id = get_param(1);
    return g_curPlayerSkill[id];
}

public Native_UseArchangelWings(plugin, params) {
    new id = get_param(1);
    new curSkill = g_curPlayerSkill[id];
    if (curSkill == -1) {
        NotifyNoAccessToSkill(id);
        return COD_SKILL_USE_FAIL;
    }

    new skill = get_param(2);
    if (skill != curSkill) {
        NotifyIsNotCurrentSkill(id, curSkill);
        return COD_SKILL_USE_FAIL;
    }

    if (g_lastUsedPlayerSkill[id] != -1) {
        return COD_SKILL_USE_FAIL;
    }
    
    g_lastUsedPlayerSkill[id] = curSkill;
    new Float:velocity[3];
    velocity[2] -= g_playerPullDownPower[id][curSkill];
    set_pev(id, pev_velocity, velocity);
    return COD_SKILL_USE_AVAILABLE;
}

public bool:Native_WillGetAccessToArchangelWings(plugin, params) {
    new id = get_param(1);
    new candidatingSkill = get_param(2);
    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_playerPullDownPower[id], hasSkill);
    return WillGetAccessToSkillByPriority(hasSkill, candidatingSkill);
}

Earthquake(id, skill) {
    static msgId;
    if(!msgId) {
        msgId = get_user_msgid("ScreenShake");
    }
        
    message_begin(MSG_ONE, msgId, {0,0,0}, id);
    write_short(7<<14);
    write_short(1<<13);
    write_short(1<<14);
    message_end();

    new players[32], target;
    new playersNum = find_sphere_class(id, "player", 200.0, players, sizeof players);
    for (new i = 0; i < playersNum; i++) {        
        target = players[i];
        if(!is_user_alive(target) || get_user_team(id) == get_user_team(target) || !(pev(target, pev_flags) & FL_ONGROUND)) {
            continue;
        }

        message_begin(MSG_ONE, msgId, {0,0,0}, target);
        write_short(7<<14);
        write_short(1<<13);
        write_short(1<<14);
        message_end();

        cod_inflict_damage(id, target, g_playerDamage[id][skill], g_playerDamagePerInt[id][skill], id, (1<<5));
    }
}