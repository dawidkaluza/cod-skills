#include <amxmodx>
#include <hamsandwich>

new g_msgBarTime;
new Float:g_endOfBarTime[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Effect - Bar time", "1.0", "d0naciak.pl");
    RegisterHam(Ham_Killed, "player", "fw_Killed_Post", 1);
    g_msgBarTime = get_user_msgid("BarTime2");
}

public plugin_natives() {
    register_library("cod_effect_barTime");
    register_native("Cod_SetPlayerBarTime", "Native_SetPlayerBarTime");
}

public client_disconnected(id, bool:drop, message[], len) {
    g_endOfBarTime[id] = 0.0;
}

public fw_Killed_Post(id, att, shGb) {
    if (!is_user_connected(id)) {
        return HAM_IGNORED;
    }

    if (g_endOfBarTime[id] > get_gametime()) {
        SetBarTime(id, 0);
    }

    return HAM_IGNORED;
}

//Natives
public Native_SetPlayerBarTime(plugin, params) {
    new id = get_param(1);
    new time = get_param(2);
    SetBarTime(id, time);
    g_endOfBarTime[id] = get_gametime() + float(time);
}

SetBarTime(id, time) {
    message_begin(id ? MSG_ONE : MSG_ALL, g_msgBarTime, _, id)
    write_short(time);
    write_short(0);
    message_end();
}