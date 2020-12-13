#if defined _cod_skills_respawn_included
  #endinput
#endif
#define _cod_skills_respawn_included

#include <cod/skills/core/utils>

native Cod_SetPlayerChanceToRespawn(id, skill, chance);
native Cod_GetPlayerChanceToRespawn(id, skill);