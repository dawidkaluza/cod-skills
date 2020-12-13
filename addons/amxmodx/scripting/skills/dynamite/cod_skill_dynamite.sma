#include <amxmodx>
#include <fakemeta_util>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>

new const DYNAMITE_CLASSNAME[] = "cod_dynamite";

new g_dynamitesNum[MAX_PLAYERS + 1][COD_SKILLS];
new Float:g_dynamiteDamage[MAX_PLAYERS + 1][COD_SKILLS];
new Float:g_dynamiteDamagePerInt[MAX_PLAYERS + 1][COD_SKILLS];
new g_curDynamitesSkill[MAX_PLAYERS + 1];
new g_curDynamitesNum[MAX_PLAYERS + 1];
new g_plantedDynamiteId[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Dynamite", "1.0", "d0naciak.pl");

    register_logevent("ev_RoundStart", 2, "1=Round_Start");
    register_event("TeamInfo","ev_TeamInfo", "a");
}

public plugin_precache() {
    precache_model("models/QTM_CodMod/dynamite.mdl");
    precache_sound("weapons/mine_activate.wav");
}

public plugin_natives() {
    register_library("cod_skill_dynamite");

    register_native("Cod_SetPlayerDynamites", "Native_SetPlayerDynamites");
    register_native("Cod_GetPlayerDynamites", "Native_GetPlayerDynamites");
    register_native("Cod_ActivateDynamite", "Native_ActivateDynamite");
    register_native("Cod_WillGetAccessToDynamites", "Native_WillGetAccessToDynamites");
}

public ev_RoundStart() {
    fm_remove_entity_name(DYNAMITE_CLASSNAME);

    for (new i = 1; i <= MaxClients; i++) {
        if (!is_user_connected(i)) {
            continue;
        }

        g_plantedDynamiteId[i] = 0;
        new skillId = g_curDynamitesSkill[i];
        if (skillId != -1) {
            g_curDynamitesNum[i] = g_dynamitesNum[i][skillId];
        }
    }
}

public ev_TeamInfo() {
    new id = read_data(1);
    if (!is_user_connected(id)) {
        return PLUGIN_CONTINUE;
    }

    RemovePlayerDynamite(id);
    return PLUGIN_CONTINUE;
}

//Natives
public Native_SetPlayerDynamites(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_dynamitesNum[id][skill] = get_param(3);
    g_dynamiteDamage[id][skill] = get_param_f(4);
    g_dynamiteDamagePerInt[id][skill] = get_param_f(5);

    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_dynamitesNum[id], hasSkill);
    new curSkill = GetCurrentSkillByPriority(hasSkill);
    if (curSkill == -1) {
        RemovePlayerDynamite(id);
        g_curDynamitesSkill[id] = -1;
        g_curDynamitesNum[id] = 0;
    } else {
        if (g_curDynamitesSkill[id] != curSkill) {
            RemovePlayerDynamite(id);
        }

        g_curDynamitesSkill[id] = curSkill;
        g_curDynamitesNum[id] = g_dynamitesNum[id][curSkill];
    }
}

public Native_GetPlayerDynamites(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_dynamitesNum[id][skill];
}

public Native_ActivateDynamite(plugin, params) {
    new id = get_param(1);
    new curSkill = g_curDynamitesSkill[id];
    if (curSkill == -1) {
        NotifyNoAccessToSkill(id);
        return COD_SKILL_USE_FAIL;
    }

    new skill = get_param(2);
    if (skill != curSkill) {
        NotifyIsNotCurrentSkill(id, curSkill);
        return COD_SKILL_USE_FAIL;
    }

    if (g_plantedDynamiteId[id]) {
        new ent = g_plantedDynamiteId[id];
        if (!pev_valid(ent)) {
            client_print(id, print_center, "Nie znaleziono Twojego dynamitu");
            return COD_SKILL_USE_FAIL;
        }

        return BlowUpDynamite(id, curSkill, ent);
    }
    
    return PlantDynamite(id, curSkill);
}

public bool:Native_WillGetAccessToDynamites(plugin, params) {
    new id = get_param(1);
    new candidatingSkill = get_param(2);
    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_dynamitesNum[id], hasSkill);
    return WillGetAccessToSkillByPriority(hasSkill, candidatingSkill);
}

PlantDynamite(id, skill) {
    if (!g_curDynamitesNum[id]) {
        client_print(id, print_center, "Nie posiadasz więcej dynamitów");
        return COD_SKILL_USE_FAIL;
    }

    new entities[2];
    if(fm_find_sphere_class(id, DYNAMITE_CLASSNAME, 52.0, entities, sizeof entities)) {
        client_print(id, print_center, "Stawianie dynamitów tak blisko siebie jest zabronione");
        return COD_SKILL_USE_FAIL;
    }
    
    if(fm_find_sphere_class(id, "grenade", 64.0, entities, sizeof entities)) {
        client_print(id, print_center, "Stawianie dynamitów na bombie jest zabronione");
        return COD_SKILL_USE_FAIL;
    }
    
    new players[MAX_PLAYERS];
    new playersNum = fm_find_sphere_class(id, "player", 96.0, players, MAX_PLAYERS);

    new targetId;
    for (new i = 0; i < playersNum; i++) {
        targetId = players[i];
        if (is_user_alive(targetId) && id != targetId) {
            client_print(id, print_center, "Jesteś za blisko innego gracza");
            return COD_SKILL_USE_FAIL;
        }
    }
    
    if(
        pev(id, pev_movetype) == MOVETYPE_FLY || 
        !(pev(id, pev_flags) & FL_ONGROUND)
    ) {
        client_print(id, print_center, "Stawiając dynamity musisz stać na jakimś podłożu");
        return COD_SKILL_USE_FAIL;
    }
    
    new Float:position[3];
    pev(id, pev_origin, position);

    new ent = g_plantedDynamiteId[id] = fm_create_entity("info_target");
    set_pev(ent, pev_classname, DYNAMITE_CLASSNAME);
    set_pev(ent, pev_owner, id);
    set_pev(ent, pev_iuser1, skill);
    set_pev(ent, pev_movetype, MOVETYPE_TOSS);
    set_pev(ent, pev_solid, SOLID_BBOX);
    engfunc(EngFunc_SetOrigin, ent, position);
    engfunc(EngFunc_SetModel, ent, "models/QTM_CodMod/dynamite.mdl");
    engfunc(EngFunc_SetSize, ent, Float:{-16.0, -16.0, 0.0}, Float:{16.0, 16.0, 2.0})
    fm_drop_to_floor(ent);

    emit_sound(ent, CHAN_ITEM, "weapons/mine_activate.wav", VOL_NORM, ATTN_NORM, 0, PITCH_LOW);
    g_curDynamitesNum[id] --;
    return COD_SKILL_USE_AVAILABLE;
}

BlowUpDynamite(id, skill, ent) {
    cod_make_explosion(id, ent, g_dynamiteDamage[id][skill], g_dynamiteDamagePerInt[id][skill], 250.0);
    fm_remove_entity(ent);
    g_plantedDynamiteId[id] = 0;
    
    if(g_curDynamitesNum[id] <= 0) {
        return COD_SKILL_USE_NAVAILABLE;
    }

    return COD_SKILL_USE_AVAILABLE
}

RemovePlayerDynamite(id) {
    new ent;
    while ((ent = fm_find_ent_by_owner(ent, DYNAMITE_CLASSNAME, id)) > 0) {
        fm_remove_entity(ent);
    }
    g_plantedDynamiteId[id] = 0;
}

stock fm_find_sphere_class(id, const classname2[], Float:distance, entlist[], len)
{
	new Float:origin[3];
	pev(id, pev_origin, origin);
	
	new ent, i;
	new classname[32];
	while((ent = fm_find_ent_in_sphere(ent, origin, distance)) != 0) 
	{
		pev(ent, pev_classname, classname, 31);
		if(equal(classname, classname2) && fm_is_ent_visible(id, ent))
		{
			entlist[i] = ent;
			i++;
		}
		if(i >= len)
			break;
	}
	return i;
}