#include <amxmodx>
#include <fakemeta>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>

#define FL_WATERJUMP (1<<11)    // popping out of the water
#define FL_ONGROUND (1<<9)      // not moving on the ground

new bool:g_playerHasAutoBh[MAX_PLAYERS + 1][COD_SKILLS];
new bool:g_curPlayerHasAutoBh[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Auto BH", "1.0", "d0naciak.pl");

    register_forward(FM_PlayerPreThink, "fw_PlayerPreThink");
}

public plugin_natives() {
    register_library("cod_skill_autoBh");
    
    register_native("Cod_SetPlayerAutoBh", "Native_SetPlayerAutoBh");
    register_native("Cod_GetPlayerAutoBh", "Native_GetPlayerAutoBh");
}

public fw_PlayerPreThink(id) {
    if (!is_user_alive(id) && !g_curPlayerHasAutoBh[id]) {
        return PLUGIN_CONTINUE
    }

    if (pev(id, pev_button) & IN_JUMP) {
        new flags = pev(id, pev_flags)

        if (flags & FL_WATERJUMP){
            return FMRES_IGNORED;
        }

        if (pev(id, pev_waterlevel) >= 2) {
            return FMRES_IGNORED;
        }

        if (!(flags & FL_ONGROUND)) {
            return FMRES_IGNORED;
        }

        new Float:velocity[3];
        pev(id, pev_velocity, velocity);
        velocity[2] += 250.0;
        set_pev(id, pev_velocity, velocity);

        set_pev(id, pev_gaitsequence, 6);
    }
    
    return FMRES_IGNORED;
}

//Natives
public Native_SetPlayerAutoBh(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new bool:set = bool:get_param(2);
    g_playerHasAutoBh[id][skill] = set;
    g_curPlayerHasAutoBh[id] = FindTrueBooleanIfExist(g_playerHasAutoBh[id], COD_SKILLS);
}

public bool:Native_GetPlayerAutoBh(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_playerHasAutoBh[id][skill];
}