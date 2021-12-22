 -- amoguSV v3.1 (21 Dec 2021)
-- by kloi34

-- Many SV tool ideas were stolen from other plugins, so here is credit to those plugins and the
-- creators behind them:
---------------------------------------------------------------------------------------------------
--    Plugin        Creator                Link                                                
---------------------------------------------------------------------------------------------------
--    iceSV         IceDynamix             @ https://github.com/IceDynamix/iceSV
--    KeepStill     Illuminati-CRAZ        @ https://github.com/Illuminati-CRAZ/KeepStill
--    Vibrato       Illuminati-CRAZ        @ https://github.com/Illuminati-CRAZ/Vibrato
--    Displacer     Illuminati-CRAZ        @ https://github.com/Illuminati-CRAZ/Displacer

---------------------------------------------------------------------------------------------------
-- Plugin Info ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- This is a plugin for Quaver, the ultimate community-driven and open-source competitive rhythm
-- game. The plugin provides various tools to add and edit SVs (Scroll Velocities) quickly and
-- efficiently when making maps.

-- If you have any feature suggestions or issues with the plugin, please open an issue at 
-- https://github.com/kloi34/amoguSV/issues

-- Last features planned for amoguSV v4.0:
--      1. Make amoguSV UI better and UX better, especially for first time users
--      2. Dedicated Vibrato+more SV tool 

---------------------------------------------------------------------------------------------------
-- Global Constants -------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- IMGUI / GUI
DEFAULT_WIDGET_HEIGHT = 26         -- value determining the height of GUI widgets
DEFAULT_WIDGET_WIDTH = 160         -- value determining the width of GUI widgets
MENU_SIZE_LEFT = {265, 465}        -- dimensions of the settings menu panel on the left
MENU_SIZE_RIGHT = {260, 465}       -- dimensions of the menu panel on the right
PADDING_WIDTH = 8                  -- value determining window and frame padding
PLUGIN_WINDOW_SIZE = {560, 540}    -- dimensions of the plugin window
SAMELINE_SPACING = 5               -- value determining spacing between GUI items on the same row
RADIO_BUTTON_SPACING = 7.5         -- value determining spacing between radio buttons
ACTION_BUTTON_SIZE = {             -- dimensions of the button that places/removes SVs
    1.6 * DEFAULT_WIDGET_WIDTH,
    1.6 * DEFAULT_WIDGET_HEIGHT
}

-- SV/Time restrictions
MAX_DURATION = 10000               -- maximum millisecond duration allowed in general
MAX_GENERAL_SV = 1000              -- maximum (absolute) value allowed for general SVs (ex. avg SV)
MAX_MS_TIME = 7200000 -- ~ 2 hrs   -- maximum song time allowed (milliseconds)
MAX_TELEPORT_DURATION = 10         -- maximum millisecond teleport duration allowed
MAX_TELEPORT_VALUE = 9999999       -- maximum (absolute) teleport SV value allowed
MIN_DURATION = 0.016 -- ~ 1/64     -- minimum millisecond duration allowed in general

-- Menu-related
CONDITION_TESTS = {                -- conditions/tests for numbers
    "= (equal to)",
    "> (greater than)",
    ">= (greater or equal to)",
    "< (less than)",
    "<= (less or equal to)"
}
EMOTICONS = {                      -- emoticons to visually clutter the plugin and confuse users
    "%( - _ - )",
    "%( e.e %)",
    "%(o_0%)",
    "%(*o*%)",
    "%(~_~%)",
    "%(>.<%)",
    "%(w.w)",
    "%(^w^%)",
    "%( c . p %)",
    "%( ; _ ; %)"
}
FINAL_SV_TYPES = {                 -- options for the last SV placed at the tail end of all SVs
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
    "Random",
    "Still",
    "Copy",
    "Remove"
}
---------------------------------------------------------------------------------------------------
-- Plugin Menus (+ other higher level menu-related functions) -------------------------------------
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
    
    local isNavHovered = createNavigationDropdown(globalVars)
    local menuName = SV_TOOLS[globalVars.currentMenuNum]
    local menuVars = declareMenuVariables(menuName)
    retrieveStateVariables(menuName, menuVars)
    imgui.Columns(2, "SV Menu Panels", false)
    local isLeftPanelHovered, svUpdateNeeded = createSettingsPanel(globalVars, menuVars, menuName)
    if svUpdateNeeded then
        updateMenuSVs(menuVars, menuName)
    end
    imgui.NextColumn()
    local isRightPanelHovered = createRightPanel(globalVars, menuVars, menuName)

    saveStateVariables(menuName, menuVars)
    saveStateVariables("Global", globalVars)
    state.IsWindowHovered = isNavHovered or isLeftPanelHovered or isRightPanelHovered
    imgui.End()
end
-- Creates the top navigation bar with the dropdown menu to select an SV tool
-- Returns whether the navigation bar is hovered [Boolean]
-- Parameters
--    globalVars : list of global plugin variables used across all menus [Table]
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
-- Creates the settings panel to adjust SV tool settings
-- Returns 2 values
--    1. whether or not this left panel is hovered over [Boolean]
--    2. whether or not menu-specific SV information has changed and needs an update [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
--    menuName   : name of the current SV menu [String]
function createSettingsPanel(globalVars, menuVars, menuName)
    imgui.BeginChild("Settings Panel", MENU_SIZE_LEFT, true)
    local isPanelHovered = imgui.IsWindowHovered()
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    local menuFunctionName = string.lower(menuName).."SettingsMenu"
    -- creates the settings menu for the current, specific SV tool
    local svUpdateNeeded = _G[menuFunctionName](globalVars, menuVars, menuName)
    imgui.EndChild()
    return isPanelHovered, svUpdateNeeded
end
-- Creates the settings menu for linear SV
-- Returns whether or not SV information has changed and needs to be updated [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for this linear menu [Table]
--    menuName   : name of this menu [String]
function linearSettingsMenu(globalVars, menuVars, menuName)
    local svUpdateNeeded = #menuVars.svValues == 0
    svUpdateNeeded = chooseStartEndSVs(menuVars, true) or svUpdateNeeded
    svUpdateNeeded = chooseSVPoints(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseFinalSV(menuVars, false) or svUpdateNeeded
    svUpdateNeeded = chooseInterlace(menuVars, menuName, true) or svUpdateNeeded
    chooseTeleportSV(globalVars, menuVars, menuName)
    chooseDisplacement(globalVars, menuVars, menuName)
    return svUpdateNeeded
end
-- Creates the settings menu for exponential SV
-- Returns whether or not SV information has changed and needs to be updated [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for this exponential menu [Table]
--    menuName   : name of this menu [String]
function exponentialSettingsMenu(globalVars, menuVars, menuName)
    local svUpdateNeeded = #menuVars.svValues == 0
    svUpdateNeeded = chooseExponentialBehavior(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseIntensity(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseAverageSV(menuVars, false) or svUpdateNeeded
    svUpdateNeeded = chooseSVPoints(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseFinalSV(menuVars, false) or svUpdateNeeded
    svUpdateNeeded = chooseInterlace(menuVars, menuName, false) or svUpdateNeeded
    chooseTeleportSV(globalVars, menuVars, menuName)
    chooseDisplacement(globalVars, menuVars, menuName)
    return svUpdateNeeded
end
-- Creates the settings menu for stutter/bump SV
-- Returns whether or not SV information has changed and needs to be updated [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for this stutter menu [Table]
--    menuName   : name of this menu [String]
function stutterSettingsMenu(globalVars, menuVars, menuName)
    local svUpdateNeeded = #menuVars.svValues == 0
    imgui.Text("First SV:")
    svUpdateNeeded = chooseStartEndSVs(menuVars, menuVars.linearStutter) or svUpdateNeeded
    svUpdateNeeded = chooseStutterDuration(menuVars, menuVars.linearStutter) or svUpdateNeeded
    svUpdateNeeded = chooseAverageSV(menuVars, menuVars.linearStutter) or svUpdateNeeded
    svUpdateNeeded = chooseFinalSV(menuVars, true) or svUpdateNeeded
    svUpdateNeeded = chooseLinearStutter(menuVars) or svUpdateNeeded
    return svUpdateNeeded
end
-- Creates the settings menu for cubic bezier SV
-- Returns whether or not SV information has changed and needs to be updated [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for this bezier menu [Table]
--    menuName   : name of this menu [String]
function bezierSettingsMenu(globalVars, menuVars, menuName)
    local svUpdateNeeded = #menuVars.svValues == 0
    provideLinkToBezierWebsite()
    svUpdateNeeded = chooseBezierPoints(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseAverageSV(menuVars, false) or svUpdateNeeded
    svUpdateNeeded = chooseSVPoints(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseFinalSV(menuVars, true) or svUpdateNeeded
    svUpdateNeeded = chooseInterlace(menuVars, menuName, false) or svUpdateNeeded
    chooseTeleportSV(globalVars, menuVars, menuName)
    chooseDisplacement(globalVars, menuVars, menuName)
    return svUpdateNeeded
end
-- Creates the settings menu for sinusoidal SV
-- Returns whether or not SV information has changed and needs to be updated [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for this sinusoidal menu [Table]
--    menuName   : name of this menu [String]
function sinusoidalSettingsMenu(globalVars, menuVars, menuName)
    local svUpdateNeeded = #menuVars.svValues == 0
    imgui.Text("Amplitude:")
    svUpdateNeeded = chooseStartEndSVs(menuVars, true) or svUpdateNeeded
    svUpdateNeeded = chooseCurveSharpness(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseConstantShift(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseNumPeriods(menuVars) or svUpdateNeeded
    svUpdateNeeded = choosePeriodShift(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseSVPerQuarterPeriod(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseFinalSV(menuVars, true) or svUpdateNeeded
    chooseTeleportSV(globalVars, menuVars, menuName)
    chooseDisplacement(globalVars, menuVars, menuName)
    return svUpdateNeeded
end
-- Creates the settings menu for single SV
-- Returns whether or not SV information has changed and needs to be updated [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for this single SV menu [Table]
--    menuName   : name of this menu [String]
function singleSettingsMenu(globalVars, menuVars, menuName)
    if menuVars.svBefore then
        chooseSVBeforeNote(menuVars)
    end
    if (not menuVars.skipSVAtNote) then
        chooseSVAtNote(menuVars)
    end
    if menuVars.svAfter then
        chooseSVAfterNote(menuVars)
    end
    chooseSingleSVInputs(menuVars)
    return false
end
-- Creates the settings menu for random SV
-- Returns whether or not SV information has changed and needs to be updated [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for this random SV menu [Table]
--    menuName   : name of this menu [String]
function randomSettingsMenu(globalVars, menuVars, menuName)
    local svUpdateNeeded = #menuVars.svValues == 0
    svUpdateNeeded = chooseRandomType(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseRandomScale(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseAverageSV(menuVars, false) or svUpdateNeeded
    svUpdateNeeded = chooseSVPoints(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseFinalSV(menuVars, true) or svUpdateNeeded
    chooseTeleportSV(globalVars, menuVars, menuName)
    chooseDisplacement(globalVars, menuVars, menuName)
    if (not globalVars.placeSVsBetweenOffsets) then
        addSeparator()
    end
    if imgui.Button("Generate New Random Set") then
        svUpdateNeeded = true
    end
    return svUpdateNeeded
end
-- Creates the settings menu for still SV
-- Returns whether or not SV information has changed and needs to be updated [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for this still SV menu [Table]
--    menuName   : name of this menu [String]
function stillSettingsMenu(globalVars, menuVars, menuName)
    local svUpdateNeeded = #menuVars.svValues == 0
    svUpdateNeeded = chooseAverageSVStill(menuVars) or svUpdateNeeded
    svUpdateNeeded = chooseFinalSV(menuVars, false) or svUpdateNeeded
    svUpdateNeeded = chooseStillMotionType(menuVars) or svUpdateNeeded
    addSeparator()
    imgui.Text("Intermediate Motion Settings:")
    addPadding()
    local motionIsLinear = menuVars.stillIntermediateMotion == "Linear"
    local motionIsExponential = menuVars.stillIntermediateMotion == "Exponential"
    local motionIsBezier = menuVars.stillIntermediateMotion == "Bezier"
    local motionIsSinusoial = menuVars.stillIntermediateMotion == "Sinusoidal"
    if motionIsLinear then
        svUpdateNeeded = chooseStartEndSVs(menuVars, true) or svUpdateNeeded
        svUpdateNeeded = chooseSVPoints(menuVars) or svUpdateNeeded
    elseif motionIsExponential then
        svUpdateNeeded = chooseExponentialBehavior(menuVars) or svUpdateNeeded
        svUpdateNeeded = chooseIntensity(menuVars) or svUpdateNeeded
        svUpdateNeeded = chooseSVPoints(menuVars) or svUpdateNeeded
    elseif motionIsBezier then
        svUpdateNeeded = chooseBezierPoints(menuVars) or svUpdateNeeded
        svUpdateNeeded = chooseSVPoints(menuVars) or svUpdateNeeded
    elseif motionIsSinusoial then
        svUpdateNeeded = chooseStartEndSVs(menuVars, true) or svUpdateNeeded
        svUpdateNeeded = chooseCurveSharpness(menuVars) or svUpdateNeeded
        svUpdateNeeded = chooseConstantShift(menuVars) or svUpdateNeeded
        svUpdateNeeded = chooseNumPeriods(menuVars) or svUpdateNeeded
        svUpdateNeeded = choosePeriodShift(menuVars) or svUpdateNeeded
        svUpdateNeeded = chooseSVPerQuarterPeriod(menuVars) or svUpdateNeeded
    end
    if (not motionIsLinear) and (not motionIsSinusoial) then
        svUpdateNeeded = chooseAverageSV(menuVars, false) or svUpdateNeeded
        createHelpMarker("This is the average velocity of the notes following the intermediate "..
                         "motion")
    end
    chooseDisplacement(globalVars, menuVars, menuName)
    return svUpdateNeeded
end
-- Creates the settings menu for copy & paste SV
-- Returns whether or not SV information has changed and needs to be updated [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for this copy & paste SV menu [Table]
--    menuName   : name of this menu [String]
function copySettingsMenu(globalVars, menuVars, menuName)
    chooseCopySettings(menuVars)
    createCopyButton(menuVars)
    addSeparator()
    imgui.Text("("..#menuVars.svValues.." SVs copied currently)")
    return false
end
-- Creates the settings menu for remove SV
-- Returns whether or not SV information has changed and needs to be updated [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for this remove SV menu [Table]
--    menuName   : name of this menu [String]
function removeSettingsMenu(globalVars, menuVars, menuName)
    _, menuVars.addRemovalCondition = imgui.Checkbox("Add SV removal condition",
                                                     menuVars.addRemovalCondition)
    if menuVars.addRemovalCondition then
        addSeparator()
        local _, svConditionIndex = imgui.Combo("SV Condition", menuVars.svCondition - 1,
                                                CONDITION_TESTS, #CONDITION_TESTS)
        menuVars.svCondition = svConditionIndex + 1
        _, menuVars.svConditionValue = imgui.InputFloat("SV value", menuVars.svConditionValue,
                                                         0, 0, "%.2fx")
        menuVars.svConditionValue = clampToInterval(menuVars.svConditionValue, -999999, 999999)
    end
    return false
end
-- Creates the right-side panel for info and action buttons
-- Returns whether or not this right panel is hovered over [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
--    menuName   : name of the current SV menu [String]
function createRightPanel(globalVars, menuVars, menuName)
    imgui.BeginChild("Right Panel", MENU_SIZE_RIGHT)
    local isPanelHovered = imgui.IsWindowHovered()
    if menuName == "Still" then
        createStillSVPanel(globalVars, menuVars, menuName)
    elseif menuName == "Remove" then
        createRemoveSVPanel(globalVars, menuVars, menuName)
    elseif menuName == "Copy" then
        createPasteSVPanel(globalVars, menuVars, menuName)
    else
        createPlaceSVPanel(globalVars, menuVars, menuName)
    end
    imgui.EndChild()
    return isPanelHovered
end
-- Creates the right panel menu for still SVs
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for the still SV menu [Table]
--    menuName   : name of the current SV menu [String]
function createStillSVPanel(globalVars, menuVars, menuName)
    plotSVs(menuVars.svValuesPreview, "Intermediate Motion")
    displaySVStats(menuVars)
    addSeparator()
    imgui.Text("Select 3 or more notes:")
    addPadding()
    if imgui.Button("Apply Still SVs On Selected Notes", ACTION_BUTTON_SIZE) or 
            utils.IsKeyPressed(keys.Y) then
        local SVs = generateStillSVs(menuVars)
        if #SVs > 0 then
            actions.PlaceScrollVelocityBatch(SVs)
        end
    end
    if utils.IsKeyPressed(keys.T) then
        local SVs = generateStillSVs(menuVars)
        if #SVs > 0 then
            removeSVs(menuVars, globalVars)
            actions.PlaceScrollVelocityBatch(SVs)
        end
    end
end
-- Creates the right panel menu for removing SVs
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for the remove menu [Table]
--    menuName   : name of the current SV menu [String]
function createRemoveSVPanel(globalVars, menuVars, menuName)
    chooseSVRangeType(globalVars, menuVars, menuName)
    if globalVars.placeSVsBetweenOffsets then
        addPadding()
        local startTime = convertToTime(menuVars.startOffset)
        local endTime = convertToTime(menuVars.endOffset)
        imgui.Text("(from "..startTime.." to "..endTime..")")
    end
    createActionSVButton(globalVars, menuVars, menuName)
end
-- Creates the right panel menu for pasting copied SVs
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for the copy SV menu [Table]
--    menuName   : name of the current SV menu [String]
function createPasteSVPanel(globalVars, menuVars, menuName)
    if imgui.Button("Place SVs at current song time", ACTION_BUTTON_SIZE) then
        local pasteOffsets = {math.floor(state.SongTime)}
        pasteSVs(menuVars.svValues, pasteOffsets)
    end
     if imgui.Button("Place SVs at selected notes", ACTION_BUTTON_SIZE) or 
            utils.IsKeyPressed(keys.Y) then
        local pasteOffsets = uniqueSelectedNoteOffsets()
        pasteSVs(menuVars.svValues, pasteOffsets)
    end
end
-- Creates the right panel menu for displaying SV stats and placing SVs
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
--    menuName   : name of the current SV menu [String]
function createPlaceSVPanel(globalVars, menuVars, menuName)
    if menuName == "Single" then
        createPlaceSingleSVButton(menuVars)
        return isPanelHovered
    end
    if menuVars.linearStutter then
        plotSVs(menuVars.svValuesPreview, "First Stutter")
        addSeparator()
        plotSVs(menuVars.svValuesSecondPreview, "Last Stutter")
    else
        plotSVMotion(menuVars.noteDistanceVsTime, not globalVars.placeSVsBetweenOffsets)
        addSeparator()
        plotSVs(menuVars.svValuesPreview, menuName)
    end
    displaySVStats(menuVars)
    addSeparator()
    chooseSVRangeType(globalVars, menuVars, menuName)
    createActionSVButton(globalVars, menuVars, menuName)
end

---------------------------------------------------------------------------------------------------
-- SV Generation/Editing/Removal Functions --------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Places SVs for the current SV menu
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
function placeSVs(menuVars, globalVars)
    local offsets = {menuVars.startOffset, menuVars.endOffset}
    if (not globalVars.placeSVsBetweenOffsets) then
        offsets = uniqueSelectedNoteOffsets()
    end
    local SVs = generateSVs(offsets, menuVars.svValues, menuVars.addTeleport,
                            menuVars.veryStartTeleport, menuVars.teleportValue,
                            menuVars.teleportDuration, menuVars.finalSVOption, menuVars.displace,
                            menuVars.displacement, menuVars.stutterDuration,
                            menuVars.linearStutter, menuVars.endSV, menuVars.linearEndAvgSV,
                            menuVars.avgSV, globalVars.placeSVsBetweenOffsets)
    if #SVs > 0 then
        actions.PlaceScrollVelocityBatch(SVs)
    end
end
-- Generates SVs to place
-- Returns the generated SVs
-- Parameters
--    offsets                : list of times to place SVs between/at [Table]
--    svValues               : ordered list of numerical values to turn into SVs [Table]
--    addTeleport            : whether or not to add a beginning teleport SV [Boolean]
--    veryStartTeleport      : whether or not the teleport SV is only at the very start [Boolean]
--    teleportValue          : SV value of the beginning teleport SV [Int/Float]
--    teleportDuration       : duration of the beginning teleport SV (milliseconds) [Int/Float]
--    finalSVOption          : option number for the type of SV placed at the very end [Int]
--    displace               : whether or not to displace notes [Boolean]
--    displacement           : displacement height of note/hitObject receptors (msx) [Int/Float]
--    stutterDuration        : duration % of first stutter SV (if applicable) [Int/Float]
--    linearStutter          : whether or not stutter linearly changes (if applicable) [Boolean]
--    endSV                  : ending first SV of linear stutter SV (if applicable) [Int/Float]
--    linearEndAvgSV         : ending average SV of linear stutter SV (if applicable) [Int/Float]
--    stutterAvgSV           : average SV of stutter SV (if applicable) [Int/Float]
--    placeSVsBetweenOffsets : whether or not SVs are placed between two offsets [Boolean]
function generateSVs(offsets, svValues, addTeleport, veryStartTeleport, teleportValue,
                     teleportDuration, finalSVOption, displace, displacement, stutterDuration,
                     linearStutter, endSV, linearEndAvgSV, stutterAvgSV, placeSVsBetweenOffsets)
    local SVs = {}
    local startSVList = {}
    local avgSVList = {}
    local isAStutterSV = stutterDuration ~= nil
    if isAStutterSV and linearStutter then
        startSVList = generateLinearSet(svValues[1], endSV, #offsets - 1, false, 0, 0)
        avgSVList = generateLinearSet(stutterAvgSV, linearEndAvgSV, #offsets - 1, false, 0, 0)
    end
    for i = 1, #offsets - 1 do
        local startOffset = determineTeleport(offsets[i], addTeleport, veryStartTeleport,
                                              i == 1, teleportValue, teleportDuration, SVs)
        local endOffset = offsets[i + 1]
        startOffset = addDisplacementSV(SVs, placeSVsBetweenOffsets, displace, i ~= 1, addTeleport,
                                        veryStartTeleport, displacement, startOffset, endOffset)
        local svOffsets
        if isAStutterSV then
            local offsetInterval = endOffset - startOffset
            local stutterSecondOffset = startOffset + offsetInterval * stutterDuration / 100
            svOffsets = {startOffset, stutterSecondOffset, endOffset}
        else
            svOffsets = generateLinearSet(startOffset, endOffset, #svValues, false, 0, 0)
        end
        if linearStutter then
            svValues = generateStutterSet(startSVList[i], stutterDuration, avgSVList[i])
        end
        for j = 1, #svOffsets - 1 do
            table.insert(SVs, utils.CreateScrollVelocity(svOffsets[j], svValues[j]))
        end
    end
    addFinalSV(SVs, offsets[#offsets], svValues[#svValues], finalSVOption, displace, displacement)
    return SVs
end
-- Adds a teleport SV to the list of SVs to place if applicable
-- Returns the start offset after accounting for the teleport SV [Int/Float]
-- Parameters
--    startOffset       : starting time of note to add teleport at (milliseconds) [Int/Float]
--    addTeleport       : whether or not to add a teleport SV [Boolean]
--    veryStartTeleport : whether or not the teleport SV is only at the very start [Boolean]
--    veryFirstSet      : whether or not the current SV set is the very first set [Boolean]
--    teleportValue     : SV value of the beginning teleport SV [Int/Float]
--    teleportDuration  : duration of the beginning teleport SV (milliseconds) [Int/Float]
--    SVs               : list of SVs to add the teleport SV to [Table]
function determineTeleport(startOffset, addTeleport, veryStartTeleport, veryFirstSet,
                           teleportValue, teleportDuration, SVs)
    if addTeleport then
        if veryFirstSet or (not veryStartTeleport) then
            table.insert(SVs, utils.CreateScrollVelocity(startOffset, teleportValue))
            startOffset = startOffset + teleportDuration
        end
    end
    return startOffset
end
-- Adds displacement SVs to the list of SVs to place if applicable
-- Returns the start offset after accounting for the displacement SV [Int/Float]
-- Parameters
--    SVs                    : list of SVs to add the displacement SV to [Table]
--    placeSVsBetweenOffsets : whether or not SVs are placed between two offsets [Boolean]
--    displace               : whether or not to displace notes [Boolean]
--    notFirstSet            : whether or not the SVs are for the first set of multiple [Boolean]
--    addTeleport            : whether or not to add a beginning teleport SV [Boolean]
--    veryStartTeleport      : whether or not the teleport SV is only at the very start [Boolean]
--    displacement           : displacement height of note/hitObject receptors (msx) [Int/Float]
--    startOffset            : start time of first note to un-displace (milliseconds) [Int/Float]
--    endOffset              : ending time of second note to displace (milliseconds) [Int/Float]
function addDisplacementSV(SVs, placeSVsBetweenOffsets, displace, notFirstSet, addTeleport,
                           veryStartTeleport, displacement, startOffset, endOffset)
    if (not placeSVsBetweenOffsets) and displace then
        local middleTelportExists = (not addTeleport) or (addTeleport and veryStartTeleport)
        if notFirstSet and middleTelportExists then
            table.insert(SVs, utils.CreateScrollVelocity(startOffset, - displacement * 64))
            startOffset = startOffset + MIN_DURATION
        end
        table.insert(SVs, utils.CreateScrollVelocity(endOffset - MIN_DURATION, displacement * 64))
    end
    return startOffset
end
-- Adds the last tail-end SV to a set of SVs, also accounting for displacement
-- Parameters
--    SVs           : list of SVs to add the displacement SV to [Table]
--    endOffset     : default/usual time to place the final SV at [Int/Float]
--    velocity      : default/usual SV value for the final SV [Int/Float]
--    finalSVOption : option number for the type of SV placed at the very end [Int]
--    displace      : whether or not to displace notes [Boolean]
--    displacement  : displacement height of note/hitObject receptors (msx) [Int/Float]
function addFinalSV(SVs, endOffset, velocity, finalSVOption, displace, displacement)
    if displace and finalSVOption ~= 2 then
        table.insert(SVs, utils.CreateScrollVelocity(endOffset, - displacement * 64))
        endOffset = endOffset + MIN_DURATION
    end
    if finalSVOption == 1 then -- normal SV option
        table.insert(SVs, utils.CreateScrollVelocity(endOffset, velocity))
    elseif finalSVOption == 3 then -- 1.00x SV option
        table.insert(SVs, utils.CreateScrollVelocity(endOffset, 1))
    end
end
-- Generates SVs to place for the single SV tool/menu
-- Returns the generated SVs
-- Parameters
--    skipSVAtNote     : whether or not to skip placing an SV directly at the note time [Boolean]
--    svBefore         : whether or not to place an SV before the note [Boolean]
--    svValueBefore    : value of the SV to place before the note [Int/Float]
--    incrementBefore  : time before the note to place the before-SV (milliseconds) [Int/Float]
--    svAfter          : whether or not to place an SV after the note [Boolean]
--    svValueAfter     : value of the SV to place after the note [Int/Float]
--    incrementAfter   : time after the note to place the after-SV (milliseconds) [Int/Float]
--    svValue          : value of the SV to place directly at the note [Int/Float]
--    scaleSVLinearly  : whether or not to scale SV values linearly over time [Boolean]
--    svValueBeforeEnd : linear end value of the SV to place before the note [Int/Float]
--    svValueEnd       : linear end value of the SV to place directly at the note [Int/Float]
--    svValueAfterEnd  : linear end value of the SV to place after the note [Int/Float]
function generateSingleSVs(skipSVAtNote, svBefore, svValueBefore, incrementBefore, svAfter,
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
-- Generates Still SVs to place
-- Returns the generated SVs
-- Parameters
--    menuVars : list of variables used for the still SV menu [Table]
function generateStillSVs(menuVars)
    local SVs = {}
    local offsets = uniqueSelectedNoteOffsets()
    if #offsets < 3 then
        return SVs
    end
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    if menuVars.stillIntermediateMotion == "Constant" then
        startOffset = determineTeleport(startOffset, menuVars.displace, true, true, 
                                        64 * menuVars.displacement, MIN_DURATION, SVs)
        table.insert(SVs, utils.CreateScrollVelocity(startOffset, menuVars.avgSV))
        for i = 2, #offsets do
            local timeFromStart = offsets[i] - startOffset
            local stillAverageDifference = menuVars.avgSVStill - menuVars.avgSV
            local teleportVelocity = stillAverageDifference * 64 * timeFromStart
            if menuVars.displace then 
                teleportVelocity = teleportVelocity + 64 * menuVars.displacement
            end
            if i == #offsets then
                table.insert(SVs, utils.CreateScrollVelocity(offsets[i] - MIN_DURATION,
                             teleportVelocity + menuVars.avgSV))
            else
                table.insert(SVs, utils.CreateScrollVelocity(offsets[i] - MIN_DURATION,
                             teleportVelocity + menuVars.avgSV))
                table.insert(SVs, utils.CreateScrollVelocity(offsets[i],
                             -teleportVelocity + menuVars.avgSV))
                table.insert(SVs, utils.CreateScrollVelocity(offsets[i] + MIN_DURATION,
                             menuVars.avgSV))
            end
        end
    else
        local motionSVOffsets = generateLinearSet(startOffset, endOffset, #menuVars.svValues,
                                                  false, 0, 0)
        startOffset = determineTeleport(startOffset, menuVars.displace, true, true,
                                        64 * menuVars.displacement, MIN_DURATION, SVs)
        table.insert(SVs, utils.CreateScrollVelocity(startOffset, menuVars.svValues[1]))
        local svValueIndex = 1
        local totalDistanceTraveled
        if menuVars.displace then
            totalDistanceTraveled = menuVars.displacement
        else
            totalDistanceTraveled = 0
        end
        for i = 2, #offsets do
            local currentMotionOffset = motionSVOffsets[svValueIndex]
            local nextMotionOffset = motionSVOffsets[svValueIndex + 1]
            local noteOffset = offsets[i]
            while nextMotionOffset < (noteOffset - MIN_DURATION) do
                lastMotionSVValue = menuVars.svValues[svValueIndex]
                local lastMotionOffset = currentMotionOffset
                if math.abs(lastMotionOffset - offsets[i - 1]) > MIN_DURATION then
                    table.insert(SVs, utils.CreateScrollVelocity(lastMotionOffset,
                                 lastMotionSVValue))
                end
                svValueIndex = svValueIndex + 1
                currentMotionOffset = motionSVOffsets[svValueIndex]
                nextMotionOffset = motionSVOffsets[svValueIndex + 1]
                local distanceTraveled = (currentMotionOffset - lastMotionOffset) * 
                        lastMotionSVValue
                totalDistanceTraveled = totalDistanceTraveled + distanceTraveled
            end
            if i == #offsets then
                while currentMotionOffset < noteOffset do
                    lastMotionSVValue = menuVars.svValues[svValueIndex]
                    local lastMotionOffset = currentMotionOffset
                    table.insert(SVs, utils.CreateScrollVelocity(lastMotionOffset,
                                 lastMotionSVValue))
                    svValueIndex = svValueIndex + 1
                    currentMotionOffset = motionSVOffsets[svValueIndex]
                    local distanceTraveled = (currentMotionOffset - lastMotionOffset) * 
                            lastMotionSVValue
                    totalDistanceTraveled = totalDistanceTraveled + distanceTraveled
                end
            end
            local thisMotionSVValue = menuVars.svValues[svValueIndex]
            local regularNoteDistance = (noteOffset - startOffset) * menuVars.avgSVStill
            local totalDistanceTraveledToNote = totalDistanceTraveled + 
                    (noteOffset - currentMotionOffset) * thisMotionSVValue
            local teleportVelocity = (regularNoteDistance - totalDistanceTraveledToNote) * 64
            if i == #offsets then
                table.insert(SVs, utils.CreateScrollVelocity(noteOffset - MIN_DURATION,
                             teleportVelocity + thisMotionSVValue))
            else
                table.insert(SVs, utils.CreateScrollVelocity(noteOffset - MIN_DURATION,
                             teleportVelocity + thisMotionSVValue))
                table.insert(SVs, utils.CreateScrollVelocity(noteOffset,
                             -teleportVelocity + thisMotionSVValue))
                if math.abs(motionSVOffsets[svValueIndex - 1] - offsets[i -1]) < MIN_DURATION then
                    table.insert(SVs, utils.CreateScrollVelocity(noteOffset + MIN_DURATION,
                                menuVars.svValues[svValueIndex + 1]))
                else
                    table.insert(SVs, utils.CreateScrollVelocity(noteOffset + MIN_DURATION,
                                thisMotionSVValue))
                end
            end
        end
    end
    addFinalSV(SVs, endOffset, menuVars.avgSVStill, menuVars.finalSVOption, false, nil)
    return SVs
end
-- Removes SVs in the map between two points of time
-- Parameters
--    menuVars   : list of variables used for the remove menu [Table]
--    globalVars : list of global variables used across all menus [Table]
function removeSVs(menuVars, globalVars)
    local offsets = {menuVars.startOffset, menuVars.endOffset}
    if (not globalVars.placeSVsBetweenOffsets) then
        local selectedNoteOffsets = uniqueSelectedNoteOffsets()
        offsets[1] = selectedNoteOffsets[1]
        offsets[2] = selectedNoteOffsets[#selectedNoteOffsets]
    end
    local svsToRemove = locateRemovableSVs(offsets, menuVars.addRemovalCondition,
                                           menuVars.svCondition, menuVars.svConditionValue)
    if #svsToRemove > 0 then
        actions.RemoveScrollVelocityBatch(svsToRemove)
    end
end
-- Locates SVs that are removable based on given parameters
-- Returns the list of removable SVs [Table]
-- Parameters
--    offsets             : list containing two times to remove SVs between [Table]
--    addRemovalCondition : whether or not to add removal condition for SVs [Boolean]
--    svCondition         : number of the removal condition (of CONDITION_TESTS) [Int]
--    svConditionValue    : value to base the removal condition on [Int/Float]
function locateRemovableSVs(offsets, addRemovalCondition, svCondition, svConditionValue)
    local startOffset = offsets[1]
    local endOffset = offsets[2]
    -- corrects start/end offsets if user inputted the reverse by switching them
    if startOffset > endOffset then
        startOffset = offsets[2]
        endOffset = offsets[1]
    end
    local roundedConditionValue = round(svConditionValue, 2)
    local svsToRemove = {}
    for i, sv in pairs(map.ScrollVelocities) do
        local roundedSV = round(sv.Multiplier, 2)
        local svIsInRange = sv.StartTime >= startOffset and sv.StartTime < endOffset
        if svIsInRange then
            if addRemovalCondition then
                if svCondition == 1 or svCondition == 3 or svCondition == 5 then
                    if roundedSV == roundedConditionValue then
                        table.insert(svsToRemove, sv)
                    end
                end
                if svCondition == 2 or svCondition == 3 then
                    if roundedSV > roundedConditionValue then
                        table.insert(svsToRemove, sv)
                    end
                end
                if svCondition == 4 or svCondition == 5 then
                    if roundedSV < roundedConditionValue then
                        table.insert(svsToRemove, sv)
                    end
                end
            else
                table.insert(svsToRemove, sv)
            end
        end
    end
    return svsToRemove
end
-- Copies SVs between two times
-- Returns a list of tables with values: 1. SV multiplier 2. relative offset to copy start [Table]
-- Parameters
--    startOffset : starting time to start copying SVs
--    endOffset   : ending time to stop copying SVs
function copySVs(startOffset, endOffset)
    local SVs = {}
    for i, sv in pairs(map.ScrollVelocities) do
        if sv.StartTime >= startOffset and sv.StartTime < endOffset then
            local relativeTime = sv.StartTime - startOffset 
            table.insert(SVs, {sv.Multiplier, relativeTime})
        end
    end
    return SVs
end
-- Pastes copied SVs
-- Parameters
--    svValues     : variable containing copied SV info (1. multiplier, 2. relative offset) [Table]
--    pasteOffsets : offsets/times to paste copied SVs
function pasteSVs(svValues, pasteOffsets)
    local svsToPaste = {}
    for i = 1, #pasteOffsets do
        local pasteOffset = pasteOffsets[i]
        for j = 1, #svValues do
            local svMultiplier = svValues[j][1]
            local relativeOffset = svValues[j][2]
            local timeToPasteSV = pasteOffset + relativeOffset
            table.insert(svsToPaste, utils.CreateScrollVelocity(timeToPasteSV, svMultiplier))
        end
    end
    if #svsToPaste > 0 then
        actions.PlaceScrollVelocityBatch(svsToPaste)
    end
end
---------------------------------------------------------------------------------------------------
-- Numerical Value Generation for SVs -------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Generates a single set of values (used for SV multipliers)
-- Parameters
--    menuVars   : list of variables used for the current SV menu [Table]
--    menuName   : name of the current SV menu [String]
function generateSetOfValues(menuVars, menuName)
    if menuName == "Linear" then
        return generateLinearSet(menuVars.startSV, menuVars.endSV, menuVars.svPoints + 1,
                                 menuVars.interlace, menuVars.secondStartSV, menuVars.secondEndSV)
    end
    if menuName == "Exponential" then
        return generateExponentialSet(menuVars.exponentialIncrease, menuVars.svPoints + 1,
                                      menuVars.avgSV, menuVars.intensity, menuVars.interlace,
                                      menuVars.interlaceMultiplier)
    end
    if menuName == "Stutter" then
        return generateStutterSet(menuVars.startSV, menuVars.stutterDuration, menuVars.avgSV)
    end
    if menuName == "Bezier" then
        return generateBezierSet(menuVars.x1, menuVars.y1, menuVars.x2, menuVars.y2,
                                 menuVars.avgSV, menuVars.svPoints + 1, menuVars.interlace,
                                 menuVars.interlaceMultiplier)
    end
    if menuName == "Sinusoidal" then
        return generateSinusoidalSet(menuVars.startSV, menuVars.endSV, menuVars.periods,
                                     menuVars.periodsShift, menuVars.svsPerQuarterPeriod,
                                     menuVars.verticalShift, menuVars.curveSharpness)
    end
    if menuName == "Random" then
        return generateRandomSet(menuVars.avgSV, menuVars.svPoints + 1, menuVars.randomType,
                                 menuVars.randomScale)
    end
    if menuName == "Constant" then
        return {menuVars.avgSV, menuVars.avgSV}
    end
    if menuName == "Still" then
        return generateSetOfValues(menuVars, menuVars.stillIntermediateMotion)
    end
    return nil
end

-- Generates a single set of linear values
-- Returns the set of linear values [Table]
-- Parameters
--    startVal   : starting value of the linear set [Int/Float]
--    endVal     : ending value of the linear set [Int/Float]
--    numValues  : total number of values in the linear set [Int]
--    interlace  : whether or not to interlace another linear set in between [Boolean]
--    interStart : starting value of the linear interlace [Int/Float]
--    interEnd   : ending value of the linear interlace [Int/Float]
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
-- Generates a single set of exponential values
-- Returns the set of exponential values [Table]
-- Parameters
--    exponentialIncrease : whether or not the values will be exponentially increasing [Boolean]
--    numValues           : total number of values in the exponential set [Int]
--    avgValue            : average value of the set [Int/Float]
--    intensity           : value determining sharpness/rapidness of exponential change [Int/Float]
--    interlace           : whether or not to interlace another exponential set between [Boolean]
--    interlaceMultiplier : multiplier of interlaced values relative to usual values [Int/Float]
function generateExponentialSet(exponentialIncrease, numValues, avgValue, intensity, interlace,
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
        if interlace and (i ~= numValues - 1) then
            table.insert(exponentialSet, velocity * interlaceMultiplier)
        end
    end
    normalizeValues(exponentialSet, avgValue, false)
    return exponentialSet
end
-- Generates a single set of stutter values
-- Returns the set of stutter values [Table]
-- Parameters
--    startSV         : velocity of first SV in the stutter [Int/Float]
--    stutterDuration : duration % of the first SV in the stutter [Float]
--    avgSV           : average SV of the stutter [Int/Float]
function generateStutterSet(startSV, stutterDuration, avgSV)
    stutterSet = {startSV} 
    table.insert(stutterSet, calculateSecondStutterValue(startSV, stutterDuration, avgSV))
    return stutterSet
end
-- Generates a single set of cubic bezier values
-- Returns the set of bezier values [Table]
-- Parameters
--    x1                  : x-coordinate of the first (inputted) cubic bezier point [Int/Float]
--    y1                  : y-coordinate of the first (inputted) cubic bezier point [Int/Float]
--    x2                  : x-coordinate of the second (inputted) cubic bezier point [Int/Float]
--    y2                  : y-coordinate of the second (inputted) cubic bezier point [Int/Float]
--    avgValue            : average value of the set [Int/Float]
--    numValues           : total number of values in the bezier set [Int]
--    interlace           : whether or not to interlace another bezier set in between [Boolean]
--    interlaceMultiplier : multiplier of interlaced values relative to usual values [Int/Float]
function generateBezierSet(x1, y1, x2, y2, avgValue, numValues, interlace, interlaceMultiplier)
    local startingTimeGuess = 0.5
    local timeGuesses = {}
    local targetXPositions = {}
    local iterations = 20
    for i = 1, numValues do
        table.insert(timeGuesses, startingTimeGuess)
        table.insert(targetXPositions, i / numValues)
    end
    for i = 1, iterations do
        local timeIncrement = 0.5 ^ (i + 1)
        for j = 1, numValues do
            local xPositionGuess = simplifiedOneDimensionalBezier(x1, x2, timeGuesses[j])
            if xPositionGuess < targetXPositions[j] then
                timeGuesses[j] = timeGuesses[j] + timeIncrement
            elseif xPositionGuess > targetXPositions[j] then
                timeGuesses[j] = timeGuesses[j] - timeIncrement
            end
        end
    end
    local yPositions = {}
    for i = 1, #timeGuesses do
        table.insert(yPositions, simplifiedOneDimensionalBezier(y1, y2, timeGuesses[i]))
    end
    table.insert(yPositions, 1, 0)
    local bezierSet = {}
    for i = 1, #yPositions - 1 do
        local velocity = (yPositions[i + 1] - yPositions[i]) * numValues
        table.insert(bezierSet, velocity)
        if interlace then
            table.insert(bezierSet, velocity * interlaceMultiplier)
        end
    end
    normalizeValues(bezierSet, avgValue, false)
    return bezierSet
end
-- Generates a single set of sinusoidal values
-- Returns the set of sinusoidal values [Table]
-- Parameters
--    startAmplitude         : starting amplitude of the sinusoidal wave [Int/Float]
--    endAmplitude           : ending amplitude of the sinusoidal wave [Int/Float]
--    periods                : number of periods/cycles of the sinusoidal wave [Int/Float]
--    periodsShift           : number of periods/cycles to shift the sinusoidal wave [Int/Float]
--    valuesPerQuarterPeriod : number of values to calculate per quarter period/cycle [Int/Float]
--    verticalShift          : constant to add to each value in the set at very the end [Int/Float]
--    curveSharpness         : value determining the curviness of the sine curve [Int/Float]
function generateSinusoidalSet(startAmplitude, endAmplitude, periods, periodsShift,
                               valuesPerQuarterPeriod, verticalShift, curveSharpness)
    local sinusoidalSet = {}
    local quarterPeriods = 4 * periods
    local quarterPeriodsShift = 4 * periodsShift
    local totalSVs = valuesPerQuarterPeriod * quarterPeriods
    local amplitudes = generateLinearSet(startAmplitude, endAmplitude, totalSVs + 1, false, 0, 0)
    local normalizedSharpness
    if curveSharpness > 50 then
        normalizedSharpness = math.sqrt((curveSharpness - 50) * 2)
    else
        normalizedSharpness = (curveSharpness / 50) ^ 2
    end
    for i = 0, totalSVs do
        local angle = (math.pi / 2) * ((i / valuesPerQuarterPeriod) + quarterPeriodsShift)
        local velocity = amplitudes[i + 1] * (math.abs(math.sin(angle))^(normalizedSharpness))
        velocity = velocity * mathGetSignOfNum(math.sin(angle)) + verticalShift
        table.insert(sinusoidalSet, velocity)
    end
    return sinusoidalSet
end
-- Generates a single set of random values
-- Returns the set of random values [Table]
-- Parameters
function generateRandomSet(avgValue, numValues, randomType, randomScale)
    local randomSet = {}
    for i = 1, numValues do
        if randomType == "Uniform" then
            local randomValue = avgValue + randomScale * 2 * (0.5 - math.random())
            table.insert(randomSet, randomValue)
        end
        if randomType == "Normal" then
            -- Box-Muller transformation
            local u1 = math.random()
            local u2 = math.random()
            local randomIncrement = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
            local randomValue = avgValue + randomScale * randomIncrement
            table.insert(randomSet, randomValue)
        end
    end
    normalizeValues(randomSet, avgValue, false)
    return randomSet
end

---------------------------------------------------------------------------------------------------
-- Menu Input Widgets, SORTED ALPHABETICALLY ------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Lets users choose the average SV
-- Returns whether or not the average SV changed [Boolean]
-- Parameters
--    menuVars      : list of variables used for the current SV menu [Table]
--    chooseBothSVs : whether to choose both a start and end average or just 1 average [Boolean]
function chooseAverageSV(menuVars, chooseBothSVs)
    local oldAvgValues = {menuVars.avgSV, menuVars.linearEndAvgSV}
    if chooseBothSVs then
        local _, newAvgValues = imgui.InputFloat2("Start/End Avg", oldAvgValues, "%.2fx")
        menuVars.avgSV, menuVars.linearEndAvgSV = table.unpack(newAvgValues)
        menuVars.avgSV = clampToInterval(menuVars.avgSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
        menuVars.linearEndAvgSV = clampToInterval(menuVars.linearEndAvgSV, -MAX_GENERAL_SV,
                                                  MAX_GENERAL_SV)
    else 
        _, menuVars.avgSV = imgui.InputFloat("Average SV", menuVars.avgSV, 0, 0, "%.2fx")
        menuVars.avgSV = clampToInterval(menuVars.avgSV, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    end
    local startValueChanged = oldAvgValues[1] ~= menuVars.avgSV
    local endValueChanged = oldAvgValues[2] ~= menuVars.linearEndAvgSV
    return startValueChanged or endValueChanged
end
-- Lets users choose the average SV of a still
-- Returns whether or not the average SV changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseAverageSVStill(menuVars)
    local oldAvg = menuVars.avgSVStill
    _, menuVars.avgSVStill = imgui.InputFloat("Note spacing", menuVars.avgSVStill, 0, 0, "%.2fx")
    menuVars.avgSVStill = clampToInterval(menuVars.avgSVStill, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    return oldAvg ~= menuVars.avgSVStill
end
-- Lets users choose coordinates for two cubic bezier points
-- Returns whether or not any coordinates changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseBezierPoints(menuVars)
    local oldFirstPoint = {menuVars.x1, menuVars.y1}
    local oldSecondPoint = {menuVars.x2, menuVars.y2}
    local _, newFirstPoint = imgui.DragFloat2("(x1, y1)", oldFirstPoint, 0.01, -1, 2, "%.2f")
    createHelpMarker("Coordinates of the first point of the cubic bezier")
    local _, newSecondPoint = imgui.DragFloat2("(x2, y2)", oldSecondPoint, 0.01, -1, 2, "%.2f")
    createHelpMarker("Coordinates of the second point of the cubic bezier")
    menuVars.x1, menuVars.y1 = table.unpack(newFirstPoint)
    menuVars.x2, menuVars.y2 = table.unpack(newSecondPoint)
    menuVars.x1 = clampToInterval(menuVars.x1, 0, 1)
    menuVars.y1 = clampToInterval(menuVars.y1, -1, 2)
    menuVars.x2 = clampToInterval(menuVars.x2, 0, 1)
    menuVars.y2 = clampToInterval(menuVars.y2, -1, 2)
    local firstXChanged = (oldFirstPoint[1] ~= menuVars.x1) 
    local firstYChanged = (oldFirstPoint[2] ~= menuVars.y1)
    local secondXChanged = (oldSecondPoint[1] ~= menuVars.x2)
    local secondYChanged = (oldSecondPoint[2] ~= menuVars.y2)
    local firstPointChanged = firstXChanged or firstYChanged
    local secondPointChanged = secondXChanged or secondYChanged
    return firstPointChanged or secondPointChanged
end
-- Lets users choose a constant amount to shift SVs
-- Returns whether or not the shift amount changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseConstantShift(menuVars)
    local oldShift = menuVars.verticalShift
    if imgui.Button("Reset ", {DEFAULT_WIDGET_WIDTH * 0.3, DEFAULT_WIDGET_HEIGHT}) then
        menuVars.verticalShift = 0
    end
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.7 - SAMELINE_SPACING)
    _, menuVars.verticalShift = imgui.InputFloat("Vertical Shift", menuVars.verticalShift, 0, 0,
                                                 "%.2fx")
    menuVars.verticalShift = clampToInterval(menuVars.verticalShift, -10, 10)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    return oldShift ~= menuVars.verticalShift
end
-- Lets users choose how to select SVs to copy (between notes times)
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseCopySettings(menuVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Copy SVs Between:")
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Notes", not menuVars.copyBetweenOffsets) then
        menuVars.copyBetweenOffsets = false
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Offsets", menuVars.copyBetweenOffsets) then
        menuVars.copyBetweenOffsets = true
    end
    addPadding()
    if menuVars.copyBetweenOffsets then
        local currentButtonSize = {DEFAULT_WIDGET_WIDTH * 0.4, DEFAULT_WIDGET_HEIGHT}
        if imgui.Button("Current", currentButtonSize) then
            menuVars.startOffsetCopy = state.SongTime
        end
        imgui.SameLine(0, SAMELINE_SPACING)
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.75)
        _, menuVars.startOffsetCopy = imgui.InputInt("Start", menuVars.startOffsetCopy)
        menuVars.startOffsetCopy = clampToInterval(menuVars.startOffsetCopy, 0, MAX_MS_TIME)
        
        if imgui.Button(" Current ", currentButtonSize) then
            menuVars.endOffsetCopy = state.SongTime
        end
        imgui.SameLine(0, SAMELINE_SPACING)
        _, menuVars.endOffsetCopy = imgui.InputInt("End", menuVars.endOffsetCopy)
        menuVars.endOffsetCopy = clampToInterval(menuVars.endOffsetCopy, 0, MAX_MS_TIME)
        addPadding()
    end
end
-- Lets users choose SV curve sharpness
-- Returns whether or not the curve sharpness changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseCurveSharpness(menuVars)
    local oldCurveSharpness = menuVars.curveSharpness
    if imgui.Button("Reset", {DEFAULT_WIDGET_WIDTH * 0.3, DEFAULT_WIDGET_HEIGHT}) then
        menuVars.curveSharpness = 50
    end
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.7 - SAMELINE_SPACING)
    _, menuVars.curveSharpness = imgui.DragInt("Curve Sharpness", menuVars.curveSharpness, 1, 1,
                                               100, "%d%%")
    menuVars.curveSharpness = clampToInterval(menuVars.curveSharpness, 1, 100)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    return oldCurveSharpness ~= menuVars.curveSharpness
end
-- Lets users choose displacement SV options
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
--    menuName   : name of the current SV menu [String]
function chooseDisplacement(globalVars, menuVars, menuName)
    addSeparator()
    if (globalVars.placeSVsBetweenOffsets and menuName ~= "Still") then return end
    if menuName == "Still" then
        _, menuVars.displace = imgui.Checkbox("Add initial displacement to still", 
                                              menuVars.displace)
    else
        _, menuVars.displace = imgui.Checkbox("Displace ends notes", menuVars.displace)
        createHelpMarker("Shifts the note/hit-object receptor up or down, changing how high "..
                         "notes are hit on the screen")
    end
    if menuVars.displace then
        _, menuVars.displacement = imgui.InputFloat("Height", menuVars.displacement, 0, 0,
                                                    "%.2f msx")
        menuVars.displacement = clampToInterval(menuVars.displacement, -MAX_GENERAL_SV,
                                                MAX_GENERAL_SV)
        createHelpMarker("("..round(64 * menuVars.displacement, 2).."x 1/64 ms SV)")
    end
end
-- Lets users choose the exponential behavior (speed up or slow down)
-- Returns whether or not the exponential behavior changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
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
-- Lets users choose the final SV to place at the end
-- Returns whether or not the final SV type changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
--    noNormal : whether or not to include the "Normal" type option [Boolean]
function chooseFinalSV(menuVars, noNormal)
    local oldOption = menuVars.finalSVOption
    local startIndex = 1
    if noNormal then
        startIndex = 2
    end
    addPadding()
    imgui.AlignTextToFramePadding()
    imgui.Text("Final SV:")
    createToolTip("This is the very last SV placed at the end of all SVs")
    imgui.SameLine(0, SAMELINE_SPACING)
    for i = startIndex, #FINAL_SV_TYPES do
        if i ~= startNum then
            imgui.SameLine(0, RADIO_BUTTON_SPACING)
        end
        _, menuVars.finalSVOption = imgui.RadioButton(FINAL_SV_TYPES[i], menuVars.finalSVOption, i)
    end
    return oldOption ~= menuVars.finalSVOption
end
-- Lets users choose the intensity of something (like SV curve)
-- Returns whether or not the intensity changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseIntensity(menuVars)
    local oldIntensity = menuVars.intensity
    _, menuVars.intensity = imgui.SliderInt("Intensity", menuVars.intensity, 1, 100,
                                            menuVars.intensity.."%%")
    menuVars.intensity = clampToInterval(menuVars.intensity, 1, 100)
    return oldIntensity ~= menuVars.intensity
end
-- Lets users choose interlace SV options
-- Returns whether or not interlace settings changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
--    menuName : name of the current menu [String]
--    isLinear : whether or not the interlace is a linear set [Boolean]
function chooseInterlace(menuVars, menuName, isLinear)
    menuName = string.lower(menuName)
    addSeparator()
    local oldInterlace = menuVars.interlace
    local oldMultiplier = menuVars.interlaceMultiplier
    local oldInterlaceValues = {menuVars.secondStartSV, menuVars.secondEndSV}
    _, menuVars.interlace = imgui.Checkbox("Interlace another "..menuName, menuVars.interlace)
    createHelpMarker("Adds another set of "..menuName.." SVs in-between the regular set of SVs")
    if menuVars.interlace then
        if isLinear then
            local _, newInterlaceValues = imgui.InputFloat2("Start/End SV ", oldInterlaceValues,
                                                            "%.2fx")
            menuVars.secondStartSV, menuVars.secondEndSV = table.unpack(newInterlaceValues)
            menuVars.secondStartSV = clampToInterval(menuVars.secondStartSV, -MAX_GENERAL_SV,
                                                     MAX_GENERAL_SV)
            menuVars.secondEndSV = clampToInterval(menuVars.secondEndSV, -MAX_GENERAL_SV,
                                                   MAX_GENERAL_SV)
        else
            _, menuVars.interlaceMultiplier = imgui.InputFloat("Lace multiplier",
                                                               menuVars.interlaceMultiplier, 0, 0,
                                                               "%.2f")
            menuVars.interlaceMultiplier = clampToInterval(menuVars.interlaceMultiplier,
                                                           -MAX_GENERAL_SV, MAX_GENERAL_SV)
        end
    end
    local interlaceChanged = oldInterlace ~= menuVars.interlace
    local multiplierChanged = oldMultiplier ~= menuVars.interlaceMultiplier
    local secondStartSVChanged = oldInterlaceValues[1] ~= menuVars.secondStartSV
    local secondEndSVChanged = oldInterlaceValues[2] ~= menuVars.secondEndSV
    return interlaceChanged or multiplierChanged or secondStartSVChanged or secondEndSVChanged
end
-- Lets users choose the linear stutter option
-- Returns whether or not the chosen linear stutter option changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseLinearStutter(menuVars)
    addSeparator()
    local oldLinearStutter = menuVars.linearStutter
    _, menuVars.linearStutter = imgui.Checkbox("Change stutter values linearly over time",
                                               menuVars.linearStutter)
    return oldLinearStutter ~= menuVars.linearStutter
end
-- Lets users choose the number of periods (for a sinusoidal wave)
-- Returns whether or not the number of periods changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseNumPeriods(menuVars)
    addSeparator()
    local oldPeriods = menuVars.periods
    _, menuVars.periods = imgui.InputFloat("Periods/Cycles", menuVars.periods, 0.25, 0.25, "%.2f")
    menuVars.periods = forceQuarter(menuVars.periods)
    menuVars.periods = clampToInterval(menuVars.periods, 0.25, 20)
    return oldPeriods ~= menuVars.periods
end
-- Lets users choose the number of periods to shift over (for a sinusoidal wave)
-- Returns whether or not the period shift value changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function choosePeriodShift(menuVars)
    local oldPeriodsShift = menuVars.periodsShift
    _, menuVars.periodsShift = imgui.InputFloat("Phase Shift", menuVars.periodsShift, 0.25, 0.25,
                                                "%.2f")
    menuVars.periodsShift = forceQuarter(menuVars.periodsShift)
    menuVars.periodsShift = clampToInterval(menuVars.periodsShift, -0.75, 0.75)
    return oldPeriodsShift ~= menuVars.periodsShift
end
-- Lets users choose the variability of randomness
-- Returns whether or not the variability value changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseRandomScale(menuVars)
    local oldScale = menuVars.randomScale
     _, menuVars.randomScale = imgui.InputFloat("Random Range", menuVars.randomScale, 0, 0, 
                                                "%.2fx")
     menuVars.randomScale = clampToInterval(menuVars.randomScale, -MAX_GENERAL_SV, MAX_GENERAL_SV)
    return oldScale ~= menuVars.randomScale
end
-- Lets users choose the type of random generation
-- Returns whether or not the type of random generation changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseRandomType(menuVars)
    local oldRandomType = menuVars.randomType
    imgui.AlignTextToFramePadding()
    imgui.Text("Random Distribution Type:")
    if imgui.RadioButton("Uniform", menuVars.randomType == "Uniform") then
         menuVars.randomType = "Uniform"
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Normal", menuVars.randomType == "Normal") then
         menuVars.randomType = "Normal"
    end
    addSeparator()
    return oldRandomType ~= menuVars.randomType
end
-- Lets users choose SV input options for the single SV menu
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseSingleSVInputs(menuVars)
    local inputExists = menuVars.svBefore or (not menuVars.skipSVAtNote) or menuVars.svAfter
    if inputExists then
        addSeparator()
    end
    _, menuVars.svBefore = imgui.Checkbox("Add SV before note", menuVars.svBefore)
    _, menuVars.svAfter = imgui.Checkbox("Add SV after note", menuVars.svAfter)
    _, menuVars.skipSVAtNote = imgui.Checkbox("Skip SV at note", menuVars.skipSVAtNote)
    _, menuVars.scaleSVLinearly = imgui.Checkbox("Scale SV values linearly over time",
                                                 menuVars.scaleSVLinearly)
end
-- Lets users choose a start and end SV value
-- Returns whether or not the start and/or end SV value changed [Boolean]
-- Parameters
--    menuVars      : list of variables used for the current SV menu [Table]
--    chooseBothSVs : whether or not to choose both start an end or just start SV values [Boolean]
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
-- Lets users choose the still SV motion type
-- Returns whether or not the motion type changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseStillMotionType(menuVars)
    addSeparator()
    local oldType = menuVars.stillIntermediateMotion
    imgui.Text("Intermediate Motion:")
    if imgui.RadioButton("Constant Velocity", menuVars.stillIntermediateMotion == "Constant") then
        menuVars.stillIntermediateMotion = "Constant"
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Linear", menuVars.stillIntermediateMotion == "Linear") then
        menuVars.stillIntermediateMotion = "Linear"
    end
    if imgui.RadioButton("Exponential", menuVars.stillIntermediateMotion == "Exponential") then
        menuVars.stillIntermediateMotion = "Exponential"
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Bezier", menuVars.stillIntermediateMotion == "Bezier") then
        menuVars.stillIntermediateMotion = "Bezier"
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Sinusoidal", menuVars.stillIntermediateMotion == "Sinusoidal") then
        menuVars.stillIntermediateMotion = "Sinusoidal"
    end
    return oldType ~= menuVars.stillIntermediateMotion
end
-- Lets users choose the stutter duration
-- Returns whether or not the stutter duration changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseStutterDuration(menuVars)
    local oldDuration = menuVars.stutterDuration
     _, menuVars.stutterDuration = imgui.SliderInt("Duration", menuVars.stutterDuration, 1, 99,
                                                   menuVars.stutterDuration.."%%")
    menuVars.stutterDuration = clampToInterval(menuVars.stutterDuration, 1, 99)
    addSeparator()
    return oldDuration ~= menuVars.stutterDuration
end
-- Lets users choose the single SV to place after a note
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseSVAfterNote(menuVars)
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
        _, menuVars.svValueAfter = imgui.InputFloat("SV value  ", menuVars.svValueAfter, 0, 0,
                                                    "%.2fx")
    end
    menuVars.svValueAfter = clampToInterval(menuVars.svValueAfter, -MAX_TELEPORT_VALUE,
                                            MAX_TELEPORT_VALUE)
    _, menuVars.incrementAfter = imgui.InputFloat("Time After", menuVars.incrementAfter, 0, 0,
                                                  "%.3f ms")
    menuVars.incrementAfter = clampToInterval(menuVars.incrementAfter, MIN_DURATION, MAX_DURATION)
end
-- Lets users choose the single SV to place at a note
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseSVAtNote(menuVars)
    if menuVars.svBefore then
        addPadding()
    end
    imgui.Text("At note:")
    if menuVars.scaleSVLinearly then
        local atNoteSVValues = {menuVars.svValue, menuVars.svValueEnd}
        _, atNoteSVValues = imgui.InputFloat2("Start/End SV ", atNoteSVValues, "%.2fx")
        menuVars.svValue, menuVars.svValueEnd = table.unpack(atNoteSVValues)
        menuVars.svValueEnd = clampToInterval(menuVars.svValueEnd, -MAX_TELEPORT_VALUE,
                                              MAX_TELEPORT_VALUE)
    else
        _, menuVars.svValue = imgui.InputFloat("SV value ", menuVars.svValue, 0, 0, "%.2fx")
    end
    menuVars.svValue = clampToInterval(menuVars.svValue, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
end
-- Lets users choose the single SV to place before a note
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseSVBeforeNote(menuVars)
    imgui.Text("Before note:")
    if menuVars.scaleSVLinearly then
        local beforeSVValues = {menuVars.svValueBefore, menuVars.svValueBeforeEnd}
        _, beforeSVValues = imgui.InputFloat2("Start/End SV", beforeSVValues, "%.2fx")
        menuVars.svValueBefore, menuVars.svValueBeforeEnd = table.unpack(beforeSVValues)
        menuVars.svValueBeforeEnd = clampToInterval(menuVars.svValueBeforeEnd, -MAX_TELEPORT_VALUE,
                                                    MAX_TELEPORT_VALUE)
    else
        _, menuVars.svValueBefore = imgui.InputFloat("SV value", menuVars.svValueBefore, 0, 0,
                                                     "%.2fx")
    end
    menuVars.svValueBefore = clampToInterval(menuVars.svValueBefore, -MAX_TELEPORT_VALUE,
                                             MAX_TELEPORT_VALUE)
    _, menuVars.incrementBefore = imgui.InputFloat("Time before", menuVars.incrementBefore, 0, 0,
                                                   "%.3f ms")
    menuVars.incrementBefore = clampToInterval(menuVars.incrementBefore, MIN_DURATION,
                                               MAX_DURATION)
end
-- Lets users choose the number of SV points per quarter period (for sinusoidal wave)
-- Returns whether or not the number of SVs changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseSVPerQuarterPeriod(menuVars)
    addPadding()
    imgui.Text("For every 0.25 period/cycle, place...")
    local oldPerQuarterPeriod = menuVars.svsPerQuarterPeriod
    _, menuVars.svsPerQuarterPeriod = imgui.InputInt("SV points", menuVars.svsPerQuarterPeriod)
    menuVars.svsPerQuarterPeriod = clampToInterval(menuVars.svsPerQuarterPeriod, 1, 128)
    return oldPerQuarterPeriod ~= menuVars.svsPerQuarterPeriod
end
-- Lets users choose the number of SVs points
-- Returns whether or not the number of SVs points changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseSVPoints(menuVars)
    local oldSVPoints = menuVars.svPoints
    _, menuVars.svPoints = imgui.InputInt("SV points", menuVars.svPoints, 1, 1)
    menuVars.svPoints = clampToInterval(menuVars.svPoints, 1, 128)
    return oldSVPoints ~= menuVars.svPoints
end
-- Lets users choose how to place SVs
-- Returns whether or not the option for how to place SVs changed [Boolean]
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
--    menuName   : name of the current SV menu [String]
function chooseSVRangeType(globalVars, menuVars, menuName)
    imgui.AlignTextToFramePadding()
    if menuName == "Remove" then
        imgui.Text("Remove SVs between:")
    else
        imgui.Text("Place SVs between:")
    end
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
        menuVars.startOffset = clampToInterval(menuVars.startOffset, 0, MAX_MS_TIME)
        
        if imgui.Button(" Current ", currentButtonSize) then
            menuVars.endOffset = state.SongTime
        end
        imgui.SameLine(0, SAMELINE_SPACING)
        _, menuVars.endOffset = imgui.InputInt("End Offset", menuVars.endOffset)
        menuVars.endOffset = clampToInterval(menuVars.endOffset, 0, MAX_MS_TIME)
        addPadding()
    end
end
-- Lets users choose teleport SV options
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
--    menuName   : name of the current SV menu [String]
function chooseTeleportSV(globalVars, menuVars, menuName)
    addSeparator()
    _, menuVars.addTeleport = imgui.Checkbox("Add teleport SV at beginning", menuVars.addTeleport)
    createHelpMarker("Adds a big (or small) SV at the beginning of the SV set that lasts for a "..
                     "short time")
    if menuVars.addTeleport then
        _, menuVars.teleportValue = imgui.InputFloat("Teleport SV", menuVars.teleportValue, 0, 0,
                                                     "%.2fx")
        menuVars.teleportValue = clampToInterval(menuVars.teleportValue, -MAX_TELEPORT_VALUE,
                                                 MAX_TELEPORT_VALUE)
        _, menuVars.teleportDuration = imgui.InputFloat("Duration", menuVars.teleportDuration,
                                                        0, 0, "%.3f ms")
        menuVars.teleportDuration = clampToInterval(menuVars.teleportDuration, MIN_DURATION,
                                                    MAX_TELEPORT_DURATION)
        if (not globalVars.placeSVsBetweenOffsets) then
            addPadding()
            if imgui.RadioButton("Very start", menuVars.veryStartTeleport) then
                menuVars.veryStartTeleport = true
            end
            imgui.SameLine(0, RADIO_BUTTON_SPACING)
            if imgui.RadioButton("Every "..string.lower(menuName).." set",
                                 not menuVars.veryStartTeleport) then
                menuVars.veryStartTeleport = false
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
-- Math/Calculation Functions ---------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

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
-- Creates a distance vs time graph/plot of SV motion
-- Parameters
--    noteDistances : list of note distances [Table]
--    forNotes      : whether or SV motion is describing notes [Boolean]
function plotSVMotion(noteDistances, forNotes)
    if forNotes then
        imgui.Text("Projected Note Motion (Distance vs Time):")
    else
        imgui.Text("Projected Motion (Distance vs Time):")
    end
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

------------------------------------------------------------ Non-Graph/Plot * SORTED ALPHABETICALLY

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
-- Restricts a number to be within a closed interval
-- Returns the result of the restriction [Int/Float]
-- Parameters
--    x          : number to keep within the interval [Int/Float]
--    lowerBound : lower bound of the interval [Int/Float]
--    upperBound : upper bound of the interval [Int/Float]
function clampToInterval(x, lowerBound, upperBound)
    if x < lowerBound then
        return lowerBound
    end
    if x > upperBound then
        return upperBound
    end
    return x
end
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
    -- if-statement below is needed or else the returned string is messed up when milliseconds is
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

-- Calculates the average value of a set of numbers
-- Returns the average value of the set [Int/Float]
-- Parameters
--    values                    : set of numbers [Table]
--    includeLastValueInAverage : whether or not to include the last value in the average [Boolean]
function getAverage(values, includeLastValueInAverage)
    if #values == 0 or ((not includeLastValueInAverage) and #values == 1) then
        return nil
    end
    if includeLastValueInAverage then
        return totalSum(values, includeLastValueInAverage) / #values
    else
        return totalSum(values, includeLastValueInAverage) / (#values - 1)
    end
end
-- Returns the sign of a number: +1 if the number is non-negative and -1 if negative [Int]
-- Parameters
--    x : number to get the sign of
function mathGetSignOfNum(x)
    if x < 0 then
        return -1
    end
    return 1
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
-- Evaluates a simplified one-dimensional cubic bezier expression for SV value generation purposes
-- Returns the result of the bezier evaluation
-- Parameters
--    v1 : second coordinate of the actual cubic bezier, first for the SV plugin input [Int/Float]
--    v2 : third coordinate of the actual cubic bezier, second for the SV plugin input [Int/Float]
--    t  : time to evaluate the cubic bezier at [Int/Float]
function simplifiedOneDimensionalBezier(v1, v2, t)
    -- this simplified 1-D cubic bezier has points (0, v1, v2, 1) rather than (v1, v2, v3, v4)
    -- this plugin evaluates those points for both x and y: (0, x1, x2, 1), (0, y1, y2, 1)
    return 3*t*(1-t)^2*v1 + 3*t^2*(1-t)*v2 + t^3
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

---------------------------------------------------------------------------------------------------
-- Variable Management ----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Declares/initiates a menu-specific list of variables
-- Returns the list of variables for that menu [Table]
-- Parameters
--    menuName : name of the current SV menu [String]
function declareMenuVariables(menuName)
    -- default/baseline template menu variables
    local menuVars = {
        startSV = 2,
        endSV = 0,
        curveSharpness = 50,
        verticalShift = 0,
        stutterDuration = nil,
        exponentialIncrease = false,
        intensity = 30,
        periods = 1,
        periodsShift = 0.25,
        avgSV = 1,
        svsPerQuarterPeriod = 8,
        svPoints = 16,
        finalSVOption = 1,
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
        addRemovalCondition = false,
        svCondition = 1,
        svConditionValue = 0,
        startOffset = 0,
        endOffset = 0,
        copyBetweenOffsets = false,
        startOffsetCopy = 0,
        endOffsetCopy = 0,
        randomType = "Uniform",
        randomScale = 1,
        avgSVStill = 0.5,
        stillIntermediateMotion = "Constant"
    }
    if menuName == "Stutter" then
        menuVars.startSV = 1.5
        menuVars.endSV = 2
        menuVars.stutterDuration = 50
        menuVars.finalSVOption = 2
    elseif menuName == "Bezier" then
        menuVars.finalSVOption = 2
    elseif menuName == "Sinusoidal" then
        menuVars.endSV = 2
        menuVars.finalSVOption = 2
    elseif menuName == "Random" then
        menuVars.finalSVOption = 2
    elseif menuName == "Still" then
        menuVars.avgSV = 0
    end
    return menuVars
end
-- Retrieves variables from the state
-- Parameters
--    menuName  : name of the current SV menu [String]
--    variables : list of variables for the current SV menu [Table]
function retrieveStateVariables(menuName, variables)
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(menuName..key) or value
    end
end
-- Saves variables to the state
-- Parameters
--    menuName  : name of the current SV menu [String]
--    variables : list of variables for the current SV menu [Table]
function saveStateVariables(menuName, variables)
    for key, value in pairs(variables) do
        state.SetValue(menuName..key, value)
    end
end

---------------------------------------------------------------------------------------------------
-- Extra GUI elements -----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

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
-- Creates a tooltip box when an IMGUI item is hovered over
-- Parameters
--    text : text to appear in the tooltip box
function createToolTip(text)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
        imgui.Text(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end
-- Creates an inline, grayed-out '(?)' symbol that shows a tooltip box when hovered over
-- Parameters
--    text : text to appear in the tooltip box
function createHelpMarker(text)
    imgui.SameLine()
    imgui.TextDisabled("(?)")
    createToolTip(text)
end

---------------------------------------------------------------------------------------------------
-- All other calculator/helper functions, SORTED ALPHABETICALLY -----------------------------------
---------------------------------------------------------------------------------------------------

-- Creates the action button to do something with SVs
-- Parameters
--    globalVars : list of global variables used across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
--    menuName   : name of the current SV menu [String]
function createActionSVButton(globalVars, menuVars, menuName)
    local svButtonText = "SVs "
    if menuName == "Remove" then
        svButtonText = "Remove ".. svButtonText
    else
        svButtonText = "Place ".. svButtonText
    end
    if globalVars.placeSVsBetweenOffsets then
        svButtonText = svButtonText.."Between Start/End Offsets"
    else
        svButtonText = svButtonText.."Between Selected Notes"
    end
    if imgui.Button(svButtonText, ACTION_BUTTON_SIZE) or utils.IsKeyPressed(keys.Y) then
        if menuName == "Remove" then
            removeSVs(menuVars, globalVars)
        else
            placeSVs(menuVars, globalVars)
        end
    end
    createToolTip("Alternatively, press ' Y ' on your keyboard to place SVs and ' T ' to replace"..
                  " (delete old and place new) SVs")
    if utils.IsKeyPressed(keys.T) then
        removeSVs(menuVars, globalVars)
        placeSVs(menuVars, globalVars)
    end
end
-- Creates the copy SV button
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function createCopyButton(menuVars)
    local buttonText = "Copy SVs Between "
    if menuVars.copyBetweenOffsets then
        buttonText = buttonText.."Offsets"
    else
        buttonText = buttonText.."Notes"
    end
    if imgui.Button(buttonText, {240, ACTION_BUTTON_SIZE[2]}) then
        if (not menuVars.copyBetweenOffsets) then
            local selectedNoteOffsets = uniqueSelectedNoteOffsets()
            local startOffset = selectedNoteOffsets[1]
            local endOffset = selectedNoteOffsets[#selectedNoteOffsets]
            menuVars.svValues = copySVs(startOffset, endOffset)
        else
            menuVars.svValues = copySVs(menuVars.startOffsetCopy, menuVars.endOffsetCopy)
        end
    end
end
-- Creates the place single SV button
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function createPlaceSingleSVButton(menuVars)
    if imgui.Button("Place SVs At Selected Notes", ACTION_BUTTON_SIZE) or 
            utils.IsKeyPressed(keys.Y) then
        local SVs = generateSingleSVs(menuVars.skipSVAtNote, menuVars.svBefore,
                                      menuVars.svValueBefore, menuVars.incrementBefore,
                                      menuVars.svAfter, menuVars.svValueAfter,
                                      menuVars.incrementAfter, menuVars.svValue,
                                      menuVars.scaleSVLinearly, menuVars.svValueBeforeEnd,
                                      menuVars.svValueEnd, menuVars.svValueAfterEnd)
        if #SVs > 0 then
            actions.PlaceScrollVelocityBatch(SVs)
        end
    end
end
-- Calculates and displays info/stats about the current menu's projected SVs
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
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
            imgui.Text("First SVs:")
            imgui.Text("Second SVs:")
            imgui.Text("Stutter Averages:")
            imgui.NextColumn()
            imgui.Text(firstSV.."x --> "..endFirstSV.."x")
            imgui.Text(secondSV.."x --> "..endSecondSV.."x")
            imgui.Text(roundedAvgSV.."x -->"..roundedEndAvgSV.."x")
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
-- Provides a copy-pastable link to a website that lets you play around with a cubic bezier curve
function provideLinkToBezierWebsite()
    local url = "https://cubic-bezier.com/"
    imgui.InputText("Helpful site", url, #url, imgui_input_text_flags.AutoSelectAll)
    createHelpMarker("This site lets you play around with a cubic bezier whose graph represents "..
                     "the motion/path of notes. Play around with the points until you find a "..
                     "good shape for note motion and input those coordinates below")
    addSeparator()
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
-- Updates SVs that are pre-stored in menu variables
-- Parameters
--    menuVars   : list of variables used for the current SV menu [Table]
--    menuName   : name of the current SV menu [String]
function updateMenuSVs(menuVars, menuName)
    menuVars.svValues = generateSetOfValues(menuVars, menuName)
    menuVars.noteDistanceVsTime = calculateDistanceVsTime(menuVars.svValues,
                                                          menuVars.stutterDuration)
    menuVars.svValuesPreview = {}
    for i = 1, #menuVars.svValues do
        table.insert(menuVars.svValuesPreview, menuVars.svValues[i])
    end
    if menuVars.stutterDuration ~=nil then
       menuVars.svValuesSecondPreview = generateStutterSet(menuVars.endSV,
                                                           menuVars.stutterDuration,
                                                           menuVars.linearEndAvgSV)
    end
    if menuVars.finalSVOption ~= 1 and (menuVars.stutterDuration == nil) then
        table.remove(menuVars.svValuesPreview, #menuVars.svValuesPreview)
    end
    if menuVars.finalSVOption == 3 then
        if menuVars.linearStutter then
            table.insert(menuVars.svValuesSecondPreview, 1)
        else
            table.insert(menuVars.svValuesPreview, 1)
        end
    end
end