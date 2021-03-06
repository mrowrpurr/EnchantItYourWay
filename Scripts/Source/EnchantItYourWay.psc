scriptName EnchantItYourWay extends Quest

; Before bed tonight, create Crossbow of Restore Health

; When adding effects to an Enchantment, don't show the effects the enchantment already has

;;;
;;; 1: On RemoveItem, take the item AWAY from the player
;;;
;;; 2: When enchanting, SPAWN a new object...
;;;

Actor property PlayerRef auto

Message property EnchantItYourWay_Menu_Main auto
Message property EnchantItYourWay_Menu_ManageEnchantmentsLibrary auto
Message property EnchantItYourWay_Menu_ViewEnchantment auto
Message property EnchantItYourWay_Menu_ChooseEnchantmentType auto
Message property EnchantItYourWay_Menu_ManageMagicEffectsLibrary auto
Message property EnchantItYourWay_Menu_ViewMagicEffect auto
Message property EnchantItYourWay_Menu_SetName auto

Form property EnchantItYourWay_MessageText_BaseForm auto

ObjectReference property ItemsContainer auto

GlobalVariable property EnchantItYourWay_EnchantmentHasAnyEffects auto

bool property CurrentlyChoosingItemFromInventory auto
Form property CurrentlySelectedItemFromInventory auto
string property CurrentlySelectedItemEnchantementType auto

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
    Spell theSpell = Game.GetFormFromFile(0x802, "EnchantItYourWay.esp") as Spell
    PlayerRef.EquipSpell(theSpell, 0)
    PlayerRef.EquipSpell(theSpell, 1)

    ; Load Config Files
    EnchantItYourWay_MagicEffect.LoadFromFile()
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
    CurrentlySelectedItemEnchantementType = ""
    CurrentlySelectedItemFromInventory = None
    CurrentlyChoosingItemFromInventory = false

    ; TESTING
    EnchantItYourWay_Enchantment.LoadFromFile()
    EnchantItYourWay_MagicEffect.LoadFromFile()

    SetMessageBoxText()
    int enchantItem = 0
    int enchantmentsLibrary = 1
    int magicEffectsLibrary = 2
    int result = EnchantItYourWay_Menu_Main.Show()
    if result == enchantItem
        Form theItem = ChooseItemFromInventory()
        ManageEnchantments()
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
    int result = EnchantItYourWay_Menu_ManageEnchantmentsLibrary.Show()
    if result == createNew
        CreateNewEnchantment()
    elseIf result == viewEnchantment
        string enchantmentType = CurrentlySelectedItemEnchantementType
        if ! enchantmentType
            enchantmentType = ChooseEnchantmentType()
        endIf
        string enchantmentName = ChooseEnchantment(enchantmentType)
        if enchantmentName
            ViewEnchantment(enchantmentType, enchantmentName)
        else
            ManageEnchantments()
        endIf
    elseIf result == remove
        string enchantmentType = CurrentlySelectedItemEnchantementType
        if ! enchantmentType
            enchantmentType = ChooseEnchantmentType()
        endIf
        string enchantmentName = ChooseEnchantment(enchantmentType)
        EnchantItYourWay_Enchantment.Delete(enchantmentType, enchantmentName)
        Debug.MessageBox("Deleted enchantment " + enchantmentName)
        ManageEnchantments()
    elseIf result == mainMenu
        MainMenu()
    endIf
endFunction

function ShowSetNamePrompt(string text)
    SetMessageBoxText(text, header = "")
    EnchantItYourWay_Menu_SetName.Show()
endFunction

function CreateNewEnchantment()
    string enchantmentType = CurrentlySelectedItemEnchantementType
    if ! enchantmentType
        enchantmentType = ChooseEnchantmentType()
    endIf

    ShowSetNamePrompt("Set a name for your new enchantment")

    bool uniqueName
    string enchantmentName
    while ! uniqueName
        enchantmentName = GetUserInput()
        if enchantmentName
            uniqueName = ! EnchantItYourWay_Enchantment.EnchantmentExists(enchantmentType, enchantmentName)
        else
            ManageEnchantments()
            return
        endIf
    endWhile

    EnchantItYourWay_Enchantment.Create(enchantmentType, enchantmentName)
    ViewEnchantment(enchantmentType, enchantmentName)
endFunction

function ViewEnchantment(string enchantmentType, string enchantmentName)
    string text = "Enchantment Type: " + enchantmentType + \
        "\nEnchantment Name: " + enchantmentName

    if EnchantItYourWay_Enchantment.HasAnyMagicEffects(enchantmentType, enchantmentName)
        text += "\n\nMagic Effects:\n"
        string[] theEffectsNames = EnchantItYourWay_Enchantment.GetMagicEffectNames(enchantmentType, enchantmentName)
        int i = 0
        while i < theEffectsNames.Length
            text += "- " + theEffectsNames[i] + "\n"
            i += 1
        endWhile
    endIf
    SetMessageBoxText(text)

    if EnchantItYourWay_Enchantment.HasAnyMagicEffects(enchantmentType, enchantmentName)
        EnchantItYourWay_EnchantmentHasAnyEffects.Value = 1
    else
        EnchantItYourWay_EnchantmentHasAnyEffects.Value = 0
    endIf

    int enchantItem = 0
    int rename = 1
    int addMagicEffect = 2
    int viewMagicEffect = 3
    int mainMenu = 4
    int result = EnchantItYourWay_Menu_ViewEnchantment.Show()
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
        if magicEffectName
            ViewMagicEffect(enchantmentType, magicEffectName, enchantmentName)
        else
            ViewEnchantment(enchantmentType, enchantmentName)
        endIf
    elseIf result == mainMenu
        MainMenu()
    endIf
endFunction

function ViewEnchantment_AddMagicEffect(string enchantmentType, string enchantmentName)
    string[] magicEffectNames = EnchantItYourWay_MagicEffect.GetAllMagicEffectNames(enchantmentType)
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
        EnchantItYourWay_Enchantment.AddMagicEffect(enchantmentType, enchantmentName, magicEffectName)
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

    if effectNameText
        int resultIndex = JMap.getInt(effectDisplayNameIndexes, effectNameText)
        int effectResult = ConsoleSearch.GetNthResultOfRecordType(searchResults, "MGEF", resultIndex)
        string formId = ConsoleSearch.GetRecordFormID(effectResult)
        MagicEffect theEffect = FormHelper.HexToForm(formId) as MagicEffect
        
        ; Get a unique name for this magic effect
        ShowSetNamePrompt("Set a name for this magic effect")

        string magicEffectName = theEffect.GetName()
        bool uniqueName
        while ! uniqueName
            magicEffectName = GetUserInput(magicEffectName)
            if magicEffectName
                uniqueName = ! EnchantItYourWay_MagicEffect.MagicEffectExists(enchantmentType, magicEffectName)
            else
                ViewEnchantment(enchantmentType, enchantmentName)
                return
            endIf
        endWhile

        int magicEffectObject = EnchantItYourWay_MagicEffect.Create(enchantmentType, magicEffectName, theEffect)
        EnchantItYourWay_Enchantment.AddMagicEffect(enchantmentType, enchantmentName, magicEffectName)
    endIf

    JValue.release(effectDisplayNames)
    JValue.release(effectDisplayNameIndexes)
    JValue.release(searchResults)

    ViewEnchantment(enchantmentType, enchantmentName)
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
        uniqueName = ! EnchantItYourWay_MagicEffect.MagicEffectExists(enchantmentType, newName)
    endWhile
    EnchantItYourWay_Enchantment.SetName(enchantmentType, enchantmentName, newName)
    return newName
endFunction

function EnchantItem(string enchantmentType, string enchantmentName)
    Form weaponOrArmor = CurrentlySelectedItemFromInventory
    if ! weaponOrArmor
        weaponOrArmor = ChooseItemFromInventory(enchantmentType)
    endIf

    Weapon theWeapon = weaponOrArmor as Weapon
    Armor  theArmor  = weaponOrArmor as Armor

    ItemsContainer.RemoveAllItems()

    int existingItemCount = PlayerRef.GetItemCount(weaponOrArmor)
    if existingItemCount
        PlayerRef.RemoveItem(weaponOrArmor, existingItemCount, abSilent = true, akOtherContainer = ItemsContainer)
    endIf

    int handSlot
    int slotMask
    
    PlayerRef.AddItem(weaponOrArmor)
    PlayerRef.EquipItem(weaponOrArmor)

    ; Check Papyrus Extender TODO
    if theWeapon
        slotMask = 0
        if PlayerRef.GetEquippedWeapon(abLeftHand = true)
            handSlot = 0
        elseIf PlayerRef.GetEquippedWeapon(abLeftHand = false)
            handSlot = 1
        else
            Debug.MessageBox("Uh oh. Nothing got equipped! Object: " + weaponOrArmor) 
            return
        endIf
        theWeapon.SetEnchantmentValue(1) ; ??? Needed ??? Only operates on the base form
        if PlayerRef.IsWeaponDrawn()
            PlayerRef.SheatheWeapon()
            Utility.Wait(1)
        endIf
    else
        handSlot = 0
        slotMask = theArmor.GetSlotMask()
    endIf

    float maxCharge = 1000 ; TODO set via UI

    MagicEffect[] theEffects       = EnchantItYourWay_Enchantment.GetMagicEffects(enchantmentType, enchantmentName)
    float[]       theMagnitudes    = EnchantItYourWay_Enchantment.GetMagicEffectMagnitudes(enchantmentType, enchantmentName)
    int[]         theAreaOfEffects = EnchantItYourWay_Enchantment.GetMagicEffectAreaOfEffects(enchantmentType, enchantmentName)
    int[]         theDurations     = EnchantItYourWay_Enchantment.GetMagicEffectDurations(enchantmentType, enchantmentName)

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
        ItemsContainer.RemoveItem(weaponOrArmor, existingItemCount, abSilent = true, akOtherContainer = PlayerRef)
    endIf

    ShowSetNamePrompt("Set the name of your newly enchanted item")
    string name = GetUserInput(weaponOrArmor.GetName() + " of " + enchantmentName)
    WornObject.SetDisplayName(PlayerRef, handSlot, slotMask, name, force = true) 
    Debug.MessageBox("Enchanted " + name)
endFunction

string function ChooseEnchantment(string enchantmentType)
    string[] enchantmentNames = EnchantItYourWay_Enchantment.GetAllEnchantmentNames(enchantmentType)
    return GetUserSelection(enchantmentNames)
endFunction

function ManageMagicEffects()
    int add = 0
    int remove = 1
    int rename = 2
    int viewMagicEffect = 3
    int mainMenu = 4
    int result = EnchantItYourWay_Menu_ManageMagicEffectsLibrary.Show()
    if result == add
        
    elseIf result == remove
    elseIf result == rename
    elseIf result == viewMagicEffect
        string enchantmentType = CurrentlySelectedItemEnchantementType
        if ! enchantmentType
            enchantmentType = ChooseEnchantmentType()
        endIf
        string magicEffectName = ChooseMagicEffect(enchantmentType)
        if magicEffectName
            ViewMagicEffect(enchantmentType, magicEffectName)
        else
            ManageMagicEffects()
        endIf
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
    int result = EnchantItYourWay_Menu_ViewMagicEffect.Show()

    if result == rename
        string newName = ViewMagicEffect_Rename(enchantmentType, magicEffectName, enchantmentName)
        ViewMagicEffect(enchantmentType, newName, enchantmentName)
        
    elseIf result == setMagnitude
        float magnitude = EnchantItYourWay_MagicEffect.GetMagnitude(enchantmentType, magicEffectName, enchantmentName)
        float newMagnitude = GetUserInput(magnitude) as float
        if newMagnitude
            EnchantItYourWay_MagicEffect.SetMagnitude(enchantmentType, magicEffectName, newMagnitude, enchantmentName)
            Debug.MessageBox("Set magnitude of " + magicEffectName + " to " + newMagnitude)
        endIf
        ViewMagicEffect(enchantmentType, magicEffectName, enchantmentName)

    elseIf result == setDuration
        int duration = EnchantItYourWay_MagicEffect.GetDuration(enchantmentType, magicEffectName, enchantmentName)
        int newDuration = GetUserInput(duration) as int
        if newDuration
            EnchantItYourWay_MagicEffect.SetDuration(enchantmentType, magicEffectName, newDuration, enchantmentName)
            Debug.MessageBox("Set duration of " + magicEffectName + " to " + newDuration)
        endIf
        ViewMagicEffect(enchantmentType, magicEffectName, enchantmentName)

    elseIf result == setAreaOfEffect
        int areaOfEffect = EnchantItYourWay_MagicEffect.GetAreaOfEffect(enchantmentType, magicEffectName, enchantmentName)
        int newAreaOfEffect = GetUserInput(areaOfEffect) as int
        if newAreaOfEffect
            EnchantItYourWay_MagicEffect.SetAreaOfEffect(enchantmentType, magicEffectName, newAreaOfEffect, enchantmentName)
            Debug.MessageBox("Set areaOfEffect of " + magicEffectName + " to " + newAreaOfEffect)
        endIf
        ViewMagicEffect(enchantmentType, magicEffectName, enchantmentName)

    elseIf result == delete
        EnchantItYourWay_Enchantment.RemoveMagicEffect(enchantmentType, enchantmentName, magicEffectName)
        ViewEnchantment(enchantmentType, enchantmentName)

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
        uniqueName = ! EnchantItYourWay_MagicEffect.MagicEffectExists(enchantmentType, newName, enchantmentName)
    endWhile
    EnchantItYourWay_MagicEffect.SetName(enchantmentType, magicEffectName, newName, enchantmentName)
    return newName
endFunction

string function ChooseMagicEffect(string enchantmentType, string enchantmentName = "")
    string[] magicEffectNames = EnchantItYourWay_MagicEffect.GetAllMagicEffectNames(enchantmentType, enchantmentName)
    return GetUserSelection(magicEffectNames)
endFunction

; TODO!
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

Form function ChooseItemFromInventory(string enchantmentType = "")
    ItemsContainer.RemoveAllItems()
    int itemCount = PlayerRef.GetNumItems()
    int i = 0
    while i < itemCount
        Form theForm = PlayerRef.GetNthForm(i)
        if ! IsEnchanted(theForm)
            Weapon theWeapon = theForm as Weapon
            Armor  theArmor  = theForm as Armor
            if ((! enchantmentType) && (theWeapon || theArmor)) || (enchantmentType == "WEAPON" && theWeapon) || (enchantmentType == "ARMOR" && theArmor)
                ; TODO - what to do if it's an ObjectReference, e.g. quest item
                ItemsContainer.AddItem(theForm)
            endIf
        endIf
        i += 1
    endWhile

    CurrentlyChoosingItemFromInventory = true
    ListenForContainerMenu()

    ; This opens the container view (NON-BLOCKING)
    ItemsContainer.Activate(PlayerRef)

    ; Block and WAIT for either:
    ; (a) An item to be selected
    ; (b) The inventory chooser to be closed
    while CurrentlyChoosingItemFromInventory
        Utility.WaitMenuMode(0.5)
    endWhile

    CurrentlyChoosingItemFromInventory = false
    Form theForm = CurrentlySelectedItemFromInventory
    if theForm as Weapon
        CurrentlySelectedItemEnchantementType = "WEAPON"
    elseIf theForm as Armor
        CurrentlySelectedItemEnchantementType = "ARMOR"
    endIf

    return theForm
endFunction

string function ChooseEnchantmentType(string text = "Choose enchantment item type: Armor or Weapons")
    SetMessageBoxText(text, header = "")
    int armorType = 0
    int weaponType = 1
    int result = EnchantItYourWay_Menu_ChooseEnchantmentType.Show()
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
            EnchantItYourWay_MessageText_BaseForm.SetName(header + "\n\n" + text)
        else
            EnchantItYourWay_MessageText_BaseForm.SetName(text)
        endIf
    else
        EnchantItYourWay_MessageText_BaseForm.SetName(header)
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

function ListenForContainerMenu()
    RegisterForMenu("ContainerMenu")
endFunction

function StopListeningForContainerMenu()
    UnregisterForMenu("ContainerMenu")
endFunction

event OnMenuClose(string menuName)
    if menuName == "ContainerMenu"
        CurrentlyChoosingItemFromInventory = false
    endIf
endEvent
