#if defined _cod_skills_electromagnet_included
  #endinput
#endif
#define _cod_skills_electromagnet_included

#include <cod/skills/core/utils>

native Cod_SetPlayerElectromagnets(id, skill, num);
native Cod_GetPlayerElectromagnets(id, skill);
native Cod_WillGetAccessToElectromagnets(id, candidatingSkill);
native Cod_PlantElectromagnet(id, skill);