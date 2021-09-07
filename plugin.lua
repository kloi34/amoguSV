-- amoguSV pre-v2.0 (7 Sept 2021) 
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
--      1. Redesign bezier tab
--      2. Fix sinusoidal, single, and remove menus to be accessible work again.

--      1. Fix bezier tab and bezier calculation for iceSV method
--      2. Revamp + upgrade the "Remove" menu
--      3. Adding tooltips to widgets
--      4. Implement different Cubic bezier calculation (right now, uses iceSV method
--         which is slow/laggy when the live sv graphs update every time settings change)
--      5. Change bezier points to slider instead of input
--      6. ADD comments, review code, review overall structure of the code,
--         refactoring code

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
RADIO_BUTTON_SPACING = 7.5         -- value determining spacing between IMGUI radio buttons
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
    --"%(^w^%)",
    "%( - _ - )",
    "%( e.e %)",
    "%(o_0%)",
    "%(*o*%)",
    "%(~_~%)",
    "%(>.<%)",
    "%( ; _ ; %)"
    --"%(w.w)"
}
END_SV_TYPES = {                   -- options for the last SV placed at the tail end of all SVs
    "Normal",
    "Skip",
    "1.00x"   
}
SV_TOOLS = {                       -- list of the available tools for editing SVs
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
    setPluginAppearance()
    createMainMenu()
end
-- Configures GUI styles (colors and appearance)
function setPluginAppearance()
    -- Plugin Styles
    local rounding = 5 -- determines how rounded corners are
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
    local globalVars = {
        currentMenuNum = 1,
        placeSVsBetweenOffsets = false
    }
    retrieveStateVariables("Global", globalVars)
    
    local navHovered = createNavigationDropdown(globalVars)
    
    local menuName = SV_TOOLS[globalVars.currentMenuNum]
    local menuVars = declareMenuVariables(menuName)
    retrieveStateVariables(menuName, menuVars)
    imgui.Columns(2, "SV Menu Panels", false)
    local leftPanelHovered, svUpdateNeeded = createSettingsPanel(globalVars, menuVars, menuName)
    if svUpdateNeeded then
        --!! REMOVE WHEN DONE !! --
        imgui.Text("Debug: Variables changing")
        --!! REMOVE WHEN DONE !! --
        updateMenuSVs(globalVars, menuVars, menuName)
    end
    imgui.NextColumn()
    local rightPanelHovered = createRightPanel(globalVars, menuVars, menuName)

    saveStateVariables(menuName, menuVars)
    saveStateVariables("Global", globalVars)
    state.IsWindowHovered = navHovered or leftPanelHovered or rightPanelHovered
    imgui.End()
end
-- Creates the settings menu for linear SV
-- Returns whether or not menu-specific SV information has changed and needs an update [Boolean]
-- Parameters
--    globalVars : list of global variables used across all tools/menus [Table]
--    menuVars   : list of variables used for this linear menu [Table]
--    menuName   : name of this menu [String]
function linearSettingsMenu(globalVars, menuVars, menuName)
    local svUpdateNeeded = #menuVars.svValues == 0
    svUpdateNeeded = chooseStartEndSVs(menuVars, true) or svUpdateNeeded
    svUpdateNeeded = chooseSVPoints(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseEndSV(menuVars, false) or svUpdateNeeded
    svUpdateNeeded = chooseInterlace(menuVars, menuName, true) or svUpdateNeeded
    chooseTeleportSV(globalVars, menuVars, menuName)
    chooseDisplacement(globalVars, menuVars)
    return svUpdateNeeded
end
-- Creates the settings menu for exponential SV
-- Returns whether or not menu-specific SV information has changed and needs an update [Boolean]
-- Parameters
--    globalVars : list of global variables used across all tools/menus [Table]
--    menuVars   : list of variables used for this exponential menu [Table]
--    menuName   : name of this menu [String]
function exponentialSettingsMenu(globalVars, menuVars, menuName)
    local svUpdateNeeded = #menuVars.svValues == 0
    svUpdateNeeded = chooseExponentialBehavior(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseIntensity(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseAverageSV(menuVars, false) or svUpdateNeeded
    svUpdateNeeded = chooseSVPoints(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseEndSV(menuVars, false) or svUpdateNeeded
    svUpdateNeeded = chooseInterlace(menuVars, menuName, false) or svUpdateNeeded
    chooseTeleportSV(globalVars, menuVars, menuName)
    chooseDisplacement(globalVars, menuVars)
    return svUpdateNeeded
end
-- Creates the settings menu for stutter/bump SV
-- Returns whether or not menu-specific SV information has changed and needs an update [Boolean]
-- Parameters
--    globalVars : list of global variables used across all tools/menus [Table]
--    menuVars   : list of variables used for this stutter menu [Table]
--    menuName   : name of this menu [String]
function stutterSettingsMenu(globalVars, menuVars, menuName)
    local svUpdateNeeded = #menuVars.svValues == 0
    imgui.Text("First SV:")
    svUpdateNeeded = chooseStartEndSVs(menuVars, menuVars.linearStutter) or svUpdateNeeded
    svUpdateNeeded = chooseStutterDuration(menuVars, menuVars.linearStutter) or svUpdateNeeded
    svUpdateNeeded = chooseAverageSV(menuVars, menuVars.linearStutter) or svUpdateNeeded
    svUpdateNeeded = chooseEndSV(menuVars, true) or svUpdateNeeded
    svUpdateNeeded = chooseLinearStutter(menuVars) or svUpdateNeeded
    return svUpdateNeeded
end
-- Creates the settings menu for bezier SV
-- Returns whether or not menu-specific SV information has changed and needs an update [Boolean]
-- Parameters
--    globalVars : list of global variables used across all tools/menus [Table]
--    menuVars   : list of variables used for this bezier menu [Table]
--    menuName   : name of this menu [String]
function bezierSettingsMenu(globalVars, menuVars, menuName)
    local svUpdateNeeded = #menuVars.svValues == 0
    svUpdateNeeded = chooseBezierCalculationMethod(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseBezierPoints(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseAverageSV(menuVars, false) or svUpdateNeeded
    svUpdateNeeded = chooseSVPoints(menuVars) or svUpdateNeeded
    -- maybe replace line below with "svUpdateNeeded = chooseEndSV(menuVars, false) or svUpdateNeeded" instead
    svUpdateNeeded = chooseEndSV(menuVars, true) or svUpdateNeeded
    svUpdateNeeded = chooseInterlace(menuVars, menuName, false) or svUpdateNeeded
    chooseTeleportSV(globalVars, menuVars, menuName)
    chooseDisplacement(globalVars, menuVars)
    return svUpdateNeeded
end
-- Creates the "Sinusoidal SV" menu
-- Parameters
--    menuName : name of the menu [String]
function sinusoidalSettingsMenu(menuName, menuIndex, placeSVsBetweenOffsets)
    local menuVars = declareMenuVariables(menuName)
    retrieveStateVariables(menuName, menuVars)
    local svUpdateNeeded = #menuVars.svValues == 0
    
    imgui.Text("Amplitude:")
    svUpdateNeeded = chooseStartEndSVs(menuVars, true) or svUpdateNeeded
    addSeparator()
    local oldPeriods = menuVars.periods
    _, menuVars.periods = imgui.InputFloat("Periods/Cycles", menuVars.periods, 0.25, 0.25, "%.2f")
    menuVars.periods = forceQuarter(menuVars.periods)
    menuVars.periods = clampToInterval(menuVars.periods, 0.25, 20)
    svUpdateNeeded = svUpdateNeeded or (oldPeriods ~= menuVars.periods)
    local oldPeriodsShift = menuVars.periodsShift
    _, menuVars.periodsShift = imgui.InputFloat("Phase Shift", menuVars.periodsShift, 0.25, 0.25,
                                            "%.2f")
    menuVars.periodsShift = forceQuarter(menuVars.periodsShift)
    menuVars.periodsShift = clampToInterval(menuVars.periodsShift, 0, 0.75)
    svUpdateNeeded = svUpdateNeeded or (oldPeriodsShift ~= menuVars.periodsShift)
    addPadding()
    imgui.Text("For every 0.25 period/cycle, place...")
    local oldPerQuarterPeriod = menuVars.svsPerQuarterPeriod
    _, menuVars.svsPerQuarterPeriod = imgui.InputInt("SV points", menuVars.svsPerQuarterPeriod)
    menuVars.svsPerQuarterPeriod = clampToInterval(menuVars.svsPerQuarterPeriod, 1, 50)
    svUpdateNeeded = svUpdateNeeded or (oldPerQuarterPeriod ~= menuVars.svsPerQuarterPeriod)
    addPadding()
    svUpdateNeeded = chooseEndSV(menuVars, true) or svUpdateNeeded
    chooseTeleportSV(menuVars, menuName, placeSVsBetweenOffsets)
    addSeparator()
    chooseDisplacement(menuVars, placeSVsBetweenOffsets)
    imgui.EndChild()
    
    imgui.NextColumn()
    local svSetInfo = {menuVars.startSV, menuVars.endSV, menuVars.periods, menuVars.periodsShift,
                       menuVars.svsPerQuarterPeriod}
    placeSVsBetweenOffsets = rightPanel(svUpdateNeeded, menuVars, menuName, svSetInfo, menuIndex, placeSVsBetweenOffsets)
    saveStateVariables(menuName, menuVars)
    return placeSVsBetweenOffsets
end
-- Creates the "Single SV" menu
-- Parameters
--    menuName : name of the menu [String]
function singleSettingsMenu(menuName, menuIndex, placeSVsBetweenOffsets)
    local menuVars = {
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
    retrieveStateVariables(menuName, menuVars)

    if menuVars.svBefore then
        imgui.Text("Before note:")
        if menuVars.scaleSVLinearly then
            local beforeSVValues = {menuVars.svValueBefore, menuVars.svValueBeforeEnd}
            _, beforeSVValues = imgui.InputFloat2("Start/End SV", beforeSVValues, "%.2fx")
            menuVars.svValueBefore, menuVars.svValueBeforeEnd = table.unpack(beforeSVValues)
            menuVars.svValueBeforeEnd = clampToInterval(menuVars.svValueBeforeEnd, -MAX_TELEPORT_VALUE,
                                              MAX_TELEPORT_VALUE)
        else
            _, menuVars.svValueBefore = imgui.InputFloat("SV value", menuVars.svValueBefore, 0, 0, "%.2fx")
        end
        menuVars.svValueBefore = clampToInterval(menuVars.svValueBefore, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        _, menuVars.incrementBefore = imgui.InputFloat("Time before", menuVars.incrementBefore, 0, 0,
                                                   "%.3f ms")
        menuVars.incrementBefore = clampToInterval(menuVars.incrementBefore, MIN_DURATION, MAX_DURATION)
    end
    if (not menuVars.skipSVAtNote) then
        if menuVars.svBefore then
            addPadding()
        end
        imgui.Text("At note:")
        if menuVars.scaleSVLinearly then
            local atNoteSVValues = {menuVars.svValue, menuVars.svValueEnd}
            _, atNoteSVValues = imgui.InputFloat2("Start/End SV ", atNoteSVValues, "%.2fx")
            menuVars.svValue, menuVars.svValueEnd = table.unpack(atNoteSVValues)
            menuVars.svValueEnd = clampToInterval(menuVars.svValueEnd, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        else
            _, menuVars.svValue = imgui.InputFloat("SV value ", menuVars.svValue, 0, 0, "%.2fx")
        end
        menuVars.svValue = clampToInterval(menuVars.svValue, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
    end
    if menuVars.svAfter then
        if menuVars.svBefore or (not menuVars.skipSVAtNote) then
            addPadding()
        end
        imgui.Text("After note:")
        if menuVars.scaleSVLinearly then
            local afterSVValues = {menuVars.svValueAfter, menuVars.svValueAfterEnd}
            _, afterSVValues = imgui.InputFloat2("Start/End SV  ", afterSVValues, "%.2fx")
            menuVars.svValueAfter, menuVars.svValueAfterEnd = table.unpack(afterSVValues)
            menuVars.svValueAfterEnd = clampToInterval(menuVars.svValueAfterEnd, -MAX_TELEPORT_VALUE,
                                             MAX_TELEPORT_VALUE)
        else
            _, menuVars.svValueAfter = imgui.InputFloat("SV value  ", menuVars.svValueAfter, 0, 0, "%.2fx")
        end
        menuVars.svValueAfter = clampToInterval(menuVars.svValueAfter, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        _, menuVars.incrementAfter = imgui.InputFloat("Time After", menuVars.incrementAfter, 0, 0,
                                                   "%.3f ms")
        menuVars.incrementAfter = clampToInterval(menuVars.incrementAfter, MIN_DURATION, MAX_DURATION)
    end
    local inputExists = menuVars.svBefore or (not menuVars.skipSVAtNote) or menuVars.svAfter
    if inputExists then
        addSeparator()
    end
    _, menuVars.svBefore = imgui.Checkbox("Add SV before note", menuVars.svBefore)
    _, menuVars.svAfter = imgui.Checkbox("Add SV after note", menuVars.svAfter)
    _, menuVars.skipSVAtNote = imgui.Checkbox("Skip SV at note", menuVars.skipSVAtNote)
    _, menuVars.scaleSVLinearly = imgui.Checkbox("Scale SV values linearly over time", menuVars.scaleSVLinearly)
    imgui.EndChild()
    
    imgui.NextColumn()
    imgui.BeginChild("Right Menu", MENU_SIZE_RIGHT)
    if inputExists then
        if imgui.Button("Place SVs At All Selected Notes", ACTION_BUTTON_SIZE) then
            local SVs = calculateSingleSV(menuVars.skipSVAtNote, menuVars.svBefore, menuVars.svValueBefore,
                                          menuVars.incrementBefore, menuVars.svAfter, menuVars.svValueAfter,
                                          menuVars.incrementAfter, menuVars.svValue, menuVars.scaleSVLinearly,
                                          menuVars.svValueBeforeEnd, menuVars.svValueEnd,
                                          menuVars.svValueAfterEnd)
            if #SVs > 0 then
                actions.PlaceScrollVelocityBatch(SVs)
            end
        end
    end
    saveStateVariables(menuName, menuVars)
    return placeSVsBetweenOffsets
end
-- Creates the "Remove SV" menu
-- Parameters
--    menuName : name of the menu [String]
function removeSettingsMenu(menuName, menuIndex, placeSVsBetweenOffsets)
    local menuVars = {
        startOffset = 0,
        endOffset = 0,
        inputTime = false
    }
    retrieveStateVariables(menuName, menuVars)
    
    local currentButtonSize = {0.6 * DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT}
    local halfWidgetWidth = 100
    imgui.Text("Remove SVs...")
    addPadding()
    imgui.AlignTextToFramePadding()
    imgui.Text("From")
    imgui.SameLine(0, 2 * SAMELINE_SPACING)
    if menuVars.inputTime then
        imgui.PushItemWidth(halfWidgetWidth)
        _, menuVars.startOffset = imgui.InputFloat("", menuVars.startOffset, 0, 0, "%.3f ms")
        imgui.PopItemWidth()
        imgui.SameLine(0, 2 * SAMELINE_SPACING + 2)
    else
        imgui.Text(":  "..convertToTime(menuVars.startOffset).." (Start) ")
        imgui.SameLine(0, 2 * SAMELINE_SPACING + 3)
    end
    if imgui.Button("Set Current", currentButtonSize) then
        menuVars.startOffset = math.floor(state.SongTime)
    end
    menuVars.startOffset = clampToInterval(menuVars.startOffset, 0, MAX_MS_TIME)
    imgui.AlignTextToFramePadding()
    imgui.Indent(imgui.CalcTextSize("From")[1] - imgui.CalcTextSize("To")[1])
    imgui.Text("To")
    imgui.Unindent(imgui.CalcTextSize("From")[1] - imgui.CalcTextSize("To")[1])
    imgui.SameLine(0, 2 * SAMELINE_SPACING)
    if menuVars.inputTime then
        imgui.PushItemWidth(halfWidgetWidth)
        _, menuVars.endOffset = imgui.InputFloat(" ", menuVars.endOffset, 0, 0, "%.3f ms")
        imgui.SameLine(0, SAMELINE_SPACING)
    else
        imgui.Text(":  "..convertToTime(menuVars.endOffset).." (End)")
        imgui.SameLine(0, 4 * SAMELINE_SPACING + 2)
    end
    if imgui.Button(" Set Current ", currentButtonSize) then
        menuVars.endOffset = math.floor(state.SongTime)
    end
    menuVars.endOffset = clampToInterval(menuVars.endOffset, 0, MAX_MS_TIME)
    addPadding()
    _, menuVars.inputTime = imgui.Checkbox("Manually input time", menuVars.inputTime)
    imgui.EndChild()
    
    imgui.NextColumn()
    imgui.BeginChild("Right Menu", MENU_SIZE_RIGHT)
    if imgui.Button("Remove SVs Between Times", ACTION_BUTTON_SIZE) then
        removeSVs(menuVars.startOffset, menuVars.endOffset)
    end
    saveStateVariables(menuName, menuVars)
    return placeSVsBetweenOffsets
end
-- Creates the right panel menu for seeing SV stats and placing SV
-- Returns whether or not this right panel is hovered over [Boolean]
-- Parameters
--    globalVars : list of global variables used across all tools/menus [Table]
--    menuVars   : list of variables used for this stutter menu [Table]
--    menuName   : name of this menu [String]
function createRightPanel(globalVars, menuVars, menuName)
    imgui.BeginChild("Right Panel", MENU_SIZE_RIGHT)
    local isPanelHovered = imgui.IsWindowHovered()
    if not (globalVars.placeSVsBetweenOffsets or menuVars.linearStutter) then
        plotNotePath(menuVars.noteDistanceVsTime)
        addSeparator()
    end
    if menuVars.linearStutter then
        plotSVs(menuVars.svValuesPreview, "First Stutter")
        addSeparator()
        plotSVs(menuVars.svValuesSecondPreview, "Last Stutter")
    else
        plotSVs(menuVars.svValuesPreview, menuName)
    end
    displaySVStats(menuVars)
    addSeparator()
    chooseSVPlacementType(globalVars, menuVars)
    createPlaceSVButton(globalVars, menuVars)
    imgui.EndChild()
    return isPanelHovered
end

---------------------------------------------------------------------------------------------------
-- Calculation/helper functions
---------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------- Variable Management

-- Retrieves variables from the state
-- Parameters
--    menuName    : name of the menu that the variables are from [String]
--    variables : table of variables and values [Table]
function retrieveStateVariables(menuName, variables)
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(menuName..key) or value
    end
end
-- Saves variables to the state
-- Parameters
--    menuName    : name of the menu that the variables are from [String]
--    variables : table of variables and values [Table]
function saveStateVariables(menuName, variables)
    for key, value in pairs(variables) do
        state.SetValue(menuName..key, value)
    end
end

----------------------------------------------------------------------------------------- IMGUI GUI

-- Adds vertical blank space/padding on the GUI
function addPadding()
    imgui.Dummy({0, 0})
end
-- Draws a horizontal line separator on the GUI
function addSeparator()
    addPadding()
    imgui.Separator()
    addPadding()
end

------------------------------------------------------------------------------------- IMGUI Widgets

-- Lets users choose the average SV
-- Returns whether or not a new average SV was inputted [Boolean]
-- Parameters
--    menuVars : reference to the list of variables for a menu [Table]
function chooseAverageSV(menuVars, chooseBothSVs)
    local oldAvgValues = {menuVars.avgSV, menuVars.linearEndAvgSV}
    if chooseBothSVs then
        local _, newAvgValues = imgui.InputFloat2("Start/End Avg", oldAvgValues, "%.2fx")
        menuVars.avgSV, menuVars.linearEndAvgSV = table.unpack(newAvgValues)
        menuVars.avgSV = clampToInterval(menuVars.avgSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
        menuVars.linearEndAvgSV = clampToInterval(menuVars.linearEndAvgSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    else 
        _, menuVars.avgSV = imgui.InputFloat("Average SV", menuVars.avgSV, 0, 0, "%.2fx")
        menuVars.avgSV = clampToInterval(menuVars.avgSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    end
    local startValueChanged = oldAvgValues[1] ~= menuVars.avgSV
    local endValueChanged = oldAvgValues[2] ~= menuVars.linearEndAvgSV
    return startValueChanged or endValueChanged
end
-- Lets users choose and adjust displacment SV options
-- Parameters
--    menuVars : reference to the list of variables for a menu [Table]
--    globalVars
function chooseDisplacement(globalVars, menuVars)
    addSeparator()
    if (not globalVars.placeSVsBetweenOffsets) then
        _, menuVars.displace = imgui.Checkbox("Displace end notes' hit receptor/position", menuVars.displace)
        if menuVars.displace then
            _, menuVars.displacement = imgui.InputFloat("Height", menuVars.displacement, 0, 0, "%.2f msx")
            menuVars.displacement = clampToInterval(menuVars.displacement, -MAX_GENERAL_SV, MAX_GENERAL_SV)
        end
    end
end
-- Lets users choose the end SV type
-- Returns whether or not a new end SV was chosen [Boolean]
-- Parameters
--    menuVars     : reference to the list of variables for a menu [Table]
--    noNormal : whether or not to have the "Normal" end SV option [Boolean]
function chooseEndSV(menuVars, noNormal)
    local oldOption = menuVars.endSVOption
    local startIndex = 1
    if noNormal then
        startIndex = 2
    end
    addPadding()
    imgui.AlignTextToFramePadding()
    imgui.Text("Final SV:")
    imgui.SameLine(0, SAMELINE_SPACING)
    for i = startIndex, #END_SV_TYPES do
        if i ~= startNum then
            imgui.SameLine(0, RADIO_BUTTON_SPACING)
        end
        _, menuVars.endSVOption = imgui.RadioButton(END_SV_TYPES[i], menuVars.endSVOption, i)
    end
    return oldOption ~= menuVars.endSVOption
end
-- Lets users choose and adjust interlace SV options
-- Returns whether or not the interlace checkbox or the interlace multiplier changed [Boolean]
-- Parameters
--    menuVars : reference to the list of variables for a menu [Table]
--    menuName : name of the menu of the variables [String]
--    isLinear : 
function chooseInterlace(menuVars, menuName, isLinear)
    addSeparator()
    local oldInterlace = menuVars.interlace
    local oldMultiplier = menuVars.interlaceMultiplier
    local oldInterlaceValues = {menuVars.secondStartSV, menuVars.secondEndSV}
    _, menuVars.interlace = imgui.Checkbox("Interlace another "..string.lower(menuName), menuVars.interlace)
    if menuVars.interlace then
        if isLinear then
            local _, newInterlaceValues = imgui.InputFloat2("Start/End SV ", oldInterlaceValues, "%.2fx")
            menuVars.secondStartSV, menuVars.secondEndSV = table.unpack(newInterlaceValues)
            menuVars.secondStartSV = clampToInterval(menuVars.secondStartSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
            menuVars.secondEndSV = clampToInterval(menuVars.secondEndSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
        else
            _, menuVars.interlaceMultiplier = imgui.InputFloat("Lace multiplier",
                                                           menuVars.interlaceMultiplier, 0, 0, "%.2f")
            menuVars.interlaceMultiplier = clampToInterval(menuVars.interlaceMultiplier, -MAX_GENERAL_SV,
                                                 MAX_GENERAL_SV)
        end
    end
    local interlaceChanged = oldInterlace ~= menuVars.interlace
    local interlacedMultiplierChanged = oldMultiplier ~= menuVars.interlaceMultiplier
    local secondStartSVChanged = oldInterlaceValues[1] ~= menuVars.secondStartSV
    local secondEndSVChanged = oldInterlaceValues[2] ~= menuVars.secondEndSV
    return interlaceChanged or interlacedMultiplierChanged or secondStartSVChanged or secondEndSVChanged
end

--[[
function chooseSecondStartEndSVs(menuVars)
    local oldStartEndValues = {menuVars.startSV, menuVars.endSV}
    local _, newStartEndValues = imgui.InputFloat2("Start/End SV", oldStartEndValues, "%.2fx")
    menuVars.startSV, menuVars.endSV = table.unpack(newStartEndValues)
    menuVars.startSV = clampToInterval(menuVars.startSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    menuVars.endSV = clampToInterval(menuVars.endSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    local startValueChanged = oldStartEndValues[1] ~= menuVars.startSV
    local endValueChanged = oldStartEndValues[2] ~= menuVars.endSV
    return startValueChanged or endValueChanged
end
--]]

-- Lets users choose the number of SV points to place
-- Returns whether or not a new number of SV points was inputted [Boolean]
-- Parameters
--    menuVars : reference to the list of variables for a menu [Table]
function chooseSVPoints(menuVars)
    local oldSVPoints = menuVars.svPoints
    _, menuVars.svPoints = imgui.InputInt("SV points", menuVars.svPoints, 1, 1)
    menuVars.svPoints = clampToInterval(menuVars.svPoints, 1, 128)
    return oldSVPoints ~= menuVars.svPoints
end
-- Lets users choose and adjust teleport SV options
-- Parameters
--    globalVars 
--    menuVars
--    menuName
function chooseTeleportSV(globalVars, menuVars, menuName)
    addSeparator()
    _, menuVars.addTeleport = imgui.Checkbox("Add teleport SV at beginning", menuVars.addTeleport)
    if menuVars.addTeleport then
        _, menuVars.teleportValue = imgui.InputFloat("Teleport SV", menuVars.teleportValue, 0, 0, "%.2fx")
        menuVars.teleportValue = clampToInterval(menuVars.teleportValue, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        _, menuVars.teleportDuration = imgui.InputFloat("Duration", menuVars.teleportDuration, 0, 0,
                                                    "%.3f ms")
        menuVars.teleportDuration = clampToInterval(menuVars.teleportDuration, MIN_DURATION,
                                          MAX_TELEPORT_DURATION)
        if (not globalVars.placeSVsBetweenOffsets) then
            addPadding()
            if imgui.RadioButton("Very start", menuVars.veryStartTeleport) then
                menuVars.veryStartTeleport = true
            end
            imgui.SameLine(0, RADIO_BUTTON_SPACING)
            if imgui.RadioButton("Every "..string.lower(menuName).." set", not menuVars.veryStartTeleport) then
                menuVars.veryStartTeleport = false
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
    if displace and endSVOption ~= 2 then
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

function generateSVs(offsets, svValues, addTeleport, veryStartTeleport, teleportValue,
                     teleportDuration, endSVOption, displace, displacement, stutterDuration,
                     linearStutter, endSV, linearEndAvgSV, stutterAvgSV, placeSVsBetweenOffsets)
    local SVs = {}
    local startSVList = {}
    local avgSVList = {}
    if stutterDuration ~= nil and linearStutter then
        startSVList = generateLinearSet(svValues[1], endSV, #offsets - 1, false, 0, 0)
        avgSVList = generateLinearSet(stutterAvgSV, linearEndAvgSV, #offsets - 1, false, 0, 0)
    end
    for i = 1, #offsets - 1 do
        local startOffset = determineTeleport(offsets[i], addTeleport, veryStartTeleport,
                                              i == 1, teleportValue, teleportDuration, SVs)
        local endOffset = offsets[i + 1]
        if (not placeSVsBetweenOffsets) and displace then
            local notFirstSet = (i ~= 1)
            local middleTelportExists = (not addTeleport) or (addTeleport and veryStartTeleport)
            if notFirstSet and middleTelportExists then
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
            svOffsets = {startOffset, startOffset + offsetInterval * stutterDuration / 100, endOffset}
        end
        if linearStutter then
            local stutterFirstSV = startSVList[i]
            local stutterSecondSV = calculateSecondStutterValue(stutterFirstSV, stutterDuration, avgSVList[i])
            svValues = {stutterFirstSV, stutterSecondSV}
        end
        for j = 1, #svOffsets - 1 do
            table.insert(SVs, utils.CreateScrollVelocity(svOffsets[j], svValues[j]))
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
    -- reduce intensity scaling to produce more useful/practical values
    intensity = intensity / 5
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
--    stutterDuration : duration (percentage) of the first SV in the stutter [Float]
--    avgSV           : average SV of the stutter [Int/Float]
function calculateSecondStutterValue(startSV, stutterDuration, avgSV)
    local durationPercent = stutterDuration / 100
    return (avgSV - startSV * durationPercent) / (1 - durationPercent)
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
function clampToInterval(x, lowerBound, upperBound)
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
            if i < (100 - stutterDuration) then
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
-- Parameters
-- 
function updateMenuSVs(globalVars, menuVars, menuName)
    menuVars.svValues = {}
    if menuName == "Linear" then
        menuVars.svValues = generateLinearSet(menuVars.startSV, menuVars.endSV,
                                              menuVars.svPoints + 1, menuVars.interlace,
                                              menuVars.secondStartSV, menuVars.secondEndSV)
    elseif menuName == "Exponential" then
        menuVars.svValues = generateExponentialSet(menuVars.exponentialIncrease,
                                                   menuVars.svPoints + 1, menuVars.avgSV,
                                                   menuVars.intensity, menuVars.interlace,
                                                   menuVars.interlaceMultiplier)
    elseif menuName == "Stutter" then
        menuVars.svValues = generateStutterSet(menuVars.startSV, menuVars.stutterDuration,
                                               menuVars.avgSV)
    elseif menuName == "Bezier" then
        menuVars.svValues = generateBezierSetIceSV(menuVars.x1, menuVars.y1, menuVars.x2, menuVars.y2,
                                                   menuVars.avgSV, menuVars.svPoints + 2, menuVars.interlace,
                                                   menuVars.interlaceMultiplier)
    end
    menuVars.noteDistanceVsTime = calculateDistanceVsTime(menuVars.svValues, menuVars.stutterDuration)
    menuVars.svValuesPreview = {}
    for i = 1, #menuVars.svValues do
        table.insert(menuVars.svValuesPreview, menuVars.svValues[i])
    end
    if menuVars.stutterDuration ~=nil then
       menuVars.svValuesSecondPreview = generateStutterSet(menuVars.endSV,
                                                           menuVars.stutterDuration,
                                                           menuVars.linearEndAvgSV)
    end
    if menuVars.endSVOption ~= 1 and (menuVars.stutterDuration == nil) then
        table.remove(menuVars.svValuesPreview, #menuVars.svValuesPreview)
    end
    if menuVars.endSVOption == 3 then
        if menuVars.linearStutter then
            table.insert(menuVars.svValuesSecondPreview, 1)
        else
            table.insert(menuVars.svValuesPreview, 1)
        end
    end
end

-- Calculates and displays info/stats about the current menu's projected SVs
-- Parameters
--    menuVars : variables of the current SV tool menu [Table]
function displaySVStats(menuVars)
    imgui.Columns(2, "SV Stats", false)
    if menuVars.stutterDuration == nil then -- non-stutter SV
        local svValuesAverage = round(getAverage(menuVars.svValues, false), 2)
        local tempLastValue = table.remove(menuVars.svValues, #menuVars.svValues)
        local maxSV = round(math.max(table.unpack(menuVars.svValues)), 2)
        local minSV = round(math.min(table.unpack(menuVars.svValues)), 2)
        table.insert(menuVars.svValues, tempLastValue)
        imgui.Text("Max SV:")
        imgui.Text("Min SV:")
        imgui.Text("Average SV:")
        imgui.NextColumn()
        imgui.Text(maxSV.."x")
        imgui.Text(minSV.."x")
        imgui.Text(svValuesAverage.."x")
    else -- stutter SV
        if menuVars.linearStutter then  -- linearly varying stutter
            local firstSV = round(menuVars.svValues[1], 2)
            local secondSV = round(menuVars.svValues[2], 2)
            local endFirstSV = round(menuVars.svValuesSecondPreview[1], 2)
            local endSecondSV = round(menuVars.svValuesSecondPreview[2], 2)
            local roundedAvgSV = round(menuVars.avgSV, 2)
            local roundedEndAvgSV = round(menuVars.linearEndAvgSV, 2)
            imgui.Text("Beginning Stutter SVs:")
            imgui.Text("Ending Stutter SVs:")
            imgui.Text("Stutter Averages:")
            imgui.NextColumn()
            imgui.Text(firstSV.."x, "..secondSV.."x")
            imgui.Text(endFirstSV.."x, "..endSecondSV.."x")
            imgui.Text(roundedAvgSV.."x --> "..roundedEndAvgSV.."x")
        else -- non-linearly varying stutter
            local firstSV = round(menuVars.svValues[1], 2)
            local firstDurationPerc = menuVars.stutterDuration
            local secondDurationPerc = 100 - firstDurationPerc
            local secondSV = round(menuVars.svValues[2], 2)
            local roundedAvgSV = round(menuVars.avgSV, 2)
            imgui.Text("Stutter First SV:")
            imgui.Text("Stutter Second SV:")
            imgui.Text("Stutter Average SV:")
            imgui.NextColumn()
            imgui.Text(firstSV.."x  ("..firstDurationPerc.."%% duration)")
            imgui.Text(secondSV.."x  ("..secondDurationPerc.."%% duration)")
            imgui.Text(roundedAvgSV.."x")
        end
    end
    imgui.Columns(1)
end

-- Lets users choose and adjust a start and end SV value
-- Returns whether or not the start and end SV value changed [Boolean]
-- Parameters
--    menuVars : the current SV menu's variables [Table]
--    chooseBothSVs
function chooseStartEndSVs(menuVars, chooseBothSVs)
    local oldStartEndValues = {menuVars.startSV, menuVars.endSV}
    if chooseBothSVs then
        local _, newStartEndValues = imgui.InputFloat2("Start/End SV", oldStartEndValues, "%.2fx")
        menuVars.startSV, menuVars.endSV = table.unpack(newStartEndValues)
        menuVars.startSV = clampToInterval(menuVars.startSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
        menuVars.endSV = clampToInterval(menuVars.endSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    else 
        _, menuVars.startSV = imgui.InputFloat("Start SV", menuVars.startSV, 0, 0, "%.2fx")
        menuVars.startSV = clampToInterval(menuVars.startSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    end
    local startValueChanged = oldStartEndValues[1] ~= menuVars.startSV
    local endValueChanged = oldStartEndValues[2] ~= menuVars.endSV
    return startValueChanged or endValueChanged
end

function declareMenuVariables(menuName)
    -- default/baseline template menu variables
    local menuVars = {
        startSV = 2,
        endSV = 0,
        stutterDuration = nil,
        exponentialIncrease = false,
        intensity = 30,
        periods = 0.25,
        periodsShift = 0,
        avgSV = 1,
        svsPerQuarterPeriod = 8,
        svPoints = 16,
        endSVOption = 1,
        linearStutter = false,
        linearEndAvgSV = 1,
        interlace = false,
        interlaceMultiplier = -0.5,
        secondStartSV = -1,
        secondEndSV = 0,
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 1,
        calcMethodNum = 1,
        addTeleport = false,
        veryStartTeleport = false,
        teleportValue = 10000,
        teleportDuration = 1.000,
        displace = false,
        displacement = 150,
        svValues = {},
        svValuesPreview = {},
        svValuesSecondPreview = {},
        noteDistanceVsTime = {},
        startOffset = 0,
        endOffset = 0
    }
    if menuName == "Stutter" then
        menuVars.startSV = 1.5
        menuVars.endSV = 2
        menuVars.stutterDuration = 50
        menuVars.endSVOption = 2
    elseif menuName == "Bezier" then
        menuVars.endSVOption = 2
    elseif menuName == "Sinusoidal" then
        menuVars.endSV = 2
        menuVars.endSVOption = 2
    end
    return menuVars
end

function chooseExponentialBehavior(menuVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Behavior:")
    local oldBehavior = menuVars.exponentialIncrease
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Slow down", not menuVars.exponentialIncrease) then
        menuVars.exponentialIncrease = false
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Speed up", menuVars.exponentialIncrease) then
        menuVars.exponentialIncrease = true
    end
    return oldBehavior ~= menuVars.exponentialIncrease
end

function chooseIntensity(menuVars)
    local oldIntensity = menuVars.intensity
    _, menuVars.intensity = imgui.SliderInt("Intensity", menuVars.intensity, 1, 100, menuVars.intensity.."%%")
    menuVars.intensity = clampToInterval(menuVars.intensity, 1, 100)
    return oldIntensity ~= menuVars.intensity
end

-- Creates the top navigation bar with the dropdown menu to select an SV tool
-- Returns whether the navigation bar is hovered [Boolean]
-- Parameters
--    globalVars : list of global plugin variables used across all SV tool menus [Table]
function createNavigationDropdown(globalVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Current SV Tool:")
    imgui.SameLine()
    imgui.PushItemWidth(2 * DEFAULT_WIDGET_WIDTH)
    local _, menuIndex = imgui.Combo("     ", globalVars.currentMenuNum - 1, SV_TOOLS, #SV_TOOLS)
    globalVars.currentMenuNum = menuIndex + 1
    imgui.SameLine()
    imgui.Text(EMOTICONS[globalVars.currentMenuNum])
    addPadding()
    return imgui.IsWindowHovered()
end

function createSettingsPanel(globalVars, menuVars, menuName)
  imgui.BeginChild("Settings Panel", MENU_SIZE_LEFT, true)
  local isPanelHovered = imgui.IsWindowHovered()
  --[[
  local centering = (MENU_SIZE_LEFT[1] - imgui.CalcTextSize("SETTINGS")[1] - 2 * PADDING_WIDTH) / 2
  imgui.Indent(centering)
  imgui.Text("SETTINGS")
  imgui.Unindent(centering)
  addSeparator()
  --]]
  imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
  
  -- creates the menu of the currently selected SV tool
  local menuFunctionName = string.lower(menuName).."SettingsMenu"
  local svUpdateNeeded = _G[menuFunctionName](globalVars, menuVars, menuName)
  imgui.EndChild()
  return isPanelHovered, svUpdateNeeded
end

function chooseSVPlacementType(globalVars, menuVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Place SVs between:")
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Notes", not globalVars.placeSVsBetweenOffsets) then
        globalVars.placeSVsBetweenOffsets = false
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Offsets", globalVars.placeSVsBetweenOffsets) then
        globalVars.placeSVsBetweenOffsets = true
        menuVars.displace = false
    end
    addPadding()
    if globalVars.placeSVsBetweenOffsets then
        local currentButtonSize = {DEFAULT_WIDGET_WIDTH * 0.4, DEFAULT_WIDGET_HEIGHT}
        if imgui.Button("Current", currentButtonSize) then
            menuVars.startOffset = state.SongTime
        end
        imgui.SameLine(0, SAMELINE_SPACING)
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.75)
        _, menuVars.startOffset = imgui.InputInt("Start Offset", menuVars.startOffset)
        
        if imgui.Button(" Current ", currentButtonSize) then
            menuVars.endOffset = state.SongTime
        end
        imgui.SameLine(0, SAMELINE_SPACING)
        _, menuVars.endOffset = imgui.InputInt("End Offset", menuVars.endOffset)
        addPadding()
    end
end

function createPlaceSVButton(globalVars, menuVars)
    local svButtonText = "Place SVs "
    if globalVars.placeSVsBetweenOffsets then
        svButtonText = svButtonText.."Between Start/End Offsets"
    else
        svButtonText = svButtonText.."Between Selected Notes"
    end
    if imgui.Button(svButtonText, ACTION_BUTTON_SIZE) then
        local offsets = {menuVars.startOffset, menuVars.endOffset}
        if (not globalVars.placeSVsBetweenOffsets) then
            offsets = uniqueSelectedNoteOffsets()
        end
        local SVs = generateSVs(offsets, menuVars.svValues, menuVars.addTeleport,
                                menuVars.veryStartTeleport, menuVars.teleportValue,
                                menuVars.teleportDuration, menuVars.endSVOption, menuVars.displace,
                                menuVars.displacement, menuVars.stutterDuration,
                                menuVars.linearStutter, menuVars.endSV, menuVars.linearEndAvgSV,
                                menuVars.avgSV, globalVars.placeSVsBetweenOffsets)
        if #SVs > 0 then
            actions.PlaceScrollVelocityBatch(SVs)
        end
    end
end

function chooseStutterDuration(menuVars)
    local oldDuration = menuVars.stutterDuration
     _, menuVars.stutterDuration = imgui.SliderInt("Duration", menuVars.stutterDuration, 1, 99, menuVars.stutterDuration.."%%")
    menuVars.stutterDuration = clampToInterval(menuVars.stutterDuration, 1, 99)
    addSeparator()
    return oldDuration ~= menuVars.stutterDuration
end

function chooseLinearStutter(menuVars)
    addSeparator()
    local oldLinearStutter = menuVars.linearStutter
    _, menuVars.linearStutter = imgui.Checkbox("Change stutter linearly over time", menuVars.linearStutter)
    return oldLinearStutter ~= menuVars.linearStutter
end

function chooseBezierPoints(menuVars)
    local oldFirstPoint = {menuVars.x1, menuVars.y1}
    local oldSecondPoint = {menuVars.x2, menuVars.y2}
    local _, newFirstPoint = imgui.InputFloat2("(x1, y1)", oldFirstPoint, "%.2f")
    local _, newSecondPoint = imgui.InputFloat2("(x2, y2)", oldSecondPoint, "%.2f")
    menuVars.x1, menuVars.y1 = table.unpack(newFirstPoint)
    menuVars.x2, menuVars.y2 = table.unpack(newSecondPoint)
    menuVars.x1 = clampToInterval(menuVars.x1, 0, 1)
    menuVars.y1 = clampToInterval(menuVars.y1, -1, 2)
    menuVars.x2 = clampToInterval(menuVars.x2, 0, 1)
    menuVars.y2 = clampToInterval(menuVars.y2, -1, 2)
    local firstPointDifferent = (oldFirstPoint[1] ~= menuVars.x1) or (oldFirstPoint[2] ~= menuVars.y1)
    local secondPointDifferent = (oldSecondPoint[1] ~= menuVars.x2) or (oldSecondPoint[2] ~= menuVars.y2)
    return firstPointDifferent or secondPointDifferent
end

function chooseBezierCalculationMethod(menuVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Calc. method:")
    local oldMethodNum = menuVars.calcMethodNum
    imgui.SameLine()
    _, menuVars.calcMethodNum = imgui.RadioButton("1", menuVars.calcMethodNum, 1) --root finding
    imgui.SameLine()
    _, menuVars.calcMethodNum = imgui.RadioButton("2", menuVars.calcMethodNum, 2) --iceSV
    imgui.SameLine()
    _, menuVars.calcMethodNum = imgui.RadioButton("3", menuVars.calcMethodNum, 3) --iceSV
    return oldMethodNum ~= menuVars.calcMethodNum
end