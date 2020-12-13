#if defined _cod_skills_heal_included
  #endinput
#endif
#define _cod_skills_heal_included

#include <cod/skills/core/utils>

native Cod_SetPlayerChanceToHeal(id, skill, chance);
native Cod_GetPlayerChanceToHeal(id, skill);