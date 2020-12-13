#include <amxmodx>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>

new g_chanceToStealPerk[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToStealPerk[MAX_PLAYERS + 1];

new g_lastKilledPlayerUserId[MAX_PLAYERS + 1];
new g_lastKilledPlayerPerk[MAX_PLAYERS + 1];
new g_lastKilledPlayerPerkValue[MAX_PLAYERS];
public plugin_init() {
    register_plugin("Cod Skill - Steal perk", "1.0", "Dawid Kałuża");
    RegisterHam(Ham_Killed, "player", "fw_Killed_Post", 1);
}

public plugin_natives() {
    register_library("cod_skill_stealPerk");

    register_native("Cod_SetPlayerChanceToStealPerk", "Native_SetPlayerChanceToStealPerk");
    register_native("Cod_GetPlayerChanceToStealPerk", "Native_GetPlayerChanceToStealPerk");
}

public fw_Killed_Post(id, att, shGb) {
    if (!is_user_connected(att) || get_user_team(id) == get_user_team(att)) {
        return HAM_IGNORED;
    }

    if (g_curChanceToStealPerk[att] && !random(g_curChanceToStealPerk[att])) {
        new perk = g_lastKilledPlayerPerk[att] = cod_get_user_perk(id, g_lastKilledPlayerPerkValue[att]);
        if (perk) {
            g_lastKilledPlayerUserId[att] = get_user_userid(id);

            new perkName[64];
            cod_get_perk_name(perk, perkName, 63);

            new title[192];
            formatex(title, 255, "Chcesz zabrać perk\w %s?", perkName);

            new menu = menu_create(title, "StealPerkMenu_Handler");
            menu_additem(menu, "Tak");
            menu_additem(menu, "Nie");
            menu_display(att, menu);
        }
    }

    return HAM_IGNORED;
}

public StealPerkMenu_Handler(id, menu, item) {
    if (!is_user_connected(id)) {
        menu_destroy(menu);
        return PLUGIN_CONTINUE;
    }

    if (item == 0) {
        new targetId = find_player("k", g_lastKilledPlayerUserId[id]);
        if (targetId) {
            cod_set_user_perk(targetId, 0);
            client_print(targetId, print_center, "Ktoś ukradł Ci perk!");
        }
        
        cod_set_user_perk(id, g_lastKilledPlayerPerk[id], g_lastKilledPlayerPerkValue[id], 0);
        client_print(id, print_center, "Perk został skradziony");
    }

    menu_destroy(menu);
    return PLUGIN_CONTINUE;
}

//Natives
public Native_SetPlayerChanceToStealPerk(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToStealPerk[id][skill] = get_param(3);
    new bestSkill = FindLowestValueIfExist(g_chanceToStealPerk[id], COD_SKILLS);
    if (bestSkill == -1) {
        g_curChanceToStealPerk[id] = 0;
    } else {
        g_curChanceToStealPerk[id] = g_chanceToStealPerk[id][bestSkill];
    }
}

public Native_GetPlayerChanceToStealPerk(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToStealPerk[id][skill];
}