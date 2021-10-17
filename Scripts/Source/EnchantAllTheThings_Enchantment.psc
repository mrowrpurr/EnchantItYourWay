scriptName EnchantAllTheThings_Enchantment
{Represents the 'Enchant All The Things' version of an enchantment}

int function Create() global
    int newEnchantment = JMap.object()
    JArray.addObj(GetEnchantmentsArray(), newEnchantment)
    return newEnchantment
endFunction

function SetName(int theEnchantment, string name) global
    JMap.setStr(theEnchantment, "name", name)
endFunction

string function GetName(int theEnchantment) global
    return JMap.getStr(theEnchantment, "name")
endFunction

int function GetEnchantmentsArray() global
    int theArray = JDB.solveObj(".enchantAllTheThings.enchantments")
    if ! theArray
        theArray = JArray.object()
        JDB.solveObjSetter(".enchantAllTheThings.enchantments", theArray, createMissingKeys = true)
    endIf
    return theArray
endFunction