#if defined _cod_skills_basics_damage_included
  #endinput
#endif
#define _cod_skills_basics_damage_included

#include <cod/skills/basics/damage_consts>

forward Cod_OnTakeDamage(id, att, ent, Float:damage, damageBits);
native Cod_ChangeForwardDamage(Float:damage);