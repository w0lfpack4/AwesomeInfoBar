
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Shards"]          =  "|t24:24:"..AIB.name.."/Textures/shards.dds|t"
AIB.icons["ShardsCritical"] =  "|t24:24:"..AIB.name.."/Textures/shards_critical.dds|t"
AIB.icons["ShardsWarning"]  =  "|t24:24:"..AIB.name.."/Textures/shards_warning.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Shards"] = {
  on        = true,
  alwaysOn  = false,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Shards"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.plugins.Shards.UpdateShards()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.account.Shards.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Shards", EVENT_SKILL_POINTS_CHANGED, AIB.plugins.Shards.OnSkillPointsChanged)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Shards", EVENT_SKILL_POINTS_CHANGED)
    end
  end,

  ------------------------------------------------
  -- EVENT: OnSkillPointsChanged
  ------------------------------------------------
  OnSkillPointsChanged = function(oldPoints, newPoints, oldPartialPoints, newPartialPoints, changeReason)
    AIB.plugins.Shards.UpdateShards()
  end,

  ------------------------------------------------
  -- METHOD: UpdateShards
  ------------------------------------------------
  UpdateShards = function()
    local snoozing = AIB.isSnoozing("Shards")
    AIB.setLabel("Shards","")

    -- if show shards
    if (AIB.saved.account.Shards.on and not snoozing) then
      local header, value = "",""
      local isWarning, isCritical = false, false

      -- get data
      local shards = GetNumSkyShards()

      -- set header
      header = AIB.setHeader("Shards",isWarning,isCritical)

      -- set warnings and value
      if (shards == 2) then
        isCritical = true
      elseif (shards == 1) then
        isWarning = true
      end

      -- set value
      value = AIB.setValue(shards.."/3",isWarning,isCritical)

      -- set label
      if ((not AIB.saved.account.Shards.alwaysOn and (isWarning or isCritical))
        or (AIB.saved.account.Shards.alwaysOn)) then
        AIB.setLabel("Shards", header..value)
      end
    end
  end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Shards.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Shards..AIB.colors.blue.."Sky Shards|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display a warning when you are missing 2 or more shards.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.Shards.on end,
        setFunc = function(newValue) AIB.saved.account.Shards.on = newValue; AIB.plugins.Shards.RegisterEvents(); AIB.plugins.Shards.UpdateShards() end,
        default = AIB.defaults.Shards.on,
      },
      {
        type = "checkbox",
        name = "Only show if shards are missing",
        tooltip = "If checked, shards will only display if 1 or 2 are missing. If not checked, shards will always be displayed.",
        getFunc = function() return not AIB.saved.account.Shards.alwaysOn end,
        setFunc = function(newValue) AIB.saved.account.Shards.alwaysOn = not newValue; AIB.plugins.Shards.UpdateShards() end,
        disabled = function() return not(AIB.saved.account.Shards.on) end,
        default = not AIB.defaults.Shards.alwaysOn,
      }
    }
  }
}
