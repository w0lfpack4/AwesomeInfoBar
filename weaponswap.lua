
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Swap"] =  {
  --"Swap" = "|t36:36:EsoUI/Art/CharacterWindow/swap_button_up.dds|t",
  [AIB.colors.red.."DPS-1"]     = "|t32:32:esoui/art/icons/progression_tabicon_dualwield_up.dds|t",
  [AIB.colors.red.."DPS-2"]     = "|t32:32:esoui/art/icons/progression_tabicon_dualwield_up.dds|t",
  [AIB.colors.green.."HEAL-1"]  = "|t32:32:esoui/art/icons/progression_tabicon_healstaff_up.dds|t",
  [AIB.colors.green.."HEAL-2"]  = "|t32:32:esoui/art/icons/progression_tabicon_healstaff_up.dds|t",
  [AIB.colors.yellow.."TANK-1"] = "|t32:32:esoui/art/icons/progression_tabicon_1handed_up.dds|t",
  [AIB.colors.yellow.."TANK-2"] = "|t32:32:esoui/art/icons/progression_tabicon_1handed_up.dds|t",
}

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Swap"] = {
  on          = false,
  swap1Label  = AIB.colors.red.."DPS-1",
  swap2Label  = AIB.colors.red.."DPS-2",
  lastSwap    = 1,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Swap"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    -- load global defaults to character if missing
    if (AIB.saved.character.Swap == nil) then
      AIB.saved.character.Swap = AIB.defaults.Swap
    end
    AIB.plugins.Swap.UpdateWeaponSwap()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.character.Swap.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Swap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, AIB.plugins.Swap.OnActiveWeaponPairChanged)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Swap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    end
  end,

  ------------------------------------------------
  -- EVENT: OnActiveWeaponPairChanged
  ------------------------------------------------
  OnActiveWeaponPairChanged = function(event, activeWeaponPair, locked)
    AIB.plugins.Swap.UpdateWeaponSwap(activeWeaponPair)
  end,

  ------------------------------------------------
  -- METHOD: UpdateWeaponSwap
  ------------------------------------------------
  UpdateWeaponSwap = function(activeWeaponPair)
    local snoozing = AIB.isSnoozing("Swap")
    AIB.setLabel("Swap","")

    -- save last state
    if (not activeWeaponPair) then
      activeWeaponPair = AIB.saved.character.Swap.lastSwap
    else
      AIB.saved.character.Swap.lastSwap = activeWeaponPair
    end

    -- if show weapon swap
    if (AIB.saved.character.Swap.on and not snoozing) then
      --if (activeWeaponPair == 1) then
      --  AIB.setLabel("Swap",AIB.icons.Swap[AIB.saved.character.Swap.swap1Label]..AIB.saved.character.Swap.swap1Label)
      --else
      --  AIB.setLabel("Swap",AIB.icons.Swap[AIB.saved.character.Swap.swap2Label]..AIB.saved.character.Swap.swap2Label)
      --end
      AIB.setLabel("Swap",AIB.icons.Swap[AIB.saved.character.Swap.swap2Label]..activeWeaponPair)
    end
  end,

}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Swap.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Swap[AIB.colors.yellow.."TANK-1"]..AIB.colors.blue.."Weapon Swap Notification|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display current weapon set. These settings are per character.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.character.Swap.on end,
        setFunc = function(newValue) AIB.saved.character.Swap.on = newValue; AIB.plugins.Swap.RegisterEvents(); AIB.plugins.Swap.UpdateWeaponSwap() end,
        default = AIB.defaults.Swap.on,
      },
      {
        type = "dropdown",
        name = "Set 1 Name",
        tooltip = "The name to use for weapon set 1",
        choices = {AIB.colors.red.."DPS-1",AIB.colors.green.."HEAL-1",AIB.colors.yellow.."TANK-1"},
        setFunc = function(newValue)
          AIB.saved.character.Swap.swap1Label = newValue;
        end,
        getFunc = function() return AIB.saved.character.Swap.swap1Label end,
        disabled = function() return not(AIB.saved.character.Swap.on) end,
        default = AIB.defaults.Swap.swap1Label,
      },
      {
        type = "dropdown",
        name = "Set 2 Name",
        tooltip = "The name to use for weapon set 2",
        choices = {AIB.colors.red.."DPS-2",AIB.colors.green.."HEAL-2",AIB.colors.yellow.."TANK-2"},
        setFunc = function(newValue)
          AIB.saved.character.Swap.swap2Label = newValue;
        end,
        getFunc = function() return AIB.saved.character.Swap.swap2Label end,
        disabled = function() return not(AIB.saved.character.Swap.on) end,
        default = AIB.defaults.Swap.swap2Label,
      }
    }
  }
}
