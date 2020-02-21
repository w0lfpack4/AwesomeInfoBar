
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Skills"] = "|t28:28:"..AIB.name.."/Textures/skills.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Skills"] = {
  on        = true,
  alwaysOn  = false,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Skills"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.plugins.Skills.UpdateSkills()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.account.Skills.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Skills", EVENT_SKILL_POINTS_CHANGED, AIB.plugins.Skills.OnSkillPointsChanged)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Skills", EVENT_SKILL_POINTS_CHANGED)
    end
  end,

  ------------------------------------------------
  -- EVENT: OnSkillPointsChanged
  ------------------------------------------------
  OnSkillPointsChanged = function(oldPoints, newPoints, oldPartialPoints, newPartialPoints, changeReason)
    AIB.plugins.Skills.UpdateSkills()
  end,

  ------------------------------------------------
  -- METHOD: UpdateSkills
  ------------------------------------------------
  UpdateSkills = function()
    local snoozing = AIB.isSnoozing("Skills")
    AIB.setLabel("Skills","")

    -- if skills on, update
    if (AIB.saved.account.Skills.on and not snoozing) then
      local header, value = "",""

      -- get data
      local points = GetAvailableSkillPoints()

      -- set header
      header = AIB.setHeader("Skills", false, false)

      -- set value
      value = AIB.setValue(points, false, false)

      -- set label
      if ((not AIB.saved.account.Skills.alwaysOn and (points > 0))
        or (AIB.saved.account.Skills.alwaysOn)) then
        AIB.setLabel("Skills", header..value)
      end
    end
  end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Skills.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Skills..AIB.colors.blue.."Skill Points|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display undistributed skill points.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.Skills.on end,
        setFunc = function(newValue) AIB.saved.account.Skills.on = newValue; AIB.plugins.Skills.RegisterEvents(); AIB.plugins.Skills.UpdateSkills() end,
        default = AIB.defaults.Skills.on,
      },
      {
        type = "checkbox",
        name = "Only show undistributed skill points",
        tooltip = "If checked, skill points will only display if there are undistributed skill points. If not checked, skill points will always be displayed.",
        getFunc = function() return not AIB.saved.account.Skills.alwaysOn end,
        setFunc = function(newValue) AIB.saved.account.Skills.alwaysOn = not newValue; AIB.plugins.Skills.UpdateSkills() end,
        disabled = function() return not(AIB.saved.account.Skills.on) end,
        default = not AIB.defaults.Skills.alwaysOn,
      }
    }
  }
}
