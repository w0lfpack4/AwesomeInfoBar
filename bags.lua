
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Bags"]         = "|t24:24:"..AIB.name.."/Textures/bags.dds|t"
AIB.icons["BagsCritical"] = "|t24:24:"..AIB.name.."/Textures/bags_critical.dds|t"
AIB.icons["BagsWarning"]  = "|t24:24:"..AIB.name.."/Textures/bags_warning.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Bags"] = {
  on          = true,
  alwaysOn    = false,
  displayType = "CUR / MAX",
  warning     = 10,
  critical    = 5,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Bags"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.Debug("Bags.Initialize")
    AIB.plugins.Bags.UpdateBags()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.account.Bags.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Bags", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, AIB.plugins.Bags.OnInventorySingleSlotUpdate)
      EVENT_MANAGER:RegisterForEvent("AIB_Bags", EVENT_LOOT_RECEIVED, AIB.plugins.Bags.OnLootReceived)
      EVENT_MANAGER:RegisterForEvent("AIB_Bags", EVENT_MONEY_UPDATE, AIB.plugins.Bags.OnMoneyUpdate)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Bags", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
      EVENT_MANAGER:UnregisterForEvent("AIB_Bags", EVENT_LOOT_RECEIVED)
      EVENT_MANAGER:UnregisterForEvent("AIB_Bags", EVENT_MONEY_UPDATE)
    end
  end,

  ------------------------------------------------
  -- EVENT: OnInventorySingleSlotUpdate
  ------------------------------------------------
  OnInventorySingleSlotUpdate = function(eventCode)
    AIB.plugins.Bags.UpdateBags()
  end,

  ------------------------------------------------
  -- EVENT: OnLootReceived
  ------------------------------------------------
  OnLootReceived = function(receivedBy, itemName, quantity, itemSound, lootType, receivedBySelf, isPickpocketLoot)
    AIB.plugins.Bags.UpdateBags()
  end,

  ------------------------------------------------
  -- EVENT: OnMoneyUpdate
  ------------------------------------------------
  OnMoneyUpdate = function(currencyInput, currencyAmount, eventType)
    AIB.plugins.Bags.UpdateBags()
  end,

  ------------------------------------------------
  -- METHOD: UpdateBags
  ------------------------------------------------
  UpdateBags = function()
    local snoozing = AIB.isSnoozing("Bags")
    AIB.setLabel("Bags","")

    -- if show bags
    if (AIB.saved.account.Bags.on and not snoozing) then
      local header, value = "",""
      local isWarning, isCritical = false, false

      -- get data
      local curInv,maxInv =PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
      local freeInv = maxInv - curInv

      -- set warnings
      if (freeInv <= AIB.saved.account.Bags.warning) then
        if (freeInv <= AIB.saved.account.Bags.critical) then
          isCritical = true
        else
          isWarning = true
        end
      end

      -- set header
      header = AIB.setHeader("Bags",isWarning,isCritical)

      -- set value
      local displayType = AIB.saved.account.Bags.displayType
      if (displayType == "CUR / MAX") then
        value = curInv .. " / " .. maxInv
      elseif (displayType == "CUR") then
        value = curInv
      elseif (displayType == "CUR / MAX (FREE)") then
        value = curInv .. " / " .. maxInv .. " (" .. freeInv .. ")"
      elseif (displayType == "FREE") then
        value = free
      end
      value = AIB.setValue(value,isWarning,isCritical)

      -- set label
      if ((not AIB.saved.account.Bags.alwaysOn and (isWarning or isCritical))
        or (AIB.saved.account.Bags.alwaysOn)) then
        AIB.setLabel("Bags", header..value)
      end

    end
  end, -- AIB.UpdateBags
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Bags.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Bags..AIB.colors.blue.."Bag Space|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Displays free bag space|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.Bags.on end,
        setFunc = function(newValue) AIB.saved.account.Bags.on = newValue; AIB.plugins.Bags.RegisterEvents(); AIB.plugins.Bags.UpdateBags() end,
        default = AIB.defaults.Bags.on,
      },
      {
        type = "dropdown",
        name = "Display",
        tooltip = "How do you want this information displayed",
        choices = {"CUR / MAX","CUR","CUR / MAX (FREE)","FREE"},
        getFunc = function() return AIB.saved.account.Bags.displayType end,
        setFunc = function(newValue) AIB.saved.account.Bags.displayType = newValue; AIB.plugins.Bags.UpdateBags() end,
        disabled = function() return not(AIB.saved.account.Bags.on) end,
        default = AIB.defaults.Bags.displayType,
      },
      {
        type = "checkbox",
        name = "Only show when bag space is low",
        tooltip = "If checked, bag space will only display if the warning or critical threshold has been reached. If not checked, bag space will always be displayed.",
        getFunc = function() return not AIB.saved.account.Bags.alwaysOn end,
        setFunc = function(newValue) AIB.saved.account.Bags.alwaysOn = not newValue; AIB.plugins.Bags.UpdateBags() end,
        disabled = function() return not(AIB.saved.account.Bags.on) end,
        default = not AIB.defaults.Bags.alwaysOn,
      },
      {
        type = "slider",
        name = "Low Bag space "..AIB.colors.yellow.."warning|r (slots)",
        tooltip = "If remaining bag space is this many or less, you will see a warning",
        min  = 1,
        max = 20,
        getFunc = function() return AIB.saved.account.Bags.warning end,
        setFunc = function(newValue) AIB.saved.account.Bags.warning = newValue; AIB.plugins.Bags.UpdateBags() end,
        disabled = function() return not(AIB.saved.account.Bags.on) end,
        default = AIB.defaults.Bags.warning,
      },
      {
        type = "slider",
        name = "Low Bag space "..AIB.colors.red.."critical warning|r (slots)",
        tooltip = "If remaining bag space is this many or less, you will see a critical warning.",
        min  = 1,
        max = 10,
        getFunc = function() return AIB.saved.account.Bags.critical end,
        setFunc = function(newValue) AIB.saved.account.Bags.critical = newValue; AIB.plugins.Bags.UpdateBags() end,
        disabled = function() return not(AIB.saved.account.Bags.on) end,
        default = AIB.defaults.Bags.critical,
      }
    }
  }
}
