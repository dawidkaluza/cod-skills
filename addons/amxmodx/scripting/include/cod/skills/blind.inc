#if defined _cod_skills_blind_included
  #endinput
#endif
#define _cod_skills_blind_included

#include <cod/skills/core/utils>

//Chance to blind
native Cod_SetPlayerChanceToBlind(id, skill, chance);
native Cod_GetPlayerChanceToBlind(id, skill);

//Mass blind
native Cod_SetPlayerMassBlinds(id, skill, num);
native Cod_GetCurPlayerMassBlinds(id);
native Cod_UseMassBlind(id, skill);
native bool:Cod_WillGetAccessToMassBlind(id, candidateSkill);

//Invulnerability to blind
native Cod_SetPlayerInvulnerabilityToBlind(id, skill, bool:value);
native bool:Cod_GetPlayerInvulnerabilityToBlind(id, skill);