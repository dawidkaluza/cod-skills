#if defined _cod_skills_damage_included
  #endinput
#endif
#define _cod_skills_damage_included

#include <cod/skills/core/utils>

/**
    Sets player damage bonus. 
    If weapon is set to 0, bonus will be active on every weapon.
 */
native Cod_SetPlayerDamageBonus(id, skill, damage, weapon = 0);

/**
    Returns player damage bonus.
    If weapon is set to 0, bonus will be active on every weapon.
 */
native Cod_GetPlayerDamageBonus(id, skill, weapon = 0);

native Cod_SetPlayerHitBoxDamageBonus(id, skill, hitbox, damage);
native Cod_GetPlayerHitBoxDamageBonus(id, skill, hitbox);

native Cod_SetPlayerDamageMultiplier(id, skill, Float:multiplier, weapon = 0);
native Float:Cod_GetPlayerDamageMultiplier(id, skill, weapon = 0);

native Cod_SetPlayerHitBoxDamageMultiplier(id, skill, hitbox, Float:multiplier);
native Float:Cod_GetPlayerHitBoxDamageMultiplier(id, skill, hitbox);

native Cod_SetPlayerDamagePerIntMultiplier(id, skill, Float:multiplier, weapon = 0);
native Float:Cod_GetPlayerDamagePerIntMultiplier(id, skill, weapon = 0);

native Cod_SetPlayerHitBoxDamagePerIntMultiplier(id, skill, hitbox, Float:multiplier);
native Float:Cod_GetPlayerHitBoxDamagePerIntMultiplier(id, skill, hitbox);

native Cod_SetPlayerResistanceBonus(id, skill, damage);
native Cod_GetPlayerResistanceBonus(id, skill);

native Cod_GetPlayerHitBoxResistanceBonus(id, skill, hitbox, damage);
native Cod_GetPlayerHitBoxResistanceBonus(id, skill, hitbox);

native Cod_SetPlayerResistanceMultiplier(id, skill, Float:multiplier);
native Float:Cod_GetPlayerResistanceMultiplier(id, skill);

native Cod_SetPlayerHitBoxResistanceMultiplier(id, skill, hitbox, Float:multiplier);
native Float:Cod_GetPlayerHitBoxResistanceMultiplier(id, skill, hitbox);

native Cod_SetPlayerExploResistanceMultiplier(id, skill, Float:multiplier);
native Float:Cod_GetPlayerExploResistanceMultiplier(id, skill);

native Cod_SetPlayerChanceToKill(id, skill, chance, weapon = 0);
native Cod_GetPlayerChanceToKill(id, skill, weapon = 0);

native Cod_SetPlayerKnifeChanceToKill(id, skill, chance, bool:onlyRightStub);
native Cod_GetPlayerKnifeChanceToKill(id, skill);
native bool:Cod_CanPlayerKillOnlyByRightStub(id, skill);

native Cod_SetPlayerHitBoxChanceToKill(id, skill, hitbox, chance);
native Cod_GetPlayerHitBoxChanceToKill(id, skill, hitbox);