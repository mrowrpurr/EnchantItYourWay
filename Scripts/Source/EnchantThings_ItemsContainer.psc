scriptName EnchantThings_ItemsContainer extends ObjectReference  

EnchantAllTheThings property ModQuestScript auto

event OnItemRemoved(Form item, int count, ObjectReference akItemReference, ObjectReference akDestContainer)
    if ModQuestScript.CurrentlyChoosingItemFromInventory
        ModQuestScript.CurrentlySelectedItemFromInventory = item
        Input.TapKey(1) ; Escape
    endIf
endEvent
