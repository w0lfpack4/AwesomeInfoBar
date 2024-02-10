----------------------------------------------------
-- ICONS
----------------------------------------------------
AIB.icons["Companion"] = "|t32:32:/esoui/art/companion/keyboard/category_u30_rapport_up.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AIB.defaults["Companion"] = {
    on 			  = false,
	show		  = HasActiveCompanion(),
    showPercent   = true,
    showValue     = false,
    showTotal = false,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AIB.plugins["Companion"] = {
	
	------------------------------------------------
	-- PARENT METHOD: Initialize
	------------------------------------------------
	Initialize = function()
		-- load global defaults to character if missing
		if (AIB.saved.character.Companion == nil) then
            AIB.saved.character.Companion = AIB.defaults.Companion          
		end		
		AIB.plugins.Companion.IsCompanionSummoned()
		AIB.plugins.Companion.UpdateCompanion()
	end,

	------------------------------------------------
	-- PARENT METHOD: RegisterEvents
	------------------------------------------------
	RegisterEvents = function()
		--ZO_PreHookHandler(ZO_PlayerProgressBar, 'OnUpdate', AIB.plugins.Companion.UpdateCompanion)
		EVENT_MANAGER:RegisterForEvent("AI_Companion", EVENT_ACTIVE_COMPANION_STATE_CHANGED, AIB.plugins.Companion.UpdateCompanion)
		EVENT_MANAGER:RegisterForEvent("AI_Companion", EVENT_COMPANION_RAPPORT_UPDATE , AIB.plugins.Companion.UpdateCompanion)
	end,			
	
	
	------------------------------------------------
	-- METHOD: UpdateCompanion
	------------------------------------------------
	UpdateCompanion = function()
		local snoozing = AIB.isSnoozing("Companion")
		AIB.setLabel("Companion","")
		
		AIB.plugins.Companion.IsCompanionSummoned()

		-- if Companion on, update
		if (AIB.saved.character.Companion.on and AIB.saved.character.Companion.show and not snoozing) then
			local header, value, display = "","",""
		
			-- get data
            local rapportValue = GetActiveCompanionRapport()
            local rapportMax = GetMaximumRapport()
            local rapportMin = GetMinimumRapport()
            local rdr, rdg, rdb = 0, 153 / 255, 102 / 255 -- dislike
            local rmr, rmg, rmb = 157 / 255, 132 / 255, 13 / 255 -- moderate
            local rlr, rlg, rlb = 114 / 255, 35 / 255, 35 / 255 -- like
            local rapportPcValue = rapportValue - rapportMin
            local rapportPcMax = rapportMax - rapportMin
            local percent = math.max(zo_roundToNearest(rapportPcValue / rapportPcMax, 0.01), 0)
            local r, g, b = AIB.plugins.Companion.Gradient(percent, rlr, rlg, rlb, rmr, rmg, rmb, rdr, rdg, rdb)

			-- show Value points
            if (AIB.saved.character.Companion.showPercent) then
                display = percent.."%"
            else
                if (AIB.saved.character.Companion.showValue) then
                    if (AIB.saved.character.Companion.showTotal) then
                        display = rapportValue.."|r/"..rapportMax
                    else
                        display = rapportValue
                    end
                end
			end
			
			-- set header
			header = AIB.setHeader("Companion", false, false)
			
            -- set value
            value = AIB.setValue(display, false, false)
									
			-- set label
			AIB.setLabel("Companion", header..value)	
			
			-- set color
			AIB.setLabelColor("Companion", r, g, b, 1)
		end
    end,

	------------------------------------------------
	-- METHOD: Is the companion summoned?
	------------------------------------------------
	IsCompanionSummoned = function()
		if (HasActiveCompanion()) then
			AIB.saved.character.Companion.show = true
		else
			AIB.saved.character.Companion.show = false
		end
	end,
    
	------------------------------------------------
	-- METHOD: Gradient
	------------------------------------------------
    Gradient = function(perc, ...)
        if perc >= 1 then
            local r, g, b = select(select("#", ...) - 2, ...)
            return r, g, b
        elseif perc <= 0 then
            local r, g, b = ...
            return r, g, b
        end

        local num = select("#", ...) / 3

        local segment, relperc = math.modf(perc * (num - 1))
        local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

        return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
    end
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AIB.plugins.Companion.Menu = {	
	{
		type = "submenu",
		name = AIB.icons.Companion..AIB.colors.blue.."Companion Rapport|r",
		controls = {
			{
				type = "description",
				text = AIB.colors.orange.."Displays Companion points. These settings are per character.|r",
			},
			{   
				type = "checkbox", 
				name = "Enabled", 
				tooltip = "Enables this plugin when checked", 
				getFunc = function() return AIB.saved.character.Companion.on end, 
				setFunc = function(newValue) AIB.saved.character.Companion.on = newValue; AIB.plugins.Companion.UpdateCompanion() end, 
				default = AIB.defaults.Companion.on, 
			},
			{   
				type = "checkbox", 
				name = "Show percent", 
				tooltip = "Displays percentage of rapport gained", 
				getFunc = function() return AIB.saved.character.Companion.showPercent end, 
				setFunc = function(newValue) AIB.saved.character.Companion.showPercent = newValue; AIB.plugins.Companion.UpdateCompanion() end, 
				disabled = function() return not(AIB.saved.character.Companion.on) end,
				default = AIB.defaults.Companion.showPercent, 
			},
			{   
				type = "checkbox", 
				name = "Show current rapport value", 
				tooltip = "Display current rapport value", 
				getFunc = function() return AIB.saved.character.Companion.showValue end, 
				setFunc = function(newValue) AIB.saved.character.Companion.showValue = newValue; AIB.plugins.Companion.UpdateCompanion() end, 
				disabled = function() return not(AIB.saved.character.Companion.on) end,
				default = AIB.defaults.Companion.showValue, 
			},
			{   
				type = "checkbox", 
				name = "Show total rapport value", 
				tooltip = "Displays total rapport value", 
				getFunc = function() return AIB.saved.character.Companion.showTotal end, 
				setFunc = function(newValue) AIB.saved.character.Companion.showTotal = newValue; AIB.plugins.Companion.UpdateCompanion() end, 
				disabled = function() return not(AIB.saved.character.Companion.on) end,
				default = AIB.defaults.Companion.showTotal, 
			}
		}
	}
}