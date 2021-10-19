scriptName EnchantAllTheThings_MagicEffect
{Represents the 'Enchant All The Things' version of a magic effect}

int function Create(string enchantmentType) global
    Debug.MessageBox("TODO")
endFunction

function SetName(string enchantmentType, string magicEffectName, string name) global
    int magicEffectsForType = _getMagicEffectsMapForType(enchantmentType)
    int currentObject = JMap.getObj(magicEffectsForType, magicEffectName)
    JMap.setObj(magicEffectsForType, name, currentObject)
    JMap.removeKey(magicEffectsForType, magicEffectName)
    Save()
endFunction

bool function MagicEffectExists(string enchantmentType, string magicEffectName) global
    int magicEffectsForType = _getMagicEffectsMapForType(enchantmentType)
    return JMap.hasKey(magicEffectsForType, magicEffectName)
endFunction

string[] function GetAllMagicEffectNames(string enchantmentType) global
    return JMap.allKeysPArray(_getMagicEffectsMapForType(enchantmentType))
endFunction

function Save() global
    string filename = "Data/EnchantAllTheThings/MagicEffects.json"
    JValue.writeToFile(_getAllMagicEffectsMap(), filename)
endFunction

function LoadFromFile() global
    string filename = "Data/EnchantAllTheThings/MagicEffects.json"
    int fileData = JValue.readFromFile(filename)
    if fileData
        JDB.solveObjSetter(".enchantAllTheThings.magicEffects", fileData, createMissingKeys = true)
    endIf
endFunction

int function _getMagicEffect(string enchantmentType, string magicEffectName) global
    return JMap.getObj(_getMagicEffectsMapForType(enchantmentType), magicEffectName)
endFunction

int function _getMagicEffectsMapForType(string enchantmentType) global
    return JMap.getObj(_getAllMagicEffectsMap(), enchantmentType)
endFunction

int function _getAllMagicEffectsMap() global
    int magicEffectsMap = JDB.solveObj(".enchantAllTheThings.magicEffects")
    if ! magicEffectsMap
        magicEffectsMap = JMap.object()
        JDB.solveObjSetter(".enchantAllTheThings.magicEffects", magicEffectsMap, createMissingKeys = true)
        JMap.setObj(magicEffectsMap, "Weapon", JMap.object())
        JMap.setObj(magicEffectsMap, "Armor", JMap.object())
    endIf
    return magicEffectsMap
endFunction
