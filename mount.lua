
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Mount"]          =  "|t26:26:"..AIB.name.."/Textures/mount.dds|t"
AIB.icons["MountCritical"]  =  "|t26:26:"..AIB.name.."/Textures/mount_critical.dds|t"
AIB.icons["MountWarning"]   =  "|t26:26:"..AIB.name.."/Textures/mount_warning.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Mount"] = {
  on       = true,
  alwaysOn = false,
  warning  = 15,       -- minutes
  critical = 5,       -- minutes
}

----------------------------------------------------
-- LOCAL VARS
----------------------------------------------------
AIB.vars["Mount"] = {
  lastUpdate  = 0,
  frequency   = 10
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Mount"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.plugins.Mount.UpdateMount()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.account.Mount.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Mount", EVENT_RIDING_SKILL_IMPROVEMENT, AIB.plugins.Mount.onRidingSkillImprovement)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Mount", EVENT_RIDING_SKILL_IMPROVEMENT)
    end
  end,

  ------------------------------------------------
  -- PARENT METHOD: Update (every 1 sec)
  ------------------------------------------------
  Update = function()
    if (AIB.saved.account.Mount.on) then
      -- less frequent update (10 sec default)
      AIB.vars.Mount.lastUpdate = AIB.vars.Mount.lastUpdate + 1
      if (AIB.vars.Mount.lastUpdate > AIB.vars.Mount.frequency) then
        AIB.vars.Mount.lastUpdate = 0
        AIB.plugins.Mount.UpdateMount()
      end
    end
  end,

  ------------------------------------------------
  -- EVENT: onRidingSkillImprovement
  ------------------------------------------------
  onRidingSkillImprovement = function(ridingSkill, previous, current, source)
    AIB.plugins.Mount.UpdateMount()
  end,

  ------------------------------------------------
  -- METHOD: UpdateMount
  ------------------------------------------------
  UpdateMount = function()
    local snoozing = AIB.isSnoozing("Mount")
    AIB.setLabel("Mount","")

    -- if show mount
    if (AIB.saved.account.Mount.on and not snoozing) then
      local header, value = "",""
      local isWarning, isCritical = false, false

      -- get data
      local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
      local ridingSkillMaxedOut = (inventoryBonus == maxInventoryBonus) and (staminaBonus == maxStaminaBonus) and (speedBonus == maxSpeedBonus)
      local mountTimer = GetTimeUntilCanBeTrained()

      -- hide label for characters with no mount, or fully trained mounts.
      if mountTimer == nil or ridingSkillMaxedOut then
        EVENT_MANAGER:UnregisterForEvent("AIB_Mount", EVENT_RIDING_SKILL_IMPROVEMENT)
        return
      end

      if (mountTimer > 0) then
        -- convert to minutes.
        mountTimer = math.floor(mountTimer / 60000)
      end

      -- set warnings
      if (mountTimer <= AIB.saved.account.Mount.warning) then
        if (mountTimer <= AIB.saved.account.Mount.critical) then
          isCritical = true
        else
          isWarning = true
        end
      end

      -- set header
      header = AIB.setHeader("Mount",isWarning,isCritical)

      -- set value
      if (mountTimer > 0) then
        local mountTimerFormatted = FormatTimeSeconds(60 * mountTimer, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT , TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR , TIME_FORMAT_DIRECTION_NONE)
        value = AIB.setValue(mountTimerFormatted,isWarning,isCritical)
      else
        value = AIB.setValue("train!",isWarning,isCritical)
      end

      -- set label
      if ((not AIB.saved.account.Mount.alwaysOn and (isWarning or isCritical))
        or (AIB.saved.account.Mount.alwaysOn)) then
        AIB.setLabel("Mount", header..value)
      end
    end
  end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Mount.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Mount..AIB.colors.blue.."Mount Training Timer|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display a countdown timer for mount training.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.Mount.on end,
        setFunc = function(newValue) AIB.saved.account.Mount.on = newValue; AIB.plugins.Mount.RegisterEvents(); AIB.plugins.Mount.UpdateMount() end,
        default = AIB.defaults.Mount.on,
      },
      {
        type = "checkbox",
        name = "Only show when timer is low",
        tooltip = "If checked, the mount training timer will only display if the warning or critical threshold has been reached. If not checked, the mount training timer will always be displayed.",
        getFunc = function() return not AIB.saved.account.Mount.alwaysOn end,
        setFunc = function(newValue) AIB.saved.account.Mount.alwaysOn = not newValue; AIB.plugins.Mount.UpdateMount(); end,
        disabled = function() return not(AIB.saved.account.Mount.on) end,
        default = not AIB.defaults.Mount.alwaysOn,
      },
      {
        type = "slider",
        name = "Mount training "..AIB.colors.yellow.."warning|r (minutes)",
        tooltip = "If number of minutes remaining is this many or less, you will see a warning.",
        min  = 1,
        max = 30,
        getFunc = function() return AIB.saved.account.Mount.warning end,
        setFunc = function(newValue) AIB.saved.account.Mount.warning = newValue; AIB.plugins.Mount.UpdateMount() end,
        disabled = function() return not(AIB.saved.account.Mount.on) end,
        default = AIB.defaults.Mount.warning,
      },
      {
        type = "slider",
        name = "Mount training "..AIB.colors.red.."critical warning|r (minutes)",
        tooltip = "If number of minutes remaining is this many or less, you will see a critical warning.",
        min  = 1,
        max = 15,
        getFunc = function() return AIB.saved.account.Mount.critical end,
        setFunc = function(newValue) AIB.saved.account.Mount.critical = newValue; AIB.plugins.Mount.UpdateMount() end,
        disabled = function() return not(AIB.saved.account.Mount.on) end,
        default = AIB.defaults.Mount.critical,
      }
    }
  }
}
