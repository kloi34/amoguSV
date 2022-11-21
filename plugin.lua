-- amoguSV v5.0 (21 Nov 2022)
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

-- SV/Time restrictions
MAX_SV_POINTS = 1000               -- maximum number of SV points allowed
MIN_DURATION = 1/64                -- minimum millisecond duration allowed in general
MIN_DURATION_FAR = 1/8             -- minimum millisecond duration for teleports above ~4 minutes
MAX_DURATION = 1                   -- maximum millisecond duration for teleports

-- Menu-related
FINAL_SV_TYPES = {                 -- options for the last SV placed at the tail end of all SVs
    "Normal",
    "Skip",
    "Custom"   
}
TAB_MENUS = {
    "Info",
    "Place SVs",
    "Edit SVs",
    "Delete SVs"
}
SV_SHAPES = {                      -- list of the available tools for editing SVs
    "Linear",
    "Exponential",
    "Stutter",
    "Bezier",
    "Sinusoidal",
    "Random",
    "Custom",
}
GIMMICK_SV = {                     -- list of gimmick SV types
    "Single",
    "Upscroll",
    "Splitscroll",
    "Animate"
}
EDIT_SV_TOOLS = {                  -- list of tools for editing SVs
    "Copy & Paste",
    "Displace Note",
    "Displace View",
    "Merge",
    "Measure",
    "Scale"
--    "Vibe"
}
SCALE_TYPES = {                    -- list of ways to scale SV multipliers
    "Average SV",
    "Absolute Distance",
    "Relative Ratio"
}
DISPLACE_TYPES = {                 -- list of ways of how to scale/calculate distances
    "Absolute Distance",
    "Relative Distance"
}
SECTIONS = {                       -- list of ways to apply actions on sections
    "Per note section",
    "Whole section"
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
        rgb = false,
        red = 0,
        green = 1,
        blue = 1,
        editToolIndex = 1,
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
    if tabName == "Info" then infoTab(globalVars) end
    if tabName == "Place SVs" then placeSVTab(globalVars) end
    if tabName == "Edit SVs" then editSVTab(globalVars) end
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
    chooseSVselection(globalVars)
    addSeparator()
    chooseRGBMode(globalVars)
end
-- Creates the "Place SVs" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function placeSVTab(globalVars)
    imgui.Text("debuggy place")
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
    if toolName == "Merge"         then simpleActionMenu("Merge", mergeSVs, globalVars, nil) end
    if toolName == "Measure"       then measureSVMenu(globalVars) end
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
    simpleActionMenu("Displace Note", displaceNoteSVs, globalVars, menuVars)
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
    simpleActionMenu("Displace View", displaceViewSVs, globalVars, menuVars)
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
               "places), calculated based on the SVs")
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

---------------------------------------------------------------------------------------------- Math

-- Rounds a number to a given amount of decimal places
-- Returns the rounded number [Int/Float]
-- Parameters
--    x             : number to round [Int/Float]
--    decimalPlaces : number of decimal places to round the number to [Int]
function round(x, decimalPlaces)
    local multiplier = 10 ^ decimalPlaces
    return math.floor(x * multiplier + 0.5) / multiplier
end
-- Calculates the average SV over time for a given set of SVs
-- Returns the average SV [Int/Float]
-- Parameters
--    svs        : list of ordered svs to calculate average SV with [Table]
--    lastOffset : final time (milliseconds) to stop calculating at [Int]
function calculateAvgSV(svs, lastOffset)
    local totalDisplacement = calculateDispacementFromSVs(svs, lastOffset)
    local firstOffset = svs[1].StartTime
    local timeInterval = lastOffset - firstOffset
    local avgSV = totalDisplacement / timeInterval
    return avgSV
end
-- Calculates the total msx displacement over time for a given set of SVs
-- Returns the total displacement [Int/Float]
-- Parameters
--    svs        : list of ordered svs to calculate displacement with [Table]
--    lastOffset : final time (milliseconds) to stop calculating at [Int]
function calculateDispacementFromSVs(svs, lastOffset)
    local totalDisplacement = 0
    table.insert(svs, utils.CreateScrollVelocity(lastOffset, 0))
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
    if actionName == "Displace Note" then 
        minimumNotes = 1
        actionThing = "for"
    end
    chooseStartEndOffsets(globalVars)
    local needToSelectNotes = (not globalVars.useManualOffsets) and #state.SelectedHitObjects < minimumNotes
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
    if menuVars and menuVars.sectionIndex == 1 then -- SV per note
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
                    newSVsToRemove, newSVsToAdd = func(menuVars, svsBetweenOffsets, startOffset, endOffset)
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

function abc(a, b, c)
    if a then return b end
    return c
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
    return oldAvg == menuVars.avgSV
end
function chooseDisplaceType(globalVars, menuVars)
    --if globalVars.useManualOffsets then menuVars.displaceTypeIndex = 1 return end
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
    _, comboIndex = imgui.Combo(" ", comboIndex, EDIT_SV_TOOLS, #EDIT_SV_TOOLS)
    globalVars.editToolIndex = comboIndex + 1
    local currentTool = EDIT_SV_TOOLS[globalVars.editToolIndex]
    if currentTool == "Copy & Paste"  then toolTip("Copy SVs and paste them somewhere else") end
    if currentTool == "Displace Note" then toolTip("Move where notes are hit on the screen") end
    if currentTool == "Displace View" then toolTip("Temporarily displace the playfield view") end
    if currentTool == "Merge"         then toolTip("Combine SVs that overlap") end
    if currentTool == "Measure"       then toolTip("Get info/stats about SVs in a section") end
    if currentTool == "Scale"         then toolTip("Scale SV values to change note spacing") end
    --if currentTool == "Vibe"          then toolTip("Make notes appear in two places at once") end
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
    if globalVars.useManualOffsets or menuVars.scaleTypeIndex == 3 then return end
    local comboIndex = menuVars.sectionIndex - 1
    _, comboIndex = imgui.Combo("Target Section", comboIndex, SECTIONS, #SECTIONS)
    menuVars.sectionIndex = comboIndex + 1
end
-- Lets you choose start and end offsets
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseStartEndOffsets(globalVars)
    if not globalVars.useManualOffsets then return end
    addPadding()
    local currentButtonSize = {DEFAULT_WIDGET_WIDTH * 0.4, DEFAULT_WIDGET_HEIGHT}
    
    if imgui.Button("Current", currentButtonSize) then
        globalVars.startOffset = state.SongTime
    end
    toolTip("Set the start offset to the current song time")
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.75)
    _, globalVars.startOffset = imgui.InputInt("Start", globalVars.startOffset)
    helpMarker("Start offset/time in milliseconds")
    
    if imgui.Button(" Current ", currentButtonSize) then
        globalVars.endOffset = state.SongTime
    end
    toolTip("Set the end offset to the current song time")
    imgui.SameLine(0, SAMELINE_SPACING)
    _, globalVars.endOffset = imgui.InputInt("End", globalVars.endOffset)
    helpMarker("End offset/time in milliseconds")
    addSeparator()
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
function chooseSVselection(globalVars)
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

---------------------------------------------------------------------------------------------------
-- Doing SV Stuff ---------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Deletes SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function deleteSVs(globalVars)
    local offsets = getSelectedOffsets(globalVars)
    local svsToRemove = getSVsBetweenOffsets(offsets[1], offsets[#offsets])
    if #svsToRemove > 0 then actions.RemoveScrollVelocityBatch(svsToRemove) end
end

function copySVs(globalVars, menuVars)
    editSVs(globalVars, menuVars, getSVsToCopy, false)
end

function mergeSVs(globalVars)
    editSVs(globalVars, nil, getSVsToMerge, false)
end

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

function scaleSVs(globalVars, menuVars)
    editSVs(globalVars, menuVars, getSVsToScale, true)
end

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
        if menuVars.displaceTypeIndex == 2 then -- relative displacement
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
function displaceViewSVs(globalVars, menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local offsets
    if globalVars.useManualOffsets then
        offsets = {globalVars.startOffset, globalVars.endOffset}
    else
        local selectedNoteOffsets = uniqueSelectedNoteOffsets()
        offsets = uniqueNoteOffsets(selectedNoteOffsets[1], selectedNoteOffsets[#selectedNoteOffsets])
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
        if menuVars.displaceTypeIndex == 2 then -- relative displacement
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

function getSVsToScale(menuVars, svs, firstOffset, lastOffset)
    local svsToAdd = {}
    local svsToRemove = {}
    local scaleType = SCALE_TYPES[menuVars.scaleTypeIndex]
    local scalingFactor
    for i, sv in pairs(svs) do
        table.insert(svsToRemove, sv)
    end
    if svs[1].StartTime ~= firstOffset then
        local svMultiplierAtFirstOffset = getSVMultiplierAt(firstOffset)
        table.insert(svs, 1, utils.CreateScrollVelocity(firstOffset, svMultiplierAtFirstOffset))
    end
    if scaleType == "Average SV" then
        local svAverage = calculateAvgSV(svs, lastOffset)
        scalingFactor = menuVars.avgSV / svAverage
    end
    if scaleType == "Absolute Distance" then
        local distanceTraveled = calculateDispacementFromSVs(svs, lastOffset)
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

function getSVsToCopy(menuVars, svs)
    menuVars.copiedSVs = {}
    local startOffset = svs[1].StartTime
    for _, sv in pairs(svs) do
        local relativeTime = sv.StartTime - startOffset 
        table.insert(menuVars.copiedSVs, {sv.Multiplier, relativeTime})
    end
    return {}, {}
end

function getSVMultiplierAt(offset)
    local sv = map.GetScrollVelocityAt(offset) 
    if sv then return sv.Multiplier end
    return 1
end