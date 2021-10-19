scriptName EnchantAllTheThings_Enchantment
{Represents the 'Enchant All The Things' version of an enchantment}

int function Create(string enchantmentType, string name) global
    int enchantmentsForType = _getEnchantmentsMapForType(enchantmentType)
    int theEnchantment = JMap.object()
    JMap.setObj(enchantmentsForType, name, theEnchantment)
    JMap.setObj(theEnchantment, "magicEffects", JMap.object())
endFunction

function SetName(string enchantmentType, string enchantmentName, string name) global
    int enchantmentsForType = _getEnchantmentsMapForType(enchantmentType)
    int currentObject = JMap.getObj(enchantmentsForType, enchantmentName)
    JMap.setObj(enchantmentsForType, name, currentObject)
    JMap.removeKey(enchantmentsForType, enchantmentName)
    Save()
endFunction

bool function EnchantmentExists(string enchantmentType, string enchantmentName) global
    int enchantmentsForType = _getEnchantmentsMapForType(enchantmentType)
    return JMap.hasKey(enchantmentsForType, enchantmentName)
endFunction

string[] function GetAllEnchantmentNames(string enchantmentType) global
    return JMap.allKeysPArray(_getEnchantmentsMapForType(enchantmentType))
endFunction

bool function HasAnyMagicEffects(string enchantmentType, string enchantmentName) global
    return JMap.count(_getMagicEffectsMap(enchantmentType, enchantmentName)) > 0
endFunction

string[] function GetMagicEffectNames(string enchantmentType, string enchantmentName) global
    return JMap.allKeysPArray(_getMagicEffectsMap(enchantmentType, enchantmentName))
endFunction

MagicEffect[] function GetMagicEffects(string enchantmentType, string enchantmentName) global
    int magicEffectsMap       = _getMagicEffectsMap(enchantmentType, enchantmentName)
    string[] magicEffectNames = JMap.allKeysPArray(magicEffectsMap)
    int magicEffectCount      = magicEffectNames.Length
    ; Initialize Magic Effects
    ; This has to be manually done for each size
    ; because SKSE cannot generate MagicEffect[]
    ; of a dynamic size :(
    MagicEffect[] magicEffects
    if magicEffectCount == 1
        magicEffects = new MagicEffect[1]
    elseIf magicEffectCount == 2
        magicEffects = new MagicEffect[2]
    elseIf magicEffectCount == 3
        magicEffects = new MagicEffect[3]
    else
        Debug.MessageBox("No support yet for more than 3 magic effects")
        return magicEffects
    endIf
    ; Fill the array
    int i = 0
    while i < magicEffectCount
        int magicEffectObject = JMap.getObj(magicEffectsMap, magicEffectNames[i])
        MagicEffect theMagicEffect = JMap.getForm(magicEffectObject, "Effect") as MagicEffect
        magicEffects[i] = theMagicEffect
        i += 1
    endWhile
    return magicEffects
endFunction

function AddMagicEffect(string enchantmentType, string enchantmentName, string magicEffectName) global
    int magicEffectsMap = _getMagicEffectsMap(enchantmentType, enchantmentName)
    int baseMagicEffect = EnchantAllTheThings_MagicEffect._getMagicEffect(enchantmentType, magicEffectName)
    int enchantmentMagicEffect = JValue.shallowCopy(baseMagicEffect)
    JMap.setObj(magicEffectsMap, magicEffectName, enchantmentMagicEffect)
    Save()
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

int function _getMagicEffect(string enchantmentType, string enchantmentName, string magicEffectName) global
    int magicEffectsMap = _getMagicEffectsMap(enchantmentType, enchantmentName)
    return JMap.getObj(magicEffectsMap, magicEffectName)
endFunction

int function _getMagicEffectsMap(string enchantmentType, string enchantmentName) global
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
