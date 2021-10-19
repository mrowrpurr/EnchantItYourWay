scriptName EnchantAllTheThings extends Quest

Actor property PlayerRef auto

Message property EnchantThings_Menu_Main auto

Message property EnchantThings_Menu_ManageEnchantmentsLibrary auto
Message property EnchantThings_Menu_ViewEnchantment auto
Message property EnchantThings_Menu_ChooseEnchantmentType auto

Message property EnchantThings_Menu_ManageMagicEffectsLibrary auto
Message property EnchantThings_Menu_ViewMagicEffect auto

Message property EnchantThings_Menu_ChooseItem auto
Message property EnchantThings_Menu_SetName auto

Form property EnchantThings_MessageText_BaseForm auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Versioning
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

float property CurrentlyInstalledVersion auto

float function GetCurrentVersion() global
    return 1.0
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mod Installation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Mod Installation
event OnInit()
    CurrentlyInstalledVersion = GetCurrentVersion()
    Spell theSpell = Game.GetFormFromFile(0x802, "EnchantAllTheThings.esp") as Spell
    PlayerRef.EquipSpell(theSpell, 0)
    PlayerRef.EquipSpell(theSpell, 1)

    ; Load Config Files
    EnchantAllTheThings_MagicEffect.LoadFromFile()
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string property RecurringNotificationMessage auto
float property RecurringNotificationMessageInterval auto

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function MainMenu()
    SetMessageBoxText()
    int enchantItem = 0
    int enchantmentsLibrary = 1
    int magicEffectsLibrary = 2
    int result = EnchantThings_Menu_Main.Show()
    if result == enchantItem
        Debug.MessageBox("TODO")
    elseIf result == enchantmentsLibrary
        ManageEnchantments()
    elseIf result == magicEffectsLibrary
        ManageMagicEffects()
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function ManageEnchantments()
    SetMessageBoxText()
    int createNew = 0
    int remove = 1
    int rename = 2
    int viewEnchantment = 3
    int mainMenu = 4
    int result = EnchantThings_Menu_ManageEnchantmentsLibrary.Show()
    if result == createNew
        CreateNewEnchantment()
    elseIf result == viewEnchantment
        string enchantmentName = ChooseEnchantment(ChooseEnchantmentType())
        ; if theEnchantment_Search
        ;     string enchamentType = ChooseEnchantmentType()
        ;     string enchantmentName = ChooseEnchantment()
        ;     ViewEnchantment(enchantmentType, enchantmentName)
        ; else
        ;     ManageEnchantments()
        ; endIf
    elseIf result == mainMenu
        MainMenu()
    endIf
endFunction

function ShowSetNamePrompt(string text)
    SetMessageBoxText(text, header = "")
    EnchantThings_Menu_SetName.Show()
endFunction

function CreateNewEnchantment()
    string enchantmentType = ChooseEnchantmentType()
    ShowSetNamePrompt("Set a name for your new enchantment")

    bool uniqueName
    string enchantmentName
    while ! uniqueName
        enchantmentName = GetUserInput()
        if enchantmentName
            uniqueName = ! EnchantAllTheThings_MagicEffect.MagicEffectExists(enchantmentType, enchantmentName)
        else
            ManageEnchantments()
        endIf
    endWhile

    EnchantAllTheThings_Enchantment.Create(enchantmentType, enchantmentName)
    ViewEnchantment(enchantmentType, enchantmentName)
endFunction

function ViewEnchantment(string enchantmentType, string enchantmentName)
    string text = "Enchantment Type: " + enchantmentType + \
        "\nEnchantment Name: " + enchantmentName

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; TODO UPDATE THIS TO PRINT REAL NAMES, NOT FORM NAMES
    if EnchantAllTheThings_Enchantment.HasAnyMagicEffects(enchantmentType, enchantmentName)
        text += "\nMagic Effects:\n"
        MagicEffect[] theEffects = EnchantAllTheThings_Enchantment.GetMagicEffects(enchantmentType, enchantmentName)
        int i = 0
        while i < theEffects.Length
            text += "- " + theEffects[i].GetName() + "\n"
            i += 1
        endWhile
    endIf
    SetMessageBoxText(text)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    int enchantItem = 0
    int rename = 1
    int addMagicEffect = 2
    int viewMagicEffect = 3
    int mainMenu = 4
    int result = EnchantThings_Menu_ViewEnchantment.Show()
    if result == enchantItem
        ; EnchantItem(theEnchantment)
    elseIf result == rename
        ViewEnchanment_Rename(enchantmentType, enchantmentName)
        ViewEnchantment(enchantmentType, enchantmentName)
    elseIf result == addMagicEffect
        ViewEnchantment_AddMagicEffect(enchantmentType, enchantmentName)
        ViewEnchantment(enchantmentType, enchantmentName)
    elseIf result == viewMagicEffect
        Debug.MessageBox("VIEW MAGIC EFFECT")
    elseIf result == mainMenu
        MainMenu()
    endIf
endFunction

function ViewEnchantment_AddMagicEffect(string enchantmentType, string enchantmentName)
    string[] magicEffectNames = EnchantAllTheThings_MagicEffect.GetAllMagicEffectNames(enchantmentType)
    string[] options = Utility.CreateStringArray(magicEffectNames.Length + 1)
    options[0] = "[Search]"
    int i = 0
    while i < magicEffectNames.Length
        options[i + 1] = magicEffectNames[i]
        i += 1
    endWhile
    string magicEffectName = GetUserSelection(options)
    if magicEffectName == "[Search]"
        Debug.MessageBox("TODO SEARCH AGAIN")
    else
        EnchantAllTheThings_Enchantment.AddMagicEffect(enchantmentType, enchantmentName, magicEffectName)
    endIf
endFunction

string function ViewEnchanment_Rename(string enchantmentType, string enchantmentName)
    bool uniqueName
    string newName
    while ! uniqueName
        if newName
            newName = GetUserInput(newName)
        else
            newName = GetUserInput(enchantmentName)
        endIf
        uniqueName = ! EnchantAllTheThings_MagicEffect.MagicEffectExists(enchantmentType, newName)
    endWhile
    EnchantAllTheThings_Enchantment.SetName(enchantmentType, enchantmentName, newName)
    return newName
endFunction

; TODO extract ChooseMagicEffectFromEnchantment
; function ViewEnchantment_AddMagicEffect_Search(string enchantmentType, string enchantmentName)
;     string query = GetUserInput()

;     int searchResults = Search.ExecuteSearch(query, "MGEF")
;     JValue.retain(searchResults)
;     int effectCount = Search.GetResultCategoryCount(searchResults, "MGEF")

;     int effectDisplayNames = JArray.object()
;     JValue.retain(effectDisplayNames)

;     int effectDisplayNameIndexes = JMap.object()
;     JValue.retain(effectDisplayNameIndexes)

;     int i = 0
;     while i < effectCount
;         int effectResult = Search.GetNthResultInCategory(searchResults, "MGEF", i)
;         string effectName = Search.GetResultName(effectResult)
;         string formId = Search.GetResultFormID(effectResult)
;         MagicEffect theEffect = FormHelper.HexToForm(formId) as MagicEffect

;         if theEffect
;             ; Contant Effects on Self
;             if EnchantAllTheThings_Enchantment.IsArmorType(theEnchantment) && \
;                 theEffect.GetCastingType() == 0 && \
;                 theEffect.GetDeliveryType() == 0
;                 JArray.addStr(effectDisplayNames, effectName + " (" + formId + ")")
;                 JMap.setInt(effectDisplayNameIndexes, effectName + " (" + formId + ")", i)

;             ; Fire and Forget on Contact
;             elseIf EnchantAllTheThings_Enchantment.IsWeaponType(theEnchantment) && \
;                 theEffect.GetCastingType() == 1 && \
;                 theEffect.GetDeliveryType() == 1
;                 JArray.addStr(effectDisplayNames, effectName + " (" + formId + ")")
;                 JMap.setInt(effectDisplayNameIndexes, effectName + " (" + formId + ")", i)

;             endIf
;         endIf
;         i += 1
;     endWhile

;     string effectNameText = GetUserSelection(JArray.asStringArray(effectDisplayNames))
;     int resultIndex = JMap.getInt(effectDisplayNameIndexes, effectNameText)
;     int effectResult = Search.GetNthResultInCategory(searchResults, "MGEF", resultIndex)
;     string formId = Search.GetResultFormID(effectResult)

;     MagicEffect theEffect = FormHelper.HexToForm(formId) as MagicEffect
;     EnchantAllTheThings_Enchantment.AddMagicEffect(theEnchantment, theEffect)

;     Debug.MessageBox("Added " + theEffect.GetName() + " " + formId + " to " + EnchantAllTheThings_Enchantment.GetName(theEnchantment))

;     JValue.release(effectDisplayNames)
;     JValue.release(effectDisplayNameIndexes)
;     JValue.release(searchResults)

;     ViewEnchantment(theEnchantment)
; endFunction

; TODO put the enchantment display text here!
function EnchantItem(string enchantmentType, string enchantmentName)
    ; Form weaponOrArmor = ChooseItem( \
    ;     theEnchantment = theEnchantment, \
    ;     enchantmentType = EnchantAllTheThings_Enchantment.GetType(theEnchantment))

    ; Weapon theWeapon = weaponOrArmor as Weapon
    ; Armor  theArmor  = weaponOrArmor as Armor
    
    ; PlayerRef.AddItem(weaponOrArmor)

    ; int handSlot
    ; int slotMask

    ; if theWeapon
    ;     PlayerRef.EquipItemEx(theWeapon, equipSlot = 2) ; May or may not need to use the Ex version of this
    ;     handSlot = 1
    ;     slotMask = 0
    ; elseIf theArmor
    ;     PlayerRef.EquipItem(theArmor)
    ;     slotMask = theArmor.GetSlotMask()
    ; endIf

    ; float         maxCharge        = EnchantAllTheThings_Enchantment.GetMagicEffectMaxCharge(theEnchantment)
    ; MagicEffect[] theEffects       = EnchantAllTheThings_Enchantment.GetMagicEffects(theEnchantment)
    ; float[]       theMagnitudes    = EnchantAllTheThings_Enchantment.GetMagicEffectMagnitudes(theEnchantment)
    ; int[]         theAreaOfEffects = EnchantAllTheThings_Enchantment.GetMagicEffectAreaOfEffects(theEnchantment)
    ; int[]         theDurations     = EnchantAllTheThings_Enchantment.GetMagicEffectDurations(theEnchantment)

    ; Debug.MessageBox(maxCharge)
    ; Debug.MessageBox(theEffects)
    ; Debug.MessageBox(theMagnitudes)
    ; Debug.MessageBox(theAreaOfEffects)
    ; Debug.MessageBox(theDurations)

    ; WornObject.CreateEnchantment( \
    ;     PlayerRef, \
    ;     handSlot, \
    ;     slotMask, \
    ;     maxCharge, \
    ;     theEffects, \
    ;     theMagnitudes, \
    ;     theAreaOfEffects, \
    ;     theDurations \
    ; )

    ; Debug.MessageBox("Enchanted " + weaponOrArmor.GetName() + " with " + EnchantAllTheThings_Enchantment.GetName(theEnchantment))
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function ChooseEnchantment(string enchantmentType)
    string[] enchantmentNames = EnchantAllTheThings_Enchantment.GetAllEnchantmentNames(enchantmentType)
    return GetUserSelection(enchantmentNames)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function ManageMagicEffects()
    int add = 0
    int remove = 1
    int rename = 2
    int viewMagicEffect = 3
    int mainMenu = 4
    int result = EnchantThings_Menu_ManageMagicEffectsLibrary.Show()
    if result == add
    elseIf result == remove
    elseIf result == rename
    elseIf result == viewMagicEffect
        string enchantmentType = ChooseEnchantmentType()
        string magicEffectName = ChooseMagicEffect(enchantmentType)
        ViewMagicEffect(enchantmentType, magicEffectName)
    elseIf result == mainMenu
        MainMenu()
    endIf
endFunction

function ViewMagicEffect(string enchantmentType, string magicEffectName)
    SetMessageBoxText("Magic Effect: " + magicEffectName)
    int rename = 0
    int setMagnitude = 1
    int setDuration = 2
    int setAreaOfEffect = 3
    int setCost = 4
    int delete = 5
    int back = 6
    int mainMenu = 7
    int result = EnchantThings_Menu_ViewMagicEffect.Show()
    if result == rename
        string newName = ViewMagicEffect_Rename(enchantmentType, magicEffectName)
        ViewMagicEffect(enchantmentType, newName)
    elseIf result == setMagnitude

    elseIf result == setDuration

    elseIf result == setAreaOfEffect

    elseIf result == setCost

    elseIf result == delete

    elseIf result == back
        ; if theEnchantment
        ;     ; ViewEnchantment(enchantmentType, enchantmentName)
        ; else
        ;     ManageMagicEffects()
        ; endIf
    elseIf result == mainMenu
        MainMenu()
    endIf
endFunction

string function ViewMagicEffect_Rename(string enchantmentType, string magicEffectName)
    bool uniqueName
    string newName
    while ! uniqueName
        if newName
            newName = GetUserInput(newName)
        else
            newName = GetUserInput(magicEffectName)
        endIf
        uniqueName = ! EnchantAllTheThings_MagicEffect.MagicEffectExists(enchantmentType, newName)
    endWhile
    EnchantAllTheThings_MagicEffect.SetName(enchantmentType, magicEffectName, newName)
    return newName
endFunction

string function ChooseMagicEffect(string enchantmentType)
    string[] magicEffectNames = EnchantAllTheThings_MagicEffect.GetAllMagicEffectNames(enchantmentType)
    return GetUserSelection(magicEffectNames)
endFunction

int function ChooseMagicEffectFromEnchantment(int theEnchantment)
    Debug.MessageBox("TODO")    
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
            ; ViewEnchantment(enchantmentType, enchantmentName)
        else
            MainMenu()
        endIf
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

function SetMessageBoxText(string text = "", string header = "~ Enchant All The Things ~")
    if text
        if header
            EnchantThings_MessageText_BaseForm.SetName(header + "\n\n" + text)
        else
            EnchantThings_MessageText_BaseForm.SetName(text)
        endIf
    else
        EnchantThings_MessageText_BaseForm.SetName(header)
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
