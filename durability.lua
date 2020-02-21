
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Durability"]         =  "|t24:24:"..AIB.name.."/Textures/durability.dds|t"
AIB.icons["DurabilityCritical"] =  "|t24:24:"..AIB.name.."/Textures/durability_critical.dds|t"
AIB.icons["DurabilityWarning"]  =  "|t24:24:"..AIB.name.."/Textures/durability_warning.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Durability"] = {
  on        = true,
  alwaysOn  = false,
  warning   = 50,       -- percentage
  critical  = 25,       -- percentage
}

----------------------------------------------------
-- LOCAL VARS
----------------------------------------------------
AIB.vars["Durability"] = {
  lastUpdate  = 0,
  frequency   = 10
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Durability"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.plugins.Durability.UpdateDurability()
  end,

  ------------------------------------------------
  -- PARENT METHOD: Update (every 1 sec)
  ------------------------------------------------
  Update = function()
    if (AIB.saved.account.Durability.on) then
      -- less frequent update (10 sec default)
      AIB.vars.Durability.lastUpdate = AIB.vars.Durability.lastUpdate + 1
      if (AIB.vars.Durability.lastUpdate > AIB.vars.Durability.frequency) then
        AIB.vars.Durability.lastUpdate = 0
        AIB.plugins.Durability.UpdateDurability()
      end
    end
  end,

  ------------------------------------------------
  -- METHOD: UpdateDurability
  ------------------------------------------------
  UpdateDurability = function()
    local snoozing = AIB.isSnoozing("Durability")
    AIB.setLabel("Durability","")

    -- if show durability
    if (AIB.saved.account.Durability.on and not snoozing) then
      local header, value = "",""
      local isWarning, isCritical = false, false

      -- check slots 0-16
      local lowestDurability = 100
      for i=0,16,1 do
        local thisDurability = 100
        if (DoesItemHaveDurability(BAG_WORN,i)) then
          thisDurability = math.min(lowestDurability,GetItemCondition(BAG_WORN,i))
        end
        if (thisDurability < lowestDurability) then
          lowestDurability = thisDurability
        end
      end

      -- set warnings
      if (lowestDurability <= AIB.saved.account.Durability.warning) then
        if (lowestDurability <= AIB.saved.account.Durability.critical) then
          isCritical = true
        else
          isWarning = true
        end
      end

      -- set header
      header = AIB.setHeader("Durability",isWarning,isCritical)

      -- set value
      value = AIB.setValue(lowestDurability .. "% (" .. GetRepairAllCost() .. AIB.icons.gold .. ")",isWarning,isCritical)

      -- set label
      if ((not AIB.saved.account.Durability.alwaysOn and (isWarning or isCritical))
        or (AIB.saved.account.Durability.alwaysOn)) then
        AIB.setLabel("Durability", header..value)
      end

    end
  end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Durability.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Durability..AIB.colors.blue.."Durability|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display a warning when your armor durability falls below the warning and critical values.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.Durability.on end,
        setFunc = function(newValue) AIB.saved.account.Durability.on = newValue; AIB.plugins.Durability.UpdateDurability() end,
        default = AIB.defaults.Durability.on,
      },
      {
        type = "checkbox",
        name = "Only show when durability is low",
        tooltip = "If checked, durability will only display if the warning or critical threshold has been reached. If not checked, durability will always be displayed.",
        getFunc = function() return not AIB.saved.account.Durability.alwaysOn end,
        setFunc = function(newValue) AIB.saved.account.Durability.alwaysOn = not newValue; AIB.plugins.Durability.UpdateDurability(); end,
        disabled = function() return not(AIB.saved.account.Durability.on) end,
        default = not AIB.defaults.Durability.alwaysOn,
      },
      {
        type = "slider",
        name = "Low Durability "..AIB.colors.yellow.."warning|r (percent)",
        tooltip = "If durability of one of your equipped items is this many or less, you will see a warning.",
        min  = 1,
        max = 60,
        getFunc = function() return AIB.saved.account.Durability.warning end,
        setFunc = function(newValue) AIB.saved.account.Durability.warning = newValue; AIB.plugins.Durability.UpdateDurability() end,
        disabled = function() return not(AIB.saved.account.Durability.on) end,
        default = AIB.defaults.Durability.warning,
      },
      {
        type = "slider",
        name = "Low Durability "..AIB.colors.red.."critical warning|r (percent)",
        tooltip = "If durability of one of your equipped items is this many or less, you will see a critical warning.",
        min  = 1,
        max = 40,
        getFunc = function() return AIB.saved.account.Durability.critical end,
        setFunc = function(newValue) AIB.saved.account.Durability.critical = newValue; AIB.plugins.Durability.UpdateDurability() end,
        disabled = function() return not(AIB.saved.account.Durability.on) end,
        default = AIB.defaults.Durability.critical,
      }
    }
  }
}
