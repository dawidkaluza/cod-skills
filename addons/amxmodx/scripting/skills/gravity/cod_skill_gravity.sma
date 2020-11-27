#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <cod/skills/core/core>

new Float:g_playerGravity[MAX_PLAYERS + 1][COD_SKILLS];
new Float:g_curPlayerGravity[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Gravity", "1.0", "d0naciak.pl");
    RegisterHam(Ham_Spawn, "player", "fw_Spawn_Post", 1);
}

public plugin_natives() {
    register_library("cod_skill_gravity");
    
    register_native("Cod_SetPlayerGravity", "Native_SetPlayerGravity");
    register_native("Cod_GetPlayerGravity", "Native_GetPlayerGravity");
}

public fw_Spawn_Post(id) {
    if (is_user_alive(id) && g_curPlayerGravity[id]) {
        set_pev(id, pev_gravity, g_curPlayerGravity[id]);
    }
}

//Natives
public Native_SetPlayerGravity(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new Float:gravity = get_param_f(3);
    g_playerGravity[id][skill] = gravity;

    new bestId = FindLowestFloatValueIfExist(g_playerGravity[id], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerGravity[id] = 0.0;
        set_pev(id, pev_gravity, 1.0);
    } else {
        g_curPlayerGravity[id] = g_playerGravity[id][bestId];
        set_pev(id, pev_gravity, g_curPlayerGravity[id]);
    }
}

public Float:Native_GetPlayerGravity(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_playerGravity[id][skill];
}
