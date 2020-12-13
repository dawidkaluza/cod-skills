#include <amxmodx>
#include <engine>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>

new g_bitSumIgnoredWeapons = ((1<<2)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_KNIFE)|(1<<CSW_C4));
new const g_weaponNames[][] = {
    "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", 
    "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", 
    "weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", 
    "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", 
    "weapon_ak47", "weapon_knife", "weapon_p90" 
};

new const ELECTROMAGNET_CLASSNAME[] = "cod_electromagnet";

enum _:CVARS {
    CVAR_RANGE,
    CVAR_DURATION,
    CVAR_DELAY,
    CVAR_PERIOD_TIME
};
new g_cvars[CVARS];

new g_electromagnetsNum[MAX_PLAYERS + 1][COD_SKILLS];
new g_curSkill[MAX_PLAYERS + 1];
new g_curElectromagnetsNum[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Electromagnet", "1.0", "RiviT & d0naciak");

    g_cvars[CVAR_RANGE] = register_cvar("cod_electromagnet_range", "450.0");
    g_cvars[CVAR_DURATION] = register_cvar("cod_electromagnet_duration", "13.0");
    g_cvars[CVAR_DELAY] = register_cvar("cod_electromagnet_delay", "3.5");
    g_cvars[CVAR_PERIOD_TIME] = register_cvar("cod_electromagnet_periodTime", "0.2");

    register_think(ELECTROMAGNET_CLASSNAME, "fw_ElectromagnetThink");
    register_logevent("ev_RoundStart", 2, "1=Round_Start");
}

public plugin_precache() {
    precache_model("models/QTM_CodMod/electromagnet.mdl");
    precache_sound("weapons/mine_charge.wav");
    precache_sound("weapons/mine_activate.wav");
    precache_sound("weapons/mine_deploy.wav");
}


public plugin_natives() {
    register_library("cod_skill_electromagnet");

    register_native("Cod_SetPlayerElectromagnets", "Native_SetPlayerElectromagnets");
    register_native("Cod_GetPlayerElectromagnets", "Native_GetPlayerElectromagnets");
    register_native("Cod_WillGetAccessToElectromagnets", "Native_WillGetAccessToElectromagnets");
    register_native("Cod_PlantElectromagnet", "Native_PlantElectromagnet");
}

public ev_RoundStart() {
    remove_entity_name(ELECTROMAGNET_CLASSNAME);
    for (new i = 1; i <= MaxClients; i++) {
        if (!is_user_connected(i)) {
            continue;
        }

        new skillId = g_curSkill[i];
        if (skillId != -1) {
            g_curElectromagnetsNum[i] = g_electromagnetsNum[i][skillId];
        }
    }
}

//Natives
public Native_SetPlayerElectromagnets(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_electromagnetsNum[id][skill] = get_param(3);

    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_electromagnetsNum[id], hasSkill);
    new curSkill = GetCurrentSkillByPriority(hasSkill);
    if (curSkill == -1) {
        g_curSkill[id] = -1;
        g_curElectromagnetsNum[id] = 0;

        new ent;
        while ((ent = find_ent_by_owner(ent, ELECTROMAGNET_CLASSNAME, id)) > 0) {
            remove_entity(ent);
        }
    } else {
        g_curSkill[id] = curSkill;
        g_curElectromagnetsNum[id] = g_electromagnetsNum[id][curSkill];
    }
}

public Native_GetPlayerElectromagnets(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_electromagnetsNum[id][skill];
}

public bool:Native_WillGetAccessToElectromagnets(plugin, params) {
    new id = get_param(1);
    new candidatingSkill = get_param(2);
    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_electromagnetsNum[id], hasSkill);
    return WillGetAccessToSkillByPriority(hasSkill, candidatingSkill);
}

public Native_PlantElectromagnet(plugin, params) {
    new id = get_param(1);
    new curSkill = g_curSkill[id];
    if (curSkill == -1) {
        NotifyNoAccessToSkill(id);
        return COD_SKILL_USE_FAIL;
    }

    new skill = get_param(2);
    if (skill != curSkill) {
        NotifyIsNotCurrentSkill(id, curSkill);
        return COD_SKILL_USE_FAIL;
    }

    if (!g_curElectromagnetsNum[id]) {
        client_print(id, print_center, "Nie posiadasz więcej elektromagnesów");
        return COD_SKILL_USE_FAIL;
    }

    new Float:range = get_pcvar_float(g_cvars[CVAR_RANGE]);
    new entities[2];
    if (find_sphere_class(id, ELECTROMAGNET_CLASSNAME, range, entities, sizeof entities)) {
        client_print(id, print_center, "W pobliżu znajduje sie juz jeden elektromagnes");
        return COD_SKILL_USE_FAIL;
    }
    
    if (find_sphere_class(id, "func_bomb_target", 450.0, entities, sizeof entities)) {
        client_print(id, print_center, "Stawianie elektromagnesu w pobliżu BS'a jest zabronione");
        return COD_SKILL_USE_FAIL;
    }

    if (find_sphere_class(id, "hostage_entity", 200.0, entities, sizeof entities)) {
        client_print(id, print_center, "Stawianie elektromagnesu w pobliżu hostow jest zabronione");
        return COD_SKILL_USE_FAIL;
    }
    
    new Float:origin[3], Float:gametime = get_gametime();
    entity_get_vector(id, EV_VEC_origin, origin);
    
    new ent = create_entity("info_target");
    entity_set_string(ent, EV_SZ_classname, ELECTROMAGNET_CLASSNAME);
    entity_set_edict(ent, EV_ENT_owner, id);
    entity_set_int(ent, EV_INT_solid, SOLID_NOT);
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
    entity_set_vector(ent, EV_VEC_origin, origin);
    
    entity_set_model(ent, "models/QTM_CodMod/electromagnet.mdl");
    drop_to_floor(ent);
    
    emit_sound(ent, CHAN_VOICE, "weapons/mine_charge.wav", 0.5, ATTN_NORM, 0, PITCH_NORM );
    emit_sound(ent, CHAN_ITEM, "weapons/mine_deploy.wav", 0.5, ATTN_NORM, 0, PITCH_NORM );
    
    entity_set_float(ent, EV_FL_nextthink, gametime + get_pcvar_float(g_cvars[CVAR_DELAY]));
    entity_set_float(ent, EV_FL_ltime, gametime + get_pcvar_float(g_cvars[CVAR_DURATION]));

    if(--g_electromagnetsNum[id][skill] > 0) {
        return COD_SKILL_USE_AVAILABLE;
    }

    return COD_SKILL_USE_NAVAILABLE;
}

public fw_ElectromagnetThink(ent) {
    static id, Float:forigin[3], entlist[33], numfound, i, n, pid, num, wpn[32], Float:gametime;
    id = entity_get_edict(ent, EV_ENT_owner);
    gametime = halflife_time();
    
    if(!is_user_alive(id)) {
        remove_entity(ent);
        return PLUGIN_HANDLED;
    }

    if(entity_get_int(ent, EV_INT_iuser1) == 0) {
        emit_sound(ent, CHAN_VOICE, "weapons/mine_activate.wav", 0.5, ATTN_NORM, 0, PITCH_NORM);
        entity_set_int(ent, EV_INT_iuser1, 1);
    }

    if(entity_get_float(ent, EV_FL_ltime) < gametime) {
        remove_entity(ent);
        return PLUGIN_HANDLED;
    }

    new Float:range = get_pcvar_float(g_cvars[CVAR_RANGE]);
    numfound = find_sphere_class(ent, "player", get_pcvar_float(g_cvars[CVAR_RANGE]), entlist, 32);
    
    num = 0
    
    for (i = 0; i < numfound; i++) {
        pid = entlist[i];

        if (!is_user_alive(pid) || get_user_team(pid) == get_user_team(id)) {
            continue;
        }
        
        get_user_weapons(pid, wpn, num)

        for(n = 0; n < num; n++) {
            if(1<<wpn[n] & g_bitSumIgnoredWeapons) continue;

            engclient_cmd(pid, "drop", g_weaponNames[wpn[n]]);
        }
    }
    
    numfound = find_sphere_class(ent, "weaponbox", range + 100.0, entlist, 32);
    for (i = 0; i < numfound; i++) {
        if(get_entity_distance(ent, entlist[i]) > 50.0) {
            entity_get_vector(ent, EV_VEC_origin, forigin);
            set_velocity_to_origin(entlist[i], forigin, 700.0);
        }
    }

    entity_set_float(ent, EV_FL_nextthink, halflife_time() + get_pcvar_float(g_cvars[CVAR_PERIOD_TIME]));
    return PLUGIN_HANDLED;
}

stock get_velocity_to_origin( ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3] )
{
    new Float:fEntOrigin[3];
    entity_get_vector( ent, EV_VEC_origin, fEntOrigin );

    // Velocity = Distance / Time

    new Float:fDistance[3];
    fDistance[0] = fEntOrigin[0] - fOrigin[0];
    fDistance[1] = fEntOrigin[1] - fOrigin[1];
    fDistance[2] = fEntOrigin[2] - fOrigin[2];

    new Float:fTime = -( vector_distance( fEntOrigin,fOrigin ) / fSpeed );

    fVelocity[0] = fDistance[0] / fTime;
    fVelocity[1] = fDistance[1] / fTime;
    fVelocity[2] = fDistance[2] / fTime + 50.0;

    return ( fVelocity[0] && fVelocity[1] && fVelocity[2] );
}

stock set_velocity_to_origin( ent, Float:fOrigin[3], Float:fSpeed )
{
    new Float:fVelocity[3];
    get_velocity_to_origin( ent, fOrigin, fSpeed, fVelocity )

    entity_set_vector( ent, EV_VEC_velocity, fVelocity );
}