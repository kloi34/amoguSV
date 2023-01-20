-- amoguSV v5.1 (20 Jan 2023)
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

--------------------------------------------------------------------------------------- IMGUI / GUI

DEFAULT_WIDGET_HEIGHT = 26         -- value determining the height of GUI widgets
DEFAULT_WIDGET_WIDTH = 160         -- value determining the width of GUI widgets
PADDING_WIDTH = 8                  -- value determining window and frame padding
RADIO_BUTTON_SPACING = 7.5         -- value determining spacing between radio buttons
SAMELINE_SPACING = 5               -- value determining spacing between GUI items on the same row
ACTION_BUTTON_SIZE = {             -- dimensions of the button that does important things
    1.6 * DEFAULT_WIDGET_WIDTH - 1,
    1.6 * DEFAULT_WIDGET_HEIGHT
}
SECONDARY_BUTTON_SIZE = {          -- dimensions of a button that does less important things
    0.3 * DEFAULT_WIDGET_WIDTH,
    DEFAULT_WIDGET_HEIGHT - 2
}

------------------------------------------------------------------------------ SV/Time restrictions

MAX_SV_POINTS = 1000               -- maximum number of SV points allowed

-------------------------------------------------------------------------------------- Menu related

COLOR_SCHEMES = {                  -- available color themes for the plugin
    "Classic",
    "Strawberry",
    "Glass",
    "Glass + RGB",
    "RGB Gamer Mode"
}
DISPLACE_TYPES = {                 -- ways to scale/calculate distances
    "Relative Distance",
    "Absolute Distance"
}
EDIT_SV_TOOLS = {                  -- tools for editing SVs
    "Add Teleport",
    "Copy & Paste",
    "Displace Note",
    "Displace View",
    "Flicker",
    "Measure",
    "Merge",
    "Scale"
}
EMOTICONS = {                      -- emoticons to visually clutter the plugin and confuse users
    "( - _ - )",
    "( e . e )",
    "( * o * )",
    "( ~ _ ~ )",
    "( w . w )",
    "( ^ w ^ )",
    "( o _ 0 )",
    "( > . < )",
    "( v . ^ )",
    "( ; _ ; )",
    "[mwm]"
}
FINAL_SV_TYPES = {                 -- options for the last SV placed at the tail end of all SVs
    "Normal",
    "Skip",
    "Custom"
}
FLICKER_TYPES = {                  -- types of flickers
    "Normal",
    "Delayed"
}
PLACE_BEHAVIORS = {                -- ways to place SVs
    "Replace old SVs",
    "Keep old SVs"
}
PLACE_TYPES = {                    -- general categories of SVs to place
    "Standard",
    "Special",
    "Still"
}
RANDOM_TYPES = {                   -- distribution types of random values
    "Normal",
    "Uniform"
}
SCALE_TYPES = {                    -- ways to scale SV multipliers
    "Average SV",
    "Absolute Distance",
    "Relative Ratio"
}
SECTIONS = {                       -- ways to apply SV actions on sections
    "Per note section",
    "Whole section"
}
SPECIAL_SVS = {                    -- tools for placing special SVs
    "Stutter",
    "Teleport Stutter",
    "Reverse Scroll",
    "Splitscroll",
    "Animate"
}
STANDARD_SVS = {                   -- tools for placing standard SVs
    "Linear",
    "Exponential",
    "Bezier",
    "Sinusoidal",
    "Random",
    "Custom"
}
STILL_TYPES = {                    -- types of still displacements
    "No",
    "Start",
    "End",
    "Auto"
}
STYLE_SCHEMES = {                  -- available style/appearance themes for the plugin
    "Rounded",
    "Boxed",
    "Rounded + Border",
    "Boxed + Border"
}
SV_BEHAVIORS = {                   -- behaviors of SVs
    "Slow down",
    "Speed up"
}
TAB_MENUS = {                      -- tab names for different SV menus
    "Info",
    "Place SVs",
    "Edit SVs",
    "Delete SVs"
}

---------------------------------------------------------------------------------------------------
-- Plugin Styles and Colors -----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Configures the plugin GUI appearance
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function setPluginAppearance(globalVars)
    local colorScheme = COLOR_SCHEMES[globalVars.colorSchemeIndex]
    local styleScheme = STYLE_SCHEMES[globalVars.styleSchemeIndex]
    
    setPluginAppearanceStyles(styleScheme)
    setPluginAppearanceColors(globalVars, colorScheme)
    
    local rgbColorScheme = colorScheme == "RGB Gamer Mode" or colorScheme == "Glass + RGB"
    if rgbColorScheme and (not globalVars.rgbPaused) then updateRGBColors(globalVars) end
end
-- Configures the plugin GUI styles
-- Parameters
--    styleScheme : name of the desired style scheme [String]
function setPluginAppearanceStyles(styleScheme)
    local boxed = styleScheme == "Boxed" or styleScheme == "Boxed + Border"
    local cornerRoundnessValue = 5 -- up to 12, 14 for WindowRounding and 16 for ChildRoundin
    if boxed then cornerRoundnessValue = 0 end
    
    local addBorder = styleScheme == "Rounded + Border" or styleScheme == "Boxed + Border"
    local borderSize = 0
    if addBorder then borderSize = 1 end

    imgui.PushStyleVar( imgui_style_var.FrameBorderSize,    borderSize           )
    imgui.PushStyleVar( imgui_style_var.WindowPadding,      { PADDING_WIDTH, 8 } )
    imgui.PushStyleVar( imgui_style_var.FramePadding,       { PADDING_WIDTH, 5 } )
    imgui.PushStyleVar( imgui_style_var.ItemSpacing,        { DEFAULT_WIDGET_HEIGHT / 2 - 1, 4 } )
    imgui.PushStyleVar( imgui_style_var.ItemInnerSpacing,   { SAMELINE_SPACING, 6 } )
    imgui.PushStyleVar( imgui_style_var.WindowRounding,     cornerRoundnessValue )
    imgui.PushStyleVar( imgui_style_var.ChildRounding,      cornerRoundnessValue )
    imgui.PushStyleVar( imgui_style_var.FrameRounding,      cornerRoundnessValue )
    imgui.PushStyleVar( imgui_style_var.GrabRounding,       cornerRoundnessValue )
    imgui.PushStyleVar( imgui_style_var.ScrollbarRounding,  cornerRoundnessValue )
    imgui.PushStyleVar( imgui_style_var.TabRounding,        cornerRoundnessValue )
    
    -- not working? TabBorderSize doesn't exist? But it's changable in the style editor demo?
    -- imgui.PushStyleVar( imgui_style_var.TabBorderSize,      borderSize           ) 
end
-- Configures the plugin GUI colors
-- Parameters
--    globalVars  : list of variables used globally across all menus [Table]
--    colorScheme : name of the desired color scheme [String]
function setPluginAppearanceColors(globalVars, colorScheme)
    if colorScheme == "Classic" then
        imgui.PushStyleColor( imgui_col.WindowBg,               { 0.00, 0.00, 0.00, 1.00 } )
        imgui.PushStyleColor( imgui_col.Border,                 { 0.81, 0.88, 1.00, 0.30 } )
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
        imgui.PushStyleColor( imgui_col.ScrollbarGrab,          { 0.31, 0.38, 0.50, 1.00 } )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   { 0.41, 0.48, 0.60, 1.00 } )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    { 0.51, 0.58, 0.70, 1.00 } )
    elseif colorScheme == "Strawberry" then
        imgui.PushStyleColor( imgui_col.WindowBg,               { 0.00, 0.00, 0.00, 1.00 } )
        imgui.PushStyleColor( imgui_col.Border,                 { 1.00, 0.81, 0.88, 0.30 } )
        imgui.PushStyleColor( imgui_col.FrameBg,                { 0.28, 0.14, 0.24, 1.00 } )
        imgui.PushStyleColor( imgui_col.FrameBgHovered,         { 0.38, 0.24, 0.34, 1.00 } )
        imgui.PushStyleColor( imgui_col.FrameBgActive,          { 0.43, 0.29, 0.39, 1.00 } )
        imgui.PushStyleColor( imgui_col.TitleBg,                { 0.65, 0.41, 0.48, 1.00 } )
        imgui.PushStyleColor( imgui_col.TitleBgActive,          { 0.75, 0.51, 0.58, 1.00 } )
        imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       { 0.75, 0.51, 0.58, 0.50 } )
        imgui.PushStyleColor( imgui_col.CheckMark,              { 1.00, 0.81, 0.88, 1.00 } )
        imgui.PushStyleColor( imgui_col.SliderGrab,             { 0.75, 0.56, 0.63, 1.00 } )
        imgui.PushStyleColor( imgui_col.SliderGrabActive,       { 0.80, 0.61, 0.68, 1.00 } )
        imgui.PushStyleColor( imgui_col.Button,                 { 0.50, 0.31, 0.38, 1.00 } )
        imgui.PushStyleColor( imgui_col.ButtonHovered,          { 0.60, 0.41, 0.48, 1.00 } )
        imgui.PushStyleColor( imgui_col.ButtonActive,           { 0.70, 0.51, 0.58, 1.00 } )
        imgui.PushStyleColor( imgui_col.Tab,                    { 0.50, 0.31, 0.38, 1.00 } )
        imgui.PushStyleColor( imgui_col.TabHovered,             { 0.75, 0.51, 0.58, 1.00 } )
        imgui.PushStyleColor( imgui_col.TabActive,              { 0.75, 0.51, 0.58, 1.00 } )
        imgui.PushStyleColor( imgui_col.Header,                 { 1.00, 0.81, 0.88, 0.40 } )
        imgui.PushStyleColor( imgui_col.HeaderHovered,          { 1.00, 0.81, 0.88, 0.50 } )
        imgui.PushStyleColor( imgui_col.HeaderActive,           { 1.00, 0.81, 0.88, 0.54 } )
        imgui.PushStyleColor( imgui_col.Separator,              { 1.00, 0.81, 0.88, 0.30 } )
        imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 1.00, 0.81, 0.88, 0.40 } )
        imgui.PushStyleColor( imgui_col.ScrollbarGrab,          { 0.50, 0.31, 0.38, 1.00 } )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   { 0.60, 0.41, 0.48, 1.00 } )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    { 0.70, 0.51, 0.58, 1.00 } )
    elseif colorScheme == "Glass" then
        local transparent = {0.00, 0.00, 0.00, 0.25}
        local transparentWhite = {1.00, 1.00, 1.00, 0.70}
        local whiteTint = {1.00, 1.00, 1.00, 0.30}
        
        imgui.PushStyleColor( imgui_col.WindowBg,               transparent      )
        imgui.PushStyleColor( imgui_col.Border,                 transparentWhite )
        imgui.PushStyleColor( imgui_col.FrameBg,                transparent      )
        imgui.PushStyleColor( imgui_col.FrameBgHovered,         whiteTint        )
        imgui.PushStyleColor( imgui_col.FrameBgActive,          whiteTint        )
        imgui.PushStyleColor( imgui_col.TitleBg,                transparent      )
        imgui.PushStyleColor( imgui_col.TitleBgActive,          transparent      )
        imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       transparent      )
        imgui.PushStyleColor( imgui_col.CheckMark,              transparentWhite )
        imgui.PushStyleColor( imgui_col.SliderGrab,             whiteTint        )
        imgui.PushStyleColor( imgui_col.SliderGrabActive,       transparentWhite )
        imgui.PushStyleColor( imgui_col.Button,                 transparent      )
        imgui.PushStyleColor( imgui_col.ButtonHovered,          whiteTint        )
        imgui.PushStyleColor( imgui_col.ButtonActive,           whiteTint        )
        imgui.PushStyleColor( imgui_col.Tab,                    transparent      )
        imgui.PushStyleColor( imgui_col.TabHovered,             whiteTint        )
        imgui.PushStyleColor( imgui_col.TabActive,              whiteTint        )
        imgui.PushStyleColor( imgui_col.Header,                 transparent      )
        imgui.PushStyleColor( imgui_col.HeaderHovered,          whiteTint        )
        imgui.PushStyleColor( imgui_col.HeaderActive,           whiteTint        )
        imgui.PushStyleColor( imgui_col.Separator,              whiteTint        )
        imgui.PushStyleColor( imgui_col.TextSelectedBg,         whiteTint        )
        imgui.PushStyleColor( imgui_col.ScrollbarGrab,          whiteTint        )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   transparentWhite )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    transparentWhite )
    elseif colorScheme == "Glass + RGB" then
        local transparent = {0.00, 0.00, 0.00, 0.25}
        local activeColor = {globalVars.red, globalVars.green, globalVars.blue, 0.8}
        local colorTint = {globalVars.red, globalVars.green, globalVars.blue, 0.3}
        
        imgui.PushStyleColor( imgui_col.WindowBg,               transparent )
        imgui.PushStyleColor( imgui_col.Border,                 activeColor )
        imgui.PushStyleColor( imgui_col.FrameBg,                transparent )
        imgui.PushStyleColor( imgui_col.FrameBgHovered,         colorTint   )
        imgui.PushStyleColor( imgui_col.FrameBgActive,          colorTint   )
        imgui.PushStyleColor( imgui_col.TitleBg,                transparent )
        imgui.PushStyleColor( imgui_col.TitleBgActive,          transparent )
        imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       transparent )
        imgui.PushStyleColor( imgui_col.CheckMark,              activeColor )
        imgui.PushStyleColor( imgui_col.SliderGrab,             colorTint   )
        imgui.PushStyleColor( imgui_col.SliderGrabActive,       activeColor )
        imgui.PushStyleColor( imgui_col.Button,                 transparent )
        imgui.PushStyleColor( imgui_col.ButtonHovered,          colorTint   )
        imgui.PushStyleColor( imgui_col.ButtonActive,           colorTint   )
        imgui.PushStyleColor( imgui_col.Tab,                    transparent )
        imgui.PushStyleColor( imgui_col.TabHovered,             colorTint   )
        imgui.PushStyleColor( imgui_col.TabActive,              colorTint   )
        imgui.PushStyleColor( imgui_col.Header,                 transparent )
        imgui.PushStyleColor( imgui_col.HeaderHovered,          colorTint   ) 
        imgui.PushStyleColor( imgui_col.HeaderActive,           colorTint   )
        imgui.PushStyleColor( imgui_col.Separator,              colorTint   )
        imgui.PushStyleColor( imgui_col.TextSelectedBg,         colorTint   )
        imgui.PushStyleColor( imgui_col.ScrollbarGrab,          colorTint   )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   activeColor )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    activeColor )
    elseif colorScheme == "RGB Gamer Mode" then
        local activeColor = {globalVars.red, globalVars.green, globalVars.blue, 0.8}
        local inactiveColor = {globalVars.red, globalVars.green, globalVars.blue, 0.5}
        local white = {1.00, 1.00, 1.00, 1.00}
        local clearWhite = {1.00, 1.00, 1.00, 0.40}
        local black = {0.00, 0.00, 0.00, 1.00}
        
        imgui.PushStyleColor( imgui_col.WindowBg,               black         )
        imgui.PushStyleColor( imgui_col.Border,                 inactiveColor )
        imgui.PushStyleColor( imgui_col.FrameBg,                inactiveColor )
        imgui.PushStyleColor( imgui_col.FrameBgHovered,         activeColor   )
        imgui.PushStyleColor( imgui_col.FrameBgActive,          activeColor   )
        imgui.PushStyleColor( imgui_col.TitleBg,                inactiveColor )
        imgui.PushStyleColor( imgui_col.TitleBgActive,          activeColor   )
        imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       inactiveColor )
        imgui.PushStyleColor( imgui_col.CheckMark,              white         )
        imgui.PushStyleColor( imgui_col.SliderGrab,             activeColor   )
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
        imgui.PushStyleColor( imgui_col.Separator,              inactiveColor )
        imgui.PushStyleColor( imgui_col.TextSelectedBg,         clearWhite    )
        imgui.PushStyleColor( imgui_col.ScrollbarGrab,          inactiveColor )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   activeColor   )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    activeColor   )
    end
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
    
    local increment = 0.0004
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
-- Creates a tooltip box when the last (most recently created) item is hovered over
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
        placeBehaviorIndex = 1,
        colorSchemeIndex = 1,
        styleSchemeIndex = 1,
        red = 0,
        green = 1,
        blue = 1,
        rgbPaused = false,
        editToolIndex = 1,
        placeTypeIndex = 1,
        debugText = "debuggy capybara"
    }
    getVariables("globalVars", globalVars)
    setPluginAppearance(globalVars)
    setWindowFocusIfHotkeysPressed()
    initializeNextWindowNotCollapsed("mainCollapsed")
    
    imgui.Begin("amoguSV", imgui_window_flags.AlwaysAutoResize)
    centerWindowIfHotkeysPressed()
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    imgui.BeginTabBar("SV tabs")
    for i = 1, #TAB_MENUS do
        createMenuTab(globalVars, TAB_MENUS[i])
    end
    imgui.EndTabBar()
    state.IsWindowHovered = imgui.IsWindowHovered()
    imgui.End()
    
    saveVariables("globalVars", globalVars)
end
-- Makes the main plugin window focused/active if Shift + Tab is pressed
function setWindowFocusIfHotkeysPressed()
    local shiftKeyPressedDown = utils.IsKeyDown(keys.LeftShift) or utils.IsKeyDown(keys.RightShift)
    local tabKeyPressed = utils.IsKeyPressed(keys.Tab)
    if shiftKeyPressedDown and tabKeyPressed then imgui.SetNextWindowFocus() end
end
-- Makes the next plugin window not collapsed on startup
-- Parameters
--    key : name of the next plugin window [String]
function initializeNextWindowNotCollapsed(key)
    if state.GetValue(key) then return end
    imgui.SetNextWindowCollapsed(false)
    state.SetValue(key, true)
end
-- Makes the plugin window centered if Ctrl + Shift + Tab is pressed
function centerWindowIfHotkeysPressed()
    local ctrlKeyPressedDown = utils.IsKeyDown(keys.LeftControl) or utils.IsKeyDown(keys.RightControl)
    local shiftKeyPressedDown = utils.IsKeyDown(keys.LeftShift) or utils.IsKeyDown(keys.RightShift)
    local tabKeyPressed = utils.IsKeyPressed(keys.Tab)
    if not (ctrlKeyPressedDown and shiftKeyPressedDown and tabKeyPressed) then return end
    
    local windowWidth, windowHeight = table.unpack(state.WindowSize)
    local pluginWidth, pluginHeight = table.unpack(imgui.GetWindowSize())
    local coordinatesToCenter = {(windowWidth - pluginWidth) / 2, (windowHeight - pluginHeight) / 2}
    imgui.SetWindowPos("amoguSV", coordinatesToCenter)
end

----------------------------------------------------------------------------------------- Tab stuff

-- Creates a menu tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    tabName    : name of the tab currently being created [String]
function createMenuTab(globalVars, tabName)
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
    showShortcuts()
    showInfoLinks()
    choosePluginSettings(globalVars)
end
-- Display shortcuts for the plugin
function showShortcuts()
    if not imgui.CollapsingHeader("Key Shortcuts") then return end
    local indentWidth = -6
    imgui.Indent(indentWidth)
    addPadding()
    imgui.BulletText("Ctrl + Shift + Tab = center plugin window")
    toolTip("Useful if the plugin begins or ends up offscreen")
    addSeparator()
    imgui.BulletText("Shift + Tab = focus plugin + navigate inputs")
    toolTip("Useful if you click off the plugin but want to quickly change an input value")
    addSeparator()
    imgui.BulletText("T = activate the big button doing SV stuff")
    toolTip("Use this everytime for quick workflow")
    addPadding()
    imgui.Unindent(indentWidth)
end
-- Display links relevant to the plugin
function showInfoLinks()
    if not imgui.CollapsingHeader("Links") then return end
    provideLink("Quaver SV Guide", "https://kloi34.github.io/QuaverSVGuide")
    provideLink("GitHub Repository", "https://github.com/kloi34/amoguSV")
end
-- Lets you choose global plugin settings
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function choosePluginSettings(globalVars)
    if not imgui.CollapsingHeader("Plugin Settings") then return end
    addPadding()
    chooseSVSelection(globalVars)
    addSeparator()
    choosePlaceBehavior(globalVars)
    addSeparator()
    chooseStyleScheme(globalVars)
    chooseColorScheme(globalVars)
    chooseRGBPause(globalVars)
    addSeparator()
    imgui.TextDisabled("How to permanently change default settings?")
    if not imgui.IsItemHovered() then return end
    imgui.BeginTooltip()
    imgui.BulletText("Open the plugin file (\"plugin.lua\") in a text editor or code editor")
    imgui.BulletText("Find the line with \"local globalVars = { \"")
    imgui.BulletText("Edit index values in globalVars that correspond to a plugin setting")
    imgui.BulletText("Save the file with changes and reload the plugin")
    imgui.Text("Example: change \"colorSchemeIndex = 1,\" to \"colorSchemeIndex = 2,\"")
    imgui.EndTooltip()
end
-- Creates the "Place SVs" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function placeSVTab(globalVars)
    choosePlaceSVType(globalVars)
    local placeType = PLACE_TYPES[globalVars.placeTypeIndex]
    if placeType == "Standard" then placeStandardSVMenu(globalVars) end
    if placeType == "Special"  then placeSpecialSVMenu(globalVars) end
    if placeType == "Still"    then placeStillSVMenu(globalVars) end
end
-- Creates the "Edit SVs" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function editSVTab(globalVars)
    chooseEditTool(globalVars)
    addSeparator()
    local toolName = EDIT_SV_TOOLS[globalVars.editToolIndex]
    if toolName == "Add Teleport"  then addTeleportMenu(globalVars) end
    if toolName == "Copy & Paste"  then copyNPasteMenu(globalVars) end
    if toolName == "Displace Note" then displaceNoteMenu(globalVars) end
    if toolName == "Displace View" then displaceViewMenu(globalVars) end
    if toolName == "Flicker"       then flickerMenu(globalVars) end
    if toolName == "Measure"       then measureSVMenu(globalVars) end
    if toolName == "Merge"         then simpleActionMenu("Merge", mergeSVs, globalVars, nil) end
    if toolName == "Scale"         then scaleSVMenu(globalVars) end
end
-- Creates the "Delete SVs" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function deleteSVTab(globalVars)
    simpleActionMenu("Delete", deleteSVs, globalVars, nil)
end

--------------------------------------------------------------------------------------------- Menus

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
    addSeparator()
    
    local currentSVType = STANDARD_SVS[menuVars.svTypeIndex]
    local settingVars = getSettingVars(currentSVType)
    local menuFunctionName = string.lower(currentSVType).."SettingsMenu"
    needSVUpdate = _G[menuFunctionName](settingVars) or needSVUpdate
    
    if needSVUpdate then updateMenuSVs(currentSVType, menuVars, settingVars) end
    
    initializeNextWindowNotCollapsed("infoCollapsed")
    makeSVInfoWindow("SV Info", menuVars.svStats, menuVars.svDistances, menuVars.svMultipliers, nil)
    addSeparator()
    simpleActionMenu("Place", placeSVs, globalVars, menuVars)
    saveVariables(currentSVType.."Settings", settingVars)
    saveVariables("placeStandardMenu", menuVars)
end
-- Creates the menu for linear SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this linear menu [Table]
function linearSettingsMenu(settingVars)
    local settingsChanged = false
    settingsChanged = chooseStartEndSVs(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for exponential SV settings
-- Parameters
--    settingVars : list of setting variables for this exponential menu [Table]
function exponentialSettingsMenu(settingVars)
    local settingsChanged = false
    settingsChanged = chooseExponentialBehavior(settingVars) or settingsChanged
    settingsChanged = chooseIntensity(settingVars) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for bezier SV settings
-- Parameters
--    settingVars : list of setting variables for this bezier menu [Table]
function bezierSettingsMenu(settingVars)
    local settingsChanged = false
    settingsChanged = provideBezierWebsiteLink(settingVars) or settingsChanged
    settingsChanged = chooseBezierPoints(settingVars) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for sinusoidal SV settings
-- Parameters
--    settingVars : list of setting variables for this sinusoidal menu [Table]
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
--    settingVars : list of setting variables for this random menu [Table]
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
--    settingVars : list of setting variables for this custom menu [Table]
function customSettingsMenu(settingVars)
    local settingsChanged = false
    settingsChanged = chooseCustomMultipliers(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    adjustNumberOfMultipliers(settingVars)
    return settingsChanged
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
    local currentSVType = SPECIAL_SVS[menuVars.svTypeIndex]
    if currentSVType == "Stutter"          then stutterMenu(globalVars) end
    if currentSVType == "Teleport Stutter" then telportStutterMenu(globalVars) end
    if currentSVType == "Reverse Scroll"   then reverseScrollMenu(globalVars) end
    if currentSVType == "Splitscroll"      then splitScrollMenu(globalVars) end
    if currentSVType == "Animate"          then imgui.Text("Coming Soon ?!?!") end
    saveVariables("placeSpecialMenu", menuVars)
end
-- Creates the menu for stutter SV
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function stutterMenu(globalVars)
    local menuVars = {
        startSV = 1.5,
        endSV = 0.5,
        stutterDuration = 50,
        stuttersPerSection = 1,
        avgSV = 1,
        finalSVIndex = 3,
        customSV = 1,
        linearlyChange = false,
        svMultipliers = {},
        svDistances = {},
        svStats = {
            minScale = 0,
            maxScale = 0,
            distMinScale = 0,
            distMaxScale = 0,
        },
        svMultipliers2 = {},
        svDistances2 = {},
        svStats2 = {
            minScale = 0,
            maxScale = 0,
            distMinScale = 0,
            distMaxScale = 0,
        }
    }
    getVariables("stutterMenu", menuVars)
    
    local settingsChanged = #menuVars.svMultipliers == 0
    imgui.Text("First SV:")
    settingsChanged = chooseStartEndSVs(menuVars) or settingsChanged
    settingsChanged = chooseStutterDuration(menuVars) or settingsChanged
    addSeparator()
    settingsChanged = chooseStuttersPerSection(menuVars) or settingsChanged
    settingsChanged = chooseAverageSV(menuVars) or settingsChanged
    settingsChanged = chooseFinalSV(menuVars) or settingsChanged
    settingsChanged = chooseLinearlyChange(menuVars) or settingsChanged
        
    if settingsChanged then updateStutterMenuSVs(menuVars) end
    
    local windowText = "SV Info"
    if menuVars.linearlyChange then
        initializeNextWindowNotCollapsed("info2Collapsed")
        windowText = windowText.." (Starting first SV)"
    else
        initializeNextWindowNotCollapsed("infoCollapsed")
    end
    makeSVInfoWindow(windowText, menuVars.svStats, menuVars.svDistances,
                     menuVars.svMultipliers, menuVars.stutterDuration)
    if menuVars.linearlyChange then
        initializeNextWindowNotCollapsed("info3Collapsed")
        makeSVInfoWindow("SV Info (Ending first SV)", menuVars.svStats2, menuVars.svDistances2,
                         menuVars.svMultipliers2, menuVars.stutterDuration)
    end
    
    addSeparator()
    simpleActionMenu("Place", placeStutterSVs, globalVars, menuVars)
    saveVariables("stutterMenu", menuVars)
end
-- Creates the menu for teleport stutter SV
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function telportStutterMenu(globalVars)
    local menuVars = {
        svPercent = 50,
        distance = 50,
        mainSV = 0.5,
        useDistance = false,
        avgSV = 1,
        finalSVIndex = 3,
        customSV = 1
    }
    getVariables("teleportStutterMenu", menuVars)
    if menuVars.useDistance then
        chooseDistance(menuVars)
        helpMarker("Start SV teleport distance")
    else
        chooseStartSVPercent(menuVars)
    end
    chooseMainSV(menuVars)
    chooseAverageSV(menuVars)
    chooseFinalSV(menuVars)
    chooseUseDistance(menuVars)
    addSeparator()
    simpleActionMenu("Place", placeTeleportStutterSVs, globalVars, menuVars)
    saveVariables("teleportStutterMenu", menuVars)
end
-- Creates the menu for reverse scroll SV
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function reverseScrollMenu(globalVars)
    local menuVars = {
        avgSV = -1,
        distance = 400
    }
    getVariables("reverseScrollMenu", menuVars)
    chooseAverageSV(menuVars)
    chooseDistance(menuVars)
    helpMarker("Height at which revesrse scroll notes are hit")
    addSeparator()
    simpleActionMenu("Place", placeReverseScrollSVs, globalVars, menuVars)
    saveVariables("reverseScrollMenu", menuVars)
end
-- Creates the menu for splitscroll SV
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function splitScrollMenu(globalVars)
    local menuVars = {
        scrollSpeed1 = 0.9,
        height1 = 0,
        scrollSpeed2 = -0.9,
        height2 = 400,
        msPerFrame = 16,
        distanceBack = 1000000,
        noteTimes2 = {}
    }
    getVariables("splitScrollMenu", menuVars)
    chooseFirstScrollSpeed(menuVars)
    chooseFirstHeight(menuVars)
    chooseSecondScrollSpeed(menuVars)
    chooseSecondHeight(menuVars)
    chooseMSPF(menuVars)
    addSeparator()
    local noNoteTimesInitially = #menuVars.noteTimes2 == 0
    imgui.Text(#menuVars.noteTimes2.." note times added for 2nd scroll")
    if imgui.Button("Add selected note times to 2nd scroll", ACTION_BUTTON_SIZE) then
        addSelectedNoteTimes(menuVars)
    end
    
    if (not noNoteTimesInitially) and imgui.Button("Clear all 2nd scroll note times", ACTION_BUTTON_SIZE) then
        menuVars.noteTimes2 = {}
    end
    saveVariables("splitScrollMenu", menuVars)
    if noNoteTimesInitially then return end
    
    addSeparator()
    simpleActionMenu("Place Splitscroll", placeSplitScrollSVs, globalVars, menuVars)
end
-- Creates the menu for placing still SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function placeStillSVMenu(globalVars)
    local menuVars = {
        svTypeIndex = 1,
        noteSpacing = 1,
        stillTypeIndex = 1,
        stillDistance = 200,
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
    getVariables("placeStillMenu", menuVars)
    local needSVUpdate =  #menuVars.svMultipliers == 0
    
    needSVUpdate = chooseStandardSVType(menuVars) or needSVUpdate
    addPadding()
    imgui.Text("Still Settings:")
    chooseNoteSpacing(menuVars)
    chooseStillType(menuVars)
    addSeparator()
    
    local currentSVType = STANDARD_SVS[menuVars.svTypeIndex]
    local settingVars = getSettingVars(currentSVType)
    local menuFunctionName = string.lower(currentSVType).."SettingsMenu"
    needSVUpdate = _G[menuFunctionName](settingVars) or needSVUpdate
    
    if needSVUpdate then updateMenuSVs(currentSVType, menuVars, settingVars) end
    
    initializeNextWindowNotCollapsed("infoCollapsed")
    makeSVInfoWindow("SV Info", menuVars.svStats, menuVars.svDistances, menuVars.svMultipliers, nil)
    addSeparator()
    simpleActionMenu("Place", placeSVs, globalVars, menuVars)
    saveVariables(currentSVType.."Settings", settingVars)
    saveVariables("placeStillMenu", menuVars)
end
-- Creates the add teleport menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function addTeleportMenu(globalVars)
    local menuVars = {
        distance = 10727
    }
    getVariables("addTeleportMenu", menuVars)
    chooseDistance(menuVars)
    addSeparator()
    simpleActionMenu("Add teleport", addTeleportSVs, globalVars, menuVars)
    saveVariables("addTeleportMenu", menuVars)
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
    if noSVsCopiedInitially then simpleActionMenu("Copy", copySVs, globalVars, menuVars) end
    
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
        distance = 200
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
        distance = 200
    }
    getVariables("displaceViewMenu", menuVars)
    chooseDisplaceType(globalVars, menuVars)
    chooseDistance(menuVars)
    addSeparator()
    simpleActionMenu("Displace view", displaceViewSVs, globalVars, menuVars)
    saveVariables("displaceViewMenu", menuVars)
end
-- Creates the flicker menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function flickerMenu(globalVars)
    local menuVars = {
        flickerTypeIndex = 1,
        distance = -69420.727,
        numFlickers = 2
    }
    getVariables("flickerMenu", menuVars)
    chooseFlickerType(menuVars)
    helpMarker("Use \"Displace View\" + large negative distance for manual flickers")
    chooseDistance(menuVars)
    chooseNumFlickers(menuVars)
    addSeparator()
    simpleActionMenu("Add flicker", flickerSVs, globalVars, menuVars)
    saveVariables("flickerMenu", menuVars)
end
-- Creates the measure menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function measureSVMenu(globalVars)
    local menuVars = {
        measuredNSVDistance = 0,
        measuredDistance = 0,
        avgSV = 0
    }
    getVariables("measureMenu", menuVars)
    displayMeasuredStats(menuVars)
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

-------------------------------------------------------------------------------------- Menu related

-- Adjusts the number of SV multipliers available for the custom SV menu
-- Parameters
--    settingVars : list of variables used for the custom SV menu [Table]
function adjustNumberOfMultipliers(settingVars)
    if settingVars.svPoints > #settingVars.svMultipliers then
        local difference = settingVars.svPoints - #settingVars.svMultipliers
        for i = 1, difference do
            table.insert(settingVars.svMultipliers, 1)
        end
    end
    if settingVars.svPoints < #settingVars.svMultipliers then
        if settingVars.selectedMultiplierIndex > settingVars.svPoints then
            settingVars.selectedMultiplierIndex = settingVars.svPoints
        end
        local difference = #settingVars.svMultipliers - settingVars.svPoints
        for i = 1, difference do
            table.remove(settingVars.svMultipliers)
        end
    end
end
-- Displays stats of measured SV
-- Parameters
--    menuVars : list of variables used for the measure SV menu [Table]
function displayMeasuredStats(menuVars)
    imgui.Text("NSV Distance: "..menuVars.measuredNSVDistance.." msx")
    helpMarker("This is the normal distance between the start and the end, ignoring SVs")
    imgui.Text("SV Distance: "..menuVars.measuredDistance.." msx")
    helpMarker("This is the actual distance between the start and the end (rounded to 5 decimal "..
               "places), calculated with SVs")
    imgui.Text("Average SV: "..menuVars.avgSV.."x")
    helpMarker("(rounded to 5 decimal places)")
end
-- Displays stats for stutter SVs
-- Parameters
--    svMultipliers   : stutter multipliers [Table]
--    stutterDuration : duration of the stutter (out of 100) [Int]
function displayStutterSVStats(svMultipliers, stutterDuration)
    local firstSV = round(svMultipliers[1], 3)
    local secondSV = round(svMultipliers[2], 3)
    local firstDuration = stutterDuration
    local secondDuration = 100 - stutterDuration
    imgui.Columns(2, "SV Stutter Stats", false)
    imgui.Text("First SV:")
    imgui.Text("Second SV:")
    imgui.NextColumn()
    imgui.Text(firstSV.."x  ("..firstDuration.."%% duration)")
    imgui.Text(secondSV.."x  ("..secondDuration.."%% duration)")
    imgui.Columns(1)
end
-- Displays stats for the current menu's SVs
-- Parameters
--    svStats : list of stats for the current SV menu [Table]
function displaySVStats(svStats)
    imgui.Columns(2, "SV Stats", false)
    imgui.Text("Max SV:")
    imgui.Text("Min SV:")
    imgui.Text("Average SV:")
    imgui.NextColumn()
    imgui.Text(svStats.maxSV.."x")
    imgui.Text(svStats.minSV.."x")
    imgui.Text(svStats.avgSV.."x")
    helpMarker("Rounded to 3 decimal places")
    imgui.Columns(1)
end
-- Gets the current "Place SV" menu's setting variables
-- Parameters
--    svType : name of the current menu's type of SV [Table]
function getSettingVars(svType)
    local settingVars
    if svType == "Linear" then
        settingVars = {
            startSV = 1.5,
            endSV = 0.5,
            svPoints = 16,
            finalSVIndex = 3,
            customSV = 1
        }
    elseif svType == "Exponential" then
        settingVars = {
            behaviorIndex = 1,
            intensity = 30,
            avgSV = 1,
            svPoints = 16,
            finalSVIndex = 3,
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
            finalSVIndex = 3,
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
            finalSVIndex = 3,
            customSV = 1
        }
    elseif svType == "Random" then
        settingVars = {
            randomTypeIndex = 1,
            randomScale = 2,
            avgSV = 1,
            svPoints = 16,
            finalSVIndex = 3,
            customSV = 1
        }
    elseif svType == "Custom" then
        settingVars = {
            svMultipliers = {1.5, -0.5, 1.5, -0.5, 1.5, -0.5, 1.5, -0.5},
            selectedMultiplierIndex = 1,
            svPoints = 8,
            finalSVIndex = 3,
            customSV = 1
        }
    end
    getVariables(svType.."Settings", settingVars)
    return settingVars
end
-- Creates a new window with plots/graphs and stats of the current menu's SVs
-- Parameters
--    windowText      : name of the window [String]
--    svStats         : stats of the SVs [Table]
--    svDistances     : distance vs time list [Table]
--    svMultipliers   : multiplier values of the SVs [Table]
--    stutterDuration : percent duration of first stutter (nil if not stutter SV) [Int]
function makeSVInfoWindow(windowText, svStats, svDistances, svMultipliers, stutterDuration)
    imgui.Begin(windowText, imgui_window_flags.AlwaysAutoResize)
    imgui.Text("Projected Note Motion:")
    helpMarker("Distance vs Time graph of notes")
    plotSVMotion(svDistances, svStats.distMinScale, svStats.distMaxScale)
    imgui.Text("Projected SVs:")
    plotSVs(svMultipliers, svStats.minScale, svStats.maxScale)
    if stutterDuration then
        displayStutterSVStats(svMultipliers, stutterDuration)
    else
        displaySVStats(svStats)
    end
    imgui.End()
end
-- Provides a copy-pastable link to a cubic bezier website and also can parse inputted links
-- Returns whether new bezier coordinates were parsed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function provideBezierWebsiteLink(settingVars)
    local coordinateParsed = false
    local bezierText = state.GetValue("bezierText") or "https://cubic-bezier.com/"
    local imguiFlag = imgui_input_text_flags.AutoSelectAll
    _, bezierText = imgui.InputText("##bezierWebsite", bezierText, 100, imguiFlag)
    imgui.SameLine(0, SAMELINE_SPACING)
    if imgui.Button("Parse", SECONDARY_BUTTON_SIZE) then
        local regex = "(-?%d*%.?%d+)"
        local values = {}
        for value, _ in string.gmatch(bezierText, regex) do
            table.insert(values, tonumber(value))
        end
        if #values >= 4 then
            settingVars.x1, settingVars.y1, settingVars.x2, settingVars.y2 = table.unpack(values)
            coordinateParsed = true
        end
        bezierText = "https://cubic-bezier.com/"
    end
    state.SetValue("bezierText", bezierText)
    helpMarker("This site lets you play around with a cubic bezier whose graph represents the "..
               "motion/path of notes. After finding a good shape for note motion, paste the "..
               "resulting url into the input box and hit the parse button to import the "..
               "coordinate values. Alternatively, enter 4 numbers and hit parse.")
    return coordinateParsed
end

-- Updates the final SV of the precalculated menu SVs
-- Parameters
--    finalSVIndex  : index value for the type of final SV [Int]
--    svMultipliers : list of SV multipliers [Table]
--    customSV      : custom SV value [Int/Float]
function updateFinalSV(finalSVIndex, svMultipliers, customSV)
    local finalSVType = FINAL_SV_TYPES[finalSVIndex]
    if finalSVType == "Normal" then return end
    table.remove(svMultipliers)
    if finalSVType == "Skip" then return end
    table.insert(svMultipliers, customSV)
end
-- Updates SVs and SV info stored in the menu
-- Parameters
--    currentSVType : current type of SV being updated [String]
--    menuVars      : list of variables used for the place SV menu [Table]
--    settingVars   : list of variables used for the current SV menu [Table]
function updateMenuSVs(currentSVType, menuVars, settingVars)
    menuVars.svMultipliers = generateSVMultipliers(currentSVType, settingVars)
    
    local svMultipliersNoEndSV = makeDuplicateList(menuVars.svMultipliers)
    table.remove(svMultipliersNoEndSV)
    menuVars.svDistances = calculateDistanceVsTime(svMultipliersNoEndSV)
    
    updateFinalSV(settingVars.finalSVIndex, menuVars.svMultipliers, settingVars.customSV)
    updateSVStats(menuVars.svStats, menuVars.svMultipliers, svMultipliersNoEndSV,
                  menuVars.svDistances)
end
-- Updates SVs and SV info stored in the stutter menu
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function updateStutterMenuSVs(menuVars)
    menuVars.svMultipliers = generateSVMultipliers("Stutter1", menuVars)
    local svMultipliersNoEndSV = makeDuplicateList(menuVars.svMultipliers)
    table.remove(svMultipliersNoEndSV)
    
    menuVars.svMultipliers2 = generateSVMultipliers("Stutter2", menuVars)
    local svMultipliersNoEndSV2 = makeDuplicateList(menuVars.svMultipliers2)
    table.remove(svMultipliersNoEndSV2)
    
    menuVars.svDistances = calculateStutterDistanceVsTime(svMultipliersNoEndSV, 
                                                          menuVars.stutterDuration,
                                                          menuVars.stuttersPerSection)
    menuVars.svDistances2 = calculateStutterDistanceVsTime(svMultipliersNoEndSV2, 
                                                           menuVars.stutterDuration,
                                                           menuVars.stuttersPerSection)
    
    if menuVars.linearlyChange then
        updateFinalSV(menuVars.finalSVIndex, menuVars.svMultipliers2, menuVars.customSV)
        table.remove(menuVars.svMultipliers)
    else
        updateFinalSV(menuVars.finalSVIndex, menuVars.svMultipliers, menuVars.customSV)
    end
    local svStats = menuVars.svStats
    svStats.minScale, svStats.maxScale = calculatePlotScale(menuVars.svMultipliers)
    svStats.distMinScale, svStats.distMaxScale = calculatePlotScale(menuVars.svDistances)
    local svStats2 = menuVars.svStats2
    svStats2.minScale, svStats2.maxScale = calculatePlotScale(menuVars.svMultipliers2)
    svStats2.distMinScale, svStats2.distMaxScale = calculatePlotScale(menuVars.svDistances2)
end
-- Updates stats for the current menu's SVs
-- Parameters
--    svStats              : list of stats for the current menu's SVs [Table]
--    svMultipliers        : list of sv multipliers [Table]
--    svMultipliersNoEndSV : list of sv multipliers, no end multiplier [Table]
--    svDistances          : list of distances calculated from SV multipliers [Table]
function updateSVStats(svStats, svMultipliers, svMultipliersNoEndSV, svDistances)
    svStats.minScale, svStats.maxScale = calculatePlotScale(svMultipliers)
    svStats.distMinScale, svStats.distMaxScale = calculatePlotScale(svDistances)
    svStats.minSV = round(calculateMinValue(svMultipliersNoEndSV), 2)
    svStats.maxSV = round(calculateMaxValue(svMultipliersNoEndSV), 2)
    svStats.avgSV = round(calculateAverage(svMultipliersNoEndSV, true), 3)
end

---------------------------------------------------------------------------------------------------
-- General Utility Functions ----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

----------------------------------------------------------------------- Notes, SVs, Offsets, Tables

-- Constructs a new reverse-order table from an existing table
-- Returns the reversed table [Table]
-- Parameters
--    oldTable : table to be reversed [Table]
function getReverseTable(oldTable)
    local reverseTable = {}
    for i = 1, #oldTable do
        table.insert(reverseTable, oldTable[#oldTable + 1 - i])
    end
    return reverseTable
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
-- Returns a list of SVs between two offsets/times
-- Parameters
--    startOffset : start time in milliseconds [Int/Float]
--    endOffset   : end time in milliseconds [Int/Float]
function getSVsBetweenOffsets(startOffset, endOffset)
    local svsBetweenOffsets = {}
    for _, sv in pairs(map.ScrollVelocities) do
        local svIsInRange = sv.StartTime >= startOffset and sv.StartTime < endOffset
        if svIsInRange then table.insert(svsBetweenOffsets, sv) end
    end
    return table.sort(svsBetweenOffsets, function(a, b) return a.StartTime < b.StartTime end)
end
-- Makes a duplicate list
-- Returns the new duplicate list [Table]
-- Parameters
--    list : list of values [Table]
function makeDuplicateList(list)
    local duplicateList = {}
    for _, value in ipairs(list) do
        table.insert(duplicateList, value)
    end  
    return duplicateList
end
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
--    startOffset : start time in milliseconds [Int/Float]
--    endOffset   : end time in milliseconds [Int/Float]
function uniqueNoteOffsets(startOffset, endOffset)
    local offsets = {}
    for _, hitObject in pairs(map.HitObjects) do
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

---------------------------------------------------------------------------------------------- Math

-- Calculates the average SV over time for a given set of SVs
-- Returns the average SV [Int/Float]
-- Parameters
--    svs       : list of ordered svs to calculate average SV with [Table]
--    endOffset : final time (milliseconds) to stop calculating at [Int]
function calculateAvgSV(svs, endOffset)
    local totalDisplacement = calculateDisplacementFromSVs(svs, endOffset)
    local startOffset = svs[1].StartTime
    local timeInterval = endOffset - startOffset
    return totalDisplacement / timeInterval
end
-- Calculates the total msx displacement over time for a given set of SVs
-- Returns the total displacement [Int/Float]
-- Parameters
--    svs       : list of ordered svs to calculate displacement with [Table]
--    endOffset : final time (milliseconds) to stop calculating at [Int]
function calculateDisplacementFromSVs(svs, endOffset)
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
    table.remove(svs)
    return totalDisplacement
end
-- Calculates the total msx displacements over time at offsets
-- Returns a table of total displacements [Table]
-- Parameters
--    noteOffsets : list of offsets (milliseconds) to calculate displacement at [Table]
--    noteSpacing : SV multiplier determining spacing [Int/Float]
function calculateDisplacementsFromNotes(noteOffsets, noteSpacing)
    local totalDisplacement = 0
    local displacements = {0}
    for i = 1, #noteOffsets - 1 do
        local noteOffset1 = noteOffsets[i]
        local noteOffset2 = noteOffsets[i + 1]
        local time = (noteOffsets[i + 1] - noteOffsets[i])
        local distance = time * noteSpacing
        totalDisplacement = totalDisplacement + distance
        table.insert(displacements, totalDisplacement)
    end
    return displacements
end
-- Calculates the total msx displacements over time at offsets for a given set of SVs
-- Returns a table of total displacements [Table]
-- Parameters
--    svs     : list of ordered svs to calculate displacement with [Table]
--    offsets : list of offsets (milliseconds) to calculate displacement at [Table]
function calculateDisplacementsFromSVs(svs, offsets)
    local totalDisplacement = 0
    local displacements = {}
    local lastOffset = offsets[#offsets]
    table.insert(svs, utils.CreateScrollVelocity(lastOffset, 0))
    local j = 1
    for i = 1, (#svs - 1) do
        local lastSV = svs[i]
        local nextSV = svs[i + 1]
        local timeDifference = nextSV.StartTime - lastSV.StartTime
        while nextSV.StartTime > offsets[j] do
            local time = offsets[j] - lastSV.StartTime
            local displacement = totalDisplacement
            if time > 0 then
                displacement = displacement + time * lastSV.Multiplier
            end
            table.insert(displacements, displacement)
            j = j + 1
        end
        if timeDifference > 0 then
            local thisDisplacement = timeDifference * lastSV.Multiplier
            totalDisplacement = totalDisplacement + thisDisplacement
        end
    end
    table.remove(svs)
    table.insert(displacements, totalDisplacement)
    return displacements
end
-- Calculates still displacements
-- Returns the still displacements [Table]
-- Parameters
--    stillType        : type of still [String]
--    stillDistance    : distance of the still according to the still type [Int/Float]
--    svDisplacements  : list of displacements of notes based on svs [Table]
--    nsvDisplacements : list of displacements of notes based on notes only, no sv [Table]
function calculateStillDisplacements(stillType, stillDistance, svDisplacements, nsvDisplacements)
    local finalDisplacements = {}
    for i = 1, #svDisplacements do
        local difference = nsvDisplacements[i] - svDisplacements[i]
        table.insert(finalDisplacements, difference)
    end
    local extraDisplacement = stillDistance
    if stillType == "End" then
        extraDisplacement = stillDistance - finalDisplacements[#finalDisplacements]
    end
    if stillType ~= "No" then
        for i = 1, #finalDisplacements do
            finalDisplacements[i] = finalDisplacements[i] + extraDisplacement
        end
    end
    return finalDisplacements
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
-- Forces a number to be a multiple of a half (0.5)
-- Returns the result of the force [Int/Float]
-- Parameters
--    number : number to force to be a multiple of one quarter [Int/Float]
function forceHalf(number)
    return math.floor(number * 2 + 0.5) / 2
end
-- Forces a number to be a multiple of a quarter (0.25)
-- Returns the result of the force [Int/Float]
-- Parameters
--    number : number to force to be a multiple of one quarter [Int/Float]
function forceQuarter(number)
    return math.floor(number * 4 + 0.5) / 4
end
-- Returns the sign of a number: +1 if the number is non-negative, -1 if negative [Int]
-- Parameters
--    number : number to get the sign of
function getSignOfNumber(number)
    if number >= 0 then return 1 end
    return -1
end
-- Returns a usable multiplier for a given offset [Int/Float]
--[[
-- 64 until 2^18 = 262144 ms ~4.3 min, then —> 32
-- 32 until 2^19 = 524288 ms ~8.7 min, then —> 16
-- 16 until 2^20 = 1048576 ms ~17.4 min, then —> 8
-- 8 until 2^21 = 2097152 ms ~34.9 min, then —> 4
-- 4 until 2^22 = 4194304 ms ~69.9 min, then —> 2
-- 2 until 2^23 = 8388608 ms ~139.8 min, then —> 1
--]]
-- Parameters
--    offset: time in milliseconds [Int]
function getUsableOffsetMultiplier(offset)
    local exponent = 23 - math.floor(math.log(math.abs(offset) + 1) / math.log(2))
    if exponent > 6 then exponent = 6 end
    return 2 ^ exponent
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
-- Rounds a number to a given amount of decimal places
-- Returns the rounded number [Int/Float]
-- Parameters
--    number        : number to round [Int/Float]
--    decimalPlaces : number of decimal places to round the number to [Int]
function round(number, decimalPlaces)
    local multiplier = 10 ^ decimalPlaces
    return math.floor(number * multiplier + 0.5) / multiplier
end
-- Evaluates a simplified one-dimensional cubic bezier expression for SV purposes
-- Returns the result of the bezier evaluation
-- Parameters
--    p2 : second coordinate of the actual cubic bezier, first for the SV plugin input [Int/Float]
--    p3 : third coordinate of the actual cubic bezier, second for the SV plugin input [Int/Float]
--    t  : time to evaluate the cubic bezier at [Int/Float]
function simplifiedOneDimensionalBezier(p2, p3, t)
    -- this simplified 1-D cubic bezier has points (0, p2, p3, 1) rather than (p1, p2, p3, p4)
    -- this plugin evaluates those points for both x and y: (0, x1, x2, 1), (0, y1, y2, 1)
    return 3*t*(1-t)^2*p2 + 3*t^2*(1-t)*p3 + t^3
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
--    svValues : set of SV values [Table]
function calculateDistanceVsTime(svValues)
    local distance = 0
    local distancesBackwards = {distance}
    local svValuesBackwards = getReverseTable(svValues)
    for i = 1, #svValuesBackwards do
        distance = distance + svValuesBackwards[i]
        table.insert(distancesBackwards, distance)
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
    if max <= 0 then maxScale = 0 end
    -- restrict the plot range to non-negative values when all values are non-negative
    if min >= 0 then minScale = 0 end
    return minScale, maxScale
end
-- Calculates distance vs time values of a note given a set of stutter SV values
-- Returns the list of distances [Table]
-- Parameters
--    svValues           : set of SV values [Table]
--    stutterDuration    : duration of stutter SV [Int/Float]
--    stuttersPerSection : number of stutters per section [Int]
function calculateStutterDistanceVsTime(svValues, stutterDuration, stuttersPerSection)
    local distance = 0
    local distancesBackwards = {distance}
    local iterations = stuttersPerSection * 100
    if iterations > 1000 then iterations = 1000 end
    for i = 1, iterations do
        local x = ((i - 1) % 100) + 1
        if x <= (100 - stutterDuration) then
            distance = distance + svValues[2]
        else
            distance = distance + svValues[1]
        end
        table.insert(distancesBackwards, distance)
    end
    return getReverseTable(distancesBackwards)
end
-- Creates a distance vs time graph/plot of SV motion
-- Parameters
--    noteDistances : list of note distances [Table]
--    minScale      : minimum scale of the plot [Int/Float]
--    maxScale      : maximum scale of the plot [Int/Float]
function plotSVMotion(noteDistances, minScale, maxScale)
    local plotSize = {ACTION_BUTTON_SIZE[1], 100}
    imgui.PlotLines("##motion", noteDistances, #noteDistances, 0, "", minScale, maxScale, plotSize)
end
-- Returns the minimum value from a list of values [Int/Float]
-- Parameters
--    values : list of numerical values [Table]
function calculateMinValue(values) return math.min(table.unpack(values)) end
-- Returns the maximum value from a list of values [Int/Float]
-- Parameters
--    values : list of numerical values [Table]
function calculateMaxValue(values) return math.max(table.unpack(values)) end
-- Returns the average value from a list of values [Int/Float]
-- Parameters
--    values           : list of numerical values [Table]
--    includeLastValue : whether or not to include the last value for the average [Boolean]
function calculateAverage(values, includeLastValue)
    if #values == 0 then return nil end
    local sum = 0
    for _, value in pairs(values) do
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
    local plotSize = {ACTION_BUTTON_SIZE[1], 100}
    imgui.PlotHistogram("##svplot", svVals, #svVals, 0, "", minScale, maxScale, plotSize)
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
    local onlyStartOffset = false
    if actionName == "Displace note" then 
        minimumNotes = 1
        actionThing = "for"
    elseif actionName == "Add teleport" then    
        minimumNotes = 1
        actionThing = "at"
        onlyStartOffset = true
    end
    chooseStartEndOffsets(globalVars, onlyStartOffset)
    local enoughSelectedNotes = checkEnoughSelectedNotes(minimumNotes)
    local needToSelectNotes = not (globalVars.useManualOffsets or enoughSelectedNotes)
    if needToSelectNotes then imgui.Text("Select "..minimumNotes.." or more notes") return end
    
    local actionItem = "selected notes"
    if globalVars.useManualOffsets then actionItem = "offsets" end
    local buttonText = actionName.." SVs "..actionThing.." "..actionItem
    button(buttonText, ACTION_BUTTON_SIZE, actionfunc, globalVars, menuVars)
    toolTip("You can also press 'T' on your keyboard to do the same thing as this button")
    ifKeyPressedThenExecute(keys.T, actionfunc, globalVars, menuVars)
end
-- Checks to see if enough notes are selected
-- Returns whether or not there are enought notes [Boolean]
-- Parameters
--    minimumNotes : minimum number of notes needed to select [Int]
function checkEnoughSelectedNotes(minimumNotes)
    local selectedNotes = state.SelectedHitObjects
    local numSelectedNotes = #selectedNotes
    if numSelectedNotes == 0 then return false end
    if numSelectedNotes > map.GetKeyCount() then return true end
    if minimumNotes == 1 then return true end
    return selectedNotes[1].StartTime ~= selectedNotes[numSelectedNotes].StartTime
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
    if menuVars and menuVars.sectionIndex == 1 then -- per note section
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
            for _, sv in pairs(newSVsToRemove) do 
                table.insert(svsToRemove, sv)
            end
            for _, sv in pairs(newSVsToAdd) do 
                table.insert(svsToAdd, sv)
            end
        end
    end
    removeAndAddSVs(svsToRemove, svsToAdd)
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
    _, menuVars.avgSV = imgui.InputFloat("Average SV", menuVars.avgSV, 0, 0, "%.2fx")
    return oldAvg ~= menuVars.avgSV
end
-- Lets you choose the bezier point coordinates
-- Returns whether or not any of the coordinates changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
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
    local x1Changed = (oldFirstPoint[1] ~= settingVars.x1) 
    local y1Changed = (oldFirstPoint[2] ~= settingVars.y1)
    local x2Changed = (oldSecondPoint[1] ~= settingVars.x2)
    local y2Changed = (oldSecondPoint[2] ~= settingVars.y2)
    return x1Changed or y1Changed or x2Changed or y2Changed
end
-- Lets you choose the color scheme of the plugin
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseColorScheme(globalVars)
    local comboIndex = globalVars.colorSchemeIndex - 1
    _, comboIndex = imgui.Combo("Color Scheme", comboIndex, COLOR_SCHEMES, #COLOR_SCHEMES)
    globalVars.colorSchemeIndex = comboIndex + 1
end
-- Lets you choose a constant amount to shift SVs
-- Returns whether or not the shift amount changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseConstantShift(settingVars)
    if imgui.Button("Reset##verticalShift", SECONDARY_BUTTON_SIZE) then
        settingVars.verticalShift = 1
    end
    local oldShift = settingVars.verticalShift
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.7 - SAMELINE_SPACING)
    local _, newShift = imgui.InputFloat("Vertical Shift", oldShift, 0, 0, "%.2fx")
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    settingVars.verticalShift = newShift
    return oldShift ~= newShift
end
-- Lets you choose SV curve sharpness
-- Returns whether or not the curve sharpness changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseCurveSharpness(settingVars)
    if imgui.Button("Reset##curveSharpness", SECONDARY_BUTTON_SIZE) then
        settingVars.curveSharpness = 50
    end
    local oldSharpness = settingVars.curveSharpness
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.7 - SAMELINE_SPACING)
    local _, newSharpness = imgui.DragInt("Curve Sharpness", oldSharpness, 1, 1, 100, "%d%%")
    newSharpness = clampToInterval(newSharpness, 1, 100)
    settingVars.curveSharpness = newSharpness
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    return oldSharpness ~= newSharpness
end
-- Lets you choose custom multipliers for custom SV
-- Returns whether or not any custom multipliers changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseCustomMultipliers(settingVars)
    imgui.BeginChild("Custom Multipliers", {imgui.GetContentRegionAvailWidth(), 90}, true)
    for i = 1, #settingVars.svMultipliers do
        local selectableText = i.." )   "..round(settingVars.svMultipliers[i], 5)
        if imgui.Selectable(selectableText, settingVars.selectedMultiplierIndex == i) then
            settingVars.selectedMultiplierIndex = i
        end
    end
    imgui.EndChild()
    local index = settingVars.selectedMultiplierIndex
    local oldMultiplier = settingVars.svMultipliers[index]
    local _, newMultiplier = imgui.InputFloat("SV Multiplier", oldMultiplier, 0, 0, "%.2fx")
    settingVars.svMultipliers[index] = newMultiplier
    addSeparator()
    return oldMultiplier ~= newMultiplier
end
-- Lets you choose the displace type
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function chooseDisplaceType(globalVars, menuVars)
    local comboIndex = menuVars.displaceTypeIndex - 1
    _, comboIndex = imgui.Combo("Displace Type", comboIndex, DISPLACE_TYPES, #DISPLACE_TYPES)
    menuVars.displaceTypeIndex = comboIndex + 1
end
-- Lets you choose a distance
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseDistance(menuVars)
    _, menuVars.distance = imgui.InputFloat("Distance##stand", menuVars.distance, 0, 0, "%.3f msx")
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
    if currentTool == "Add Teleport"  then toolTip("Add a large teleport SV to move far away") end
    if currentTool == "Copy & Paste"  then toolTip("Copy SVs and paste them somewhere else") end
    if currentTool == "Displace Note" then toolTip("Move where notes are hit on the screen") end
    if currentTool == "Displace View" then toolTip("Temporarily displace the playfield view") end
    if currentTool == "Flicker"       then toolTip("Flash notes on and off the screen") end
    if currentTool == "Measure"       then toolTip("Get info/stats about SVs in a section") end
    if currentTool == "Merge"         then toolTip("Combine SVs that overlap") end
    if currentTool == "Scale"         then toolTip("Scale SV values to change note spacing") end
    --if currentTool == "Vibe"          then toolTip("Make notes appear in two places at once") end
end
-- Lets you choose the behavior of the exponential SVs
-- Returns whether or not the behavior changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseExponentialBehavior(settingVars)
    local oldBehaviorIndex = settingVars.behaviorIndex
    local comboIndex = settingVars.behaviorIndex - 1
    _, comboIndex = imgui.Combo("Behavior", comboIndex, SV_BEHAVIORS, #SV_BEHAVIORS)
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
-- Lets you choose the first height/displacement for splitscroll
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseFirstHeight(menuVars)
    _, menuVars.height1 = imgui.InputFloat("1st Height", menuVars.height1, 0, 0, "%.3f msx")
    helpMarker("Height at which notes are hit at on screen for the 1st scroll speed")
end
-- Lets you choose the first scroll speed for splitscroll
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseFirstScrollSpeed(menuVars)
    local text = "1st Scroll Speed"
    _, menuVars.scrollSpeed1 = imgui.InputFloat(text, menuVars.scrollSpeed1, 0, 0, "%.2fx")
end
-- Lets you choose the main SV multiplier of a teleport stutter
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseMainSV(menuVars)
    _, menuVars.mainSV = imgui.InputFloat("Main SV", menuVars.mainSV, 0, 0, "%.2fx")
    helpMarker("This SV will last ~99.99%% of the stutter")
end
-- Lets you choose the mspf (milliseconds per frame) for splitscroll
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseMSPF(menuVars)
    local _, newMSPF = imgui.InputFloat("ms Per Frame", menuVars.msPerFrame, 0.5, 0.5, "%.1f")
    newMSPF = forceHalf(newMSPF)
    newMSPF = clampToInterval(newMSPF, 4, 1000)
    menuVars.msPerFrame = newMSPF
    helpMarker("Number of milliseconds the splitscroll will display one scroll speed at before "..
               "jumping to the next scroll speed")
end
-- Lets you choose whether or not to linearly change something
-- Returns whether or not the choice changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseLinearlyChange(menuVars)
    local oldChoice = menuVars.linearlyChange
    local _, newChoice = imgui.Checkbox("Change stutter over time", oldChoice)
    menuVars.linearlyChange = newChoice
    return oldChoice ~= newChoice
end
-- Lets you choose the flicker type
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseFlickerType(menuVars)
    local comboIndex = menuVars.flickerTypeIndex - 1
    _, comboIndex = imgui.Combo("Flicker Type", comboIndex, FLICKER_TYPES, #FLICKER_TYPES)
    menuVars.flickerTypeIndex = comboIndex + 1
end
-- Lets you choose the intensity of something from 1 to 100
-- Returns whether or not the intensity changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function chooseIntensity(settingVars)
    local oldIntensity = settingVars.intensity
    local _, newIntensity = imgui.SliderInt("Intensity", oldIntensity, 1, 100, oldIntensity.."%%")
    newIntensity = clampToInterval(newIntensity, 1, 100)
    settingVars.intensity = newIntensity
    return oldIntensity ~= newIntensity
end
-- Lets you choose the note spacing
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseNoteSpacing(menuVars)
    _, menuVars.noteSpacing = imgui.InputFloat("Note Spacing", menuVars.noteSpacing, 0, 0, "%.2fx")
end
-- Lets you choose the number of flickers
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseNumFlickers(menuVars)
    _, menuVars.numFlickers = imgui.InputInt("Flickers", menuVars.numFlickers, 1, 1)
    menuVars.numFlickers = clampToInterval(menuVars.numFlickers, 1, 100)
end
-- Lets you choose the number of periods for a sinusoidal wave
-- Returns whether or not the number of periods changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function chooseNumPeriods(settingVars)
    local oldPeriods = settingVars.periods
    local _, newPeriods = imgui.InputFloat("Periods/Cycles", oldPeriods, 0.25, 0.25, "%.2f")
    newPeriods = forceQuarter(newPeriods)
    newPeriods = clampToInterval(newPeriods, 0.25, 20)
    settingVars.periods = newPeriods
    return oldPeriods ~= newPeriods
end
-- Lets you choose the number of periods to shift over for a sinusoidal wave
-- Returns whether or not the period shift value changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function choosePeriodShift(settingVars)
    local oldShift = settingVars.periodsShift
    local _, newShift = imgui.InputFloat("Phase Shift", oldShift, 0.25, 0.25, "%.2f")
    newShift = forceQuarter(newShift)
    newShift = clampToInterval(newShift, -0.75, 0.75)
    settingVars.periodsShift = newShift
    return oldShift ~= newShift
end
-- Lets you choose the place SV behavior
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function choosePlaceBehavior(globalVars)
    local comboIndex = globalVars.placeBehaviorIndex - 1
    _, comboIndex = imgui.Combo("Place Behavior", comboIndex, PLACE_BEHAVIORS, #PLACE_BEHAVIORS)
    globalVars.placeBehaviorIndex = comboIndex + 1
    local behavior = PLACE_BEHAVIORS[globalVars.placeBehaviorIndex]
    if behavior == "Replace old SVs" then toolTip("Delete old SVs when placing SVs") end
    if behavior == "Keep old SVs"    then toolTip("DON'T delete old SVs when placing SVs") end
end
-- Lets you choose the 'place SV' type
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function choosePlaceSVType(globalVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("  Type : ")
    imgui.SameLine(0, SAMELINE_SPACING)
    local comboIndex = globalVars.placeTypeIndex - 1
    _, comboIndex = imgui.Combo("##placetype", comboIndex, PLACE_TYPES, #PLACE_TYPES)
    globalVars.placeTypeIndex = comboIndex + 1
    local placeType = PLACE_TYPES[globalVars.placeTypeIndex]
    if placeType == "Still" then toolTip("Still makes notes keep the normal distance apart") end
end
-- Lets you choose the variability scale of randomness
-- Returns whether or not the variability value changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function chooseRandomScale(settingVars)
    local oldScale = settingVars.randomScale
    local _, newScale = imgui.InputFloat("Random Scale", oldScale, 0, 0, "%.2fx")
    settingVars.randomScale = newScale
    return oldScale ~= newScale
end
-- Lets you choose the type of random generation
-- Returns whether or not the type of random generation changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function chooseRandomType(settingVars)
    local oldIndex = settingVars.randomTypeIndex
    local comboIndex = oldIndex - 1
    _, comboIndex = imgui.Combo("Random Type", comboIndex, RANDOM_TYPES, #RANDOM_TYPES)
    settingVars.randomTypeIndex = comboIndex + 1
    return oldIndex ~= settingVars.randomTypeIndex
end
-- Lets you choose the ratio
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseRatio(menuVars)
    _, menuVars.ratio = imgui.InputFloat("Ratio", menuVars.ratio, 0, 0, "%.2f")
end
-- Lets you choose whether or not to pause RGB color cycling
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseRGBPause(globalVars)
    addPadding()
    _, globalVars.rgbPaused = imgui.Checkbox("Pause RGB color changing", globalVars.rgbPaused)
    helpMarker("If you have a RGB color scheme selected, stops the colors from cycling/changing")
end
-- Lets you choose the second height/displacement for splitscroll
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseSecondHeight(menuVars)
    _, menuVars.height2 = imgui.InputFloat("2nd Height", menuVars.height2, 0, 0, "%.3f msx")
    helpMarker("Height at which notes are hit at on screen for the 2nd scroll speed")
end
-- Lets you choose the second scroll speed for splitscroll
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseSecondScrollSpeed(menuVars)
    local text = "2nd Scroll Speed"
    _, menuVars.scrollSpeed2 = imgui.InputFloat(text, menuVars.scrollSpeed2, 0, 0, "%.2fx")
end
-- Lets you choose which section(s) to target SV actions at
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function chooseSection(globalVars, menuVars)
    if globalVars.useManualOffsets or menuVars.scaleTypeIndex == 3 then return end -- Relative Ratio
    local comboIndex = menuVars.sectionIndex - 1
    _, comboIndex = imgui.Combo("Target Section", comboIndex, SECTIONS, #SECTIONS)
    menuVars.sectionIndex = comboIndex + 1
end
-- Lets you choose the special SV type
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseSpecialSVType(menuVars)
    local comboIndex = menuVars.svTypeIndex - 1
    local emoticonIndex = menuVars.svTypeIndex + #STANDARD_SVS
    local emoticon = EMOTICONS[emoticonIndex]
    local indentAmount = 45
    imgui.Indent(indentAmount)
    _, comboIndex = imgui.Combo("  "..emoticon, comboIndex, SPECIAL_SVS, #SPECIAL_SVS)
    imgui.Unindent(indentAmount)
    menuVars.svTypeIndex = comboIndex + 1
    addSeparator()
end
-- Lets you choose the standard SV type
-- Returns whether or not the SV type changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseStandardSVType(menuVars)
    local oldcomboIndex = menuVars.svTypeIndex - 1
    local emoticonIndex = menuVars.svTypeIndex
    local emoticon = EMOTICONS[emoticonIndex]
    local indentAmount = 45
    imgui.Indent(indentAmount)
    local _, newComboIndex = imgui.Combo(" "..emoticon, oldcomboIndex, STANDARD_SVS, #STANDARD_SVS)
    imgui.Unindent(indentAmount)
    menuVars.svTypeIndex = newComboIndex + 1
    return oldcomboIndex ~= newComboIndex
end
-- Lets you choose start and end offsets (globally available)
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    onlyStart  : whether or not to only choose the start offset [Boolean]
function chooseStartEndOffsets(globalVars, onlyStart)
    if not globalVars.useManualOffsets then return end
    
    local currentButtonSize = {DEFAULT_WIDGET_WIDTH * 0.4, DEFAULT_WIDGET_HEIGHT - 2}
    
    if imgui.Button("Current##startOffset", currentButtonSize) then
        globalVars.startOffset = state.SongTime
    end
    toolTip("Set the start offset to the current song time")
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.8)
    _, globalVars.startOffset = imgui.InputInt("Start", globalVars.startOffset)
    helpMarker("Start offset/time in milliseconds")
    
    if onlyStart then addSeparator() return end
    
    if imgui.Button("Current##endOffset", currentButtonSize) then
        globalVars.endOffset = state.SongTime
    end
    toolTip("Set the end offset to the current song time")
    imgui.SameLine(0, SAMELINE_SPACING)
    _, globalVars.endOffset = imgui.InputInt("End", globalVars.endOffset)
    helpMarker("End offset/time in milliseconds")
    addSeparator()
end
-- Lets you choose a start and an end SV
-- Returns whether or not the start or end SVs changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseStartEndSVs(settingVars)
    if settingVars.linearlyChange == false then
        local oldValue = settingVars.startSV
        local _, newValue = imgui.InputFloat("Start SV", oldValue, 0, 0, "%.2fx")
        settingVars.startSV = newValue
        return oldValue ~= newValue
    end
    local oldValues = {settingVars.startSV, settingVars.endSV}
    local _, newValues = imgui.InputFloat2("Start/End SV", oldValues, "%.2fx")
    settingVars.startSV = newValues[1]
    settingVars.endSV = newValues[2]
    return oldValues[1] ~= newValues[1] or oldValues[2] ~= newValues[2]
end
-- Lets you choose a start SV percent
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseStartSVPercent(menuVars)
    _, menuVars.svPercent = imgui.InputFloat("Start SV %", menuVars.svPercent, 1, 1, "%.2f%%")
    helpMarker("%% distance between notes")
end
-- Lets you choose the still type
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseStillType(menuVars)
    local stillType = STILL_TYPES[menuVars.stillTypeIndex]
    local dontChooseDistance = stillType == "No" or stillType == "Auto"
    local indentWidth = DEFAULT_WIDGET_WIDTH * 0.5 + 16
    if dontChooseDistance then
        imgui.Indent(indentWidth)
    else
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.6 - 5)
        _, menuVars.stillDistance = imgui.InputFloat("##still", menuVars.stillDistance, 0, 0,
                                                     "%.2f msx")
        imgui.SameLine(0, SAMELINE_SPACING)
    end
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.4)
    local comboIndex = menuVars.stillTypeIndex - 1
    _, comboIndex = imgui.Combo("Displacement", comboIndex, STILL_TYPES, #STILL_TYPES)
    menuVars.stillTypeIndex = comboIndex + 1
    
    if stillType == "No"    then toolTip("Don't use an inital or end displacement") end
    if stillType == "Start" then toolTip("Use an inital starting displacement for the still") end
    if stillType == "End"   then toolTip("Have a displacement to end at for the still") end
    if stillType == "Auto"  then toolTip("Use last displacement of a previous still to start") end
    
    if dontChooseDistance then
        imgui.Unindent(indentWidth)
    end
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
end
-- Lets you choose the duration of the first stutter SV
-- Returns whether or not the duration changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseStutterDuration(menuVars)
    local oldDuration = menuVars.stutterDuration
    local _, newDuration = imgui.SliderInt("Duration", oldDuration, 1, 99, oldDuration.."%%")
    newDuration = clampToInterval(newDuration, 1, 99)
    menuVars.stutterDuration = newDuration 
    return oldDuration ~= newDuration 
end
-- Lets you choose the number of stutters per section
-- Returns whether or not the number of stutters changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseStuttersPerSection(menuVars)
    local oldNumber = menuVars.stuttersPerSection
    local _, newNumber = imgui.InputInt("Stutters", oldNumber, 1, 1)
    helpMarker("Number of stutters per section")
    newNumber = clampToInterval(newNumber, 1, 100)
    menuVars.stuttersPerSection = newNumber
    return oldNumber ~= newNumber
end
-- Lets you choose the style scheme of the plugin
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseStyleScheme(globalVars)
    local comboIndex = globalVars.styleSchemeIndex - 1
    _, comboIndex = imgui.Combo("Style Scheme", comboIndex, STYLE_SCHEMES, #STYLE_SCHEMES)
    globalVars.styleSchemeIndex = comboIndex + 1
end
-- Lets you choose the number of SV points per quarter period of a sinusoidal wave
-- Returns whether or not the number of SV points changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function chooseSVPerQuarterPeriod(settingVars)
    local oldPoints = settingVars.svsPerQuarterPeriod
    local _, newPoints = imgui.InputInt("SV Points##perQuarter", oldPoints, 1, 1)
    helpMarker("Number of SV points per 0.25 period/cycle")
    local maxSVsPerQuarterPeriod = MAX_SV_POINTS / (4 * settingVars.periods)
    newPoints = clampToInterval(newPoints, 1, maxSVsPerQuarterPeriod)
    settingVars.svsPerQuarterPeriod = newPoints
    return oldPoints ~= newPoints
end
-- Lets you choose the number of SV points
-- Returns whether or not the number of SV points changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function chooseSVPoints(settingVars)
    local oldPoints = settingVars.svPoints
    _, settingVars.svPoints = imgui.InputInt("SV Points##regular", oldPoints, 1, 1)
    settingVars.svPoints = clampToInterval(settingVars.svPoints, 1, MAX_SV_POINTS)
    return oldPoints ~= settingVars.svPoints
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
-- Lets you choose whether to use distnace or not
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseUseDistance(menuVars)
    _, menuVars.useDistance = imgui.Checkbox("Use distance for start SV", menuVars.useDistance)
end
---------------------------------------------------------------------------------------------------
-- Doing SV Stuff ---------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------ Generating SVs

-- Returns generated sv multipliers [Table]
-- Parameters
--    svType      : type of SV to generate [String]
--    settingVars : list of variables used for the current menu [Table]
function generateSVMultipliers(svType, settingVars)
    local multipliers = {727, 69}
    if svType == "Linear" then
        multipliers = generateLinearSet(settingVars.startSV, settingVars.endSV, 
                                        settingVars.svPoints + 1)
    elseif svType == "Exponential" then
        local behavior = SV_BEHAVIORS[settingVars.behaviorIndex]
        multipliers = generateExponentialSet(behavior, settingVars.svPoints + 1, settingVars.avgSV,
                                             settingVars.intensity)
    elseif svType == "Bezier" then
        multipliers = generateBezierSet(settingVars.x1, settingVars.y1, settingVars.x2,
                                        settingVars.y2, settingVars.avgSV, settingVars.svPoints + 1)
    elseif svType == "Sinusoidal" then
         multipliers = generateSinusoidalSet(settingVars.startSV, settingVars.endSV,
                                             settingVars.periods, settingVars.periodsShift,
                                             settingVars.svsPerQuarterPeriod,
                                             settingVars.verticalShift, settingVars.curveSharpness)
    elseif svType == "Random" then
        local randomType = RANDOM_TYPES[settingVars.randomTypeIndex]
        multipliers = generateRandomSet(settingVars.avgSV, settingVars.svPoints + 1, randomType,
                                        settingVars.randomScale)
    elseif svType == "Custom" then
        multipliers = generateCustomSet(settingVars.svMultipliers)
    elseif svType == "Stutter1" then
        multipliers = generateStutterSet(settingVars.startSV, settingVars.stutterDuration,
                                         settingVars.avgSV)
    elseif svType == "Stutter2" then
        multipliers = generateStutterSet(settingVars.endSV, settingVars.stutterDuration,
                                         settingVars.avgSV)
    end
    return multipliers
end
-- Returns a set of linear values [Table]
-- Parameters
--    startValue : starting value of the linear set [Int/Float]
--    endValue   : ending value of the linear set [Int/Float]
--    numValues  : total number of values in the linear set [Int]
function generateLinearSet(startValue, endValue, numValues)
    local linearSet = {startValue}
    if numValues > 1 then
        local increment = (endValue - startValue) / (numValues - 1)
        for i = 1, numValues - 1 do
            table.insert(linearSet, startValue + i * increment)
        end
    end
    return linearSet
end
-- Returns a set of exponential values [Table]
-- Parameters
--    behavior  : behavior of the values (increase/speed up, or decrease/slow down) [String]
--    numValues : total number of values in the exponential set [Int]
--    avgValue  : average value of the set [Int/Float]
--    intensity : value determining sharpness/rapidness of exponential change [Int/Float]
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
        local y = (math.exp(x) / math.exp(1)) / intensity
        table.insert(exponentialSet, y)
    end
    normalizeValues(exponentialSet, avgValue, false)
    return exponentialSet
end
-- Returns a set of bezier values [Table]
-- Parameters
--    x1        : x-coordinate of the first (inputted) cubic bezier point [Int/Float]
--    y1        : y-coordinate of the first (inputted) cubic bezier point [Int/Float]
--    x2        : x-coordinate of the second (inputted) cubic bezier point [Int/Float]
--    y2        : y-coordinate of the second (inputted) cubic bezier point [Int/Float]
--    avgValue  : average value of the set [Int/Float]
--    numValues : total number of values in the bezier set [Int]
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
        local slope = (yPositions[i + 1] - yPositions[i]) * numValues
        table.insert(bezierSet, slope)
    end
    normalizeValues(bezierSet, avgValue, false)
    return bezierSet
end
-- Returns a set of sinusoidal values [Table]
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
        local value = amplitudes[i + 1] * (math.abs(math.sin(angle))^(normalizedSharpness))
        value = value * getSignOfNumber(math.sin(angle)) + verticalShift
        table.insert(sinusoidalSet, value)
    end
    return sinusoidalSet
end
-- Returns a set of random values [Table]
-- Parameters
--    avgValue    : average value of the set [Int/Float]
--    numValues   : total number of values in the exponential set [Int]
--    randomType  : type of random distribution to use [String]
--    randomScale : how much to scale random values [Int/Float]
function generateRandomSet(avgValue, numValues, randomType, randomScale)
    local randomSet = {}
    for i = 1, numValues do
        if randomType == "Uniform" then
            local randomValue = avgValue + randomScale * 2 * (0.5 - math.random())
            table.insert(randomSet, randomValue)
        elseif randomType == "Normal" then
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
-- Returns a set of custom values [Table]
-- Parameters
--    oldMultipliers : chosen custom multiplier values [Table]
function generateCustomSet(oldMultipliers)
    local newMultipliers = {}
    for _, multiplier in pairs(oldMultipliers) do
        table.insert(newMultipliers, multiplier)
    end
    local averageMultiplier = calculateAverage(newMultipliers, true)
    table.insert(newMultipliers, averageMultiplier)
    return newMultipliers
end
-- Returns a set of stutter values [Table]
-- Parameters
--    firstSV         : value of the first SV of the stutter [Int/Float]
--    stutterDuration : duration of the stutter (out of 100) [Int]
--    avgSV           : average SV value [Int/Float]
function generateStutterSet(firstSV, stutterDuration, avgSV)
    local durationPercent = stutterDuration / 100
    local secondSV = (avgSV - firstSV * durationPercent) / (1 - durationPercent)
    return {firstSV, secondSV, avgSV}
end

------------------------------------------------------------------------------------- Acting on SVs

-- Gets removable SVs
-- Parameters
--    svsToRemove   : list of SVs to remove [Table]
--    svTimeIsAdded : list of SVs times added [Table]
--    startOffset   : starting offset to remove after [Int]
--    endOffset     : endd offset to remove before [Int]
function getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    for _, sv in pairs(map.ScrollVelocities) do
        local svIsInRange = sv.StartTime >= startOffset - 1 and sv.StartTime <= endOffset + 1
        if svIsInRange then 
            local svRemovable = svTimeIsAdded[sv.StartTime]
            if svRemovable then table.insert(svsToRemove, sv) end
        end
    end
end
-- Removes and adds SVs
-- Parameters
--    svsToRemove : list of SVs to remove [Table]
--    svsToAdd    : list of SVs to add [Table]
function removeAndAddSVs(svsToRemove, svsToAdd)
    if #svsToAdd == 0 then return end
    local editorActions = {
        utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToRemove),
        utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svsToAdd)
    }
    actions.PerformBatch(editorActions)
end
-- Places stutter SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function placeStutterSVs(globalVars, menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local offsets = getSelectedOffsets(globalVars)
    local firstOffset = offsets[1]
    local lastOffset = offsets[#offsets]
    local lastFirstStutter = menuVars.endSV
    if not menuVars.linearlyChange then 
        lastFirstStutter = menuVars.startSV
    end
    local totalNumStutters = (#offsets - 1) * menuVars.stuttersPerSection
    local firstStutterSVs = generateLinearSet(menuVars.startSV, lastFirstStutter, totalNumStutters)
    local stutterIndex = 1
    for i = 1, #offsets - 1 do
        local startOffset = offsets[i]
        local endOffset = offsets[i + 1]
        local stutterOffsets =  generateLinearSet(startOffset, endOffset,
                                                  menuVars.stuttersPerSection + 1)
        for j = 1, #stutterOffsets - 1 do
            local svMultipliers = generateStutterSet(firstStutterSVs[stutterIndex],
                                                     menuVars.stutterDuration, menuVars.avgSV)
            local stutterStart = stutterOffsets[j]
            local stutterEnd = stutterOffsets[j + 1]
            local timeInterval = stutterEnd - stutterStart
            local secondSVOffset = stutterStart + timeInterval * menuVars.stutterDuration / 100
            table.insert(svsToAdd, utils.CreateScrollVelocity(stutterStart, svMultipliers[1]))
            table.insert(svsToAdd, utils.CreateScrollVelocity(secondSVOffset, svMultipliers[2]))
            stutterIndex = stutterIndex + 1
        end
    end
    local finalSVType = FINAL_SV_TYPES[menuVars.finalSVIndex]
    local hasFinalSV = finalSVType ~= "Skip"
    if hasFinalSV then
        local lastMultiplier
        if menuVars.linearlyChange then
            lastMultiplier = menuVars.svMultipliers2[3]
        else
            lastMultiplier = menuVars.svMultipliers[3]
        end
        table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset, lastMultiplier))
    end
    local placeBehavior = PLACE_BEHAVIORS[globalVars.placeBehaviorIndex]
    if placeBehavior == "Replace old SVs" then
        svsToRemove = getSVsBetweenOffsets(firstOffset, lastOffset)
    end
    
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Places teleport stutter SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function placeTeleportStutterSVs(globalVars, menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local offsets = getSelectedOffsets(globalVars)
    local firstOffset = offsets[1]
    local lastOffset = offsets[#offsets]
    for i = 1, #offsets - 1 do
        local startOffset = offsets[i]
        local endOffset = offsets[i + 1]
        local offsetInterval = endOffset - startOffset
        local startMultiplier = getUsableOffsetMultiplier(startOffset)
        local startDuration = 1 / startMultiplier
        local endMultiplier = getUsableOffsetMultiplier(endOffset)
        local endDuration = 1 / endMultiplier

        local startDistance = menuVars.distance
        if not menuVars.useDistance then startDistance = offsetInterval * (menuVars.svPercent / 100) end
        local expectedDistance = offsetInterval * menuVars.avgSV
        local traveledDistance = offsetInterval * menuVars.mainSV
        local endDistance = expectedDistance - startDistance - traveledDistance
        
        table.insert(svsToAdd, utils.CreateScrollVelocity(startOffset, menuVars.mainSV + startDistance * startMultiplier))
        table.insert(svsToAdd, utils.CreateScrollVelocity(startOffset + startDuration, menuVars.mainSV))
        table.insert(svsToAdd, utils.CreateScrollVelocity(endOffset - endDuration, menuVars.mainSV + endDistance * endMultiplier))
    end
    
    local finalSVType = FINAL_SV_TYPES[menuVars.finalSVIndex]
    if finalSVType == "Custom" then
        table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset, menuVars.customSV))
    elseif finalSVType == "Normal" then
        table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset, menuVars.avgSV))
    end
    
    local placeBehavior = PLACE_BEHAVIORS[globalVars.placeBehaviorIndex]
    if placeBehavior == "Replace old SVs" then
        svsToRemove = getSVsBetweenOffsets(firstOffset, lastOffset)
    end
    
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Places (standard) SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function placeSVs(globalVars, menuVars)
    local placingStillSVs = menuVars.stillDistance ~= nil and not globalVars.useManualOffsets
    local svsToAdd = {}
    local svsToRemove = {}
    local numMultipliers = #menuVars.svMultipliers
    local offsets = getSelectedOffsets(globalVars)
    local firstOffset = offsets[1]
    local lastOffset = offsets[#offsets]
    if placingStillSVs then offsets = {firstOffset, lastOffset} end
      
    for i = 1, #offsets - 1 do
        local startOffset = offsets[i]
        local endOffset = offsets[i + 1]
        local svOffsets = generateLinearSet(startOffset, endOffset, #menuVars.svDistances)
        for j = 1, #svOffsets - 1 do
            local offset = svOffsets[j]
            local multiplier = menuVars.svMultipliers[j]
            table.insert(svsToAdd, utils.CreateScrollVelocity(offset, multiplier))
        end
    end
    
    local hasFinalSV = #menuVars.svDistances == numMultipliers
    if hasFinalSV then
        local lastMultiplier = menuVars.svMultipliers[numMultipliers]
        table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset, lastMultiplier))
    end
    
    local placeBehavior = PLACE_BEHAVIORS[globalVars.placeBehaviorIndex]
    if placeBehavior == "Replace old SVs" or placingStillSVs then
        svsToRemove = getSVsBetweenOffsets(firstOffset, lastOffset)
    end
    
    removeAndAddSVs(svsToRemove, svsToAdd)
    if placingStillSVs then placeStillSVs(menuVars, firstOffset, lastOffset) end
end
-- Places still SVs
-- Parameters
--    menuVars    : list of variables used for the current menu [Table]
--    firstOffset : starting millisecond time of the still [Int]
--    lastOffset  : ending millisecond time of the still [Int]
function placeStillSVs(menuVars, firstOffset, lastOffset)
    local stillType = STILL_TYPES[menuVars.stillTypeIndex]
    local noteOffsets = uniqueNoteOffsets(firstOffset, lastOffset)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local svsBetweenOffsets = getSVsBetweenOffsets(firstOffset, lastOffset)
    local svDisplacements = calculateDisplacementsFromSVs(svsBetweenOffsets, noteOffsets)
    local nsvDisplacements = calculateDisplacementsFromNotes(noteOffsets, menuVars.noteSpacing)
    local stillDistance = menuVars.stillDistance
    if stillType == "Auto" then
        local candidateSVs = getSVsBetweenOffsets(firstOffset - 1, firstOffset)
        if #candidateSVs == 0 then
            stillDistance = 0
        else
            local lastSV = candidateSVs[#candidateSVs]
            local time = firstOffset - lastSV.StartTime
            stillDistance = lastSV.Multiplier * time
        end
    end
    local finalDisplacements = calculateStillDisplacements(stillType, stillDistance,
                                                           svDisplacements, nsvDisplacements)
    for i = 1, #noteOffsets do
        local noteOffset = noteOffsets[i]
        local multiplier = getUsableOffsetMultiplier(noteOffset)
        local duration = 1 / multiplier
        if i ~= #noteOffsets then
            local timeAt = noteOffset
            local timeAfter = noteOffset + duration
            svTimeIsAdded[timeAt] = true
            svTimeIsAdded[timeAfter] = true
            local svMultiplierAt = getSVMultiplierAt(timeAt)
            local svMultiplierAfter = getSVMultiplierAt(timeAfter)
            local newMultiplierAt = -finalDisplacements[i] * multiplier + svMultiplierAt
            local newMultiplierAfter = svMultiplierAfter
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, newMultiplierAt))
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, newMultiplierAfter))
        end
        if i ~= 1 then
            local timeBefore = noteOffset - duration
            svTimeIsAdded[timeBefore] = true
            local svMultiplierBefore = getSVMultiplierAt(timeBefore)
            local newMultiplierBefore = finalDisplacements[i] * multiplier + svMultiplierBefore
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeBefore, newMultiplierBefore))
        end
    end
    getRemovableSVs(svsToRemove, svTimeIsAdded, firstOffset, lastOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Places reverse scroll SVs 
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function placeReverseScrollSVs(globalVars, menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local offsets = getSelectedOffsets(globalVars)
    local firstOffset = offsets[1]
    local lastOffset = offsets[#offsets]
    local timeInterval = lastOffset - firstOffset
    local noteOffsets = uniqueNoteOffsets(firstOffset, lastOffset)
    local msxSeparatingDistance = 10000
    for i = 1, #noteOffsets do
        local noteOffset = noteOffsets[i]
        local multiplier = getUsableOffsetMultiplier(noteOffset)
        local duration = 1 / multiplier
        local timeBefore = noteOffset - duration
        local timeAt = noteOffset
        local timeAfter = noteOffset + duration
        local svBefore =  multiplier * menuVars.distance + menuVars.avgSV
        local svAt = multiplier * -menuVars.distance + menuVars.avgSV
        local svAfter = menuVars.avgSV
        if i == #noteOffsets then
            svAt = (timeInterval * math.abs(menuVars.avgSV) + msxSeparatingDistance) * multiplier
            svAfter = 1
        end
        if i == 1 then
            svAt = (timeInterval * math.abs(menuVars.avgSV) + msxSeparatingDistance) * multiplier
        end
        if i ~= 1 then
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeBefore, svBefore))
        end
        table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, svAt))
        table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, svAfter))
    end
    local placeBehavior = PLACE_BEHAVIORS[globalVars.placeBehaviorIndex]
    if placeBehavior == "Replace old SVs" then
        svsToRemove = getSVsBetweenOffsets(firstOffset, lastOffset)
    end
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Places split scroll SVs 
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function placeSplitScrollSVs(globalVars, menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local isNoteOffsetFor2nd = {}
    local offsets = getSelectedOffsets(globalVars)
    for _, offset in pairs(menuVars.noteTimes2) do
        table.insert(offsets, offset)
    end
    offsets = table.sort(offsets, function(a, b) return a < b end)
    local firstOffset = offsets[1]
    local lastOffset = offsets[#offsets]
    local totalTime = lastOffset - firstOffset
    local noteOffsets = uniqueNoteOffsets(firstOffset, lastOffset)
    for _, noteOffset in pairs(menuVars.noteTimes2) do
        isNoteOffsetFor2nd[noteOffset] = true
    end
    local scrollSpeed1 = menuVars.scrollSpeed1
    local height1 = menuVars.height1
    local scrollSpeed2 = menuVars.scrollSpeed2
    local height2 = menuVars.height2
    local initialDistance = menuVars.distanceBack
    local millisecondsPerFrame = menuVars.msPerFrame
    local numFrames = math.floor((totalTime - 1) / millisecondsPerFrame)
    local noteIndex = 2
    local goingFrom1To2 = false
    local currentScrollSpeed = scrollSpeed2
    local nextScrollSpeed = scrollSpeed1
    for i = 0, numFrames do
        local timePassed = i * millisecondsPerFrame
        local timeAt = firstOffset + timePassed
        local multiplier = getUsableOffsetMultiplier(timeAt)
        local duration = 1 / multiplier
        local timeBefore = timeAt - duration
        local timeAfter = timeAt + duration
        local tpDistance = initialDistance + timePassed * (scrollSpeed1 - scrollSpeed2)
        if i == 0 then tpDistance = 0 end
        local currentHeight = height2
        if goingFrom1To2 then
            tpDistance = -tpDistance
            currentScrollSpeed = scrollSpeed1
            nextScrollSpeed = scrollSpeed2
            currentHeight = height1
        else
            currentScrollSpeed = scrollSpeed2
            nextScrollSpeed = scrollSpeed1
        end
        
        local noteOffset = noteOffsets[noteIndex]
        while noteOffset < timeAt do
            local noteMultiplier = getUsableOffsetMultiplier(noteOffset)
            local noteDuration = 1 / noteMultiplier
            local noteInOtherScroll = (isNoteOffsetFor2nd[noteOffset] and goingFrom1To2) or
                                      (not isNoteOffsetFor2nd[noteOffset] and not goingFrom1To2)
            local noteTimeBefore = noteOffset - noteDuration
            local noteTimeAt = noteOffset
            local noteTimeAfter = noteOffset + noteDuration
            local thisHeight = height1
            if isNoteOffsetFor2nd[noteOffset] then
                thisHeight = height2
            end
            local extraDisplacement = 0
            if noteInOtherScroll then
                extraDisplacement = initialDistance + (noteOffset - firstOffset) * (scrollSpeed1 - scrollSpeed2)
            end
            if goingFrom1To2 then
                extraDisplacement = -extraDisplacement
            end
            local svBefore = currentScrollSpeed + (thisHeight + extraDisplacement) * noteMultiplier
            local svAt = currentScrollSpeed - (thisHeight + extraDisplacement) * noteMultiplier
            local svAfter = currentScrollSpeed
            table.insert(svsToAdd, utils.CreateScrollVelocity(noteTimeBefore, svBefore))
            table.insert(svsToAdd, utils.CreateScrollVelocity(noteTimeAt, svAt))
            table.insert(svsToAdd, utils.CreateScrollVelocity(noteTimeAfter, svAfter))
            noteIndex = noteIndex + 1
            noteOffset = noteOffsets[noteIndex]
        end
        if noteOffset == timeAt then
            local thisHeight = height1
            if isNoteOffsetFor2nd[noteOffset] then
                thisHeight = height2
            end
            local noteInOtherScroll = (isNoteOffsetFor2nd[noteOffset] and goingFrom1To2) or
                                      (not isNoteOffsetFor2nd[noteOffset] and not goingFrom1To2)
            if noteInOtherScroll then
                table.insert(svsToAdd, utils.CreateScrollVelocity(timeBefore, currentScrollSpeed + (tpDistance + thisHeight) * multiplier))
                table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, nextScrollSpeed - thisHeight * multiplier))
                table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, nextScrollSpeed))
            else
                table.insert(svsToAdd, utils.CreateScrollVelocity(timeBefore, currentScrollSpeed + thisHeight * multiplier))
                table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, nextScrollSpeed + (tpDistance - thisHeight) * multiplier))
                table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, nextScrollSpeed))
            end
            noteIndex = noteIndex + 1
        else
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, nextScrollSpeed + tpDistance * multiplier))
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, nextScrollSpeed))
        end
        goingFrom1To2 = not goingFrom1To2
    end
    
    local noteOffset = noteOffsets[noteIndex]
    while noteOffset < lastOffset do
        local multiplier = getUsableOffsetMultiplier(noteOffset)
        local duration = 1 / multiplier
        local noteInOtherScroll = (isNoteOffsetFor2nd[noteOffset] and goingFrom1To2) or
                                  (not isNoteOffsetFor2nd[noteOffset] and not goingFrom1To2)
        local noteTimeBefore = noteOffset - duration
        local noteTimeAt = noteOffset
        local noteTimeAfter = noteOffset + duration
        local thisHeight = height1
        if isNoteOffsetFor2nd[noteOffset] then
            thisHeight = height2
        end
        local extraDisplacement = 0
        if noteInOtherScroll then
            extraDisplacement = initialDistance + (noteOffset - firstOffset) * (scrollSpeed1 - scrollSpeed2)
        end
        if goingFrom1To2 then
            extraDisplacement = -extraDisplacement
        end
        local svBefore = nextScrollSpeed + (thisHeight + extraDisplacement) * multiplier
        local svAt = nextScrollSpeed - (thisHeight + extraDisplacement) * multiplier
        local svAfter = nextScrollSpeed
        table.insert(svsToAdd, utils.CreateScrollVelocity(noteTimeBefore, svBefore))
        table.insert(svsToAdd, utils.CreateScrollVelocity(noteTimeAt, svAt))
        table.insert(svsToAdd, utils.CreateScrollVelocity(noteTimeAfter, svAfter))
        noteIndex = noteIndex + 1
        noteOffset = noteOffsets[noteIndex]
    end
    
    local multiplier = getUsableOffsetMultiplier(lastOffset)
    local duration = 1 / multiplier
    local tpDistance = initialDistance + totalTime * (scrollSpeed1 - scrollSpeed2)
    local noteInOtherScroll = (isNoteOffsetFor2nd[lastOffset] and goingFrom1To2) or
                              (not isNoteOffsetFor2nd[lastOffset] and not goingFrom1To2)
    if not goingFrom1To2 then
        if isNoteOffsetFor2nd[lastOffset] then
            table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset - duration, height2 * multiplier + scrollSpeed2))
            table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset, (tpDistance - height2) * multiplier + scrollSpeed1))
        else
            table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset - duration, (height1 + tpDistance) * multiplier + scrollSpeed2))
            table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset, -height1 * multiplier + scrollSpeed1))
        end
    else
        if isNoteOffsetFor2nd[lastOffset] then
            table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset - duration, (-tpDistance + height2) * multiplier + scrollSpeed1))
            table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset, (tpDistance - height2) * multiplier + scrollSpeed1))
        else
            table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset - duration, height1 * multiplier + scrollSpeed1))
            table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset, -height1 * multiplier + scrollSpeed1))
        end
    end
    table.insert(svsToAdd, utils.CreateScrollVelocity(lastOffset + duration, scrollSpeed1))
    local placeBehavior = PLACE_BEHAVIORS[globalVars.placeBehaviorIndex]
    if placeBehavior == "Replace old SVs" then
        svsToRemove = getSVsBetweenOffsets(firstOffset, lastOffset)
    end
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Adds selected note times to the splitscroll 2nd scroll speed list
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function addSelectedNoteTimes(menuVars)
    for _, hitObject in pairs(state.SelectedHitObjects) do
        table.insert(menuVars.noteTimes2, hitObject.StartTime)
    end
    menuVars.noteTimes2 = removeDuplicateValues(menuVars.noteTimes2)
    menuVars.noteTimes2 = table.sort(menuVars.noteTimes2, function(a, b) return a < b end)
end
-- Deletes SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function deleteSVs(globalVars)
    local offsets = getSelectedOffsets(globalVars)
    local svsToRemove = getSVsBetweenOffsets(offsets[1], offsets[#offsets])
    if #svsToRemove > 0 then actions.RemoveScrollVelocityBatch(svsToRemove) end
end
-- Adds teleport SVs 
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function addTeleportSVs(globalVars, menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local offsets = {globalVars.startOffset}
    if not globalVars.useManualOffsets then
        offsets = uniqueSelectedNoteOffsets()
    end
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local displaceAmount = menuVars.distance
    
    for i = 1, #offsets do
        local noteOffset = offsets[i]
        local multiplier = getUsableOffsetMultiplier(noteOffset)
        local duration = 1 / multiplier
        local timeAt = noteOffset
        local timeAfter = noteOffset + duration
        svTimeIsAdded[timeAt] = true
        svTimeIsAdded[timeAfter] = true
        local svMultiplierAt = getSVMultiplierAt(timeAt)
        local svMultiplierAfter = getSVMultiplierAt(timeAfter)
        local newMultiplierAt = displaceAmount * multiplier
        local newMultiplierAfter = svMultiplierAfter
        newMultiplierAt = newMultiplierAt + svMultiplierAt
        table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, newMultiplierAt))
        table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, newMultiplierAfter))
    end
    
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Copies SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function copySVs(globalVars, menuVars)
    editSVs(globalVars, menuVars, getSVsToCopy, false)
end
-- Adds flicker SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function flickerSVs(globalVars, menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local offsets = {globalVars.startOffset, globalVars.endOffset}
    if not globalVars.useManualOffsets then
        offsets = uniqueSelectedNoteOffsets()
    end
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local displaceAmount = menuVars.distance
    local numberOfTeleports =  2 * menuVars.numFlickers
    local flickerType = FLICKER_TYPES[menuVars.flickerTypeIndex]
    
    for i = 1, #offsets - 1 do
        local note1Offset = offsets[i]
        local note2Offset = offsets[i + 1]
        local multiplier = getUsableOffsetMultiplier(note2Offset)
        local duration = 1 / multiplier
        local teleportOffsets = generateLinearSet(note1Offset, note2Offset, numberOfTeleports + 1)
        for j = 1, numberOfTeleports do
            local offsetIndex = j
            if flickerType == "Delayed" then offsetIndex = offsetIndex + 1 end
            local teleportOffset = math.floor(teleportOffsets[offsetIndex])
            local timeAt = teleportOffset
            local timeAfter = teleportOffset + duration
            svTimeIsAdded[timeAt] = true
            svTimeIsAdded[timeAfter] = true
            local svMultiplierAt = getSVMultiplierAt(timeAt)
            local svMultiplierAfter = getSVMultiplierAt(timeAfter)
            local newMultiplierAt = displaceAmount * multiplier
            local newMultiplierAfter = svMultiplierAfter
            if j % 2 == 0 then newMultiplierAt = -1 * newMultiplierAt end
            newMultiplierAt = newMultiplierAt + svMultiplierAt
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, newMultiplierAt))
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, newMultiplierAfter))
        end
    end
    
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Measures SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function measureSVs(globalVars, menuVars)
    local startOffset = globalVars.startOffset
    local endOffset = globalVars.endOffset
    if not globalVars.useManualOffsets then
        local noteOffsets = uniqueSelectedNoteOffsets()
        startOffset = noteOffsets[1]
        endOffset = noteOffsets[#noteOffsets]
    end
    
    local svs = getSVsBetweenOffsets(startOffset, endOffset)
    if #svs == 0 or svs[1].StartTime ~= startOffset then
        local svMultiplierAtStartOffset = getSVMultiplierAt(startOffset)
        table.insert(svs, 1, utils.CreateScrollVelocity(startOffset, svMultiplierAtStartOffset))
    end
    
    local displacement = calculateDisplacementFromSVs(svs, endOffset)
    menuVars.measuredDistance = round(displacement, 5)
    menuVars.measuredNSVDistance = endOffset - startOffset
    menuVars.avgSV = 0
    if menuVars.measuredNSVDistance ~= 0 then
        menuVars.avgSV = round(displacement / menuVars.measuredNSVDistance, 5)
    end
end
-- Merges SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function mergeSVs(globalVars)
    editSVs(globalVars, nil, getSVsToMerge, false)
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
        local multiplier = getUsableOffsetMultiplier(noteOffset)
        local duration = 1 / multiplier
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
    
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Adds SVs that temporarily displace the playfield view
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function displaceViewSVs(globalVars, menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local offsets = {globalVars.startOffset, globalVars.endOffset}
    if not globalVars.useManualOffsets then
        local selectedOffsets = uniqueSelectedNoteOffsets()
        offsets = uniqueNoteOffsets(selectedOffsets[1], selectedOffsets[#selectedOffsets])
    end
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local displaceAmount = menuVars.distance
    
    for i = 1, #offsets - 1 do
        local note1Offset = offsets[i]
        local note2Offset = offsets[i + 1]
        local multiplier = getUsableOffsetMultiplier(note2Offset)
        local duration = 1 / multiplier
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
    local sv = map.GetScrollVelocityAt(endOffset) 
    local svExistsAtEndOffset = sv and (sv.StartTime == endOffset)
    if not svExistsAtEndOffset then
        table.insert(svsToAdd, utils.CreateScrollVelocity(endOffset, 1))
    end
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
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
    for _, sv in pairs(svs) do
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
    for _, sv in pairs(svs) do
        table.insert(svsToRemove, sv)
    end
    if svs[1].StartTime ~= startOffset then
        local multiplierAtStartOffset = getSVMultiplierAt(startOffset)
        table.insert(svs, 1, utils.CreateScrollVelocity(startOffset, multiplierAtStartOffset))
    end
    local scaleType = SCALE_TYPES[menuVars.scaleTypeIndex]
    local scalingFactor = menuVars.ratio
    if scaleType == "Average SV" then
        local svAverage = calculateAvgSV(svs, endOffset)
        scalingFactor = menuVars.avgSV / svAverage
    elseif scaleType == "Absolute Distance" then
        local distanceTraveled = calculateDisplacementFromSVs(svs, endOffset)
        scalingFactor = menuVars.distance / distanceTraveled
    end
    for _, sv in pairs(svs) do
        local newSVMultiplier = sv.Multiplier * scalingFactor
        table.insert(svsToAdd, utils.CreateScrollVelocity(sv.StartTime, newSVMultiplier))
    end
    return svsToRemove, svsToAdd
end
-- Gets SVs to copy and copies them
-- Returns SVs to remove and add (none, for copying) [Table]
-- Parameters
--    menuVars  : list of variables used for the current menu [Table]
--    svsToCopy : SVs to copy [Table]
function getSVsToCopy(menuVars, svsToCopy)
    menuVars.copiedSVs = {}
    local startOffset = svsToCopy[1].StartTime
    for _, sv in pairs(svsToCopy) do
        local relativeTime = sv.StartTime - startOffset 
        table.insert(menuVars.copiedSVs, {sv.Multiplier, relativeTime})
    end
    return {}, {}
end