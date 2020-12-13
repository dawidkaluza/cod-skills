#if defined _cod_skills_dropWeapon_included
  #endinput
#endif
#define _cod_skills_dropWeapon_included

#include <cod/skills/core/utils>

native Cod_SetPlayerChanceToDropWeapon(id, skill, chance);
native Cod_GetPlayerChanceToDropWeapon(id, skill);