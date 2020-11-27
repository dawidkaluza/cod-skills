#if defined _cod_skills_mirrorDamage_included
  #endinput
#endif
#define _cod_skills_mirrorDamage_included

#include <cod/skills/core/utils>

native Cod_SetPlayerChanceToMirrorDamage(id, skill, chance);
native Cod_GetPlayerChanceToMirrorDamage(id, skill);

native Cod_SetPlayerDamageMirrors(id, skill, num);
native Cod_GetPlayerDamageMirrors(id, skill);