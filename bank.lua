
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Bank"]         = "|t22:22:"..AIB.name.."/Textures/bank.dds|t"
AIB.icons["BankCritical"] = "|t22:22:"..AIB.name.."/Textures/bank_critical.dds|t"
AIB.icons["BankWarning"]  = "|t22:22:"..AIB.name.."/Textures/bank_warning.dds|t"
AIB.icons["gold"]         = " |t14:14:EsoUI/Art/currency/currency_gold.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Bank"] = {
  on        = true,
  alwaysOn  = false,
  warning   = 5000,       -- amount
  critical  = 1000,       -- amount
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Bank"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.plugins.Bank.UpdateBank()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.account.Bank.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Bank", EVENT_MONEY_UPDATE, AIB.plugins.Bank.OnMoneyUpdate)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Bank", EVENT_MONEY_UPDATE)
    end
  end,

  ------------------------------------------------
  -- EVENT: OnMoneyUpdate
  ------------------------------------------------
  OnMoneyUpdate = function(currencyInput, currencyAmount, eventType)
    AIB.plugins.Bank.UpdateBank()
  end,

  ------------------------------------------------
  -- METHOD: UpdateBank
  ------------------------------------------------
  UpdateBank = function()
    local snoozing = AIB.isSnoozing("Bank")
    AIB.setLabel("Bank","")

    -- if show bank
    if (AIB.saved.account.Bank.on and not snoozing) then
      local header, value = "",""
      local isWarning, isCritical = false, false

      -- get data
      local money = tonumber(GetBankedMoney())

      -- set warnings
      if (money < AIB.saved.account.Bank.warning) then
        if (money <= AIB.saved.account.Bank.critical) then
          isCritical = true
        else
          isWarning = true
        end
      end

      -- set header
      header = AIB.setHeader("Bank",isWarning,isCritical)

      -- set value
      if (AIB.saved.account.system.useIcons) then
        value = AIB.setValue(money,isWarning,isCritical)
      else
        value = AIB.setValue(money..AIB.icons.gold,isWarning,isCritical)
      end

      -- set label
      if ((not AIB.saved.account.Bank.alwaysOn and (isWarning or isCritical))
        or (AIB.saved.account.Bank.alwaysOn)) then
        AIB.setLabel("Bank", header..value)
      end
    end
  end,

}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Bank.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Bank..AIB.colors.blue.."Bank|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display the amount of gold in your bank.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.Bank.on end,
        setFunc = function(newValue) AIB.saved.account.Bank.on = newValue; AIB.plugins.Bank.RegisterEvents(); AIB.plugins.Bank.UpdateBank() end,
        default = AIB.defaults.Bank.on,
      },
      {
        type = "checkbox",
        name = "Only show when bank gold is low",
        tooltip = "If checked, bank gold will only display if the warning or critical threshold has been reached. If not checked, bank gold will always be displayed.",
        getFunc = function() return not AIB.saved.account.Bank.alwaysOn end,
        setFunc = function(newValue) AIB.saved.account.Bank.alwaysOn = not newValue; AIB.plugins.Bank.UpdateBank(); end,
        disabled = function() return not(AIB.saved.account.Bank.on) end,
        default = not AIB.defaults.Bank.alwaysOn,
      },
      {
        type = "slider",
        name = "Low Bank Gold "..AIB.colors.yellow.."warning|r",
        tooltip = "If remaining bank gold is this many or less, you will see a warning",
        min  = 5000,
        max = 10000,
        step = 500,
        getFunc = function() return AIB.saved.account.Bank.warning end,
        setFunc = function(newValue) AIB.saved.account.Bank.warning = newValue; AIB.plugins.Bank.UpdateBank() end,
        disabled = function() return not(AIB.saved.account.Bank.on) end,
        default = AIB.defaults.Bank.warning,
      },
      {
        type = "slider",
        name = "Low Bank Gold "..AIB.colors.red.."critical warning|r",
        tooltip = "If remaining bank gold is this many or less, you will see a critical warning.",
        min  = 500,
        max = 5000,
        step = 500,
        getFunc = function() return AIB.saved.account.Bank.critical end,
        setFunc = function(newValue) AIB.saved.account.Bank.critical = newValue; AIB.plugins.Bank.UpdateBank() end,
        disabled = function() return not(AIB.saved.account.Bank.on) end,
        default = AIB.defaults.Bank.critical,
      }
    }
  }
}
