scriptName EnchantAllTheThings extends Quest

Message property EnchantThings_Menu_Main auto
Message property EnchantThings_Menu_ViewEnchantment auto
Message property EnchantThings_Menu_ManageEnchantments auto
Message property EnchantThings_Menu_ChooseEnchantmentType auto
Message property EnchantThings_Menu_ChooseItem auto

Form property EnchantThings_MessageText_BaseForm auto

float property CurrentlyInstalledVersion auto

; Mod Installation
event OnInit()
    CurrentlyInstalledVersion = GetCurrentVersion()
endEvent

float function GetCurrentVersion() global
    return 1.0
endFunction

function MainMenu()
    SetMessageBoxText()
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
    SetMessageBoxText()
    int newEnchantment = 0
    int mainMenu = 1
    int result = EnchantThings_Menu_ManageEnchantments.Show()
    if result == newEnchantment
        NewEnchantment()
    elseIf result == mainMenu
        mainMenu()
    endIf
endFunction

function NewEnchantment()
    SetMessageBoxText()
    int armorType = 0
    int weaponType = 1
    int result = EnchantThings_Menu_ChooseEnchantmentType.Show()
    if result == armorType
        int theEnchantment = EnchantAllTheThings_Enchantment.Create("ARMOR")
        ViewEnchantment(theEnchantment)
    elseIf result == weaponType
        int theEnchantment = EnchantAllTheThings_Enchantment.Create("WEAPON")
        ViewEnchantment(theEnchantment)
    endIf
endFunction

string function ChooseEnchantmentType()
    int armorType = 0
    int weaponType = 1
    int result = EnchantThings_Menu_ChooseEnchantmentType.Show()
    if result == armorType
        return "ARMOR"
    elseIf result == weaponType
        return "WEAPON"
    endIf
endFunction

function ViewEnchantment(int theEnchantment)
    string text = "Enchantment Type: " + EnchantAllTheThings_Enchantment.GetType(theEnchantment) + \
        "\nEnchantment Name: " + EnchantAllTheThings_Enchantment.GetName(theEnchantment)

    if EnchantAllTheThings_Enchantment.HasAnyMagicEffects(theEnchantment)
        text += "\nMagic Effects:\n"
        Form[] theEffects = EnchantAllTheThings_Enchantment.GetMagicEffects(theEnchantment)
        int i = 0
        while i < theEffects.Length
            text += "- " + theEffects[i].GetName() + "\n"
            i += 1
        endWhile
    endIf
    SetMessageBoxText(text)

    int setName = 0
    int addMagicEffect = 1
    int modifyMagicEffect = 2
    int deleteMagicEffect = 3
    int enchantItem = 4
    int mainMenu = 5
    int result = EnchantThings_Menu_ViewEnchantment.Show()
    if result == setName
        string name = GetUserInput()
        EnchantAllTheThings_Enchantment.SetName(theEnchantment, name)
        ViewEnchantment(theEnchantment)
    elseIf result == addMagicEffect
        ViewEnchantment_AddMagicEffect(theEnchantment)
    elseIf result == modifyMagicEffect
        ; ; ; ModifyMagicEffect(theEnchantment)
    elseIf result == deleteMagicEffect
        ; ; ; DeleteMagicEffect(theEnchantment)
    elseIf result == enchantItem
        EnchantItem(theEnchantment)
    elseIf result == mainMenu
        MainMenu()
    endIf
endFunction

function ViewEnchantment_AddMagicEffect(int theEnchantment)
    string query = GetUserInput()

    int searchResults = Search.ExecuteSearch(query, "MGEF")
    JValue.retain(searchResults)
    int effectCount = Search.GetResultCategoryCount(searchResults, "MGEF")

    int effectDisplayNames = JArray.object()
    JValue.retain(effectDisplayNames)
    int i = 0
    while i < effectCount
        int effectResult = Search.GetNthResultInCategory(searchResults, "MGEF", i)
        string effectName = Search.GetResultName(effectResult)
        string formId = Search.GetResultFormID(effectResult)
        MagicEffect theEffect = FormHelper.HexToForm(formId) as MagicEffect

        if theEffect
            ; Contant Effects on Self
            if EnchantAllTheThings_Enchantment.IsArmorType(theEnchantment) && \
                theEffect.GetCastingType() == 0 && \
                theEffect.GetDeliveryType() == 0
                JArray.addStr(effectDisplayNames, effectName + " (" + formId + ")")
                
            ; Fire and Forget on Contact
            elseIf EnchantAllTheThings_Enchantment.IsWeaponType(theEnchantment) && \
                theEffect.GetCastingType() == 1 && \
                theEffect.GetDeliveryType() == 1
                JArray.addStr(effectDisplayNames, effectName + " (" + formId + ")")

            endIf
        endIf
        i += 1
    endWhile

    string effectNameText = GetUserSelection(JArray.asStringArray(effectDisplayNames))
    int resultIndex = JArray.findStr(effectDisplayNames, effectNameText)
    int effectResult = Search.GetNthResultInCategory(searchResults, "MGEF", resultIndex)
    string formId = Search.GetResultFormID(effectResult)

    MagicEffect theEffect = FormHelper.HexToForm(formId) as MagicEffect
    EnchantAllTheThings_Enchantment.AddMagicEffect(theEnchantment, theEffect)

    Debug.MessageBox("Added " + theEffect.GetName() + " to " + EnchantAllTheThings_Enchantment.GetName(theEnchantment))

    JValue.release(effectDisplayNames)
    JValue.release(searchResults)

    ViewEnchantment(theEnchantment)
endFunction

function SetMessageBoxText(string text = "")
    if text
        EnchantThings_MessageText_BaseForm.SetName("~ Enchant All The Things ~\n\n" + text)
    else
        EnchantThings_MessageText_BaseForm.SetName("~ Enchant All The Things ~")
    endIf
endFunction

function EnchantItem(int theEnchantment)
    Form weaponOrArmor = ChooseItem( \
        theEnchantment = theEnchantment, \
        enchantmentType = EnchantAllTheThings_Enchantment.GetType(theEnchantment))

    Debug.MessageBox("The item to enchant is: " + weaponOrArmor)
    ; ....
endFunction

Form function ChooseItem(string enchantmentType = "", int theEnchantment = 0)
    if ! enchantmentType
        enchantmentType = ChooseEnchantmentType()
    endIf
    SetMessageBoxText()
    int searchAll = 0
    int searchInventory = 1
    int listInventory = 2
    int mainMenu = 3
    int back = 4
    int result = EnchantThings_Menu_ChooseItem.Show()
    if result == searchAll
        return SearchAll()
    elseIf result == searchInventory
        return SearchInventory()
    elseIf result == listInventory
        return ChooseFromInventory()
    elseIf result == mainMenu
        MainMenu()
    elseIf result == back
        if theEnchantment
            ViewEnchantment(theEnchantment)
        else
            MainMenu()
        endIf
    endIf
endFunction

Form function SearchAll()
    string query = GetUserInput()
    ; int searchResults = Search.ExecuteSearch(query)
endFunction

Form function SearchInventory()
    Debug.MessageBox("TODO")
endFunction

Form function ChooseFromInventory()
    Debug.MessageBox("TODO")
endFunction

string function GetUserInput(string defaultText = "") global
    UITextEntryMenu textEntry = UIExtensions.GetMenu("UITextEntryMenu") as UITextEntryMenu
    if defaultText
        textEntry.SetPropertyString("text", defaultText)
    endIf
    textEntry.OpenMenu()
    return textEntry.GetResultString()
endFunction

string function GetUserSelection(string[] options, bool showFilter = true, string filter = "") global
    int optionsToShow = JArray.object()
    JValue.retain(optionsToShow)

    UIListMenu listMenu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
    if showFilter
        listMenu.AddEntryItem("[Filter List]")
    endIf

    int i = 0
    while i < options.Length
        string optionText = options[i]
        if ! filter || StringUtil.Find(optionText, filter) > -1
            JArray.addStr(optionsToShow, optionText)
            listMenu.AddEntryItem(optionText)
        endIf
        i += 1
    endWhile

    listMenu.OpenMenu()

    int selection = listMenu.GetResultInt()

    if selection > -1
        if selection == 0 && showFilter
            string[] theOptions = JArray.asStringArray(optionsToShow)
            JValue.release(optionsToShow)
            return GetUserSelection(theOptions, showFilter = true, filter = GetUserInput())
        else
            int index = selection
            if showFilter
                index = selection - 1
            endIf
            string option = JArray.getStr(optionsToShow, index)
            JValue.release(optionsToShow)
            return option
        endIf
    endIf
endFunction
