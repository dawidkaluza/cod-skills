#if defined _cod_skills_hitBonuses_included
  #endinput
#endif
#define _cod_skills_hitBonuses_included

#include <cod/skills/core/utils>

native Cod_SetPlayerHealthBonusForHitTarget(id, skill, value);
native Cod_GetPlayerHealthBonusForHitTarget(id, skill);

native Cod_SetPlayerExpBonusForHitTarget(id, skill, value);
native Cod_GetPlayerExpBonusForHitTarget(id, skill);

native Cod_SetPlayerHealthBonusForHeadshot(id, skill, value);
native Cod_GetPlayerHealthBonusForHeadshot(id, skill);

native Cod_SetPlayerExpBonusForHeadshot(id, skill, value);
native Cod_GetPlayerExpBonusForHeadshot(id, skill);