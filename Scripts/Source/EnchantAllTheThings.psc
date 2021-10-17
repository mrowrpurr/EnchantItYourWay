scriptName EnchantAllTheThings extends Quest

Message property EnchantThings_Menu_ViewEnchantment auto
Message property EnchantThings_Menu_ManageEnchantments auto
Message property EnchantThings_Menu_Main auto

function MainMenu()
    int enchantItem = 0
    int enchantments = 1
    int result = EnchantThings_Menu_Main.Show()
    if result == enchantItem
        Debug.MessageBox("TODO")
    elseIf result == enchantments
        ManageEnchantments()
    endIf
endFunction

function ManageEnchantments()
    int newEnchantment = 0
    int mainMenu = 1
    int result = EnchantThings_Menu_ManageEnchantments.Show()
    if result == newEnchantment
        ViewEnchantment(EnchantAllTheThings_Enchantment.Create())
    elseIf result == mainMenu
        mainMenu()
    endIf
endFunction

function ViewEnchantment(int theEnchantment)
    int setName = 0
    int addMagicEffect = 1
    int modifyMagicEffect = 2
    int deleteMagicEffect = 3
    int mainMenu = 4
    int result = EnchantThings_Menu_ViewEnchantment.Show()
    if result == setName
        string name = GetUserInput()
        EnchantAllTheThings_Enchantment.SetName(theEnchantment, name)
        ViewEnchantment(theEnchantment)
    elseIf result == addMagicEffect
        AddMagicEffect(theEnchantment)
    elseIf result == modifyMagicEffect
        ; ModifyMagicEffect(theEnchantment)
    elseIf result == deleteMagicEffect
        ; DeleteMagicEffect(theEnchantment)
    elseIf result == mainMenu
        MainMenu()
    endIf
endFunction

function AddMagicEffect(int theEnchantment)
    string query = GetUserInput()

endFunction

string function GetUserInput(string defaultText = "")
    UITextEntryMenu textEntry = UIExtensions.GetMenu("UITextEntryMenu") as UITextEntryMenu
    if defaultText
        textEntry.SetPropertyString("text", defaultText)
    endIf
    textEntry.OpenMenu()
    return textEntry.GetResultString()
endFunction
