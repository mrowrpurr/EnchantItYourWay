scriptName EnchantAllTheThings_MagicEffect
{Represents the 'Enchant All The Things' version of a magic effect}

int function Create(string enchantmentType) global
    Debug.MessageBox("TODO")
endFunction

function SetName(string enchantmentType, string magicEffectName, string name, string enchantmentName = "") global
    int magicEffectsForType = _getMagicEffectsMap(enchantmentType, enchantmentName)
    int currentObject = JMap.getObj(magicEffectsForType, magicEffectName)
    JMap.setObj(magicEffectsForType, name, currentObject)
    JMap.removeKey(magicEffectsForType, magicEffectName)
    if enchantmentName
        EnchantAllTheThings_Enchantment.Save()
    else
        Save()
    endIf
endFunction

bool function MagicEffectExists(string enchantmentType, string magicEffectName, string enchantmentName = "") global
    int magicEffectsForType = _getMagicEffectsMap(enchantmentType, enchantmentName)
    return JMap.hasKey(magicEffectsForType, magicEffectName)
endFunction

string[] function GetAllMagicEffectNames(string enchantmentType, string enchantmentName = "") global
    return JMap.allKeysPArray(_getMagicEffectsMap(enchantmentType, enchantmentName))
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

int function _getMagicEffect(string enchantmentType, string magicEffectName, string enchantmentName = "") global
    if enchantmentName
        return EnchantAllTheThings_Enchantment._getMagicEffect(enchantmentType, enchantmentName, magicEffectName)
    else
        return JMap.getObj(_getMagicEffectsMap(enchantmentType), magicEffectName)
    endIf
endFunction

int function _getMagicEffectsMap(string enchantmentType, string enchantmentName = "") global
    if enchantmentName
        return EnchantAllTheThings_Enchantment._getMagicEffectsMap(enchantmentType, enchantmentName)
    else
        return JMap.getObj(_getAllMagicEffectsMap(), enchantmentType)
    endIf
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
