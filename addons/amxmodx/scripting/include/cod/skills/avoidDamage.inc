#if defined _cod_skills_avoidDamage_included
  #endinput
#endif
#define _cod_skills_avoidDamage_included

#include <cod/skills/core/utils>

native Cod_SetPlayerChanceToAvoidBullet(id, skill, chance);
native Cod_GetPlayerChanceToAvoidBullet(id, skill);

native Cod_SetPlayerChanceToAvoidHeadshot(id, skill, chance);
native Cod_GetPlayerChanceToAvoidHeadshot(id, skill);

native Cod_SetPlayerChanceToAvoidGrenade(id, skill, chance);
native Cod_GetPlayerChanceToAvoidGrenade(id, skill);

native Cod_SetPlayerBulletsNumToAvoid(id, skill, num);
native Cod_GetPlayerBulletsNumToAvoid(id, skill);

native Cod_SetPlayerAvoidDamageByWeapon(id, skill, weapon, bool:set);
native bool:Cod_GetPlayerAvoidDamageByWeapon(id, skill, weapon);