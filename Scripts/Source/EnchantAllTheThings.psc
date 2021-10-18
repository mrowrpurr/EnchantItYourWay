scriptName EnchantAllTheThings extends Quest

; Before we ship this...
;
; Include a Fus Ro Dah-like effect on a sword...
;
; Make a single Magic Effect available for PushAway

Actor property PlayerRef auto

Message property EnchantThings_Menu_Main auto
Message property EnchantThings_Menu_ViewEnchantment auto
Message property EnchantThings_Menu_ManageEnchantments auto
Message property EnchantThings_Menu_ChooseEnchantmentType auto
Message property EnchantThings_Menu_ChooseItem auto
Message property EnchantThings_Menu_ViewEnchanementMagicEffect auto

Form property EnchantThings_MessageText_BaseForm auto

float property CurrentlyInstalledVersion auto

string property RecurringNotificationMessage auto
float property RecurringNotificationMessageInterval auto

float function GetCurrentVersion() global
    return 1.0
endFunction

; Mod Installation
event OnInit()
    CurrentlyInstalledVersion = GetCurrentVersion()
endEvent

event OnUpdate()
    if RecurringNotificationMessage
        Debug.Notification(RecurringNotificationMessage)
        RegisterForSingleUpdate(RecurringNotificationMessageInterval)
    endIf
endEvent

function ShowRecurringNotificatonMessage(string text, float interval = 3.0)
    RecurringNotificationMessage = text
    RecurringNotificationMessageInterval = interval
    RegisterForSingleUpdate(0)
endFunction

function StopRecurringNotificationMessage()
    RecurringNotificationMessage = ""
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
    string enchantmentType = ChooseEnchantmentType()
    int theEnchantment = EnchantAllTheThings_Enchantment.Create(enchantmentType)
    ViewEnchantment(theEnchantment)
endFunction

function ViewEnchantment(int theEnchantment)
    string text = "Enchantment Type: " + EnchantAllTheThings_Enchantment.GetType(theEnchantment) + \
        "\nEnchantment Name: " + EnchantAllTheThings_Enchantment.GetName(theEnchantment)

    if EnchantAllTheThings_Enchantment.HasAnyMagicEffects(theEnchantment)
        text += "\nMagic Effects:\n"
        MagicEffect[] theEffects = EnchantAllTheThings_Enchantment.GetMagicEffects(theEnchantment)
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

; TODO extract ChooseMagicEffect
function ViewEnchantment_AddMagicEffect(int theEnchantment)
    string query = GetUserInput()

    int searchResults = Search.ExecuteSearch(query, "MGEF")
    JValue.retain(searchResults)
    int effectCount = Search.GetResultCategoryCount(searchResults, "MGEF")

    int effectDisplayNames = JArray.object()
    JValue.retain(effectDisplayNames)

    int effectDisplayNameIndexes = JMap.object()
    JValue.retain(effectDisplayNameIndexes)

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
                JMap.setInt(effectDisplayNameIndexes, effectName + " (" + formId + ")", i)

            ; Fire and Forget on Contact
            elseIf EnchantAllTheThings_Enchantment.IsWeaponType(theEnchantment) && \
                theEffect.GetCastingType() == 1 && \
                theEffect.GetDeliveryType() == 1
                JArray.addStr(effectDisplayNames, effectName + " (" + formId + ")")
                JMap.setInt(effectDisplayNameIndexes, effectName + " (" + formId + ")", i)

            endIf
        endIf
        i += 1
    endWhile

    string effectNameText = GetUserSelection(JArray.asStringArray(effectDisplayNames))
    int resultIndex = JMap.getInt(effectDisplayNameIndexes, effectNameText)
    int effectResult = Search.GetNthResultInCategory(searchResults, "MGEF", resultIndex)
    string formId = Search.GetResultFormID(effectResult)

    MagicEffect theEffect = FormHelper.HexToForm(formId) as MagicEffect
    EnchantAllTheThings_Enchantment.AddMagicEffect(theEnchantment, theEffect)

    Debug.MessageBox("Added " + theEffect.GetName() + " " + formId + " to " + EnchantAllTheThings_Enchantment.GetName(theEnchantment))

    JValue.release(effectDisplayNames)
    JValue.release(effectDisplayNameIndexes)
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

; TODO put the enchantment display text here!
function EnchantItem(int theEnchantment)
    Form weaponOrArmor = ChooseItem( \
        theEnchantment = theEnchantment, \
        enchantmentType = EnchantAllTheThings_Enchantment.GetType(theEnchantment))

    Weapon theWeapon = weaponOrArmor as Weapon

    if ! theWeapon
        Debug.MessageBox("Sorry, we're only supporting weapons right now!")
        return
    endIf
    
    ; Debug.MessageBox("Player " + PlayerRef + " equipping " + theWeapon)
    PlayerRef.AddItem(theWeapon)
    PlayerRef.EquipItemEx(theWeapon, equipSlot = 1)

    int handSlot = 1
    int slotMask = 0

    float         maxCharge        = EnchantAllTheThings_Enchantment.GetMagicEffectMaxCharge(theEnchantment)
    MagicEffect[] theEffects       = EnchantAllTheThings_Enchantment.GetMagicEffects(theEnchantment)
    float[]       theMagnitudes    = EnchantAllTheThings_Enchantment.GetMagicEffectMagnitudes(theEnchantment)
    int[]         theAreaOfEffects = EnchantAllTheThings_Enchantment.GetMagicEffectAreaOfEffects(theEnchantment)
    int[]         theDurations     = EnchantAllTheThings_Enchantment.GetMagicEffectDurations(theEnchantment)

    Debug.MessageBox(maxCharge)
    Debug.MessageBox(theEffects)
    Debug.MessageBox(theMagnitudes)
    Debug.MessageBox(theAreaOfEffects)
    Debug.MessageBox(theDurations)

    WornObject.CreateEnchantment( \
        PlayerRef, \
        handSlot, \
        slotMask, \
        maxCharge, \
        theEffects, \
        theMagnitudes, \
        theAreaOfEffects, \
        theDurations \
    )

    Debug.MessageBox("Enchanted " + theWeapon.GetName() + " with " + EnchantAllTheThings_Enchantment.GetName(theEnchantment))
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
        return SearchAll(enchantmentType)
    elseIf result == searchInventory
        return SearchInventory(enchantmentType)
    elseIf result == listInventory
        return ChooseFromInventory(enchantmentType)
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

Form function SearchAll(string enchantmentType, bool showItemsWithEnchantments = false)
    string query = GetUserInput()

    ShowRecurringNotificatonMessage("Searching...")

    string category = SearchCategoryForEnchantmentType(enchantmentType)
    int searchResults = Search.ExecuteSearch(query, category)
    JValue.retain(searchResults)

    int itemDisplayNames = JArray.object()
    JValue.retain(itemDisplayNames)

    int categoryResultsCount = Search.GetResultCategoryCount(searchResults, category)
    int i = 0
    while i < categoryResultsCount
        int itemResult = Search.GetNthResultInCategory(searchResults, category, i)
        string name = Search.GetResultName(itemResult)
        string formId = Search.GetResultFormID(itemResult)
        if showItemsWithEnchantments
            JArray.addStr(itemDisplayNames, name + " (" + formId + ")")
        else
            Form theItem = FormHelper.HexToForm(formId)
            if ! IsEnchanted(theItem)
                JArray.addStr(itemDisplayNames, name + " (" + formId + ")")
            endIf
        endIf
        i += 1
    endWhile

    string itemDisplayText = GetUserSelection(JArray.asStringArray(itemDisplayNames))
    int resultIndex = JArray.findStr(itemDisplayNames, itemDisplayText)
    int itemResult = Search.GetNthResultInCategory(searchResults, category, resultIndex)
    string formId = Search.GetResultFormID(itemResult)

    JValue.release(searchResults)
    JValue.release(itemDisplayNames)
    StopRecurringNotificationMessage()

    return FormHelper.HexToForm(formId)
endFunction

bool function IsEnchanted(Form item)
    Enchantment theEnchantment
    Weapon theWeapon = item as Weapon
    Armor  theArmor  = item as Armor
    if theWeapon
        theEnchantment = theWeapon.GetEnchantment()
        ; No can do!
        ; if ! theEnchantment
        ;     theEnchantment = WornObject.GetEnchantment()
        ; endIf
    elseIf theArmor
        theEnchantment = theArmor.GetEnchantment()
        if ! theEnchantment

        endIf
    endIf
    return theEnchantment
endFunction

Form function SearchInventory(string enchantmentType)
    Debug.MessageBox("TODO")
endFunction

Form function ChooseFromInventory(string enchantmentType)
    Debug.MessageBox("TODO")
endFunction

string function ChooseEnchantmentType()
    SetMessageBoxText()
    int armorType = 0
    int weaponType = 1
    int result = EnchantThings_Menu_ChooseEnchantmentType.Show()
    if result == armorType
        return "ARMOR"
    elseIf result == weaponType
        return "WEAPON"
    endIf
endFunction

string function SearchCategoryForEnchantmentType(string enchantmentType)
    if enchantmentType == "WEAPON"
        return "WEAP"
    elseIf enchantmentType == "ARMOR"
        return "ARMO"
    endIf
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
