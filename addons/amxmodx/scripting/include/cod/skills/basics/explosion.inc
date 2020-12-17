#if defined _cod_skills_basics_explosion_included
  #endinput
#endif
#define _cod_skills_basics_explosion_included

native Cod_MakeExplosionOnEntityPosition(att, ent, Float:damage, Float:damagePerInt, Float:range);
native Cod_MakeExplosionOnPosition(att, Float:position[3], Float:damagePerInt, Float:range);