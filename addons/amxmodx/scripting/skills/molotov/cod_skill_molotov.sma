#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/burn>

//Molotov grenades
enum _:MODELS { 
    MODEL_V, 
    MODEL_W 
};
new const g_models[MODELS][] = {
    "models/molotov/v_molotov.mdl",
    "models/molotov/w_molotov.mdl"
};

enum _:SPRITES {
    SPRITE_TRAIL
};
new g_sprites[SPRITES];

#define MarkAsMolotov(%1) set_pev(%1,pev_iuser3,1)
#define IsMolotov(%1) (pev(%1,pev_iuser3)==1)

new g_molotovGrenadesNum[MAX_PLAYERS + 1][COD_SKILLS];
new g_curMolotovGrenadeSkill[MAX_PLAYERS + 1];
new g_curMolotovGrenadesNum[MAX_PLAYERS + 1];

enum _:CVARS {
    CVAR_DAMAGE,
    CVAR_BURNS_NUM,
    CVAR_PERIOD_TIME,
    CVAR_INT_MULTIPLIER
};
new g_pcvar[CVARS];

public plugin_init() {
    register_plugin("Cod Skill - Molotov", "1.0", "d0naciak.pl");

    if (!LibraryExists("cod_basicSkill_burn", LibType_Library)) {
        set_fail_state("Cant load cod_basicSkill_burn library");
        return;
    }
    
    g_pcvar[CVAR_DAMAGE] = register_cvar("cod_skill_molotov_damage", "5.0");
    g_pcvar[CVAR_BURNS_NUM] = register_cvar("cod_skill_molotov_num", "10");
    g_pcvar[CVAR_PERIOD_TIME] = register_cvar("cod_skill_molotov_period_time", "0.4");
    g_pcvar[CVAR_INT_MULTIPLIER] = register_cvar("cod_skill_molotov_int_multiplier", "0.02");

    RegisterHam(Ham_Spawn, "player", "fw_Spawn_Post", 1);
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1);
    RegisterHam(Ham_Item_Deploy, "weapon_hegrenade", "fw_HegrenadeDeploy_Post", 1);
    register_forward(FM_SetModel, "fw_SetModel_Post", 1);
}

public plugin_precache() {
    for (new i = 0; i < MODELS; i++) {
        precache_model(g_models[i]);
    }

    g_sprites[SPRITE_TRAIL] = precache_model("sprites/xbeam5.spr");
}

public plugin_natives() {
    register_library("cod_skill_molotov");

    register_native("Cod_SetPlayerMolotovGrenades", "Native_SetPlayerMolotovGrenades");
    register_native("Cod_GetPlayerMolotovGrenades", "Native_GetPlayerMolotovGrenades");
}

public fw_Spawn_Post(id) {
    if (!is_user_alive(id)) {
        return HAM_IGNORED;
    }

    new curSkill = g_curMolotovGrenadeSkill[id];
    if (curSkill != -1) {
        new num = g_molotovGrenadesNum[id][curSkill];
        cs_set_user_bpammo(id, CSW_HEGRENADE, num);
        g_curMolotovGrenadesNum[id] = num;
    }

    return HAM_IGNORED;
}

public fw_TakeDamage_Post(id, ent, att, Float:damage, damageBits) {
    if (!is_user_connected(att) || get_user_team(id) == get_user_team(att)) {
        return HAM_IGNORED;
    }

    if (damageBits & (1<<24)) {
        if (pev_valid(ent) && IsMolotov(ent)) {
            Cod_BurnPlayer(
                att, id, 
                get_pcvar_float(g_pcvar[CVAR_PERIOD_TIME]), get_pcvar_num(g_pcvar[CVAR_BURNS_NUM]), 
                get_pcvar_float(g_pcvar[CVAR_DAMAGE]) + get_pcvar_float(g_pcvar[CVAR_INT_MULTIPLIER]) * cod_get_user_intelligence(att)
            );
        }
    }

    return HAM_IGNORED;
}

public fw_HegrenadeDeploy_Post(ent) {
    if (!pev_valid(ent)) {
        return HAM_IGNORED;
    }

    new id = pev(ent, pev_owner);
    if (!is_user_connected(id) || !g_curMolotovGrenadesNum[id]) {
        return HAM_IGNORED;
    }

    set_pev(id, pev_viewmodel2, g_models[MODEL_V]);
    return HAM_IGNORED;
}

public fw_SetModel_Post(ent, const model[]) {
    if (!pev_valid(ent) || !equal(model, "models/w_hegrenade.mdl")) {
        return FMRES_IGNORED;
    }

    new id = pev(ent, pev_owner);
    if (!is_user_connected(id) || !g_curMolotovGrenadesNum[id]) {
        return FMRES_IGNORED;
    }

    MarkAsMolotov(ent);
    engfunc(EngFunc_SetModel, ent, g_models[MODEL_W]);

    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte(TE_BEAMFOLLOW);
    write_short(ent);
    write_short(g_sprites[SPRITE_TRAIL]);
    write_byte(5);
    write_byte(5);
    write_byte(255); //r
    write_byte(127); //g
    write_byte(0); //b
    write_byte(255);
    message_end();

    g_curMolotovGrenadesNum[id] --;
    return FMRES_IGNORED;
}

//Natives
public Native_SetPlayerMolotovGrenades(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_molotovGrenadesNum[id][skill] = get_param(3);
    new bestId = FindHighestValueIfExist(g_molotovGrenadesNum[id], skill);
    if (bestId == -1) {
        cod_take_weapon(id, CSW_HEGRENADE);
        g_curMolotovGrenadeSkill[id] = -1;
        g_curMolotovGrenadesNum[id] = 0;
    } else {
        new num = g_molotovGrenadesNum[id][bestId];
        cod_give_weapon(id, CSW_HEGRENADE);
        if (is_user_alive(id)) {
            cs_set_user_bpammo(id, CSW_HEGRENADE, num);
        }
        g_curMolotovGrenadeSkill[id] = bestId;
        g_curMolotovGrenadesNum[id] = num;
    }
}

public Native_GetPlayerMolotovGrenades(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_molotovGrenadesNum[id][skill];
}