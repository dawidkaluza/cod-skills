#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/burn>

new const MINE_CLASSNAME[] = "cod_burningMine";

enum _:CVARS {
    CVAR_DAMAGE,
    CVAR_BURNS_NUM,
    CVAR_PERIOD_TIME,
    CVAR_INT_MULTIPLIER
};
new g_pcvar[CVARS];

new g_minesNum[MAX_PLAYERS + 1][COD_SKILLS];
new g_curMinesSkill[MAX_PLAYERS + 1];
new g_curMinesNum[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Burning mine", "1.0", "d0naciak.pl");

    if (!LibraryExists("cod_basicSkill_burn", LibType_Library)) {
        set_fail_state("Cant load cod_basicSkill_burn library");
        return;
    }
    
    g_pcvar[CVAR_DAMAGE] = register_cvar("cod_skill_burningMine_damage", "5.0");
    g_pcvar[CVAR_BURNS_NUM] = register_cvar("cod_skill_burningMine_num", "10");
    g_pcvar[CVAR_PERIOD_TIME] = register_cvar("cod_skill_burningMine_period_time", "0.4");
    g_pcvar[CVAR_INT_MULTIPLIER] = register_cvar("cod_skill_burningMine_int_multiplier", "0.02");

    register_logevent("ev_RoundStart", 2, "1=Round_Start");
    register_event("TeamInfo","ev_TeamInfo", "a");
    register_touch(MINE_CLASSNAME, "player", "fw_MineTouch");
}

public plugin_precache() {
    precache_model("models/QTM_CodMod/mine.mdl");
    precache_sound("weapons/mine_activate.wav");
}

public plugin_natives() {
    register_library("cod_skill_burningMine");

    register_native("Cod_SetPlayerBurningMines", "Native_SetPlayerBurningMines");
    register_native("Cod_GetPlayerBurningMines", "Native_SetPlayerBurningMines");
    register_native("Cod_PlantBurningMine", "Native_PlantBurningMine");
}

public ev_RoundStart() {
    remove_entity_name(MINE_CLASSNAME);

    for (new i = 1; i <= MaxClients; i++) {
        if (!is_user_connected(i)) {
            continue;
        }

        new skillId = g_curMinesSkill[i];
        if (skillId != -1) {
            g_curMinesNum[i] = g_minesNum[i][skillId];
        }
    }
}

public ev_TeamInfo() {
    new id = read_data(1);
    if (!is_user_connected(id)) {
        return PLUGIN_CONTINUE;
    }

    RemovePlayerMines(id);
    return PLUGIN_CONTINUE;
}

public fw_MineTouch(ent, id) {
    if (!is_valid_ent(ent) || !is_user_alive(id)) {
        return PLUGIN_CONTINUE;
    }

    new owner = entity_get_edict(ent, EV_ENT_owner);
    if(get_user_team(owner) != get_user_team(id)) {
        Cod_BurnPlayer(
            owner, id, 
            get_pcvar_float(g_pcvar[CVAR_PERIOD_TIME]), get_pcvar_num(g_pcvar[CVAR_BURNS_NUM]), 
            get_pcvar_float(g_pcvar[CVAR_DAMAGE]) + get_pcvar_float(g_pcvar[CVAR_INT_MULTIPLIER]) * cod_get_user_intelligence(owner)
        );
        remove_entity(ent);
    }
    
    return PLUGIN_CONTINUE;
}

RemovePlayerMines(id) {
    new ent;
    while ((ent = find_ent_by_owner(ent, "cod_burningMine", id)) > 0) {
        remove_entity(ent);
    }
}

//Natives
public Native_SetPlayerBurningMines(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_minesNum[id][skill] = get_param(3);
    new bestId = FindHighestValueIfExist(g_minesNum[id], skill);
    if (bestId == -1) {
        g_curMinesSkill[id] = -1;
        g_curMinesNum[id] = 0;
    } else {
        g_curMinesSkill[id] = bestId;
        g_curMinesNum[id] = g_minesNum[id][bestId];
    }
}

public Native_GetPlayerBurningMines(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_minesNum[id][skill];
}

public Native_PlantBurningMine(plugin, params) {
    new id = get_param(1);
    new curSkill = g_curMinesSkill[id];
    if (curSkill == -1) {
        NotifyNoAccessToSkill(id);
        return COD_SKILL_USE_FAIL;
    }

    new skill = get_param(2);
    if (skill != curSkill) {
        NotifyIsNotCurrentSkill(id, curSkill);
        return COD_SKILL_USE_FAIL;
    }

    if (!g_curMinesNum[id]) {
        client_print(id, print_center, "Nie posiadasz więcej min");
        return COD_SKILL_USE_FAIL;
    }

    new entities[2];
    if (find_sphere_class(id, MINE_CLASSNAME, 52.0, entities, sizeof entities)) {
        client_print(id, print_center, "Stawianie min blisko siebie jest zabronione");
        return COD_SKILL_USE_FAIL;
    }

    if(find_sphere_class(id, "grenade", 64.0, entities, sizeof entities)) {
        client_print(id, print_center, "Stawianie min na bombie jest zabronione");
        return COD_SKILL_USE_FAIL;
    }

    new players[MAX_PLAYERS];
    new playersNum = find_sphere_class(id, "player", 96.0, players, MAX_PLAYERS);

    new targetId;
    for (new i = 0; i < playersNum; i++) {
        targetId = players[i];
        if (is_user_alive(targetId) && id != targetId) {
            client_print(id, print_center, "Jesteś za blisko innego gracza");
            return COD_SKILL_USE_FAIL;
        }
    }
    
    if(
        entity_get_int(id, EV_INT_movetype) == MOVETYPE_FLY || 
        !(entity_get_int(id, EV_INT_flags) & FL_ONGROUND)
    ) {
        client_print(id, print_center, "Stawiając miny musisz stać na jakimś podłożu");
        return COD_SKILL_USE_FAIL;
    }
        
    new Float:position[3];
    entity_get_vector(id, EV_VEC_origin, position);

    new ent = create_entity("info_target");
    entity_set_string(ent, EV_SZ_classname, MINE_CLASSNAME);
    entity_set_edict(ent, EV_ENT_owner, id);
    entity_set_int(ent, EV_INT_iuser2, skill);
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
    entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
    entity_set_origin(ent, position);
    entity_set_model(ent, "models/QTM_CodMod/mine.mdl");
    entity_set_size(ent, Float:{-16.0, -16.0, 0.0}, Float:{16.0, 16.0, 2.0});
    set_rendering(ent, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 70);
    drop_to_floor(ent);
    emit_sound(ent, CHAN_ITEM, "weapons/mine_activate.wav", VOL_NORM, ATTN_NORM, 0, PITCH_LOW);

    if(--g_curMinesNum[id] <= 0) {
        return COD_SKILL_USE_NAVAILABLE;
    }

    return COD_SKILL_USE_AVAILABLE;
}