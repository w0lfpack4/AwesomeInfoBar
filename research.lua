
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Research"]         =  "|t22:22:"..AIB.name.."/Textures/timer.dds|t"
AIB.icons["ResearchCritical"] =  "|t22:22:"..AIB.name.."/Textures/timer_critical.dds|t"
AIB.icons["ResearchWarning"]  =  "|t22:22:"..AIB.name.."/Textures/timer_warning.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Research"] = {
  on        = true,
  alwaysOn  = true,
  warning   = 2,   -- amount
  critical  = 1,   -- amount
  displayType = "ACTIVE / MAX",
}

AIB.vars["Research"] = {
  types = {
    blacksmithing = CRAFTING_TYPE_BLACKSMITHING,
    clothier      = CRAFTING_TYPE_CLOTHIER,
    woodworking   = CRAFTING_TYPE_WOODWORKING,
    jewelcrafting = CRAFTING_TYPE_JEWELRYCRAFTING,
  }
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Research"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    -- load global defaults to character if missing
    if (AIB.saved.character.Research == nil) then
      AIB.saved.character.Research = AIB.defaults.Research
    end
    AIB.plugins.Research.UpdateResearch()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.character.Research.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Research", EVENT_PLAYER_ACTIVATED, AIB.plugins.Research.UpdateResearch)
      EVENT_MANAGER:RegisterForEvent("AIB_Research", EVENT_SKILLS_FULL_UPDATE, AIB.plugins.Research.UpdateResearch)
      EVENT_MANAGER:RegisterForEvent("AIB_Research", EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, AIB.plugins.Research.UpdateResearch)
      EVENT_MANAGER:RegisterForEvent("AIB_Research", EVENT_SMITHING_TRAIT_RESEARCH_STARTED, AIB.plugins.Research.UpdateResearch)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Research", EVENT_PLAYER_ACTIVATED)
      EVENT_MANAGER:UnregisterForEvent("AIB_Research", EVENT_SKILLS_FULL_UPDATE)
      EVENT_MANAGER:UnregisterForEvent("AIB_Research", EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED)
      EVENT_MANAGER:UnregisterForEvent("AIB_Research", EVENT_SMITHING_TRAIT_RESEARCH_STARTED)
    end
  end,

  ------------------------------------------------
  -- EVENT: UpdateResearch
    ------------------------------------------------
    UpdateResearch = function()
    local snoozing = AIB.isSnoozing("Research")
    AIB.setLabel("Research","")

    -- if show gold
    if (AIB.saved.character.Research.on and not snoozing) then
      local header, value = "",""
      local isWarning, isCritical = false, false
      local maxSlots = 0
      local activeSlots = 0
      for key, craftingType in pairs(AIB.vars.Research.types) do
          local maxCraft = GetMaxSimultaneousSmithingResearch(craftingType)
          maxSlots = maxSlots + maxCraft
          for lineIndex = 1, GetNumSmithingResearchLines(craftingType) do
              local _, _, numTraits = GetSmithingResearchLineInfo(craftingType, lineIndex)
              for traitIndex = 1, numTraits do
                  local duration, remaining = GetSmithingResearchLineTraitTimes(craftingType, lineIndex, traitIndex)
                  if remaining then
                      activeSlots = activeSlots + 1
                  end
              end
          end
      end

      -- set warnings
      if (activeSlots < AIB.saved.character.Research.warning) then
        if (activeSlots <= AIB.saved.character.Research.critical) then
          isCritical = true
        else
          isWarning = true
        end
      end

      -- set header
      header = AIB.setHeader("Research",isWarning,isCritical)

      -- determine value
      local valueToUse = activeSlots
      if (AIB.saved.character.Research.displayType == "ACTIVE / MAX") then
          displayValue = activeSlots.."/"..maxSlots
      elseif (AIB.saved.character.Research.displayType == "INACTIVE") then
          displayValue = maxSlots - activeSlots
      end

      -- set value
      value = AIB.setValue(displayValue,isWarning,isCritical)

      -- set label
      if ((not AIB.saved.character.Research.alwaysOn and (isWarning or isCritical))
        or (AIB.saved.character.Research.alwaysOn)) then
        AIB.setLabel("Research", header..value)
      end
    end
  end,

  ------------------------------------------------
  -- METHOD: GetMaxResearchSlots
  ------------------------------------------------
  GetMaxResearchSlots = function()
    local maxSlots = 0
    for key, craftingType in pairs(AIB.vars.Research.types) do
      local maxCraft = GetMaxSimultaneousSmithingResearch(craftingType)
      maxSlots = maxSlots + maxCraft
    end
    return maxSlots
  end,

}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Research.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Research..AIB.colors.blue.."Research|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display the amount of active research.  These settings are per character.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.character.Research.on end,
        setFunc = function(newValue) AIB.saved.character.Research.on = newValue; AIB.plugins.Research.RegisterEvents(); AIB.plugins.Research.UpdateResearch() end,
        default = AIB.defaults.Research.on,
      },
      {
        type = "dropdown",
        name = "Display",
        tooltip = "How do you want this information displayed",
        choices = {"ACTIVE","INACTIVE","ACTIVE / MAX"},
        getFunc = function() return AIB.saved.character.Research.displayType end,
        setFunc = function(newValue) AIB.saved.character.Research.displayType = newValue; AIB.plugins.Research.UpdateResearch() end,
        disabled = function() return not(AIB.saved.character.Research.on) end,
        default = AIB.defaults.Research.displayType,
      },
      {
        type = "checkbox",
        name = "Only show when Research is low",
        tooltip = "If checked, Research will only display if the warning or critical threshold has been reached. If not checked, Research will always be displayed.",
        getFunc = function() return not AIB.saved.character.Research.alwaysOn end,
        setFunc = function(newValue) AIB.saved.character.Research.alwaysOn = not newValue; AIB.plugins.Research.UpdateResearch() end,
        disabled = function() return not(AIB.saved.character.Research.on) end,
        default = not AIB.defaults.Research.alwaysOn,
      },
      {
        type = "slider",
        name = "Low Research "..AIB.colors.yellow.."warning|r",
        tooltip = "If remaining active research is this many or less, you will see a warning",
        min  = 0,
        max = AIB.plugins.Research.GetMaxResearchSlots(),
        step = 1,
        getFunc = function() return AIB.saved.character.Research.warning end,
        setFunc = function(newValue) AIB.saved.character.Research.warning = newValue; AIB.plugins.Research.UpdateResearch() end,
        disabled = function() return (not(AIB.saved.character.Research.on) or AIB.saved.character.Research.alwaysOn) end,
        default = AIB.defaults.Research.warning,
      },
      {
        type = "slider",
        name = "Low Research "..AIB.colors.red.."critical warning|r",
        tooltip = "If remaining active research is this many or less, you will see a critical warning.",
        min  = 0,
        max = AIB.plugins.Research.GetMaxResearchSlots(),
        step = 1,
        getFunc = function() return AIB.saved.character.Research.critical end,
        setFunc = function(newValue) AIB.saved.character.Research.critical = newValue; AIB.plugins.Research.UpdateResearch() end,
        disabled = function() return (not(AIB.saved.character.Research.on) or AIB.saved.character.Research.alwaysOn) end,
        default = AIB.defaults.Research.critical,
      }
    }
  }
}
