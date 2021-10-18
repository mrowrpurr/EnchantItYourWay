scriptName EnchantAllTheThings_Enchantment
{Represents the 'Enchant All The Things' version of an enchantment}

int function Create(string enchantmentType) global
    int newEnchantment = JMap.object()
    JArray.addObj(_getEnchantmentsArray(), newEnchantment)
    JMap.setStr(newEnchantment, "type", enchantmentType)
    JMap.setObj(newEnchantment, "magicEffects", JArray.object())
    return newEnchantment
endFunction

function SetName(int theEnchantment, string name) global
    JMap.setStr(theEnchantment, "name", name)
endFunction

string function GetName(int theEnchantment) global
    if JMap.hasKey(theEnchantment, "name")
        return JMap.getStr(theEnchantment, "name")
    else
        return "Enchantment"
    endIf
endFunction

string function GetType(int theEnchantment) global
    return JMap.getStr(theEnchantment, "type")
endFunction

bool function IsArmorType(int theEnchantment) global
    return GetType(theEnchantment) == "ARMOR"
endFunction

bool function IsWeaponType(int theEnchantment) global
    return GetType(theEnchantment) == "WEAPON"
endFunction

function AddMagicEffect(int theEnchantment, MagicEffect theEffect) global
    JArray.addForm(_getMagicEffectsArray(theEnchantment), theEffect)
endFunction

bool function HasAnyMagicEffects(int theEnchantment) global
    return JArray.count(_getMagicEffectsArray(theEnchantment)) > 0
endFunction

Form[] function GetMagicEffects(int theEnchantment) global
    return JArray.asFormArray(_getMagicEffectsArray(theEnchantment))
endFunction

int function _getMagicEffectsArray(int theEnchantment) global
    return JMap.getObj(theEnchantment, "magicEffects")
endFunction

int function _getEnchantmentsArray() global
    int theArray = JDB.solveObj(".enchantAllTheThings.enchantments")
    if ! theArray
        theArray = JArray.object()
        JDB.solveObjSetter(".enchantAllTheThings.enchantments", theArray, createMissingKeys = true)
    endIf
    return theArray
endFunction