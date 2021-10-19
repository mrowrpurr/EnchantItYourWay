scriptName EnchantAllTheThings_Enchantment
{Represents the 'Enchant All The Things' version of an enchantment}

int function Create(string enchantmentType, string name) global
    int enchantmentsForType = _getEnchantmentsMapForType(enchantmentType)
    int theEnchantment = JMap.object()
    JMap.setObj(enchantmentsForType, name, theEnchantment)
    JMap.setObj(theEnchantment, "magicEffects", JArray.object())
endFunction

function SetName(string enchantmentType, string enchantmentName, string name) global
    int enchantmentsForType = _getEnchantmentsMapForType(enchantmentType)
    int currentObject = JMap.getObj(enchantmentsForType, enchantmentName)
    JMap.setObj(enchantmentsForType, name, currentObject)
    JMap.removeKey(enchantmentsForType, enchantmentName)
endFunction

bool function EnchantmentExists(string enchantmentType, string enchantmentName) global
    int enchantmentsForType = _getEnchantmentsMapForType(enchantmentType)
    return JMap.hasKey(enchantmentsForType, enchantmentName)
endFunction

string[] function GetAllEnchantmentNames(string enchantmentType) global
    return JMap.allKeysPArray(_getEnchantmentsMapForType(enchantmentType))
endFunction

bool function HasAnyMagicEffects(string enchantmentType, string enchantmentName) global
    return JArray.count(_getMagicEffectsArray(enchantmentType, enchantmentName)) > 0
endFunction

MagicEffect[] function GetMagicEffects(string enchantmentType, string enchantmentName) global
    
endFunction

function Save() global
    string filename = "Data/EnchantAllTheThings/Enchantments.json"
    JValue.writeToFile(_getAllEnchantmentsMap(), filename)
endFunction

function LoadFromFile() global
    string filename = "Data/EnchantAllTheThings/Enchantments.json"
    int fileData = JValue.readFromFile(filename)
    if fileData
        JDB.solveObjSetter(".enchantAllTheThings.enchantments", fileData, createMissingKeys = true)
    endIf
endFunction

int function _getMagicEffectsArray(string enchantmentType, string enchantmentName) global
    int theEnchantment = _getEnchantment(enchantmentType, enchantmentName)
    return JMap.getObj(theEnchantment, "magicEffects")
endFunction

int function _getEnchantment(string enchantmentType, string enchantmentName) global
    int enchantmentsForType = _getEnchantmentsMapForType(enchantmentType)
    return JMap.getObj(enchantmentsForType, enchantmentName)
endFunction

int function _getEnchantmentsMapForType(string enchantmentType) global
    return JMap.getObj(_getAllEnchantmentsMap(), enchantmentType)
endFunction

int function _getAllEnchantmentsMap() global
    int enchantmentsMap = JDB.solveObj(".enchantAllTheThings.enchantments")
    if ! enchantmentsMap
        enchantmentsMap = JMap.object()
        JDB.solveObjSetter(".enchantAllTheThings.enchantments", enchantmentsMap, createMissingKeys = true)
        JMap.setObj(enchantmentsMap, "Weapon", JMap.object())
        JMap.setObj(enchantmentsMap, "Armor", JMap.object())
    endIf
    return enchantmentsMap
endFunction
