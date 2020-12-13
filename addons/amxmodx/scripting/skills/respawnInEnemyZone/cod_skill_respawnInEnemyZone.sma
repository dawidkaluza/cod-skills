#include <amxmodx>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/spawn>

new g_chanceToRespawn[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToRespawn[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Respawn in enemy zone", "1.0", "d0naciak.pl");
    RegisterHam(Ham_Spawn, "player", "fw_Spawn_Post", 1);
    RegisterHam(Ham_Killed, "player", "fw_Killed_Post", 1);
}

public plugin_natives() {
    register_library("cod_skill_respawnInEnemyZone");

    register_native("Cod_SetPlayerChanceToRespawnInEnemyZone", "Native_SetPlayerChanceToRespawnInEnemyZone");
    register_native("Cod_GetPlayerChanceToRespawnInEnemyZone", "Native_GetPlayerChanceToRespawnInEnemyZone");
}

public client_disconnected(id, bool:drop, message[], len) {
    remove_task(id);
}

public fw_Spawn_Post(id) {
    if (is_user_alive(id)) {
        remove_task(id);
    }
}

public fw_Killed_Post(id, att, shGb) {
    if (!is_user_connected(id)) {
        return HAM_IGNORED;
    }

    if (g_curChanceToRespawn[id] && !random(g_curChanceToRespawn[id])) {
        set_task(0.1, "Task_Respawn", id);
    }

    return HAM_IGNORED;
}

public Task_Respawn(id) {
    SpawnInEnemySpawnZone(id);
}

//Natives
public Native_SetPlayerChanceToRespawnInEnemyZone(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToRespawn[id][skill] = get_param(3);
    new bestSkill = FindLowestValueIfExist(g_chanceToRespawn[id], COD_SKILLS);
    if (bestSkill == -1) {
        g_curChanceToRespawn[id] = 0;
    } else {
        g_curChanceToRespawn[id] = g_chanceToRespawn[id][bestSkill];
    }
}

public Native_GetPlayerChanceToRespawnInEnemyZone(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToRespawn[id][skill];
}