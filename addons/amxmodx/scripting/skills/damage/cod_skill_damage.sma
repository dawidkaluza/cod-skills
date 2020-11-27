#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <codmod_1s2k_401>
#include <cod/skills/core/utils>
#include <cod/skills/basics/damage>

//Damage bonus
new g_playerDamageBonus[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1][COD_SKILLS];
new g_curPlayerDamageBonus[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1];

//HitBox damage bonus
new g_playerHitBoxDamageBonus[MAX_PLAYERS + 1][MAX_BODYHITS][COD_SKILLS];
new g_curPlayerHitBoxDamageBonus[MAX_PLAYERS + 1][MAX_BODYHITS];

//Damage multiplier
new Float:g_playerDamageMultiplier[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1][COD_SKILLS];
new Float:g_curPlayerDamageMultiplier[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1];

//HitBox damage multiplier
new Float:g_playerHitBoxDamageMultiplier[MAX_PLAYERS + 1][MAX_BODYHITS][COD_SKILLS];
new Float:g_curPlayerHitBoxDamageMultiplier[MAX_PLAYERS + 1][MAX_BODYHITS];

//Damage per intelligence multiplier
new Float:g_playerDamagePerIntMultiplier[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1][COD_SKILLS];
new Float:g_curPlayerDamagePerIntMultiplier[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1];

//HitBox damage per intelligence multiplier
new Float:g_playerHitBoxDamagePerIntMultiplier[MAX_PLAYERS + 1][MAX_BODYHITS][COD_SKILLS];
new Float:g_curPlayerHitBoxDamagePerIntMultiplier[MAX_PLAYERS + 1][MAX_BODYHITS];

//Resistance bonus
new g_playerResistanceBonus[MAX_PLAYERS + 1][COD_SKILLS];
new g_curPlayerResistanceBonus[MAX_PLAYERS + 1];

//HitBox resistance bonus
new g_playerHitBoxResistanceBonus[MAX_PLAYERS + 1][MAX_BODYHITS][COD_SKILLS];
new g_curPlayerHitBoxResistanceBonus[MAX_PLAYERS + 1][MAX_BODYHITS];

//Resistance multiplier
new Float:g_playerResistanceMultiplier[MAX_PLAYERS + 1][COD_SKILLS];
new Float:g_curPlayerResistanceMultiplier[MAX_PLAYERS + 1];

//HitBox resistance multiplier
new Float:g_playerHitBoxResistanceMultiplier[MAX_PLAYERS + 1][MAX_BODYHITS][COD_SKILLS];
new Float:g_curPlayerHitBoxResistanceMultiplier[MAX_PLAYERS + 1][MAX_BODYHITS];

//Explosion resistance multiplier
new Float:g_playerExploResistanceMultiplier[MAX_PLAYERS + 1][COD_SKILLS];
new Float:g_curPlayerExploResistanceMultiplier[MAX_PLAYERS + 1];

//Chance to kill
new g_playerChanceToKill[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1][COD_SKILLS];
new bool:g_playerOnlyRightKnifeStub[MAX_PLAYERS + 1][COD_SKILLS];
new g_curPlayerChanceToKill[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1];
new bool:g_curPlayerOnlyRightKnifeStub[MAX_PLAYERS + 1];

//HitBox chance to kill
new g_playerHitBoxChanceToKill[MAX_PLAYERS + 1][MAX_BODYHITS][COD_SKILLS];
new g_curPlayerHitBoxChanceToKill[MAX_PLAYERS + 1][MAX_BODYHITS];

public plugin_init() {
    register_plugin("Cod Skill - Damage", "1.0", "d0naciak.pl");

    if (!LibraryExists("cod_basicSkill_damage", LibType_Library)) {
        set_fail_state("Library cod_basicSkill_damage doesnt exist");
        return;
    }
}

public plugin_natives() {
    register_library("cod_skill_damage");

    //Damage bonus
    register_native("Cod_SetPlayerDamageBonus", "Native_SetPlayerDamageBonus");
    register_native("Cod_GetPlayerDamageBonus", "Native_GetPlayerDamageBonus");
    
    //HitBox damage bonus
    register_native("Cod_SetPlayerHitBoxDamageBonus", "Native_SetPlayerHitBoxDamageBonus");
    register_native("Cod_GetPlayerHitBoxDamageBonus", "Native_GetPlayerHitBoxDamageBonus");

    //Damage multiplier
    register_native("Cod_SetPlayerDamageMultiplier", "Native_SetPlayerDamageMultiplier");
    register_native("Cod_GetPlayerDamageMultiplier", "Native_GetPlayerDamageMultiplier");

    //HitBox damage multiplier
    register_native("Cod_SetPlayerHitBoxDamageMultiplier", "Native_SetPlayerHitBoxDamageMultiplier");
    register_native("Cod_GetPlayerHitBoxDamageMultiplier", "Native_GetPlayerHitBoxDamageMultiplier");

    //Damage per intelligence multiplier
    register_native("Cod_SetPlayerDamagePerIntMultiplier", "Native_SetPlayerDamagePerIntMultiplier");
    register_native("Cod_GetPlayerDamagePerIntMultiplier", "Native_GetPlayerDamagePerIntMultiplier");

    //HitBox damage per intelligence multiplier
    register_native("Cod_SetPlayerHitBoxDamagePerIntMultiplier", "Native_SetPlayerHitBoxDamagePerIntMultiplier");
    register_native("Cod_GetPlayerHitBoxDamagePerIntMultiplier", "Native_GetPlayerHitBoxDamagePerIntMultiplier");

    //Resistance bonus
    register_native("Cod_SetPlayerResistanceBonus", "Native_SetPlayerResistanceBonus");
    register_native("Cod_GetPlayerResistanceBonus", "Native_GetPlayerResistanceBonus");

    //HitBox resistance bonus
    register_native("Cod_SetPlayerHitBoxResistanceBonus", "Native_SetPlayerHitBoxResistanceBonus");
    register_native("Cod_GetPlayerHitBoxResistanceBonus", "Native_GetPlayerHitBoxResistanceBonus");

    //Resistance multiplier
    register_native("Cod_SetPlayerResistanceMultiplier", "Native_SetPlayerResistanceMultiplier");
    register_native("Cod_GetPlayerResistanceMultiplier", "Native_GetPlayerResistanceMultiplier");

    //HitBox resistance multiplier
    register_native("Cod_SetPlayerHitBoxResistanceMultiplier", "Native_SetPlayerHitBoxResistanceMultiplier");
    register_native("Cod_GetPlayerHitBoxResistanceMultiplier", "Native_GetPlayerHitBoxResistanceMultiplier");

    //Explosion resistance multiplier
    register_native("Cod_SetPlayerExploResistanceMultiplier", "Native_SetPlayerExploResistanceMultiplier");
    register_native("Cod_GetPlayerExploResistanceMultiplier", "Native_GetPlayerExploResistanceMultiplier");

    //Chance to kill
    register_native("Cod_SetPlayerChanceToKill", "Native_SetPlayerChanceToKill");
    register_native("Cod_GetPlayerChanceToKill", "Native_GetPlayerChanceToKill");

    //Knife chance to kill
    register_native("Cod_SetPlayerKnifeChanceToKill", "Native_SetPlayerKnifeChanceToKill");
    register_native("Cod_CanPlayerKillOnlyByRightStub", "Native_GetPlayerKnifeChanceToKill");
    register_native("Cod_CanPlayerKillOnlyByRightStub", "Native_CanPlayerKillOnlyByRightStub");

    //HitBox chance to kill
    register_native("Cod_SetPlayerHitBoxChanceToKill", "Native_SetPlayerHitBoxChanceToKill");
    register_native("Cod_GetPlayerHitBoxChanceToKill", "Native_GetPlayerHitBoxChanceToKill");
}

public Cod_OnTakeDamage(id, att, ent, Float:damage, damageBits) {
    static weapon, hitBox, bool:appliedDamageBonuses, bool:appliedResistanceBonuses;
    
    //Reset variables every forward
    weapon = 0;
    hitBox = 0;
    appliedDamageBonuses = false;
    appliedResistanceBonuses = false;

    if (damageBits & (1<<1)) {
        weapon = get_user_weapon(att);
        hitBox = get_pdata_int(id, 75, 5);
        if (CSW_ALL_GUNS & (1<<weapon)) {
            //Chance to kill by gun
            new chance = GetPlayerChanceToKill(att, weapon, hitBox);
            if (chance && !random(chance)) {
                return CODDMG_KILL;
            }
        } else if (weapon == CSW_KNIFE) {
            //Chance to kill by knife
            new chance = GetPlayerKnifeChanceToKill(att);
            if (chance && !random(chance)) {
                return CODDMG_KILL;
            }
        }

        appliedDamageBonuses = ApplyWeaponDamageBonuses(att, damage, weapon, hitBox);
    } else if (damageBits & (1<<24)) {
        //Chance to kill by grenade
        new chance = g_curPlayerChanceToKill[att][CSW_HEGRENADE];
        if (chance && !random(chance)) {
            return CODDMG_KILL;
        }
        
        appliedDamageBonuses = ApplyGrenadeDamageBonuses(att, damage);
    }

    appliedResistanceBonuses = ApplyResistanceBonuses(id, damage, damageBits, hitBox)

    if (appliedDamageBonuses || appliedResistanceBonuses) {
        Cod_ChangeForwardDamage(damage);
        return CODDMG_CHANGE;
    }

    return CODDMG_IGNORE;
}

GetPlayerChanceToKill(id, weapon, hitBox) {
    new chances[3], chancesNum;

    if (g_curPlayerChanceToKill[id][0]) {
        chances[chancesNum++] = g_curPlayerChanceToKill[id][0];
    }

    if (g_curPlayerChanceToKill[id][weapon]) {
        chances[chancesNum++] = g_curPlayerChanceToKill[id][weapon];
    }

    if (g_curPlayerHitBoxChanceToKill[id][hitBox]) {
        chances[chancesNum++] = g_curPlayerHitBoxChanceToKill[id][hitBox];
    }

    new bestId = FindLowestValueIfExist(chances, chancesNum);
    return bestId == -1 ? 0 : chances[bestId];
}

GetPlayerKnifeChanceToKill(id) {
    new buttons = pev(id, pev_button);
    new bool:onlyRightStub = g_curPlayerOnlyRightKnifeStub[id];
    if (buttons & IN_ATTACK2 || !onlyRightStub) {
        return g_curPlayerChanceToKill[id][CSW_KNIFE];
    }

    return 0;
}

bool:ApplyWeaponDamageBonuses(id, &Float:damage, weapon, hitBox) {
    new Float:damageWithoutBonus = damage;

    if (g_curPlayerDamageMultiplier[id][0]) {
        damage += damageWithoutBonus * g_curPlayerDamageMultiplier[id][0];
    }
    
    if (g_curPlayerDamageMultiplier[id][weapon]) {
        damage += damageWithoutBonus * g_curPlayerDamageMultiplier[id][weapon];
    }
    
    if (g_curPlayerHitBoxDamageMultiplier[id][hitBox]) {
        damage += damageWithoutBonus * g_curPlayerHitBoxDamageMultiplier[id][hitBox];
    }

    new Float:intelligence = float(cod_get_user_intelligence(id));
    if (g_curPlayerDamagePerIntMultiplier[id][0]) {
        damage += g_curPlayerDamagePerIntMultiplier[id][0] * intelligence;
    }
    
    if (g_curPlayerDamagePerIntMultiplier[id][weapon]) {
        damage += g_curPlayerDamagePerIntMultiplier[id][weapon] * intelligence;
    }
    
    if (g_curPlayerHitBoxDamagePerIntMultiplier[id][hitBox]) {
        damage += g_curPlayerHitBoxDamagePerIntMultiplier[id][hitBox] * intelligence;
    }

    damage += float(
        g_curPlayerDamageBonus[id][0] + 
        g_curPlayerDamageBonus[id][weapon] + 
        g_curPlayerHitBoxDamageBonus[id][hitBox]
    );

    return damage != damageWithoutBonus ? true : false;
}

bool:ApplyGrenadeDamageBonuses(id, &Float:damage) {
    new Float:damageWithoutBonus = damage;
    
    if (g_curPlayerDamageMultiplier[id][CSW_HEGRENADE]) {
        damage += damageWithoutBonus * g_curPlayerDamageMultiplier[id][CSW_HEGRENADE];
    }
    
    if (g_curPlayerDamagePerIntMultiplier[id][CSW_HEGRENADE]) {
        damage += g_curPlayerDamagePerIntMultiplier[id][CSW_HEGRENADE] * cod_get_user_intelligence(id);
    }
    
    damage += float(g_curPlayerDamageBonus[id][CSW_HEGRENADE]);
    return damage != damageWithoutBonus ? true : false;
}

bool:ApplyResistanceBonuses(id, &Float:damage, damageBits, hitBox) {
    new Float:damageWithoutBonus = damage;

    damage -= float(g_curPlayerResistanceBonus[id] + g_curPlayerHitBoxResistanceBonus[id][hitBox]);
    
    if (g_curPlayerResistanceMultiplier[id]) {
        damage *= 1.0 - g_curPlayerResistanceMultiplier[id];
    }
    
    if (g_curPlayerHitBoxResistanceMultiplier[id][hitBox]) {
        damage *= 1.0 - g_curPlayerHitBoxResistanceMultiplier[id][hitBox];
    }

    if ((damageBits & (1<<24)+DMG_KILLHEGREN) && g_curPlayerExploResistanceMultiplier[id]) {
        damage *= 1.0 - g_curPlayerExploResistanceMultiplier[id];
    }

    damage = floatmin(1.0, damage);
    return damage != damageWithoutBonus ? true : false;
}

//Natives
public Native_SetPlayerDamageBonus(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new bonus = get_param(3);
    new weapon = get_param(4);

    g_playerDamageBonus[id][weapon][skill] = bonus;
    new bestId = FindHighestValueIfExist(g_playerDamageBonus[id][weapon], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerDamageBonus[id][weapon] = 0;
    } else {
        g_curPlayerDamageBonus[id][weapon] = g_playerDamageBonus[id][weapon][bestId];
    }
}

public Native_GetPlayerDamageBonus(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new weapon = get_param(3);
    return g_playerDamageBonus[id][weapon][skill];
}

public Native_SetPlayerHitBoxDamageBonus(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new hitbox = get_param(3);
    new bonus = get_param(4);

    g_playerHitBoxDamageBonus[id][hitbox][skill] = bonus;
    new bestId = FindHighestValueIfExist(g_playerHitBoxDamageBonus[id][hitbox], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerHitBoxDamageBonus[id][hitbox] = 0;
    } else {
        g_curPlayerHitBoxDamageBonus[id][hitbox] = g_playerHitBoxDamageBonus[id][hitbox][bestId];
    }
}

public Native_GetPlayerHitBoxDamageBonus(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new hitbox = get_param(3);
    return g_playerHitBoxDamageBonus[id][hitbox][skill];
}

public Native_SetPlayerDamageMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new Float:multiplier = get_param_f(3);
    new weapon = get_param(4);

    g_playerDamageMultiplier[id][weapon][skill] = multiplier;
    new bestId = FindHighestFloatValueIfExist(g_playerDamageMultiplier[id][weapon], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerDamageMultiplier[id][weapon] = 0.0;
    } else {
        g_curPlayerDamageMultiplier[id][weapon] = g_playerDamageMultiplier[id][weapon][bestId];
    }
}

public Float:Native_GetPlayerDamageMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new weapon = get_param(3);
    return g_playerDamageMultiplier[id][weapon][skill];
}

public Native_SetPlayerHitBoxDamageMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new hitbox = get_param(3);
    new Float:multiplier = get_param_f(4);

    g_playerHitBoxDamageMultiplier[id][hitbox][skill] = multiplier;
    new bestId = FindHighestFloatValueIfExist(g_playerHitBoxDamageMultiplier[id][hitbox], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerHitBoxDamageMultiplier[id][hitbox] = 0.0;
    } else {
        g_curPlayerHitBoxDamageMultiplier[id][hitbox] = g_playerHitBoxDamageMultiplier[id][hitbox][bestId];
    }
}

public Float:Native_GetPlayerHitBoxDamageMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new hitbox = get_param(3);
    return g_playerHitBoxDamageMultiplier[id][hitbox][skill];
}

public Native_SetPlayerDamagePerIntMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new Float:multiplier = get_param_f(3);
    new weapon = get_param(4);

    g_playerDamagePerIntMultiplier[id][weapon][skill] = multiplier;
    new bestId = FindHighestFloatValueIfExist(g_playerDamagePerIntMultiplier[id][weapon], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerDamagePerIntMultiplier[id][weapon] = 0.0;
    } else {
        g_curPlayerDamagePerIntMultiplier[id][weapon] = g_playerDamagePerIntMultiplier[id][weapon][bestId];
    }
}

public Float:Native_GetPlayerDamagePerIntMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new weapon = get_param(3);
    return g_playerDamagePerIntMultiplier[id][weapon][skill];
}

public Native_SetPlayerHitBoxDamagePerIntMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new hitbox = get_param(3);
    new Float:multiplier = get_param_f(4);

    g_playerHitBoxDamagePerIntMultiplier[id][hitbox][skill] = multiplier;
    new bestId = FindHighestFloatValueIfExist(g_playerHitBoxDamagePerIntMultiplier[id][hitbox], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerHitBoxDamagePerIntMultiplier[id][hitbox] = 0.0;
    } else {
        g_curPlayerHitBoxDamagePerIntMultiplier[id][hitbox] = g_playerHitBoxDamagePerIntMultiplier[id][hitbox][bestId];
    }
}

public Float:Native_GetPlayerHitBoxDamagePerIntMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new hitbox = get_param(3);
    return g_playerHitBoxDamagePerIntMultiplier[id][hitbox][skill];
}

public Native_SetPlayerResistanceBonus(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new bonus = get_param(3);

    g_playerResistanceBonus[id][skill] = bonus;
    new bestId = FindHighestValueIfExist(g_playerResistanceBonus[id], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerResistanceBonus[id] = 0;
    } else {
        g_curPlayerResistanceBonus[id] = g_playerResistanceBonus[id][bestId];
    }
}

public Native_GetPlayerResistanceBonus(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_playerResistanceBonus[id][skill];
}

public Native_SetPlayerHitBoxResistanceBonus(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new hitbox = get_param(3);
    new bonus = get_param(4);

    g_playerHitBoxResistanceBonus[id][hitbox][skill] = bonus;
    new bestId = FindHighestValueIfExist(g_playerHitBoxResistanceBonus[id][hitbox], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerHitBoxResistanceBonus[id][hitbox] = 0;
    } else {
        g_curPlayerHitBoxResistanceBonus[id][hitbox] = g_playerHitBoxResistanceBonus[id][hitbox][bestId];
    }
}

public Native_GetPlayerHitBoxResistanceBonus(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new hitbox = get_param(3);
    return g_playerHitBoxResistanceBonus[id][hitbox][skill];
}

public Native_SetPlayerResistanceMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new Float:multiplier = get_param_f(3);

    g_playerResistanceMultiplier[id][skill] = multiplier;
    new bestId = FindHighestFloatValueIfExist(g_playerResistanceMultiplier[id], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerResistanceMultiplier[id] = 0.0;
    } else {
        g_curPlayerResistanceMultiplier[id] = g_playerResistanceMultiplier[id][bestId];
    }
}

public Float:Native_GetPlayerResistanceMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_playerResistanceMultiplier[id][skill];
}

public Native_SetPlayerHitBoxResistanceMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new hitbox = get_param(3);
    new Float:multiplier = get_param_f(4);

    g_playerHitBoxResistanceMultiplier[id][hitbox][skill] = multiplier;
    new bestId = FindHighestFloatValueIfExist(g_playerHitBoxResistanceMultiplier[id][hitbox], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerHitBoxResistanceMultiplier[id][hitbox] = 0.0;
    } else {
        g_curPlayerHitBoxResistanceMultiplier[id][hitbox] = g_playerHitBoxResistanceMultiplier[id][hitbox][bestId];
    }
}

public Float:Native_GetPlayerHitBoxResistanceMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new hitbox = get_param(3);
    return g_playerHitBoxResistanceMultiplier[id][hitbox][skill];
}

public Native_SetPlayerExploResistanceMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new Float:multiplier = get_param_f(3);

    g_playerExploResistanceMultiplier[id][skill] = multiplier;
    new bestId = FindHighestFloatValueIfExist(g_playerExploResistanceMultiplier[id], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerExploResistanceMultiplier[id] = 0.0;
    } else {
        g_curPlayerExploResistanceMultiplier[id] = g_playerExploResistanceMultiplier[id][bestId];
    }
}

public Float:Native_GetPlayerExploResistanceMultiplier(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_playerExploResistanceMultiplier[id][skill];
}

public Native_SetPlayerChanceToKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new chance = get_param(3);
    new weapon = get_param(4);

    g_playerChanceToKill[id][weapon][skill] = chance;
    new bestId = FindLowestValueIfExist(g_playerChanceToKill[id][weapon], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerChanceToKill[id][weapon] = 0;
    } else {
        g_curPlayerChanceToKill[id][weapon] = g_playerChanceToKill[id][weapon][bestId];
    }
}

public Native_GetPlayerChanceToKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new weapon = get_param(3);
    return g_playerChanceToKill[id][weapon][skill];
}

public Native_SetPlayerKnifeChanceToKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new chance = get_param(3);
    new bool:onlyRightStub = bool:get_param(4);

    g_playerChanceToKill[id][CSW_KNIFE][skill] = chance;
    g_playerOnlyRightKnifeStub[id][skill] = onlyRightStub;
    new bestId = FindLowestValueIfExist(g_playerChanceToKill[id][CSW_KNIFE], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerChanceToKill[id][CSW_KNIFE] = 0;
        g_curPlayerOnlyRightKnifeStub[id] = false;
    } else {
        g_curPlayerChanceToKill[id][CSW_KNIFE] = g_playerChanceToKill[id][CSW_KNIFE][bestId];
        g_curPlayerOnlyRightKnifeStub[id] = g_playerOnlyRightKnifeStub[id][bestId];
    }
}

public Native_GetPlayerKnifeChanceToKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_playerChanceToKill[id][CSW_KNIFE][skill];
}

public bool:Cod_CanPlayerKillOnlyByRightStub(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    return g_playerOnlyRightKnifeStub[id][skill];
}

public Native_SetPlayerHitBoxChanceToKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new hitbox = get_param(3);
    new chance = get_param(4);

    g_playerHitBoxChanceToKill[id][hitbox][skill] = chance;
    new bestId = FindLowestValueIfExist(g_playerHitBoxChanceToKill[id][hitbox], COD_SKILLS);
    if (bestId == -1) {
        g_curPlayerHitBoxChanceToKill[id][hitbox] = 0;
    } else {
        g_curPlayerHitBoxChanceToKill[id][hitbox] = g_playerHitBoxChanceToKill[id][hitbox][bestId];
    }
}

public Native_GetPlayerHitBoxChanceToKill(plugin, params) {
    new id = get_param(1);
    new skill = get_param(2);
    new hitbox = get_param(3);
    return g_playerHitBoxChanceToKill[id][hitbox][skill];
}












