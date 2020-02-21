local LAM = LibStub("LibAddonMenu-2.0")

function AIB.CreateConfigMenu()

  ----------------------------------------------------
  -- Set up panel info for Awesome InfoBar
  ----------------------------------------------------
    local AwesomeInfoBarPanel = {
     type                 = "panel",
     name                 = AIB.displayName,
     registerForRefresh   = true,
     registerForDefaults  = true,
     author               = AIB.colors.red..AIB.author.."|r",
     version              = AIB.colors.green..AIB.version.."|r",
    }

  ----------------------------------------------------
  -- Register panel for Awesome Info Bar
  ----------------------------------------------------
  LAM:RegisterAddonPanel(AIB.displayName, AwesomeInfoBarPanel)

  ----------------------------------------------------
  -- Set up options info for Awesome InfoBar
  ----------------------------------------------------
  local AwesomeInfoBarOptions = {
    {
      type = "description",
      text = AIB.colors.orange.."There are many ways you can customise your AIB experience, so don't forget to scroll down the options page.|r",
    },
    {
      type = "submenu",
      name = AIB.colors.normal.."InfoBar Options|r",
      controls = {
        {
          type = "description",
          text = AIB.colors.orange.."UI Options|r",
        },
        {
          type = "checkbox",
          name = "Unlock Window",
          tooltip = "UnLocks the window so it can be moved.",
          getFunc = function() return AIB.saved.account.system.windowLocked end,
          setFunc = function(newValue)
            AIB.saved.account.system.windowLocked = newValue
            -- set moveable
            _G[AIB.name]:SetMovable(newValue)
            -- set mouse enabled for each child
            for i = AIB.saved.account.system.childStartIndex, _G[AIB.name]:GetNumChildren() do
              local child = _G[AIB.name]:GetChild(i)
              child:SetMouseEnabled(not newValue)
            end
          end,
          default = AIB.defaults.system.windowLocked,
        },
        {
          type = "slider",
          name = "UI scale",
          tooltip = "Set the scale of the UI.",
          min  = 5,
          max = 15,
          getFunc = function() return 10 * AIB.saved.account.system.scaling end,
          setFunc = function(newValue) AIB.saved.account.system.scaling = newValue / 10; _G[AIB.name]:SetScale(AIB.saved.account.system.scaling) end,
          default = 10 * AIB.defaults.system.scaling,
        },
        {
          type = "description",
          text = AIB.colors.orange.."Combat Options|r",
        },
        {
          type = "checkbox",
          name = "Hide "..AIB.displayName.." in combat",
          tooltip = "Hides this addon in combat",
          getFunc = function() return AIB.saved.account.system.hideCombatAI end,
          setFunc = function(newValue) AIB.saved.account.system.hideCombatAI = newValue end,
          default = AIB.defaults.system.hideCombatAI,
        },
        {
          type = "description",
          text = AIB.colors.orange.."Icon Options|r",
        },
        {
          type = "checkbox",
          name = "Use Icons Instead of Text",
          tooltip = "Uses icons instead of header text in the info bar",
          getFunc = function() return AIB.saved.account.system.useIcons end,
          setFunc = function(newValue) AIB.saved.account.system.useIcons = newValue end,
          requiresReload = true,
          default = AIB.defaults.system.useIcons,
        },
        {
          type = "checkbox",
          name = "Color Icons on Warning and Critical Thresholds",
          tooltip = "If checked, the icons will be colored red, yellow, or normal depending upon which warning threshold has been met. If not checked, the icon color will remain the same and the text will be colored instead",
          getFunc = function() return AIB.saved.account.system.colorIcons end,
          setFunc = function(newValue) AIB.saved.account.system.colorIcons = newValue end,
          requiresReload = true,
          disabled = function() return not(AIB.saved.account.system.useIcons) end,
          default = AIB.defaults.system.colorIcons,
        },
        {
          type = "description",
          text = AIB.colors.orange.."Alignment Options|r",
        },
        {
          type = "dropdown",
          name = "Text alignment",
          tooltip = "The alignment of all text within the add-on.",
          getFunc = function() return AIB.saved.account.system.textAlign end,
          setFunc = function(newValue) AIB.saved.account.system.textAlign = newValue end,
          choices = {"LEFT","CENTER","RIGHT"},
          setFunc = function(newValue) AIB.SetTextAlign(newValue) end,
          getFunc = function() return AIB.saved.account.system.textAlign end,
          default = AIB.defaults.system.textAlign,
        },
        {
          type = "dropdown",
          name = "Item alignment",
          tooltip = "The alignment of all items within the add-on.",
          choices = {"HORIZONTAL","VERTICAL"},
          getFunc = function() return AIB.saved.account.system.direction end,
          setFunc = function(newValue) AIB.saved.account.system.direction = newValue; AIB.SetAnchors(); AIB.UpdateWidthAndHeight() end,
          default = AIB.defaults.system.direction,
        },
        {
          type = "description",
          text = AIB.colors.orange.."Background Options|r",
        },
        {
          type = "checkbox",
          name = "Show Background",
          tooltip = "Shows the background",
          getFunc = function() return AIB.saved.account.system.showBG end,
          setFunc = function(newValue) AIB.saved.account.system.showBG = newValue; AIB.SetBackgroundAlpha() end,
          default = AIB.defaults.system.showBG,
        },
        {
          type = "slider",
          name = "Background Transparency",
          tooltip = "Sets the transparency (alpha) of the background",
          min  = 0,
          max = 100,
          step = 1,
          getFunc = function() return AIB.saved.account.system.bgAlpha * 100 end,
          setFunc = function(newValue) AIB.saved.account.system.bgAlpha = newValue / 100; AIB.SetBackgroundAlpha() end,
          default = AIB.defaults.system.bgAlpha * 100,
        },
        {
          type = "description",
          text = AIB.colors.orange.."Snoozing: Click a warning to hide it for a specified amount of time|r",
        },
        {
          type = "checkbox",
          name = "Allow Snoozing",
          tooltip = "Turns the snoozing feature on or off.",
          getFunc = function() return AIB.saved.account.system.allowSnooze end,
          setFunc = function(newValue) AIB.saved.account.system.allowSnooze = newValue end,
          disabled = function() return AIB.saved.account.system.windowLocked end,
          default = AIB.defaults.system.allowSnooze,
        },
        {
          type = "slider",
          name = "Snooze duration (in minutes)",
          tooltip = "The amount of time in minutes before a warning will show again.",
          min  = 1,
          max = 60,
          step = 1,
          getFunc = function() return AIB.saved.account.system.snoozeDuration end,
          setFunc = function(newValue) AIB.saved.account.system.snoozeDuration = newValue end,
          disabled = function() return not(AIB.saved.account.system.allowSnooze) end,
          default = AIB.defaults.system.snoozeDuration,
        }
      }
    }
  }

  ----------------------------------------------------
  -- Merge plugin menus for Awesome InfoBar
  ----------------------------------------------------
  for key,value in pairs(AIB.plugins) do
    if (AIB.plugins[key].Menu ~= nil) then
      AwesomeInfoBarOptions = AIB.Merge(AwesomeInfoBarOptions, AIB.plugins[key].Menu)
    end
  end
  ----------------------------------------------------
  -- Register option controls for Awesome Info
  ----------------------------------------------------
  LAM:RegisterOptionControls(AIB.displayName, AwesomeInfoBarOptions)


end -- AIB.CreateConfigMenu
