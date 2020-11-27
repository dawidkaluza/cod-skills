#if defined _cod_skills_autoBh_included
  #endinput
#endif
#define _cod_skills_autoBh_included

#include <cod/skills/core/utils>

native Cod_SetPlayerAutoBh(id, skill, bool:set);
native bool:Cod_GetPlayerAutoBh(id, skill);