
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Quests"]         = "|t38:38:esoui/art/treeicons/achievements_indexicon_quests_up.dds|t"
AIB.icons["QuestsCritical"] = "|t38:38:esoui/art/treeicons/achievements_indexicon_quests_up.dds|t"
AIB.icons["QuestsWarning"]  = "|t38:38:esoui/art/treeicons/achievements_indexicon_quests_up.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Quests"] = {
  on                  = true,
  showRemainingQuests = true,
  alwaysOn            = true,
  warning             = 10,       -- amount
  critical            = 6,        -- amount
  questLimit          = 25,       -- current limit on quests
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Quests"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.plugins.Quests.UpdateQuests()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.account.Quests.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Quests", EVENT_QUEST_ADDED, AIB.plugins.Quests.OnJournalQuestAdded)
      EVENT_MANAGER:RegisterForEvent("AIB_Quests", EVENT_QUEST_REMOVED, AIB.plugins.Quests.OnJournalQuestRemoved)
      EVENT_MANAGER:RegisterForEvent("AIB_Quests", EVENT_QUEST_COMPLETE, AIB.plugins.Quests.OnJournalQuestComplete)
      EVENT_MANAGER:RegisterForEvent("AIB_Quests", EVENT_PLAYER_ACTIVATED, AIB.plugins.Quests.OnPlayerActivated)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Quests", EVENT_QUEST_ADDED)
      EVENT_MANAGER:UnregisterForEvent("AIB_Quests", EVENT_QUEST_REMOVED)
      EVENT_MANAGER:UnregisterForEvent("AIB_Quests", EVENT_QUEST_COMPLETE)
      EVENT_MANAGER:UnregisterForEvent("AIB_Quests", EVENT_PLAYER_ACTIVATED)
    end
  end,

  ------------------------------------------------
  -- EVENT: OnJournalQuestAdded
  ------------------------------------------------
  OnJournalQuestAdded = function(eventCode, journalIndex, questName, objectiveName)
    AIB.plugins.Quests.UpdateQuests()
  end,

  ------------------------------------------------
  -- EVENT: OnJournalQuestRemoved
  ------------------------------------------------
  OnJournalQuestRemoved = function(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)
    AIB.plugins.Quests.UpdateQuests()
  end,

  ------------------------------------------------
  -- EVENT: OnJournalQuestComplete
  ------------------------------------------------
  OnJournalQuestComplete = function(eventCode, questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType)
    AIB.plugins.Quests.UpdateQuests()
  end,

  ------------------------------------------------
  -- EVENT: OnPlayerActivated
  ------------------------------------------------
  OnPlayerActivated = function(eventCode, initial)
    AIB.plugins.Quests.UpdateQuests()
  end,

  ------------------------------------------------
  -- METHOD: UpdateQuests
  ------------------------------------------------
  UpdateQuests = function()
    local snoozing = AIB.isSnoozing("Quests")
    AIB.setLabel("Quests","")

    -- if show quests
    if (AIB.saved.account.Quests.on and not snoozing) then
      local header, value = "",""
      local isWarning, isCritical = false, false

      -- max number of quests
      local maxQuests = AIB.defaults.Quests.questLimit
      -- current number of quests
      local numQuests = GetNumJournalQuests()
      -- quests remaining
      local remainingQuests = maxQuests - numQuests

      -- set warnings
      if (remainingQuests <= AIB.saved.account.Quests.warning) then
        if (remainingQuests <= AIB.saved.account.Quests.critical) then
          isCritical  = true
        else
          isWarning   = true
        end
      end

      -- set header
      header = AIB.setHeader("Quests",isWarning,isCritical)

      -- set value
      if (AIB.saved.account.Quests.showRemainingQuests) then
        value = AIB.setValue(numQuests.." ("..remainingQuests..")",isWarning,isCritical)
      else
        value = AIB.setValue(numQuests,isWarning,isCritical)
      end

      -- set label
      if ((not AIB.saved.account.Quests.alwaysOn and (isWarning or isCritical))
        or (AIB.saved.account.Quests.alwaysOn)) then
        AIB.setLabel("Quests", header..value)
      end
    end
  end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Quests.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Quests..AIB.colors.blue.."Quests|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display quests in your journal.|r",
      },
      {
        type    = "checkbox",
        name    = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.Quests.on end,
        setFunc = function(newValue) AIB.saved.account.Quests.on = newValue; AIB.plugins.Quests.RegisterEvents(); AIB.plugins.Quests.UpdateQuests() end,
        default = AIB.defaults.Quests.on,
      },
      {
        type      = "checkbox",
        name      = "Show remaining quests",
        tooltip   = "Displays both current quest count and remaining quest count",
        getFunc   = function() return AIB.saved.account.Quests.showRemainingQuests end,
        setFunc   = function(newValue) AIB.saved.account.Quests.showRemainingQuests = newValue; AIB.plugins.Quests.UpdateQuests() end,
        disabled  = function() return not(AIB.saved.account.Quests.on) end,
        default   = AIB.defaults.Quests.showRemainingQuests,
      },
      {
        type      = "checkbox",
        name      = "Only show when quests are low",
        tooltip   = "If checked, quests will only display if the warning or critical threshold has been reached. If not checked, quests will always be displayed.",
        getFunc   = function() return not AIB.saved.account.Quests.alwaysOn end,
        setFunc   = function(newValue) AIB.saved.account.Quests.alwaysOn = not newValue; AIB.plugins.Quests.UpdateQuests() end,
        disabled  = function() return not(AIB.saved.account.Quests.on) end,
        default   = not AIB.defaults.Quests.alwaysOn,
      },
      {
        type      = "slider",
        name      = "Low remaining Quest count "..AIB.colors.yellow.."warning|r",
        tooltip   = "If remaining number of quests is this many or less, you will see a warning",
        min       = 1,
        max       = AIB.defaults.Quests.questLimit,
        getFunc   = function() return AIB.saved.account.Quests.warning end,
        setFunc   = function(newValue) AIB.saved.account.Quests.warning = newValue; AIB.plugins.Quests.UpdateQuests() end,
        disabled  = function() return AIB.saved.account.Quests.alwaysOn end,
        default   = AIB.defaults.Quests.warning,
      },
      {
        type      = "slider",
        name      = "Low remaining Quest count"..AIB.colors.red.."critical warning|r",
        tooltip   = "If remaining number of quests is this many or less, you will see a critical warning.",
        min       = 1,
        max       = AIB.defaults.Quests.questLimit,
        getFunc   = function() return AIB.saved.account.Quests.critical end,
        setFunc   = function(newValue) AIB.saved.account.Quests.critical = newValue; AIB.plugins.Quests.UpdateQuests() end,
        disabled  = function() return AIB.saved.account.Quests.alwaysOn end,
        default   = AIB.defaults.Quests.critical,
      }
    }
  }
}
