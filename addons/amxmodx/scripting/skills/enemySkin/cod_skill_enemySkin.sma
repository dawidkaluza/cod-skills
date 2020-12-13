#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>

new g_chanceToGetEnemySkin[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToGetEnemySkin[MAX_PLAYERS + 1];

new g_weaponAssociatedWithSkin[MAX_PLAYERS + 1][2][COD_SKILLS];
new g_curWeaponAssociatedWithSkin[MAX_PLAYERS + 1][2];

public plugin_init() {
    register_plugin("Cod Skill - Enemy skin", "1.0", "d0naciak.pl");

    RegisterHam(Ham_Spawn, "player", "fw_Spawn_Post", 1);
    new weaponName[32];
    for (new i = 1; i <= CSW_LAST_WEAPON; i++) {
        if (!(CSW_ALL_WEAPONS & (1<<i))) {
            continue;
        }

        get_weaponname(i, weaponName, charsmax(weaponName));
        RegisterHam(Ham_Item_Deploy, weaponName, "fw_ItemDeploy_Post", 1);
        RegisterHam(Ham_Item_AddToPlayer, weaponName, "fw_ItemAddToPlayer_Post", 1);
    }
}

public plugin_natives() {
    register_library("cod_skill_enemySkin");

    register_native("Cod_SetPlayerChanceToGetEnemySkin", "Native_SetPlayerChanceToGetEnemySkin");
    register_native("Cod_GetPlayerChanceToGetEnemySkin", "Native_GetPlayerChanceToGetEnemySkin");
    
    register_native("Cod_AssociateWeaponWithSkin", "Native_AssociateWeaponWithSkin");
    register_native("Cod_GetWeaponAssociatedWithSkin", "Native_GetWeaponAssociatedWithSkin");
}

public fw_Spawn_Post(id) {
    if (!is_user_alive(id)) {
        return HAM_IGNORED;
    }

    if (g_curChanceToGetEnemySkin[id] && !random(g_curChanceToGetEnemySkin[id])) {
        SetPlayerSkin(id, get_user_team(id) == 1 ? 2 : 1);
    } else if (!g_curWeaponAssociatedWithSkin[id][0]) {
        cs_reset_user_model(id);
    }
    return HAM_IGNORED;
}

public fw_ItemAddToPlayer_Post(ent, id) {
    if (!pev_valid(ent) || !is_user_alive(id)) {
        return HAM_IGNORED;
    }

    new data[1];
    data[0] = cs_get_weapon_id(ent);
    remove_task(id);
    set_task(0.1, "Task_ItemAddToPlayer", id, data, sizeof data);
    return HAM_IGNORED;
}

public Task_ItemAddToPlayer(data[1], id) {
    if (!is_user_alive(id)) {
        return PLUGIN_CONTINUE;
    }

    new addedWeapon;
    if (addedWeapon == get_user_weapon(id)) {
        SwitchWeapon(id, addedWeapon);
    }

    return PLUGIN_CONTINUE;
}

public fw_ItemDeploy_Post(ent) {
    if (!pev_valid(ent)) {
        return HAM_IGNORED;
    }

    new id = pev(ent, pev_owner);
    if (!is_user_alive(id)) {
        return HAM_IGNORED;
    }

    SwitchWeapon(id, cs_get_weapon_id(ent));
    return HAM_IGNORED;
}

SwitchWeapon(id, weapon) {
    if (g_curWeaponAssociatedWithSkin[id][0] == weapon) {
        SetPlayerSkin(id, 1);
    } else if (g_curWeaponAssociatedWithSkin[id][1] == weapon) {
        SetPlayerSkin(id, 2);
    }
}

//Natives
public Native_SetPlayerChanceToGetEnemySkin(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToGetEnemySkin[id][skill] = get_param(3);

    new bestSkill = FindLowestValueIfExist(g_chanceToGetEnemySkin[id], COD_SKILLS);
    if (bestSkill == -1) {
        g_curChanceToGetEnemySkin[id] = 0;
        
        if (is_user_alive(id) && !g_curWeaponAssociatedWithSkin[id][0]) {
            cs_reset_user_model(id);
        }
    } else {
        g_curChanceToGetEnemySkin[id] = g_chanceToGetEnemySkin[id][bestSkill];
    }
}

public Native_GetPlayerChanceToGetEnemySkin(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToGetEnemySkin[id][skill];
}

public Native_AssociateWeaponWithSkin(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_weaponAssociatedWithSkin[id][0][skill] = get_param(3);
    g_weaponAssociatedWithSkin[id][1][skill] = get_param(4);
    
    new bool:hasSkill[COD_SKILLS];
    ConvertValuesToBooleans(g_weaponAssociatedWithSkin[id][0], hasSkill);
    new curSkill = GetCurrentSkillByPriority(hasSkill);
    if (curSkill == -1) {
        g_curWeaponAssociatedWithSkin[id][0] = 0;
        g_curWeaponAssociatedWithSkin[id][1] = 0;

        if (is_user_alive(id) && !g_curChanceToGetEnemySkin[id]) {
            cs_reset_user_model(id);
        }
    } else {
        g_curWeaponAssociatedWithSkin[id][0] = g_weaponAssociatedWithSkin[id][0][curSkill];
        g_curWeaponAssociatedWithSkin[id][1] = g_weaponAssociatedWithSkin[id][1][curSkill];
    }
}

public Native_GetWeaponAssociatedWithSkin(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new team = get_param(3) - 1;
    return g_weaponAssociatedWithSkin[id][team][skill];
}

SetPlayerSkin(id, team) {
    static const models[][][] = {
        { "arctic","leet","guerilla","terror" },
        { "sas","gsg9","urban","gign" }
    };

    cs_set_user_model(id, models[team-1][random(4)]);
}