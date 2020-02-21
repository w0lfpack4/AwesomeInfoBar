
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Gems"]         = "|t24:24:"..AIB.name.."/Textures/gem_filled.dds|t"
AIB.icons["GemsCritical"] = "|t24:24:"..AIB.name.."/Textures/gem_filled_critical.dds|t"
AIB.icons["GemsWarning"]  = "|t24:24:"..AIB.name.."/Textures/gem_filled_warning.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Gems"] = {
  on             = true,
  showEmptyGems  = true,
  showEmptyCount = false,
  alwaysOn       = true,
  warning        = 10,       -- amount
  critical       = 5,        -- amount
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Gems"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.plugins.Gems.UpdateGems()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.account.Gems.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Gems", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, AIB.plugins.Gems.OnInventorySingleSlotUpdate)
      EVENT_MANAGER:RegisterForEvent("AIB_Gems", EVENT_LOOT_RECEIVED, AIB.plugins.Gems.OnLootReceived)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Gems", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
      EVENT_MANAGER:UnregisterForEvent("AIB_Gems", EVENT_LOOT_RECEIVED)
    end
  end,

  ------------------------------------------------
  -- EVENT: OnInventorySingleSlotUpdate
  ------------------------------------------------
  OnInventorySingleSlotUpdate = function(eventCode)
    AIB.plugins.Gems.UpdateGems()
  end,

  ------------------------------------------------
  -- EVENT: OnLootReceived
  ------------------------------------------------
  OnLootReceived = function(receivedBy, itemName, quantity, itemSound, lootType, receivedBySelf, isPickpocketLoot)
    AIB.plugins.Gems.UpdateGems()
  end,

  ------------------------------------------------
  -- METHOD: UpdateGems
  ------------------------------------------------
  UpdateGems = function()
    local snoozing = AIB.isSnoozing("Gems")
    AIB.setLabel("Gems","")

    -- if show gems
    if (AIB.saved.account.Gems.on and not snoozing) then
      local header, value = "",""
      local isWarning, isCritical = false, false

      -- get filled gem count
      local fname, ficon, fcount, fquality = GetSoulGemInfo(SOUL_GEM_TYPE_FILLED, GetUnitEffectiveLevel("player"), true)
      if (fcount==nil) then fcount=0 end
      -- get empty gem count
      local ename, eicon, ecount, equality = GetSoulGemInfo(SOUL_GEM_TYPE_EMPTY, GetUnitEffectiveLevel("player"), true)
      if (ecount==nil) then ecount=0 end

      -- set warnings
      if (fcount <= AIB.saved.account.Gems.warning) then
        if (fcount <= AIB.saved.account.Gems.critical) then
          isCritical  = true
        else
          isWarning   = true
        end
      end

      -- set header
      header = AIB.setHeader("Gems",isWarning,isCritical)

      -- set value
      if (AIB.saved.account.Gems.showEmptyGems and ecount > 0) then
        if (AIB.saved.account.Gems.showEmptyCount) then
          value = AIB.setValue(fcount.." ("..ecount..")",isWarning,isCritical)
        else
          value = AIB.setValue(fcount.." / "..(fcount+ecount),isWarning,isCritical)
        end
      else
        value = AIB.setValue(fcount,isWarning,isCritical)
      end

      -- set label
      if ((not AIB.saved.account.Gems.alwaysOn and (isWarning or isCritical))
        or (AIB.saved.account.Gems.alwaysOn)) then
        AIB.setLabel("Gems", header..value)
      end
    end
  end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Gems.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Gems..AIB.colors.blue.."Soul Gems|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display soul gems in your inventory.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.Gems.on end,
        setFunc = function(newValue) AIB.saved.account.Gems.on = newValue; AIB.plugins.Gems.RegisterEvents(); AIB.plugins.Gems.UpdateGems() end,
        default = AIB.defaults.Gems.on,
      },
      {
        type = "checkbox",
        name = "Include empty soul gems",
        tooltip = "Displays both filled and empty soul gems",
        getFunc = function() return AIB.saved.account.Gems.showEmptyGems end,
        setFunc = function(newValue) AIB.saved.account.Gems.showEmptyGems = newValue; AIB.plugins.Gems.UpdateGems() end,
        disabled = function() return not(AIB.saved.account.Gems.on) end,
        default = AIB.defaults.Gems.showEmptyGems,
      },
      {
        type = "checkbox",
        name = "Show empty gem count",
        tooltip = "When including empty gems, only show empty count, not total count",
        getFunc = function() return AIB.saved.account.Gems.showEmptyCount end,
        setFunc = function(newValue) AIB.saved.account.Gems.showEmptyCount = newValue; AIB.plugins.Gems.UpdateGems() end,
        disabled = function() return not(AIB.saved.account.Gems.on) end,
        default = AIB.defaults.Gems.showEmptyCount,
      },
      {
        type = "checkbox",
        name = "Only show when soul gems are low",
        tooltip = "If checked, soul gems will only display if the warning or critical threshold has been reached. If not checked, soul gems will always be displayed.",
        getFunc = function() return not AIB.saved.account.Gems.alwaysOn end,
        setFunc = function(newValue) AIB.saved.account.Gems.alwaysOn = not newValue; AIB.plugins.Gems.UpdateGems() end,
        disabled = function() return not(AIB.saved.account.Gems.on) end,
        default = not AIB.defaults.Gems.alwaysOn,
      },
      {
        type = "slider",
        name = "Low Soul Gems "..AIB.colors.yellow.."warning|r",
        tooltip = "If remaining number of soul gems is this many or less, you will see a warning",
        min  = 1,
        max = 200,
        getFunc = function() return AIB.saved.account.Gems.warning end,
        setFunc = function(newValue) AIB.saved.account.Gems.warning = newValue; AIB.plugins.Gems.UpdateGems() end,
        disabled = function() return AIB.saved.account.Gems.alwaysOn end,
        default = AIB.defaults.Gems.warning,
      },
      {
        type = "slider",
        name = "Low Soul Gems "..AIB.colors.red.."critical warning|r",
        tooltip = "If remaining number of soul gems is this many or less, you will see a critical warning.",
        min  = 1,
        max = 200,
        getFunc = function() return AIB.saved.account.Gems.critical end,
        setFunc = function(newValue) AIB.saved.account.Gems.critical = newValue; AIB.plugins.Gems.UpdateGems() end,
        disabled = function() return AIB.saved.account.Gems.alwaysOn end,
        default = AIB.defaults.Gems.critical,
      }
    }
  }
}
