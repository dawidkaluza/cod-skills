#if defined _cod_skills_burn_included
  #endinput
#endif
#define _cod_skills_burn_included

#include <cod/skills/core/utils>

//Chance to burn
native Cod_SetPlayerChanceToBurn(id, skill, chance);
native Cod_GetPlayerChanceToBurn(id, skill);

//Molotov grenades
native Cod_SetPlayerMolotovGrenades(id, skill, chance);
native Cod_GetPlayerMolotovGrenades(id, skill);

//Invulnerability to Burn
native Cod_SetPlayerInvulnerabilityToBurn(id, skill, bool:value);
native bool:Cod_GetPlayerInvulnerabilityToBurn(id, skill);