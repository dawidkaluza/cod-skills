#if defined _cod_skills_multiplyDamage_included
  #endinput
#endif
#define _cod_skills_multiplyDamage_included

#include <cod/skills/core/utils>

native Cod_SetPlayerChanceToMultiplyDamage(id, skill, chance, Float:multiplier);
native Cod_GetPlayerChanceToMultiplyDamage(id, skill);
native Float:Cod_GetPlayerChanceDamageMultiplier(id, skill);