----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Champion"] = "|t38:38:esoui/art/treeicons/achievements_indexicon_champion_up.dds|t"

local CHAMPION_ATTRIBUTE_HUD_ICONS =
{
    [ATTRIBUTE_HEALTH]  = "EsoUI/Art/Champion/champion_points_health_icon-HUD-32.dds",
    [ATTRIBUTE_MAGICKA] = "EsoUI/Art/Champion/champion_points_magicka_icon-HUD-32.dds",
    [ATTRIBUTE_STAMINA] = "EsoUI/Art/Champion/champion_points_stamina_icon-HUD-32.dds",
}

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Champion"] = {
  on            = IsUnitChampion("player"),
  showPercent   = true,
  showSpent     = false,
  onlyShowSpent = false,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Champion"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    -- load global defaults to character if missing
    if (AIB.saved.character.Champion == nil) then
      AIB.saved.character.Champion = AIB.defaults.Champion
    end
    if (not IsUnitChampion("player")) then
      AIB.saved.character.Champion.on = false
    end
    AIB.plugins.Champion.UpdateChampion()
  end,

  ------------------------------------------------
  -- PARENT METHOD: RegisterEvents
  ------------------------------------------------
  RegisterEvents = function()
    if (AIB.saved.account.Champion.on) then
      EVENT_MANAGER:RegisterForEvent("AIB_Champion", EVENT_EXPERIENCE_GAIN, AIB.plugins.Champion.UpdateChampion)
    else
      EVENT_MANAGER:UnregisterForEvent("AIB_Champion", EVENT_EXPERIENCE_GAIN)
    end
  end,


  ------------------------------------------------
  -- METHOD: UpdateChampion
  ------------------------------------------------
  UpdateChampion = function()
    local snoozing = AIB.isSnoozing("Champion")
    AIB.setLabel("Champion","")

    -- if Champion on, update
    if (AIB.saved.character.Champion.on and not snoozing) then
      local header, value, display = "","",""

      -- get data
      local points = GetPlayerChampionPointsEarned()

      -- get spent
      local pointsSpent = 0
      for attribute, _ in next, CHAMPION_ATTRIBUTE_HUD_ICONS do
        pointsSpent = pointsSpent + GetNumSpentChampionPoints(attribute)
      end
      pointsSpent = points-pointsSpent

      -- show spent points
      if (AIB.saved.character.Champion.showSpent) then
        if (AIB.saved.character.Champion.onlyShowSpent) then
          if (pointsSpent < points) then
            display = AI.colors.red..pointsSpent
          else
            display = AI.colors.red..0
          end
        else
          if (pointsSpent < points) then
            display = AI.colors.red..pointsSpent.."|r/"..points
          else
            display = points
          end
          if (AIB.saved.character.Champion.showPercent) then
            display = display..": "..AIB.plugins.Champion.GetPercent().."%"
          end
        end
      else
        display = points
        if (AIB.saved.character.Champion.showPercent) then
          display = display..": "..AIB.plugins.Champion.GetPercent().."%"
        end
      end

      -- set header
      header = AIB.setHeader("Champion", false, false)

      -- set value
      value = AIB.setValue(display, false, false)

      -- set label
      AIB.setLabel("Champion", header..value)

      -- set color
      local currentLevel = 0
      if CanUnitGainChampionPoints("player") then
        currentLevel = GetPlayerChampionPointsEarned()
      else
        currentLevel = GetUnitLevel("player")
      end
      if GetNumChampionXPInChampionPoint(currentLevel) ~= nil then
        currentLevel = currentLevel + 1
      end
      local nextPoint = GetChampionPointAttributeForRank(currentLevel)
      local color1 = ZO_CP_BAR_GRADIENT_COLORS[nextPoint][1]
      local color2 = ZO_CP_BAR_GRADIENT_COLORS[nextPoint][2]
      AIB.setLabelColor("Champion", color2.r, color2.g, color2.b, color2.a)
    end
    end,

  ------------------------------------------------
  -- METHOD: GetPercent
  ------------------------------------------------
    GetPercent = function()
      local cp = GetUnitChampionPoints("player")
      return math.floor((GetPlayerChampionXP()/GetNumChampionXPInChampionPoint(cp)) * 100)
    end,

}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Champion.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Champion..AIB.colors.blue.."Champion Points|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Displays champion points. These settings are per character.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.character.Champion.on end,
        setFunc = function(newValue) AIB.saved.character.Champion.on = newValue; AIB.plugins.Champion.UpdateChampion() end,
        default = AIB.defaults.Champion.on,
      },
      {
        type = "checkbox",
        name = "Show percent till next Champion Point",
        tooltip = "Displays percentage until the next Champion Point",
        getFunc = function() return AIB.saved.character.Champion.showPercent end,
        setFunc = function(newValue) AIB.saved.character.Champion.showPercent = newValue; AIB.plugins.Champion.UpdateChampion() end,
        disabled = function() return not(AIB.saved.character.Champion.on) end,
        default = AIB.defaults.Champion.showPercent,
      },
      {
        type = "checkbox",
        name = "Show points spent / points earned",
        tooltip = "Displays how many points have been spent",
        getFunc = function() return AIB.saved.character.Champion.showSpent end,
        setFunc = function(newValue) AIB.saved.character.Champion.showSpent = newValue; AIB.plugins.Champion.UpdateChampion() end,
        disabled = function() return not(AIB.saved.character.Champion.on) end,
        default = AIB.defaults.Champion.showSpent,
      },
      {
        type = "checkbox",
        name = "Only display unspent points",
        tooltip = "Displays only unspent points",
        getFunc = function() return AIB.saved.character.Champion.onlyShowSpent end,
        setFunc = function(newValue) AIB.saved.character.Champion.onlyShowSpent = newValue; AIB.plugins.Champion.UpdateChampion() end,
        disabled = function() return not(AIB.saved.character.Champion.on) end,
        default = AIB.defaults.Champion.onlyShowSpent,
      }
    }
  }
}
