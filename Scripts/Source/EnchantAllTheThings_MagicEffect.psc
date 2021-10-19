scriptName EnchantAllTheThings_MagicEffect
{Represents the 'Enchant All The Things' version of a magic effect}

string[] function GetAllMagicEffectNames(string enchantmentType) global
    return JMap.allKeysPArray(_getMagicEffectsMapForType(enchantmentType))
endFunction

function Save() global
    string filename = "Data/EnchantAllTheThings/MagicEffects.json"
    JValue.writeToFile(_getAllMagicEffectsMap(), filename)
endFunction

function LoadFromFile() global
    Debug.MessageBox("Load From File!")
    string filename = "Data/EnchantAllTheThings/MagicEffects.json"
    int fileData = JValue.readFromFile(filename)
    Debug.MessageBox("The file " + filename + " was loaded? " + fileData)
    if fileData
        JDB.solveObjSetter(".enchantAllTheThings.magicEffects", fileData, createMissingKeys = true)
    endIf
endFunction

int function _getMagicEffectsMapForType(string enchantmentType) global
    return JMap.getObj(_getAllMagicEffectsMap(), enchantmentType)
endFunction

int function _getAllMagicEffectsMap() global
    int magicEffectsMap = JDB.solveObj(".enchantAllTheThings.magicEffects")
    if ! magicEffectsMap
        magicEffectsMap = JMap.object()
        JDB.solveObjSetter(".enchantAllTheThings.magicEffects", magicEffectsMap, createMissingKeys = true)
        JMap.setObj(magicEffectsMap, "Weapon Enchantments", JMap.object())
        JMap.setObj(magicEffectsMap, "Armor Enchantments", JMap.object())
    endIf
    return magicEffectsMap
endFunction
