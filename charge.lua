
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Charge"]         =  "|t26:26:"..AIB.name.."/Textures/charge.dds|t"
AIB.icons["ChargeCritical"] =  "|t26:26:"..AIB.name.."/Textures/charge_critical.dds|t"
AIB.icons["ChargeWarning"]  =  "|t26:26:"..AIB.name.."/Textures/charge_warning.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Charge"] = {
  on        = true,
  warning   = 15,       -- percentage
  critical  = 5,       -- percentage
}

----------------------------------------------------
-- LOCAL VARS
----------------------------------------------------
AIB.vars["Charge"] = {
  lastUpdate  = 0,
  frequency   = 10
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Charge"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.plugins.Charge.UpdateCharge()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.account.Charge.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Charge", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, AIB.plugins.Charge.OnInventorySingleSlotUpdate)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Charge", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    end
  end,

  ------------------------------------------------
  -- PARENT METHOD: Update (every 1 sec)
  ------------------------------------------------
  Update = function()
    if (AIB.saved.account.Charge.on) then
      -- less frequent update (10 sec default)
      AIB.vars.Charge.lastUpdate = AIB.vars.Charge.lastUpdate + 1
      if (AIB.vars.Charge.lastUpdate > AIB.vars.Charge.frequency) then
        AIB.vars.Charge.lastUpdate = 0
        AIB.plugins.Charge.UpdateCharge()
      end
    end
  end,

  ------------------------------------------------
  -- EVENT: OnInventorySingleSlotUpdate
  ------------------------------------------------
  OnInventorySingleSlotUpdate = function(eventCode)
    AIB.plugins.Charge.UpdateCharge()
  end,

  ------------------------------------------------
  -- METHOD: UpdateCharge
  ------------------------------------------------
  UpdateCharge = function()
    local snoozing = AIB.isSnoozing("Charge")
    AIB.setLabel("Charge","")

    -- if show weapon durability
    if (AIB.saved.account.Charge.on and not snoozing) then
      local header, value = "",""
      local isWarning, isCritical = false, false

      -- get data
      local lowWeaponIndex = 0
      local lowWeaponValue = 100
      local curCharge,i,vlocal
      local weaponName = ""

      -- Item IDs are 4 & 5 for main weapon set, 20 & 21 for alternate set.
      local weaponChargeTable = { 4, 5, 20, 21 }

      -- iterate the weapons
      for i,v in ipairs(weaponChargeTable) do
        -- calculate the charge
        curCharge = AIB.plugins.Charge.CalcPercentageWeaponCharge(v)
        if (curCharge < lowWeaponValue) then
          lowWeaponValue = curCharge
          lowWeaponIndex = v
        end
      end

      -- set warnings
      if (lowWeaponValue <= AIB.saved.account.Charge.warning) then
        if (lowWeaponValue <= AIB.saved.account.Charge.critical) then
          isCritical = true
        else
          isWarning = true
        end
      end

      -- set header
      header = AIB.setHeader("Charge",isWarning,isCritical)

      -- format the unfortunate weapon
      local name = GetItemName(BAG_WORN, lowWeaponIndex).." "
      local quality = AIB.quality[select(8, GetItemInfo(0, lowWeaponIndex))]
      if (quality ~= nil) then
        value = zo_strformat(SI_TOOLTIP_ITEM_NAME, quality..name).." ("..lowWeaponValue.."%)"
      else
        value = AI.colors.red.."Missing Weapon!"
      end

      -- set value
      if (isWarning or isCritical) then
        AIB.setLabel("Charge", header..value)
      end

    end
  end,

  ------------------------------------------------
  -- METHOD: CalcPercentageWeaponCharge
  ------------------------------------------------
  CalcPercentageWeaponCharge = function(slotID)
    local isChargeable = IsItemChargeable(BAG_WORN, slotID)
    if (isChargeable) then
      local charges, maxCharges = GetChargeInfoForItem(BAG_WORN, slotID)
      return math.floor(100 * charges / maxCharges)       -- express as a percentage
    else
      return 100
    end
  end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Charge.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Charge..AIB.colors.blue.."Low Weapon Charge Warnings|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display a warning when the charge on your weapon enchantment falls below the warning and critical values.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.Charge.on end,
        setFunc = function(newValue) AIB.saved.account.Charge.on = newValue; AIB.plugins.Charge.RegisterEvents(); AIB.plugins.Charge.UpdateCharge() end,
        default = AIB.defaults.Charge.on,
      },
      {
        type = "slider",
        name = "Low Weapon Charge "..AIB.colors.yellow.."warning|r %",
        tooltip = "If the charge on your weapon enchantment is this many or less, you will see a warning.",
        min  = 1,
        max = 60,
        getFunc = function() return AIB.saved.account.Charge.warning end,
        setFunc = function(newValue) AIB.saved.account.Charge.warning = newValue; AIB.plugins.Charge.UpdateCharge() end,
        disabled = function() return not(AIB.saved.account.Charge.on) end,
        default = AIB.defaults.Charge.warning,
      },
      {
        type = "slider",
        name = "Low Weapon Charge "..AIB.colors.red.."critical warning|r %",
        tooltip = "If the charge on your weapon enchantment is this many or less, you will see a critical warning.",
        min  = 1,
        max = 40,
        getFunc = function() return AIB.saved.account.Charge.critical end,
        setFunc = function(newValue) AIB.saved.account.Charge.critical = newValue; AIB.plugins.Charge.UpdateCharge() end,
        disabled = function() return not(AIB.saved.account.Charge.on) end,
        default = AIB.defaults.Charge.critical,
      }
    }
  }
}
