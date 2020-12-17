#include <amxmodx>
#include <fakemeta_util>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>

new g_explosionsOnPlayerPosNum[MAX_PLAYERS + 1][COD_SKILLS];
new g_explosionsOnPlayerPosDamage[MAX_PLAYERS + 1][COD_SKILLS];
new g_explosionsOnPlayerPosDamagePerInt[MAX_PLAYERS + 1][COD_SKILLS];
new g_explosionsOnPlayerPosRange[MAX_PLAYERS + 1][COD_SKILLS];
new g_curExplosionsOnPlayerPosNum[MAX_PLAYERS + 1];
new g_curExplosionsOnPlayerPosSkill[MAX_PLAYERS + 1];

new g_explosionsOnAimPosNum[MAX_PLAYERS + 1][COD_SKILLS];
new g_explosionsOnAimPosDamage[MAX_PLAYERS + 1][COD_SKILLS];
new g_explosionsOnAimPosDamagePerInt[MAX_PLAYERS + 1][COD_SKILLS];
new g_explosionsOnAimPosRange[MAX_PLAYERS + 1][COD_SKILLS];
new g_curExplosionsOnAimPosNum[MAX_PLAYERS + 1];
new g_curExplosionsOnAimPosSkill[MAX_PLAYERS + 1];

public plugin_init() {
    register_plugin("Cod Skill - Explosion", "1.0", "d0naciak.pl");
}

public plugin_natives() {
    register_library("cod_skill_explosion");

    register_native("Cod_SetPlayerExplosionsOnPlayerPos", "Native_SetPlayerExplosionsOnPlayerPos");
    register_native("Cod_GetPlayerExplosionsOnPlayerPos", "Native_GetPlayerExplosionsOnPlayerPos");
    register_native("Cod_ExplodeOnPlayerPos", "Native_ExplodeOnPlayerPos");

    register_native("Cod_SetPlayerExplosionsOnAimPos", "Native_SetPlayerExplosionsOnAimPos");
    register_native("Cod_GetPlayerExplosionsOnAimPos", "Native_GetPlayerExplosionsOnAimPos");
    register_native("Cod_ExplodeOnAimPos", "Native_ExplodeOnAimPos");
}

//Natives
public Native_SetPlayerExplosionsOnPlayerPos(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_explosionsOnPlayerPosNum[id][skill] = get_param(3);
    g_explosionsOnPlayerPosDamage[id][skill] = get_param_f(4);
    g_explosionsOnPlayerPosDamagePerInt[id][skill] = get_param_f(5);
    g_explosionsOnPlayerPosRange[id][skill] = get_param_f(5);

    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_explosionsOnPlayerPosNum[id], hasSkill);
    new curSkill = GetCurrentSkillByPriority(hasSkill);
    if (curSkill == -1) {
        g_curExplosionsOnPlayerPosSkill[id] = -1;
        g_curExplosionsOnPlayerPosNum[id] = 0;
    } else {
        g_curExplosionsOnPlayerPosSkill[id] = curSkill;
        g_curExplosionsOnPlayerPosNum[id] = g_explosionsOnPlayerPosNum[id][curSkill];
    }
}

public Native_GetPlayerExplosionsOnPlayerPos(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_explosionsOnPlayerPosNum[id][skill];
}

public Native_ExplodeOnPlayerPos(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    
    new id = get_param(1);
    new curSkill = g_curExplosionsOnPlayerPosSkill[id];
    if (curSkill == -1) {
        NotifyNoAccessToSkill(id);
        return COD_SKILL_USE_FAIL;
    }

    new skill = get_param(2);
    if (skill != curSkill) {
        NotifyIsNotCurrentSkill(id, curSkill);
        return COD_SKILL_USE_FAIL;
    }

    if (!g_curExplosionsOnPlayerPosNum[id]) {
        client_print(id, print_center, "Nie posiadasz więcej eksplozji");
        return COD_SKILL_USE_FAIL;
    }

    cod_make_explosion(
        id, id, g_explosionsOnPlayerPosDamage[id][skill], 
        g_explosionsOnPlayerPosDamagePerInt[id][skill], g_explosionsOnPlayerPosRange[id][skill]
    );

    if (--g_curExplosionsOnPlayerPosNum[id] <= 0) {
        return COD_SKILL_USE_NAVAILABLE;
    }
    
    return COD_SKILL_USE_AVAILABLE;
}

public Native_SetPlayerExplosionsOnAimPos(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_explosionsOnAimPosNum[id][skill] = get_param(3);
    g_explosionsOnAimPosDamage[id][skill] = get_param_f(4);
    g_explosionsOnAimPosDamagePerInt[id][skill] = get_param_f(5);
    g_explosionsOnAimPosRange[id][skill] = get_param_f(5);

    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_explosionsOnAimPosNum[id], hasSkill);
    new curSkill = GetCurrentSkillByPriority(hasSkill);
    if (curSkill == -1) {
        g_curExplosionsOnAimPosSkill[id] = -1;
        g_curExplosionsOnAimPosNum[id] = 0;
    } else {
        g_curExplosionsOnAimPosSkill[id] = curSkill;
        g_curExplosionsOnAimPosNum[id] = g_explosionsOnAimPosNum[id][curSkill];
    }
}

public Native_GetPlayerExplosionsOnPlayerPos(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_explosionsOnAimPosNum[id][skill];
}

public Native_ExplodeOnAimPos(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    
    new id = get_param(1);
    new curSkill = g_curExplosionsOnAimPosSkill[id];
    if (curSkill == -1) {
        NotifyNoAccessToSkill(id);
        return COD_SKILL_USE_FAIL;
    }

    new skill = get_param(2);
    if (skill != curSkill) {
        NotifyIsNotCurrentSkill(id, curSkill);
        return COD_SKILL_USE_FAIL;
    }

    if (!g_curExplosionsOnAimPosNum[id]) {
        client_print(id, print_center, "Nie posiadasz więcej eksplozji");
        return COD_SKILL_USE_FAIL;
    }

    cod_make_explosion(
        id, id, g_explosionsOnPlayerPosDamage[id][skill], 
        g_explosionsOnPlayerPosDamagePerInt[id][skill], g_explosionsOnPlayerPosRange[id][skill]
    );

    if (--g_curExplosionsOnPlayerPosNum[id] <= 0) {
        return COD_SKILL_USE_NAVAILABLE;
    }
    
    return COD_SKILL_USE_AVAILABLE;
}