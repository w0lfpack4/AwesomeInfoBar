
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Gold"]         =  "|t22:22:"..AIB.name.."/Textures/gold.dds|t"
AIB.icons["GoldCritical"] =  "|t22:22:"..AIB.name.."/Textures/gold_critical.dds|t"
AIB.icons["GoldWarning"]  =  "|t22:22:"..AIB.name.."/Textures/gold_warning.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Gold"] = {
  on        = true,
  alwaysOn  = true,
  warning   = 750,   -- amount
  critical  = 250,   -- amount
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Gold"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.plugins.Gold.UpdateGold()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.account.Gold.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Gold", EVENT_MONEY_UPDATE, AIB.plugins.Gold.OnMoneyUpdate)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Gold", EVENT_MONEY_UPDATE)
    end
  end,

  ------------------------------------------------
  -- EVENT: OnMoneyUpdate
  ------------------------------------------------
  OnMoneyUpdate = function(currencyInput, currencyAmount, eventType)
    AIB.plugins.Gold.UpdateGold()
  end,

  ------------------------------------------------
  -- METHOD: UpdateGold
  ------------------------------------------------
  UpdateGold = function()
    local snoozing = AIB.isSnoozing("Gold")
    AIB.setLabel("Gold","")

    -- if show gold
    if (AIB.saved.account.Gold.on and not snoozing) then
      local header, value = "",""
      local isWarning, isCritical = false, false

      -- get data
      local money = tonumber(GetCurrentMoney()) or 0

      -- set warnings
      if (money < AIB.saved.account.Gold.warning) then
        if (money <= AIB.saved.account.Gold.critical) then
          isCritical = true
        else
          isWarning = true
        end
      end

      -- set header
      header = AIB.setHeader("Gold",isWarning,isCritical)

      -- set value
      if (AIB.saved.account.system.useIcons) then
        value = AIB.setValue(money,isWarning,isCritical)
      else
        value = AIB.setValue(money..AIB.icons.gold,isWarning,isCritical)
      end

      -- set label
      if ((not AIB.saved.account.Gold.alwaysOn and (isWarning or isCritical))
        or (AIB.saved.account.Gold.alwaysOn)) then
        AIB.setLabel("Gold", header..value)
      end
    end
  end,

}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Gold.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Gold..AIB.colors.blue.."Gold|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display the amount of gold in your inventory|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.Gold.on end,
        setFunc = function(newValue) AIB.saved.account.Gold.on = newValue; AIB.plugins.Gold.RegisterEvents(); AIB.plugins.Gold.UpdateGold() end,
        default = AIB.defaults.Gold.on,
      },
      {
        type = "checkbox",
        name = "Only show when gold is low",
        tooltip = "If checked, gold will only display if the warning or critical threshold has been reached. If not checked, gold will always be displayed.",
        getFunc = function() return not AIB.saved.account.Gold.alwaysOn end,
        setFunc = function(newValue) AIB.saved.account.Gold.alwaysOn = not newValue; AIB.plugins.Gold.UpdateGold() end,
        disabled = function() return not(AIB.saved.account.Gold.on) end,
        default = not AIB.defaults.Gold.alwaysOn,
      },
      {
        type = "slider",
        name = "Low Gold "..AIB.colors.yellow.."warning|r",
        tooltip = "If remaining gold is this many or less, you will see a warning",
        min  = 0,
        max = 5000,
        step = 100,
        getFunc = function() return AIB.saved.account.Gold.warning end,
        setFunc = function(newValue) AIB.saved.account.Gold.warning = newValue; AIB.plugins.Gold.UpdateGold() end,
        disabled = function() return AIB.saved.account.Gold.alwaysOn end,
        default = AIB.defaults.Gold.warning,
      },
      {
        type = "slider",
        name = "Low Gold "..AIB.colors.red.."critical warning|r",
        tooltip = "If remaining gold is this many or less, you will see a critical warning.",
        min  = 0,
        max = 5000,
        step = 100,
        getFunc = function() return AIB.saved.account.Gold.critical end,
        setFunc = function(newValue) AIB.saved.account.Gold.critical = newValue; AIB.plugins.Gold.UpdateGold() end,
        disabled = function() return AIB.saved.account.Gold.alwaysOn end,
        default = AIB.defaults.Gold.critical,
      }
    }
  }
}
