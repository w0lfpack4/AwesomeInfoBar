
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Enlightenment"] = "|t38:38:esoui/art/treeicons/achievements_indexicon_champion_up.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Enlightenment"] = {
  on = true,
}

----------------------------------------------------
-- HELPER FUNCTION: comma_value
----------------------------------------------------
function comma_value(amount)
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Enlightenment"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.plugins.Enlightenment.UpdateEnlightenment()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.account.Enlightenment.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Enlightenment", EVENT_ENLIGHTENED_STATE_GAINED, AIB.plugins.Enlightenment.OnEnlightenmentGained)
      EVENT_MANAGER:RegisterForEvent("AIB_Enlightenment", EVENT_ENLIGHTENED_STATE_LOST, AIB.plugins.Enlightenment.OnEnlightenmentLost)
      EVENT_MANAGER:RegisterForEvent("AIB_Enlightenment", EVENT_EXPERIENCE_UPDATE, AIB.plugins.Enlightenment.OnExperienceUpdate)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Enlightenment", EVENT_ENLIGHTENED_STATE_GAINED)
      EVENT_MANAGER:UnregisterForEvent("AIB_Enlightenment", EVENT_ENLIGHTENED_STATE_LOST)
      EVENT_MANAGER:UnregisterForEvent("AIB_Enlightenment", EVENT_EXPERIENCE_UPDATE)
    end
  end,

  ------------------------------------------------
  -- EVENT: OnEnlightenmentGained EVENT_ENLIGHTENED_STATE_GAINED (number eventCode)
  ------------------------------------------------
  OnEnlightenmentGained = function(eventCode)
    AIB.plugins.Enlightenment.UpdateEnlightenment()
  end,

  ------------------------------------------------
  -- EVENT: OnEnlightenmentLost EVENT_ENLIGHTENED_STATE_LOST (number eventCode)
  ------------------------------------------------
  OnEnlightenmentLost = function(eventCode)
    AIB.plugins.Enlightenment.UpdateEnlightenment()
  end,

  ------------------------------------------------
  -- EVENT: OnExperienceUpdate EVENT_EXPERIENCE_UPDATE (number eventCode, string unitTag, number currentExp, number maxExp, ProgressReason reason)
  ------------------------------------------------
  OnExperienceUpdate = function(eventCode, unitTag, currentExp, maxExp, reason)
    AIB.plugins.Enlightenment.UpdateEnlightenment()
  end,

  ------------------------------------------------
  -- METHOD: UpdateEnlightenment
  ------------------------------------------------
  UpdateEnlightenment = function()
    local snoozing = AIB.isSnoozing("Enlightenment")
    AIB.setLabel("Enlightenment","")

    -- if show enlightenment
    if (AIB.saved.account.Enlightenment.on and not snoozing and IsEnlightenedAvailableForCharacter()) then
      local header, value = "",""

      local pool = GetEnlightenedPool()
      local mult = 1 + GetEnlightenedMultiplier() -- the multiplier is zero-indexed
      local boosted = 0

      if pool > 0 then
        boosted = pool * mult
        if boosted > 999 then
          boosted = comma_value(boosted)
        end
      end

      -- set header
      header = AIB.setHeader("Enlightenment", false, false)

      -- set value
      value = AIB.setValue(AIB.colors.cyan..boosted, false, false)

      -- set label
      if (AIB.saved.account.Enlightenment.on and boosted ~= 0) then
        AIB.setLabel("Enlightenment", header..value)
      end
    end
  end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Enlightenment.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Enlightenment..AIB.colors.blue.."Enlightenment|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Displays when you are Enlightened.|r",
      },
      {
        type    = "checkbox",
        name    = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.Enlightenment.on end,
        setFunc = function(newValue) AIB.saved.account.Enlightenment.on = newValue; AIB.plugins.Enlightenment.RegisterEvents(); AIB.plugins.Enlightenment.UpdateEnlightenment() end,
        default = AIB.defaults.Enlightenment.on,
      }
    }
  }
}
