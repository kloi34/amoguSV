-- amoguSV v1.0 (29 June 2021)
-- by kloi34

-- Many SV tool ideas and/or code snippets were stolen, and im also planning to steal more that I
-- have yet to implement, so here is credit to the SV plugins and the creators behind them:
--    iceSV       (by IceDynamix)         @ https://github.com/IceDynamix/iceSV
--    KeepStill   (by Illuminati-CRAZ)    @ https://github.com/Illuminati-CRAZ/KeepStill
--    Vibrato     (by Illuminati-CRAZ)    @ https://github.com/Illuminati-CRAZ/Vibrato

---------------------------------------------------------------------------------------------------
-- Plugin Info
---------------------------------------------------------------------------------------------------

-- This is an SV plugin for Quaver, the ultimate community-driven and open-source competitive
-- rhythm game. The plugin contains various tools for editing SVs quickly and efficiently.
-- It's most similar to (i.e. 50% of SV features and code stolen from) iceSV.

-- Things that still need working on/fixing:
--      1. Make first time usability better / make plugin and plugin widgets for new-user more
--         understandable in what they do/when to use them. Basically user-friendly upgrading.
--      2. Cubic bezier. The implementation and code is copied directly from iceSV, but it is
--         computationally inefficient in the usage context of my plugin
--      3. Reducing redundancies in code (ex. addTeleport across 'calculate___SV' functions is
--         nearly identical)
--      4. Remove "Normal" end SV options for stutter and cubic bezier

--  Optional things that I maybe want to add later
--      1. Dedicated KeepStill+more SV tool 
--      2. Dedicated Vibrato+more SV tool 
--      3. Option to skip placing SVs between every other note (or every third note, etc.)
--      4. ?? Note animation by choosing which still frames to telport to ??
--      5. A "presets" tool that can place reverse-scroll svs, bounce svs, etc.
--      6. linearly spaced random svs that normalize to 1.00x?
--      7. hyperbolic sv 5head, or any common function studied in school like quadratic
--      8. dampened harmonic motion svs 5head
--      9. steal iceSV sv multiplier tool? and also steal svs range tool to copy paste svs?
--      10. steal iceSV bezier parse
--      11. make graphs in imgui to show the svs that are about to get placed 

-- ** code side note **
-- The 'Global Constants' section is located at the bottom of the code instead of here at the top
-- because one of the constants uses references to functions; only after the functions are declared
-- can the constant be declared with references to those functions. Including this constant reduces
-- redundancies and increases future code maintainability.

---------------------------------------------------------------------------------------------------
-- Plugin Menus and GUI
---------------------------------------------------------------------------------------------------

-- Creates the plugin window
function draw()
    applyStyle()
    mainMenu()
end
-- Configures GUI visual settings
function applyStyle()
    -- Plugin Styles
    local rounding = 5
    
    imgui.PushStyleVar( imgui_style_var.WindowPadding,      { 8, 8 } )
    imgui.PushStyleVar( imgui_style_var.FramePadding,       { 8, 5 } )
    imgui.PushStyleVar( imgui_style_var.ItemSpacing,        { DEFAULT_WIDGET_HEIGHT / 2 - 1, 4 } )
    imgui.PushStyleVar( imgui_style_var.ItemInnerSpacing,   { SAMELINE_SPACING, 6 } )
    imgui.PushStyleVar( imgui_style_var.WindowBorderSize,   0        )
    imgui.PushStyleVar( imgui_style_var.WindowRounding,     rounding )
    imgui.PushStyleVar( imgui_style_var.ChildRounding,      rounding )
    imgui.PushStyleVar( imgui_style_var.FrameRounding,      rounding )
    
    -- Plugin Colors
    imgui.PushStyleColor( imgui_col.Button,                 { 0.35, 0.36, 0.37, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          { 0.45, 0.46, 0.47, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonActive,           { 0.60, 0.61, 0.62, 1.00 } )
end
-- Creates the main plugin menu
function mainMenu()
    imgui.Begin("amoguSV", imgui_window_flags.AlwaysAutoResize)
    local menuID = "main"
    local vars = {
        hovered = {false, false, false},
        optionNum = 1
    }
    retrieveStateVariables(menuID, vars)
    
    local indentVal = 84 - imgui.CalcTextSize("Tool Options")[1]
    imgui.Indent(indentVal)
    imgui.Text("Tool Options")
    imgui.Unindent(indentVal)
    imgui.SameLine(0, 40)
    local menuTitle = sandwichStrings(TOOL_OPTIONS[vars.optionNum].." SV", "         ")
    imgui.Text(sandwichStrings(menuTitle, EMOTICONS[vars.optionNum]))
    separator()
    
    imgui.BeginChild("SV Tool Options", {100, #TOOL_OPTIONS * 18 + 13}, true)
    for i = 1, #TOOL_OPTIONS do
        if imgui.Selectable(TOOL_OPTIONS[i], vars.optionNum == i) then
            vars.optionNum = i
        end
    end
    vars.hovered[1] = imgui.IsWindowHovered()
    imgui.EndChild()
    
    imgui.SameLine(0, 20)
    imgui.BeginChild("SV Menu", {300, 400}, false)
    MENUS[vars.optionNum](TOOL_OPTIONS[vars.optionNum])
    vars.hovered[2] = imgui.IsWindowHovered()
    imgui.EndChild()
    
    saveStateVariables(menuID, vars)
    vars.hovered[3] = imgui.IsWindowHovered()
    state.IsWindowHovered = vars.hovered[1] or vars.hovered[2] or vars.hovered[3]
    imgui.End()
end
-- Creates the "Linear SV" menu
-- Parameters
--    menuID : name of the menu [String]
function linearMenu(menuID)
    local vars = {
        startSV = 2,
        endSV = 0,
        endSVOption = 1,
        svPoints = 16,
        interlace = false,
        interlaceStartSV = -1,
        interlaceEndSV = 0,
        addTeleport = false,
        veryStartTeleport = false,
        teleportValue = 10000,
        teleportDuration = 1.000
    }
    retrieveStateVariables(menuID, vars)
    
    local halfWidgetWidth = (DEFAULT_WIDGET_WIDTH - SAMELINE_SPACING) / 2
    imgui.PushItemWidth(halfWidgetWidth - imgui.CalcTextSize(" ")[1] / 2)
    _, vars.startSV = imgui.DragFloat("", vars.startSV, 0.01, -MAX_GENERAL_SV, MAX_GENERAL_SV,
                                      "%.2fx")
    vars.startSV = mathClamp(vars.startSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    imgui.SameLine(0, SAMELINE_SPACING + imgui.CalcTextSize(" ")[1])
    _, vars.endSV = imgui.DragFloat("Start/End SV", vars.endSV, 0.01, -MAX_GENERAL_SV,
                                    MAX_GENERAL_SV, "%.2fx")
    vars.endSV = mathClamp(vars.endSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    if imgui.Button(" Swap End and Start ", {DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT}) then
        local temp = vars.startSV
        vars.startSV = vars.endSV
        vars.endSV = temp
    end
    imgui.PopItemWidth()
    spacing()
    
    chooseSVPoints(vars)
    chooseEndSV(vars)
    
    _, vars.interlace = imgui.Checkbox("Interlace with different linear", vars.interlace)
    if vars.interlace then
        spacing()
        imgui.PushItemWidth(halfWidgetWidth - imgui.CalcTextSize(" ")[1] / 2)
        _, vars.interlaceStartSV = imgui.DragFloat(" ", vars.interlaceStartSV, 0.01,
                                                   -MAX_GENERAL_SV, MAX_GENERAL_SV, "%.2fx")
        vars.interlaceStartSV = mathClamp(vars.interlaceStartSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
        imgui.SameLine(0, 0)
        _, vars.interlaceEndSV = imgui.DragFloat(" Start/End SV ", vars.interlaceEndSV, 0.01,
                                                 -MAX_GENERAL_SV, MAX_GENERAL_SV, "%.2fx")
        vars.interlaceEndSV = mathClamp(vars.interlaceEndSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
        if imgui.Button("Swap End and Start", {DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT}) then
            local temp = vars.interlaceStartSV
            vars.interlaceStartSV = vars.interlaceEndSV
            vars.interlaceEndSV = temp
        end
        imgui.PopItemWidth()
        spacing()
    end
    separator()
    
    chooseTeleportSV(vars, menuID)
       
    if imgui.Button("Place SVs Between Selected Notes", {1.5 * DEFAULT_WIDGET_WIDTH - 25,
                    1.5 * DEFAULT_WIDGET_HEIGHT}) then
        local SVs = calculateLinearSV(vars.startSV, vars.endSV, vars.svPoints, vars.endSVOption,
                                      vars.interlace, vars.interlaceStartSV, vars.interlaceEndSV,
                                      vars.addTeleport, vars.veryStartTeleport, vars.teleportValue,
                                      vars.teleportDuration)
        if #SVs > 0 then
            actions.PlaceScrollVelocityBatch(SVs)
        end
    end
    spacing()
    saveStateVariables(menuID, vars)
end
-- Creates the "Exponential SV" menu
-- Parameters
--    menuID : name of the menu [String]
function exponentialMenu(menuID)
    local vars = {
        exponentialIncrease = false,
        svPoints = 16,
        avgSV = 1,
        intensity = 3,
        endSVOption = 1,
        interlace = false,
        interlaceMultiplier = -0.5,
        addTeleport = false,
        veryStartTeleport = false,
        teleportValue = 10000,
        teleportDuration = 1.000
    }
    retrieveStateVariables(menuID, vars)
    imgui.Text("Exponential type:")
    spacing()
    if imgui.RadioButton("Increase (speed up)", vars.exponentialIncrease) then
        vars.exponentialIncrease = true
    end
    imgui.SameLine(0, 3 * SAMELINE_SPACING)
    if imgui.RadioButton("Decay (slow down)", not vars.exponentialIncrease) then
        vars.exponentialIncrease = false
    end
    separator()
    imgui.Text("Exponential sharpness")
    spacing()
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
     _, vars.intensity = imgui.SliderFloat("Intensity", vars.intensity, 1, 10, "%.2f")
    vars.intensity = mathClamp(vars.intensity, 1, 10)
    imgui.PopItemWidth()
    separator()
    
    chooseAverageSV(vars)
    chooseSVPoints(vars)
    chooseEndSV(vars)
    chooseInterlaceMultiplier(vars, menuID)
    chooseTeleportSV(vars, menuID)
    
    if imgui.Button("Place SVs Between Selected Notes", {1.5 * DEFAULT_WIDGET_WIDTH - 25,
                    1.5 * DEFAULT_WIDGET_HEIGHT}) then
        local SVs = calculateExponentialSV(vars.exponentialIncrease, vars.svPoints, vars.avgSV,
                                           vars.intensity, vars.endSVOption, vars.interlace,
                                           vars.interlaceMultiplier, vars.addTeleport,
                                           vars.veryStartTeleport, vars.teleportValue,
                                           vars.teleportDuration)
        if #SVs > 0 then
            actions.PlaceScrollVelocityBatch(SVs)
        end
    end
    saveStateVariables(menuID, vars)
end
-- Creates the "Stutter SV" menu
-- Parameters
--    menuID : name of the menu [String]
function stutterMenu(menuID)
    local vars = {
        startSV = 1.5,
        svDuration = 0.5,
        avgSV = 1,
        endSVOption = 1,
        linearStutter = false,
        linearEndStutterSV = 2,
        linearEndAvgSV = 1,
        linearEndDuration = 0.5
    }
    retrieveStateVariables(menuID, vars)
    
    _, vars.startSV = imgui.DragFloat("Stutter start SV", vars.startSV, 0.01, -MAX_GENERAL_SV,
                                      MAX_GENERAL_SV, "%.2fx")
    vars.startSV = mathClamp(vars.startSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    _, vars.svDuration = imgui.SliderFloat("Duration", vars.svDuration, 0.01, 0.99, "%.2f")
    vars.svDuration = mathClamp(vars.svDuration, 0.01, 0.99)
    spacing()
    
    chooseAverageSV(vars)
    chooseEndSV(vars)
    
    _, vars.linearStutter = imgui.Checkbox("Change stutter linearly over time", vars.linearStutter)
    if vars.linearStutter then
        spacing()
        imgui.Text("Linearly end at:")
        spacing()
        
        _, vars.linearEndStutterSV = imgui.DragFloat("Stutter start SV ", vars.linearEndStutterSV,
                                                     0.01, -MAX_GENERAL_SV, MAX_GENERAL_SV,
                                                     "%.2fx")
        vars.linearEndStutterSV = mathClamp(vars.linearEndStutterSV, -MAX_GENERAL_SV,
                                            MAX_GENERAL_SV)
        _, vars.linearEndDuration = imgui.SliderFloat("Duration ", vars.linearEndDuration,
                                                      0.01, 0.99, "%.2f")
        vars.linearEndDuration = mathClamp(vars.linearEndDuration, 0.01, 0.99)
        spacing()
        _, vars.linearEndAvgSV = imgui.DragFloat("Average SV ", vars.linearEndAvgSV, 0.01,
                                                 -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE, "%.2fx")
        vars.linearEndAvgSV = mathClamp(vars.linearEndAvgSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    end
    separator()
    
    if imgui.Button("Place SVs Between Selected Notes", {1.5 * DEFAULT_WIDGET_WIDTH - 25,
                    1.5 * DEFAULT_WIDGET_HEIGHT}) then
        local SVs = calculateStutterSV(vars.startSV, vars.svDuration, vars.avgSV, vars.endSVOption,
                                       vars.linearStutter, vars.linearEndStutterSV,
                                       vars.linearEndDuration, vars.linearEndAvgSV)
        if #SVs > 0 then
            actions.PlaceScrollVelocityBatch(SVs)
        end
    end
    saveStateVariables(menuID, vars)
end
-- Creates the "Bezier SV" menu
-- Parameters
--    menuID : name of the menu [String]
function bezierMenu(menuID)
    local vars = {
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 1,
        svPoints = 16,
        avgSV = 1,
        endSVOption = 1,
        interlace = false,
        interlaceMultiplier = -0.5,
        addTeleport = false,
        veryStartTeleport = false,
        teleportValue = 10000,
        teleportDuration = 1.000
    }
    retrieveStateVariables(menuID, vars)
    
    imgui.Text("Cubic Bezier Parameters:")
    spacing()
    local coords = {vars.x1, vars.y1, vars.x2, vars.y2}
    _, coords = imgui.DragFloat4("x1, y1, x2, y2", coords, 0.01, -1, 2, "%.2f")
    vars.y2, vars.x1, vars.y1, vars.x2 = table.unpack(coords)
    vars.x1 = mathClamp(vars.x1, 0, 1)
    vars.y1 = mathClamp(vars.y1, -1, 2)
    vars.x2 = mathClamp(vars.x2, 0, 1)
    vars.y2 = mathClamp(vars.y2, -1, 2)
    separator()
    
    chooseAverageSV(vars)
    chooseSVPoints(vars)
    chooseEndSV(vars)
    chooseInterlaceMultiplier(vars, menuID)
    chooseTeleportSV(vars, menuID)
    
    if imgui.Button("Place SVs Between Selected Notes", {1.5 * DEFAULT_WIDGET_WIDTH - 25,
                    1.5 * DEFAULT_WIDGET_HEIGHT}) then
        local SVs = calculateBezierSV(vars.x1, vars.y1, vars.x2, vars.y2, vars.svPoints,
                                      vars.avgSV, vars.endSVOption, vars.interlace,
                                      vars.interlaceMultiplier, vars.addTeleport,
                                      vars.veryStartTeleport, vars.teleportValue,
                                      vars.teleportDuration)
        if #SVs > 0 then
            actions.PlaceScrollVelocityBatch(SVs)
        end
    end
    saveStateVariables(menuID, vars)
end
-- Creates the "Sinusoidal SV" menu
-- Parameters
--    menuID : name of the menu [String]
function sinusoidalMenu(menuID)
    local vars = {
        startAmplitude = 2,
        endAmplitude = 2,
        periods = 0.25,
        shiftPeriods = 0,
        svsPerQuarterPeriod = 8,
        endSVOption = 1,
        addTeleport = false,
        veryStartTeleport = false,
        teleportValue = 10000,
        teleportDuration = 1.000
    }
    retrieveStateVariables(menuID, vars)
    
    imgui.Text("Wave Amplitude:")
    spacing()
    _, vars.startAmplitude = imgui.DragFloat("Start", vars.startAmplitude, 0.01,
                                             -MAX_GENERAL_SV, MAX_GENERAL_SV, "%.2f")
    vars.startAmplitude = mathClamp(vars.startAmplitude, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    _, vars.endAmplitude = imgui.DragFloat("End", vars.endAmplitude, 0.01,
                                           -MAX_GENERAL_SV, MAX_GENERAL_SV, "%.2f")
    vars.endAmplitude = mathClamp(vars.endAmplitude, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    separator()
    
    _, vars.periods = imgui.InputFloat("Periods/Cycles", vars.periods, 0.25, 0.25, "%.2f")
    vars.periods = forceQuarter(vars.periods)
    vars.periods = mathClamp(vars.periods, 0.25, 20)
    
    local text = "Shift start by "
    imgui.AlignTextToFramePadding()
    imgui.Text(text)
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH - imgui.CalcTextSize(text)[1] - 2 * SAMELINE_SPACING)
    _, vars.shiftPeriods = imgui.InputFloat("Periods/Cycles ", vars.shiftPeriods, 0.25, 0.25,
                                            "%.2f")
    vars.shiftPeriods = forceQuarter(vars.shiftPeriods)
    vars.shiftPeriods = mathClamp(vars.shiftPeriods, 0, 0.75)
    imgui.PopItemWidth()
    spacing()
    
    imgui.Text("SV points per quarter period/cycle")
    spacing()
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    _, vars.svsPerQuarterPeriod = imgui.InputInt(" ", vars.svsPerQuarterPeriod)
    vars.svsPerQuarterPeriod = mathClamp(vars.svsPerQuarterPeriod, 1, 50)
    imgui.PopItemWidth()
    separator()
    
    chooseEndSV(vars)
    chooseTeleportSV(vars, menuID)
    
    if imgui.Button("Place SVs Between Selected Notes", {1.5 * DEFAULT_WIDGET_WIDTH - 25,
                    1.5 * DEFAULT_WIDGET_HEIGHT}) then
        local SVs = calculateSinusoidalSV(vars.startAmplitude, vars.endAmplitude, vars.periods,
                                          vars.shiftPeriods, vars.svsPerQuarterPeriod,
                                          vars.endSVOption, vars.addTeleport,
                                          vars.veryStartTeleport, vars.teleportValue,
                                          vars.teleportDuration)
        if #SVs > 0 then
            actions.PlaceScrollVelocityBatch(SVs)
        end
    end
    saveStateVariables(menuID, vars)
end
-- Creates the "Single SV" menu
-- Parameters
--    menuID : name of the menu [String]
function singleMenu(menuID)
    local vars = {
        skipSVAtNote = false,
        svBefore = false,
        svValueBefore = 0,
        incrementBefore = 0.125,
        svAfter = false,
        svValueAfter = 0,
        incrementAfter = 0.125,
        svValue = 1,
        scaleSVLinearly = false,
        svValueBeforeEnd = 0,
        svValueEnd = 1,
        svValueAfterEnd = 0
    }
    retrieveStateVariables(menuID, vars)
    
    _, vars.svBefore = imgui.Checkbox("Add SV before note", vars.svBefore)
    _, vars.svAfter = imgui.Checkbox("Add SV after note", vars.svAfter)
    spacing()
    _, vars.skipSVAtNote = imgui.Checkbox("Skip SV at note", vars.skipSVAtNote)
    separator()
    
    if vars.svBefore then
        _, vars.svValueBefore = imgui.DragFloat("SV before note ", vars.svValueBefore, 0.01,
                                                -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE, "%.2fx")
        vars.svValueBefore = mathClamp(vars.svValueBefore, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        _, vars.incrementBefore = imgui.DragFloat("Time before", vars.incrementBefore, 0.01,
                                                  MIN_DURATION, MAX_DURATION, "%.3f ms")
        vars.incrementBefore = mathClamp(vars.incrementBefore, MIN_DURATION, MAX_DURATION)
    end
    if (not vars.skipSVAtNote) then
        if vars.svBefore then
            spacing()
        end
        _, vars.svValue = imgui.DragFloat("SV at note ", vars.svValue, 0.01, -MAX_TELEPORT_VALUE,
                                          MAX_TELEPORT_VALUE, "%.2fx")
        vars.svValue = mathClamp(vars.svValue, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
    end
    if vars.svAfter then
        if vars.svBefore or (not vars.skipSVAtNote) then
            spacing()
        end
        _, vars.svValueAfter = imgui.DragFloat("SV after note ", vars.svValueAfter, 0.01,
                                               -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE, "%.2fx")
        vars.svValueAfter = mathClamp(vars.svValueAfter, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        _, vars.incrementAfter = imgui.DragFloat("Time after", vars.incrementAfter, 0.01,
                                                 MIN_DURATION, MAX_DURATION, "%.3f ms")
        vars.incrementAfter = mathClamp(vars.incrementAfter, MIN_DURATION, MAX_DURATION)
    end
    
    if vars.svBefore or (not vars.skipSVAtNote) or vars.svAfter then
        separator()
        _, vars.scaleSVLinearly = imgui.Checkbox("Scale SV values linearly over time", vars.scaleSVLinearly)
        if vars.scaleSVLinearly then
            spacing()
            imgui.Text("End values for...")
            spacing()
            if vars.svBefore then
                _, vars.svValueBeforeEnd = imgui.DragFloat("SV before note", vars.svValueBeforeEnd,
                                                           0.01, -MAX_TELEPORT_VALUE,
                                                           MAX_TELEPORT_VALUE, "%.2fx")
                vars.svValueBeforeEnd = mathClamp(vars.svValueBeforeEnd, -MAX_TELEPORT_VALUE,
                                                  MAX_TELEPORT_VALUE)
            end
            if (not vars.skipSVAtNote) then
                if vars.svBefore then
                    spacing()
                end
                _, vars.svValueEnd = imgui.DragFloat("SV at note", vars.svValueEnd, 0.01,
                                                  -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE, "%.2fx")
                vars.svValueEnd = mathClamp(vars.svValueEnd, -MAX_TELEPORT_VALUE,
                                            MAX_TELEPORT_VALUE)
            end
            if vars.svAfter then
                if vars.svBefore or (not vars.skipSVAtNote) then
                    spacing()
                end
                _, vars.svValueAfterEnd = imgui.DragFloat("SV after note", vars.svValueAfterEnd,
                                                          0.01, -MAX_TELEPORT_VALUE,
                                                          MAX_TELEPORT_VALUE, "%.2fx")
                vars.svValueAfterEnd = mathClamp(vars.svValueAfterEnd, -MAX_TELEPORT_VALUE,
                                                 MAX_TELEPORT_VALUE)
            end
        end
        separator()
        if imgui.Button("Place SVs At Selected Notes", {1.5 * DEFAULT_WIDGET_WIDTH - 25,
                        1.5 * DEFAULT_WIDGET_HEIGHT}) then
            local SVs = calculateSingleSV(vars.skipSVAtNote, vars.svBefore, vars.svValueBefore,
                                          vars.incrementBefore, vars.svAfter, vars.svValueAfter,
                                          vars.incrementAfter, vars.svValue, vars.scaleSVLinearly,
                                          vars.svValueBeforeEnd, vars.svValueEnd,
                                          vars.svValueAfterEnd)
            if #SVs > 0 then
                actions.PlaceScrollVelocityBatch(SVs)
            end
        end
    end
    saveStateVariables(menuID, vars)
end
-- Creates the "Remove SV" menu
-- Parameters
--    menuID : name of the menu [String]
function removeMenu(menuID)
    local vars = {
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    
    imgui.AlignTextToFramePadding()
    imgui.Text("From") 
    imgui.SameLine(0, 2 * SAMELINE_SPACING + (30 - imgui.CalcTextSize("From")[1]))
    if imgui.Button("Current", {0.3 * DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT}) then
        vars.startOffset = state.SongTime
    end
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(0.7 * DEFAULT_WIDGET_WIDTH)
    _, vars.startOffset = imgui.InputInt("(Start)", vars.startOffset)
    imgui.PopItemWidth()
    
    imgui.AlignTextToFramePadding()
    imgui.Text("To")
    imgui.SameLine(0, 2 * SAMELINE_SPACING + (30 - imgui.CalcTextSize("To")[1]))
    if imgui.Button(" Current" , {0.3 * DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT}) then
        vars.endOffset = state.SongTime
    end
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(0.7 * DEFAULT_WIDGET_WIDTH)
    _, vars.endOffset = imgui.InputInt("(End)", vars.endOffset)
    imgui.PopItemWidth()
    separator()
    
    if imgui.Button("Remove SVs", {1.5 * DEFAULT_WIDGET_WIDTH - 25,
                    1.5 * DEFAULT_WIDGET_HEIGHT}) then
        local svsToRemove = {}
        for i, sv in pairs(map.ScrollVelocities) do
            if sv.StartTime >= vars.startOffset and sv.StartTime <= vars.endOffset then
                table.insert(svsToRemove, sv)
            end
        end
        if #svsToRemove > 0 then
            actions.RemoveScrollVelocityBatch(svsToRemove)
        end
    end
    saveStateVariables(menuID, vars)
end

---------------------------------------------------------------------------------------------------
-- Calculation/helper functions
---------------------------------------------------------------------------------------------------

-- Retrieves variables from the state
-- Parameters
--    menuID    : name of the menu that the variables are from [String]
--    variables : table of variables and values [Table]
function retrieveStateVariables(menuID, variables)
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(menuID..key) or value
    end
end
-- Saves variables to the state
-- Parameters
--    menuID    : name of the menu that the variables are from [String]
--    variables : table of variables and values [Table]
function saveStateVariables(menuID, variables)
    for key, value in pairs(variables) do
        state.SetValue(menuID..key, value)
    end
end
-- Adds vertical blank space on the GUI
function spacing()
    imgui.Dummy({0,5})
end
-- Adds a horizontal line separator on the GUI
function separator()
    spacing()
    imgui.Separator()
    spacing()
end
-- Calculates all linear SVs to place
-- Returns a list of all calculated linear SVs [Table]
-- Parameters
--    startSV           : starting value of the linear SV [Int/Float] 
--    endSV             : ending value of the linear SV [Int/Float] 
--    svPoints          : number of SVs to place (excluding the very last SV) [Int]
--    endSVOption       : option number for the last SV (based on constant END_SV_TYPES) [Int]
--    interlace         : whether or not to interlace another linear SV [Boolean]
--    interlaceStartSV  : starting value of the interlaced linear SV [Int/Float] 
--    interlaceEndSV    : ending value of the interlaced linear SV [Int/Float] 
--    addTeleport       : whether or not to add a teleport SV [Boolean]
--    veryStartTeleport : whether or not the teleport SV is only at the very start [Boolean]
--    teleportValue     : value of the teleport SV [Int/Float] 
--    teleportDuration  : duration of the teleport SV in milliseconds [Int/Float] 
function calculateLinearSV(startSV, endSV, svPoints, endSVOption, interlace, interlaceStartSV,
                           interlaceEndSV, addTeleport, veryStartTeleport, teleportValue,
                           teleportDuration)
    local offsets = uniqueSelectedNoteOffsets()
    local SVs = {}
    for i = 1, #offsets - 1 do
        local startOffset = offsets[i]
        if addTeleport then
            -- if we want a teleport for each linear or we are at the very start
            if (not veryStartTeleport) or i == 1 then
                table.insert(SVs, utils.CreateScrollVelocity(startOffset, teleportValue))
                startOffset = startOffset + teleportDuration
            end
        end
        local endOffset = offsets[i + 1]
        local timeInterval = (endOffset - startOffset) / svPoints
        local svIncrement = (endSV - startSV) / svPoints
        local linearSVs = {}
        local thisEndSVOption = getThisEndSVOption(i == #offsets - 1, endSVOption)
        linearSVs = generateLinearSV(startOffset, timeInterval, startSV, svIncrement, svPoints,
                                     thisEndSVOption)
        for j = 1, #linearSVs do
            table.insert(SVs, linearSVs[j])
        end
        
        if interlace then
            local interlaceSVInterval = (interlaceEndSV - interlaceStartSV) / svPoints
            startOffset = startOffset + (timeInterval * 0.5)
            local interlaceSVs = generateLinearSV(startOffset, timeInterval, interlaceStartSV,
                                                  interlaceSVInterval, svPoints, 2)
            for j = 1, #interlaceSVs do
                table.insert(SVs, interlaceSVs[j])
            end
        end
    end
    return SVs
end
-- Calculates a single set of linear SVs
-- Returns the set of linear SVs [Table]
-- Parameters
--    startOffset  : start time of the linear SVs [Int]
--    timeInterval : time in-between each consecutive SV [Int/Float]
--    startSV      : starting value of the first SV [Int/Float]
--    svIncrement  : change in SV value for each consecutive SV [Int/Float]
--    svPoints     : number of SVs to place (excluding the very last SV) [Int]
--    endSVOption  : option number for the last SV (based on constant END_SV_TYPES) [Int]
function generateLinearSV(startOffset, timeInterval, startSV, svIncrement, svPoints, endSVOption)
    local SVs = {}
    for step = 0, svPoints do
        local offset = step * timeInterval + startOffset 
        local velocity = step * svIncrement + startSV
        if step == svPoints then
            velocity = endSVValue(velocity, endSVOption)
        end
        if velocity ~= nil then
            table.insert(SVs, utils.CreateScrollVelocity(offset, velocity))
        end
    end
    return SVs
end
-- Calculates all exponential SVs to place
-- Returns a list of all calculated exponential SVs [Table]
-- Parameters
--    exponentialIncrease : whether or not the SVs will be exponentially increasing [Boolean]
--    svPoints            : number of SVs to place (excluding the very last SV) [Int]
--    avgSV               : intended average SV [Int/Float]
--    intensity           : how sharp/rapid the exponential increase/decrease will be [Int/Float]
--    endSVOption         : option number for the last SV (based on constant END_SV_TYPES) [Int]
--    interlace           : whether or not to interlace another linear SV [Boolean]
--    interlaceMultiplier : multiplier/ratio of the interlaced exponential SV [Int/Float] 
--    addTeleport         : whether or not to add a teleport SV [Boolean]
--    veryStartTeleport   : whether or not the teleport SV is only at the very start [Boolean]
--    teleportValue       : value of the teleport SV [Int/Float] 
--    teleportDuration    : duration of the teleport SV in milliseconds [Int/Float] 
function calculateExponentialSV(exponentialIncrease, svPoints, avgSV, intensity, endSVOption,
                                interlace, interlaceMultiplier, addTeleport, veryStartTeleport,
                                teleportValue, teleportDuration)
    local offsets = uniqueSelectedNoteOffsets()
    local SVs = {}
    for i = 1, #offsets - 1 do
        local startOffset = offsets[i]
        if addTeleport then
            -- if we want a teleport for each exponential or we are at the very start
            if (not veryStartTeleport) or i == 1 then
                table.insert(SVs, utils.CreateScrollVelocity(startOffset, teleportValue))
                startOffset = startOffset + teleportDuration
            end
        end
        local endOffset = offsets[i + 1]
        local timeInterval = (endOffset - startOffset) / svPoints
        local exponentialSVs = {}
        local thisEndSVOption = getThisEndSVOption(i == #offsets - 1, endSVOption)
        exponentialSVs = generateExponentialSV(exponentialIncrease, startOffset, timeInterval,
                                               svPoints, avgSV, intensity, thisEndSVOption)
        for j = 1, #exponentialSVs do
            table.insert(SVs, exponentialSVs[j])
        end
        
        local interlaceSVs = {}
        if interlace then
            startOffset = startOffset + (0.5 * timeInterval)
            local tempAvgSV = avgSV * interlaceMultiplier
            interlaceSVs = generateExponentialSV(exponentialIncrease, startOffset, timeInterval,
                                                 svPoints, tempAvgSV, intensity, 2)
        end
        for j = 1, #interlaceSVs do
            table.insert(SVs, interlaceSVs[j])
        end
    end
    return SVs
end
-- Calculates a single set of exponential SVs
-- Returns the set of exponential SVs [Table]
-- Parameters
--    exponentialIncrease : whether or not the SVs will be exponentially increasing [Boolean]
--    startOffset         : start time of the exponential SVs [Int]
--    timeInterval        : time in-between each consecutive SV [Int/Float]
--    svPoints            : number of SVs to place (excluding the very last SV) [Int]
--    avgSV               : intended average SV [Int/Float]
--    intensity           : how sharp/rapid the exponential increase/decrease will be [Int/Float]
--    endSVOption         : option number for the last SV (based on constant END_SV_TYPES) [Int]
function generateExponentialSV(exponentialIncrease, startOffset, timeInterval, svPoints, avgSV,
                               intensity, endSVOption)
    local SVs = {}
    local svValues = {}
    local xIncrement = 1 / svPoints
    
    -- calculates expected exponential SV values
    for step = 0, svPoints do
        local x = (step + 0.5) * xIncrement * intensity
        local velocity = (math.exp(x) / math.exp(1)) / intensity
        table.insert(svValues, velocity)
    end
    
    -- calculate the "total SV" to use to find the average of the expected exponential SV.
    local svTotal = 0
    for i = 1, svPoints do
        svTotal = svTotal + svValues[i]
    end
    local actualSVAverage = svTotal / svPoints
    
    -- correct each expected SV value so that the SVs altogether achieves the user-inputted average
    for i = 1, #svValues do
        svValues[i] = (svValues[i] * avgSV) / actualSVAverage
    end
    
    for step = 0, svPoints do
        local offset = step * timeInterval + startOffset
        local velocity = svValues[step + 1]
        if (not exponentialIncrease) then
            if svPoints ~= step then
                velocity = svValues[svPoints - step]
            else
                velocity = (math.exp(-0.5 * xIncrement * intensity) / math.exp(1)) / intensity
            end
        end
        if step == svPoints then
            velocity = endSVValue(velocity, endSVOption)
        end
        if velocity ~= nil then
            table.insert(SVs, utils.CreateScrollVelocity(offset, velocity))
        end
    end
    return SVs
end
-- Calculates all stutter SVs to place
-- Returns a list of all calculated stutter SVs [Table]
-- Parameters
--    startSV            : starting value of the first SV in a single stutter [Int/Float]
--    svDuration         : duration (percent) of the first SV in a single stutter [Float]
--    avgSV              : average SV of the stutter [Int/Float]
--    endSVOption        : option number for the last SV (based on constant END_SV_TYPES) [Int]
--    linearStutter      : whether or not to linearly change the stutter over time [Boolean]
--    linearEndStutterSV : linear end value of the first SV of the last stutter [Int/Float]
--    linearEndDuration  : linear end value of the duration of the last stutter's first SV [Float]
--    linearEndAvgSV     : linear end value of the average SV for the last stutter [Int/Float]
function calculateStutterSV(startSV, svDuration, avgSV, endSVOption, linearStutter,
                            linearEndStutterSV, linearEndDuration, linearEndAvgSV)
    local offsets = uniqueSelectedNoteOffsets()
    local SVs = {}
    local startSVList = {}
    local svDurationList = {}
    local avgSVList = {}
    if linearStutter then
        startSVList = generateLinearSet(startSV, linearEndStutterSV, #offsets - 1)
        svDurationList = generateLinearSet(svDuration, linearEndDuration, #offsets - 1)
        avgSVList = generateLinearSet(avgSV, linearEndAvgSV, #offsets - 1)
    else
        startSVList = generateLinearSet(startSV, startSV, #offsets - 1)
        svDurationList = generateLinearSet(svDuration, svDuration, #offsets - 1)
        avgSVList = generateLinearSet(avgSV, avgSV, #offsets - 1)
    end
    for i = 1, #offsets - 1 do
        local startOffset = offsets[i]
        local endOffset = offsets[i + 1]
        local timeInterval = endOffset - startOffset
        local stutterSVs = generateStutterSV(startOffset, timeInterval, startSVList[i],
                                             svDurationList[i], avgSVList[i])
        for j = 1, #stutterSVs do
            table.insert(SVs, stutterSVs[j])
        end
    end
    if endSVOption ~= 2 then
        table.insert(SVs, utils.CreateScrollVelocity(offsets[#offsets], 1))
    end
    return SVs
end
-- Calculates a single set of stutter SVs
-- Returns the set of stutter SVs [Table]
-- Parameters
--    startOffset  : start time of the stutter SV [Int]
--    timeInterval : total time the stutter effect will last (milliseconds) [Int/Float]
--    startSV      : starting value of the stutter SV [Int/Float]
--    svDuration   : duration (percent) of the first SV in the stutter [Float]
--    avgSV        : average SV of the stutter [Int/Float]
function generateStutterSV(startOffset, timeInterval, startSV, svDuration, avgSV)
    local SVs = {}
    table.insert(SVs, utils.CreateScrollVelocity(startOffset, startSV))
    local stutterOffset = startOffset + svDuration * timeInterval
    local stutterSV = (avgSV - startSV * svDuration) / (1 - svDuration)
    table.insert(SVs, utils.CreateScrollVelocity(stutterOffset, stutterSV))
    return SVs
end
-- Calculates all bezier SVs to place
-- Returns a list of all calculated bezier SVs [Table]
-- Parameters
function calculateBezierSV(x1, y1, x2, y2, svPoints, avgSV, endSVOption, interlace,
                           interlaceMultiplier, addTeleport, veryStartTeleport, teleportValue,
                           teleportDuration)
    local offsets = uniqueSelectedNoteOffsets(svPoints)
    local SVs = {}
    for i = 1, #offsets - 1 do
        local startOffset = offsets[i]
        if addTeleport then
            -- if we want a teleport for each bezier or we are at the very start
            if (not veryStartTeleport) or i == 1 then
                table.insert(SVs, utils.CreateScrollVelocity(startOffset, teleportValue))
                startOffset = startOffset + teleportDuration
            end
        end
        local endOffset = offsets[i + 1]
        --local timeInterval = endOffset - startOffset / svPoints
        --local bezierSVs = generateBezierSV()
        local skipEndSV = true
        local bezierSVs = generateBezierSV(x1, y1, x2, y2, startOffset, endOffset, avgSV, svPoints,
                                          skipEndSV, interlace, interlaceMultiplier)
        for j = 1, #bezierSVs do
            table.insert(SVs, bezierSVs[j])
        end
    end
    --temporary
    if endSVOption ~= 2 then
        table.insert(SVs, utils.CreateScrollVelocity(offsets[#offsets], 1))
    end
    return SVs
end
-- Calculates a single set of bezier SVs
-- Returns the set of bezier SVs [Table]
-- Parameters
--[[function generateBezierSV(x1, y1, x2, y2, startOffset, endOffset, avgSV, svPoints, true)
    local SVs = {}
    return SVs
end
--]]

----***THE 2 FUNCTIONS BELOW RELATED TO BEZIER COPIED DIRECTLY FROM iceSV + SLIGHTLY MODIFIED***
-- Will remake + add comments to the bezier functions once i get a better understanding of beziers
-- As it stands right now, how the function is used is very computationally inefficient
-- when there are 2+ notes. This is because the same bezier sample is calculated
-- and thrown out x - 1 times where x is the number of notes selected to place bezier svs between
-- @return table of scroll velocities
function generateBezierSV(P1_x, P1_y, P2_x, P2_y, startOffset, endOffset, averageSV, intermediatePoints, skipEndSV, interlace,
                           interlaceMultiplier)

    local stepInterval = 1/intermediatePoints
    local timeInterval = (endOffset - startOffset) * stepInterval

    -- the larger this number, the more accurate the final sv is
    -- ... and the longer it's going to take
    local totalSampleSize = 2500
    local allBezierSamples = {}
    
    for t=0, 1, 1/totalSampleSize do
        local x = mathCubicBezier({0, P1_x, P2_x, 1}, t)
        local y = mathCubicBezier({0, P1_y, P2_y, 1}, t)
        table.insert(allBezierSamples, {x=x,y=y})
    end

    local SVs = {}
    local positions = {}

    local currentPoint = 0

    for sampleCounter = 1, totalSampleSize, 1 do
        if allBezierSamples[sampleCounter].x > currentPoint then
            table.insert(positions, allBezierSamples[sampleCounter].y)
            currentPoint = currentPoint + stepInterval
        end
    end

    for i = 2, intermediatePoints, 1 do
        local offset = (i-2) * timeInterval + startOffset
        local velocity = (positions[i] - (positions[i-1] or 0)) * averageSV * intermediatePoints
        velocity = math.floor(velocity * 100 + 0.5) / 100
        SVs[i-1] = utils.CreateScrollVelocity(offset, velocity)
    end

    table.insert(SVs, utils.CreateScrollVelocity((intermediatePoints - 1) * timeInterval + startOffset, SVs[#SVs].Multiplier))
    if interlace then
        local numSVs = #SVs
        for i = 1, numSVs do
            table.insert(SVs, utils.CreateScrollVelocity(SVs[i].StartTime + timeInterval * 0.5, SVs[i].Multiplier * interlaceMultiplier))
        end
    end
    if skipEndSV == false then
        table.insert(SVs, utils.CreateScrollVelocity(endOffset, averageSV))
    end
    
    return SVs
end
function mathCubicBezier(P, t)
    return P[1] + 3*t*(P[2]-P[1]) + 3*t^2*(P[1]+P[3]-2*P[2]) + t^3*(P[4]-P[1]+3*P[2]-3*P[3])
end

-- Calculates all sinusoidal SVs to place
-- Returns a list of all calculated sinusoidal SVs [Table]
-- Parameters
--    startAmplitude      : starting amplitude of the sinusoidal wave [Int/Float]
--    endAmplitude        : ending amplitude of the sinusoidal wave [Int/Float]
--    periods             : number of periods/cycles the sinusoidal wave lasts [Int/Float]
--    shiftPeriods        : number of periods/cycles to delay the sinusoidal wave [Int/Float]
--    svsPerQuarterPeriod : number of SVs to place every quarter of a cycle [Int/Float]
--    endSVOption         : option number for the last SV (based on constant END_SV_TYPES) [Int]
--    addTeleport         : whether or not to add a teleport SV [Boolean]
--    veryStartTeleport   : whether or not the teleport SV is only at the very start [Boolean]
--    teleportValue       : value of the teleport SV [Int/Float] 
--    teleportDuration    : duration of the teleport SV in milliseconds [Int/Float] 
function calculateSinusoidalSV(startAmplitude, endAmplitude, periods, shiftPeriods,
                               svsPerQuarterPeriod, endSVOption, addTeleport, veryStartTeleport,
                               teleportValue, teleportDuration)
    local offsets = uniqueSelectedNoteOffsets()
    local SVs = {}
    for i = 1, #offsets - 1 do
        local startOffset = offsets[i]
        if addTeleport then
            -- if we want a teleport for each sinusoidal or we are at the very start
            if (not veryStartTeleport) or i == 1 then
                table.insert(SVs, utils.CreateScrollVelocity(startOffset, teleportValue))
                startOffset = startOffset + teleportDuration
            end
        end
        local endOffset = offsets[i + 1]
        local timeInterval = endOffset - startOffset
        local sinusoidalSVs = {}
        local thisEndSVOption = getThisEndSVOption(i == #offsets - 1, endSVOption)
        sinusoidalSVs = generateSinusoidalSV(startOffset, timeInterval, startAmplitude,
                                             endAmplitude, periods, shiftPeriods,
                                             svsPerQuarterPeriod, thisEndSVOption)
        for j = 1, #sinusoidalSVs do
            table.insert(SVs, sinusoidalSVs[j])
        end
    end
    return SVs
end
-- Calculates a single set of sinusoidal SVs
-- Returns the set of sinusoidal SVs [Table]
-- Parameters
--    startOffset         : start time of the sinusoidal SV [Int]
--    timeInterval        : total time the sinusoidal SV will last (milliseconds) [Int/Float]
--    startAmplitude      : starting amplitude of the sinusoidal wave [Int/Float]
--    endAmplitude        : ending amplitude of the sinusoidal wave [Int/Float]
--    periods             : number of periods/cycles the sinusoidal wave lasts [Int/Float]
--    shiftPeriods        : number of periods/cycles to delay the sinusoidal wave [Int/Float]
--    svsPerQuarterPeriod : number of SVs to place every quarter of a cycle [Int/Float]
--    endSVOption         : option number for the last SV (based on constant END_SV_TYPES) [Int]
function generateSinusoidalSV(startOffset, timeInterval, startAmplitude, endAmplitude, periods,
                              shiftPeriods, svsPerQuarterPeriod, endSVOption)
    local SVs = {}
    local quarterPeriods = 4 * periods
    local quarterShiftPeriods = 4 * shiftPeriods
    local totalSVs = svsPerQuarterPeriod * quarterPeriods
    local amplitudes = generateLinearSet(startAmplitude, endAmplitude, totalSVs + 1)
    local timeIncrement = timeInterval / totalSVs
    for i = 0, totalSVs do
        local offset = startOffset + timeIncrement * i
        local angle = (math.pi / 2) * ((i / svsPerQuarterPeriod) +  quarterShiftPeriods)
        local velocity = amplitudes[i + 1] * math.sin(angle)
        if i == totalSVs then
            velocity = endSVValue(velocity, endSVOption)
        end
        if velocity ~= nil then
            table.insert(SVs, utils.CreateScrollVelocity(offset, velocity))
        end
    end
    return SVs
end
-- Calculates all sinusoidal SVs to place
-- Returns a list of all calculated sinusoidal SVs [Table]
-- Parameters
function calculateSingleSV(skipSVAtNote, svBefore, svValueBefore, incrementBefore, svAfter,
                           svValueAfter, incrementAfter, svValue, scaleSVLinearly,
                           svValueBeforeEnd, svValueEnd, svValueAfterEnd)
    local offsets = uniqueSelectedNoteOffsets()
    local SVs = {}
    local svValuesBefore = {}
    local svValuesAfter = {}
    local svValuesAt = {}
    if scaleSVLinearly then
        svValuesBefore = generateLinearSet(svValueBefore, svValueBeforeEnd, #offsets)
        svValuesAfter = generateLinearSet(svValueAfter, svValueAfterEnd, #offsets)
        svValuesAt = generateLinearSet(svValue, svValueEnd, #offsets)
    else
        svValuesBefore = generateLinearSet(svValueBefore, svValueBefore, #offsets)
        svValuesAfter = generateLinearSet(svValueAfter, svValueAfter, #offsets)
        svValuesAt = generateLinearSet(svValue, svValue, #offsets)
    end
    for i = 1, #offsets do
        if svBefore then
            table.insert(SVs, utils.CreateScrollVelocity(offsets[i] - incrementBefore,
                         svValuesBefore[i]))
        end
        if (not skipSVAtNote) then
             table.insert(SVs, utils.CreateScrollVelocity(offsets[i],  svValuesAt[i]))
        end
        if svAfter then
            table.insert(SVs, utils.CreateScrollVelocity(offsets[i] + incrementAfter,
                         svValuesAfter[i]))
        end
    end
    return SVs
end
-- Returns the value of the last SV for a set of SVs [Int/Float]
-- Parameters
--    velocity    : default/usual SV value for the end SV [Int/Float]
--    endSVOption : option number for the last SV (based on global constant END_SV_TYPES) [Int]
function endSVValue(velocity, endSVOption)
    if endSVOption == 1 then -- normal SV option
        return velocity
    elseif endSVOption == 2 then -- skip SV option
        return nil
    else -- 1.00x SV option
        return 1
    end
end
-- Restricts a number to be within a closed interval
-- Returns the result of the restriction [Int/Float]
-- Parameters
--    x          : number to keep within the interval [Int/Float]
--    lowerBound : lower bound of the interval [Int/Float]
--    upperBound : upper bound of the interval [Int/Float]
function mathClamp(x, lowerBound, upperBound)
    if x < lowerBound then
        return lowerBound
    elseif x > upperBound then
        return upperBound
    else
        return x
    end
end
-- Finds the unique offsets of all currently selected notes
-- Returns a list of all unique offsets in ascending order (of currently selected notes) [Table]
function uniqueSelectedNoteOffsets()
    local offsets = {}
    for i, hitObject in pairs(state.SelectedHitObjects) do
        offsets[i] = hitObject.StartTime
    end
    offsets = uniqueByTime(offsets)
    offsets = table.sort(offsets, function(a, b) return a < b end)
    return offsets
end
-- Takes in a list of offsets and locates offsets that are at a unique time
-- Returns a list only with offsets that are at a unique time [Table]
-- Parameters
--    offsets : list of offsets [Table]
function uniqueByTime(offsets)
    local hash = {}
    -- new list of unique offsets
    local uniqueTimes = {}
    for _, value in ipairs(offsets) do
        -- if the offset is not already in the new list of offsets
        if (not hash[value]) then
            -- add the offset to the new list
            uniqueTimes[#uniqueTimes + 1] = value
            hash[value] = true
        end
    end
    return uniqueTimes
end
-- Concatenates two strings by sandwiching one string between two of another string
-- Returns the result of the concatenated strings [String]
-- Parameters
--    string1 : string to put in the middle [String]
--    string2 : string to add on both sides [String]
function sandwichStrings(string1, string2)
    return string2..string1..string2
end
-- Forces a number to be a multiple of one quarter
-- Returns the forced number [Int/Float]
-- Parameters
--    x : number to force to be a multiple of one quarter [Int/Float]
function forceQuarter(x)
    return (math.floor(x * 4 + 0.5)) / 4
end
-- Returns the end SV option for a given set of SVs [Int]
-- Parameters
--    isVeryEnd   : whether or not the set of SVs is at the very end [Boolean]
--    endSVOption : option number for the last SV (based on constant END_SV_TYPES) [Int]
function getThisEndSVOption(isVeryEnd, endSVOption)
    if isVeryEnd then
        return endSVOption
    end
    return 2
end
-- Generates a linear set of equally-spaced numbers between two numbers (inclusive)
-- Returns the linear set of numbers [Table]
-- Parameters
--    startVal  : starting value of the set [Int/Float]
--    endVal    : ending value of the set [Int/Float]
--    numValues : number of values in the linear set (including the start and end values) [Int]
function generateLinearSet(startVal, endVal, numValues)
    local linearSet = {}
    if numValues > 1 then
        local increment = (endVal - startVal) / (numValues - 1)
        for i = 0, numValues - 1 do
            table.insert(linearSet, startVal + i * increment)
        end
    elseif numValues == 1 then
        table.insert(linearSet, startVal)
    end
    return linearSet
end
-- Lets users choose the average SV
-- Parameters
--    vars : a reference to the variables of a menu [Table]
function chooseAverageSV(vars)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    _, vars.avgSV = imgui.DragFloat("Average SV", vars.avgSV, 0.01, -MAX_TELEPORT_VALUE,
                                    MAX_TELEPORT_VALUE, "%.2fx")    
    vars.avgSV = mathClamp(vars.avgSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    imgui.PopItemWidth()
    spacing()
end
-- Lets users choose the number of SV points to place
-- Parameters
--    vars : a reference to the variables of a menu [Table]
function chooseSVPoints(vars)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    _, vars.svPoints = imgui.InputInt("SV points", vars.svPoints)
    vars.svPoints = mathClamp(vars.svPoints, 1, 256)
    imgui.PopItemWidth()
    separator()
end
-- Lets users choose the end SV type
-- Parameters
--    vars : a reference to the variables of a menu [Table]
function chooseEndSV(vars)
    imgui.Text("Very last SV:")
    spacing()
    for i = 1, #END_SV_TYPES do
        _, vars.endSVOption = imgui.RadioButton(END_SV_TYPES[i], vars.endSVOption, i)
        if i ~= #END_SV_TYPES then
            imgui.SameLine(0, 3 * SAMELINE_SPACING)
        end
    end
    separator()
end
-- Lets users choose and adjust teleport SV options
-- Parameters
--    vars   : a reference to the variables of a menu [Table]
--    menuID : name of the menu of the variables [String]
function chooseTeleportSV(vars, menuID)
    _, vars.addTeleport = imgui.Checkbox("Add teleport SV at start", vars.addTeleport)
    if vars.addTeleport then
        spacing()
        if imgui.RadioButton("Only very start", vars.veryStartTeleport) then
            vars.veryStartTeleport = true
        end
        imgui.SameLine(0, 3 * SAMELINE_SPACING)
        if imgui.RadioButton("Every "..string.lower(menuID).." start",
                             not vars.veryStartTeleport) then
            vars.veryStartTeleport = false
        end
        spacing()
        _, vars.teleportValue = imgui.DragFloat("Teleport SV", vars.teleportValue, 0.01,
                                                -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE, "%.2fx")
        vars.teleportValue = mathClamp(vars.teleportValue, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        _, vars.teleportDuration = imgui.DragFloat("Duration", vars.teleportDuration, 0.01,
                                                   MIN_DURATION, MAX_TELEPORT_DURATION,
                                                  "%.3f ms")
        vars.teleportDuration = mathClamp(vars.teleportDuration, MIN_DURATION,
                                          MAX_TELEPORT_DURATION)
    end
    separator()
end

-- Lets users choose and adjust interlace SV options
-- Parameters
--    vars   : a reference to the variables of a menu [Table]
--    menuID : name of the menu of the variables [String]
function chooseInterlaceMultiplier(vars, menuID)
    _, vars.interlace = imgui.Checkbox("Interlace with another "..string.lower(menuID), 
                                       vars.interlace)
    if vars.interlace then
        spacing()
        _, vars.interlaceMultiplier = imgui.DragFloat("Interlace Ratio", vars.interlaceMultiplier,
                                                      0.01, -MAX_GENERAL_SV, MAX_GENERAL_SV)
        vars.interlaceMultiplier = mathClamp(vars.interlaceMultiplier, -MAX_GENERAL_SV,
                                             MAX_GENERAL_SV)
        spacing()
    end
    separator()
end
---------------------------------------------------------------------------------------------------
-- Global Constants
---------------------------------------------------------------------------------------------------

-- IMGUI / GUI
DEFAULT_WIDGET_HEIGHT = 26         -- value determining the height of GUI widgets
DEFAULT_WIDGET_WIDTH = 200         -- value determining the width of GUI widgets
SAMELINE_SPACING = 5               -- value determining spacing between GUI items on the same row

-- SV restrictions
MAX_TELEPORT_VALUE = 100000        -- maximum (absolute) teleport SV value allowed
MAX_TELEPORT_DURATION = 10         -- maximum teleport duration allowed (milliseconds)
MAX_GENERAL_SV = 100               -- maximum (absolute) value allowed for general SVs (ex. avg SV)
MIN_DURATION = 0.016               -- minimum duration allowed in general (milliseconds)
MAX_DURATION = 10000               -- maximum duration allowed in general (milliseconds)

-- Menu-related
EMOTICONS = {                      -- emoticons to clutter menu titles and confuse users
    "%(^w^%)",
    "%(o_0%)",
    "%(*o*%)",
    "%(>.<%)",
    "%(~_~%)",
    "%( e.e %)",
    "%( ; _ ; %)"
}
END_SV_TYPES = {                   -- options for the last SV placed at the end of an SV effect
    "Normal",
    "Skip",
    "1.00x"   
}
TOOL_OPTIONS = {                   -- list of the available tools for editing SVs
    "Linear",
    "Exponential",
    "Stutter",
    "Bezier",
    "Sinusoidal",
    "Single",
    "Remove"
}
MENUS = {}                         -- table of references to Lua functions for menus
-- Adds references to functions for each SV menu into the table 'MENUS'
for i = 1, #TOOL_OPTIONS do
    local functionName = string.lower(TOOL_OPTIONS[i]).."Menu"
    table.insert(MENUS, _G[functionName])
end