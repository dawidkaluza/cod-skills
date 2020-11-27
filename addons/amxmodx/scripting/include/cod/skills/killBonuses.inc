#if defined _cod_skills_killBonuses_included
  #endinput
#endif
#define _cod_skills_killBonuses_included

#include <cod/skills/core/utils>

native Cod_SetPlayerHealthBonusForKill(id, skill, value);
native Cod_GetPlayerHealthBonusForKill(id, skill);

native Cod_SetPlayerExpBonusForKill(id, skill, value);
native Cod_GetPlayerExpBonusForKill(id, skill);

native Cod_SetPlayerCoinsBonusForKill(id, skill, value);
native Cod_GetPlayerCoinsBonusForKill(id, skill);

native Cod_SetPlayerAmmoBonusForKill(id, skill, Float:value);
native Float:Cod_GetPlayerAmmoBonusForKill(id, skill);