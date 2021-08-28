-- amoguSV pre-v2.0 (28 Aug 2021) 
-- by kloi34

-- Many SV tool ideas were stolen from other plugins, and I'm also planning to steal more that have
-- yet to be implemented, so here is credit to those SV plugins and the creators behind them:
--    iceSV       (by IceDynamix)         @ https://github.com/IceDynamix/iceSV
--    KeepStill   (by Illuminati-CRAZ)    @ https://github.com/Illuminati-CRAZ/KeepStill
--    Vibrato     (by Illuminati-CRAZ)    @ https://github.com/Illuminati-CRAZ/Vibrato
--    Displacer   (by Illuminati-CRAZ)    @ https://github.com/Illuminati-CRAZ/Displacer

---------------------------------------------------------------------------------------------------
-- Plugin Info ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- This is an SV plugin for Quaver, the ultimate community-driven and open-source competitive
-- rhythm game. The plugin contains various tools for editing SVs quickly and efficiently.
-- It's most similar to (i.e. 50% of SV features/ideas stolen from) iceSV. More features will be
-- added (stolen) from Illuminati-CRAZ's plugins in the future as well.

-- Things that still need working on/fixing:
--      1. Fix bezier tab and bezier calculation for iceSV method
--      2. Revamp + upgrade the "Remove" menu
--      3. Adding tooltips to widgets
--      4. Implement different Cubic bezier calculation (right now, uses iceSV method
--         which is slow/laggy when the live sv graphs update every time settings change)
--      5. Change bezier points to slider instead of input
--      6. Display linearly changing stutter SV values on right panel
--      7. Organize code better, create a table of contents listing major sections of code,
--         review + ADD comments, review code, review overall structure of the code,
--         basically refactoring code

-- Optional things that I maybe want to add later
--      1. Dedicated KeepStill+more SV tool 
--      2. Dedicated Vibrato+more SV tool 
--      3. Option to skip placing SVs between every other note (or every third note, etc.)
--         Place this option as a toggle on the right side
--      4. ?? Note animation by choosing which still frames to telport to ??
--      5. Other tools that can place predetermined sv effects like reverse-scroll, bounce, etc.
--      6. linearly spaced random svs that normalize to 1.00x?
--      7. hyperbolic sv 5head, or some common function
--      8. dampened harmonic motion svs 5head
--      9. steal iceSV sv multiplier tool? and also steal svs range tool to copy paste svs?
--      10. steal iceSV bezier parse
--      11. edit sv values option (sv multiplier over range)
--      12. expand bezier to orders other than cubic?
--      13. add point weights to bezier points
--      14. interpolation tab? quadratic or cubic interpolation of distance vs time points?
--      15. add a curve sharpness to sinusoidal
--      16. add a duration slider for determining % duration of SVs when placing SVs between notes
--          and have a toggle to determine from the start or from the end

---------------------------------------------------------------------------------------------------
-- Global Constants -------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- IMGUI / GUI
DEFAULT_WIDGET_HEIGHT = 26         -- value determining the height of GUI widgets
DEFAULT_WIDGET_WIDTH = 160         -- value determining the width of GUI widgets
MENU_SIZE_LEFT = {265, 465}        -- dimensions of the left side of the menu (IMGUI child window)
MENU_SIZE_RIGHT = {260, 465}       -- dimensions of the right side of the menu (IMGUI child window)
PADDING_WIDTH = 8                  -- value determining window and frame padding
PLUGIN_WINDOW_SIZE = {560, 540}    -- dimensions (width and height) of the plugin window
SAMELINE_SPACING = 5               -- value determining spacing between GUI items on the same row
ACTION_BUTTON_SIZE = {             -- dimensions of the button that places/removes SVs
    1.6 * DEFAULT_WIDGET_WIDTH,
    1.6 * DEFAULT_WIDGET_HEIGHT
}

-- SV/Time restrictions
MAX_DURATION = 10000               -- maximum duration allowed in general (milliseconds)
MAX_GENERAL_SV = 1000              -- maximum (absolute) value allowed for general SVs (ex. avg SV)
MAX_MS_TIME = 7200000              -- maximum song time (milliseconds) allowed ~ 2 hours
MAX_TELEPORT_DURATION = 10         -- maximum teleport duration allowed (milliseconds)
MAX_TELEPORT_VALUE = 1000000       -- maximum (absolute) teleport SV value allowed
MIN_DURATION = 0.016               -- minimum duration allowed in general (milliseconds)

-- Menu-related
EMOTICONS = {                      -- emoticons to visually clutter the plugin and confuse users
    "%(^w^%)",
    "%(o_0%)",
    "%(*o*%)",
    "%(>.<%)",
    "%(~_~%)",
    "%( e.e %)",
    "%( ; _ ; %)"
}
END_SV_TYPES = {                   -- options for the last SV placed at the tail end of all SVs
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

---------------------------------------------------------------------------------------------------
-- Plugin Menus and GUI ---------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Creates the plugin window
function draw()
    setPluginAppearence()
    createMainMenu()
end
-- Configures GUI styles: colors and appearence 
function setPluginAppearence()
    -- Plugin Styles
    local rounding = 5
    imgui.PushStyleVar( imgui_style_var.WindowPadding,      { PADDING_WIDTH, 8 } )
    imgui.PushStyleVar( imgui_style_var.FramePadding,       { PADDING_WIDTH, 5 } )
    imgui.PushStyleVar( imgui_style_var.ItemSpacing,        { DEFAULT_WIDGET_HEIGHT / 2 - 1, 4 } )
    imgui.PushStyleVar( imgui_style_var.ItemInnerSpacing,   { SAMELINE_SPACING, 6 } )
    imgui.PushStyleVar( imgui_style_var.WindowBorderSize,   0        )
    imgui.PushStyleVar( imgui_style_var.WindowRounding,     rounding )
    imgui.PushStyleVar( imgui_style_var.ChildRounding,      rounding )
    imgui.PushStyleVar( imgui_style_var.FrameRounding,      rounding )
    imgui.PushStyleVar( imgui_style_var.GrabRounding,       rounding )
    
    -- Plugin Colors
    imgui.PushStyleColor( imgui_col.WindowBg,               { 0.00, 0.00, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBg,                { 0.14, 0.24, 0.28, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         { 0.24, 0.34, 0.38, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          { 0.29, 0.39, 0.43, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBg,                { 0.41, 0.48, 0.65, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          { 0.51, 0.58, 0.75, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       { 0.51, 0.58, 0.75, 0.50 } )
    imgui.PushStyleColor( imgui_col.CheckMark,              { 0.81, 0.88, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrab,             { 0.56, 0.63, 0.75, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       { 0.61, 0.68, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.Button,                 { 0.31, 0.38, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          { 0.41, 0.48, 0.60, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonActive,           { 0.51, 0.58, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.Header,                 { 0.81, 0.88, 1.00, 0.40 } )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          { 0.81, 0.88, 1.00, 0.50 } )
    imgui.PushStyleColor( imgui_col.HeaderActive,           { 0.81, 0.88, 1.00, 0.54 } )
    imgui.PushStyleColor( imgui_col.Separator,              { 0.81, 0.88, 1.00, 0.30 } )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 0.81, 0.88, 1.00, 0.40 } )
end
-- Creates the main menu
function createMainMenu()
    imgui.SetNextWindowSize(PLUGIN_WINDOW_SIZE)
    imgui.Begin("amoguSV", imgui_window_flags.AlwaysAutoResize)
    local menuID = "main"
    local vars = {
        isHovered = {false, false, false},
        toolOptionNum = 0,
        betweenOffsetsNotNotes = false,
    }
    retrieveStateVariables(menuID, vars)
    
    vars.isHovered[1] = imgui.IsWindowHovered()
    imgui.AlignTextToFramePadding()
    imgui.Text("Current SV Tool:")
    imgui.SameLine()
    imgui.PushItemWidth(2 * DEFAULT_WIDGET_WIDTH)
    _, vars.toolOptionNum = imgui.Combo("     ", vars.toolOptionNum, TOOL_OPTIONS, #TOOL_OPTIONS)
    local toolIndex = vars.toolOptionNum + 1
    imgui.SameLine()
    imgui.Text(EMOTICONS[toolIndex])
    spacing()
    
    imgui.Columns(2, "SV Menus", false)
    imgui.BeginChild("Left Panel", MENU_SIZE_LEFT, true)
    vars.isHovered[2] = imgui.IsWindowHovered()
    local center = (MENU_SIZE_LEFT[1] - imgui.CalcTextSize("SETTINGS")[1] - 2 * PADDING_WIDTH) / 2
    imgui.Indent(center)
    imgui.Text("SETTINGS")
    imgui.Unindent(center)
    drawSeparatorLine()
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    -- creates the menu of the currently selected SV tool
    local menuFunctionName = string.lower(TOOL_OPTIONS[toolIndex]).."Menu"
    
    vars.betweenOffsetsNotNotes = _G[menuFunctionName](TOOL_OPTIONS[toolIndex], toolIndex, vars.betweenOffsetsNotNotes)
    vars.isHovered[3] = imgui.IsWindowHovered()
    imgui.EndChild()
    
    saveStateVariables(menuID, vars)
    state.IsWindowHovered = vars.isHovered[1] or vars.isHovered[2] or vars.isHovered[3]
    imgui.End()
end
function rightPanel(svVariablesHaveChanged, vars, menuID, svSetInfo, toolIndex, betweenOffsetsNotNotes)
    imgui.BeginChild("Right Panel", MENU_SIZE_RIGHT)
    if svVariablesHaveChanged then
        updateMenuSVs(vars, toolIndex, svSetInfo)
    end
    if (not betweenOffsetsNotNotes) then
        plotNotePath(vars.noteDistanceVsTime)
        drawSeparatorLine()
    end
    plotSVs(vars.svValuesPreview, menuID)
    displaySVStats(vars)
    drawSeparatorLine()
    imgui.AlignTextToFramePadding()
    imgui.Text("Place SVs between:")
    imgui.SameLine(0, 1.5 * SAMELINE_SPACING)
    if imgui.RadioButton("Notes", not betweenOffsetsNotNotes) then
        betweenOffsetsNotNotes = false
    end
    imgui.SameLine(0, 1.5 * SAMELINE_SPACING)
    if imgui.RadioButton("Offsets", betweenOffsetsNotNotes) then
        betweenOffsetsNotNotes = true
        vars.displace = false
    end
    spacing()
    if betweenOffsetsNotNotes then
        if imgui.Button("Current", {DEFAULT_WIDGET_WIDTH * 0.4, DEFAULT_WIDGET_HEIGHT}) then
            vars.startOffset = state.SongTime
        end
        imgui.SameLine(0, SAMELINE_SPACING)
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.75)
        _, vars.startOffset = imgui.InputInt("Start Offset", vars.startOffset)
        
        if imgui.Button(" Current ", {DEFAULT_WIDGET_WIDTH * 0.4, DEFAULT_WIDGET_HEIGHT}) then
            vars.endOffset = state.SongTime
        end
        imgui.SameLine(0, SAMELINE_SPACING)
        _, vars.endOffset = imgui.InputInt("End Offset", vars.endOffset)
    end
    local svButtonText = "Place SVs "
    if betweenOffsetsNotNotes then
        svButtonText = svButtonText.."Between Start/End Offsets"
        spacing()
    else
        svButtonText = svButtonText.."Between Selected Notes"
    end
    if imgui.Button(svButtonText, ACTION_BUTTON_SIZE) then
        local offsets = {vars.startOffset, vars.endOffset}
        if (not betweenOffsetsNotNotes) then
            offsets = uniqueSelectedNoteOffsets()
        end
        local SVs = generateSVs(offsets, vars.svValues, vars.addTeleport,
                                vars.veryStartTeleport, vars.teleportValue,
                                vars.teleportDuration, vars.endSVOption, vars.displace,
                                vars.displacement, vars.stutterDuration, vars.linearStutter,
                                vars.linearEndStutterSV, vars.linearEndDuration,
                                vars.linearEndAvgSV, vars.avgSV, betweenOffsetsNotNotes)
        if #SVs > 0 then
            actions.PlaceScrollVelocityBatch(SVs)
        end
    end
    return betweenOffsetsNotNotes
end

-- Creates the Linear SV menu
-- Parameters
--    menuID : name of the menu [String]
function linearMenu(menuID, toolIndex, betweenOffsetsNotNotes)
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
        teleportDuration = 1.000,
        displace = false,
        displacement = 150,
        svValues = {},
        svValuesPreview = {},
        noteDistanceVsTime = {},
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    
    local svVariablesHaveChanged = #vars.svValues == 0
    local linearSVValues = {vars.startSV, vars.endSV}
    _, linearSVValues = imgui.InputFloat2("Start/End SV", linearSVValues, "%.2fx")
    svVariablesHaveChanged = svVariablesHaveChanged or (linearSVValues[1] ~=  vars.startSV)
                    or (linearSVValues[2] ~= vars.endSV)
    vars.startSV, vars.endSV = table.unpack(linearSVValues)
    vars.startSV = mathClamp(vars.startSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    vars.endSV = mathClamp(vars.endSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    svVariablesHaveChanged = chooseSVPoints(vars) or svVariablesHaveChanged
    spacing()
    svVariablesHaveChanged = chooseEndSV(vars, false) or svVariablesHaveChanged
    local oldInterlace = vars.interlace
    local oldInterlaceStart = vars.interlaceStartSV
    local oldInterlaceEnd = vars.interlaceEndSV
    _, vars.interlace = imgui.Checkbox("Interlace another linear", vars.interlace)
    if vars.interlace then
        local interlaceSVValues = {vars.interlaceStartSV, vars.interlaceEndSV}
        _, interlaceSVValues = imgui.InputFloat2("Start/End SV ", interlaceSVValues, "%.2fx")
        vars.interlaceStartSV, vars.interlaceEndSV = table.unpack(interlaceSVValues)
        vars.interlaceStartSV = mathClamp(vars.interlaceStartSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
        vars.interlaceEndSV = mathClamp(vars.interlaceEndSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    end
    svVariablesHaveChanged = svVariablesHaveChanged or (oldInterlace ~= vars.interlace)
                    or (oldInterlaceStart ~= vars.interlaceStartSV)
                    or (oldInterlaceEnd ~= vars.interlaceEndSV)
    drawSeparatorLine()
    chooseTeleportSV(vars, menuID, betweenOffsetsNotNotes)
    drawSeparatorLine()
    chooseDisplacement(vars, betweenOffsetsNotNotes)
    imgui.EndChild()
    
    imgui.NextColumn()
    local svSetInfo = {vars.startSV, vars.endSV, vars.svPoints + 1, vars.interlace, vars.interlaceStartSV, vars.interlaceEndSV}
    betweenOffsetsNotNotes = rightPanel(svVariablesHaveChanged, vars, menuID, svSetInfo, toolIndex, betweenOffsetsNotNotes)
    saveStateVariables(menuID, vars)
    return betweenOffsetsNotNotes
end
-- Creates the "Exponential SV" menu
-- Parameters
--    menuID : name of the menu [String]
function exponentialMenu(menuID, toolIndex, betweenOffsetsNotNotes)
    local vars = {
        exponentialIncrease = false,
        svPoints = 16,
        avgSV = 1,
        intensity = 30,
        endSVOption = 1,
        interlace = false,
        interlaceMultiplier = -0.5,
        addTeleport = false,
        veryStartTeleport = false,
        teleportValue = 10000,
        teleportDuration = 1.000,
        displace = false,
        displacement = 150,
        svValues = {},
        svValuesPreview = {},
        noteDistanceVsTime = {},
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    
    local svVariablesHaveChanged = #vars.svValues == 0
    imgui.AlignTextToFramePadding()
    imgui.Text("Behavior:")
    local oldBehavior = vars.exponentialIncrease
    imgui.SameLine(0, 1.5 * SAMELINE_SPACING)
    if imgui.RadioButton("Slow down", not vars.exponentialIncrease) then
        vars.exponentialIncrease = false
    end
    imgui.SameLine(0, 1.5 * SAMELINE_SPACING)
    if imgui.RadioButton("Speed up", vars.exponentialIncrease) then
        vars.exponentialIncrease = true
    end
    svVariablesHaveChanged = (oldBehavior ~= vars.exponentialIncrease) or svVariablesHaveChanged
    local oldIntensity = vars.intensity
    _, vars.intensity = imgui.SliderInt("Intensity", vars.intensity, 1, 200, vars.intensity.."%%")
    vars.intensity = mathClamp(vars.intensity, 1, 200)
    svVariablesHaveChanged = (oldIntensity ~= vars.intensity) or svVariablesHaveChanged
    svVariablesHaveChanged = chooseAverageSV(vars) or svVariablesHaveChanged
    svVariablesHaveChanged = chooseSVPoints(vars) or svVariablesHaveChanged
    spacing()
    svVariablesHaveChanged = chooseEndSV(vars, false) or svVariablesHaveChanged
    svVariablesHaveChanged = chooseInterlaceMultiplier(vars, menuID) or svVariablesHaveChanged
    chooseTeleportSV(vars, menuID, betweenOffsetsNotNotes)
    drawSeparatorLine()
    chooseDisplacement(vars, betweenOffsetsNotNotes)
    imgui.EndChild()
    
    imgui.NextColumn()
    local svSetInfo = {vars.exponentialIncrease, vars.svPoints + 1, vars.avgSV, vars.intensity,
                       vars.interlace, vars.interlaceMultiplier}
    betweenOffsetsNotNotes = rightPanel(svVariablesHaveChanged, vars, menuID, svSetInfo, toolIndex, betweenOffsetsNotNotes)
    saveStateVariables(menuID, vars)
    return betweenOffsetsNotNotes
end
-- Creates the "Stutter SV" menu
-- Parameters
--    menuID : name of the menu [String]
function stutterMenu(menuID, toolIndex, betweenOffsetsNotNotes)
    local vars = {
        startSV = 1.5,
        stutterDuration = 0.5,
        avgSV = 1,
        endSVOption = 2,
        linearStutter = false,
        linearEndStutterSV = 2,
        linearEndAvgSV = 1,
        linearEndDuration = 0.5,
        displace = false,
        displacement = 150,
        svValues = {},
        svValuesPreview = {},
        noteDistanceVsTime = {},
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    
    local svVariablesHaveChanged = #vars.svValues == 0
    local oldStartSV = vars.startSV
    _, vars.startSV = imgui.InputFloat("Stutter first SV", vars.startSV, 0, 0, "%.2fx")
    vars.startSV = mathClamp(vars.startSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    svVariablesHaveChanged = svVariablesHaveChanged or (oldStartSV ~= vars.startSV)
    local oldDuration = vars.stutterDuration
    _, vars.stutterDuration = imgui.SliderFloat("Duration", vars.stutterDuration, 0.01, 0.99, "%.2f")
    vars.stutterDuration = mathClamp(vars.stutterDuration, 0.01, 0.99)
    svVariablesHaveChanged = svVariablesHaveChanged or (oldDuration ~= vars.stutterDuration)
    
    spacing()
    svVariablesHaveChanged = chooseAverageSV(vars) or svVariablesHaveChanged
    spacing()
    svVariablesHaveChanged = chooseEndSV(vars, true) or svVariablesHaveChanged
    _, vars.linearStutter = imgui.Checkbox("Change stutter linearly over time", vars.linearStutter)
    if vars.linearStutter then
        spacing()
        imgui.Text("Linearly end at:")
        spacing()
        _, vars.linearEndStutterSV = imgui.InputFloat("Stutter start SV ", vars.linearEndStutterSV,
                                                      0, 0, "%.2fx")
        vars.linearEndStutterSV = mathClamp(vars.linearEndStutterSV, -MAX_GENERAL_SV,
                                            MAX_GENERAL_SV)
        _, vars.linearEndDuration = imgui.SliderFloat("Duration ", vars.linearEndDuration,
                                                      0.01, 0.99, "%.2f")
        vars.linearEndDuration = mathClamp(vars.linearEndDuration, 0.01, 0.99)
        spacing()
        _, vars.linearEndAvgSV = imgui.InputFloat("Average SV ", vars.linearEndAvgSV, 0, 0,
                                                  "%.2fx")
        vars.linearEndAvgSV = mathClamp(vars.linearEndAvgSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    end
    imgui.EndChild()
    
    imgui.NextColumn()
    local svSetInfo = {vars.startSV, vars.stutterDuration, vars.avgSV}
    betweenOffsetsNotNotes = rightPanel(svVariablesHaveChanged, vars, menuID, svSetInfo, toolIndex, betweenOffsetsNotNotes)
    saveStateVariables(menuID, vars)
    return betweenOffsetsNotNotes
end
-- Creates the "Bezier SV" menu
-- Parameters
--    menuID : name of the menu [String]
function bezierMenu(menuID, toolIndex, betweenOffsetsNotNotes)
    local vars = {
        calculationMethodOption = 0,
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 1,
        svPoints = 16,
        avgSV = 1,
        endSVOption = 2,
        interlace = false,
        interlaceMultiplier = -0.5,
        addTeleport = false,
        veryStartTeleport = false,
        teleportValue = 10000,
        teleportDuration = 1.000,
        displace = false,
        displacement = 150,
        bezierSVValues = {},
        noteDistanceVsTime = {},
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    
    local svVariablesHaveChanged = #vars.bezierSVValues == 0
    
    local firstPoint = {vars.x1, vars.y1}
    local secondPoint = {vars.x2, vars.y2}
    _, firstPoint = imgui.InputFloat2("x1, y1", firstPoint, "%.2f")
    _, secondPoint = imgui.InputFloat2("x2, y2", secondPoint, "%.2f")
    svVariablesHaveChanged = svVariablesHaveChanged or (firstPoint[1] ~= vars.x1) or (firstPoint[2] ~= vars.y1)
                    or (secondPoint[1] ~= vars.x2) or (secondPoint[2] ~= vars.y2)
    vars.x1, vars.y1 = table.unpack(firstPoint)
    vars.x2, vars.y2 = table.unpack(secondPoint)
    vars.x1 = mathClamp(vars.x1, 0, 1)
    vars.y1 = mathClamp(vars.y1, -1, 2)
    vars.x2 = mathClamp(vars.x2, 0, 1)
    vars.y2 = mathClamp(vars.y2, -1, 2)
    svVariablesHaveChanged = chooseAverageSV(vars) or svVariablesHaveChanged
    svVariablesHaveChanged = chooseSVPoints(vars) or svVariablesHaveChanged
    spacing()
    svVariablesHaveChanged = chooseEndSV(vars, true) or svVariablesHaveChanged
    svVariablesHaveChanged = chooseInterlaceMultiplier(vars, menuID) or svVariablesHaveChanged
    chooseTeleportSV(vars, menuID, betweenOffsetsNotNotes)
    drawSeparatorLine()
    chooseDisplacement(vars, betweenOffsetsNotNotes)
    drawSeparatorLine()
    imgui.AlignTextToFramePadding()
    imgui.Text("Calculation Style:")
    local oldMethodOption = vars.calculationMethodOption
    imgui.SameLine()
    _, vars.calculationMethodOption = imgui.RadioButton("IceSV", vars.calculationMethodOption, 0)
    imgui.SameLine()
    _, vars.calculationMethodOption = imgui.RadioButton("Option 2", vars.calculationMethodOption, 1)
    svVariablesHaveChanged = oldMethodOption ~= vars.calculationMethodOption or svVariablesHaveChanged
    imgui.EndChild()
    
    imgui.NextColumn()
    imgui.BeginChild("Right Menu", MENU_SIZE_RIGHT)
    if svVariablesHaveChanged then
        vars.bezierSVValues =  generateBezierSetIceSV(vars.x1, vars.y1, vars.x2, vars.y2, vars.avgSV, vars.svPoints + 2, vars.interlace, vars.interlaceMultiplier)
        vars.noteDistanceVsTime = calculateDistanceVsTime(vars.bezierSVValues, -1)
        if vars.endSVOption ~= 1 then
            table.remove(vars.bezierSVValues, #vars.bezierSVValues)
        end
        if vars.endSVOption == 3 then
            table.insert(vars.bezierSVValues, 1)
        end
    end
    plotNotePath(vars.noteDistanceVsTime)
    drawSeparatorLine()
    --plotSVs(vars.bezierSVValues, menuID)
    drawSeparatorLine()
    if imgui.Button("Place SVs Between Selected Notes", ACTION_BUTTON_SIZE) then
        local SVs = calculateBezierSV(vars.x1, vars.y1, vars.x2, vars.y2, vars.svPoints,
                                      vars.avgSV, vars.endSVOption, vars.interlace,
                                      vars.interlaceMultiplier, vars.addTeleport,
                                      vars.veryStartTeleport, vars.teleportValue,
                                      vars.teleportDuration, vars.displace, vars.displacement)
        if #SVs > 0 then
            actions.PlaceScrollVelocityBatch(SVs)
        end
    end
    saveStateVariables(menuID, vars)
    return betweenOffsetsNotNotes
end
-- Creates the "Sinusoidal SV" menu
-- Parameters
--    menuID : name of the menu [String]
function sinusoidalMenu(menuID, toolIndex, betweenOffsetsNotNotes)
    local vars = {
        startAmplitude = 2,
        endAmplitude = 2,
        periods = 0.25,
        periodsShift = 0,
        svsPerQuarterPeriod = 8,
        endSVOption = 2,
        addTeleport = false,
        veryStartTeleport = false,
        teleportValue = 10000,
        teleportDuration = 1.000,
        displace = false,
        displacement = 150,
        svValues = {},
        svValuesPreview = {},
        noteDistanceVsTime = {},
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    local svVariablesHaveChanged = #vars.svValues == 0
    
    imgui.Text("Amplitude:")
    local amplitudes = {vars.startAmplitude, vars.endAmplitude}
    _, amplitudes = imgui.InputFloat2("Start/End", amplitudes, "%.2fx")
    svVariablesHaveChanged = svVariablesHaveChanged or (amplitudes[1] ~= vars.startAmplitude) or (amplitudes[2] ~= endAmplitude)
    vars.startAmplitude, vars.endAmplitude = table.unpack(amplitudes)
    vars.startAmplitude = mathClamp(vars.startAmplitude, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    vars.endAmplitude = mathClamp(vars.endAmplitude, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    drawSeparatorLine()
    local oldPeriods = vars.periods
    _, vars.periods = imgui.InputFloat("Periods/Cycles", vars.periods, 0.25, 0.25, "%.2f")
    vars.periods = forceQuarter(vars.periods)
    vars.periods = mathClamp(vars.periods, 0.25, 20)
    svVariablesHaveChanged = svVariablesHaveChanged or (oldPeriods ~= vars.periods)
    local oldPeriodsShift = vars.periodsShift
    _, vars.periodsShift = imgui.InputFloat("Phase Shift", vars.periodsShift, 0.25, 0.25,
                                            "%.2f")
    vars.periodsShift = forceQuarter(vars.periodsShift)
    vars.periodsShift = mathClamp(vars.periodsShift, 0, 0.75)
    svVariablesHaveChanged = svVariablesHaveChanged or (oldPeriodsShift ~= vars.periodsShift)
    spacing()
    imgui.Text("For every 0.25 period/cycle, place...")
    local oldPerQuarterPeriod = vars.svsPerQuarterPeriod
    _, vars.svsPerQuarterPeriod = imgui.InputInt("SV points", vars.svsPerQuarterPeriod)
    vars.svsPerQuarterPeriod = mathClamp(vars.svsPerQuarterPeriod, 1, 50)
    svVariablesHaveChanged = svVariablesHaveChanged or (oldPerQuarterPeriod ~= vars.svsPerQuarterPeriod)
    spacing()
    svVariablesHaveChanged = chooseEndSV(vars, true) or svVariablesHaveChanged
    chooseTeleportSV(vars, menuID, betweenOffsetsNotNotes)
    drawSeparatorLine()
    chooseDisplacement(vars, betweenOffsetsNotNotes)
    imgui.EndChild()
    
    imgui.NextColumn()
    local svSetInfo = {vars.startAmplitude, vars.endAmplitude, vars.periods, vars.periodsShift,
                       vars.svsPerQuarterPeriod}
    betweenOffsetsNotNotes = rightPanel(svVariablesHaveChanged, vars, menuID, svSetInfo, toolIndex, betweenOffsetsNotNotes)
    saveStateVariables(menuID, vars)
    return betweenOffsetsNotNotes
end
-- Creates the "Single SV" menu
-- Parameters
--    menuID : name of the menu [String]
function singleMenu(menuID, toolIndex, betweenOffsetsNotNotes)
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
        svValueAfterEnd = 0,
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)

    if vars.svBefore then
        imgui.Text("Before note:")
        if vars.scaleSVLinearly then
            local beforeSVValues = {vars.svValueBefore, vars.svValueBeforeEnd}
            _, beforeSVValues = imgui.InputFloat2("Start/End SV", beforeSVValues, "%.2fx")
            vars.svValueBefore, vars.svValueBeforeEnd = table.unpack(beforeSVValues)
            vars.svValueBeforeEnd = mathClamp(vars.svValueBeforeEnd, -MAX_TELEPORT_VALUE,
                                              MAX_TELEPORT_VALUE)
        else
            _, vars.svValueBefore = imgui.InputFloat("SV value", vars.svValueBefore, 0, 0, "%.2fx")
        end
        vars.svValueBefore = mathClamp(vars.svValueBefore, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        _, vars.incrementBefore = imgui.InputFloat("Time before", vars.incrementBefore, 0, 0,
                                                   "%.3f ms")
        vars.incrementBefore = mathClamp(vars.incrementBefore, MIN_DURATION, MAX_DURATION)
    end
    if (not vars.skipSVAtNote) then
        if vars.svBefore then
            spacing()
        end
        imgui.Text("At note:")
        if vars.scaleSVLinearly then
            local atNoteSVValues = {vars.svValue, vars.svValueEnd}
            _, atNoteSVValues = imgui.InputFloat2("Start/End SV ", atNoteSVValues, "%.2fx")
            vars.svValue, vars.svValueEnd = table.unpack(atNoteSVValues)
            vars.svValueEnd = mathClamp(vars.svValueEnd, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        else
            _, vars.svValue = imgui.InputFloat("SV value ", vars.svValue, 0, 0, "%.2fx")
        end
        vars.svValue = mathClamp(vars.svValue, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
    end
    if vars.svAfter then
        if vars.svBefore or (not vars.skipSVAtNote) then
            spacing()
        end
        imgui.Text("After note:")
        if vars.scaleSVLinearly then
            local afterSVValues = {vars.svValueAfter, vars.svValueAfterEnd}
            _, afterSVValues = imgui.InputFloat2("Start/End SV  ", afterSVValues, "%.2fx")
            vars.svValueAfter, vars.svValueAfterEnd = table.unpack(afterSVValues)
            vars.svValueAfterEnd = mathClamp(vars.svValueAfterEnd, -MAX_TELEPORT_VALUE,
                                             MAX_TELEPORT_VALUE)
        else
            _, vars.svValueAfter = imgui.InputFloat("SV value  ", vars.svValueAfter, 0, 0, "%.2fx")
        end
        vars.svValueAfter = mathClamp(vars.svValueAfter, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        _, vars.incrementAfter = imgui.InputFloat("Time After", vars.incrementAfter, 0, 0,
                                                   "%.3f ms")
        vars.incrementAfter = mathClamp(vars.incrementAfter, MIN_DURATION, MAX_DURATION)
    end
    local inputExists = vars.svBefore or (not vars.skipSVAtNote) or vars.svAfter
    if inputExists then
        drawSeparatorLine()
    end
    _, vars.svBefore = imgui.Checkbox("Add SV before note", vars.svBefore)
    _, vars.svAfter = imgui.Checkbox("Add SV after note", vars.svAfter)
    _, vars.skipSVAtNote = imgui.Checkbox("Skip SV at note", vars.skipSVAtNote)
    _, vars.scaleSVLinearly = imgui.Checkbox("Scale SV values linearly over time", vars.scaleSVLinearly)
    imgui.EndChild()
    
    imgui.NextColumn()
    imgui.BeginChild("Right Menu", MENU_SIZE_RIGHT)
    if inputExists then
        if imgui.Button("Place SVs At All Selected Notes", ACTION_BUTTON_SIZE) then
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
    return betweenOffsetsNotNotes
end
-- Creates the "Remove SV" menu
-- Parameters
--    menuID : name of the menu [String]
function removeMenu(menuID, toolIndex, betweenOffsetsNotNotes)
    local vars = {
        startOffset = 0,
        endOffset = 0,
        inputTime = false
    }
    retrieveStateVariables(menuID, vars)
    
    local currentButtonSize = {0.6 * DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT}
    local halfWidgetWidth = 100
    imgui.Text("Remove SVs...")
    spacing()
    imgui.AlignTextToFramePadding()
    imgui.Text("From")
    imgui.SameLine(0, 2 * SAMELINE_SPACING)
    if vars.inputTime then
        imgui.PushItemWidth(halfWidgetWidth)
        _, vars.startOffset = imgui.InputFloat("", vars.startOffset, 0, 0, "%.3f ms")
        imgui.PopItemWidth()
        imgui.SameLine(0, 2 * SAMELINE_SPACING + 2)
    else
        imgui.Text(":  "..convertToTime(vars.startOffset).." (Start) ")
        imgui.SameLine(0, 2 * SAMELINE_SPACING + 3)
    end
    if imgui.Button("Set Current", currentButtonSize) then
        vars.startOffset = math.floor(state.SongTime)
    end
    vars.startOffset = mathClamp(vars.startOffset, 0, MAX_MS_TIME)
    imgui.AlignTextToFramePadding()
    imgui.Indent(imgui.CalcTextSize("From")[1] - imgui.CalcTextSize("To")[1])
    imgui.Text("To")
    imgui.Unindent(imgui.CalcTextSize("From")[1] - imgui.CalcTextSize("To")[1])
    imgui.SameLine(0, 2 * SAMELINE_SPACING)
    if vars.inputTime then
        imgui.PushItemWidth(halfWidgetWidth)
        _, vars.endOffset = imgui.InputFloat(" ", vars.endOffset, 0, 0, "%.3f ms")
        imgui.SameLine(0, SAMELINE_SPACING)
    else
        imgui.Text(":  "..convertToTime(vars.endOffset).." (End)")
        imgui.SameLine(0, 4 * SAMELINE_SPACING + 2)
    end
    if imgui.Button(" Set Current ", currentButtonSize) then
        vars.endOffset = math.floor(state.SongTime)
    end
    vars.endOffset = mathClamp(vars.endOffset, 0, MAX_MS_TIME)
    spacing()
    _, vars.inputTime = imgui.Checkbox("Manually input time", vars.inputTime)
    imgui.EndChild()
    
    imgui.NextColumn()
    imgui.BeginChild("Right Menu", MENU_SIZE_RIGHT)
    if imgui.Button("Remove SVs Between Times", ACTION_BUTTON_SIZE) then
        removeSVs(vars.startOffset, vars.endOffset)
    end
    saveStateVariables(menuID, vars)
    return betweenOffsetsNotNotes
end

---------------------------------------------------------------------------------------------------
-- Calculation/helper functions
---------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------- Variable Management

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

----------------------------------------------------------------------------------------- IMGUI GUI

-- Adds vertical blank space on the GUI
function spacing()
    imgui.Dummy({0,1})
end
-- Draws a horizontal line separator on the GUI
function drawSeparatorLine()
    spacing()
    imgui.Separator()
    spacing()
end

------------------------------------------------------------------------------------- IMGUI Widgets

-- Lets users choose the average SV
-- Returns whether or not a new average SV was inputted [Boolean]
-- Parameters
--    vars : reference to the list of variables for a menu [Table]
function chooseAverageSV(vars)
    local oldAvg = vars.avgSV
    _, vars.avgSV = imgui.InputFloat("Average SV", vars.avgSV, 0, 0, "%.2fx")    
    vars.avgSV = mathClamp(vars.avgSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    return oldAvg ~= vars.avgSV
end
-- Lets users choose and adjust displacment SV options
-- Parameters
--    vars : reference to the list of variables for a menu [Table]
--    betweenOffsetsNotNotes
function chooseDisplacement(vars, betweenOffsetsNotNotes)
    if (not betweenOffsetsNotNotes) then
        _, vars.displace = imgui.Checkbox("Displace end notes' hit receptor/position", vars.displace)
        if vars.displace then
            _, vars.displacement = imgui.InputFloat("Height", vars.displacement, 0, 0, "%.2f msx")
            vars.displacement = mathClamp(vars.displacement, -MAX_GENERAL_SV, MAX_GENERAL_SV)
        end
    end
end
-- Lets users choose the end SV type
-- Returns whether or not a new end SV was chosen [Boolean]
-- Parameters
--    vars     : reference to the list of variables for a menu [Table]
--    noNormal : whether or not to have the "Normal" end SV option [Boolean]
function chooseEndSV(vars, noNormal)
    imgui.AlignTextToFramePadding()
    imgui.Text("Last SV:")
    local oldOption = vars.endSVOption
    local startNum = 1
    if noNormal then
        startNum = 2
    end
    for i = startNum, #END_SV_TYPES do
        local spacing = SAMELINE_SPACING
        if i ~= startNum then
            spacing = 1.5 * spacing
        end
        imgui.SameLine(0, spacing)
        _, vars.endSVOption = imgui.RadioButton(END_SV_TYPES[i], vars.endSVOption, i)
    end
    drawSeparatorLine()
    return oldOption ~= vars.endSVOption
end
-- Lets users choose and adjust interlace SV options
-- Returns whether or not the interlace checkbox or the interlace multiplier changed [Boolean]
-- Parameters
--    vars   : reference to the list of variables for a menu [Table]
--    menuID : name of the menu of the variables [String]
function chooseInterlaceMultiplier(vars, menuID)
    local oldInterlace = vars.interlace
    local oldMultiplier = vars.interlaceMultiplier
    _, vars.interlace = imgui.Checkbox("Interlace another "..string.lower(menuID), vars.interlace)
    if vars.interlace then
        _, vars.interlaceMultiplier = imgui.InputFloat("Lace multiplier",
                                                       vars.interlaceMultiplier, 0, 0, "%.2f")
        vars.interlaceMultiplier = mathClamp(vars.interlaceMultiplier, -MAX_GENERAL_SV,
                                             MAX_GENERAL_SV)
    end
    drawSeparatorLine()
    return oldInterlace ~= vars.interlace or oldMultiplier ~= vars.interlaceMultiplier
end
-- Lets users choose the number of SV points to place
-- Returns whether or not a new number of SV points was inputted [Boolean]
-- Parameters
--    vars : reference to the list of variables for a menu [Table]
function chooseSVPoints(vars)
    local oldSVPoints = vars.svPoints
    _, vars.svPoints = imgui.InputInt("SV points", vars.svPoints, 1, 1)
    vars.svPoints = mathClamp(vars.svPoints, 1, 256)
    return oldSVPoints ~= vars.svPoints
end
-- Lets users choose and adjust teleport SV options
-- Parameters
--    vars   : reference to the list of variables for a menu [Table]
--    menuID : name of the menu of the variables [String]
--    betweenOffsetsNotNotes
function chooseTeleportSV(vars, menuID, betweenOffsetsNotNotes)
    _, vars.addTeleport = imgui.Checkbox("Add teleport SV at beginning", vars.addTeleport)
    if vars.addTeleport then
        _, vars.teleportValue = imgui.InputFloat("Teleport SV", vars.teleportValue, 0, 0, "%.2fx")
        vars.teleportValue = mathClamp(vars.teleportValue, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        _, vars.teleportDuration = imgui.InputFloat("Duration", vars.teleportDuration, 0, 0,
                                                    "%.3f ms")
        vars.teleportDuration = mathClamp(vars.teleportDuration, MIN_DURATION,
                                          MAX_TELEPORT_DURATION)
        if (not betweenOffsetsNotNotes) then
            if imgui.RadioButton("Very start", vars.veryStartTeleport) then
                vars.veryStartTeleport = true
            end
            imgui.SameLine(0, 1.5 * SAMELINE_SPACING)
            if imgui.RadioButton("Every "..string.lower(menuID).." set", not vars.veryStartTeleport) then
                vars.veryStartTeleport = false
            end
        end
    end
end

----------------------------------------------------------------------------- SV Generation/Editing

-- Adds the last SV to a set of SVs
-- Parameters
--    SVs
--    endOffset
--    velocity    : default/usual SV value for the end SV [Int/Float]
--    endSVOption : option number for the last SV (based on global constant END_SV_TYPES) [Int]
--    displace
--    displacement
function addEndSV(SVs, endOffset, velocity, endSVOption, displace, displacement)
    if displace then
        table.insert(SVs, utils.CreateScrollVelocity(endOffset, - displacement * 64))
        endOffset = endOffset + MIN_DURATION
    end
    if endSVOption == 1 then -- normal SV option
        table.insert(SVs, utils.CreateScrollVelocity(endOffset, velocity))
    elseif endSVOption == 3 then -- 1.00x SV option
        table.insert(SVs, utils.CreateScrollVelocity(endOffset, 1))
    end
end
-- Adds a teleport SV to the start of a set of SVs if applicable
-- Returns the (adjusted) start offset based on the teleport [Int/Float]
-- Parameters
--    startOffset       : start time of the SV set being calculated [Int/Float]
--    addTeleport       : whether or not to add a teleport SV [Boolean]
--    veryStartTeleport : whether or not the teleport SV is only at the very start [Boolean]
--    veryFirstSet      : whether or not the current SV set is the very first set [Boolean]
--    teleportValue     : value of the teleport SV [Int/Float] 
--    teleportDuration  : duration of the teleport SV in milliseconds [Int/Float] 
--    SVs               : table of all SVs that will be calculated [Table]
function determineTeleport(startOffset, addTeleport, veryStartTeleport, veryFirstSet,
                           teleportValue, teleportDuration, SVs)
    if addTeleport then
        -- adds a teleport and adjusts the start offset if we are at the very first set or want a
        -- teleport for each set
        if veryFirstSet or (not veryStartTeleport) then
            table.insert(SVs, utils.CreateScrollVelocity(startOffset, teleportValue))
            startOffset = startOffset + teleportDuration
        end
    end
    return startOffset
end

function generateSVs(offsets, svValues, addTeleport, veryStartTeleport, teleportValue, teleportDuration,
                     endSVOption, displace, displacement, stutterDuration, linearStutter,
                     linearEndStutterSV, linearEndDuration, linearEndAvgSV, stutterAvgSV,
                     betweenOffsetsNotNotes)
    local SVs = {}
    local startSVList = {}
    local svDurationList = {}
    local avgSVList = {}
    if stutterDuration ~= nil and linearStutter then
        startSVList = generateLinearSet(svValues[1], linearEndStutterSV, #offsets - 1, false, 0, 0)
        svDurationList = generateLinearSet(stutterDuration, linearEndDuration, #offsets - 1, false, 0, 0)
        avgSVList = generateLinearSet(stutterAvgSV, linearEndAvgSV, #offsets - 1, false, 0, 0)
    end
    for i = 1, #offsets - 1 do
        local startOffset = determineTeleport(offsets[i], addTeleport, veryStartTeleport,
                                              i == 1, teleportValue, teleportDuration, SVs)
        local endOffset = offsets[i + 1]
        if (not betweenOffsetsNotNotes) and displace then
            if i ~= 1 and ((not addTeleport) or (addTeleport and veryStartTeleport)) then
                table.insert(SVs, utils.CreateScrollVelocity(startOffset, - displacement * 64))
                startOffset = startOffset + MIN_DURATION
            end
            table.insert(SVs, utils.CreateScrollVelocity(endOffset - MIN_DURATION, displacement * 64))
        end
        local svOffsets
        if stutterDuration == nil then
            svOffsets = generateLinearSet(startOffset, endOffset, #svValues, false, 0, 0)
        else
            local offsetInterval = endOffset - startOffset
            if linearStutter then
                svOffsets = {startOffset, startOffset + offsetInterval * svDurationList[i], endOffset}
            else
                svOffsets = {startOffset, startOffset + offsetInterval * stutterDuration, endOffset}
            end
        end
        if linearStutter then
            local thisStartSV = startSVList[i]
            svValues = {thisStartSV, calculateSecondStutterValue(thisStartSV, svDurationList[i], avgSVList[i])}
        end
        for j = 1, #svOffsets - 1 do
            if linearStutter then
                table.insert(SVs, utils.CreateScrollVelocity(svOffsets[j], svValues[j]))
            else
                table.insert(SVs, utils.CreateScrollVelocity(svOffsets[j], svValues[j]))
            end
        end
    end
    addEndSV(SVs, offsets[#offsets], svValues[#svValues], endSVOption, displace, displacement)
    return SVs
end
-- Calculates all single SVs to place
-- Returns a list of all calculated siingle SVs [Table]
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
        svValuesBefore = generateLinearSet(svValueBefore, svValueBeforeEnd, #offsets, false, 0, 0)
        svValuesAfter = generateLinearSet(svValueAfter, svValueAfterEnd, #offsets, false, 0, 0)
        svValuesAt = generateLinearSet(svValue, svValueEnd, #offsets, false, 0, 0)
    else
        svValuesBefore = generateLinearSet(svValueBefore, svValueBefore, #offsets, false, 0, 0)
        svValuesAfter = generateLinearSet(svValueAfter, svValueAfter, #offsets, false, 0, 0)
        svValuesAt = generateLinearSet(svValue, svValue, #offsets, false, 0, 0)
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

-- Calculates all bezier SVs to place
-- Returns a list of all calculated bezier SVs [Table]
-- Parameters
function calculateBezierSV(x1, y1, x2, y2, svPoints, avgSV, endSVOption, interlace,
                           interlaceMultiplier, addTeleport, veryStartTeleport, teleportValue,
                           teleportDuration, displace, displacement)
    local bezierSVValues = generateBezierSetIceSV(x1, y1, x2, y2, avgSV, svPoints + 2, interlace, interlaceMultiplier)
    return generateSVs(uniqueSelectedNoteOffsets(), bezierSVValues, addTeleport, veryStartTeleport, teleportValue,
                       teleportDuration, endSVOption, displace, displacement)
end
-- Removes SVs in the map between two points of time
-- Parameters
--    startOffset : starting time (milliseconds) to begin removing SVs at [Int/Float]
--    endOffset   : ending time (milliseconds) to stop removing SVs at [Int/Float]
function removeSVs(startOffset, endOffset)
    local svsToRemove = {}
    for i, sv in pairs(map.ScrollVelocities) do
        local isInBetween = (sv.StartTime >= startOffset and sv.StartTime <= endOffset) or
                            (sv.StartTime >= endOffset and sv.StartTime <= startOffset)
        if isInBetween then
            table.insert(svsToRemove, sv)
        end
    end
    if #svsToRemove > 0 then
        actions.RemoveScrollVelocityBatch(svsToRemove)
    end
end

-------------------------------------------------------------------------- Math/Numbers/Calculation

-- ** Note ** The built-in utils.MillisecondsToTime function already exists for Quaver, but doesn't
-- display hours. A slightly more efficient way to code the function below is to concatenate the
-- hours to the output of the utils.MillisecondsToTime function (if hours > 0). I already coded
-- this function before knowing this fact though, so I'm leaving this function as is.
--
-- Converts a given amount of time in milliseconds to hh:mm:ss format
-- Returns the converted time as text [String]
-- Parameters
--    milliseconds : time in milliseconds to be converted [Int/Float]
function convertToTime(milliseconds)
    -- if-statment below is needed or else the returned string is messed up when milliseconds is
    -- equal to negative zero 
    if milliseconds == 0 then
        return "00:00.000"
    end
    
    local millisecondsLeft = milliseconds
    local hours = math.floor(millisecondsLeft / (1000 * 60 * 60))
    millisecondsLeft = millisecondsLeft % (1000 * 60 * 60)
    local minutes = math.floor(millisecondsLeft / (1000 * 60))
    millisecondsLeft = millisecondsLeft % (1000 * 60)
    local seconds = math.floor(millisecondsLeft / 1000)
    millisecondsLeft = millisecondsLeft % 1000
    
    local time = ""
    if hours > 0 then
        time =  hours..":"
    end
    if minutes < 10 then
        time = time.."0"
    end
    time = time..minutes..":"
    if seconds < 10 then
        time = time.."0"
    end
    time = time..seconds.."."
    if millisecondsLeft < 10 then
        time = time.."0"
    end
    if millisecondsLeft < 100 then
        time = time.."0"
    end
    -- have the time displayed down to the millisecond, no fractions of a millisecond
    time = time..(math.floor(millisecondsLeft))
    return time
end
-- Forces a number to be a multiple of one quarter (0.25)
-- Returns the result of the force [Int/Float]
-- Parameters
--    x : number to force to be a multiple of one quarter [Int/Float]
function forceQuarter(x)
    return (math.floor(x * 4 + 0.5)) / 4
end
----*** FUNCTION BELOW COPIED FROM iceSV ***
function generateBezierSetIceSV(P1_x, P1_y, P2_x, P2_y, averageSV, intermediatePoints, interlace, interlaceMultiplier)
    local stepInterval = 1/intermediatePoints

    -- the larger this number, the more accurate the final sv is
    -- ... and the longer it's going to take
    local totalSampleSize = 2500
    local allBezierSamples = {}
    
    for t=0, 1, 1/totalSampleSize do
        local x = mathCubicBezier({0, P1_x, P2_x, 1}, t)
        local y = mathCubicBezier({0, P1_y, P2_y, 1}, t)
        table.insert(allBezierSamples, {x=x,y=y})
    end

    local positions = {}

    local currentPoint = 0
    for sampleCounter = 1, totalSampleSize, 1 do
        if allBezierSamples[sampleCounter].x > currentPoint then
            table.insert(positions, allBezierSamples[sampleCounter].y)
            currentPoint = currentPoint + stepInterval
        end
    end

    local bezierSet = {}
    for i = 2, intermediatePoints do
        local velocity = (positions[i] - (positions[i-1] or 0)) * averageSV * intermediatePoints
        velocity = math.floor(velocity * 100 + 0.5) / 100
        table.insert(bezierSet, velocity)
        if interlace and (i ~= intermediatePoints) then
            table.insert(bezierSet, velocity * interlaceMultiplier)
        end
    end
    return bezierSet
end
-- Calculates a single set of exponential values
-- Returns the set of exponential values [Table]
-- Parameters
--    exponentialIncrease : whether or not the values will be exponentially increasing [Boolean]
--    numValues           : total number of values in the exponential set (including the end) [Int]
--    avgSV               : intended average value of the set [Int/Float]
--    intensity           : value determining sharpness/rapidness of exponential change [Int/Float]
--    interlace           : whether or not to interlace another exponential set inbetween [Boolean]
--    interlaceMultiplier : multiplier of interlaced values relalative to usual values [Int/Float]
function generateExponentialSet(exponentialIncrease, numValues, avgSV, intensity, interlace,
                                interlaceMultiplier)
    local exponentialSet = {}
    -- reduce intensity scaling to produce more managable numbers
    intensity = intensity / 10
    for i = 0, numValues - 1 do
        local x 
        if exponentialIncrease then
            x = (i + 0.5) * intensity / numValues  
        else
            x = (numValues - i - 0.5) * intensity / numValues  
        end
        local velocity = (math.exp(x) / math.exp(1)) / intensity
        table.insert(exponentialSet, velocity)
        -- adds interlaced values when appropriate
        if interlace and (i ~= numValues - 1) then
            table.insert(exponentialSet, velocity * interlaceMultiplier)
        end
    end
    normalizeValues(exponentialSet, avgSV, false)
    return exponentialSet
end
-- Generates a linear set of equally-spaced numbers between two numbers (inclusive)
-- Returns the linear set of numbers [Table]
-- Parameters
--    startVal   : starting value of the set [Int/Float]
--    endVal     : ending value of the set [Int/Float]
--    numValues  : total number of values in the linear set (including the end) [Int]
--    interlace  : whether or not to interlace another set of linear SVs inbetween [Boolean]
--    interStart : starting value of the interlace [Int/Float]
--    interEnd   : ending value of the interlace [Int/Float]
function generateLinearSet(startVal, endVal, numValues, interlace, interStart, interEnd)
    local linearSet = {}
    if numValues > 1 then
        local increment = (endVal - startVal) / (numValues - 1)
        local interlaceIncrement = (interEnd - interStart) / (numValues - 1)
        for i = 0, numValues - 1 do
            table.insert(linearSet, startVal + i * increment)
            if interlace and (i ~= numValues - 1) then
                table.insert(linearSet, interStart + i * interlaceIncrement)
            end
        end
    elseif numValues == 1 then
        table.insert(linearSet, startVal)
        table.insert(linearSet, interStart)
    end
    return linearSet
end
-- Generates a single set of sinusoidal values
-- Returns the set of sinusoidal values [Table]
-- Parameters
--    startAmplitude         : starting amplitude of the sinusoidal wave [Int/Float]
--    endAmplitude           : ending amplitude of the sinusoidal wave [Int/Float]
--    periods                : number of periods/cycles of the sinusoidal wave [Int/Float]
--    periodsShift           : number of periods/cycles to shift the sinusoidal wave [Int/Float]
--    valuesPerQuarterPeriod : number of values to calculate per quarter period/cycle [Int/Float]
function generateSinusoidalSet(startAmplitude, endAmplitude, periods, periodsShift,
                               valuesPerQuarterPeriod)
    local sinusoidalSet = {}
    local quarterPeriods = 4 * periods
    local quarterPeriodsShift = 4 * periodsShift
    local totalSVs = valuesPerQuarterPeriod * quarterPeriods
    local amplitudes = generateLinearSet(startAmplitude, endAmplitude, totalSVs + 1, false, 0, 0)
    for i = 0, totalSVs do
        local angle = (math.pi / 2) * ((i / valuesPerQuarterPeriod) + quarterPeriodsShift)
        local velocity = amplitudes[i + 1] * math.sin(angle)
        table.insert(sinusoidalSet, velocity)
    end
    return sinusoidalSet
end
-- Calculates the second SV value for a stutter SV
-- Returns the second SV value for the stutter SV [Int/Float]
-- Parameters
--    startSV         : velocity of first SV in the stutter [Int/Float]
--    stutterDuration : duration (ratio) of the first SV in the stutter [Float]
--    avgSV           : average SV of the stutter [Int/Float]
function calculateSecondStutterValue(startSV, stutterDuration, avgSV)
    return (avgSV - startSV * stutterDuration) / (1 - stutterDuration)
end
-- Generates a single set of stutter values
-- Returns the set of stutter values [Table]
-- Parameters
--    startSV         : velocity of first SV in the stutter [Int/Float]
--    stutterDuration : duration (ratio) of the first SV in the stutter [Float]
--    avgSV           : average SV of the stutter [Int/Float]
function generateStutterSet(startSV, stutterDuration, avgSV)
    stutterSet = {startSV} 
    table.insert(stutterSet, calculateSecondStutterValue(startSV, stutterDuration, avgSV))
    return stutterSet
end
-- Calculates the average value of a set of numbers
-- Returns the average value of the set [Int/Float]
-- Parameters
--    values                    : set of numbers [Table]
--    includeLastValueInAverage : whether or not to include the last value in the average [Boolean]
function getAverage(values, includeLastValueInAverage)
    if #values == 0 then
        return nil
    end
    if includeLastValueInAverage then
        return totalSum(values, includeLastValueInAverage) / #values
    else
        return totalSum(values, includeLastValueInAverage) / (#values - 1)
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
----*** FUNCTION BELOW COPIED FROM iceSV ***
function mathCubicBezier(P, t)
    return P[1] + 3*t*(P[2]-P[1]) + 3*t^2*(P[1]+P[3]-2*P[2]) + t^3*(P[4]-P[1]+3*P[2]-3*P[3])
end
-- Normalizes a set of values to achieve a target average
-- Parameters
--    values                    : set of numbers [Table]
--    targetAverage             : average value that is aimed for [Int/Float]
--    includeLastValueInAverage : whether or not to include the last value in the average [Boolean]
function normalizeValues(values, targetAverage, includeLastValueInAverage)
    local valuesAverage = getAverage(values, includeLastValueInAverage)
    for i = 1, #values do
        values[i] = (values[i] * targetAverage) / valuesAverage
    end
end
-- Rounds a number to a given amount of decimal places
-- Returns the rounded number [Int/Float]
-- Parameters
--    x             : number to round [Table]
--    decimalPlaces : number of decimal places to round the number to [Int]
function round(x, decimalPlaces)
    local multiplier = 10 ^ decimalPlaces
    return math.floor(x * multiplier + 0.5) / multiplier
end
-- Calculates the total sum of a set of numbers
-- Returns the total sum of the set [Int/Float]
-- Parameters
--    values           : set of numbers [Table]
--    includeLastValue : whether or not to include the last value in the sum [Boolean]
function totalSum(values, includeLastValue)
    local sum = 0
    local endIndex = #values
    if (not includeLastValue) then
        endIndex = endIndex - 1
    end
    for i = 1, endIndex do
        sum = sum + values[i]
    end
    return sum
end

-------------------------------------------------------------------------------- Graph/Plot Related

-- Calculates distance vs time values of a note given a set of SV values
-- Returns the list of distances [Table]
-- Parameters
--    svValues        : set of SV values [Table]
--    stutterDuration : duration of stutter SV (if applicable) [Int/Float]
function calculateDistanceVsTime(svValues, stutterDuration)
    local distance = 0
    local distancesBackwards = {distance}
    if stutterDuration ~= nil then -- stutter
        for i = 1, 100 do
            if i < (1 - stutterDuration) * 100 then
                distance = distance + svValues[2]
            else
                distance = distance + svValues[1]
            end
            table.insert(distancesBackwards, distance)
        end
    else -- non-stutter
        local svValuesBackwards = getReverseTable(svValues, true)
        for i = 1, #svValuesBackwards do
            distance = distance + svValuesBackwards[i]
            table.insert(distancesBackwards, distance)
        end
    end
    return getReverseTable(distancesBackwards, false)
end
-- Calculates the minimum and maximum scale of a plot
-- Returns the minimum scale and maximum scale [Int/Float]
-- Parameters
--    values : set of numbers to calculate plot scale for [Table]
function calculatePlotScale(values)
    local min = math.min(table.unpack(values))
    local max = math.max(table.unpack(values))
    local absMax = math.max(math.abs(min), math.abs(max))
    -- as the default, set the plot range to +- the absolute max value
    local minScale = -absMax
    local maxScale = absMax
    -- restrict the plot range to non-positive values when all values are non-positive
    if max <= 0 then
        maxScale = 0
    -- restrict the plot range to non-negative values when all values are non-negative
    elseif min >= 0 then
        minScale = 0
    end
    return minScale, maxScale
end
-- Creates a distance vs time graph/plot of note motion
-- Parameters
--    noteDistances : list of note distances [Table]
function plotNotePath(noteDistances)
    imgui.Text("Projected Note Motion (Distance vs Time):")
    minScale, maxScale = calculatePlotScale(noteDistances)
    imgui.PlotLines("     ", noteDistances, #noteDistances, 0, "", minScale, maxScale,
                    {ACTION_BUTTON_SIZE[1], 100})
end
-- Creates a bar graph/plot of SVs
-- Parameters
--    svVals : list of numerical SV values [Table]    
--    svName : name of the SV type being plotted [String]
function plotSVs(svVals, svName)
    imgui.Text("Projected "..svName.." SVs:")
    minScale, maxScale = calculatePlotScale(svVals)
    imgui.PlotHistogram("   ", svVals, #svVals, 0, "", minScale, maxScale, 
                        {ACTION_BUTTON_SIZE[1], 100})
end

---------------------------------------------------------------------------------------------- MISC

-- Finds unique offsets of all notes currently selected in the Quaver map editor
-- Returns a list of unique offsets (in increasing order) of selected notes [Table]
function uniqueSelectedNoteOffsets()
    local offsets = {}
    for i, hitObject in pairs(state.SelectedHitObjects) do
        offsets[i] = hitObject.StartTime
    end
    offsets = removeDuplicateValues(offsets)
    offsets = table.sort(offsets, function(a, b) return a < b end)
    return offsets
end
-- Combs through a list and locates unique values
-- Returns a list of only unique values (no duplicates) [Table]
-- Parameters
--    list : list of values [Table]
function removeDuplicateValues(list)
    local hash = {}
    local newList = {}
    for _, value in ipairs(list) do
        -- if the value is not already in the new list
        if (not hash[value]) then
            -- add the value to the new list
            newList[#newList + 1] = value
            hash[value] = true
        end
    end
    return newList
end
-- Constructs a new table from an old table with the order reversed
-- Returns the reversed table [Table]
-- Parameters
--    oldTable      : table to be reversed [Table]
--    skipLastValue : whether or not to leave out the last value of the original table [Boolean]
function getReverseTable(oldTable, skipLastValue)
    local lastIndex = #oldTable
    if skipLastValue then
        lastIndex = lastIndex - 1
    end
    local reverseTable = {}
    for i = 1, lastIndex do
        table.insert(reverseTable, oldTable[lastIndex + 1 - i])
    end
    return reverseTable
end

-- Updates SVs stored in menus
function updateMenuSVs(vars, toolIndex, svSetInfo)
    local generatorFunctionName = "generate"..TOOL_OPTIONS[toolIndex].."Set"
    vars.svValues = _G[generatorFunctionName](table.unpack(svSetInfo))
    vars.noteDistanceVsTime = calculateDistanceVsTime(vars.svValues, vars.stutterDuration)
    vars.svValuesPreview = {}
    for i = 1, #vars.svValues do
        table.insert(vars.svValuesPreview, vars.svValues[i])
    end
    if vars.endSVOption ~= 1 and (vars.stutterDuration == nil) then
        table.remove(vars.svValuesPreview, #vars.svValuesPreview)
    end
    if vars.endSVOption == 3 then
        table.insert(vars.svValuesPreview, 1)
    end
end

-- Displays info/stats about the current menu's projected SVs
-- Parameters
--    vars : variables of the current SV tool menu [Table]
function displaySVStats(vars)
    imgui.Columns(2, "SV Stats", false)
    if vars.stutterDuration == nil then -- non-stutter SV
        local svValuesAverage = round(getAverage(vars.svValues, false), 2)
        local tempLastValue = table.remove(vars.svValues, #vars.svValues)
        local maxSV = round(math.max(table.unpack(vars.svValues)), 2)
        local minSV = round(math.min(table.unpack(vars.svValues)), 2)
        table.insert(vars.svValues, tempLastValue)
        imgui.Text("Max SV:")
        imgui.Text("Min SV:")
        imgui.Text("Average SV:")
        imgui.NextColumn()
        imgui.Text(maxSV.."x")
        imgui.Text(minSV.."x")
        imgui.Text(svValuesAverage.."x")
    else -- stutter SV
        local firstSV = round(vars.svValues[1], 2)
        local firstDurationPerc = round(vars.stutterDuration * 100, 0)
        local secondSV = round(vars.svValues[2], 2)
        local secondDurationPerc = round((1 - vars.stutterDuration) * 100, 0)
        local roundedAvgSV = round(vars.avgSV, 2)
        imgui.Text("First SV:")
        imgui.Text("Second SV:")
        imgui.Text("Average SV:")
        imgui.NextColumn()
        imgui.Text(firstSV.."x  ("..firstDurationPerc.."%% duration)")
        imgui.Text(secondSV.."x  ("..secondDurationPerc.."%% duration)")
        imgui.Text(roundedAvgSV.."x")
    end
    imgui.Columns(1)
end