#if defined _cod_skills_backDamage_included
  #endinput
#endif
#define _cod_skills_backDamage_included

#include <cod/skills/core/utils>

native Cod_SetPlayerBackDamageMultiplier(id, skill, Float:value);
native Float:Cod_GetPlayerBackDamageMultiplier(id, skill);