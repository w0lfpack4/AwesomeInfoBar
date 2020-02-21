
--------------------------------------------------
-- ICONS
--------------------------------------------------
AIB.icons["BankSpace"]         = "|t24:24:esoui/art/icons/mapkey/mapkey_bank.dds|t"
AIB.icons["BankSpaceCritical"] = "|t22:22:esoui/art/icons/mapkey/mapkey_bank.dds|t"
AIB.icons["BankSpaceWarning"]  = "|t22:22:esoui/art/icons/mapkey/mapkey_bank.dds|t"


--------------------------------------------------
-- DEFAULT VARS
--------------------------------------------------
AIB.defaults["BankSpace"] = {
  on           = true,
  alwaysOn     = true,
  displayType  = "CUR / MAX",
  warning      = 10,
  critical     = 5,
}

--------------------------------------------------
-- DEFINE PLUGIN
--------------------------------------------------
AIB.plugins["BankSpace"] = {
  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.plugins.BankSpace.UpdateBankSpace()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.account.BankSpace.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_BankSpace", EVENT_CLOSE_BANK, AIB.plugins.BankSpace.OnBankClose)
      EVENT_MANAGER:RegisterForEvent("AIB_BankSpace", EVENT_INVENTORY_BANK_CAPACITY_CHANGED, AIB.plugins.BankSpace.OnBankCapacityChanged)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_BankSpace", EVENT_CLOSE_BANK)
      EVENT_MANAGER:UnregisterForEvent("AIB_BankSpace", EVENT_INVENTORY_BANK_CAPACITY_CHANGED)
    end
  end,

  ------------------------------------------------
  -- EVENT: OnBankClose (number eventCode)
  ------------------------------------------------
  OnBankClose = function(eventCode)
    AIB.plugins.BankSpace.UpdateBankSpace()
  end,

  ------------------------------------------------
  -- EVENT: OnBankCapacityChanged (number eventCode, number previousCapacity, number currentCapacity, number previousUpgrade, number currentUpgrade)
  ------------------------------------------------
  OnBankCapacityChanged = function(eventCode, previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
    AIB.plugins.BankSpace.UpdateBankSpace()
  end,

  ------------------------------------------------
  -- METHOD: UpdateBankSpace
  ------------------------------------------------
  UpdateBankSpace = function()
    local snoozing = AIB.isSnoozing("BankSpace")
    AIB.setLabel("BankSpace", "")

    -- if show bank space
    if (AIB.saved.account.BankSpace.on and not snoozing) then
      local header, value = "", ""
      local isWarning, isCritical = false, false
      local max, free, cur = 0, 0, 0

      -- get the data
      max  = GetBagSize(BAG_BANK)
      cur  = GetNumBagUsedSlots(BAG_BANK)
      free = max - cur

      if IsESOPlusSubscriber() then
        max  = max + GetBagSize(BAG_SUBSCRIBER_BANK)
        cur  = cur + GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK)
        free = max - cur
      end

      -- set warnings
      if (free < AIB.saved.account.BankSpace.warning) then
        if (free <= AIB.saved.account.BankSpace.critical) then
          isCritical = true
        else
          isWarning = true
        end
      end

      -- set header
      header = AIB.setHeader("BankSpace", isWarning, isCritical)

      -- set value
      local displayType = AIB.saved.account.BankSpace.displayType
      AIB.Debug("DisplayType: "..displayType)
      if (displayType == "CUR") then
        value = cur
      elseif (displayType == "CUR / MAX") then
        value = cur .. " / " .. max
      elseif (displayType == "CUR / MAX (FREE)") then
        value = cur .. " / " .. max .. " (" .. free .. ")"
      elseif (displayType == "FREE") then
        value = free
      end
      value = AIB.setValue(value, isWarning, isCritical)

      -- set label
      if ((not AIB.saved.account.BankSpace.alwaysOn and (isWarning or isCritical)) or (AIB.saved.account.BankSpace.alwaysOn)) then
        AIB.setLabel("BankSpace", header..value)
      end
    end
  end,
}

--------------------------------------------------
-- SETTINGS MENU
--------------------------------------------------
AIB.plugins.BankSpace.Menu = {
  {
    type = "submenu",
    name = AIB.icons.BankSpace..AIB.colors.blue.."Bank Space|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display the amount of bank space.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.BankSpace.on end,
        setFunc = function(newValue) AIB.saved.account.BankSpace.on = newValue; AIB.plugins.BankSpace.RegisterEvents(); AIB.plugins.BankSpace.UpdateBankSpace() end,
        default = AIB.defaults.BankSpace.on,
      },
      {
        type = "checkbox",
        name = "Only show when bank space are low",
        tooltip = "If checked, bank space will only display if the warning or critical threshold has been reached. If not checked, bank space will always be displayed.",
        getFunc = function() return not AIB.saved.account.BankSpace.alwaysOn end,
        setFunc = function(newValue) AIB.saved.account.BankSpace.alwaysOn = not newValue; AIB.plugins.BankSpace.UpdateBankSpace(); end,
        disabled = function() return not(AIB.saved.account.BankSpace.on) end,
        default = not AIB.defaults.BankSpace.alwaysOn,
      },
      {
        type = "dropdown",
        name = "Display",
        tooltip = "How do you want this information displayed",
        choices = {"CUR / MAX","CUR","CUR / MAX (FREE)","FREE"},
        getFunc = function() return AIB.saved.account.BankSpace.displayType end,
        setFunc = function(newValue) AIB.saved.account.BankSpace.displayType = newValue; AIB.plugins.BankSpace.UpdateBankSpace() end,
        disabled = function() return not(AIB.saved.account.BankSpace.on) end,
        default = AIB.defaults.BankSpace.displayType,
      },
      {
        type = "slider",
        name = "Low Bank Space "..AIB.colors.yellow.."warning|r",
        tooltip = "If remaining bank space is this many or less, you will see a warning",
        min  = 1,
        max = 250,
        getFunc = function() return AIB.saved.account.BankSpace.warning end,
        setFunc = function(newValue) AIB.saved.account.BankSpace.warning = newValue; AIB.plugins.BankSpace.UpdateBankSpace() end,
        disabled = function() return not(AIB.saved.account.BankSpace.on) end,
        default = AIB.defaults.BankSpace.warning,
      },
      {
        type = "slider",
        name = "Low Bank Space "..AIB.colors.red.."critical warning|r",
        tooltip = "If remaining bank space is this many or less, you will see a critical warning.",
        min  = 1,
        max = 250,
        getFunc = function() return AIB.saved.account.BankSpace.critical end,
        setFunc = function(newValue) AIB.saved.account.BankSpace.critical = newValue; AIB.plugins.BankSpace.UpdateBankSpace() end,
        disabled = function() return not(AIB.saved.account.BankSpace.on) end,
        default = AIB.defaults.BankSpace.critical,
      }
    }
  }
}
