#if defined _cod_skills_concreteBody_included
  #endinput
#endif
#define _cod_skills_concreteBody_included

#include <cod/skills/core/utils>

native Cod_SetPlayerConcreteBody(id, skill, time);
native Cod_GetPlayerConcreteBody(id, skill);
native Cod_UseConcreteBody(id, skill);
native Cod_WillGetAccessToConcreteBody(id, skill);