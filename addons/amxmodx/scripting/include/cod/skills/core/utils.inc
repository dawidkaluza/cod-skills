#if defined _cod_skills_core_utils_included
  #endinput
#endif
#define _cod_skills_core_utils_included

#include <cod/skills/core/consts>

//Selecting skills by best value
// stock FindBestChanceIfExist(chances[], chancesNum) {
//     new bestChance;
//     new bestChanceIndex = -1;
//     for(new i = 0; i < chancesNum; i++) {
//         if(chances[i] && (!bestChance || chances[i] < bestChance)) {
//             bestChance = chances[i];
//             bestChanceIndex = i;
//         }
//     }

//     return bestChanceIndex;
// }

stock FindHighestValueIfExist(values[], valuesNum) {
    new bestValue;
    new bestValueIndex = -1;
    for(new i = 0; i < valuesNum; i++) {
        if(values[i] && values[i] > bestValue) {
            bestValue = values[i];
            bestValueIndex = i;
        }
    }

    return bestValueIndex;
}

stock FindHighestFloatValueIfExist(Float:values[], valuesNum) {
    new Float:bestValue;
    new bestValueIndex = -1;
    for(new i = 0; i < valuesNum; i++) {
        if(values[i] && values[i] > bestValue) {
            bestValue = values[i];
            bestValueIndex = i;
        }
    }

    return bestValueIndex;
}

stock FindLowestValueIfExist(values[], valuesNum) {
    new bestValue;
    new bestValueIndex = -1;
    for(new i = 0; i < valuesNum; i++) {
        if(values[i] && (!bestValue || values[i] < bestValue)) {
            bestValue = values[i];
            bestValueIndex = i;
        }
    }

    return bestValueIndex;
}

stock FindLowestFloatValueIfExist(Float:values[], valuesNum) {
    new Float:bestValue;
    new bestValueIndex = -1;
    for(new i = 0; i < valuesNum; i++) {
        if(values[i] && (!bestValue || values[i] < bestValue)) {
            bestValue = values[i];
            bestValueIndex = i;
        }
    }

    return bestValueIndex;
}

stock bool:FindTrueBooleanIfExist(bool:values[], valuesNum) {
    for(new i = 0; i < valuesNum; i++) {
        if(values[i]) {
            return true;
        }
    }

    return false;
}

//Selecting skills by priority
stock GetCurrentSkillByPriority(bool:values[COD_SKILLS]) {
    if (values[COD_SKILL_CLASS]) {
        return COD_SKILL_CLASS;
    }

    if (values[COD_SKILL_ASSET]) {
        return COD_SKILL_ASSET;
    }

    if (values[COD_SKILL_PERK]) {
        return COD_SKILL_PERK;
    }

    return -1;
}

stock bool:WillGetAccessToSkillByPriority(bool:values[], candidatingSkill) {
    switch (candidatingSkill) {
        case COD_SKILL_PERK: {
            return !values[COD_SKILL_CLASS] && !values[COD_SKILL_ASSET];
        }
        
        case COD_SKILL_ASSET: {
            return !values[COD_SKILL_CLASS];
        }
    }

    return true;
}

//Notifications
stock NotifyNoAccessToSkill(id) {
    client_print(id, print_center, "Nie masz dostępu do tej umiejętności");
}

stock NotifyIsNotCurrentSkill(id, curSkill) {
    static skillName[][] = {
        "klasie", "perku", "atucie"
    };
    client_print(id, print_center, "Umiejętność ta jest zablokowana, ponieważ posiadasz ją już w %s", skillName[curSkill]);
}

//Converters
stock ConvertValuesToBooleans(values[COD_SKILLS], bool:booleans[COD_SKILLS]) {
    for (new i = 0; i < COD_SKILLS; i++) {
        booleans[i] = values[i] > 0 ? true : false;
    }
}

//Math operations on arrays
stock SumValues(values[], valuesNum) {
    new sum;
    for (new i = 0; i < valuesNum; i++) {
        sum += values[i];
    }
    return sum;
}

stock Float:SumFloatValues(Float:values[], valuesNum) {
    new Float:sum;
    for (new i = 0; i < valuesNum; i++) {
        sum += values[i];
    }
    return sum;
}