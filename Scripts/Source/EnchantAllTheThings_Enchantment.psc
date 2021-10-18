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

MagicEffect[] function GetMagicEffects(int theEnchantment) global
    MagicEffect[] theEffects
    Form[] theEffectForms = JArray.asFormArray(_getMagicEffectsArray(theEnchantment))
    if theEffectForms.Length == 1
        theEffects = new MagicEffect[1]
        theEffects[0] = theEffectForms[0] as MagicEffect
    else
        Debug.MessageBox("We only currently support 1 magic effect")
    endIf
    return theEffects
endFunction

float[] function GetMagicEffectMagnitudes(int theEnchantment) global
    float[] magnitudes = new float[1]
    magnitudes[0] = 6969
    return magnitudes
endFunction

int[] function GetMagicEffectAreaOfEffects(int theEnchantment) global
    int[] areaOfEffects = new int[1]
    areaOfEffects[0] = 100
    return areaOfEffects
endFunction

int[] function GetMagicEffectDurations(int theEnchantment) global
    int[] durations = new int[1]
    durations[0] = 100
    return durations
endFunction

float function GetMagicEffectMaxCharge(int theEnchantment) global
    return 10000
endFunction

string[] function GetEnchantmentNames() global
    int enchantmentNames = JArray.object()
    int enchantmentsArray = _getEnchantmentsArray()
    int count = JArray.count(enchantmentsArray)
    int i = 0
    while i < count
        int theEnchantment = JArray.getObj(enchantmentsArray, i)
        string name = GetName(theEnchantment)
        JArray.addStr(enchantmentNames, name)
        i += 1
    endWhile
    return JArray.asStringArray(enchantmentNames)
endFunction

int function GetEnchantmentByName(string name) global
    int enchantmentNames = JArray.object()
    int enchantmentsArray = _getEnchantmentsArray()
    int count = JArray.count(enchantmentsArray)
    int i = 0
    while i < count
        int theEnchantment = JArray.getObj(enchantmentsArray, i)
        string enchantmentName = GetName(theEnchantment)
        if name == enchantmentName
            return theEnchantment
        endIf
        i += 1
    endWhile
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