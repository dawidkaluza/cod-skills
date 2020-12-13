#if defined _cod_skills_dynamite_included
  #endinput
#endif
#define _cod_skills_dynamite_included

#include <cod/skills/core/utils>

native Cod_SetPlayerDynamites(id, skill, num, Float:damage, Float:damagePerInt);
native Cod_GetPlayerDynamites(id, skill);
native Cod_ActivateDynamite(id, skill);
native bool:Cod_WillGetAccessToDynamites(id, candidatingSkill);