#include <amxmodx>
#include <fakemeta>
#include <cstrike>
#include <cod/skills/core/core>
#include <cod/skills/basics/ammo>

new bool:g_playerHasAgileFingers[MAX_PLAYERS + 1][COD_SKILLS];
new bool:g_curPlayerHasAgileFingers[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Agile Fingers", "1.0", "d0naciak.pl");

    register_forward(FM_CmdStart, "fw_CmdStart");
    register_logevent("ev_StartRound", 2, "1=Round_Start");
}

public plugin_natives() {
    register_library("cod_skill_agileFingers");
    
    register_native("Cod_SetPlayerAgileFingers", "nat_SetPlayerAgileFingers");
    register_native("Cod_GetPlayerAgileFingers", "nat_GetPlayerAgileFingers");
}

public fw_CmdStart(id, ucHandler) {
    if(!is_user_alive(id) || !g_curPlayerHasAgileFingers[id]) {
        return FMRES_IGNORED;
    }

    static buttons, oldButtons, clip, bpammo, weapon;
    buttons = get_uc(ucHandler, UC_Buttons);
    oldButtons = pev(id, pev_oldbuttons);
    weapon = get_user_weapon(id, clip, bpammo);
    if(MAX_BPAMMO[weapon] <= 2 || !bpammo) {
        return FMRES_IGNORED;
    }
    
    if((buttons & IN_RELOAD && !(oldButtons & IN_RELOAD) && !(buttons & IN_ATTACK)) || !clip) {
        new newClip = bpammo < MAX_CLIP[weapon] ? bpammo : MAX_CLIP[weapon];
        if(newClip > MAX_CLIP[weapon]) {
            newClip = MAX_CLIP[weapon];
        }

        cs_set_user_bpammo(id, weapon, bpammo - (newClip - clip));
        SetPlayerClip(id, newClip, weapon);
    }
    
    return FMRES_IGNORED;
}

public ev_StartRound() {
    for(new id = 1; id <= MaxClients; id++) {
        if (!is_user_alive(id) || !g_curPlayerHasAgileFingers[id]) {
            continue;
        }

        new weapons[32], weaponsNum, weapon;
        get_user_weapons(id, weapons, weaponsNum);
        for(new i = 0; i < weaponsNum; i++) {
            weapon = weapons[i];
            if(MAX_BPAMMO[weapon] > 2) {
                cs_set_user_bpammo(id, weapon, MAX_BPAMMO[weapon]);
            }
        }
    }
}

public nat_SetPlayerAgileFingers(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new bool:set = bool:get_param(2);
    g_playerHasAgileFingers[id][skill] = set;
    g_curPlayerHasAgileFingers[id] = FindTrueBooleanIfExist(g_playerHasAgileFingers[id], COD_SKILLS);
}

public bool:nat_GetPlayerAgileFingers(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_playerHasAgileFingers[id][skill];
}

