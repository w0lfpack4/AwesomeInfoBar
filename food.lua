
----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Food"]         =  "|t24:24:"..AIB.name.."/Textures/food.dds|t"
AIB.icons["FoodCritical"] =  "|t24:24:"..AIB.name.."/Textures/food_critical.dds|t"
AIB.icons["FoodWarning"]  =  "|t24:24:"..AIB.name.."/Textures/food_warning.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Food"] = {
  on        = true,
  alwaysOn  = false,
  warning   = 5,       -- minutes
  critical  = 2,       -- minutes
}

----------------------------------------------------
-- LOCAL VARS
----------------------------------------------------
AIB.vars["Food"] = {
  lastUpdate = 0,
  frequency = 10
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Food"] = {

  ------------------------------------------------
  -- PARENT METHOD: Initialize
  ------------------------------------------------
  Initialize = function()
    AIB.plugins.Food.UpdateFood()
  end,

  ------------------------------------------------
  -- PARENT METHOD: Update (every 1 sec)
  ------------------------------------------------
  Update = function()
    if (AIB.saved.account.Food.on) then
      -- less frequent update (10 sec default)
      AIB.vars.Food.lastUpdate = AIB.vars.Food.lastUpdate + 1
      if (AIB.vars.Food.lastUpdate > AIB.vars.Food.frequency) then
        AIB.vars.Food.lastUpdate = 0
        AIB.plugins.Food.UpdateFood()
      end
    end
  end,

  ------------------------------------------------
  -- METHOD: UpdateFood
  ------------------------------------------------
  UpdateFood = function()
    local snoozing = AIB.isSnoozing("Food")
    AIB.setLabel("Food","")

    -- if show food
    if (AIB.saved.account.Food.on and not snoozing) then
      local header, value = "",""
      local isWarning, isCritical = false, false

      -- get data
      local isBuffActive, foodTimer = LIB_FOOD_DRINK_BUFF:IsFoodBuffActiveAndGetTimeLeft("player")
      local buffType, isDrink, abilityId, buffName, timeStart, timeEnd, iconTexture = LIB_FOOD_DRINK_BUFF:GetFoodBuffInfos("player")
      if (foodTimer > 0) then
        -- convert seconds to minutes.
        foodTimer = math.floor(foodTimer / 60)
      end

      -- set warnings
      if isBuffActive then
        if (foodTimer <= AIB.saved.account.Food.warning) then
          if (foodTimer <= AIB.saved.account.Food.critical) then
            isCritical = true
          else
            isWarning = true
          end
        end
      else
        isCritical = true
      end

      -- swap icons
      if isDrink then
        AIB.icons["Food"]         =  "|t22:22:"..AIB.name.."/Textures/drink.dds|t"
        AIB.icons["FoodCritical"] =  "|t22:22:"..AIB.name.."/Textures/drink_critical.dds|t"
        AIB.icons["FoodWarning"]  =  "|t22:22:"..AIB.name.."/Textures/drink_warning.dds|t"
      else
        AIB.icons["Food"]         =  "|t24:24:"..AIB.name.."/Textures/food.dds|t"
        AIB.icons["FoodCritical"] =  "|t24:24:"..AIB.name.."/Textures/food_critical.dds|t"
        AIB.icons["FoodWarning"]  =  "|t24:24:"..AIB.name.."/Textures/food_warning.dds|t"
      end

      -- set header
      header = AIB.setHeader("Food",isWarning,isCritical)

      -- set value
      if isBuffActive then
        value = AIB.setValue(foodTimer.."m",isWarning,isCritical)
      else
        value = AIB.setValue("eat!",isWarning,isCritical)
      end

      -- set label
      if ((not AIB.saved.account.Food.alwaysOn and (isWarning or isCritical))
        or (AIB.saved.account.Food.alwaysOn)) then
        AIB.setLabel("Food", header..value)
      end
    end
  end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Food.Menu = {
  {
    type = "submenu",
    name = AIB.icons.Food..AIB.colors.blue.."Food and Drink Buff Timer|r",
    controls = {
      {
        type = "description",
        text = AIB.colors.orange.."Display a countdown timer for food or drink buff duration.|r",
      },
      {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Enables this plugin when checked",
        getFunc = function() return AIB.saved.account.Food.on end,
        setFunc = function(newValue) AIB.saved.account.Food.on = newValue; AIB.plugins.Food.UpdateFood() end,
        default = AIB.defaults.Food.on,
      },
      {
        type = "checkbox",
        name = "Only show when timer is low",
        tooltip = "If checked, food or drink buffs will only display if the warning or critical threshold has been reached. If not checked, food or drink buffs will always be displayed.",
        getFunc = function() return not AIB.saved.account.Food.alwaysOn end,
        setFunc = function(newValue) AIB.saved.account.Food.alwaysOn = not newValue; AIB.plugins.Food.UpdateFood(); end,
        disabled = function() return not(AIB.saved.account.Food.on) end,
        default = not AIB.defaults.Food.alwaysOn,
      },
      {
        type = "slider",
        name = "Low Food or Drink Buff "..AIB.colors.yellow.."warning|r (minutes)",
        tooltip = "If number of minutes remaining is this many or less, you will see a warning.",
        min  = 1,
        max = 30,
        getFunc = function() return AIB.saved.account.Food.warning end,
        setFunc = function(newValue) AIB.saved.account.Food.warning = newValue; AIB.plugins.Food.UpdateFood() end,
        disabled = function() return not(AIB.saved.account.Food.on) end,
        default = AIB.defaults.Food.warning,
      },
      {
        type = "slider",
        name = "Low Food or Drink Buff "..AIB.colors.red.."critical warning|r (minutes)",
        tooltip = "If number of minutes remaining is this many or less, you will see a critical warning.",
        min  = 1,
        max = 15,
        getFunc = function() return AIB.saved.account.Food.critical end,
        setFunc = function(newValue) AIB.saved.account.Food.critical = newValue; AIB.plugins.Food.UpdateFood() end,
        disabled = function() return not(AIB.saved.account.Food.on) end,
        default = AIB.defaults.Food.critical,
      }
    }
  }
}
