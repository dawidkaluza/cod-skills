#include <amxmodx>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/damage>

new g_chanceToMultiplyDamage[MAX_PLAYERS + 1][COD_SKILLS];
new Float:g_chanceDamageMultiplier[MAX_PLAYERS + 1][COD_SKILLS];
new g_curSkill[MAX_PLAYERS + 1];
public plugin_init() {
    register_plugin("Cod Skill - Multiply damage", "1.0", "d0naciak.pl");
}

public plugin_natives() {
    register_library("cod_skill_multiplyDamage");

    register_native("Cod_SetPlayerChanceToMultiplyDamage", "Native_SetPlayerChanceToMultiplyDamage");
    register_native("Cod_GetPlayerChanceToMultiplyDamage", "Native_GetPlayerChanceToMultiplyDamage");
    register_native("Cod_GetPlayerChanceDamageMultiplier", "Native_GetPlayerChanceDamageMultiplier");
}

public Cod_OnTakeDamage(id, att, ent, Float:damage, damageBits) {
    new curSkill = g_curSkill[att];
    if (curSkill != -1 && !random(g_chanceToMultiplyDamage[att][curSkill])) {
        Cod_ChangeForwardDamage(damage * g_chanceDamageMultiplier[att][curSkill]);
        return CODDMG_CHANGE;
    }

    return CODDMG_IGNORE;
}

//Natives
public Native_SetPlayerChanceToMultiplyDamage(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    g_chanceToMultiplyDamage[id][skill] = get_param(3);
    g_chanceDamageMultiplier[id][skill] = get_param_f(4);
    g_curSkill[id] = FindHighestFloatValueIfExist(g_chanceDamageMultiplier[id], COD_SKILLS);
}

public Native_GetPlayerChanceToMultiplyDamage(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceToMultiplyDamage[id][skill];
}

public Float:Native_GetPlayerChanceDamageMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_chanceDamageMultiplier[id][skill];
}