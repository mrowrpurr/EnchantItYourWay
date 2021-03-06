scriptName EnchantItYourWay_Enchantment
{Represents the 'Enchant All The Things' version of an enchantment}

int function Create(string enchantmentType, string enchantmentName) global
    int enchantmentsForType = _getEnchantmentsMapForType(enchantmentType)
    int theEnchantment = JMap.object()
    JMap.setObj(enchantmentsForType, enchantmentName, theEnchantment)
    JMap.setObj(theEnchantment, "magicEffects", JMap.object())
    Save()
endFunction

function Delete(string enchantmentType, string enchantmentName) global
    int enchantmentsForType = _getEnchantmentsMapForType(enchantmentType)
    JMap.removeKey(enchantmentsForType, enchantmentName)
    Save()
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
    elseIf magicEffectCount == 4
        magicEffects = new MagicEffect[4]
    elseIf magicEffectCount == 5
        magicEffects = new MagicEffect[5]
    elseIf magicEffectCount == 6
        magicEffects = new MagicEffect[6]
    else
        Debug.MessageBox("No support yet for more than 6 magic effects") ; TODO
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

float[] function GetMagicEffectMagnitudes(string enchantmentType, string enchantmentName) global
    int magicEffectsMap       = _getMagicEffectsMap(enchantmentType, enchantmentName)
    string[] magicEffectNames = JMap.allKeysPArray(magicEffectsMap)
    float[] magnitudes        = Utility.CreateFloatArray(magicEffectNames.Length)
    int i = 0
    while i < magicEffectNames.Length
        int magicEffectObject = JMap.getObj(magicEffectsMap, magicEffectNames[i])
        float magnitude = JMap.getFlt(magicEffectObject, "Magnitude") as float
        magnitudes[i] = magnitude
        i += 1
    endWhile
    return magnitudes
endFunction

int[] function GetMagicEffectDurations(string enchantmentType, string enchantmentName) global
    int magicEffectsMap       = _getMagicEffectsMap(enchantmentType, enchantmentName)
    string[] magicEffectNames = JMap.allKeysPArray(magicEffectsMap)
    int[] durations           = Utility.CreateIntArray(magicEffectNames.Length)
    int i = 0
    while i < magicEffectNames.Length
        int magicEffectObject = JMap.getObj(magicEffectsMap, magicEffectNames[i])
        int duration = JMap.getFlt(magicEffectObject, "Duration") as int
        durations[i] = duration
        i += 1
    endWhile
    return durations
endFunction

int[] function GetMagicEffectAreaOfEffects(string enchantmentType, string enchantmentName) global
    int magicEffectsMap       = _getMagicEffectsMap(enchantmentType, enchantmentName)
    string[] magicEffectNames = JMap.allKeysPArray(magicEffectsMap)
    int[] areaOfEffects           = Utility.CreateIntArray(magicEffectNames.Length)
    int i = 0
    while i < magicEffectNames.Length
        int magicEffectObject = JMap.getObj(magicEffectsMap, magicEffectNames[i])
        int areaOfEffect = JMap.getFlt(magicEffectObject, "AreaOfEffect") as int
        areaOfEffects[i] = areaOfEffect
        i += 1
    endWhile
    return areaOfEffects
endFunction

function AddMagicEffect(string enchantmentType, string enchantmentName, string magicEffectName) global
    int magicEffectsMap = _getMagicEffectsMap(enchantmentType, enchantmentName)
    int baseMagicEffect = EnchantItYourWay_MagicEffect._getMagicEffect(enchantmentType, magicEffectName)
    int enchantmentMagicEffect = JValue.shallowCopy(baseMagicEffect)
    JMap.setObj(magicEffectsMap, magicEffectName, enchantmentMagicEffect)
    Save()
endFunction

function RemoveMagicEffect(string enchantmentType, string enchantmentName, string magicEffectName) global
    int magicEffectsMap = _getMagicEffectsMap(enchantmentType, enchantmentName)
    JMap.removeKey(magicEffectsMap, magicEffectName)
    Save()
endFunction

function Save() global
    string filename = "Data/EnchantItYourWay/Enchantments.json"
    JValue.writeToFile(_getAllEnchantmentsMap(), filename)
endFunction

function LoadFromFile() global
    string filename = "Data/EnchantItYourWay/Enchantments.json"
    int fileData = JValue.readFromFile(filename)
    if fileData
        JDB.solveObjSetter(".enchantItYourWay.enchantments", fileData, createMissingKeys = true)
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
    int enchantmentsMap = JDB.solveObj(".enchantItYourWay.enchantments")
    if ! enchantmentsMap
        enchantmentsMap = JMap.object()
        JDB.solveObjSetter(".enchantItYourWay.enchantments", enchantmentsMap, createMissingKeys = true)
        JMap.setObj(enchantmentsMap, "Weapon", JMap.object())
        JMap.setObj(enchantmentsMap, "Armor", JMap.object())
    endIf
    return enchantmentsMap
endFunction
