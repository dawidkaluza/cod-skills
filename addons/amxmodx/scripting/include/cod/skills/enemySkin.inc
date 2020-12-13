#if defined _cod_skill_enemySkin_included
  #endinput
#endif
#define _cod_skill_enemySkin_included

#include <cod/skills/core/utils>

native Cod_SetPlayerChanceToGetEnemySkin(id, skill, chance);
native Cod_GetPlayerChanceToGetEnemySkin(id, skill);

native Cod_AssociateWeaponWithSkin(id, skill, weaponForTerroSkin, weaponForCtSkin);
native Cod_GetWeaponAssociatedWithSkin(id, skill, team);