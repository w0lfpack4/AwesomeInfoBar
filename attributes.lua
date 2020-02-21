
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Attributes"]  = "|t24:24:"..AIB.name.."/Textures/attributes.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Attributes"] = {
  on         = true,
  alwaysOn   = false,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Attributes"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    -- load global defaults to character if missing
    if (AIB.saved.character.Attributes == nil) then
            AIB.saved.character.Attributes = AIB.defaults.Attributes
    end
    if (IsUnitChampion("player")) then
      AIB.saved.character.Attributes.on = false
    end
    AIB.plugins.Attributes.UpdateAttributes()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.character.Attributes.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Attributes", EVENT_ATTRIBUTE_UPGRADE_UPDATED, AIB.plugins.Attributes.OnAttributeUpgradeUpdated)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Attributes", EVENT_ATTRIBUTE_UPGRADE_UPDATED)
    end
  end,

  ------------------------------------------------
  -- EVENT: OnAttributeUpgradeUpdated
  ------------------------------------------------
  OnAttributeUpgradeUpdated = function()
    AIB.plugins.Attributes.UpdateAttributes()
  end,

  ------------------------------------------------
  -- METHOD: UpdateAttributes
  ------------------------------------------------
  UpdateAttributes = function()
    local snoozing = AIB.isSnoozing("Attributes")
    AIB.setLabel("Attributes","")

    -- if Attributes on, update
    if (AIB.saved.character.Attributes.on and not snoozing) then
      local header, value = "",""

      -- get data
      local points = GetAttributeUnspentPoints()

      -- set header
      header = AIB.setHeader("Attributes", false, false)

      -- set value
      value = AIB.setValue(points, false, false)

      -- set label
      if ((not AIB.saved.character.Attributes.alwaysOn and (points > 0))
        or (AIB.saved.character.Attributes.alwaysOn)) then
        AIB.setLabel("Attributes", header..value)
      end
    end
  end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Attributes.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Attributes..AIB.colors.blue.."Attribute Points|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Displays undistributed attribute points. These settings are per characater.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.character.Attributes.on end,
        setFunc = function(newValue) AIB.saved.character.Attributes.on = newValue; AIB.plugins.Attributes.RegisterEvents(); AIB.plugins.Attributes.UpdateAttributes() end,
        default = AIB.defaults.Attributes.on,
      },
      {
        type = "checkbox",
        name = "Only show undistributed attribute points",
        tooltip = "If checked, attribute points will only display if there are undistributed attribute points. If not checked, attribute points will always be displayed.",
        getFunc = function() return not AIB.saved.character.Attributes.alwaysOn end,
        setFunc = function(newValue) AIB.saved.character.Attributes.alwaysOn = not newValue; AIB.plugins.Attributes.UpdateAttributes() end,
        disabled = function() return not(AIB.saved.character.Attributes.on) end,
        default = not AIB.defaults.Attributes.alwaysOn,
      }
    }
  }
}
