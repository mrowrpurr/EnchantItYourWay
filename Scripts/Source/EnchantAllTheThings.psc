scriptName EnchantAllTheThings extends Quest

; Before bed tonight, create Crossbow of Restore Health

; When adding effects to an Enchantment, don't show the effects the enchantment already has

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

function MainMenu()
    ; TESTING
    EnchantAllTheThings_Enchantment.LoadFromFile()
    EnchantAllTheThings_MagicEffect.LoadFromFile()

    SetMessageBoxText()
    int enchantItem = 0
    int enchantmentsLibrary = 1
    int magicEffectsLibrary = 2
    int result = EnchantThings_Menu_Main.Show()
    if result == enchantItem
        ChooseItem(ChooseEnchantmentType())
        ; Now do something....
        Debug.MessageBox("TODO")
    elseIf result == enchantmentsLibrary
        ManageEnchantments()
    elseIf result == magicEffectsLibrary
        ManageMagicEffects()
    endIf
endFunction

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
        string enchantmentType = ChooseEnchantmentType()
        string enchantmentName = ChooseEnchantment(enchantmentType)
        ViewEnchantment(enchantmentType, enchantmentName)
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

    if EnchantAllTheThings_Enchantment.HasAnyMagicEffects(enchantmentType, enchantmentName)
        text += "\n\nMagic Effects:\n"
        string[] theEffectsNames = EnchantAllTheThings_Enchantment.GetMagicEffectNames(enchantmentType, enchantmentName)
        int i = 0
        while i < theEffectsNames.Length
            text += "- " + theEffectsNames[i] + "\n"
            i += 1
        endWhile
    endIf
    SetMessageBoxText(text)

    int enchantItem = 0
    int rename = 1
    int addMagicEffect = 2
    int viewMagicEffect = 3
    int mainMenu = 4
    int result = EnchantThings_Menu_ViewEnchantment.Show()
    if result == enchantItem
        EnchantItem(enchantmentType, enchantmentName)
    elseIf result == rename
        ViewEnchanment_Rename(enchantmentType, enchantmentName)
        ViewEnchantment(enchantmentType, enchantmentName)
    elseIf result == addMagicEffect
        ViewEnchantment_AddMagicEffect(enchantmentType, enchantmentName)
        ViewEnchantment(enchantmentType, enchantmentName)
    elseIf result == viewMagicEffect
        string magicEffectName = ChooseMagicEffect(enchantmentType, enchantmentName)
        ViewMagicEffect(enchantmentType, magicEffectName, enchantmentName)
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
        ViewEnchantment_AddMagicEffect_Search(enchantmentType, enchantmentName)
    else
        EnchantAllTheThings_Enchantment.AddMagicEffect(enchantmentType, enchantmentName, magicEffectName)
    endIf
endFunction

function ViewEnchantment_AddMagicEffect_Search(string enchantmentType, string enchantmentName)
    string query = GetUserInput()
    if ! query
        ViewEnchantment(enchantmentType, enchantmentName)
        return
    endIf

    int searchResults = ConsoleSearch.ExecuteSearch(query, "MGEF")
    JValue.retain(searchResults)
    int effectCount = ConsoleSearch.GetResultRecordTypeCount(searchResults, "MGEF")

    int effectDisplayNames = JArray.object()
    JValue.retain(effectDisplayNames)

    int effectDisplayNameIndexes = JMap.object()
    JValue.retain(effectDisplayNameIndexes)

    int i = 0
    while i < effectCount
        int effectResult = ConsoleSearch.GetNthResultOfRecordType(searchResults, "MGEF", i)
        string effectName = ConsoleSearch.GetRecordName(effectResult)
        string formId = ConsoleSearch.GetRecordFormID(effectResult)
        MagicEffect theEffect = FormHelper.HexToForm(formId) as MagicEffect

        if theEffect
            ; Contant Effects on Self
            if enchantmentType == "ARMOR" && \
               theEffect.GetCastingType() == 0 && \
               theEffect.GetDeliveryType() == 0
               JArray.addStr(effectDisplayNames, effectName + " (" + formId + ")")
               JMap.setInt(effectDisplayNameIndexes, effectName + " (" + formId + ")", i)

            ; Fire and Forget on Contact
            elseIf enchantmentType == "WEAPON" && \
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
    int effectResult = ConsoleSearch.GetNthResultOfRecordType(searchResults, "MGEF", resultIndex)
    string formId = ConsoleSearch.GetRecordFormID(effectResult)
    MagicEffect theEffect = FormHelper.HexToForm(formId) as MagicEffect
    int magicEffectObject = EnchantAllTheThings_MagicEffect.Create(enchantmentType, theEffect)

    

    ; EnchantAllTheThings_Enchantment.AddMagicEffect()

        ; TODO

    ; EnchantAllTheThings_Enchantment.AddMagicEffect(theEnchantment, theEffect)

    ; Debug.MessageBox("Added " + theEffect.GetName() + " " + formId + " to " + EnchantAllTheThings_Enchantment.GetName(theEnchantment))

    ; JValue.release(effectDisplayNames)
    ; JValue.release(effectDisplayNameIndexes)
    ; JValue.release(searchResults)

    ; ViewEnchantment(theEnchantment)
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

function EnchantItem(string enchantmentType, string enchantmentName)
    Debug.MessageBox("Enchant Item")

    Form weaponOrArmor = ChooseItem(enchantmentType, enchantmentName)

    Debug.MessageBox("EnchantItem(" + weaponOrArmor + " : " + weaponOrArmor.GetName() + ")")

    Weapon theWeapon = weaponOrArmor as Weapon
    Armor  theArmor  = weaponOrArmor as Armor

    int existingItemCount = PlayerRef.GetItemCount(weaponOrArmor)
    if existingItemCount
        PlayerRef.RemoveItem(weaponOrArmor, existingItemCount, abSilent = true)
    endIf

    int handSlot
    int slotMask

    if theWeapon
        slotMask = 0
        handSlot = 1
        theWeapon.SetEnchantmentValue(1)
    else
        handSlot = 0
        slotMask = theArmor.GetSlotMask()
    endIf

    PlayerRef.AddItem(weaponOrArmor, abSilent = true)
    PlayerRef.EquipItem(weaponOrArmor, abSilent = true)

    Utility.Wait(0.2)

    ; TODO set via UI
    float maxCharge = 1000

    MagicEffect[] theEffects       = EnchantAllTheThings_Enchantment.GetMagicEffects(enchantmentType, enchantmentName)
    float[]       theMagnitudes    = EnchantAllTheThings_Enchantment.GetMagicEffectMagnitudes(enchantmentType, enchantmentName)
    int[]         theAreaOfEffects = EnchantAllTheThings_Enchantment.GetMagicEffectAreaOfEffects(enchantmentType, enchantmentName)
    int[]         theDurations     = EnchantAllTheThings_Enchantment.GetMagicEffectDurations(enchantmentType, enchantmentName)

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

    if existingItemCount
        PlayerRef.AddItem(weaponOrArmor, existingItemCount, abSilent = true)
    endIf

    ShowSetNamePrompt("Set the name of your newly enchanted item")
    string name = GetUserInput(weaponOrArmor.GetName() + " of " + enchantmentName)
    WornObject.SetDisplayName(PlayerRef, handSlot, slotMask, name, force = true) 
    Debug.MessageBox("Enchanted " + name)

    Debug.MessageBox(FormHelper.FormToHex(WornObject.GetEnchantment(PlayerRef, handSlot, slotMask)))
endFunction

string function ChooseEnchantment(string enchantmentType)
    string[] enchantmentNames = EnchantAllTheThings_Enchantment.GetAllEnchantmentNames(enchantmentType)
    return GetUserSelection(enchantmentNames)
endFunction

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

function ViewMagicEffect(string enchantmentType, string magicEffectName, string enchantmentName = "")
    SetMessageBoxText("Magic Effect: " + magicEffectName)
    int rename = 0
    int setMagnitude = 1
    int setDuration = 2
    int setAreaOfEffect = 3
    int delete = 4
    int back = 5
    int mainMenu = 6
    int result = EnchantThings_Menu_ViewMagicEffect.Show()

    if result == rename
        string newName = ViewMagicEffect_Rename(enchantmentType, magicEffectName, enchantmentName)
        ViewMagicEffect(enchantmentType, newName, enchantmentName)
        
    elseIf result == setMagnitude
        float magnitude = EnchantAllTheThings_MagicEffect.GetMagnitude(enchantmentType, magicEffectName, enchantmentName)
        float newMagnitude = GetUserInput(magnitude) as float
        if newMagnitude
            EnchantAllTheThings_MagicEffect.SetMagnitude(enchantmentType, magicEffectName, newMagnitude, enchantmentName)
            Debug.MessageBox("Set magnitude of " + magicEffectName + " to " + newMagnitude)
        endIf
        ViewMagicEffect(enchantmentType, magicEffectName, enchantmentName)

    elseIf result == setDuration
        int duration = EnchantAllTheThings_MagicEffect.GetDuration(enchantmentType, magicEffectName, enchantmentName)
        int newDuration = GetUserInput(duration) as int
        if newDuration
            EnchantAllTheThings_MagicEffect.SetDuration(enchantmentType, magicEffectName, newDuration, enchantmentName)
            Debug.MessageBox("Set duration of " + magicEffectName + " to " + newDuration)
        endIf
        ViewMagicEffect(enchantmentType, magicEffectName, enchantmentName)

    elseIf result == setAreaOfEffect
        int areaOfEffect = EnchantAllTheThings_MagicEffect.GetAreaOfEffect(enchantmentType, magicEffectName, enchantmentName)
        int newAreaOfEffect = GetUserInput(areaOfEffect) as int
        if newAreaOfEffect
            EnchantAllTheThings_MagicEffect.SetAreaOfEffect(enchantmentType, magicEffectName, newAreaOfEffect, enchantmentName)
            Debug.MessageBox("Set areaOfEffect of " + magicEffectName + " to " + newAreaOfEffect)
        endIf
        ViewMagicEffect(enchantmentType, magicEffectName, enchantmentName)

    elseIf result == delete
        Debug.MessageBox("TODO")

    elseIf result == back
        if enchantmentName
            ViewEnchantment(enchantmentType, enchantmentName)
        else
            ManageMagicEffects()
        endIf

    elseIf result == mainMenu
        MainMenu()
    endIf
endFunction

string function ViewMagicEffect_Rename(string enchantmentType, string magicEffectName, string enchantmentName)
    bool uniqueName
    string newName
    while ! uniqueName
        if newName
            newName = GetUserInput(newName)
        else
            newName = GetUserInput(magicEffectName)
        endIf
        uniqueName = ! EnchantAllTheThings_MagicEffect.MagicEffectExists(enchantmentType, newName, enchantmentName)
    endWhile
    EnchantAllTheThings_MagicEffect.SetName(enchantmentType, magicEffectName, newName, enchantmentName)
    return newName
endFunction

string function ChooseMagicEffect(string enchantmentType, string enchantmentName = "")
    string[] magicEffectNames = EnchantAllTheThings_MagicEffect.GetAllMagicEffectNames(enchantmentType, enchantmentName)
    return GetUserSelection(magicEffectNames)
endFunction

Form function ChooseItem(string enchantmentType, string enchantmentName = "")
    Debug.MessageBox("Choose Item")
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
        if enchantmentName
            ViewEnchantment(enchantmentType, enchantmentName)
        else
            MainMenu()
        endIf
    endIf
endFunction

Form function SearchAll(string enchantmentType, bool showItemsWithEnchantments = false)
    string query = GetUserInput()

    ShowRecurringNotificatonMessage("Searching...")

    string category = SearchCategoryForEnchantmentType(enchantmentType)
    int searchResults = ConsoleSearch.ExecuteSearch(query, category)
    JValue.retain(searchResults)

    int itemDisplayNames = JArray.object()
    JValue.retain(itemDisplayNames)

    int itemDisplayNamesToIndex = JMap.object()
    JValue.retain(itemDisplayNamesToIndex)

    int categoryResultsCount = ConsoleSearch.GetResultRecordTypeCount(searchResults, category)
    int i = 0
    while i < categoryResultsCount
        int itemResult = ConsoleSearch.GetNthResultOfRecordType(searchResults, category, i)
        string name = ConsoleSearch.GetRecordName(itemResult)
        string formId = ConsoleSearch.GetRecordFormID(itemResult)
        string displayName = name + " (" + formId + ")"
        if showItemsWithEnchantments
            JArray.addStr(itemDisplayNames, displayName)
            JMap.setInt(itemDisplayNamesToIndex, displayName, i)
        else
            Form theItem = FormHelper.HexToForm(formId)
            if ! IsEnchanted(theItem)
                JArray.addStr(itemDisplayNames, displayName)
                JMap.setInt(itemDisplayNamesToIndex, displayName, i)
            endIf
        endIf
        i += 1
    endWhile

    string itemDisplayText = GetUserSelection(JArray.asStringArray(itemDisplayNames))
    int resultIndex = JMap.getInt(itemDisplayNamesToIndex, itemDisplayText)
    int itemResult = ConsoleSearch.GetNthResultOfRecordType(searchResults, category, resultIndex)
    string formId = ConsoleSearch.GetRecordFormID(itemResult)

    JValue.release(searchResults)
    JValue.release(itemDisplayNames)
    JValue.release(itemDisplayNamesToIndex)
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
    SetMessageBoxText("Choose either Armor or Weapons to enchant", header = "")
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
