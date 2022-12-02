-- amoguSV v5.0 beta (30 Nov 2022)
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
-- game. The plugin provides various tools to place, edit, and delete SVs (Scroll Velocities)
-- quickly and efficiently when making maps.

-- If you have any feature suggestions or issues with the plugin, please open an issue at 
-- https://github.com/kloi34/amoguSV/issues

---------------------------------------------------------------------------------------------------
-- Global Constants -------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- IMGUI / GUI
DEFAULT_WIDGET_HEIGHT = 26         -- value determining the height of GUI widgets
DEFAULT_WIDGET_WIDTH = 160         -- value determining the width of GUI widgets
PADDING_WIDTH = 8                  -- value determining window and frame padding
SAMELINE_SPACING = 5               -- value determining spacing between GUI items on the same row
RADIO_BUTTON_SPACING = 7.5         -- value determining spacing between radio buttons
ACTION_BUTTON_SIZE = {             -- dimensions of the button that places/removes SVs
    1.6 * DEFAULT_WIDGET_WIDTH - 1,
    1.6 * DEFAULT_WIDGET_HEIGHT
}
SV_INFO_WINDOW_SIZE = {271, 334}

-- SV/Time restrictions
MAX_SV_POINTS = 1000               -- maximum number of SV points allowed
MIN_DURATION = 1/64                -- minimum millisecond duration allowed in general
MIN_DURATION_FAR = 1/8             -- minimum millisecond duration for teleports above 4 minutes

-- Menu-related
EMOTICONS = {                      -- emoticons to visually clutter the plugin and confuse users
    "( - _ - )",
    "( e . e )",
    "( o _ 0 )",
    "( * o * )",
    "( ~ _ ~ )",
    "( w . w )",
    "( ^ w ^ )",
    "( > . < )",
    "( c . p )",
    "( ; _ ; )",
    "[ m w m ]",
    "[ v . ^ ]"
}
FINAL_SV_TYPES = {                 -- options for the last SV placed at the tail end of all SVs
    "Normal",
    "Skip",
    "Custom"   
}
TAB_MENUS = {                      -- tabs of different SV menus
    "Info",
    "Place SVs",
    "Edit SVs",
    "Delete SVs"
}
PLACE_TYPE = {                     -- general categories of SVs to place
    "Standard",
    "Special",
}
STANDARD_SV = {                      -- tools/shapes for placing SVs
    "Linear",
    "Exponential",
    "Bezier",
    "Sinusoidal",
    "Random",
    "Custom"
}
SPECIAL_SV = {                     -- special/gimmick SV types to place
    "Stutter",
    "Single",
--    "Combo",
    "Reverse Scroll",
    "Splitscroll",
    "Animate"
}
EDIT_SV_TOOLS = {                  -- tools for editing SVs
    "Copy & Paste",
    "Displace Note",
    "Displace View",
    "Measure",
    "Merge",
    "Scale"
--    "Vibe"
}
SCALE_TYPES = {                    -- ways to scale SV multipliers
    "Average SV",
    "Absolute Distance",
    "Relative Ratio"
}
DISPLACE_TYPES = {                 -- ways to scale/calculate distances
    "Relative Distance",
    "Absolute Distance"
}
SECTIONS = {                       -- ways to apply SV actions on sections
    "Per note section",
    "Whole section"
}
BEHAVIORS = {                      -- 
    "Slow down",
    "Speed up"
}
RANDOM_DISTRIBUTION_TYPE = {
    "Normal",
    "Uniform"
}
---------------------------------------------------------------------------------------------------
-- Plugin Styles and Colors -----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Configures the plugin GUI appearance
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function setPluginAppearance(globalVars)
    if globalVars.rgb then
        activateRGBColors(globalVars)
        updateRGBColors(globalVars)
        state.SetValue("initialized", false)
    elseif not (state.GetValue("initialized") or false) then
        setDefaultPluginAppearance()
        state.SetValue("initialized", true)
    end
end
-- Configures the plugin GUI to have the default appearance (colors and styles)
function setDefaultPluginAppearance()
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
    imgui.PushStyleColor( imgui_col.Tab,                    { 0.31, 0.38, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabHovered,             { 0.51, 0.58, 0.75, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabActive,              { 0.51, 0.58, 0.75, 1.00 } )
    imgui.PushStyleColor( imgui_col.Header,                 { 0.81, 0.88, 1.00, 0.40 } )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          { 0.81, 0.88, 1.00, 0.50 } )
    imgui.PushStyleColor( imgui_col.HeaderActive,           { 0.81, 0.88, 1.00, 0.54 } )
    imgui.PushStyleColor( imgui_col.Separator,              { 0.81, 0.88, 1.00, 0.30 } )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 0.81, 0.88, 1.00, 0.40 } )
end
-- Changes plugin colors to RGB colors
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function activateRGBColors(globalVars)
    local activeColor = {globalVars.red, globalVars.green, globalVars.blue, 0.8}
    local inactiveColor = {globalVars.red, globalVars.green, globalVars.blue, 0.5}
    local white = {1.00, 1.00, 1.00, 1.00}
    local clearWhite = {1.00, 1.00, 1.00, 0.40}
    
    imgui.PushStyleColor( imgui_col.FrameBg,                inactiveColor )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         activeColor   )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          activeColor   )
    imgui.PushStyleColor( imgui_col.TitleBg,                inactiveColor )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          activeColor   )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       inactiveColor )
    imgui.PushStyleColor( imgui_col.CheckMark,              white         )
    imgui.PushStyleColor( imgui_col.SliderGrab,             white         )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       white         )
    imgui.PushStyleColor( imgui_col.Button,                 inactiveColor )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          activeColor   )
    imgui.PushStyleColor( imgui_col.ButtonActive,           activeColor   )
    imgui.PushStyleColor( imgui_col.Tab,                    inactiveColor )
    imgui.PushStyleColor( imgui_col.TabHovered,             activeColor   )
    imgui.PushStyleColor( imgui_col.TabActive,              activeColor   )
    imgui.PushStyleColor( imgui_col.Header,                 inactiveColor )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          inactiveColor )
    imgui.PushStyleColor( imgui_col.HeaderActive,           activeColor   )
    imgui.PushStyleColor( imgui_col.Separator,              activeColor   )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         clearWhite    )
end
-- Updates global RGB color values, cycling through high-saturation colors
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function updateRGBColors(globalVars)
    local fullyRed = globalVars.red == 1
    local noRed = globalVars.red == 0
    local fullyGreen = globalVars.green == 1
    local noGreen = globalVars.green == 0
    local fullyBlue = globalVars.blue == 1
    local noBlue = globalVars.blue == 0
    
    local increaseRed = fullyBlue and noGreen and (not fullyRed)
    local increaseGreen = fullyRed and noBlue and (not fullyGreen)
    local increaseBlue = fullyGreen and noRed and (not fullyBlue)
    local decreaseRed = fullyGreen and noBlue and (not noRed)
    local decreaseGreen = fullyBlue and noRed and (not noGreen)
    local decreaseBlue = fullyRed and noGreen and (not noBlue)
    
    local increment = 0.0005
    if increaseRed then globalVars.red = round(globalVars.red + increment, 4) return end
    if decreaseRed then globalVars.red = round(globalVars.red - increment, 4) return end
    if increaseGreen then globalVars.green = round(globalVars.green + increment, 4) return end
    if decreaseGreen then globalVars.green = round(globalVars.green - increment, 4) return end
    if increaseBlue then globalVars.blue = round(globalVars.blue + increment, 4) return end
    if decreaseBlue then globalVars.blue = round(globalVars.blue - increment, 4) return end
end

---------------------------------------------------------------------------------------------------
-- Variable Management ----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Retrieves variables from the state
-- Parameters
--    listName  : name of the variable list [String]
--    variables : list of variables [Table]
function getVariables(listName, variables) 
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(listName..key) or value
    end
end
-- Saves variables to the state
-- Parameters
--    listName  : name of the variable list [String]
--    variables : list of variables [Table]
function saveVariables(listName, variables)
    for key, value in pairs(variables) do
        state.SetValue(listName..key, value)
    end
end

---------------------------------------------------------------------------------------------------
-- Handy GUI elements -----------------------------------------------------------------------------
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
-- Creates a tooltip box when the last (most recent) item is hovered over
-- Parameters
--    text : text to appear in the tooltip box [String]
function toolTip(text)
    if not imgui.IsItemHovered() then return end
    imgui.BeginTooltip()
    imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
    imgui.Text(text)
    imgui.PopTextWrapPos()
    imgui.EndTooltip()
end
-- Creates an inline, grayed-out '(?)' symbol that shows a tooltip box when hovered over
-- Parameters
--    text : text to appear in the tooltip box [String]
function helpMarker(text)
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.TextDisabled("(?)")
    toolTip(text)
end
-- Creates a copy-pastable link
-- Parameters
--    text : text to describe the url [String]
--    url  : url [String]
function provideLink(text, url)
    addPadding()
    imgui.TextWrapped(text)
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth())
    imgui.InputText("##"..url, url, #url, imgui_input_text_flags.AutoSelectAll)
    imgui.PopItemWidth()
    addPadding()
end

---------------------------------------------------------------------------------------------------
-- Plugin Menus (+ other higher level menu-related functions) -------------------------------------
---------------------------------------------------------------------------------------------------

-- Creates the plugin window
function draw()
    local globalVars = {
        useManualOffsets = false,
        startOffset = 0,
        endOffset = 0,
        teleportDistance = 10000,
        rgb = false,
        red = 0,
        green = 1,
        blue = 1,
        editToolIndex = 1,
        placeTypeIndex = 1,
        debugText = "debuggy"
    }
    getVariables("globalVars", globalVars)
    setPluginAppearance(globalVars)

    imgui.Begin("amoguSV", imgui_window_flags.AlwaysAutoResize)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    imgui.BeginTabBar("SV tabs")
    for i = 1, #TAB_MENUS do
        createMenuTab(TAB_MENUS[i], globalVars)
    end
    imgui.EndTabBar()
    state.IsWindowHovered = imgui.IsWindowHovered()
    imgui.End()
    
    saveVariables("globalVars", globalVars)
end

----------------------------------------------------------------------------------------- Tab stuff

function createMenuTab(tabName, globalVars)
    if not imgui.BeginTabItem(tabName) then return end
    addPadding()
    if tabName == "Info"       then infoTab(globalVars) end
    if tabName == "Place SVs"  then placeSVTab(globalVars) end
    if tabName == "Edit SVs"   then editSVTab(globalVars) end
    if tabName == "Delete SVs" then deleteSVTab(globalVars) end
    imgui.EndTabItem()
end
-- Creates the "Info" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function infoTab(globalVars)
    showInfoLinks()
    choosePluginSettings(globalVars)
end
-- Display links relevant to the plugin
function showInfoLinks()
    if not imgui.CollapsingHeader("Links") then return end
    provideLink("Quaver SV Guide", "https://kloi34.github.io/QuaverSVGuide")
    provideLink("GitHub Repository", "https://github.com/kloi34/amoguSV")
end
-- Lets users choose global plugin settings
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function choosePluginSettings(globalVars)
    if not imgui.CollapsingHeader("Plugin Settings") then return end
    addPadding()
    chooseSVSelection(globalVars)
    addSeparator()
    chooseRGBMode(globalVars)
end
-- Creates the "Place SVs" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function placeSVTab(globalVars)
    choosePlaceSVType(globalVars)
    --addSeparator()
    local placeType = PLACE_TYPE[globalVars.placeTypeIndex]
    if placeType == "Standard" then placeStandardSVMenu(globalVars) end
    if placeType == "Special"  then placeSpecialSVMenu(globalVars) end
end
-- Creates the "Edit SVs" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function editSVTab(globalVars)
    chooseEditTool(globalVars)
    addSeparator()
    local toolName = EDIT_SV_TOOLS[globalVars.editToolIndex]
    if toolName == "Copy & Paste"  then copyNPasteMenu(globalVars) end
    if toolName == "Displace Note" then displaceNoteMenu(globalVars) end
    if toolName == "Displace View" then displaceViewMenu(globalVars) end
    if toolName == "Measure"       then measureSVMenu(globalVars) end
    if toolName == "Merge"         then simpleActionMenu("Merge", mergeSVs, globalVars, nil) end
    if toolName == "Scale"         then scaleSVMenu(globalVars) end
    --imgui.Text(globalVars.debugText)
end
-- Creates the "Delete SVs" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function deleteSVTab(globalVars)
    simpleActionMenu("Delete", deleteSVs, globalVars, nil)
end

---------------------------------------------------------------------------------------- Tool Menus

-- Creates the menu for placing standard SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function placeStandardSVMenu(globalVars)
    local menuVars = {
        svTypeIndex = 1,
        svMultipliers = {},
        svDistances = {},
        svStats = {
            minScale = 0,
            maxScale = 0,
            distMinScale = 0,
            distMaxScale = 0,
            minSV = 0,
            maxSV = 0,
            avgSV = 0
        }
    }
    getVariables("placeStandardMenu", menuVars)
    local needSVUpdate =  #menuVars.svMultipliers == 0
    needSVUpdate = chooseStandardSVType(menuVars) or needSVUpdate
    local currentSVType = STANDARD_SV[menuVars.svTypeIndex]
    local menuFunctionName = string.lower(currentSVType).."SettingsMenu"
    local settingVars = getSettingVars(currentSVType)
    needSVUpdate = _G[menuFunctionName](settingVars) or needSVUpdate
    if needSVUpdate then
        menuVars.svMultipliers = generateSVMultipliers(currentSVType, settingVars)
        local svMultipliersNoEndSV = makeDuplicateList(menuVars.svMultipliers)
        table.remove(svMultipliersNoEndSV, #svMultipliersNoEndSV)
        local finalSVType = FINAL_SV_TYPES[settingVars.finalSVIndex]
        if finalSVType == "Skip" then
            table.remove(menuVars.svMultipliers, #menuVars.svMultipliers)
        end
        if finalSVType == "Custom" then
            table.remove(menuVars.svMultipliers, #menuVars.svMultipliers)
            table.insert(menuVars.svMultipliers, settingVars.customSV)
        end
        menuVars.svDistances = calculateDistanceVsTime(svMultipliersNoEndSV, nil)
        updateSVStats(currentSVType, menuVars, menuVars.svMultipliers, svMultipliersNoEndSV)
    end
    addSeparator()
    makeSVInfoWindow(menuVars)
    simpleActionMenu("Place", placeSVs, globalVars, menuVars)
    saveVariables(currentSVType.."Settings", settingVars)
    saveVariables("placeStandardMenu", menuVars)
end
function makeSVInfoWindow(menuVars)
    imgui.SetNextWindowSize(SV_INFO_WINDOW_SIZE)
    imgui.Begin("SV Info", imgui_window_flags.AlwaysAutoResize)
    imgui.Text("Projected Note Motion:")
    helpMarker("Distance vs Time graph of notes")
    plotSVMotion(menuVars.svDistances, menuVars.svStats.distMinScale, menuVars.svStats.distMaxScale)
    imgui.Text("Projected SVs:")
    plotSVs(menuVars.svMultipliers, menuVars.svStats.minScale, menuVars.svStats.maxScale)
    displaySVStats(menuVars.svStats)
    imgui.Text(#menuVars.svDistances)
    imgui.Text(#menuVars.svMultipliers)
    imgui.End()
end
function displaySVStats(svStats)
    imgui.Columns(2, "SV Stats", false)
    imgui.Text("Max SV:")
    imgui.Text("Min SV:")
    imgui.Text("Average SV:")
    imgui.NextColumn()
    imgui.Text(svStats.maxSV.."x")
    imgui.Text(svStats.minSV.."x")
    imgui.Text(svStats.avgSV.."x")
    imgui.Columns(1)
end
function updateSVStats(currentSVType, menuVars, svMultipliers, svMultipliersNoEndSV)
    menuVars.svStats.minScale, menuVars.svStats.maxScale = calculatePlotScale(svMultipliers)
    menuVars.svStats.distMinScale, menuVars.svStats.distMaxScale = calculatePlotScale(menuVars.svDistances)
    menuVars.svStats.minSV = round(calculateMinValue(svMultipliersNoEndSV), 2)
    menuVars.svStats.maxSV = round(calculateMaxValue(svMultipliersNoEndSV), 2)
    menuVars.svStats.avgSV = round(calculateAverage(svMultipliersNoEndSV, true), 2)
end
function getSettingVars(svType)
    local settingVars
    if svType == "Linear" then
        settingVars = {
            startSV = 1.5,
            endSV = 0.5,
            svPoints = 16,
            finalSVIndex = 1,
            customSV = 1
        }
    elseif svType == "Exponential" then
        settingVars = {
            behaviorIndex = 1,
            intensity = 30,
            avgSV = 1,
            svPoints = 16,
            finalSVIndex = 1,
            customSV = 1
        }
    elseif svType == "Stutter" then
        settingVars = {
            svPoints = 16,
            finalSVIndex = 1,
            customSV = 1
        }
    elseif svType == "Bezier" then
        settingVars = {
            x1 = 0,
            y1 = 0,
            x2 = 0,
            y2 = 1,
            avgSV = 1,
            svPoints = 16,
            finalSVIndex = 1,
            customSV = 1
        }
    elseif svType == "Sinusoidal" then
        settingVars = {
            startSV = 2,
            endSV = 2,
            curveSharpness = 50,
            verticalShift = 1,
            periods = 1,
            periodsShift = 0.25,
            svsPerQuarterPeriod = 8,
            svPoints = 16,
            finalSVIndex = 1,
            customSV = 1
        }
    elseif svType == "Random" then
        settingVars = {
            randomTypeIndex = 1,
            randomScale = 2,
            avgSV = 1,
            svPoints = 16,
            finalSVIndex = 1,
            customSV = 1
        }
    elseif svType == "Custom" then
        settingVars = {
            svMultipliers = {1.5, -0.5, 1.5, -0.5, 1.5, -0.5, 1.5, -0.5},
            selectedMultiplierIndex = 1,
            svPoints = 8,
            finalSVIndex = 1,
            customSV = 1
        }
    end
    getVariables(svType.."Settings", settingVars)
    return settingVars
end
-- Creates the menu for linear SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this menu [Table]
function linearSettingsMenu(settingVars)
    local settingsChanged = false
    settingsChanged = chooseStartEndSVs(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for exponential SV settings
-- Parameters
--    settingVars : list of setting variables for this menu [Table]
function exponentialSettingsMenu(settingVars)
    local settingsChanged = false
    imgui.PushStyleVar( imgui_style_var.GrabRounding, 5) -- uuuh
    settingsChanged = chooseExponentialBehavior(settingVars) or settingsChanged
    settingsChanged = chooseIntensity(settingVars) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
--[[
-- Creates the menu for stutter SV settings
-- Parameters
--    settingVars : list of setting variables for this menu [Table]
function stutterSettingsMenu(settingVars)
    local settingsChanged = false
    return settingsChanged
end
--]]
-- Creates the menu for bezier SV settings
-- Parameters
--    settingVars : list of setting variables for this menu [Table]
function bezierSettingsMenu(settingVars)
    local settingsChanged = false
    settingsChanged = provideLinkToBezierWebsite(settingVars) or settingsChanged
    settingsChanged = chooseBezierPoints(settingVars) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Provides a copy-pastable link to a website that lets you play around with a cubic bezier curve
-- Returns whether new bezier coordinates were parsed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function provideLinkToBezierWebsite(settingVars)
    local coordinateParsed = false
    local bezierText = state.GetValue("bezierText") or "https://cubic-bezier.com/"
    _, bezierText = imgui.InputText("##bezierWebsite", bezierText, 100, imgui_input_text_flags.AutoSelectAll)
    imgui.SameLine()
    -- stolen + modified from iceSV -_-
    if imgui.Button("Parse", {DEFAULT_WIDGET_WIDTH * 0.3, DEFAULT_WIDGET_HEIGHT - 2}) then
        local regex = "(-?%d*%.?%d+)"
        local captures = {}
        for capture, _ in string.gmatch(bezierText, regex) do
            table.insert(captures, tonumber(capture))
        end
        if #captures >= 4 then
            settingVars.x1, settingVars.y1, settingVars.x2, settingVars.y2  = table.unpack(captures)
            coordinateParsed = true
        end
        bezierText = "https://cubic-bezier.com/"
    end
    state.SetValue("bezierText", bezierText)
    helpMarker("This site lets you play around with a cubic bezier whose graph represents "..
                     "the motion/path of notes. After finding a good shape for note motion, "..
                     "paste the resulting url into the input box and hit the parse button to "..
                     "import the coordinate values. Alternatively, enter 4 numbers and hit parse.")
    addSeparator()
    return coordinateParsed
end
-- Creates the menu for sinusoidal SV settings
-- Parameters
--    settingVars : list of setting variables for this menu [Table]
function sinusoidalSettingsMenu(settingVars)
    local settingsChanged = false
    imgui.Text("Amplitude:")
    settingsChanged = chooseStartEndSVs(settingVars) or settingsChanged
    settingsChanged = chooseCurveSharpness(settingVars) or settingsChanged
    settingsChanged = chooseConstantShift(settingVars) or settingsChanged
    settingsChanged = chooseNumPeriods(settingVars) or settingsChanged
    settingsChanged = choosePeriodShift(settingVars) or settingsChanged
    settingsChanged = chooseSVPerQuarterPeriod(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for random SV settings
-- Parameters
--    settingVars : list of setting variables for this menu [Table]
function randomSettingsMenu(settingVars)
    local settingsChanged = false
    settingsChanged = chooseRandomType(settingVars) or settingsChanged
    settingsChanged = chooseRandomScale(settingVars) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    addSeparator()
    if imgui.Button("Generate New Random Set") then settingsChanged = true end
    return settingsChanged
end
-- Creates the menu for custom SV settings
-- Parameters
--    settingVars : list of setting variables for this menu [Table]
function customSettingsMenu(settingVars)
    local settingsChanged = false
    settingsChanged = chooseCustomMultipliers(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    adjustNumberOfMultipliers(settingVars)
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
function adjustNumberOfMultipliers(settingVars)
    if settingVars.svPoints > #settingVars.svMultipliers then
        local difference = settingVars.svPoints - #settingVars.svMultipliers
        for i = 1, difference do
            table.insert(settingVars.svMultipliers, 1)
        end
    end
    if settingVars.svPoints < #settingVars.svMultipliers then
        settingVars.selectedMultiplierIndex = settingVars.svPoints
        local difference = #settingVars.svMultipliers - settingVars.svPoints
        for i = 1, difference do
            table.remove(settingVars.svMultipliers, #settingVars.svMultipliers)
        end
    end
end

function chooseCustomMultipliers(settingVars)
    imgui.BeginChild("Custom Multipliers", {imgui.GetContentRegionAvailWidth(), 100}, true)
    for i = 1, #settingVars.svMultipliers do
        if imgui.Selectable("SV # "..i.." : "..settingVars.svMultipliers[i], settingVars.selectedMultiplierIndex == i) then
            settingVars.selectedMultiplierIndex = i
        end
    end
    imgui.EndChild()
    local index = settingVars.selectedMultiplierIndex
    local oldMultiplier = settingVars.svMultipliers[index]
    _, settingVars.svMultipliers[index] = imgui.InputFloat("SV multiplier", oldMultiplier, 0, 0, "%.2fx")
    addSeparator()
    return oldMultiplier ~= settingVars.svMultipliers[index]
end
-- Creates the menu for placing special SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function placeSpecialSVMenu(globalVars)
    local menuVars = {
        svTypeIndex = 1
    }
    getVariables("placeSpecialMenu", menuVars)
    chooseSpecialSVType(menuVars)
    imgui.Text("Coming Soon (this is still beta amoguSV v5.0)")
    saveVariables("placeSpecialMenu", menuVars)
end
-- Creates the copy and paste menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function copyNPasteMenu(globalVars)
    local menuVars = {
        copiedSVs = {}
    }
    getVariables("copyMenu", menuVars)
    local noSVsCopiedInitially = #menuVars.copiedSVs == 0 
    imgui.Text(#menuVars.copiedSVs.." SVs copied")
    addSeparator()
    if noSVsCopiedInitially then
        simpleActionMenu("Copy", copySVs, globalVars, menuVars)
    end
    if #menuVars.copiedSVs > 0 and imgui.Button("Clear copied SVs", ACTION_BUTTON_SIZE) then
        menuVars.copiedSVs = {}
    end
    saveVariables("copyMenu", menuVars)
    if noSVsCopiedInitially then return end
    
    addSeparator()
    if imgui.Button("Paste SVs at current song time", ACTION_BUTTON_SIZE) then
        local pasteOffsets = {math.floor(state.SongTime)}
        pasteSVs(menuVars.copiedSVs, pasteOffsets)
    end
    local pasteKeyPressed = utils.IsKeyPressed(keys.T) 
    if imgui.Button("Paste SVs at selected notes", ACTION_BUTTON_SIZE) or pasteKeyPressed then
        local pasteOffsets = uniqueSelectedNoteOffsets()
        pasteSVs(menuVars.copiedSVs, pasteOffsets)
    end
    toolTip("You can also press 'T' on your keyboard to paste SVs at selected notes")
end
-- Creates the displace note menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function displaceNoteMenu(globalVars)
    local menuVars = {
        displaceTypeIndex = 1,
        distance = 100
    }
    getVariables("displaceNoteMenu", menuVars)
    chooseDisplaceType(globalVars, menuVars)
    chooseDistance(menuVars)
    addSeparator()
    simpleActionMenu("Displace note", displaceNoteSVs, globalVars, menuVars)
    saveVariables("displaceNoteMenu", menuVars)
end
-- Creates the displace view menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function displaceViewMenu(globalVars)
    local menuVars = {
        displaceTypeIndex = 1,
        distance = 100
    }
    getVariables("displaceViewMenu", menuVars)
    chooseDisplaceType(globalVars, menuVars)
    chooseDistance(menuVars)
    addSeparator()
    simpleActionMenu("Displace view", displaceViewSVs, globalVars, menuVars)
    saveVariables("displaceViewMenu", menuVars)
end
-- Creates the measure menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function measureSVMenu(globalVars)
    local menuVars = {
        measuredNSVDistance = 0,
        measuredDistance = 0
    }
    getVariables("measureMenu", menuVars)
    local text1 = "NSV Distance: "
    local text2 = "SV Distance: "
    if menuVars.measuredNSVDistance and menuVars.measuredDistance then
        text1 = text1..menuVars.measuredNSVDistance
        text2 = text2..menuVars.measuredDistance
    end
    imgui.Text(text1.." msx")
    helpMarker("This is the normal distance between the start and the end, ignoring SVs")
    imgui.Text(text2.." msx")
    helpMarker("This is the actual distance between the start and the end (rounded to 5 decimal "..
               "places), calculated with SVs")
    addSeparator()
    simpleActionMenu("Measure", measureSVs, globalVars, menuVars)
    saveVariables("measureMenu", menuVars)
end
-- Creates the scale menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function scaleSVMenu(globalVars)
    local menuVars = {
        scaleTypeIndex = 1,
        distance = 100,
        avgSV = 0.6,
        ratio = 0.6,
        sectionIndex = 1
    }
    getVariables("scaleMenu", menuVars)
    chooseSVScale(menuVars)
    chooseSection(globalVars, menuVars)
    addSeparator()
    simpleActionMenu("Scale", scaleSVs, globalVars, menuVars)
    saveVariables("scaleMenu", menuVars)
end

---------------------------------------------------------------------------------------------------
-- General Utility Functions ----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Combs through a list and locates unique values
-- Returns a list of only unique values (no duplicates) [Table]
-- Parameters
--    list : list of values [Table]
function removeDuplicateValues(list)
    local hash = {}
    local newList = {}
    for _, value in ipairs(list) do
        if (not hash[value]) then
            newList[#newList + 1] = value
            hash[value] = true
        end
    end
    return newList
end
function makeDuplicateList(list)
    local duplicateList = {}
    for _, thing in pairs(list) do
        table.insert(duplicateList, thing)
    end  
    return duplicateList
end
-- Constructs a new table from an old table with the order reversed
-- Returns the reversed table [Table]
-- Parameters
--    oldTable      : table to be reversed [Table]
function getReverseTable(oldTable)
    local reverseTable = {}
    for i = 1, #oldTable do
        table.insert(reverseTable, oldTable[#oldTable + 1 - i])
    end
    return reverseTable
end
-- Finds unique offsets of all notes between two offsets
-- Returns a list of unique offsets (in increasing order) [Table]
-- Parameters
--    startOffset :
--    endOffset   :
function uniqueNoteOffsets(startOffset, endOffset)
    local offsets = {}
    for i, hitObject in pairs(map.HitObjects) do
        if hitObject.StartTime >= startOffset and hitObject.StartTime <= endOffset then
            table.insert(offsets, hitObject.StartTime)
        end
    end
    offsets = removeDuplicateValues(offsets)
    offsets = table.sort(offsets, function(a, b) return a < b end)
    return offsets
end
-- Finds unique offsets of all notes currently selected in the editor
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
-- Returns a list of SVs between two offsets/times
-- Parameters
--    startOffset : start time in milliseconds [Int]
--    endOffset   : end time in milliseconds [Int]
function getSVsBetweenOffsets(startOffset, endOffset)
    local svsBetweenOffsets = {}
    for i, sv in pairs(map.ScrollVelocities) do
        local svIsInRange = sv.StartTime >= startOffset and sv.StartTime < endOffset
        if svIsInRange then table.insert(svsBetweenOffsets, sv) end
    end
    return svsBetweenOffsets
end
-- Returns the set of selected offsets to be used for SV stuff
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function getSelectedOffsets(globalVars)
    if globalVars.useManualOffsets then return {globalVars.startOffset, globalVars.endOffset} end
    return uniqueSelectedNoteOffsets()
end
-- Gets the SV multiplier at a specified offset in the map
-- Returns the SV multiplier at the offset [Int/Float]
-- Parameters
--    offset : millisecond time [Int/Float]
function getSVMultiplierAt(offset)
    local sv = map.GetScrollVelocityAt(offset) 
    if sv then return sv.Multiplier end
    return 1
end

---------------------------------------------------------------------------------------------- Math

-- Rounds a number to a given amount of decimal places
-- Returns the rounded number [Int/Float]
-- Parameters
--    number        : number to round [Int/Float]
--    decimalPlaces : number of decimal places to round the number to [Int]
function round(number, decimalPlaces)
    local multiplier = 10 ^ decimalPlaces
    return math.floor(number * multiplier + 0.5) / multiplier
end
-- Calculates the average SV over time for a given set of SVs
-- Returns the average SV [Int/Float]
-- Parameters
--    svs       : list of ordered svs to calculate average SV with [Table]
--    endOffset : final time (milliseconds) to stop calculating at [Int]
function calculateAvgSV(svs, endOffset)
    local totalDisplacement = calculateDispacementFromSVs(svs, endOffset)
    local startOffset = svs[1].StartTime
    local timeInterval = endOffset - startOffset
    local avgSV = totalDisplacement / timeInterval
    return avgSV
end
-- Calculates the total msx displacement over time for a given set of SVs
-- Returns the total displacement [Int/Float]
-- Parameters
--    svs       : list of ordered svs to calculate displacement with [Table]
--    endOffset : final time (milliseconds) to stop calculating at [Int]
function calculateDispacementFromSVs(svs, endOffset)
    local totalDisplacement = 0
    table.insert(svs, utils.CreateScrollVelocity(endOffset, 0))
    for i = 1, (#svs - 1) do
        local lastSV = svs[i]
        local nextSV = svs[i + 1]
        local timeDifference = nextSV.StartTime - lastSV.StartTime
        if timeDifference > 0 then
            local thisDisplacement = timeDifference * lastSV.Multiplier
            totalDisplacement = totalDisplacement + thisDisplacement
        end
    end
    table.remove(svs, #svs)
    return totalDisplacement
end
-- Returns whether an offset (in milliseconds) is above 4 minutes [Boolean]
-- Parameters
--    offset: time in milliseconds [Int]
function isAboveFourMinutes(offset)
    return offset > 240000
end
-- Ternary operator: if a then b else c
-- Parameters
--    a : boolean [Boolean]
--    b : thing 1 [Any]
--    c : thing 2 [Any]
function abc(a, b, c)
    if a then return b end
    return c
end
-- Restricts a number to be within a closed interval
-- Returns the result of the restriction [Int/Float]
-- Parameters
--    number     : number to keep within the interval [Int/Float]
--    lowerBound : lower bound of the interval [Int/Float]
--    upperBound : upper bound of the interval [Int/Float]
function clampToInterval(number, lowerBound, upperBound)
    if number < lowerBound then return lowerBound end
    if number > upperBound then return upperBound end
    return number
end
-- Restricts a number to be within a closed interval that wraps around
-- Returns the result of the restriction [Int/Float]
-- Parameters
--    number     : number to keep within the interval [Int/Float]
--    lowerBound : lower bound of the interval [Int/Float]
--    upperBound : upper bound of the interval [Int/Float]
function wrapToInterval(number, lowerBound, upperBound)
    if number < lowerBound then return upperBound end
    if number > upperBound then return lowerBound end
    return number
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
        local svValuesBackwards = getReverseTable(svValues)
        for i = 1, #svValuesBackwards do
            distance = distance + svValuesBackwards[i]
            table.insert(distancesBackwards, distance)
        end
    end
    return getReverseTable(distancesBackwards)
end
-- Calculates the minimum and maximum scale of a plot
-- Returns the minimum scale and maximum scale [Int/Float]
-- Parameters
--    plotValues : set of numbers to calculate plot scale for [Table]
function calculatePlotScale(plotValues)
    local min = math.min(table.unpack(plotValues))
    local max = math.max(table.unpack(plotValues))
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
--    minScale      : minimum scale of the plot [Int/Float]
--    maxScale      : maximum scale of the plot [Int/Float]
function plotSVMotion(noteDistances, minScale, maxScale)
    imgui.PlotLines("##notepath", noteDistances, #noteDistances, 0, "", minScale, maxScale,
                    {ACTION_BUTTON_SIZE[1], 100})
end
function calculateMinValue(values) return math.min(table.unpack(values)) end
function calculateMaxValue(values) return math.max(table.unpack(values)) end
function calculateAverage(values, includeLastValue)
    if #values == 0 then return nil end
    local sum = 0
    for i, value in pairs(values) do
        sum = sum + value
    end
    if not includeLastValue then
        sum = sum - values[#values]
        return sum / (#values - 1)
    end
    return sum / #values
end
-- Creates a bar graph/plot of SVs
-- Parameters
--    svVals   : list of numerical SV values [Table]    
--    minScale : minimum scale of the plot [Int/Float]
--    maxScale : maximum scale of the plot [Int/Float]
function plotSVs(svVals, minScale, maxScale)
    imgui.PlotHistogram("##svplot", svVals, #svVals, 0, "", minScale, maxScale, 
                        {ACTION_BUTTON_SIZE[1], 100})
end
-------------------------------------------------------------------------------------- Abstractions

-- Creates a button
-- Parameters
--    text       : text on the button [String]
--    size       : dimensions of the button [Table: {width, height}]
--    func       : function to execute once button is pressed [Function]
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function button(text, size, func, globalVars, menuVars)
    if not imgui.Button(text, size) then return end
    if menuVars then func(globalVars, menuVars) return end
    if globalVars then func(globalVars) return end
    func()
end
-- Executes a function if a key is pressed
-- Parameters
--    key        : key to be pressed [keys.~, from Quaver's MonoGame.Framework.Input.Keys enum]
--    func       : function to execute once key is pressed [Function]
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function ifKeyPressedThenExecute(key, func, globalVars, menuVars)
    if not utils.IsKeyPressed(key) then return end
    if menuVars then func(globalVars, menuVars) return end
    if globalVars then func(globalVars) return end
    func()
end
-- Creates a simple action menu that does simple SV things
-- Parameters
--    actionName : type of action to do on SVs once button is pressed [String]
--    actionfunc : function to execute once button is pressed [Function]
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function simpleActionMenu(actionName, actionfunc, globalVars, menuVars)
    local minimumNotes = 2
    local actionThing = "between"
    if actionName == "Displace note" then 
        minimumNotes = 1
        actionThing = "for"
    end
    chooseStartEndOffsets(globalVars)
    local enoughSelectedNotes = #state.SelectedHitObjects < minimumNotes
    local needToSelectNotes = (not globalVars.useManualOffsets) and enoughSelectedNotes
    if needToSelectNotes then imgui.Text("Select "..minimumNotes.." or more notes") return end
    
    local text = actionName.." SVs "..actionThing.." selected notes"
    if globalVars.useManualOffsets then text = actionName.." SVs between offsets" end
    button(text, ACTION_BUTTON_SIZE, actionfunc, globalVars, menuVars)
    toolTip("You can also press 'T' on your keyboard to do the same thing as this button")
    ifKeyPressedThenExecute(keys.T, actionfunc, globalVars, menuVars)
end
-- Edits SVs given a function that edits SVs
-- Parameters
--    globalVars  : list of variables used globally across all menus [Table]
--    menuVars    : list of variables used for the current menu [Table]
--    func        : function to edit SVs with that returns SVs to remove and add [Function]
--    needOffsets : whether or not the first and last offset is needed for the function [Boolean]
function editSVs(globalVars, menuVars, func, needOffsets)
    local offsets = getSelectedOffsets(globalVars)
    local svsToRemove = {}
    local svsToAdd = {}
    local targetOffsets
    local sectionType = SECTIONS[menuVars.sectionIndex]
    if menuVars and sectionType == "Per note section" then -- SV per note
        targetOffsets = offsets
    else 
        targetOffsets = {offsets[1], offsets[#offsets]}
    end
    for i = 1, #targetOffsets - 1 do
        local startOffset = targetOffsets[i]
        local endOffset = targetOffsets[i + 1]
        local svsBetweenOffsets = getSVsBetweenOffsets(startOffset, endOffset)
        local newSVsToRemove, newSVsToAdd
        if #svsBetweenOffsets > 0 then
            if menuVars then
                if needOffsets then
                    newSVsToRemove, newSVsToAdd = func(menuVars, svsBetweenOffsets, startOffset,
                                                       endOffset)
                else
                    newSVsToRemove, newSVsToAdd = func(menuVars, svsBetweenOffsets)
                end
            else
                if needOffsets then
                    newSVsToRemove, newSVsToAdd = func(svsBetweenOffsets, startOffset, endOffset)
                else
                    newSVsToRemove, newSVsToAdd = func(svsBetweenOffsets)
                end
            end
            for _, sv in ipairs(newSVsToRemove) do 
                table.insert(svsToRemove, sv)
            end
            for _, sv in ipairs(newSVsToAdd) do 
                table.insert(svsToAdd, sv)
            end
        end
    end
    if #svsToAdd > 0 then
        local editorActions = {
            utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToRemove),
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svsToAdd)
        }
        actions.PerformBatch(editorActions)
    end
end

---------------------------------------------------------------------------------------------------
-- Choose Functions (Sorted Alphabetically) -------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Lets you choose the average SV
-- Returns whether or not the average SV changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseAverageSV(menuVars)
    local oldAvg = menuVars.avgSV
    _, menuVars.avgSV = imgui.InputFloat("Average SV ", menuVars.avgSV, 0, 0, "%.2fx")
    return oldAvg ~= menuVars.avgSV
end
function chooseBezierPoints(settingVars)
    local oldFirstPoint = {settingVars.x1, settingVars.y1}
    local oldSecondPoint = {settingVars.x2, settingVars.y2}
    local _, newFirstPoint = imgui.DragFloat2("(x1, y1)", oldFirstPoint, 0.01, -1, 2, "%.2f")
    helpMarker("Coordinates of the first point of the cubic bezier")
    local _, newSecondPoint = imgui.DragFloat2("(x2, y2)", oldSecondPoint, 0.01, -1, 2, "%.2f")
    helpMarker("Coordinates of the second point of the cubic bezier")
    settingVars.x1, settingVars.y1 = table.unpack(newFirstPoint)
    settingVars.x2, settingVars.y2 = table.unpack(newSecondPoint)
    settingVars.x1 = clampToInterval(settingVars.x1, 0, 1)
    settingVars.y1 = clampToInterval(settingVars.y1, -1, 2)
    settingVars.x2 = clampToInterval(settingVars.x2, 0, 1)
    settingVars.y2 = clampToInterval(settingVars.y2, -1, 2)
    local firstXChanged = (oldFirstPoint[1] ~= settingVars.x1) 
    local firstYChanged = (oldFirstPoint[2] ~= settingVars.y1)
    local secondXChanged = (oldSecondPoint[1] ~= settingVars.x2)
    local secondYChanged = (oldSecondPoint[2] ~= settingVars.y2)
    local firstPointChanged = firstXChanged or firstYChanged
    local secondPointChanged = secondXChanged or secondYChanged
    return firstPointChanged or secondPointChanged
end
-- Lets users choose a constant amount to shift SVs
-- Returns whether or not the shift amount changed [Boolean]
-- Parameters
function chooseConstantShift(settingVars)
    local oldShift = settingVars.verticalShift
    if imgui.Button("Reset##verticalShift", {DEFAULT_WIDGET_WIDTH * 0.3, DEFAULT_WIDGET_HEIGHT - 2}) then
        settingVars.verticalShift = 1
    end
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.7 - SAMELINE_SPACING)
    _, settingVars.verticalShift = imgui.InputFloat("Vertical Shift", settingVars.verticalShift, 0, 0,
                                                 "%.2fx")
    settingVars.verticalShift = clampToInterval(settingVars.verticalShift, -10, 10)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    return oldShift ~= settingVars.verticalShift
end
-- Lets users choose SV curve sharpness
-- Returns whether or not the curve sharpness changed [Boolean]
-- Parameters
function chooseCurveSharpness(settingVars)
    local oldSharpness = settingVars.curveSharpness
    if imgui.Button("Reset##curveSharpness", {DEFAULT_WIDGET_WIDTH * 0.3, DEFAULT_WIDGET_HEIGHT - 2}) then
        settingVars.curveSharpness = 50
    end
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.7 - SAMELINE_SPACING)
    _, settingVars.curveSharpness = imgui.DragInt("Curve Sharpness", settingVars.curveSharpness, 1, 1, 100, "%d%%")
    settingVars.curveSharpness = clampToInterval(settingVars.curveSharpness, 1, 100)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    return oldSharpness ~= settingVars.curveSharpness
end
-- Lets you choose the displace type
-- Returns whether or not the displace type changed [Boolean]
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function chooseDisplaceType(globalVars, menuVars)
    local comboIndex = menuVars.displaceTypeIndex - 1
    _, comboIndex = imgui.Combo("Displace Type", comboIndex, DISPLACE_TYPES, #DISPLACE_TYPES)
    menuVars.displaceTypeIndex = comboIndex + 1
end
-- Lets you choose a distance
-- Returns whether or not the distance changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseDistance(menuVars)
    local oldDistance = menuVars.distance
    _, menuVars.distance = imgui.InputFloat("Distance", menuVars.distance, 0, 0, "%.3f msx")
    return oldDistance == menuVars.distance
end
-- Lets you choose which edit tool to use
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseEditTool(globalVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Current Tool:")
    imgui.SameLine(0, SAMELINE_SPACING)
    local comboIndex =  globalVars.editToolIndex - 1
    _, comboIndex = imgui.Combo("##edittool", comboIndex, EDIT_SV_TOOLS, #EDIT_SV_TOOLS)
    globalVars.editToolIndex = comboIndex + 1
    local currentTool = EDIT_SV_TOOLS[globalVars.editToolIndex]
    if currentTool == "Copy & Paste"  then toolTip("Copy SVs and paste them somewhere else") end
    if currentTool == "Displace Note" then toolTip("Move where notes are hit on the screen") end
    if currentTool == "Displace View" then toolTip("Temporarily displace the playfield view") end
    if currentTool == "Measure"       then toolTip("Get info/stats about SVs in a section") end
    if currentTool == "Merge"         then toolTip("Combine SVs that overlap") end
    if currentTool == "Scale"         then toolTip("Scale SV values to change note spacing") end
    --if currentTool == "Vibe"          then toolTip("Make notes appear in two places at once") end
end
function chooseExponentialBehavior(settingVars)
    local oldBehaviorIndex = settingVars.behaviorIndex
    local comboIndex = settingVars.behaviorIndex - 1
    _, comboIndex = imgui.Combo("Behavior", comboIndex, BEHAVIORS, #BEHAVIORS)
    settingVars.behaviorIndex = comboIndex + 1
    return oldBehaviorIndex ~= settingVars.behaviorIndex
end
-- Lets you choose the final SV to place at the end of SV sets
-- Returns whether or not the final SV type/value changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function chooseFinalSV(settingVars)
    local oldIndex = settingVars.finalSVIndex
    local oldCustomSV = settingVars.customSV
    local finalSVType = FINAL_SV_TYPES[settingVars.finalSVIndex]
    if finalSVType == "Custom" then
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.35)
        _, settingVars.customSV = imgui.InputFloat("SV", settingVars.customSV, 0, 0, "%.2fx")
        imgui.SameLine(0, SAMELINE_SPACING)
    else
        imgui.Indent(DEFAULT_WIDGET_WIDTH * 0.35 + 24)
    end
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.5)
    local comboIndex = oldIndex - 1
    _, comboIndex = imgui.Combo("Final SV", comboIndex, FINAL_SV_TYPES, #FINAL_SV_TYPES)
    if finalSVType ~= "Custom" then
        imgui.Unindent(DEFAULT_WIDGET_WIDTH * 0.35 + 24)
    end
    settingVars.finalSVIndex = comboIndex + 1
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    return (oldIndex ~= settingVars.finalSVIndex) or (oldCustomSV ~= settingVars.customSV)
end
-- Lets users choose the intensity of something from 1 to 100
-- Returns whether or not the intensity changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function chooseIntensity(settingVars)
    local oldIntensity = settingVars.intensity
    _, settingVars.intensity = imgui.SliderInt("Intensity", oldIntensity, 1, 100, oldIntensity.."%%")
    settingVars.intensity = clampToInterval(settingVars.intensity, 1, 100)
    return oldIntensity ~= settingVars.intensity
end
-- Lets users choose the number of periods (for a sinusoidal wave)
-- Returns whether or not the number of periods changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function chooseNumPeriods(settingVars)
    addSeparator()
    local oldPeriods = settingVars.periods
    _, settingVars.periods = imgui.InputFloat("Periods/Cycles", settingVars.periods, 0.25, 0.25, "%.2f")
    settingVars.periods = forceQuarter(settingVars.periods)
    settingVars.periods = clampToInterval(settingVars.periods, 0.25, 20)
    return oldPeriods ~= settingVars.periods
end
-- Forces a number to be a multiple of one quarter (0.25)
-- Returns the result of the force [Int/Float]
-- Parameters
--    x : number to force to be a multiple of one quarter [Int/Float]
function forceQuarter(x)
    return (math.floor(x * 4 + 0.5)) / 4
end
-- Lets users choose the number of periods to shift over (for a sinusoidal wave)
-- Returns whether or not the period shift value changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function choosePeriodShift(settingVars)
    local oldPeriodsShift = settingVars.periodsShift
    _, settingVars.periodsShift = imgui.InputFloat("Phase Shift", settingVars.periodsShift, 0.25, 0.25,
                                                "%.2f")
    settingVars.periodsShift = forceQuarter(settingVars.periodsShift)
    settingVars.periodsShift = clampToInterval(settingVars.periodsShift, -0.75, 0.75)
    return oldPeriodsShift ~= settingVars.periodsShift
end
-- Lets you choose the 'place SV' type
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function choosePlaceSVType(globalVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Type:")
    imgui.SameLine(0, SAMELINE_SPACING)
    local comboIndex = globalVars.placeTypeIndex - 1
    _, comboIndex = imgui.Combo("##placetype", comboIndex, PLACE_TYPE, #PLACE_TYPE)
    globalVars.placeTypeIndex = comboIndex + 1
end
-- Lets users choose the variability of randomness
-- Returns whether or not the variability value changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function chooseRandomScale(settingVars)
    local oldScale = settingVars.randomScale
     _, settingVars.randomScale = imgui.InputFloat("Random Scale", settingVars.randomScale, 0, 0, 
                                                "%.2fx")
    return oldScale ~= settingVars.randomScale
end
-- Lets users choose the type of random generation
-- Returns whether or not the type of random generation changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function chooseRandomType(settingVars)
    local oldIndex = settingVars.randomTypeIndex
    local comboIndex = oldIndex - 1
    _, comboIndex = imgui.Combo("Distribution Type", comboIndex, RANDOM_DISTRIBUTION_TYPE, #RANDOM_DISTRIBUTION_TYPE)
    settingVars.randomTypeIndex = comboIndex + 1
    return oldIndex ~= settingVars.randomTypeIndex
end
-- Lets you choose the ratio
-- Returns whether or not the ratio changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseRatio(menuVars)
    local oldRatio = menuVars.ratio 
    _, menuVars.ratio = imgui.InputFloat("Ratio", menuVars.ratio, 0, 0, "%.2f")
    return oldRatio == menuVars.ratio 
end
-- Lets you choose whether or not go RGB gamer mode (i.e. make plugin constantly rainbow colored)
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseRGBMode(globalVars)
    _, globalVars.rgb = imgui.Checkbox("RGB gamer mode", globalVars.rgb)
    toolTip("Make the plugin dynamically colorful and cool")
end
-- Lets you choose which section(s) to target SV actions at
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function chooseSection(globalVars, menuVars)
    if globalVars.useManualOffsets or menuVars.scaleTypeIndex == 3 then return end --Relative Ratio
    local comboIndex = menuVars.sectionIndex - 1
    _, comboIndex = imgui.Combo("Target Section", comboIndex, SECTIONS, #SECTIONS)
    menuVars.sectionIndex = comboIndex + 1
end
-- Lets you choose the special SV type
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseSpecialSVType(menuVars)
    local comboIndex = menuVars.svTypeIndex - 1
    local emoticonIndex = menuVars.svTypeIndex + #STANDARD_SV
    local emoticon = EMOTICONS[emoticonIndex]
    imgui.Indent(34)
    _, comboIndex = imgui.Combo("  "..emoticon.." ", comboIndex, SPECIAL_SV, #SPECIAL_SV)
    imgui.Unindent(34)
    menuVars.svTypeIndex = comboIndex + 1
    addSeparator()
end
-- Lets you choose the standard SV type
-- Returns whether or not the SV type changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseStandardSVType(menuVars)
    local oldcomboIndex = menuVars.svTypeIndex - 1
    local newComboIndex = oldcomboIndex
    local emoticonIndex = menuVars.svTypeIndex
    local emoticon = EMOTICONS[emoticonIndex]
    imgui.Indent(34)
    _, newComboIndex = imgui.Combo("  "..emoticon, newComboIndex, STANDARD_SV, #STANDARD_SV)
    imgui.Unindent(34)
    menuVars.svTypeIndex = newComboIndex + 1
    addSeparator()
    return oldcomboIndex ~= newComboIndex
end
-- Lets you choose start and end offsets
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseStartEndOffsets(globalVars)
    if not globalVars.useManualOffsets then return end
    
    local currentButtonSize = {DEFAULT_WIDGET_WIDTH * 0.4, DEFAULT_WIDGET_HEIGHT - 2}
    
    if imgui.Button("Current##startOffset", currentButtonSize) then
        globalVars.startOffset = state.SongTime
    end
    toolTip("Set the start offset to the current song time")
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.75)
    _, globalVars.startOffset = imgui.InputInt("Start", globalVars.startOffset)
    helpMarker("Start offset/time in milliseconds")
    
    if imgui.Button("Current##endOffset", currentButtonSize) then
        globalVars.endOffset = state.SongTime
    end
    toolTip("Set the end offset to the current song time")
    imgui.SameLine(0, SAMELINE_SPACING)
    _, globalVars.endOffset = imgui.InputInt("End", globalVars.endOffset)
    helpMarker("End offset/time in milliseconds")
    addSeparator()
end
function chooseStartEndSVs(settingVars)
    local oldValues = {settingVars.startSV, settingVars.endSV}
    local _, newValues = imgui.InputFloat2("Start/End SV", oldValues, "%.2fx")
    settingVars.startSV = newValues[1]
    settingVars.endSV = newValues[2]
    return oldValues[1] ~= newValues[1] or oldValues[2] ~= newValues[2]
end
-- Lets users choose the number of SV points per quarter period (for sinusoidal wave)
-- Returns whether or not the number of SVs changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function chooseSVPerQuarterPeriod(settingVars)
    addPadding()
    imgui.Text("For every 0.25 period/cycle, place...")
    local oldPerQuarterPeriod = settingVars.svsPerQuarterPeriod
    _, settingVars.svsPerQuarterPeriod = imgui.InputInt("SV points", settingVars.svsPerQuarterPeriod)
    settingVars.svsPerQuarterPeriod = clampToInterval(settingVars.svsPerQuarterPeriod, 1, MAX_SV_POINTS / (4 * settingVars.periods))
    return oldPerQuarterPeriod ~= settingVars.svsPerQuarterPeriod
end
function chooseSVPoints(settingVars)
    local oldSVPoints = settingVars.svPoints
    _, settingVars.svPoints = imgui.InputInt("SV points", oldSVPoints, 1, 1)
    settingVars.svPoints = clampToInterval(settingVars.svPoints, 1, MAX_SV_POINTS)
    return oldSVPoints ~= settingVars.svPoints
end
-- Lets you choose how to scale SVs
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseSVScale(menuVars)
    local comboIndex =  menuVars.scaleTypeIndex - 1
    _, comboIndex = imgui.Combo("Scale Type", comboIndex, SCALE_TYPES, #SCALE_TYPES)
    menuVars.scaleTypeIndex = comboIndex + 1
    local scaleType = SCALE_TYPES[menuVars.scaleTypeIndex]
    if scaleType == "Average SV"        then chooseAverageSV(menuVars) end
    if scaleType == "Absolute Distance" then chooseDistance(menuVars) end
    if scaleType == "Relative Ratio"    then chooseRatio(menuVars) end
end
-- Lets you choose how to select offset times (notes or manual offsets)
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseSVSelection(globalVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Do SV stuff by using:")
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Notes", not globalVars.useManualOffsets) then
        globalVars.useManualOffsets = false
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Offsets", globalVars.useManualOffsets) then
        globalVars.useManualOffsets = true
    end
end
--[[
-- Lets you choose the teleport distance for teleport SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseTeleportDistance(globalVars)
    local tpDist = globalVars.teleportDistance
    _, tpDist = imgui.InputFloat("Teleport distance", tpDist, 0, 0, "%.3f msx")
    globalVars.teleportDistance = tpDist
end
--]]
---------------------------------------------------------------------------------------------------
-- Doing SV Stuff ---------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------ Generating SVs

function generateSVMultipliers(svType, settingVars)
    local multipliers = {727, 69}
    if svType == "Linear" then
        multipliers = generateLinearSet(settingVars.startSV, settingVars.endSV, settingVars.svPoints + 1)
    end
    if svType == "Exponential" then
        local behavior = BEHAVIORS[settingVars.behaviorIndex]
        multipliers = generateExponentialSet(behavior, settingVars.svPoints + 1, settingVars.avgSV, settingVars.intensity)
    end
    if svType == "Bezier" then
        multipliers = generateBezierSet(settingVars.x1, settingVars.y1, settingVars.x2, settingVars.y2, settingVars.avgSV, settingVars.svPoints + 1)
    end
    if svType == "Sinusoidal" then
         multipliers = generateSinusoidalSet(settingVars.startSV, settingVars.endSV, settingVars.periods, settingVars.periodsShift, settingVars.svsPerQuarterPeriod, settingVars.verticalShift, settingVars.curveSharpness)
    end
    if svType == "Random" then
        local randomType = RANDOM_DISTRIBUTION_TYPE[settingVars.randomTypeIndex]
        multipliers = generateRandomSet(settingVars.avgSV, settingVars.svPoints + 1, randomType, settingVars.randomScale)
    end
    if svType == "Custom" then
        multipliers = {}
        for i, multiplier in pairs(settingVars.svMultipliers) do
            table.insert(multipliers, multiplier)
        end
        local averageMultiplier = calculateAverage(multipliers, true)
        table.insert(multipliers, averageMultiplier)
    end
    return multipliers
end

-- Generates a single set of linear valuses
-- Returns the set of linear values [Table]
-- Parameters
--    startVal  : starting value of the linear set [Int/Float]
--    endVal    : ending value of the linear set [Int/Float]
--    numValues : total number of values in the linear set [Int]
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
-- Generates a single set of exponential values
-- Returns the set of exponential values [Table]
-- Parameters
--    behavior : 
--    numValues           : total number of values in the exponential set [Int]
--    avgValue            : average value of the set [Int/Float]
--    intensity           : value determining sharpness/rapidness of exponential change [Int/Float]
--    interlace           : whether or not to interlace another exponential set between [Boolean]
--    interlaceMultiplier : multiplier of interlaced values relative to usual values [Int/Float]
function generateExponentialSet(behavior, numValues, avgValue, intensity)
    local exponentialIncrease = (behavior == "Speed up")
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
    end
    normalizeValues(exponentialSet, avgValue, false)
    return exponentialSet
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
function generateBezierSet(x1, y1, x2, y2, avgValue, numValues)
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
    local amplitudes = generateLinearSet(startAmplitude, endAmplitude, totalSVs + 1)
    local normalizedSharpness
    if curveSharpness > 50 then
        normalizedSharpness = math.sqrt((curveSharpness - 50) * 2)
    else
        normalizedSharpness = (curveSharpness / 50) ^ 2
    end
    for i = 0, totalSVs do
        local angle = (math.pi / 2) * ((i / valuesPerQuarterPeriod) + quarterPeriodsShift)
        local velocity = amplitudes[i + 1] * (math.abs(math.sin(angle))^(normalizedSharpness))
        velocity = velocity * getSignOfNumber(math.sin(angle)) + verticalShift
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
-- Returns the sign of a number: +1 if the number is non-negative and -1 if negative [Int]
-- Parameters
--    x : number to get the sign of
function getSignOfNumber(x)
    if x >= 0 then return 1 end
    return -1
end
-- Normalizes a set of values to achieve a target average
-- Parameters
--    values                    : set of numbers [Table]
--    targetAverage             : average value that is aimed for [Int/Float]
--    includeLastValueInAverage : whether or not to include the last value in the average [Boolean]
function normalizeValues(values, targetAverage, includeLastValueInAverage)
    local valuesAverage = calculateAverage(values, includeLastValueInAverage)
    for i = 1, #values do
        values[i] = (values[i] * targetAverage) / valuesAverage
    end
end

------------------------------------------------------------------------------------- Acting on SVs

-- Places SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function placeSVs(globalVars, menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local numMultipliers = #menuVars.svMultipliers
    local offsets = getSelectedOffsets(globalVars)
    for i = 1, #offsets - 1 do
        startOffset = offsets[i]
        endOffset = offsets[i + 1]
        svOffsets = generateLinearSet(startOffset, endOffset, #menuVars.svDistances)
        for j = 1, #svOffsets - 1 do
            table.insert(svsToAdd, utils.CreateScrollVelocity(svOffsets[j], menuVars.svMultipliers[j]))
        end
    end
    local hasFinalSV = #menuVars.svDistances == numMultipliers
    if hasFinalSV then
        table.insert(svsToAdd, utils.CreateScrollVelocity(offsets[#offsets], menuVars.svMultipliers[numMultipliers]))
    end
    if #svsToAdd > 0 then
        local editorActions = {
            utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToRemove),
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svsToAdd)
        }
        actions.PerformBatch(editorActions)
    end
end
-- Deletes SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function deleteSVs(globalVars)
    local offsets = getSelectedOffsets(globalVars)
    local svsToRemove = getSVsBetweenOffsets(offsets[1], offsets[#offsets])
    if #svsToRemove > 0 then actions.RemoveScrollVelocityBatch(svsToRemove) end
end
-- Copies SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function copySVs(globalVars, menuVars)
    editSVs(globalVars, menuVars, getSVsToCopy, false)
end
-- Merges SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function mergeSVs(globalVars)
    editSVs(globalVars, nil, getSVsToMerge, false)
end
-- Measures SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function measureSVs(globalVars, menuVars)
    local startOffset
    local endOffset
    if globalVars.useManualOffsets then
        startOffset = globalVars.startOffset
        endOffset = globalVars.endOffset
    else
        local noteOffsets = uniqueSelectedNoteOffsets()
        startOffset = noteOffsets[1]
        endOffset = noteOffsets[#noteOffsets]
    end
    local svs = getSVsBetweenOffsets(startOffset, endOffset)
    
    if #svs == 0 or svs[1].StartTime ~= startOffset then
        local svMultiplierAtStartOffset = getSVMultiplierAt(startOffset)
        table.insert(svs, 1, utils.CreateScrollVelocity(startOffset, svMultiplierAtStartOffset))
    end
    menuVars.measuredDistance =  round(calculateDispacementFromSVs(svs, endOffset), 5)
    menuVars.measuredNSVDistance = endOffset - startOffset
end
-- Scales SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function scaleSVs(globalVars, menuVars)
    editSVs(globalVars, menuVars, getSVsToScale, true)
end
-- Adds SVs that displace how high the notes are hit on the screen
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function displaceNoteSVs(globalVars, menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local offsets
    if globalVars.useManualOffsets then
        offsets = uniqueNoteOffsets(globalVars.startOffset, globalVars.endOffset)
    else
        offsets = uniqueSelectedNoteOffsets()
    end
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local displaceAmount = menuVars.distance
    for i = 1, #offsets do
        local noteOffset = offsets[i]
        local offsetAbove4Min = isAboveFourMinutes(noteOffset)
        local multiplier = abc(offsetAbove4Min, 8, 64)
        local duration = abc(offsetAbove4Min, MIN_DURATION_FAR, MIN_DURATION)
        local timeBefore = noteOffset - duration
        local timeAt = noteOffset
        local timeAfter = noteOffset + duration
        svTimeIsAdded[timeBefore] = true
        svTimeIsAdded[timeAt] = true
        svTimeIsAdded[timeAfter] = true
        local svMultiplierBefore = getSVMultiplierAt(timeBefore)
        local svMultiplierAt = getSVMultiplierAt(timeAt)
        local svMultiplierAfter = getSVMultiplierAt(timeAfter)
        local newMultiplierBefore = displaceAmount * multiplier
        local newMultiplierAt = -displaceAmount * multiplier
        local newMultiplierAfter = svMultiplierAfter
        local displaceType = DISPLACE_TYPES[menuVars.displaceTypeIndex]
        if displaceType == "Relative Distance" then
            newMultiplierBefore = newMultiplierBefore + svMultiplierBefore
            newMultiplierAt = newMultiplierAt + svMultiplierAt
        end
        table.insert(svsToAdd, utils.CreateScrollVelocity(timeBefore, newMultiplierBefore))
        table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, newMultiplierAt))
        table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, newMultiplierAfter))
    end
    for i, sv in pairs(map.ScrollVelocities) do
        local svIsInRange = sv.StartTime > startOffset - 1 and sv.StartTime < endOffset + 1
        if svIsInRange then 
            local svRemovable = svTimeIsAdded[sv.StartTime]
            if svRemovable then table.insert(svsToRemove, sv) end
        end
    end
    if #svsToAdd > 0 then
        local editorActions = {
            utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToRemove),
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svsToAdd)
        }
        actions.PerformBatch(editorActions)
    end
end
-- Adds SVs that temporarily displace the playfield view
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function displaceViewSVs(globalVars, menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local offsets
    if globalVars.useManualOffsets then
        offsets = {globalVars.startOffset, globalVars.endOffset}
    else
        local selectedOffsets = uniqueSelectedNoteOffsets()
        offsets = uniqueNoteOffsets(selectedOffsets[1], selectedOffsets[#selectedOffsets])
    end
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local displaceAmount = menuVars.distance
    for i = 1, #offsets - 1 do
        local note1Offset = offsets[i]
        local note2Offset = offsets[i + 1]
        local offsetAbove4Min = isAboveFourMinutes(note2Offset)
        local multiplier = abc(offsetAbove4Min, 8, 64)
        local duration = abc(offsetAbove4Min, MIN_DURATION_FAR, MIN_DURATION)
        local time2Before = note2Offset - duration
        local time1At = note1Offset
        local time1After = note1Offset + duration
        svTimeIsAdded[time2Before] = true
        svTimeIsAdded[time1At] = true
        svTimeIsAdded[time1After] = true
        local svMultiplierBefore = getSVMultiplierAt(time2Before)
        local svMultiplierAt = getSVMultiplierAt(time1At)
        local svMultiplierAfter = getSVMultiplierAt(time1After)
        local newMultiplierBefore = -displaceAmount * multiplier
        local newMultiplierAt = displaceAmount * multiplier
        local newMultiplierAfter = svMultiplierAfter
        local displaceType = DISPLACE_TYPES[menuVars.displaceTypeIndex]
        if displaceType == "Relative Distance" then
            newMultiplierBefore = newMultiplierBefore + svMultiplierBefore
            newMultiplierAt = newMultiplierAt + svMultiplierAt
        end
        table.insert(svsToAdd, utils.CreateScrollVelocity(time2Before, newMultiplierBefore))
        table.insert(svsToAdd, utils.CreateScrollVelocity(time1At, newMultiplierAt))
        table.insert(svsToAdd, utils.CreateScrollVelocity(time1After, newMultiplierAfter))
    end
    local svExistsAtEndOffset = false
    for i, sv in pairs(map.ScrollVelocities) do
        local svIsInRange = sv.StartTime >= startOffset and sv.StartTime <= endOffset
        if svIsInRange then 
            svExistsAtEndOffset = svExistsAtEndOffset or (sv.StartTime == endOffset)
            local svRemovable = svTimeIsAdded[sv.StartTime]
            if svRemovable then table.insert(svsToRemove, sv) end
        end
    end
    if not svExistsAtEndOffset then
        table.insert(svsToAdd, utils.CreateScrollVelocity(endOffset, 1))
    end
    if #svsToAdd > 0 then
        local editorActions = {
            utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToRemove),
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svsToAdd)
        }
        actions.PerformBatch(editorActions)
    end
end
-- Pastes copied SVs
-- Parameters
--    svValues     : list containing copied SV info (1. multiplier, 2. relative offset) [Table]
--    pasteOffsets : offsets/times to paste copied SVs at [Table]
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
-- Gets SVs to merge
-- Returns SVs to remove and add for merging SVs [Table]
-- Parameters
--    svs : SVs to merge [Table]
function getSVsToMerge(svs)
    local merged = false
    local svsToAdd = {}
    local svValuesToAdd = {}
    local svTimeExists = {}
    for i, sv in pairs(svs) do
        if svTimeExists[sv.StartTime] then
            svValuesToAdd[sv.StartTime] = svValuesToAdd[sv.StartTime] + sv.Multiplier
            merged = true
        else
            svTimeExists[sv.StartTime] = true
            svValuesToAdd[sv.StartTime] = sv.Multiplier
        end
    end
    if not merged then return {}, {} end
    for svTime, svMultiplier in pairs(svValuesToAdd) do
        table.insert(svsToAdd, utils.CreateScrollVelocity(svTime, svMultiplier))
    end
    return svs, svsToAdd
end
-- Gets SVs multiplier at a specified offset in the map
-- Returns SVs to remove and add for scaling SVs [Table]
-- Parameters
--    menuVars    : list of variables used for the current menu [Table]
--    svs         : SVs to scale [Table]
--    startOffset : time to start scaling SVs from [Int]
--    endOffset   : time to stop scaling SVs at [Int]
function getSVsToScale(menuVars, svs, startOffset, endOffset)
    local svsToAdd = {}
    local svsToRemove = {}
    local scaleType = SCALE_TYPES[menuVars.scaleTypeIndex]
    local scalingFactor
    for i, sv in pairs(svs) do
        table.insert(svsToRemove, sv)
    end
    if svs[1].StartTime ~= startOffset then
        local multiplierAtStartOffset = getSVMultiplierAt(startOffset)
        table.insert(svs, 1, utils.CreateScrollVelocity(startOffset, multiplierAtStartOffset))
    end
    if scaleType == "Average SV" then
        local svAverage = calculateAvgSV(svs, endOffset)
        scalingFactor = menuVars.avgSV / svAverage
    end
    if scaleType == "Absolute Distance" then
        local distanceTraveled = calculateDispacementFromSVs(svs, endOffset)
        scalingFactor = menuVars.distance / distanceTraveled
    end
    if scaleType == "Relative Ratio" then
        scalingFactor = menuVars.ratio
    end
    for i, sv in pairs(svs) do
        local newSVMultiplier = sv.Multiplier * scalingFactor
        table.insert(svsToAdd, utils.CreateScrollVelocity(sv.StartTime, newSVMultiplier))
    end
    return svsToRemove, svsToAdd
end
-- Gets SVs to copy and copies them
-- Returns SVs to remove and add (none for copying) [Table]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
--    svs      : SVs to copy [Table]
function getSVsToCopy(menuVars, svs)
    menuVars.copiedSVs = {}
    local startOffset = svs[1].StartTime
    for _, sv in pairs(svs) do
        local relativeTime = sv.StartTime - startOffset 
        table.insert(menuVars.copiedSVs, {sv.Multiplier, relativeTime})
    end
    return {}, {}
end