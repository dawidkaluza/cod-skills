#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>

new g_spriteBlast;
public plugin_init() {
    register_plugin("Cod Skill - Explosion", "1.0", "d0naciak.pl");
}

public plugin_precache() {
    g_spriteBlast = precache_model("sprites/dexplo.spr");
}

public plugin_natives() {
    register_library("cod_skill_explosion");

    register_native("Cod_MakeExplosionOnEntityPosition", "Native_MakeExplosionOnEntityPosition");
    register_native("Cod_MakeExplosionOnPosition", "Native_MakeExplosionOnPosition");
}

//Natives
public Native_MakeExplosionOnEntityPosition(plugin, params) {
    new att = get_param(1);
    new ent = get_param(2);
    new Float:damage = get_param_f(3);
    new Float:damagePerInt = get_param_f(4);
    new Float:range = get_param_f(5);

    new Float:position[3];
    pev(ent, pev_origin, position);

    MakeExplosion(att, ent, position, damage, damagePerInt, range);
}

public Native_MakeExplosionOnPosition(plugin, params) {
    new att = get_param(1);
    new Float:position[3];
    get_array_f(2, position, sizeof position);
    new Float:damage = get_param_f(3);
    new Float:damagePerInt = get_param_f(4);
    new Float:range = get_param_f(5);
    MakeExplosion(att, 0, position, damage, damagePerInt, range);
}

MakeExplosion(att, ent, Float:position[3], Float:damage, Float:damagePerInt, Float:range) {
    new positionAsInt[3];
    for (new i = 0; i < 3; i++) {
        positionAsInt[i] = floatround(position[i]);
    }
    
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY, positionAsInt);
    write_byte(TE_EXPLOSION);
    write_coord(positionAsInt[0]);
    write_coord(positionAsInt[1]);
    write_coord(positionAsInt[2]);
    write_short(g_spriteBlast);
    write_byte(floatround(0.16 * range)); 
    write_byte(20); 
    write_byte(0);
    message_end();

    new players[MAX_PLAYERS];
    new playersNum = fm_find_sphere_class(ent, position, "player", range, players, sizeof players);
    new intelligence = max(0, cod_get_user_intelligence(att));
    new Float:basicDamage = damage + (float(intelligence) * damagePerInt);

    new target;
    new Float:targetPosition[3];
    new Float:distanceToTarget;
    new Float:damageMultiplier;
    new Float:curDamage;
    for (new i = 0; i < playersNum; i++) {
        target = players[i];
        if (!is_user_alive(target) || get_user_team(att) == get_user_team(target)) {
            continue;
        }
        
        pev(target, pev_origin, targetPosition);
        distanceToTarget = get_distance_f(position, targetPosition);
        damageMultiplier = 1.0 - (distanceToTarget / (range * 2.0));
        curDamage = floatmax(1.1, basicDamage * damageMultiplier);
        
        ExecuteHamB(Ham_TakeDamage, target, att, att, curDamage, (1<<31)|(1<<32));
    }
}

stock fm_find_sphere_class(ent2, Float:origin[3], classname2[], Float:distance, entlist[], len) {
    new ent, i;
    static classname[32];
    while((ent = fm_find_ent_in_sphere(ent, origin, distance)) != 0) {
        pev(ent, pev_classname, classname, 31);
        if(equali(classname, classname2) && (!ent2 || fm_is_ent_visible(ent2, ent))) {
            entlist[i] = ent;
            i++;
        }

        if(i >= len) {
            break;
        }
    }
    return i;
}