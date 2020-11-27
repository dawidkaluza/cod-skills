#include <amxmodx>

new bool:g_isPlayerInvulnerableToBlind[MAX_PLAYERS + 1];
new g_msgScreenFade;
public plugin_init() {
    register_plugin("Cod Basic Skill - Blind", "1.0", "d0naciak.pl");
    g_msgScreenFade = get_user_msgid("ScreenFade");
    register_message(g_msgScreenFade, "msg_ScreenFade");
}

public plugin_natives() {
    register_library("cod_basicSkill_blind");

    register_native("Cod_BlindPlayer", "Native_BlindPlayer");
    register_native("Cod_SetPlayerInvulnerabilityToBlind", "Native_SetPlayerInvulnerabilityToBlind");
    register_native("Cod_GetPlayerInvulnerabilityToBlind", "Native_GetPlayerInvulnerabilityToBlind");
}

public msg_ScreenFade(msgType, msgId, id) {
    if (g_isPlayerInvulnerableToBlind[id]) {
        return PLUGIN_HANDLED;
    }

    return PLUGIN_CONTINUE;
}

//Natives
public Native_BlindPlayer(plugin, params) {
    new id = get_param(1);
    if (g_isPlayerInvulnerableToBlind[id]) {
        return;
    }

    new duration = get_param(2);
    new red = get_param(3);
    new green = get_param(4);
    new blue = get_param(5);
    new alpha = get_param(6);
    Display_Fade(id, (1<<12) * duration, 1<<8, 1<<16, red, green, blue, alpha);
}

public Native_SetPlayerInvulnerabilityToBlind(plugin, params) {
    new id = get_param(1);
    new bool:value = bool:get_param(2);
    g_isPlayerInvulnerableToBlind[id] = value;
}

public bool:Native_GetPlayerInvulnerabilityToBlind(plugin, params) {
    new id = get_param(1);
    return g_isPlayerInvulnerableToBlind[id];
}

stock Display_Fade(id, duration, holdTime, fadeType, red, green, blue, alpha) {
	message_begin( id ? MSG_ONE : MSG_ALL, g_msgScreenFade, {0,0,0}, id );
	write_short( duration );	// Duration of fadeout
	write_short( holdTime );	// Hold time of color
	write_short( fadeType );	// Fade type
	write_byte ( red );			// Red
	write_byte ( green );		// Green
	write_byte ( blue );		// Blue
	write_byte ( alpha );		// Alpha
	message_end();
}