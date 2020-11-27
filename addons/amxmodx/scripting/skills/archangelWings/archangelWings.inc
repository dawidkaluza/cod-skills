#if defined _cod_skills_archangelWings_included
  #endinput
#endif
#define _cod_skills_archangelWings_included

#include <cod/skills/core/utils>

native Cod_SetPlayerArchangelWings(id, skill, pullDownPower, Float:damage, Float:damagePerInt);
native Cod_GetCurPlayerArchangelWings(id);
native Cod_UseArchangelWings(id, skill);
native Cod_WillGetAccessToArchangelWings(id, candidatingSkill);