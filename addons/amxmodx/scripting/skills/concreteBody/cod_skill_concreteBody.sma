#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/damage>

new g_concreteBodyTime[MAX_PLAYERS + 1][COD_SKILLS];
new Float:g_endOfConcreteBody[MAX_PLAYERS + 1];
new g_curPlayerSkill[MAX_PLAYERS + 1];

new g_barTimeMsgId;
public plugin_init() {
    register_plugin("Cod Skill - Concrete body", "1.0", "Dawid Kałuża");

    register_logevent("ev_RoundStart", 2, "1=Round_Start");
    RegisterHam(Ham_Killed, "player", "fw_Killed_Post", 1);

    g_barTimeMsgId = get_user_msgid("BarTime2");
}

public plugin_natives() {
    register_library("cod_skill_concreteBody");

    register_native("Cod_SetPlayerConcreteBody", "Native_SetPlayerConcreteBody");
    register_native("Cod_GetPlayerConcreteBody", "Native_GetPlayerConcreteBody");
    register_native("Cod_UseConcreteBody", "Native_UseConcreteBody");
    register_native("Cod_WillGetAccessToConcreteBody", "Native_WillGetAccessToConcreteBody");
}

public client_disconnected(id, bool:drop, message[], len) {
    g_endOfConcreteBody[id] = 0.0;
}

public ev_RoundStart() {
    for (new i = 1; i <= MaxClients; i++) {
        g_endOfConcreteBody[i] = 0.0;
    }
}

public fw_Killed_Post(id, att, shGb) {
    if (g_endOfConcreteBody[id] > get_gametime()) {
        SetBarTime(id, 0);
    }
}

public Cod_OnTakeDamage(id, att, ent, Float:damage, damageBits) {
    if (g_endOfConcreteBody[id] < get_gametime()) {
        return CODDMG_IGNORE;
    }

    if ((damageBits & (1<<1) && get_pdata_int(id, 75, 5) == HIT_HEAD) || damageBits & (1<<24)) {
        return CODDMG_AVOID;
    }

    return CODDMG_IGNORE;
}

//Natives
public Native_SetPlayerConcreteBody(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_concreteBodyTime[id][skill] = get_param(3);
    
    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_concreteBodyTime[id], hasSkill);
    g_curPlayerSkill[id] = GetCurrentSkillByPriority(hasSkill);
}

public Native_GetPlayerConcreteBody(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_concreteBodyTime[id][skill];
}

public Native_UseConcreteBody(plugin, params) {
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

    if (g_endOfConcreteBody[id]) {
        client_print(id, print_center, "Betonowe ciało jest dostępne raz na rundę");
        return COD_SKILL_USE_FAIL;
    }

    new time = g_concreteBodyTime[id][skill];
    g_endOfConcreteBody[id] = get_gametime() + float(time);
    SetBarTime(id, time);
    return COD_SKILL_USE_NAVAILABLE;
}

public bool:Native_WillGetAccessToConcreteBody(plugin, params) {
    new id = get_param(1);
    new candidatingSkill = get_param(2);
    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_concreteBodyTime[id], hasSkill);
    return WillGetAccessToSkillByPriority(hasSkill, candidatingSkill);
}

SetBarTime(id, time, start=0) {
    message_begin(id ? MSG_ONE : MSG_ALL, g_barTimeMsgId, _, id)
    write_short(time);
    write_short(start);
    message_end();   
}