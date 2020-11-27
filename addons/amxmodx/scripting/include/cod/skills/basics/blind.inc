#if defined _cod_skills_basics_blind_included
  #endinput
#endif
#define _cod_skills_basics_blind_included

native Cod_BlindPlayer(id, duration, red = 255, green = 155, blue = 50, alpha = 240);
native Cod_SetPlayerInvulnerabilityToBlind(id, bool:value);
native bool:Cod_GetPlayerInvulnerabilityToBlind(id);