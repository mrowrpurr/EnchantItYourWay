.info
  .source "EnchantItYourWay_ItemsContainer.psc"
  .modifyTime 1636336687
  .compileTime 1636337028
  .user "mrowr"
  .computer "MROWR-PURR"
.endInfo
.userFlagsRef
  .flag conditional 1
  .flag hidden 0
.endUserFlagsRef
.objectTable
  .object EnchantItYourWay_ItemsContainer ObjectReference
    .userFlags 0
    .docString ""
    .autoState 
    .variableTable
      .variable ::ModQuestScript_var enchantityourway
        .userFlags 0
        .initialValue None
      .endVariable
    .endVariableTable
    .propertyTable
	  .property ModQuestScript EnchantItYourWay auto
	    .userFlags 0
	    .docString ""
	    .autoVar ::ModQuestScript_var
	  .endProperty
    .endPropertyTable
    .stateTable
      .state
        .function GetState
          .userFlags 0
          .docString "Function that returns the current state"
          .return String
          .paramTable
          .endParamTable
          .localTable
          .endLocalTable
          .code
            RETURN ::state
          .endCode
        .endFunction
        .function GotoState
          .userFlags 0
          .docString "Function that switches this object to the specified state"
          .return None
          .paramTable
            .param newState String
          .endParamTable
          .localTable
            .local ::NoneVar None
          .endLocalTable
          .code
            CALLMETHOD onEndState self ::NoneVar
            ASSIGN ::state newState
            CALLMETHOD onBeginState self ::NoneVar
          .endCode
        .endFunction
        .function OnItemRemoved 
          .userFlags 0
          .docString ""
          .return NONE
          .paramTable
            .param item Form
            .param count int
            .param akItemReference ObjectReference
            .param akDestContainer ObjectReference
          .endParamTable
          .localTable
            .local ::temp0 bool
            .local ::temp1 form
            .local ::nonevar none
          .endLocalTable
          .code
            PROPGET CurrentlyChoosingItemFromInventory ::ModQuestScript_var ::temp0 ;@line 6
            JUMPF ::temp0 label1 ;@line 6
            ASSIGN ::temp1 item ;@line 7
            PROPSET CurrentlySelectedItemFromInventory ::ModQuestScript_var ::temp1 ;@line 7
            CALLSTATIC input TapKey ::nonevar 1 ;@line 8
            JUMP label0
            label1:
            label0:
          .endCode
        .endFunction
      .endState
    .endStateTable
  .endObject
.endObjectTable