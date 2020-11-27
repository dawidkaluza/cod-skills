#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <cod/skills/basics/damage_consts>

enum _:FORWARDS {
    FORWARD_ON_TAKE_DAMAGE//,
    // FORWARD_ON_TAKE_DAMAGE_POST
};
new g_forward[FORWARDS];

new Float:g_forwardDamage;
new g_lastPlayersDamageCode[MAX_PLAYERS + 1][MAX_PLAYERS + 1];
new g_lastVictimDamageCode[MAX_PLAYERS + 1];

public plugin_init() {
    register_plugin("Cod Basic Skill - Damage", "1.0", "d0naciak.pl");

    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
    RegisterHam(Ham_BloodColor, "player", "fw_BloodColor");

    g_forward[FORWARD_ON_TAKE_DAMAGE] = CreateMultiForward("Cod_OnTakeDamage", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL);
    // g_forward[FORWARD_ON_TAKE_DAMAGE_POST] = CreateMultiForward("Cod_OnTakeDamage_Post", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL);
}

public plugin_precache() {
    precache_sound("weapons/ric_conc-1.wav");
    precache_sound("weapons/ric_conc-2.wav");
}

public plugin_natives() {
    register_library("cod_basicSkill_damage");

    register_native("Cod_ChangeForwardDamage", "nat_ChangeForwardDamage");
}

public fw_TakeDamage(id, att, ent, Float:damage, damageBits) {
    if (!is_user_connected(id) || !is_user_connected(att) || get_user_team(id) == get_user_team(att)) {
        return HAM_IGNORED;
    }

    // new fwdId = id, fwdAtt = att, fwdEnt = ent, Float:fwdDamage = damage, fwdDamageBits - damageBits;
    g_forwardDamage = damage;

    new returnCode = CODDMG_IGNORE;
    ExecuteForward(g_forward[FORWARD_ON_TAKE_DAMAGE], returnCode, id, att, ent, damage, damageBits);
    g_lastPlayersDamageCode[att][id] = returnCode;
    g_lastVictimDamageCode[id] = returnCode;
    switch (returnCode) {
        case CODDMG_IGNORE: {
            return HAM_IGNORED;
        }

        case CODDMG_CHANGE: {
            SetHamParamFloat(4, g_forwardDamage);
            return HAM_HANDLED;
        }

        case CODDMG_KILL: {
            SetHamParamFloat(4, float(get_user_health(id) * 5));
            return HAM_HANDLED;
        }

        case CODDMG_MIRROR: {
            if (g_lastPlayersDamageCode[id][att] == CODDMG_MIRROR) {
                return HAM_IGNORED;
            }

            ExecuteHamB(Ham_TakeDamage, att, id, id, damage, damageBits);
            return HAM_SUPERCEDE;
        }

        case CODDMG_AVOID: {
            return HAM_SUPERCEDE;
        }
    }

    return HAM_IGNORED;
}

public fw_BloodColor(id) {
    if (!is_user_alive(id)) {
        return HAM_IGNORED;
    }

    switch (g_lastVictimDamageCode[id]) {
        case CODDMG_MIRROR, CODDMG_AVOID: {
            SparkEffect(id);
            SetHamReturnInteger(-1);
            return HAM_SUPERCEDE;
        }
    }
    
    return HAM_IGNORED;
}

public nat_ChangeForwardDamage(plugin, params) {
    if (params != 1) {
        return;
    }

    g_forwardDamage = get_param_f(1);
}


stock SparkEffect(id) {
    static szSound[][] = { "weapons/ric_conc-1.wav", "weapons/ric_conc-2.wav" };
    new Float:fOrigin[3];
    
    pev(id, pev_origin, fOrigin);
    
    message_begin(MSG_ALL, SVC_TEMPENTITY);
    write_byte(TE_SPARKS);
    engfunc(EngFunc_WriteCoord, fOrigin[0]);
    engfunc(EngFunc_WriteCoord, fOrigin[1]);
    engfunc(EngFunc_WriteCoord, fOrigin[2]);
    message_end();
    
    engfunc(EngFunc_EmitSound, id, CHAN_ITEM, szSound[random(2)], 0.8, ATTN_STATIC, 0, PITCH_NORM);
}