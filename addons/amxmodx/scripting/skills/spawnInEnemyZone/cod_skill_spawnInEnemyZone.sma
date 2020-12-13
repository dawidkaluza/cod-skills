#include <amxmodx>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/spawn>

new g_chanceToSpawn[MAX_PLAYERS + 1][COD_SKILLS];
new g_curChanceToSpawn[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Spawn in enemy zone", "1.0", "d0naciak.pl");
    register_logevent("ev_RoundStart", 2, "1=Round_Start");
}

public plugin_natives() {
    register_library("cod_skill_spawnInEnemyZone");

    register_native("Cod_SetPlayerChanceToSpawnInEnemyZone", "Native_SetPlayerChanceToSpawnInEnemyZone");
    register_native("Cod_SetPlayerChanceToSpawnInEnemyZone", "Native_GetPlayerChanceToSpawnInEnemyZone");
}

public ev_RoundStart() {
    for (new i = 1; i <= MaxClients; i++) {
        if (!is_user_connected(i)) {
            continue;
        }

        if (g_curChanceToSpawn[i] && !random(g_curChanceToSpawn[i])) {
            SpawnInEnemySpawnZone(i);
        }
    }
}

//Natives
public Native_SetPlayerChanceToSpawnInEnemyZone(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToSpawn[id][skill] = get_param(3);
    new bestSkill = FindLowestValueIfExist(g_chanceToSpawn[id], COD_SKILLS);
    if (bestSkill == -1) {
        g_curChanceToSpawn[id] = 0;
    } else {
        g_curChanceToSpawn[id] = g_chanceToSpawn[id][bestSkill];
    }
}

public Native_GetPlayerChanceToSpawnInEnemyZone(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToSpawn[id][skill];
}