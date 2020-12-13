#if defined _cod_skills_basics_spawn_included
  #endinput
#endif
#define _cod_skills_basics_spawn_included

#include <cstrike>
#include <hamsandwich>

stock SpawnInEnemySpawnZone(id) {
    new team = get_user_team(id);
    cs_set_user_team(id, (team == 2) ? CS_TEAM_T : CS_TEAM_CT);
    ExecuteHamB(Ham_CS_RoundRespawn, id);
    cs_set_user_team(id, (team == 2) ? CS_TEAM_CT : CS_TEAM_T);
}