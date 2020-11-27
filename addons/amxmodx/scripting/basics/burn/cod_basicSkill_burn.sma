#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>

enum _:SPRITES {
    SPRITE_FIRE,
    SPRITE_SMOKE
};
new g_sprites[SPRITES];

new const g_hitSounds[] = {
    "player/bhit_flesh-1.wav",
    "player/bhit_flesh-2.wav",
    "player/bhit_flesh-3.wav"
};

new g_msgStatusIcon;
new g_pcvarOverrideBurning;

new bool:g_hasPlayerInvulnerabilityToBurn[MAX_PLAYERS + 1];

public plugin_init() {
    register_plugin("Cod Basic Skill - Burn", "1.0", "d0naciak.pl");

    g_pcvarOverrideBurning = register_cvar("cod_basic_skill_burning_override", "1");

    RegisterHam(Ham_Spawn, "player", "fw_Spawn_Post", 1);
    RegisterHam(Ham_Killed, "player", "fw_Killed_Post", 1);

    g_msgStatusIcon = get_user_msgid("StatusIcon");
}

public plugin_natives() {
    register_library("cod_basicSkill_burn");

    register_native("Cod_BurnPlayer", "Native_BurnPlayer");

    register_native("Cod_SetPlayerInvulnerabilityToBurn", "Native_SetPlayerInvulnerabilityToBurn");
    register_native("Cod_GetPlayerInvulnerabilityToBurn", "Native_GetPlayerInvulnerabilityToBurn");
}

public plugin_precache() {
    g_sprites[SPRITE_FIRE] = precache_model("sprites/fire.spr");
    g_sprites[SPRITE_SMOKE] = precache_model("sprites/steam1.spr");

    for (new i = 0; i < sizeof g_hitSounds; i++) {
        precache_sound(g_hitSounds[i]);
    }
}

public client_disconnected(id, bool:drop, message[], messageLen) {
    remove_task(id);
}

public fw_Spawn_Post(id) {
    if (!is_user_alive(id)) {
        return HAM_IGNORED;
    }

    remove_task(id);
    HideFireIcon(id);
    return HAM_IGNORED;
}

public fw_Killed_post(id) {
    if (!is_user_connected(id)) {
        return HAM_IGNORED;
    }

    remove_task(id);
    HideFireIcon(id);
    return HAM_IGNORED;
}

public Task_Burn(data[4], id) {
    if (g_hasPlayerInvulnerabilityToBurn[id]) {
        HideFireIcon(id);
        return PLUGIN_CONTINUE;
    }

    //TODO if player will disconnect the server and quickly after this new player will connect "att" can indicate to wrong player
    new att = data[0];
    if (!is_user_connected(att)) {
        HideFireIcon(id);
        return PLUGIN_CONTINUE;
    }

    new origin[3];
    get_user_origin(id, origin);
    if (pev(id, pev_flags) & FL_INWATER) {
        message_begin(MSG_PVS, SVC_TEMPENTITY, origin);
        write_byte(TE_SMOKE);
        write_coord(origin[0]);
        write_coord(origin[1]);
        write_coord(origin[2] - 50);
        write_short(g_sprites[SPRITE_SMOKE]);
        write_byte(random_num(15,20));
        write_byte(random_num(10,20));
        message_end();
        HideFireIcon(id);
        return PLUGIN_CONTINUE;
    }

    message_begin(MSG_PVS, SVC_TEMPENTITY, origin);
    write_byte(TE_SPRITE);
    write_coord(origin[0] + random_num(-5,5));
    write_coord(origin[1] + random_num(-5,5));
    write_coord(origin[2] + random_num(-10,10));
    write_short(g_sprites[SPRITE_FIRE]);
    write_byte(random_num(5,10));
    write_byte(200);

    new Float:damage = Float:data[3];
    new Float:health;
    pev(id, pev_health, health);
    if(floatround(damage, floatround_tozero) >= floatround(health, floatround_ceil)) {
        ExecuteHam(Ham_TakeDamage, id, att, att, health * 5.0, (1<<3));
    } else {
        set_pev(id, pev_health, health - damage);
        emit_sound(id, CHAN_ITEM, g_hitSounds[random(3)], 0.4, ATTN_NORM, 0, PITCH_LOW);
    }

    if (--data[2]) {
        set_task(Float:data[1], "Task_Burn", id, data, 4);
    } else {
        HideFireIcon(id);
    }

    return PLUGIN_CONTINUE;
}

//Natives
public Native_BurnPlayer(plugin, params) {
    new target = get_param(2);
    if (g_hasPlayerInvulnerabilityToBurn[target]) {
        return;
    }

    if (task_exists(target)) {
        if (get_pcvar_bool(g_pcvarOverrideBurning)) {
            remove_task(target);
        } else {
            return;
        }
    }

    new id = get_param(1);
    new Float:periodTime = get_param_f(3);
    new num = get_param(4);
    new Float:damage = get_param_f(5);

    ShowFireIcon(target);
    new data[4];
    data[0] = id;
    data[1] = _:periodTime;
    data[2] = num;
    data[3] = _:damage;
    Task_Burn(data, target);
}

public Native_SetPlayerInvulnerabilityToBurn(plugin, params) {
    new id = get_param(1);
    g_hasPlayerInvulnerabilityToBurn[id] = bool:get_param(2);
}

public bool:Native_GetPlayerInvulnerabilityToBurn(plugin, params) {
    new id = get_param(1);
    return g_hasPlayerInvulnerabilityToBurn[id];
}

ShowFireIcon(id) {
    show_icon(id, 1, "dmg_heat", 255, 0, 0);
}

HideFireIcon(id) {
    show_icon(id, 0, "dmg_heat");
}

show_icon(id, status, const name[] = "", r=0, g=255, b=0) {
    message_begin(id ? MSG_ONE : MSG_ALL, g_msgStatusIcon, _, id);
    write_byte(status); // status (0=hide, 1=show, 2=flash)
    write_string(name); // sprite name ""dmg_cold"
    write_byte(r); // red
    write_byte(g); // green
    write_byte(b); // blue
    message_end();
}