AIB = {}

-- addon info
AIB.name        = "AwesomeInfoBar"    -- Top Level Control Name / Addon Name
AIB.displayName = "|cFF6060Awesome |cffffffInfoBar|r"    -- Menu Display
AIB.version     = "3.2"
AIB.author      = "Keg"
AIB.Initialized = false
AIB.moving      = false

-- define plugins
AIB.plugins = {}

-- define saved vars
AIB.saved = {}

-- define local vars
AIB.vars = {
  snooze = {},
}

-- define icons
AIB.icons = {}

-- define standard colors
AIB.colors = {
  red       = "|cFF6060",
  yellow    = "|cFFFF60",
  green     = "|c60FF60",
  blue      = "|c45D7F7",
  cyan      = "|c4a8ee6",
  darkcyan  = "|c377cb8",
  orange    = "|cffa500",
  white     = "|cffffff",
  gray      = "|ccfcfcf",
  olive     = "|c65875c",
  purple    = "|c9B30FF",
  header    = "|cc2c29c",
  normal    = "|cffffff",
  safe      = "|c60FF60",
  warning   = "|cFFFF60",
  imminent  = "|cffa500",
  critical  = "|cFF6060",
}

AIB.quality = {
  [1] = "|cffffff", -- white
  [2] = "|c00ff00", -- green
  [3] = "|c3995fd", -- blue
  [4] = "|c9B30FF", -- purple
  [5] = "|cff7700", -- orange
}

----------------------------------------------------
-- Set-up the default options for saved variables.
----------------------------------------------------
AIB.defaults = {
  -- addon options
  system = {
    windowLocked    = false,
    locx            = 15,
    locy            = 15,
    scaling         = 1.0,
    textAlign       = "LEFT",
    hideCombatAI    = true,
    showBG          = true,
    bgAlpha         = 0.75,
    direction       = "HORIZONTAL",
    useIcons        = true,
    colorIcons      = false,
    childStartIndex = 3, -- background textures are child 1 & 2 so start at 3
    allowSnooze     = true,
    snoozeDuration  = 15, -- minutes
    lastOnUpdate    = 0,
  }
}


----------------------------------------------------
-- addon: Initialize
----------------------------------------------------
function AIB.Initialize(eventCode, addOnName)
  -- Only initialize our own addon
  if (AIB.name ~= addOnName) then return end

  -- Load the saved variables.  per character defaults are set within the plugin
  AIB.saved.account = ZO_SavedVars:NewAccountWide("AIB_SavedVariables", 1, nil, AIB.defaults)
  AIB.saved.character = ZO_SavedVars:New("AIB_SavedVariables", 1, nil)

  -- set moveable
  _G[AIB.name]:SetMovable(AIB.saved.account.system.windowLocked)

  -- set mouse enabled for each child
  for i = AIB.saved.account.system.childStartIndex, _G[AIB.name]:GetNumChildren() do
    local child = _G[AIB.name]:GetChild(i)
    child:SetMouseEnabled(not AIB.saved.account.system.windowLocked)
  end

  -- set label anchors
  AIB.SetAnchors()

  -- set fragments
  AIB.SetFragments()

  -- set AIB label alignment
  AIB.SetTextAlign(AIB.saved.account.system.textAlign)

  -- Initialize plugins
  for key,value in pairs(AIB.plugins) do
    if (AIB.plugins[key].Initialize ~= nil) then
      AIB.plugins[key].Initialize()
    end
  end

  -- reset width and height
  AIB.UpdateWidthAndHeight()

  -- Invoke config menu set-up
  AIB.CreateConfigMenu()

  -- The rest of the event registration is here, rather than with ADD_ON_LOADED because I don't want any of them being
  -- called until after initialisation is complete.
  AIB.RegisterEvents()

  -- done here
  AIB.Initialized = true

end -- AIB.Initialize


----------------------------------------------------
-- addon: set anchors on AI labels
----------------------------------------------------
function AIB.SetAnchors()
  -- Set-up all the labels. They're created in the XML but define additional info about them here.
  -- They are also set so that each label is anchored to the bottom of the previous one.
  -- This allows them to link together seamlessly without requiring code to move them around when one is hidden.
  local anchorLabel = TOP
  local anchorParent = BOTTOM

  -- change anchor positions if horizontal
  if (AIB.saved.account.system.direction == "HORIZONTAL") then
    anchorLabel = LEFT
    anchorParent = RIGHT
  end

  -- set anchors for each plugin label
  -- iterating by child instead of plugin sets the order to that of the xml
  local lastChild = nil
  for i = AIB.saved.account.system.childStartIndex, _G[AIB.name]:GetNumChildren() do
    local child = _G[AIB.name]:GetChild(i)
    if (lastChild == nil) then
      child:SetAnchor(anchorLabel, _G[AIB.name], anchorLabel, 0, 0)
    else
      child:SetAnchor(anchorLabel, lastChild, anchorParent, 0, 0)
    end
    lastChild = child
  end

end -- AIB.SetAnchors

----------------------------------------------------
-- addon: lock fragments to hud and hudui
----------------------------------------------------
function AIB.SetFragments()
  -- lock this addon to hud and hudui
  local fragment = ZO_SimpleSceneFragment:New( _G[AIB.name] )
  SCENE_MANAGER:GetScene('hud'):AddFragment( fragment )
  SCENE_MANAGER:GetScene('hudui'):AddFragment( fragment )
end --AIB.SetFragments

----------------------------------------------------
-- addon: register events
----------------------------------------------------
function AIB.RegisterEvents()
  -- core will handle combat event and loop through plugins
  EVENT_MANAGER:RegisterForEvent("AIB", EVENT_PLAYER_COMBAT_STATE, AIB.OnCombatState)

  -- loop through plugins
  for key,value in pairs(AIB.plugins) do
    if (AIB.plugins[key].RegisterEvents ~= nil) then
      AIB.plugins[key].RegisterEvents()
    end
  end
end --AIB.RegisterEvents

----------------------------------------------------
-- addon: merge tables
----------------------------------------------------
function AIB.Merge(t1,t2)
  for i=1,#t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end

----------------------------------------------------
-- addon: move start
----------------------------------------------------
function AIB.MoveStart()
  AIB.moving = true
  AIB.SetBackgroundAlpha()
end

----------------------------------------------------
-- addon: move stop
----------------------------------------------------
function AIB.MoveStop()
  if (AIB.saved.account.system.textAlign == "LEFT") then
    AIB.saved.account.system.locx = _G[AIB.name]:GetLeft()
    AIB.saved.account.system.locy = _G[AIB.name]:GetTop()

  elseif (AIB.saved.account.system.textAlign == "CENTER") then
    AIB.saved.account.system.locx, _ = _G[AIB.name]:GetCenter()
    AIB.saved.account.system.locy = _G[AIB.name]:GetTop()

  elseif (AIB.saved.account.system.textAlign == "RIGHT") then
    AIB.saved.account.system.locx = _G[AIB.name]:GetRight()
    AIB.saved.account.system.locy = _G[AIB.name]:GetTop()
  end

  AIB.moving = false
  AIB.SetBackgroundAlpha()
end

----------------------------------------------------
-- addon: set label text
----------------------------------------------------
function AIB.setLabel(label, value)
  _G[AIB.name.."Label"..label]:SetText(value)
  if (value=="") then
    _G[AIB.name.."Label"..label]:SetHeight( 0 )
  end
end

----------------------------------------------------
-- addon: set label color
----------------------------------------------------
function AIB.setLabelColor(label, r, g, b, a)
  _G[AIB.name.."Label"..label]:SetColor(r, g, b, a)
end

------------------------------------------------
-- addon: set Header icon/text
------------------------------------------------
function AIB.setHeader(label, isWarning, isCritical)
  if (AIB.saved.account.system.useIcons) then
    header = AIB.icons[label]

    if (AIB.saved.account.system.colorIcons) then
      if (isWarning)  then header = AIB.icons[label.."Warning"]  end
      if (isCritical) then header = AIB.icons[label.."Critical"]  end
    end

  else
    header = AIB.colors.header..label..": |r"
  end

  return header
end

------------------------------------------------
-- addon: set Value
------------------------------------------------
function AIB.setValue(value,  isWarning, isCritical)
  if ((not AIB.saved.account.system.useIcons) or (not AIB.saved.account.system.colorIcons)) then
    if (isWarning)  then value = AIB.colors.warning..value   end
    if (isCritical) then value = AIB.colors.critical..value  end
  end
  return value
end

----------------------------------------------------
-- addon: reset label width and height after update
----------------------------------------------------
function AIB.UpdateWidthAndHeight()
  if AIB.moving then return end

  local maxWidth = 0;
  local maxHeight = 0;

  if (AIB.saved.account.system.direction == "VERTICAL") then
    -- find the widest element
    -- and determine the height of all children
    for i = AIB.saved.account.system.childStartIndex, _G[AIB.name]:GetNumChildren() do
      local child = _G[AIB.name]:GetChild(i)
      child:SetWidth(0)
      local currentWidth = child:GetTextWidth()
      maxHeight = maxHeight + child:GetTextHeight()
      if (maxWidth < currentWidth) then
        maxWidth = currentWidth
      end
    end

    -- set each child to the width of the widest element
    for i = AIB.saved.account.system.childStartIndex, _G[AIB.name]:GetNumChildren() do
      local child = _G[AIB.name]:GetChild(i)
      child:SetWidth(maxWidth)
      child:SetHeight(child:GetTextHeight())
    end
  else
    for i = AIB.saved.account.system.childStartIndex, _G[AIB.name]:GetNumChildren() do
      local child = _G[AIB.name]:GetChild(i)
      child:SetHeight(0)
      local currentHeight = child:GetTextHeight()
      maxWidth = maxWidth + child:GetTextWidth()
      if (maxHeight > currentHeight) then
        maxHeight = currentHeight
      end
    end

    -- set each child to the width of the widest element
    for i = AIB.saved.account.system.childStartIndex, _G[AIB.name]:GetNumChildren() do
      local child = _G[AIB.name]:GetChild(i)
      child:SetHeight(maxHeight)
      -- space them out a bit
      child:SetWidth(0)
      local currentWidth = child:GetTextWidth()
      if (currentWidth ~= 0) then
        child:SetWidth(currentWidth + 20)
        maxWidth = maxWidth + 20
      end
    end
  end

  -- set the addon height and width
  _G[AIB.name]:SetWidth(maxWidth)
  _G[AIB.name]:SetHeight(maxHeight+20)

  -- set background
  AIB.SetBackgroundAlpha()

  -- reset the anchor
  AIB.UpdateAnchor()
end --AIB.UpdateWidthAndHeight


----------------------------------------------------
-- addon: reset label anchors after update
----------------------------------------------------
function AIB.SetBackgroundAlpha()
  if (AIB.moving) then
    if (AIB.saved.account.system.direction == "VERTICAL") then
      _G[AIB.name.."BG2"]:SetAlpha(1)
    else
      _G[AIB.name.."BG1"]:SetAlpha(1)
    end
  else
    _G[AIB.name.."BG1"]:SetAlpha(0)
    _G[AIB.name.."BG2"]:SetAlpha(0)
    if (AIB.saved.account.system.showBG) then
      if (AIB.saved.account.system.direction == "VERTICAL") then
        _G[AIB.name.."BG2"]:SetHeight(_G[AIB.name]:GetHeight()*5)
        _G[AIB.name.."BG2"]:SetAlpha(AIB.saved.account.system.bgAlpha)
      else
        _G[AIB.name.."BG1"]:SetWidth(_G[AIB.name]:GetWidth()*1.76)
        _G[AIB.name.."BG1"]:SetAlpha(AIB.saved.account.system.bgAlpha)
      end
    end
  end
end --SetBackgroundAlpha

----------------------------------------------------
-- addon: reset label anchors after update
----------------------------------------------------
function AIB.UpdateAnchor()
  _G[AIB.name]:ClearAnchors()
  if (AIB.saved.account.system.textAlign == "LEFT") then
    _G[AIB.name]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AIB.saved.account.system.locx, AIB.saved.account.system.locy)
  elseif (AIB.saved.account.system.textAlign == "CENTER") then
    _G[AIB.name]:SetAnchor(TOP, GuiRoot, TOPLEFT, AIB.saved.account.system.locx, AIB.saved.account.system.locy)
  elseif (AIB.saved.account.system.textAlign == "RIGHT") then
    _G[AIB.name]:SetAnchor(TOPRIGHT, GuiRoot, TOPLEFT, AIB.saved.account.system.locx, AIB.saved.account.system.locy)
  end
end --AIB.UpdateAnchor

----------------------------------------------------
-- addon: set label text alignment
----------------------------------------------------
function AIB.SetTextAlign(newValue)
  AIB.saved.account.system.textAlign = newValue
  local alignText = {}
  alignText["LEFT"]   = 0
  alignText["CENTER"] = 1
  alignText["RIGHT"]  = 2
  AIB.UpdateAnchor()
  for i = AIB.saved.account.system.childStartIndex, _G[AIB.name]:GetNumChildren() do
    local child = _G[AIB.name]:GetChild(i)
    child:SetHorizontalAlignment(alignText[newValue])
  end
end -- AIB.SetTextAlign

----------------------------------------------------
-- EVENT: OnUpdate, addon/plugin update call
----------------------------------------------------
function AIB.OnUpdate()
  -- Bail if we haven't completed the initialisation routine yet.
  if (not AIB.Initialized) then return end

  -- Only run this update if a full second has elapsed since last time we did so.
  local curSeconds = GetSecondsSinceMidnight()
  if ( curSeconds ~= AIB.lastOnUpdate ) then
    -- reset the last update value
    AIB.lastOnUpdate = curSeconds

    -- check the snooze state of the plugins
    AIB.CheckSnoozeTimers()

    -- loop through plugins
    for key,value in pairs(AIB.plugins) do
      if (AIB.plugins[key].Update ~= nil) then
        AIB.plugins[key].Update()
      end
    end

    -- updates have run, reset dimensions of the addon
    AIB.UpdateWidthAndHeight()
  end
end -- AIB.OnUpdate

----------------------------------------------------
-- EVENT: OnCombatState, hide addon in combat
----------------------------------------------------
function AIB.OnCombatState(eventCode, inCombat)
  -- Bail if we haven't completed the initialization routine yet.
  if (not AIB.Initialized) then return end

  -- in combat
  if (inCombat) then
    -- hide addon
    if (AIB.saved.account.system.hideCombatAI) then
      _G[AIB.name]:SetHidden(true)
    end

  -- not in combat
  else
    -- show addon
    if (AIB.saved.account.system.hideCombatAI) then
      _G[AIB.name]:SetHidden(false)
    end
  end
end --AIB.OnCombatState

------------------------------------------------
-- EVENT: OnMouseUp (snooze)
------------------------------------------------
function AIB.OnMouseUp(self, button, upInside)
  if (AIB.saved.account.system.allowSnooze) then
    AIB.vars.snooze[self:GetName()] = {
      on = true,
      count = 0,
    }
    _G[self:GetName()]:SetText("")
    _G[self:GetName()]:SetHeight( 0 )
  end
end

------------------------------------------------
-- METHOD: isSnoozing
------------------------------------------------
function AIB.isSnoozing(label)
  if (AIB.vars.snooze[AIB.name.."Label"..label] ~= nil) then
    return AIB.vars.snooze[AIB.name.."Label"..label].on
  end
  return false
end -- AIB.isSnoozing


------------------------------------------------
-- METHOD: SnoozeCheck
------------------------------------------------
function AIB.CheckSnoozeTimers()
  -- check the snooze timers
  for key,value in pairs(AIB.vars.snooze) do
    if (AIB.vars.snooze[key].on) then
      AIB.vars.snooze[key].count = AIB.vars.snooze[key].count + 1
      --d("snoozing: " .. AIB.vars.snooze[key].count .. " > (" .. AIB.saved.account.system.snoozeDuration .. " * 60) ? "..tostring((AIB.vars.snooze[key].count > (AIB.saved.account.system.snoozeDuration * 60))))
      if (AIB.vars.snooze[key].count > (AIB.saved.account.system.snoozeDuration * 60)) then
        AIB.vars.snooze[key].on = false
        --d("snooze off")
      end
    end
  end
end -- AIB.CheckSnoozeTimers

--------------------------------------------------
-- METHOD: Debug
--------------------------------------------------
function AIB.Debug(msg)
  CHAT_SYSTEM:AddMessage("AIB_Debug: "..msg)
end

----------------------------------------------------
-- Initialize has been defined so register the event
----------------------------------------------------
EVENT_MANAGER:RegisterForEvent("AIB", EVENT_ADD_ON_LOADED, AIB.Initialize)
