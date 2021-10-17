scriptName EnchantThings_MainMenu_Effect extends ActiveMagicEffect

EnchantAllTheThings property EnchantAllTheThings_Script auto

event OnEffectStart(Actor target, Actor caster)
    EnchantAllTheThings_Script.MainMenu()
endEvent
