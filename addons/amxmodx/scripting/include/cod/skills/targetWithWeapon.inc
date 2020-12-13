#if defined _cod_skills_targetWithWeapon_included
  #endinput
#endif
#define _cod_skills_targetWithWeapon_included

#include <cod/skills/core/utils>

native Cod_SetPlayerChanceToKillTargetWithWeapon(id, skill, weapon, chance);
native Cod_GetPlayerChanceToKillTargetWithWeapon(id, skill, weapon);