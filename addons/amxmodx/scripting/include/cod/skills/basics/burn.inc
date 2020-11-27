#if defined _cod_skills_basics_burn_included
  #endinput
#endif
#define _cod_skills_basics_burn_included

/**
    Burns target on given time
 */
native Cod_BurnPlayer(id, target, Float:periodTime, num, Float:damage);

/**
    Sets invulnerability to burn
 */
native Cod_SetPlayerInvulnerabilityToBurn(id, bool:value);

/**
    Gets invulnerability to burn
 */
native bool:Cod_GetPlayerInvulnerabilityToBurn(id);