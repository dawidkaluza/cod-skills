#include <amxmodx>
#include <cstrike>
#include <engine>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/effects/barTime>

#define TASK_ECLIPSE 333

new g_eclipsesNum[MAX_PLAYERS + 1][COD_SKILLS];
new g_eclipseDuration[MAX_PLAYERS + 1][COD_SKILLS];
new g_curSkill[MAX_PLAYERS + 1];
new g_curEclipsesNum[MAX_PLAYERS + 1];
new g_eclipseActivator;
public plugin_init() {
    register_plugin("Cod Skill - Eclipse", "1.0", "d0naciak.pl");

    register_logevent("ev_RoundStart", 2, "1=Round_Start");
}

public plugin_natives() {
    register_library("cod_skill_eclipse");

    register_native("Cod_SetPlayerEclipses", "Native_SetPlayerEclipses");
    register_native("Cod_GetPlayerEclipses", "Native_GetPlayerEclipses");
    register_native("Cod_ActivateEclipse", "Native_ActivateEclipse");
}

public client_disconnected(id, bool:drop, message[], len) {
    if (id == g_eclipseActivator) {
        g_eclipseActivator = 0;
    }
}

public ev_RoundStart() {
    if (g_eclipseActivator) {
        cs_set_user_nvg(g_eclipseActivator, 0);
        g_eclipseActivator = 0;
    }

    if (task_exists(TASK_ECLIPSE)) {
        remove_task(TASK_ECLIPSE);
        set_lights("#OFF");
    }

    for (new i = 1; i <= MaxClients; i++) {
        if (!is_user_connected(i)) {
            continue;
        }

        new skillId = g_curSkill[i];
        if (skillId != -1) {
            g_curEclipsesNum[i] = g_eclipsesNum[i][skillId];
        }
    }
}

//Natives
public Native_SetPlayerEclipses(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_eclipsesNum[id][skill] = get_param(3);
    g_eclipseDuration[id][skill] = get_param(4);

    new bestSkill = FindHighestValueIfExist(g_eclipsesNum[id], COD_SKILLS);
    if (bestSkill == -1) {
        g_curSkill[id] = -1;
        g_curEclipsesNum[id] = 0;
    } else {
        g_curSkill[id] = bestSkill;
        g_curEclipsesNum[id] = g_eclipsesNum[id][bestSkill];
    }
}

public Native_GetPlayerEclipses(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_eclipsesNum[id][skill];
}

public Native_ActivateEclipse(plugin, params) {
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

    if (!g_curEclipsesNum[id]) {
        client_print(id, print_center, "Nie posiadasz więcej zaćmień");
        return COD_SKILL_USE_FAIL;
    }
    
    if (task_exists(TASK_ECLIPSE)) {
        client_print(id, print_center, "Zaćmienie jest już aktywne");
        return COD_SKILL_USE_FAIL;
    }

    set_lights("a");
    cs_set_user_nvg(id, 1);
    client_cmd(id, "nightvision");
    g_eclipseActivator = id;

    new duration = g_eclipseDuration[id][skill];
    set_task(float(duration), "Task_EclipseEnd", TASK_ECLIPSE);
    Cod_SetPlayerBarTime(id, duration);

    if (--g_curEclipsesNum[id] <= 0) {
        return COD_SKILL_USE_NAVAILABLE;
    }

    return COD_SKILL_USE_AVAILABLE;
}

public Task_EclipseEnd() {
    set_lights("#OFF");

    if (g_eclipseActivator) {
        cs_set_user_nvg(g_eclipseActivator, 0);
        g_eclipseActivator = 0;
    }
}