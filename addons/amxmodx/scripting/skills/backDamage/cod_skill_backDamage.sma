#include <amxmodx>
#include <fakemeta>
#include <xs>
#include <engine>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/damage>

new Float:g_playerBackDamageMultiplier[MAX_PLAYERS + 1][COD_SKILLS];
new Float:g_curPlayerBackDamageMultiplier[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Back Damage", "1.0", "d0naciak.pl");
}

public plugin_natives() {
    register_library("cod_skill_backDamage");
    
    register_native("Cod_SetPlayerBackDamageMultiplier", "Native_SetPlayerBackDamageMultiplier");
    register_native("Cod_GetPlayerBackDamageMultiplier", "Native_GetPlayerBackDamageMultiplier");
}

public Cod_OnTakeDamage(id, att, ent, Float:damage, damageBits) {
    if (!(damageBits & (1<<1))) {
        return CODDMG_IGNORE;
    }

    if (g_curPlayerBackDamageMultiplier[att] && UTIL_In_FOV(att, id) && !UTIL_In_FOV(id, att)) {
        Cod_ChangeForwardDamage(damage * (1.0 + g_curPlayerBackDamageMultiplier[att]));
        return CODDMG_CHANGE;
    }

    return CODDMG_IGNORE;
}

//Natives
public Native_SetPlayerBackDamageMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_playerBackDamageMultiplier[id][skill] = get_param_f(3);
    new bestId = FindHighestFloatValueIfExist(g_playerBackDamageMultiplier[id], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerBackDamageMultiplier[id] = 0.0;
    } else {
        g_curPlayerBackDamageMultiplier[id] = g_playerBackDamageMultiplier[id][bestId];
    }
}

public Float:Native_GetPlayerBackDamageMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_playerBackDamageMultiplier[id][skill];
}

stock bool:UTIL_In_FOV(id,target)
{
    if (Find_Angle(id,target,9999.9) > 0.0)
        return true;
    return false;
}

stock Float:Find_Angle(Core,Target,Float:dist)
{
    new Float:vec2LOS[2];
    new Float:flDot;
    new Float:CoreOrigin[3];
    new Float:TargetOrigin[3];
    new Float:CoreAngles[3];
    
    pev(Core,pev_origin,CoreOrigin);
    pev(Target,pev_origin,TargetOrigin);
    
    if (get_distance_f(CoreOrigin,TargetOrigin) > dist)
        return 0.0;
    
    pev(Core,pev_angles, CoreAngles);
    
    for ( new i = 0; i < 2; i++ )
        vec2LOS[i] = TargetOrigin[i] - CoreOrigin[i];
    
    new Float:veclength = Vec2DLength(vec2LOS);
    
    //Normalize V2LOS
    if (veclength <= 0.0)
    {
        vec2LOS[0] = 0.0;
        vec2LOS[1] = 0.0;
    }
    else
    {
        new Float:flLen = 1.0 / veclength;
        vec2LOS[0] = vec2LOS[0]*flLen;
        vec2LOS[1] = vec2LOS[1]*flLen;
    }
    
    //Do a makevector to make v_forward right
    engfunc(EngFunc_MakeVectors,CoreAngles);
    
    new Float:v_forward[3];
    new Float:v_forward2D[2];
    get_global_vector(GL_v_forward, v_forward);
    
    v_forward2D[0] = v_forward[0];
    v_forward2D[1] = v_forward[1];
    
    flDot = vec2LOS[0]*v_forward2D[0]+vec2LOS[1]*v_forward2D[1];
    
    if ( flDot > 0.5 )
    {
        return flDot;
    }
    
    return 0.0;
}

stock Float:Vec2DLength( Float:Vec[2] )  
{ 
    return floatsqroot(Vec[0]*Vec[0] + Vec[1]*Vec[1] );
}