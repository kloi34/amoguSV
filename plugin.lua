-- amoguSV v6.0.3 (15 January 2024)
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

-- Also, some cursor effects were inspired (stolen) from https://github.com/tholman/cursor-effects

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

----------------------------------------------------------------------------------------------- GUI

DEFAULT_WIDGET_HEIGHT = 26          -- value determining the height of GUI widgets
DEFAULT_WIDGET_WIDTH = 160          -- value determining the width of GUI widgets
PADDING_WIDTH = 8                   -- value determining window and frame padding
RADIO_BUTTON_SPACING = 7.5          -- value determining spacing between radio buttons
SAMELINE_SPACING = 5                -- value determining spacing between GUI items on the same row
ACTION_BUTTON_SIZE = {255, 42}      -- dimensions of the button that does important things
PLOT_GRAPH_SIZE = {255, 100}        -- dimensions of the plot graph for SVs and note motion
HALF_ACTION_BUTTON_SIZE = {125, 42} -- dimensions of a button that does kinda important things
SECONDARY_BUTTON_SIZE = {48, 24}    -- dimensions of a button that does less important things
EXPORT_BUTTON_SIZE = {40, 24}       -- dimensions of the export menu settings button

------------------------------------------------------------------------------- Number restrictions

MIN_RGB_CYCLE_TIME = 6              -- minimum seconds for one complete RGB color cycle
MAX_RGB_CYCLE_TIME = 300            -- maximum seconds for one complete RGB color cycle
MAX_CURSOR_TRAIL_POINTS = 100       -- maximum number of points for cursor trail effects
MAX_SV_POINTS = 1000                -- maximum number of SV points allowed

-------------------------------------------------------------------------------------- Menu related

COLOR_THEMES = {                    -- available color themes for the plugin
    "Classic",
    "Strawberry",
    "Amethyst",
    "Tree",
    "Barbie",
    "Incognito",
    "Incognito + RGB",
    "Tobi's Glass",
    "Tobi's RGB Glass",
    "Glass",
    "Glass + RGB",
    "RGB Gamer Mode",
    "edom remag BGR",
    "BGR + otingocnI",
    "otingocnI"
}
COMBO_SV_TYPE = {                   -- options for overlapping combo SVs
    "Add",
    "Cross Multiply",
    "Remove",
    "Min",
    "Max"
}
CURSOR_TRAILS = {                   -- available cursor trail types
    "None",
    "Snake",
    "Dust",
    "Sparkle"
}
DISPLACE_SCALE_SPOTS = {            -- places to scale SV sections by displacing
    "Start",
    "End"
}
EDIT_SV_TOOLS = {                   -- tools for editing SVs
    "Add Teleport",
    "Copy & Paste",
    "Displace Note",
    "Displace View",
    "Fix LN Ends",
    "Flicker",
    "Measure",
    "Merge",
    "Reverse Scroll",
    "Scale (Displace)",
    "Scale (Multiply)",
    "Swap Notes"
}
EMOTICONS = {                       -- emoticons to visually clutter the plugin and confuse users
    "( - _ - )",
    "( e . e )",
    "( * o * )",
    "( h . m )",
    "( ~ _ ~ )",
    "( C | D )",
    "( w . w )",
    "( ^ w ^ )",
    "( + x + )",
    "( o _ 0 )",
    "[mwm]",
    "( > . < )",
    "( v . ^ )",
    "( ^ o v )",
    "( ; A ; )"
}
FINAL_SV_TYPES = {                  -- options for the last SV placed at the tail end of all SVs
    "Normal",
    "Custom"
}
FLICKER_TYPES = {                   -- types of flickers
    "Normal",
    "Delayed"
}
PLACE_TYPES = {                     -- general categories of SVs to place
    "Standard",
    "Special",
    "Still"
}
RANDOM_TYPES = {                    -- distribution types of random values
    "Normal",
    "Uniform"
}
SCALE_TYPES = {                     -- ways to scale SVs
    "Average SV",
    "Absolute Distance",
    "Relative Ratio"
}
SPECIAL_SVS = {                     -- types of special SVs
    "Stutter",
    "Teleport Stutter",
    "Splitscroll (Basic)",
    "Splitscroll (Advanced)"
}
STANDARD_SVS = {                    -- types of standard SVs
    "Linear",
    "Exponential",
    "Bezier",
    "Hermite",
    "Sinusoidal",
    "Circular",
    "Random",
    "Custom",
    "Combo"
}
STANDARD_SVS_COMBOLESS = {          -- types of standard SVs (excluding combo)
    "Linear",
    "Exponential",
    "Bezier",
    "Hermite",
    "Sinusoidal",
    "Circular",
    "Random",
    "Custom"
}
STILL_TYPES = {                     -- types of still displacements
    "No",
    "Start",
    "End",
    "Auto",
    "Otua"
}
STYLE_THEMES = {                    -- available style/appearance themes for the plugin
    "Rounded",
    "Boxed",
    "Rounded + Border",
    "Boxed + Border"
}
SV_BEHAVIORS = {                    -- behaviors of SVs
    "Slow down",
    "Speed up"
}
TAB_MENUS = {                       -- names of the tab menus
    "Info",
    "Place SVs",
    "Edit SVs",
    "Delete SVs"
}
TRAIL_SHAPES = {                    -- shapes for cursor trails
    "Circles",
    "Triangles"
}

---------------------------------------------------------------------------------------------------
-- Plugin Appearance, Styles and Colors -----------------------------------------------------------
---------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------- Main plugin GUI

-- Configures the plugin GUI appearance
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function setPluginAppearance(globalVars)
    local colorTheme = COLOR_THEMES[globalVars.colorThemeIndex]
    local styleTheme = STYLE_THEMES[globalVars.styleThemeIndex]
    
    setPluginAppearanceStyles(styleTheme)
    setPluginAppearanceColors(colorTheme, globalVars.rgbPeriod)
end
-- Configures the plugin GUI styles
-- Parameters
--    styleTheme : name of the desired style theme [String]
function setPluginAppearanceStyles(styleTheme)
    local cornerRoundnessValue = 5 -- up to 12, 14 for WindowRounding and 16 for ChildRounding
    local boxed = styleTheme == "Boxed" or
                  styleTheme == "Boxed + Border"
    if boxed then cornerRoundnessValue = 0 end
    
    local borderSize = 0
    local hasBorder = styleTheme == "Rounded + Border" or
                      styleTheme == "Boxed + Border"
    if hasBorder then borderSize = 1 end
    
    imgui.PushStyleVar( imgui_style_var.FrameBorderSize,    borderSize              )
    imgui.PushStyleVar( imgui_style_var.WindowPadding,      { PADDING_WIDTH, 8 }    )
    imgui.PushStyleVar( imgui_style_var.FramePadding,       { PADDING_WIDTH, 5 }    )
    imgui.PushStyleVar( imgui_style_var.ItemSpacing,        { 12, 4 }               )
    imgui.PushStyleVar( imgui_style_var.ItemInnerSpacing,   { SAMELINE_SPACING, 6 } )
    imgui.PushStyleVar( imgui_style_var.WindowRounding,     cornerRoundnessValue    )
    imgui.PushStyleVar( imgui_style_var.ChildRounding,      cornerRoundnessValue    )
    imgui.PushStyleVar( imgui_style_var.FrameRounding,      cornerRoundnessValue    )
    imgui.PushStyleVar( imgui_style_var.GrabRounding,       cornerRoundnessValue    )
    imgui.PushStyleVar( imgui_style_var.ScrollbarRounding,  cornerRoundnessValue    )
    imgui.PushStyleVar( imgui_style_var.TabRounding,        cornerRoundnessValue    )
    
    -- TabBorderSize not working? Doesn't exist? But it's changeable in the style editor demo?
    -- imgui.PushStyleVar( imgui_style_var.TabBorderSize,      borderSize              ) 
end
-- Configures the plugin GUI colors
-- Parameters
--    colorTheme : currently selected color theme [String]
--    rgbPeriod  : length in seconds of one RGB color cycle [Int/Float]
function setPluginAppearanceColors(colorTheme, rgbPeriod)
    if colorTheme == "Classic"          then setClassicColors() end
    if colorTheme == "Strawberry"       then setStrawberryColors() end
    if colorTheme == "Amethyst"         then setAmethystColors() end
    if colorTheme == "Tree"             then setTreeColors() end
    if colorTheme == "Barbie"           then setBarbieColors() end
    if colorTheme == "Incognito"        then setIncognitoColors() end
    if colorTheme == "Incognito + RGB"  then setIncognitoRGBColors(rgbPeriod) end
    if colorTheme == "Tobi's Glass"     then setTobiGlassColors() end
    if colorTheme == "Tobi's RGB Glass" then setTobiRGBGlassColors(rgbPeriod) end
    if colorTheme == "Glass"            then setGlassColors() end
    if colorTheme == "Glass + RGB"      then setGlassRGBColors(rgbPeriod) end
    if colorTheme == "RGB Gamer Mode"   then setRGBGamerColors(rgbPeriod) end
    if colorTheme == "edom remag BGR"   then setInvertedRGBGamerColors(rgbPeriod) end
    if colorTheme == "BGR + otingocnI"  then setInvertedIncognitoRGBColors(rgbPeriod) end
    if colorTheme == "otingocnI"        then setInvertedIncognitoColors() end
end
-- Sets plugin colors to the "Classic" theme
function setClassicColors()
    imgui.PushStyleColor( imgui_col.WindowBg,               { 0.00, 0.00, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
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
    imgui.PushStyleColor( imgui_col.Text,                   { 1.00, 1.00, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 0.81, 0.88, 1.00, 0.40 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          { 0.31, 0.38, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   { 0.41, 0.48, 0.60, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    { 0.51, 0.58, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLines,              { 0.61, 0.61, 0.61, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 1.00, 0.43, 0.35, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          { 0.90, 0.70, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 1.00, 0.60, 0.00, 1.00 } )
end
-- Sets plugin colors to the "Strawberry" theme 
function setStrawberryColors()
    imgui.PushStyleColor( imgui_col.WindowBg,               { 0.00, 0.00, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
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
    imgui.PushStyleColor( imgui_col.Text,                   { 1.00, 1.00, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 1.00, 0.81, 0.88, 0.40 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          { 0.50, 0.31, 0.38, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   { 0.60, 0.41, 0.48, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    { 0.70, 0.51, 0.58, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLines,              { 0.61, 0.61, 0.61, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 1.00, 0.43, 0.35, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          { 0.90, 0.70, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 1.00, 0.60, 0.00, 1.00 } )
end
-- Sets plugin colors to the "Amethyst" theme 
function setAmethystColors()
    imgui.PushStyleColor( imgui_col.WindowBg,               { 0.16, 0.00, 0.20, 1.00 } )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 { 0.90, 0.00, 0.81, 0.30 } )
    imgui.PushStyleColor( imgui_col.FrameBg,                { 0.40, 0.20, 0.40, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         { 0.50, 0.30, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          { 0.55, 0.35, 0.55, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBg,                { 0.31, 0.11, 0.35, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          { 0.41, 0.21, 0.45, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       { 0.41, 0.21, 0.45, 0.50 } )
    imgui.PushStyleColor( imgui_col.CheckMark,              { 1.00, 0.80, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrab,             { 0.95, 0.75, 0.95, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       { 1.00, 0.80, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.Button,                 { 0.60, 0.40, 0.60, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          { 0.70, 0.50, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonActive,           { 0.80, 0.60, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.Tab,                    { 0.50, 0.30, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabHovered,             { 0.70, 0.50, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabActive,              { 0.70, 0.50, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.Header,                 { 1.00, 0.80, 1.00, 0.40 } )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          { 1.00, 0.80, 1.00, 0.50 } )
    imgui.PushStyleColor( imgui_col.HeaderActive,           { 1.00, 0.80, 1.00, 0.54 } )
    imgui.PushStyleColor( imgui_col.Separator,              { 1.00, 0.80, 1.00, 0.30 } )
    imgui.PushStyleColor( imgui_col.Text,                   { 1.00, 1.00, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 1.00, 0.80, 1.00, 0.40 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          { 0.60, 0.40, 0.60, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   { 0.70, 0.50, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    { 0.80, 0.60, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLines,              { 1.00, 0.80, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 1.00, 0.70, 0.30, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          { 1.00, 0.80, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 1.00, 0.70, 0.30, 1.00 } )
end
-- Sets plugin colors to the "Tree" theme 
function setTreeColors()
    imgui.PushStyleColor( imgui_col.WindowBg,               { 0.20, 0.16, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 { 0.81, 0.90, 0.00, 0.30 } )
    imgui.PushStyleColor( imgui_col.FrameBg,                { 0.40, 0.40, 0.20, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         { 0.50, 0.50, 0.30, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          { 0.55, 0.55, 0.35, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBg,                { 0.35, 0.31, 0.11, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          { 0.45, 0.41, 0.21, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       { 0.45, 0.41, 0.21, 0.50 } )
    imgui.PushStyleColor( imgui_col.CheckMark,              { 1.00, 1.00, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrab,             { 0.95, 0.95, 0.75, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       { 1.00, 1.00, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.Button,                 { 0.60, 0.60, 0.40, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          { 0.70, 0.70, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonActive,           { 0.80, 0.80, 0.60, 1.00 } )
    imgui.PushStyleColor( imgui_col.Tab,                    { 0.50, 0.50, 0.30, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabHovered,             { 0.70, 0.70, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabActive,              { 0.70, 0.70, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.Header,                 { 1.00, 1.00, 0.80, 0.40 } )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          { 1.00, 1.00, 0.80, 0.50 } )
    imgui.PushStyleColor( imgui_col.HeaderActive,           { 1.00, 1.00, 0.80, 0.54 } )
    imgui.PushStyleColor( imgui_col.Separator,              { 1.00, 1.00, 0.80, 0.30 } )
    imgui.PushStyleColor( imgui_col.Text,                   { 1.00, 1.00, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 1.00, 1.00, 0.80, 0.40 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          { 0.60, 0.60, 0.40, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   { 0.70, 0.70, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    { 0.80, 0.80, 0.60, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLines,              { 1.00, 1.00, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 0.30, 1.00, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          { 1.00, 1.00, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 0.30, 1.00, 0.70, 1.00 } )
end
-- Sets plugin colors to the "Barbie" theme 
function setBarbieColors()
    local pink = {0.79, 0.31, 0.55, 1.00}
    local white = {0.95, 0.85, 0.87, 1.00}
    local blue = {0.37, 0.64, 0.84, 1.00}
    local pinkTint = {1.00, 0.86, 0.86, 0.40}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               pink     )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 pinkTint )
    imgui.PushStyleColor( imgui_col.FrameBg,                blue     )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         pinkTint )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          pinkTint )
    imgui.PushStyleColor( imgui_col.TitleBg,                blue     )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          blue     )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       pink     )
    imgui.PushStyleColor( imgui_col.CheckMark,              blue     )
    imgui.PushStyleColor( imgui_col.SliderGrab,             blue     )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       pinkTint )
    imgui.PushStyleColor( imgui_col.Button,                 blue     )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          pinkTint )
    imgui.PushStyleColor( imgui_col.ButtonActive,           pinkTint )
    imgui.PushStyleColor( imgui_col.Tab,                    blue     )
    imgui.PushStyleColor( imgui_col.TabHovered,             pinkTint )
    imgui.PushStyleColor( imgui_col.TabActive,              pinkTint )
    imgui.PushStyleColor( imgui_col.Header,                 blue     )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          pinkTint )
    imgui.PushStyleColor( imgui_col.HeaderActive,           pinkTint )
    imgui.PushStyleColor( imgui_col.Separator,              pinkTint )
    imgui.PushStyleColor( imgui_col.Text,                   white    )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         pinkTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          pinkTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   white    )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    white    )
    imgui.PushStyleColor( imgui_col.PlotLines,              pink     )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       pinkTint )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          pink     )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   pinkTint )
end
-- Sets plugin colors to the "Incognito" theme 
function setIncognitoColors()
    local black = {0.00, 0.00, 0.00, 1.00}
    local white = {1.00, 1.00, 1.00, 1.00}
    local grey = {0.20, 0.20, 0.20, 1.00}
    local whiteTint = {1.00, 1.00, 1.00, 0.40}
    local red = {1.00, 0.00, 0.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               black     )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 whiteTint )
    imgui.PushStyleColor( imgui_col.FrameBg,                grey      )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         whiteTint )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          whiteTint )
    imgui.PushStyleColor( imgui_col.TitleBg,                grey      )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          grey      )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       black     )
    imgui.PushStyleColor( imgui_col.CheckMark,              white     )
    imgui.PushStyleColor( imgui_col.SliderGrab,             grey      )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       whiteTint )
    imgui.PushStyleColor( imgui_col.Button,                 grey      )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          whiteTint )
    imgui.PushStyleColor( imgui_col.ButtonActive,           whiteTint )
    imgui.PushStyleColor( imgui_col.Tab,                    grey      )
    imgui.PushStyleColor( imgui_col.TabHovered,             whiteTint )
    imgui.PushStyleColor( imgui_col.TabActive,              whiteTint )
    imgui.PushStyleColor( imgui_col.Header,                 grey      )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          whiteTint )
    imgui.PushStyleColor( imgui_col.HeaderActive,           whiteTint )
    imgui.PushStyleColor( imgui_col.Separator,              whiteTint )
    imgui.PushStyleColor( imgui_col.Text,                   white     )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         whiteTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          whiteTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   white     )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    white     )
    imgui.PushStyleColor( imgui_col.PlotLines,              white     )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       red       )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          white     )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   red       )
end
-- Sets plugin colors to the "Incognito + RGB" theme 
-- Parameters
--    rgbPeriod : length in seconds of one RGB color cycle [Int/Float]
function setIncognitoRGBColors(rgbPeriod)
    local black = {0.00, 0.00, 0.00, 1.00}
    local white = {1.00, 1.00, 1.00, 1.00}
    local grey = {0.20, 0.20, 0.20, 1.00}
    local whiteTint = {1.00, 1.00, 1.00, 0.40}
    local currentRGB = getCurrentRGBColors(rgbPeriod)
    local rgbColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               black     )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 rgbColor  )
    imgui.PushStyleColor( imgui_col.FrameBg,                grey      )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         whiteTint )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          rgbColor  )
    imgui.PushStyleColor( imgui_col.TitleBg,                grey      )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          grey      )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       black     )
    imgui.PushStyleColor( imgui_col.CheckMark,              white     )
    imgui.PushStyleColor( imgui_col.SliderGrab,             grey      )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       rgbColor  )
    imgui.PushStyleColor( imgui_col.Button,                 grey      )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          whiteTint )
    imgui.PushStyleColor( imgui_col.ButtonActive,           rgbColor  )
    imgui.PushStyleColor( imgui_col.Tab,                    grey      )
    imgui.PushStyleColor( imgui_col.TabHovered,             whiteTint )
    imgui.PushStyleColor( imgui_col.TabActive,              rgbColor  )
    imgui.PushStyleColor( imgui_col.Header,                 grey      )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          whiteTint )
    imgui.PushStyleColor( imgui_col.HeaderActive,           rgbColor  )
    imgui.PushStyleColor( imgui_col.Separator,              rgbColor  )
    imgui.PushStyleColor( imgui_col.Text,                   white     )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         rgbColor  )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          whiteTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   white     )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    rgbColor  )
    imgui.PushStyleColor( imgui_col.PlotLines,              white     )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       rgbColor  )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          white     )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   rgbColor  )
end
-- Sets plugin colors to the "Tobi's Glass" theme
function setTobiGlassColors()
    local transparentBlack = {0.00, 0.00, 0.00, 0.70}
    local transparentWhite = {0.30, 0.30, 0.30, 0.50}
    local whiteTint = {1.00, 1.00, 1.00, 0.30}
    local buttonColor = {0.14, 0.24, 0.28, 0.80}
    local frameColor = {0.24, 0.34, 0.38, 1.00}
    local white = {1.00, 1.00, 1.00, 1.00}  

    imgui.PushStyleColor( imgui_col.WindowBg,               transparentBlack )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 frameColor       )
    imgui.PushStyleColor( imgui_col.FrameBg,                buttonColor      )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         whiteTint        )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          whiteTint        )
    imgui.PushStyleColor( imgui_col.TitleBg,                transparentBlack )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          transparentBlack )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       transparentBlack )
    imgui.PushStyleColor( imgui_col.CheckMark,              white            )
    imgui.PushStyleColor( imgui_col.SliderGrab,             whiteTint        )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       transparentWhite )
    imgui.PushStyleColor( imgui_col.Button,                 buttonColor      )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          whiteTint        )
    imgui.PushStyleColor( imgui_col.ButtonActive,           whiteTint        )
    imgui.PushStyleColor( imgui_col.Tab,                    transparentBlack )
    imgui.PushStyleColor( imgui_col.TabHovered,             whiteTint        )
    imgui.PushStyleColor( imgui_col.TabActive,              whiteTint        )
    imgui.PushStyleColor( imgui_col.Header,                 transparentBlack )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          whiteTint        )
    imgui.PushStyleColor( imgui_col.HeaderActive,           whiteTint        )
    imgui.PushStyleColor( imgui_col.Separator,              whiteTint        )
    imgui.PushStyleColor( imgui_col.Text,                   white            )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         whiteTint        )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          whiteTint        )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   transparentWhite )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    transparentWhite )
    imgui.PushStyleColor( imgui_col.PlotLines,              whiteTint        )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       transparentWhite )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          whiteTint        )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   transparentWhite )
end
-- Sets plugin colors to the "Tobi's RGB Glass" theme 
-- Parameters
--    rgbPeriod : length in seconds of one RGB color cycle [Int/Float]
function setTobiRGBGlassColors(rgbPeriod)
    local transparent = {0.00, 0.00, 0.00, 0.85}
    local white = {1.00, 1.00, 1.00, 1.00}
    local currentRGB = getCurrentRGBColors(rgbPeriod)
    local activeColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
    local colorTint = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.3}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               transparent )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
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
    imgui.PushStyleColor( imgui_col.Text,                   white       )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         colorTint   )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          colorTint   )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   activeColor )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    activeColor )
    imgui.PushStyleColor( imgui_col.PlotLines,              activeColor )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       colorTint   )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          activeColor )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   colorTint   )
end
-- Sets plugin colors to the "Glass" theme 
function setGlassColors()
    local transparentBlack = {0.00, 0.00, 0.00, 0.25}
    local transparentWhite = {1.00, 1.00, 1.00, 0.70}
    local whiteTint = {1.00, 1.00, 1.00, 0.30}
    local white = {1.00, 1.00, 1.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               transparentBlack )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 transparentWhite )
    imgui.PushStyleColor( imgui_col.FrameBg,                transparentBlack )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         whiteTint        )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          whiteTint        )
    imgui.PushStyleColor( imgui_col.TitleBg,                transparentBlack )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          transparentBlack )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       transparentBlack )
    imgui.PushStyleColor( imgui_col.CheckMark,              transparentWhite )
    imgui.PushStyleColor( imgui_col.SliderGrab,             whiteTint        )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       transparentWhite )
    imgui.PushStyleColor( imgui_col.Button,                 transparentBlack )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          whiteTint        )
    imgui.PushStyleColor( imgui_col.ButtonActive,           whiteTint        )
    imgui.PushStyleColor( imgui_col.Tab,                    transparentBlack )
    imgui.PushStyleColor( imgui_col.TabHovered,             whiteTint        )
    imgui.PushStyleColor( imgui_col.TabActive,              whiteTint        )
    imgui.PushStyleColor( imgui_col.Header,                 transparentBlack )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          whiteTint        )
    imgui.PushStyleColor( imgui_col.HeaderActive,           whiteTint        )
    imgui.PushStyleColor( imgui_col.Separator,              whiteTint        )
    imgui.PushStyleColor( imgui_col.Text,                   white            )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         whiteTint        )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          whiteTint        )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   transparentWhite )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    transparentWhite )
    imgui.PushStyleColor( imgui_col.PlotLines,              whiteTint        )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       transparentWhite )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          whiteTint        )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   transparentWhite )
end
-- Sets plugin colors to the "Glass + RGB" theme 
-- Parameters
--    rgbPeriod : length in seconds of one RGB color cycle [Int/Float]
function setGlassRGBColors(rgbPeriod)
    local currentRGB = getCurrentRGBColors(rgbPeriod)
    local activeColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
    local colorTint = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.3}
    local transparent = {0.00, 0.00, 0.00, 0.25}
    local white = {1.00, 1.00, 1.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               transparent )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
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
    imgui.PushStyleColor( imgui_col.Text,                   white       )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         colorTint   )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          colorTint   )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   activeColor )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    activeColor )
    imgui.PushStyleColor( imgui_col.PlotLines,              activeColor )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       colorTint   )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          activeColor )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   colorTint   )
end
-- Sets plugin colors to the "RGB Gamer Mode" theme 
-- Parameters
--    rgbPeriod : length in seconds of one RGB color cycle [Int/Float]
function setRGBGamerColors(rgbPeriod)
    local currentRGB = getCurrentRGBColors(rgbPeriod)
    local activeColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
    local inactiveColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.5}
    local white = {1.00, 1.00, 1.00, 1.00}
    local clearWhite = {1.00, 1.00, 1.00, 0.40}
    local black = {0.00, 0.00, 0.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               black         )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
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
    imgui.PushStyleColor( imgui_col.Text,                   white         )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         clearWhite    )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          inactiveColor )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   activeColor   )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    activeColor   )
    imgui.PushStyleColor( imgui_col.PlotLines,              { 0.61, 0.61, 0.61, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 1.00, 0.43, 0.35, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          { 0.90, 0.70, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 1.00, 0.60, 0.00, 1.00 } )
end
-- Sets plugin colors to the "edom remag BGR" theme 
-- Parameters
--    rgbPeriod : length in seconds of one RGB color cycle [Int/Float]
function setInvertedRGBGamerColors(rgbPeriod)
    local currentRGB = getCurrentRGBColors(rgbPeriod)
    local activeColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
    local inactiveColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.5}
    local white = {1.00, 1.00, 1.00, 1.00}
    local clearBlack = {0.00, 0.00, 0.00, 0.40}
    local black = {0.00, 0.00, 0.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               white         )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.92, 0.92, 0.92, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 inactiveColor )
    imgui.PushStyleColor( imgui_col.FrameBg,                inactiveColor )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         activeColor   )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          activeColor   )
    imgui.PushStyleColor( imgui_col.TitleBg,                inactiveColor )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          activeColor   )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       inactiveColor )
    imgui.PushStyleColor( imgui_col.CheckMark,              black         )
    imgui.PushStyleColor( imgui_col.SliderGrab,             activeColor   )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       black         )
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
    imgui.PushStyleColor( imgui_col.Text,                   black         )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         clearBlack    )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          inactiveColor )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   activeColor   )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    activeColor   )
    imgui.PushStyleColor( imgui_col.PlotLines,              { 0.39, 0.39, 0.39, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 0.00, 0.57, 0.65, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          { 0.10, 0.30, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 0.00, 0.40, 1.00, 1.00 } )
end
-- Sets plugin colors to the "BGR + otingocnI" theme
-- Parameters
--    rgbPeriod : length in seconds of one RGB color cycle [Int/Float]
function setInvertedIncognitoRGBColors(rgbPeriod)
    local black = {0.00, 0.00, 0.00, 1.00}
    local white = {1.00, 1.00, 1.00, 1.00}
    local grey = {0.80, 0.80, 0.80, 1.00}
    local blackTint = {0.00, 0.00, 0.00, 0.40}
    local currentRGB = getCurrentRGBColors(rgbPeriod)
    local rgbColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               white     )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.92, 0.92, 0.92, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 rgbColor  )
    imgui.PushStyleColor( imgui_col.FrameBg,                grey      )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         blackTint )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          rgbColor  )
    imgui.PushStyleColor( imgui_col.TitleBg,                grey      )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          grey      )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       white     )
    imgui.PushStyleColor( imgui_col.CheckMark,              black     )
    imgui.PushStyleColor( imgui_col.SliderGrab,             grey      )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       rgbColor  )
    imgui.PushStyleColor( imgui_col.Button,                 grey      )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          blackTint )
    imgui.PushStyleColor( imgui_col.ButtonActive,           rgbColor  )
    imgui.PushStyleColor( imgui_col.Tab,                    grey      )
    imgui.PushStyleColor( imgui_col.TabHovered,             blackTint )
    imgui.PushStyleColor( imgui_col.TabActive,              rgbColor  )
    imgui.PushStyleColor( imgui_col.Header,                 grey      )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          blackTint )
    imgui.PushStyleColor( imgui_col.HeaderActive,           rgbColor  )
    imgui.PushStyleColor( imgui_col.Separator,              rgbColor  )
    imgui.PushStyleColor( imgui_col.Text,                   black     )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         rgbColor  )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          blackTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   black     )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    rgbColor  )
    imgui.PushStyleColor( imgui_col.PlotLines,              black     )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       rgbColor  )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          black     )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   rgbColor  )
end
-- Sets plugin colors to the "otingocnI" theme
function setInvertedIncognitoColors()
    local black = {0.00, 0.00, 0.00, 1.00}
    local white = {1.00, 1.00, 1.00, 1.00}
    local grey = {0.80, 0.80, 0.80, 1.00}
    local blackTint = {0.00, 0.00, 0.00, 0.40}
    local notRed = {0.00, 1.00, 1.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               white     )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.92, 0.92, 0.92, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 blackTint )
    imgui.PushStyleColor( imgui_col.FrameBg,                grey      )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         blackTint )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          blackTint )
    imgui.PushStyleColor( imgui_col.TitleBg,                grey      )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          grey      )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       white     )
    imgui.PushStyleColor( imgui_col.CheckMark,              black     )
    imgui.PushStyleColor( imgui_col.SliderGrab,             grey      )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       blackTint )
    imgui.PushStyleColor( imgui_col.Button,                 grey      )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          blackTint )
    imgui.PushStyleColor( imgui_col.ButtonActive,           blackTint )
    imgui.PushStyleColor( imgui_col.Tab,                    grey      )
    imgui.PushStyleColor( imgui_col.TabHovered,             blackTint )
    imgui.PushStyleColor( imgui_col.TabActive,              blackTint )
    imgui.PushStyleColor( imgui_col.Header,                 grey      )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          blackTint )
    imgui.PushStyleColor( imgui_col.HeaderActive,           blackTint )
    imgui.PushStyleColor( imgui_col.Separator,              blackTint )
    imgui.PushStyleColor( imgui_col.Text,                   black     )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         blackTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          blackTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   black     )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    black     )
    imgui.PushStyleColor( imgui_col.PlotLines,              black     )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       notRed    )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          black     )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   notRed    )
end
-- Returns the RGB colors based on the current time [Table]
-- Parameters
--    rgbPeriod : length in seconds for one complete RGB cycle (i.e. period) [Int/Float]
function getCurrentRGBColors(rgbPeriod)
    local currentTime = imgui.GetTime()
    local percentIntoRGBCycle = (currentTime % rgbPeriod) / rgbPeriod
    local stagesElapsed = 6 * percentIntoRGBCycle
    local currentStageNumber = math.floor(stagesElapsed)
    local percentIntoStage = clampToInterval(stagesElapsed - currentStageNumber, 0, 1)
    
    local red = 0 
    local green = 0
    local blue = 0
    if currentStageNumber == 0 then
        green = 1 - percentIntoStage
        blue = 1
    elseif currentStageNumber == 1 then
        blue = 1
        red = percentIntoStage
    elseif currentStageNumber == 2 then
        blue = 1 - percentIntoStage
        red = 1
    elseif currentStageNumber == 3 then
        green = percentIntoStage
        red = 1
    elseif currentStageNumber == 4 then
        green = 1
        red = 1 - percentIntoStage
    else
        blue = percentIntoStage
        green = 1
    end
    return {red = red, green = green, blue = blue}
end

------------------------------------------------------------------------------------------- Drawing

-- Draws a capybara on the bottom right of the screen
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function drawCapybara(globalVars)
    if not globalVars.drawCapybara then return end
    local o = imgui.GetOverlayDrawList()
    local sz = state.WindowSize
    local headWidth = 50
    local headRadius = 20
    local eyeWidth = 10
    local eyeRadius = 3
    local earRadius = 12
    local headCoords1 = relativePoint(sz, -100, -100)
    local headCoords2 = relativePoint(headCoords1, -headWidth, 0)
    local eyeCoords1 = relativePoint(headCoords1, -10, -10)
    local eyeCoords2 = relativePoint(eyeCoords1, -eyeWidth, 0)
    local earCoords = relativePoint(headCoords1, 12, -headRadius + 5)
    local brownBodyColor = rgbaToUint(220, 150, 80, 255)
    local blackEyeColor = rgbaToUint(30, 20, 35, 255)
    local darkBrownEarColor = rgbaToUint(150, 100, 50, 255)
    -- draws capybara ear
    o.AddCircleFilled(earCoords, earRadius, darkBrownEarColor)
    -- draws capybara head
    drawHorizontalPillShape(o, headCoords1, headCoords2, headRadius, brownBodyColor, 12)
    -- draw capybara eyes
    drawHorizontalPillShape(o, eyeCoords1, eyeCoords2, eyeRadius, blackEyeColor, 12)
    -- draws capybara body
    o.AddRectFilled(sz, headCoords1, brownBodyColor)
end
-- Draws a capybara on the bottom left of the screen
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function drawCapybara2(globalVars)
    if not globalVars.drawCapybara2 then return end
    local o = imgui.GetOverlayDrawList()
    local sz = state.WindowSize
    
    local topLeftCapyPoint = {0, sz[2] - 165} -- originally -200
    local p1 = relativePoint(topLeftCapyPoint, 0, 95)
    local p2 = relativePoint(topLeftCapyPoint, 0, 165)
    local p3 = relativePoint(topLeftCapyPoint, 58, 82)
    local p3b = relativePoint(topLeftCapyPoint, 108, 82)
    local p4 = relativePoint(topLeftCapyPoint, 58, 165)
    local p5 = relativePoint(topLeftCapyPoint, 66, 29)
    local p6 = relativePoint(topLeftCapyPoint, 105, 10)
    local p7 = relativePoint(topLeftCapyPoint, 122, 126)
    local p7b = relativePoint(topLeftCapyPoint, 133, 107)
    local p8 = relativePoint(topLeftCapyPoint, 138, 11)
    local p9 = relativePoint(topLeftCapyPoint, 145, 82)
    local p10 = relativePoint(topLeftCapyPoint, 167, 82)
    local p10b = relativePoint(topLeftCapyPoint, 172, 80)
    local p11 = relativePoint(topLeftCapyPoint, 172, 50)
    local p12 = relativePoint(topLeftCapyPoint, 179, 76)
    local p12b = relativePoint(topLeftCapyPoint, 176, 78)
    local p12c = relativePoint(topLeftCapyPoint, 176, 70)
    local p13 = relativePoint(topLeftCapyPoint, 185, 50)
    
    local p14 = relativePoint(topLeftCapyPoint, 113, 10)
    local p15 = relativePoint(topLeftCapyPoint, 116, 0)
    local p16 = relativePoint(topLeftCapyPoint, 125, 2)
    local p17 = relativePoint(topLeftCapyPoint, 129, 11)
    local p17b = relativePoint(topLeftCapyPoint, 125, 11)
    
    local p18 = relativePoint(topLeftCapyPoint, 91, 0)
    local p19 = relativePoint(topLeftCapyPoint, 97, 0)
    local p20 = relativePoint(topLeftCapyPoint, 102, 1)
    local p21 = relativePoint(topLeftCapyPoint, 107, 11)
    local p22 = relativePoint(topLeftCapyPoint, 107, 19)
    local p23 = relativePoint(topLeftCapyPoint, 103, 24)
    local p24 = relativePoint(topLeftCapyPoint, 94, 17)
    local p25 = relativePoint(topLeftCapyPoint, 88, 9)
    
    local p26 = relativePoint(topLeftCapyPoint, 123, 33)
    local p27 = relativePoint(topLeftCapyPoint, 132, 30)
    local p28 = relativePoint(topLeftCapyPoint, 138, 38)
    local p29 = relativePoint(topLeftCapyPoint, 128, 40)
    
    local p30 = relativePoint(topLeftCapyPoint, 102, 133)
    local p31 = relativePoint(topLeftCapyPoint, 105, 165)
    local p32 = relativePoint(topLeftCapyPoint, 113, 165)
    
    local p33 = relativePoint(topLeftCapyPoint, 102, 131)
    local p34 = relativePoint(topLeftCapyPoint, 82, 138)
    local p35 = relativePoint(topLeftCapyPoint, 85, 165)
    local p36 = relativePoint(topLeftCapyPoint, 93, 165)
    
    local p37 = relativePoint(topLeftCapyPoint, 50, 80)
    local p38 = relativePoint(topLeftCapyPoint, 80, 40)
    local p39 = relativePoint(topLeftCapyPoint, 115, 30)
    local p40 = relativePoint(topLeftCapyPoint, 40, 92)
    local p41 = relativePoint(topLeftCapyPoint, 80, 53)
    local p42 = relativePoint(topLeftCapyPoint, 107, 43)
    local p43 = relativePoint(topLeftCapyPoint, 40, 104)
    local p44 = relativePoint(topLeftCapyPoint, 70, 56)
    local p45 = relativePoint(topLeftCapyPoint, 100, 53)
    local p46 = relativePoint(topLeftCapyPoint, 45, 134)
    local p47 = relativePoint(topLeftCapyPoint, 50, 80)
    local p48 = relativePoint(topLeftCapyPoint, 70, 87)
    local p49 = relativePoint(topLeftCapyPoint, 54, 104)
    local p50 = relativePoint(topLeftCapyPoint, 50, 156)
    local p51 = relativePoint(topLeftCapyPoint, 79, 113)
    local p52 = relativePoint(topLeftCapyPoint, 55, 24)
    local p53 = relativePoint(topLeftCapyPoint, 85, 25)
    local p54 = relativePoint(topLeftCapyPoint, 91, 16)
    local p55 = relativePoint(topLeftCapyPoint, 45, 33)
    local p56 = relativePoint(topLeftCapyPoint, 75, 36)
    local p57 = relativePoint(topLeftCapyPoint, 81, 22)
    local p58 = relativePoint(topLeftCapyPoint, 45, 43)
    local p59 = relativePoint(topLeftCapyPoint, 73, 38)
    local p60 = relativePoint(topLeftCapyPoint, 61, 32)
    local p61 = relativePoint(topLeftCapyPoint, 33, 55)
    local p62 = relativePoint(topLeftCapyPoint, 73, 45)
    local p63 = relativePoint(topLeftCapyPoint, 55, 36)
    local p64 = relativePoint(topLeftCapyPoint, 32, 95)
    local p65 = relativePoint(topLeftCapyPoint, 53, 42)
    local p66 = relativePoint(topLeftCapyPoint, 15, 75)
    local p67 = relativePoint(topLeftCapyPoint, 0, 125)
    local p68 = relativePoint(topLeftCapyPoint, 53, 62)
    local p69 = relativePoint(topLeftCapyPoint, 0, 85)
    local p70 = relativePoint(topLeftCapyPoint, 0, 165)
    local p71 = relativePoint(topLeftCapyPoint, 29, 112)
    local p72 = relativePoint(topLeftCapyPoint, 0, 105)
    
    local p73 = relativePoint(topLeftCapyPoint, 73, 70)
    local p74 = relativePoint(topLeftCapyPoint, 80, 74)
    local p75 = relativePoint(topLeftCapyPoint, 92, 64)
    local p76 = relativePoint(topLeftCapyPoint, 60, 103)
    local p77 = relativePoint(topLeftCapyPoint, 67, 83)
    local p78 = relativePoint(topLeftCapyPoint, 89, 74)
    local p79 = relativePoint(topLeftCapyPoint, 53, 138)
    local p80 = relativePoint(topLeftCapyPoint, 48, 120)
    local p81 = relativePoint(topLeftCapyPoint, 73, 120)
    local p82 = relativePoint(topLeftCapyPoint, 46, 128)
    local p83 = relativePoint(topLeftCapyPoint, 48, 165)
    local p84 = relativePoint(topLeftCapyPoint, 74, 150)
    local p85 = relativePoint(topLeftCapyPoint, 61, 128)
    local p86 = relativePoint(topLeftCapyPoint, 83, 100)
    local p87 = relativePoint(topLeftCapyPoint, 90, 143)
    local p88 = relativePoint(topLeftCapyPoint, 73, 143)
    local p89 = relativePoint(topLeftCapyPoint, 120, 107)
    local p90 = relativePoint(topLeftCapyPoint, 116, 133)
    local p91 = relativePoint(topLeftCapyPoint, 106, 63)
    local p92 = relativePoint(topLeftCapyPoint, 126, 73)
    local p93 = relativePoint(topLeftCapyPoint, 127, 53)
    local p94 = relativePoint(topLeftCapyPoint, 91, 98)
    local p95 = relativePoint(topLeftCapyPoint, 101, 76)
    local p96 = relativePoint(topLeftCapyPoint, 114, 99)
    local p97 = relativePoint(topLeftCapyPoint, 126, 63)
    local p98 = relativePoint(topLeftCapyPoint, 156, 73)
    local p99 = relativePoint(topLeftCapyPoint, 127, 53)
    
    local color1 = rgbaToUint(250, 250, 225, 255)
    local color2 = rgbaToUint(240, 180, 140, 255)
    local color3 = rgbaToUint(195, 90, 120, 255)
    local color4 = rgbaToUint(115, 5, 65, 255)
    
    local color5 = rgbaToUint(100, 5, 45, 255)
    local color6 = rgbaToUint(200, 115, 135, 255)
    local color7 = rgbaToUint(175, 10, 70, 255)
    local color8 = rgbaToUint(200, 90, 110, 255)
    local color9 = rgbaToUint(125, 10, 75, 255)
    local color10 = rgbaToUint(220, 130, 125, 255)
    
    o.AddQuadFilled(p18, p19, p24, p25, color4)
    o.AddQuadFilled(p19, p20, p21, p22, color1)
    o.AddQuadFilled(p19, p22, p23, p24, color4)
    
    o.AddQuadFilled(p14, p15, p16, p17, color4)
    o.AddTriangleFilled(p17b, p16, p17, color1)
    
    o.AddQuadFilled(p1, p2, p4, p3, color3)
    o.AddQuadFilled(p1, p3, p6, p5, color3)
    o.AddQuadFilled(p3, p4, p7, p9, color2)
    o.AddQuadFilled(p3, p6, p11, p10, color2)
    o.AddQuadFilled(p6, p8, p13, p11, color1)
    o.AddQuadFilled(p13, p12, p10, p11, color6)
    o.AddTriangleFilled(p10b, p12b, p12c, color7)
    
    o.AddTriangleFilled(p9, p7b, p3b, color8)
    
    o.AddQuadFilled(p26, p27, p28, p29, color5)
    
    o.AddQuadFilled(p7, p30, p31, p32, color5)
    o.AddQuadFilled(p33, p34, p35, p36, color5)
    
    o.AddTriangleFilled(p37, p38, p39, color8)
    o.AddTriangleFilled(p40, p41, p42, color8)
    o.AddTriangleFilled(p43, p44, p45, color8)
    o.AddTriangleFilled(p46, p47, p48, color8)
    o.AddTriangleFilled(p49, p50, p51, color2)
    
    o.AddTriangleFilled(p52, p53, p54, color9)
    o.AddTriangleFilled(p55, p56, p57, color9)
    o.AddTriangleFilled(p58, p59, p60, color9)
    o.AddTriangleFilled(p61, p62, p63, color9)
    o.AddTriangleFilled(p64, p65, p66, color9)
    o.AddTriangleFilled(p67, p68, p69, color9)
    o.AddTriangleFilled(p70, p71, p72, color9)
    
    o.AddTriangleFilled(p73, p74, p75, color10)
    o.AddTriangleFilled(p76, p77, p78, color10)
    o.AddTriangleFilled(p79, p80, p81, color10)
    o.AddTriangleFilled(p82, p83, p84, color10)
    o.AddTriangleFilled(p85, p86, p87, color10)
    o.AddTriangleFilled(p88, p89, p90, color10)
    o.AddTriangleFilled(p91, p92, p93, color10)
    o.AddTriangleFilled(p94, p95, p96, color10)
    o.AddTriangleFilled(p97, p98, p99, color10)
end
-- Draws the currently selected cursor trail
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function drawCursorTrail(globalVars)
    local o = imgui.GetOverlayDrawList()
    local m = getCurrentMousePosition()
    local t = imgui.GetTime()
    local sz = state.WindowSize
    local cursorTrail = CURSOR_TRAILS[globalVars.cursorTrailIndex]
    if cursorTrail ~= "Dust"    then state.SetValue("initializeDustParticles", false) end
    if cursorTrail ~= "Sparkle" then state.SetValue("initializeSparkleParticles", false) end
    
    if cursorTrail == "None"    then return end
    if cursorTrail == "Snake"   then drawSnakeTrail(globalVars, o, m, t, sz) end
    if cursorTrail == "Dust"    then drawDustTrail(globalVars, o, m, t, sz) end
    if cursorTrail == "Sparkle" then drawSparkleTrail(globalVars, o, m, t, sz) end
end
-- Draws the "Snake" cursor trail
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    o          : [imgui overlay drawlist]
--    m          : current (x, y) mouse position [Table]
--    t          : current in-game plugin time [Int/Float]
--    sz         : dimensions of the window for Quaver [Table]
function drawSnakeTrail(globalVars, o, m, t, sz)
    local trailPoints = globalVars.cursorTrailPoints
    local snakeTrailPoints = {}
    initializeSnakeTrailPoints(snakeTrailPoints, m, MAX_CURSOR_TRAIL_POINTS)
    getVariables("snakeTrailPoints", snakeTrailPoints)
    local needTrailUpdate = checkIfFrameChanged(t, globalVars.effectFPS)
    updateSnakeTrailPoints(snakeTrailPoints, needTrailUpdate, m, trailPoints,
                           globalVars.snakeSpringConstant)
    saveVariables("snakeTrailPoints", snakeTrailPoints)
    local trailShape = TRAIL_SHAPES[globalVars.cursorTrailShapeIndex]
    renderSnakeTrailPoints(o, m, snakeTrailPoints, trailPoints, globalVars.cursorTrailSize,
                           globalVars.cursorTrailGhost, trailShape)
end
-- Initializes the points of the snake trail
-- Parameters
--    snakeTrailPoints : list of points used for the snake trail [Table]
--    m                : current (x, y) mouse position [Table]
--    trailPoints      : number of trail points for the snake trail [Int]
function initializeSnakeTrailPoints(snakeTrailPoints, m, trailPoints)
    if state.GetValue("initializeSnakeTrail") then
        for i = 1, trailPoints do
            snakeTrailPoints[i] = {}
        end
        return
    end
    for i = 1, trailPoints do
        snakeTrailPoints[i] = generate2DPoint(m.x, m.y)
    end
    state.SetValue("initializeSnakeTrail", true)
end
-- Updates the points of the snake trail
-- Parameters
--    snakeTrailPoints    : list of data used for the snake trail [Table]
--    needTrailUpdate     : whether or not the trail info needs to be updated [Boolean]
--    m                   : current (x, y) mouse position [Table]
--    trailPoints         : number of trail points to update [Int]
--    snakeSpringConstant : how much to update the trail points per frame (0.01 to 1) [Int/Float]
function updateSnakeTrailPoints(snakeTrailPoints, needTrailUpdate, m, trailPoints,
                                snakeSpringConstant)
    if not needTrailUpdate then return end
    for i = trailPoints, 1, -1 do
        local currentTrailPoint = snakeTrailPoints[i]
        if i == 1 then
            currentTrailPoint.x = m.x
            currentTrailPoint.y = m.y
        else
            local lastTrailPoint = snakeTrailPoints[i - 1]
            local xChange = lastTrailPoint.x - currentTrailPoint.x
            local yChange = lastTrailPoint.y - currentTrailPoint.y
            currentTrailPoint.x = currentTrailPoint.x + snakeSpringConstant * xChange
            currentTrailPoint.y = currentTrailPoint.y + snakeSpringConstant * yChange
        end
    end
end
-- Draws the points of the snake trail
-- Parameters
--    o                : [imgui overlay drawlist]
--    m                : current (x, y) mouse position [Table]
--    snakeTrailPoints : list of data used for the snake trail [Table]
--    trailPoints      : number of trail points to draw [Int]
--    cursorTrailSize  : size of the cursor trail points [Int]
--    cursorTrailGhost : whether or not to make later trail points more transparent [Boolean]
--    trailShape       : shape of the trail points to draw [String]
function renderSnakeTrailPoints(o, m, snakeTrailPoints, trailPoints, cursorTrailSize,
                                cursorTrailGhost, trailShape)
    for i = 1, trailPoints do
        local point = snakeTrailPoints[i]
        local alpha = 255
        if not cursorTrailGhost then
            alpha = math.floor(255 * (trailPoints - i) / (trailPoints - 1))
        end
        local color = rgbaToUint(255, 255, 255, alpha)
        if trailShape == "Circles" then
            local coords = {point.x, point.y}
            o.AddCircleFilled(coords, cursorTrailSize, color)
        elseif trailShape == "Triangles" then
            drawTriangleTrailPoint(o, m, point, cursorTrailSize, color)
        end
    end
end
-- Draws a point of the triangle snake trail
-- Parameters
--    o               : [imgui overlay drawlist]
--    m               : current (x, y) mouse position [Table]
--    point           : (x, y) coordinates [Table]
--    cursorTrailSize : size of the cursor trail points [Int]
--    color           : color of the triangle represented as a uint [Int]
function drawTriangleTrailPoint(o, m, point, cursorTrailSize, color)
    local dx = m.x - point.x
    local dy = m.y - point.y
    if dx == 0 and dy == 0 then return end
    local angle = math.pi / 2
    if dx ~= 0 then angle = math.atan(dy / dx) end
    if dx < 0 then angle = angle + math.pi end
    if dx == 0 and dy < 0 then angle = angle + math.pi end
    drawEquilateralTriangle(o, point, cursorTrailSize, angle, color)
end
-- Draws the "Dust" cursor trail
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    o          : [imgui overlay drawlist]
--    m          : current (x, y) mouse position [Table]
--    t          : current in-game plugin time [Int/Float]
--    sz         : dimensions of the window for Quaver [Table]
function drawDustTrail(globalVars, o, m, t, sz)
    local dustSize = math.floor(sz[2] / 120)
    local dustDuration = 0.4
    local numDustParticles = 20
    local dustParticles = {}
    initializeDustParticles(sz, t, dustParticles, numDustParticles, dustDuration)
    getVariables("dustParticles", dustParticles)
    updateDustParticles(t, m, dustParticles, dustDuration, dustSize)
    saveVariables("dustParticles", dustParticles)
    renderDustParticles(globalVars.rgbPeriod, o, t, dustParticles, dustDuration, dustSize)
end
-- Initializes the particles of the dust trail
-- Parameters
--    sz               : dimensions of the window for Quaver [Table]
--    t                : current in-game plugin time [Int/Float]
--    dustParticles    : list of dust particles [Table]
--    numDustParticles : total number of dust particles [Int]
--    dustDuration     : lifespan of a dust particle [Int/Float]
function initializeDustParticles(sz, t, dustParticles, numDustParticles, dustDuration)
    if state.GetValue("initializeDustParticles") then
        for i = 1, numDustParticles do
            dustParticles[i] = {}
        end
        return
    end
    for i = 1, numDustParticles do
        local endTime = t + (i / numDustParticles) * dustDuration
        local showParticle = false
        dustParticles[i] = generateParticle(0, 0, 0, 0, endTime, showParticle)
    end
    state.SetValue("initializeDustParticles", true)
    saveVariables("dustParticles", dustParticles)
end
-- Updates the particles of the dust trail
-- Parameters
--    t             : current in-game plugin time [Int/Float]
--    m             : current (x, y) mouse position [Table]
--    dustParticles : list of dust particles [Table]
--    dustDuration  : lifespan of a dust particle [Int/Float]
--    dustSize      : size of a dust particle [Int/Float]
function updateDustParticles(t, m, dustParticles, dustDuration, dustSize)
    local yRange = 8 * dustSize * (math.random() - 0.5)
    local xRange = 8 * dustSize * (math.random() - 0.5)
    for i = 1, #dustParticles do
        local dustParticle = dustParticles[i]
        local timeLeft = dustParticle.endTime - t
        if timeLeft < 0 then
            local endTime = t + dustDuration
            local showParticle = checkIfMouseMoved(getCurrentMousePosition())
            dustParticles[i] = generateParticle(m.x, m.y, xRange, yRange, endTime, showParticle)
        end
    end
end
-- Draws the particles of the dust trail
-- Parameters
--    rgbPeriod     : length in seconds of one RGB color cycle [Int/Float]
--    o             : [imgui overlay drawlist]
--    t             : current in-game plugin time [Int/Float]
--    dustParticles : list of dust particles [Table]
--    dustDuration  : lifespan of a dust particle [Int/Float]
--    dustSize      : size of a dust particle [Int/Float]
function renderDustParticles(rgbPeriod, o, t, dustParticles, dustDuration, dustSize)
    local currentRGBColors = getCurrentRGBColors(rgbPeriod)
    local currentRed = round(255 * currentRGBColors.red, 0)
    local currentGreen = round(255 * currentRGBColors.green, 0)
    local currentBlue = round(255 * currentRGBColors.blue, 0)
    for i = 1, #dustParticles do
        local dustParticle = dustParticles[i]
        if dustParticle.showParticle then
            local time = 1 - ((dustParticle.endTime - t) / dustDuration)
            local dustX = dustParticle.x + dustParticle.xRange * time
            local dy = dustParticle.yRange * simplifiedQuadraticBezier(0, time)
            local dustY = dustParticle.y + dy
            local dustCoords = {dustX, dustY}
            local alpha = round(255 * (1 - time), 0)
            local dustColor = rgbaToUint(currentRed, currentGreen, currentBlue, alpha)
            o.AddCircleFilled(dustCoords, dustSize, dustColor)
        end
    end
end
-- Draws the "Sparkle" cursor trail
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    o          : [imgui overlay drawlist]
--    m          : current (x, y) mouse position [Table]
--    t          : current in-game plugin time [Int/Float]
--    sz         : dimensions of the window for Quaver [Table]
function drawSparkleTrail(globalVars, o, m, t, sz)
    local sparkleSize = 10
    local sparkleDuration = 0.3
    local numSparkleParticles = 10
    local sparkleParticles = {}
    initializeSparkleParticles(sz, t, sparkleParticles, numSparkleParticles, sparkleDuration)
    getVariables("sparkleParticles", sparkleParticles)
    updateSparkleParticles(t, m, sparkleParticles, sparkleDuration, sparkleSize)
    saveVariables("sparkleParticles", sparkleParticles)
    renderSparkleParticles(o, t, sparkleParticles, sparkleDuration, sparkleSize)
end
-- Initializes the particles of the sparkle trail
-- Parameters
--    sz                  : dimensions of the window for Quaver [Table]
--    t                   : current in-game plugin time [Int/Float]
--    sparkleParticles    : list of sparkle particles [Table]
--    numSparkleParticles : total number of sparkle particles [Int]
--    sparkleDuration     : lifespan of a sparkle particle [Int/Float]
function initializeSparkleParticles(sz, t, sparkleParticles, numSparkleParticles, sparkleDuration)
    if state.GetValue("initializeSparkleParticles") then
        for i = 1, numSparkleParticles do
            sparkleParticles[i] = {}
        end
        return
    end
    for i = 1, numSparkleParticles do
        local endTime = t + (i / numSparkleParticles) * sparkleDuration
        local showParticle = false
        sparkleParticles[i] = generateParticle(0, 0, 0, 0, endTime, showParticle)
    end
    state.SetValue("initializeSparkleParticles", true)
    saveVariables("sparkleParticles", sparkleParticles)
end
-- Updates the particles of the sparkle trail
-- Parameters
--    t                : current in-game plugin time [Int/Float]
--    m                : current (x, y) mouse position [Table]
--    sparkleParticles : list of sparkle particles [Table]
--    sparkleDuration  : lifespan of a sparkle particle [Int/Float]
--    sparkleSize      : size of a sparkle particle [Int/Float]
function updateSparkleParticles(t, m, sparkleParticles, sparkleDuration, sparkleSize)
    for i = 1, #sparkleParticles do
        local sparkleParticle = sparkleParticles[i]
        local timeLeft = sparkleParticle.endTime - t
        if timeLeft < 0 then
            local endTime = t + sparkleDuration
            local showParticle = checkIfMouseMoved(getCurrentMousePosition())
            local randomX = m.x + sparkleSize * 3 * (math.random() - 0.5)
            local randomY = m.y + sparkleSize * 3 * (math.random() - 0.5)
            local yRange = 6 * sparkleSize
            sparkleParticles[i] = generateParticle(randomX, randomY, 0, yRange, endTime,
                                                   showParticle)
        end
    end
end
-- Draws the particles of the sparkle trail
-- Parameters
--    o                : [imgui overlay drawlist]
--    t                : current in-game plugin time [Int/Float]
--    sparkleParticles : list of sparkle particles [Table]
--    sparkleDuration  : lifespan of a sparkle particle [Int/Float]
--    sparkleSize      : size of a sparkle particle [Int/Float]
function renderSparkleParticles(o, t, sparkleParticles, sparkleDuration, sparkleSize)
    for i = 1, #sparkleParticles do
        local sparkleParticle = sparkleParticles[i]
        if sparkleParticle.showParticle then
            local time = 1 - ((sparkleParticle.endTime - t) / sparkleDuration)
            local sparkleX = sparkleParticle.x + sparkleParticle.xRange * time
            local dy = -sparkleParticle.yRange * simplifiedQuadraticBezier(0, time)
            local sparkleY = sparkleParticle.y + dy
            local sparkleCoords = {sparkleX, sparkleY}
            local alpha = round(255 * (1 - time), 0)
            local white = rgbaToUint(255, 255, 255, 255)
            local actualSize = sparkleSize * (1 - simplifiedQuadraticBezier(0, time))
            local sparkleColor = rgbaToUint(255, 255, 100, 30)
            drawGlare(o, sparkleCoords, actualSize, white, sparkleColor)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- Variable Management ----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------- State

-- Retrieves values from the state for a list of variables
-- Parameters
--    listName  : name of the list of variables [String]
--    variables : list of variables [Table]
function getVariables(listName, variables) 
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(listName..key) or value
    end
end
-- Saves values to the state for a list of variables
-- Parameters
--    listName  : name of the list of variables [String]
--    variables : list of variables [Table]
function saveVariables(listName, variables)
    for key, value in pairs(variables) do
        state.SetValue(listName..key, value)
    end
end

------------------------------------------------------------------------------------ Menu Variables

-- Returns menuVars for the menu at Place SVs > Standard
function getStandardPlaceMenuVars()
    local menuVars = {
        svTypeIndex = 1,
        svMultipliers = {},
        svDistances = {},
        svGraphStats = createSVGraphStats(),
        svStats = createSVStats(),
        interlace = false,
        interlaceRatio = -0.5
    }
    getVariables("placeStandardMenu", menuVars)
    return menuVars
end
-- Returns menuVars for the menu at Place SVs > Special
function getSpecialPlaceMenuVars()
    local menuVars = {
        svTypeIndex = 1
    }
    getVariables("placeSpecialMenu", menuVars)
    return menuVars
end
-- Returns menuVars for the menu at Place SVs > Still
function getStillPlaceMenuVars()
    local menuVars = {
        svTypeIndex = 1,
        noteSpacing = 1,
        stillTypeIndex = 1,
        stillDistance = 200,
        prePlaceDistances = {},
        svMultipliers = {},
        svDistances = {},
        svGraphStats = createSVGraphStats(),
        svStats = createSVStats(),
        interlace = false,
        interlaceRatio = -0.5
    }
    getVariables("placeStillMenu", menuVars)
    return menuVars
end
-- Gets the current menu's setting variables
-- Parameters
--    svType : name of the current menu's type of SV [Table]
--    label  : text to delineate the type of setting variables [String]
function getSettingVars(svType, label)
    local settingVars
    if svType == "Linear" then
        settingVars = {
            startSV = 1.5,
            endSV = 0.5,
            svPoints = 16,
            finalSVIndex = 2,
            customSV = 1
        }
    elseif svType == "Exponential" then
        settingVars = {
            behaviorIndex = 1,
            intensity = 30,
            verticalShift = 0,
            avgSV = 1,
            svPoints = 16,
            finalSVIndex = 2,
            customSV = 1
        }
    elseif svType == "Bezier" then
        settingVars = {
            x1 = 0,
            y1 = 0,
            x2 = 0,
            y2 = 1,
            verticalShift = 0,
            avgSV = 1,
            svPoints = 16,
            finalSVIndex = 2,
            customSV = 1
        }
    elseif svType == "Hermite" then
        settingVars = {
            startSV = 0,
            endSV = 0,
            verticalShift = 0,
            avgSV = 1,
            svPoints = 16,
            finalSVIndex = 2,
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
            finalSVIndex = 2,
            customSV = 1
        }
    elseif svType == "Circular" then
        settingVars = {
            behaviorIndex = 1,
            arcPercent = 50,
            avgSV = 1,
            verticalShift = 0,
            svPoints = 16,
            finalSVIndex = 2,
            customSV = 1,
            dontNormalize = false
        }
    elseif svType == "Random" then
        settingVars = {
            svMultipliers = {},
            randomTypeIndex = 1,
            randomScale = 2,
            svPoints = 16,
            finalSVIndex = 2,
            customSV = 1,
            dontNormalize = false,
            avgSV = 1,
            verticalShift = 0
        }
    elseif svType == "Custom" then
        settingVars = {
            svMultipliers = {0},
            selectedMultiplierIndex = 1,
            svPoints = 1,
            finalSVIndex = 2,
            customSV = 1
        }
    elseif svType == "Combo" then
        settingVars = {
            svType1Index = 1,
            svType2Index = 2,
            comboPhase = 0,
            comboTypeIndex = 1,
            comboMultiplier1 = 1,
            comboMultiplier2 = 1,
            finalSVIndex = 2,
            customSV = 1,
            dontNormalize = false,
            avgSV = 1,
            verticalShift = 0
        }
    elseif svType == "Stutter" then
        settingVars = {
            startSV = 1.5,
            endSV = 0.5,
            stutterDuration = 50,
            stuttersPerSection = 1,
            avgSV = 1,
            finalSVIndex = 2,
            customSV = 1,
            linearlyChange = false,
            controlLastSV = false,
            svMultipliers = {},
            svDistances = {},
            svGraphStats = createSVGraphStats(),
            svMultipliers2 = {},
            svDistances2 = {},
            svGraph2Stats = createSVGraphStats()
        }
    elseif svType == "Teleport Stutter" then
        settingVars = {
            svPercent = 50,
            svPercent2 = 0,
            distance = 50,
            mainSV = 0.5,
            mainSV2 = 0,
            useDistance = false,
            linearlyChange = false,
            avgSV = 1,
            finalSVIndex = 2,
            customSV = 1
        }
    elseif svType == "Splitscroll (Basic)" then
        settingVars = {
            scrollSpeed1 = 0.9,
            height1 = 0,
            scrollSpeed2 = -0.9,
            height2 = 400,
            distanceBack = 1000000,
            msPerFrame = 16,
            noteTimes2 = {},
        }
    elseif svType == "Splitscroll (Advanced)" then
        settingVars = {
            distanceBack = 1000000,
            msPerFrame = 16,
            noteTimes2 = {},
            svsInScroll1 = {},
            svsInScroll2 = {}
        }
    end
    local labelText = table.concat({svType, "Settings", label})
    getVariables(labelText, settingVars)
    return settingVars
end

---------------------------------------------------------------------------------------------------
-- Handy GUI elements -----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Adds vertical blank space/padding on the GUI
function addPadding()
    imgui.Dummy({0, 0})
end
-- Creates a horizontal line separator on the GUI
function addSeparator()
    addPadding()
    imgui.Separator()
    addPadding()
end
-- Creates a tooltip box when the last (most recently created) GUI item is hovered over
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
--    text : text to show in the tooltip box [String]
function helpMarker(text)
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.TextDisabled("(?)")
    toolTip(text)
end
-- Creates a copy-pastable text box
-- Parameters
--    text    : text to put above the box [String]
--    label   : label of the input text [String]
--    content : content to put in the box [String]
function copiableBox(text, label, content)
    imgui.TextWrapped(text)
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth())
    imgui.InputText(label, content, #content, imgui_input_text_flags.AutoSelectAll)
    imgui.PopItemWidth()
    addPadding()
end
-- Creates a copy-pastable link box
-- Parameters
--    text : text to describe the link [String]
--    url  : link [String]
function linkBox(text, url)
    copiableBox(text, "##"..url, url)
end

---------------------------------------------------------------------------------------------------
-- Plugin Convenience Functions -------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Makes the next plugin window not collapsed on startup
-- Parameters
--    windowName : key name for the next plugin window that opens [String]
function startNextWindowNotCollapsed(windowName)
    if state.GetValue(windowName) then return end
    imgui.SetNextWindowCollapsed(false)
    state.SetValue(windowName, true)
end
-- Makes the main plugin window focused/active if Shift + Tab is pressed
function focusWindowIfHotkeysPressed()
    local shiftKeyPressedDown = utils.IsKeyDown(keys.LeftShift) or
                                utils.IsKeyDown(keys.RightShift)
    local tabKeyPressed = utils.IsKeyPressed(keys.Tab)
    if shiftKeyPressedDown and tabKeyPressed then imgui.SetNextWindowFocus() end
end
-- Makes the main plugin window centered if Ctrl + Shift + Tab is pressed
function centerWindowIfHotkeysPressed()
    local ctrlPressedDown = utils.IsKeyDown(keys.LeftControl) or
                            utils.IsKeyDown(keys.RightControl)
    local shiftPressedDown = utils.IsKeyDown(keys.LeftShift) or
                             utils.IsKeyDown(keys.RightShift)
    local tabPressed = utils.IsKeyPressed(keys.Tab)
    if not (ctrlPressedDown and shiftPressedDown and tabPressed) then return end
    
    local windowWidth, windowHeight = table.unpack(state.WindowSize)
    local pluginWidth, pluginHeight = table.unpack(imgui.GetWindowSize())
    local centeringX = (windowWidth - pluginWidth) / 2
    local centeringY = (windowHeight - pluginHeight) / 2
    local coordinatesToCenter = {centeringX, centeringY}
    imgui.SetWindowPos("amoguSV", coordinatesToCenter)
end
--[[
-- Makes a plugin window start/spawn at a certain coordiate
-- Parameters
--    name   : name of the plugin window [String]
--    coords : (x, y) coordinates to spawn at [Table]
function spawnWindowAtCoords(name, coords)
    local key = name.."spawn"
    if not state.GetValue(key) then return end
    imgui.SetWindowPos(name, coords)
    state.SetValue(key, true)
end
--]]

---------------------------------------------------------------------------------------------------
-- Plugin Menus (+ other higher level menu-related functions) -------------------------------------
---------------------------------------------------------------------------------------------------

-- Creates the plugin window
function draw()
    local globalVars = {
        dontReplaceSV = false,
        upscroll = false,
        colorThemeIndex = 3,
        styleThemeIndex = 1,
        effectFPS = 60,
        cursorTrailIndex = 1,
        cursorTrailShapeIndex = 1,
        cursorTrailPoints = 10,
        cursorTrailSize = 5,
        snakeSpringConstant = 1,
        cursorTrailGhost = false,
        rgbPeriod = 60,
        drawCapybara = false,
        drawCapybara2 = false,
        placeTypeIndex = 1,
        editToolIndex = 1,
        showExportImportMenu = false,
        importData = "",
        exportCustomSVData = "",
        exportData = "",
        debugText = "debuggy capybara"
    }
    getVariables("globalVars", globalVars)
    
    drawCapybara(globalVars)
    drawCapybara2(globalVars)
    drawCursorTrail(globalVars)
    setPluginAppearance(globalVars)
    startNextWindowNotCollapsed("amoguSVAutoOpen")
    focusWindowIfHotkeysPressed()
    centerWindowIfHotkeysPressed()
    
    imgui.Begin("amoguSV", imgui_window_flags.AlwaysAutoResize)
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

----------------------------------------------------------------------------------------- Tab stuff

-- Creates a menu tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    tabName    : name of the currently selected tab [String]
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
    provideBasicPluginInfo()
    provideMorePluginInfo(globalVars)
    listKeyboardShortcuts()
    choosePluginAppearance(globalVars)
end
-- Creates the "Place SVs" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function placeSVTab(globalVars)
    choosePlaceSVType(globalVars)
    exportImportSettingsButton(globalVars)
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
    if toolName == "Add Teleport"     then addTeleportMenu() end
    if toolName == "Copy & Paste"     then copyNPasteMenu(globalVars) end
    if toolName == "Displace Note"    then displaceNoteMenu() end
    if toolName == "Displace View"    then displaceViewMenu() end
    if toolName == "Fix LN Ends"      then fixLNEndsMenu() end
    if toolName == "Flicker"          then flickerMenu() end
    if toolName == "Measure"          then measureMenu() end
    if toolName == "Merge"            then mergeMenu() end
    if toolName == "Reverse Scroll"   then reverseScrollMenu() end
    if toolName == "Scale (Displace)" then scaleDisplaceMenu() end
    if toolName == "Scale (Multiply)" then scaleMultiplyMenu() end
    if toolName == "Swap Notes"       then swapNotesMenu() end
end
-- Creates the "Delete SVs" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function deleteSVTab(globalVars)
    simpleActionMenu("Delete SVs between selected notes", 2, deleteSVs, nil, nil)
end

--------------------------------------------------------------------------------------------- Menus

-- Creates the menu for placing standard SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function placeStandardSVMenu(globalVars)
    local menuVars = getStandardPlaceMenuVars()
    local needSVUpdate = #menuVars.svMultipliers == 0
    needSVUpdate = chooseStandardSVType(menuVars) or needSVUpdate
    
    addSeparator()
    local currentSVType = STANDARD_SVS[menuVars.svTypeIndex]
    local settingVars = getSettingVars(currentSVType, "Standard")
    if globalVars.showExportImportMenu then
        --saveVariables("placeStandardMenu", menuVars)
        exportImportSettingsMenu(globalVars, menuVars, settingVars)
        return
    end
    
    needSVUpdate = showSettingsMenu(currentSVType, settingVars, false) or needSVUpdate
    
    addSeparator()
    needSVUpdate = chooseInterlace(menuVars) or needSVUpdate
    if needSVUpdate then updateMenuSVs(currentSVType, globalVars, menuVars, settingVars) end
    
    startNextWindowNotCollapsed("svInfoAutoOpen")
    makeSVInfoWindow("SV Info", menuVars.svGraphStats, menuVars.svStats, menuVars.svDistances,
                     menuVars.svMultipliers, nil)
    
    addSeparator()
    simpleActionMenu("Place SVs between selected notes", 2, placeSVs, globalVars, menuVars)
    
    local labelText = table.concat({currentSVType, "SettingsStandard"})
    saveVariables(labelText, settingVars)
    saveVariables("placeStandardMenu", menuVars)
end
-- Creates the menu for placing special SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function placeSpecialSVMenu(globalVars)
    local menuVars = getSpecialPlaceMenuVars()
    chooseSpecialSVType(menuVars)

    addSeparator()
    local currentSVType = SPECIAL_SVS[menuVars.svTypeIndex]
    local settingVars = getSettingVars(currentSVType, "Special")
    if globalVars.showExportImportMenu then
        --saveVariables("placeSpecialMenu", menuVars)
        exportImportSettingsMenu(globalVars, menuVars, settingVars)
        return
    end
    
    if currentSVType == "Stutter"                then stutterMenu(settingVars) end
    if currentSVType == "Teleport Stutter"       then telportStutterMenu(settingVars) end
    if currentSVType == "Splitscroll (Basic)"    then splitScrollBasicMenu(settingVars) end
    if currentSVType == "Splitscroll (Advanced)" then splitScrollAdvancedMenu(settingVars) end
    
    local labelText = table.concat({currentSVType, "SettingsSpecial"})
    saveVariables(labelText, settingVars)
    saveVariables("placeSpecialMenu", menuVars)
end
-- Creates the menu for placing still SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function placeStillSVMenu(globalVars)
    local menuVars = getStillPlaceMenuVars()
    local needSVUpdate = #menuVars.svMultipliers == 0
    needSVUpdate = chooseStandardSVType(menuVars) or needSVUpdate
    
    addSeparator()
    local currentSVType = STANDARD_SVS[menuVars.svTypeIndex]
    local settingVars = getSettingVars(currentSVType, "Still")
    if globalVars.showExportImportMenu then
        --saveVariables("placeStillMenu", menuVars)
        exportImportSettingsMenu(globalVars, menuVars, settingVars)
        return
    end
    imgui.Text("Still Settings:")
    chooseNoteSpacing(menuVars)
    chooseStillType(menuVars)
    
    addSeparator()
    needSVUpdate = showSettingsMenu(currentSVType, settingVars, false) or needSVUpdate
    
    addSeparator()
    needSVUpdate = chooseInterlace(menuVars) or needSVUpdate
    if needSVUpdate then updateMenuSVs(currentSVType, globalVars, menuVars, settingVars) end
    
    startNextWindowNotCollapsed("svInfoAutoOpen")
    makeSVInfoWindow("SV Info", menuVars.svGraphStats, menuVars.svStats, menuVars.svDistances,
                     menuVars.svMultipliers, nil)
    
    addSeparator()
    simpleActionMenu("Place SVs between selected notes", 2, placeSVs, globalVars, menuVars)
    
    local labelText = table.concat({currentSVType, "SettingsStill"})
    saveVariables(labelText, settingVars)
    saveVariables("placeStillMenu", menuVars)
end
-- Creates the menu for linear SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this linear menu [Table]
--    skipFinalSV : whether or not to skip choosing the final SV [Boolean]
function linearSettingsMenu(settingVars, skipFinalSV)
    local settingsChanged = false
    settingsChanged = chooseStartEndSVs(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    if skipFinalSV then return settingsChanged end
    
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for exponential SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this exponential menu [Table]
--    skipFinalSV : whether or not to skip choosing the final SV [Boolean]
function exponentialSettingsMenu(settingVars, skipFinalSV)
    local settingsChanged = false
    settingsChanged = chooseSVBehavior(settingVars) or settingsChanged
    settingsChanged = chooseIntensity(settingVars) or settingsChanged
    settingsChanged = chooseConstantShift(settingVars, 0) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    if skipFinalSV then return settingsChanged end
    
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for bezier SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this bezier menu [Table]
--    skipFinalSV : whether or not to skip choosing the final SV [Boolean]
function bezierSettingsMenu(settingVars, skipFinalSV)
    local settingsChanged = false
    settingsChanged = provideBezierWebsiteLink(settingVars) or settingsChanged
    settingsChanged = chooseBezierPoints(settingVars) or settingsChanged
    settingsChanged = chooseConstantShift(settingVars, 0) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    if skipFinalSV then return settingsChanged end
    
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for hermite SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this hermite menu [Table]
--    skipFinalSV : whether or not to skip choosing the final SV [Boolean]
function hermiteSettingsMenu(settingVars, skipFinalSV)
    local settingsChanged = false
    settingsChanged = chooseStartEndSVs(settingVars) or settingsChanged
    settingsChanged = chooseConstantShift(settingVars, 0) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    if skipFinalSV then return settingsChanged end
    
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for sinusoidal SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this sinusoidal menu [Table]
--    skipFinalSV : whether or not to skip choosing the final SV [Boolean]
function sinusoidalSettingsMenu(settingVars, skipFinalSV)
    local settingsChanged = false
    imgui.Text("Amplitude:")
    settingsChanged = chooseStartEndSVs(settingVars) or settingsChanged
    settingsChanged = chooseCurveSharpness(settingVars) or settingsChanged
    settingsChanged = chooseConstantShift(settingVars, 1) or settingsChanged
    settingsChanged = chooseNumPeriods(settingVars) or settingsChanged
    settingsChanged = choosePeriodShift(settingVars) or settingsChanged
    settingsChanged = chooseSVPerQuarterPeriod(settingVars) or settingsChanged
    if skipFinalSV then return settingsChanged end
    
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for circular SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this circular menu [Table]
--    skipFinalSV : whether or not to skip choosing the final SV [Boolean]
function circularSettingsMenu(settingVars, skipFinalSV)
    local settingsChanged = false
    settingsChanged = chooseSVBehavior(settingVars) or settingsChanged
    settingsChanged = chooseArcPercent(settingVars) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseConstantShift(settingVars, 0) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    if not skipFinalSV then
        settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    end
    settingsChanged = chooseNoNormalize(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for random SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this random menu [Table]
--    skipFinalSV : whether or not to skip choosing the final SV [Boolean]
function randomSettingsMenu(settingVars, skipFinalSV)
    local settingsChanged = false
    
    settingsChanged = chooseRandomType(settingVars) or settingsChanged
    settingsChanged = chooseRandomScale(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    if not skipFinalSV then
        settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    end
    
    addSeparator()
    if imgui.Button("Generate New Random Set", {ACTION_BUTTON_SIZE[1], 24}) then
        generateRandomSetMenuSVs(settingVars)
        settingsChanged = true
    end
    
    addSeparator()
    if not settingVars.dontNormalize then
        settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    end
    settingsChanged = chooseConstantShift(settingVars, 0) or settingsChanged
    settingsChanged = chooseNoNormalize(settingVars) or settingsChanged
    
    return settingsChanged
end
-- Creates the menu for custom SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this custom menu [Table]
--    skipFinalSV : whether or not to skip choosing the final SV [Boolean]
function customSettingsMenu(settingVars, skipFinalSV)
    local settingsChanged = false
    settingsChanged = importCustomSVs(settingVars) or settingsChanged
    settingsChanged = chooseCustomMultipliers(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    if not skipFinalSV then
        settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    end
    adjustNumberOfMultipliers(settingVars)
    return settingsChanged
end
-- Creates the menu for custom SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this combo menu [Table]
function comboSettingsMenu(settingVars)
    local settingsChanged = false
    startNextWindowNotCollapsed("svType1AutoOpen")
    imgui.Begin("SV Type 1 Settings", imgui_window_flags.AlwaysAutoResize)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    local svType1 = STANDARD_SVS[settingVars.svType1Index]
    local settingVars1 = getSettingVars(svType1, "Combo1")
    settingsChanged = showSettingsMenu(svType1, settingVars1, true) or settingsChanged
    local labelText1 = table.concat({svType1, "SettingsCombo1"})
    saveVariables(labelText1, settingVars1)
    imgui.End()
    
    startNextWindowNotCollapsed("svType2AutoOpen")
    imgui.Begin("SV Type 2 Settings", imgui_window_flags.AlwaysAutoResize)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    local svType2 = STANDARD_SVS[settingVars.svType2Index]
    local settingVars2 = getSettingVars(svType2, "Combo2")
    settingsChanged = showSettingsMenu(svType2, settingVars2, true) or settingsChanged
    local labelText2 = table.concat({svType2, "SettingsCombo2"})
    saveVariables(labelText2, settingVars2)
    imgui.End()
    
    local maxComboPhase = settingVars1.svPoints + settingVars2.svPoints
    
    settingsChanged = chooseStandardSVTypes(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    
    addSeparator()
    settingsChanged = chooseComboPhase(settingVars, maxComboPhase) or settingsChanged
    settingsChanged = chooseComboSVOption(settingVars) or settingsChanged
    if not settingVars.dontNormalize then
        settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    end
    settingsChanged = chooseConstantShift(settingVars, 0) or settingsChanged
    settingsChanged = chooseNoNormalize(settingVars) or settingsChanged
    
    return settingsChanged
end
-- Creates the menu for stutter SV
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function stutterMenu(settingVars)
    local settingsChanged = #settingVars.svMultipliers == 0
    settingsChanged = chooseControlSecondSV(settingVars) or settingsChanged
    settingsChanged = chooseStartEndSVs(settingVars) or settingsChanged
    settingsChanged = chooseStutterDuration(settingVars) or settingsChanged
    settingsChanged = chooseLinearlyChange(settingVars) or settingsChanged
    
    addSeparator()
    settingsChanged = chooseStuttersPerSection(settingVars) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    if settingsChanged then updateStutterMenuSVs(settingVars) end
    displayStutterSVWindows(settingVars)
    
    addSeparator()
    simpleActionMenu("Place SVs between selected notes", 2, placeStutterSVs, nil, settingVars)
end
-- Creates the menu for teleport stutter SV
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function telportStutterMenu(settingVars)
    if settingVars.useDistance then
        chooseDistance(settingVars)
        helpMarker("Start SV teleport distance")
    else
        chooseStartSVPercent(settingVars)
    end
    chooseMainSV(settingVars)
    chooseAverageSV(settingVars)
    chooseFinalSV(settingVars)
    chooseUseDistance(settingVars)
    chooseLinearlyChange(settingVars)
    
    addSeparator()
    local label = "Place SVs between selected notes"
    simpleActionMenu(label, 2, placeTeleportStutterSVs, nil, settingVars)
end
-- Creates the menu for basic splitscroll SV
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function splitScrollBasicMenu(settingVars)
    chooseFirstScrollSpeed(settingVars)
    chooseFirstHeight(settingVars)
    chooseSecondScrollSpeed(settingVars)
    chooseSecondHeight(settingVars)
    chooseMSPF(settingVars)
    
    addSeparator()
    local noNoteTimesInitially = #settingVars.noteTimes2 == 0
    addOrClearNoteTimes(settingVars, noNoteTimesInitially)
    if noNoteTimesInitially then return end
    
    addSeparator()
    local label = "Place Splitscroll SVs at selected note(s)"
    simpleActionMenu(label, 1, placeSplitScrollSVs, nil, settingVars)
end
-- Creates the menu for advanced splitscroll SV
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function splitScrollAdvancedMenu(settingVars)
    chooseDistanceBack(settingVars)
    chooseMSPF(settingVars)
    
    addSeparator()
    local noNoteTimesInitially = #settingVars.noteTimes2 == 0
    addOrClearNoteTimes(settingVars, noNoteTimesInitially)
    
    addSeparator()
    local no1stSVsInitially = #settingVars.svsInScroll1 == 0
    local no2ndSVsInitially = #settingVars.svsInScroll2 == 0
    buttonsForSVsInScroll1(settingVars, no1stSVsInitially)
    addSeparator()
    buttonsForSVsInScroll2(settingVars, no2ndSVsInitially)
    if noNoteTimesInitially or no1stSVsInitially or no2ndSVsInitially then return end
    
    addSeparator()
    local label = "Place Splitscroll SVs at selected note(s)"
    simpleActionMenu(label, 1, placeAdvancedSplitScrollSVs, nil, settingVars)
end
-- Makes the export and import menu for place SV settings
-- Parameters
--    globalVars  : list of variables used globally across all menus [Table]
--    menuVars    : list of setting variables for the current menu [Table]
--    settingVars : list of setting variables for the current sv type [Table]
function exportImportSettingsMenu(globalVars, menuVars, settingVars)
    local multilineWidgetSize = {ACTION_BUTTON_SIZE[1], 50}
    local placeType = PLACE_TYPES[globalVars.placeTypeIndex]
    local isSpecialPlaceType = placeType == "Special"
    local svType
    if isSpecialPlaceType then
        svType = SPECIAL_SVS[menuVars.svTypeIndex]
    else
        svType = STANDARD_SVS[menuVars.svTypeIndex]
    end
    local isComboType = svType == "Combo"
    local isSplitscrollSVType = svType == "Splitscroll (Basic)" or
                                svType == "Splitscroll (Advanced)"
    imgui.Text("Paste exported data here to import")
    _, globalVars.importData = imgui.InputTextMultiline("##placeImport", globalVars.importData,
                                                        999999, multilineWidgetSize)
    importPlaceSVButton(globalVars)
    addSeparator()
    if isSplitscrollSVType then imgui.Text("No export option") return end
    
    if not isSpecialPlaceType then
        imgui.Text("Copy + paste exported data somewhere safe")
        imgui.InputTextMultiline("##customSVExport", globalVars.exportCustomSVData,
                                 #globalVars.exportCustomSVData, multilineWidgetSize,
                                 imgui_input_text_flags.ReadOnly)
        exportCustomSVButton(globalVars, menuVars)
        addSeparator()
    end
    if not isComboType then
        imgui.Text("Copy + paste exported data somewhere safe")
        imgui.InputTextMultiline("##placeExport", globalVars.exportData, #globalVars.exportData,
                                 multilineWidgetSize, imgui_input_text_flags.ReadOnly)
        exportPlaceSVButton(globalVars, menuVars, settingVars)
    end
end
-- Creates the add teleport menu
function addTeleportMenu()
    local menuVars = {
        distance = 10727
    }
    getVariables("addTeleportMenu", menuVars)
    chooseDistance(menuVars)
    saveVariables("addTeleportMenu", menuVars)
    
    addSeparator()
    simpleActionMenu("Add teleport SVs at selected notes", 1, addTeleportSVs, nil, menuVars)
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
    imgui.Text(table.concat({#menuVars.copiedSVs, " SVs copied"}))
      
    addSeparator()
    if noSVsCopiedInitially then
        simpleActionMenu("Copy SVs between selected notes", 2, copySVs, nil, menuVars)
    else
        button("Clear copied SVs", ACTION_BUTTON_SIZE, clearCopiedSVs, nil, menuVars)
    end
    saveVariables("copyMenu", menuVars)
    
    if noSVsCopiedInitially then return end
    
    addSeparator()
    simpleActionMenu("Paste SVs at selected notes", 1, pasteSVs, globalVars, menuVars)
end
-- Creates the displace note menu
function displaceNoteMenu()
    local menuVars = {
        distance = 200
    }
    getVariables("displaceNoteMenu", menuVars)
    chooseDistance(menuVars)
    saveVariables("displaceNoteMenu", menuVars)
    
    addSeparator()
    simpleActionMenu("Displace selected notes", 1, displaceNoteSVs, nil, menuVars)
end

-- Creates the displace view menu
function displaceViewMenu()
    local menuVars = {
        distance = 200
    }
    getVariables("displaceViewMenu", menuVars)
    chooseDistance(menuVars)
    saveVariables("displaceViewMenu", menuVars)
    
    addSeparator() 
    simpleActionMenu("Displace view between selected notes", 2, displaceViewSVs, nil, menuVars)
end
-- Creates the fix LN ends menu
function fixLNEndsMenu()
    local menuVars = {
        fixedText = "No flipped LN ends fixed yet"
    }
    getVariables("fixLNEndsMenu", menuVars)
    imgui.Text(menuVars.fixedText)
    helpMarker("If there is a negative SV at an LN end, the LN end will be flipped. This is "..
              "noticable especially for arrow skins and is jarring. This tool will fix that.")
    
    addSeparator()
    simpleActionMenu("Fix flipped LN ends", 0, fixFlippedLNEnds, nil, menuVars)
    saveVariables("fixLNEndsMenu", menuVars)
end
-- Creates the flicker menu
function flickerMenu()
    local menuVars = {
        flickerTypeIndex = 1,
        distance = -69420.727,
        numFlickers = 1
    }
    getVariables("flickerMenu", menuVars)
    chooseFlickerType(menuVars)
    chooseDistance(menuVars)
    chooseNumFlickers(menuVars)
    saveVariables("flickerMenu", menuVars)
    
    addSeparator()
    simpleActionMenu("Add flicker SVs between selected notes", 2, flickerSVs, nil, menuVars)
end
-- Creates the measure menu
function measureMenu()
    local menuVars = {
        unrounded = false,
        nsvDistance = "",
        svDistance = "",
        avgSV = "",
        startDisplacement = "",
        endDisplacement = "",
        avgSVDisplaceless = "",
        roundedNSVDistance = 0,
        roundedSVDistance = 0,
        roundedAvgSV = 0,
        roundedStartDisplacement = 0,
        roundedEndDisplacement = 0,
        roundedAvgSVDisplaceless = 0 
    }
    getVariables("measureMenu", menuVars)
    chooseMeasuredStatsView(menuVars)
    
    addSeparator()
    if menuVars.unrounded then
        displayMeasuredStatsUnrounded(menuVars)
    else
        displayMeasuredStatsRounded(menuVars)
    end
    addPadding()
    imgui.TextDisabled("*** Measuring disclaimer ***")
    toolTip("Measured values might not be 100%% accurate & may not work on older maps")
    
    addSeparator()
    simpleActionMenu("Measure SVs between selected notes", 2, measureSVs, nil, menuVars)
    saveVariables("measureMenu", menuVars)
end
-- Creates the merge menu
function mergeMenu()
     simpleActionMenu("Merge SVs between selected notes", 2, mergeSVs, nil, nil)
end
-- Creates the reverse scroll menu
function reverseScrollMenu()
    local menuVars = {
        distance = 400
    }
    getVariables("reverseScrollMenu", menuVars)
    chooseDistance(menuVars)
    helpMarker("Height at which reverse scroll notes are hit")
    saveVariables("reverseScrollMenu", menuVars)
    
    addSeparator()
    local buttonText = "Reverse scroll between selected notes"
    simpleActionMenu(buttonText, 2, reverseScrollSVs, nil, menuVars)
end
-- Creates the scale (displace) menu
function scaleDisplaceMenu()
    local menuVars = {
        scaleSpotIndex = 1,
        scaleTypeIndex = 1,
        avgSV = 0.6,
        distance = 100,
        ratio = 0.6,
    }
    getVariables("scaleDisplaceMenu", menuVars)
    chooseScaleDisplaceSpot(menuVars)
    chooseScaleType(menuVars)
    saveVariables("scaleDisplaceMenu", menuVars)
    
    addSeparator()
    local buttonText = "Scale SVs between selected notes##displace"
    simpleActionMenu(buttonText, 2, scaleDisplaceSVs, nil, menuVars)
end
-- Creates the scale (multiply) menu
function scaleMultiplyMenu()
    local menuVars = {
        scaleTypeIndex = 1,
        avgSV = 0.6,
        distance = 100,
        ratio = 0.6
    }
    getVariables("scaleMultiplyMenu", menuVars)
    chooseScaleType(menuVars)
    saveVariables("scaleMultiplyMenu", menuVars)
    
    addSeparator()
    local buttonText = "Scale SVs between selected notes##multiply"
    simpleActionMenu(buttonText, 2, scaleMultiplySVs, nil, menuVars)
end
-- Creates the menu for swapping notes
function swapNotesMenu()
     simpleActionMenu("Swap selected notes using SVs", 2, swapNoteSVs, nil, nil)
end

-------------------------------------------------------------------------------------- Menu related

-- Creates the button for exporting/importing current menu settings
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function exportImportSettingsButton(globalVars)
    local buttonText = ": )"
    if globalVars.showExportImportMenu then buttonText = "X" end
    local buttonPressed = imgui.Button(buttonText, EXPORT_BUTTON_SIZE)
    toolTip("Export and import menu settings")
    imgui.SameLine(0, SAMELINE_SPACING)
    if not buttonPressed then return end
    
    globalVars.showExportImportMenu = not globalVars.showExportImportMenu
end
-- Lets you choose global plugin appearance settings
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function choosePluginAppearance(globalVars)
    if not imgui.CollapsingHeader("Plugin appearance settings") then return end
    addPadding()
    chooseUpscroll(globalVars)
    addSeparator()
    chooseStyleTheme(globalVars)
    chooseColorTheme(globalVars)
    addSeparator()
    chooseCursorTrail(globalVars)
    chooseCursorTrailShape(globalVars)
    chooseEffectFPS(globalVars)
    chooseCursorTrailPoints(globalVars)
    chooseCursorShapeSize(globalVars)
    chooseSnakeSpringConstant(globalVars)
    chooseCursorTrailGhost(globalVars)
    addSeparator()
    chooseDrawCapybara(globalVars)
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    chooseDrawCapybara2(globalVars)
end
-- Gives basic info about how to use the plugin
function provideBasicPluginInfo()
    imgui.Text("Steps to use amoguSV:")
    imgui.BulletText("Choose an SV tool")
    imgui.BulletText("Adjust the SV tool's settings")
    imgui.BulletText("Select notes to use the tool at/between")
    imgui.BulletText("Press 'T' on your keyboard")
    addPadding()
end
-- Gives more info about the plugin
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function provideMorePluginInfo(globalVars)
    if not imgui.CollapsingHeader("More info") then return end
    addPadding()
    chooseDontReplaceSV(globalVars)
    addSeparator()
    linkBox("Goofy SV mapping guide",
            "https://docs.google.com/document/d/1ug_WV_BI720617ybj4zuHhjaQMwa0PPekZyJoa17f-I")
    linkBox("GitHub repository", "https://github.com/kloi34/amoguSV")
end
-- Lists keyboard shortcuts for the plugin
function listKeyboardShortcuts()
    if not imgui.CollapsingHeader("Keyboard shortcuts") then return end
    local indentAmount = -6
    imgui.Indent(indentAmount)
    addPadding()
    imgui.BulletText("Ctrl + Shift + Tab = center plugin window")
    toolTip("Useful if the plugin begins or ends up offscreen")
    addSeparator()
    imgui.BulletText("Shift + Tab = focus plugin + navigate inputs")
    toolTip("Useful if you click off the plugin but want to quickly change an input value")
    addSeparator()
    imgui.BulletText("T = activate the big button doing SV stuff")
    toolTip("Use this to do SV stuff for a quick workflow")
    addPadding()
    imgui.Unindent(indentAmount)
end
-- Displays measured SV stats rounded
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function displayMeasuredStatsRounded(menuVars)
    imgui.Columns(2, "Measured SV Stats", false)
    imgui.Text("NSV distance:")
    imgui.Text("SV distance:")
    imgui.Text("Average SV:")
    imgui.Text("Start displacement:")
    imgui.Text("End displacement:")
    imgui.Text("True average SV:")
    imgui.NextColumn()
    imgui.Text(table.concat({menuVars.roundedNSVDistance, " msx"}))
    helpMarker("The normal distance between the start and the end, ignoring SVs")
    imgui.Text(table.concat({menuVars.roundedSVDistance, " msx"}))
    helpMarker("The actual distance between the start and the end, calculated with SVs")
    imgui.Text(table.concat({menuVars.roundedAvgSV, "x"}))
    imgui.Text(table.concat({menuVars.roundedStartDisplacement, " msx"}))
    helpMarker("Calculated using amoguSV displacement metrics, so might not always work")
    imgui.Text(table.concat({menuVars.roundedEndDisplacement, " msx"}))
    helpMarker("Calculated using amoguSV displacement metrics, so might not always work")
    imgui.Text(table.concat({menuVars.roundedAvgSVDisplaceless, "x"}))
    helpMarker("Average SV calculated ignoring the start and end displacement")
    imgui.Columns(1)
end
-- Displays measured SV stats unrounded
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function displayMeasuredStatsUnrounded(menuVars)
    copiableBox("NSV distance", "##nsvDistance", menuVars.nsvDistance)
    copiableBox("SV distance", "##svDistance", menuVars.svDistance)
    copiableBox("Average SV", "##avgSV", menuVars.avgSV)
    copiableBox("Start displacement", "##startDisplacement", menuVars.startDisplacement)
    copiableBox("End displacement", "##endDisplacement", menuVars.endDisplacement)
    copiableBox("True average SV", "##avgSVDisplaceless", menuVars.avgSVDisplaceless)
end
-- Shows the settings menu for the current SV type
-- Returns whether or not any settings changed [Boolean]
-- Parameters
--    currentSVType : current SV type to choose the settings for [String]
--    settingVars   : list of variables used for the current menu [Table]
--    skipFinalSV   : whether or not to skip choosing the final SV [Boolean]
function showSettingsMenu(currentSVType, settingVars, skipFinalSV)
    if currentSVType == "Linear" then
        return linearSettingsMenu(settingVars, skipFinalSV)
    elseif currentSVType == "Exponential" then
        return exponentialSettingsMenu(settingVars, skipFinalSV)
    elseif currentSVType == "Bezier" then
        return bezierSettingsMenu(settingVars, skipFinalSV)
    elseif currentSVType == "Hermite" then
        return hermiteSettingsMenu(settingVars, skipFinalSV)
    elseif currentSVType == "Sinusoidal" then
        return sinusoidalSettingsMenu(settingVars, skipFinalSV)
    elseif currentSVType == "Circular" then
        return circularSettingsMenu(settingVars, skipFinalSV)
    elseif currentSVType == "Random" then
        return randomSettingsMenu(settingVars, skipFinalSV)
    elseif currentSVType == "Custom" then
        return customSettingsMenu(settingVars, skipFinalSV)
    elseif currentSVType == "Combo" then
        return comboSettingsMenu(settingVars)
    end
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
    if imgui.Button("Parse##beizerValues", SECONDARY_BUTTON_SIZE) then
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
-- Provides an import box to parse inputted custom SVs
-- Returns whether new custom SVs were parsed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function importCustomSVs(settingVars)
    local svsParsed = false
    local customSVText = state.GetValue("customSVText") or "Import SV values here"
    local imguiFlag = imgui_input_text_flags.AutoSelectAll
    _, customSVText = imgui.InputText("##customSVs", customSVText, 99999, imguiFlag)
    imgui.SameLine(0, SAMELINE_SPACING)
    if imgui.Button("Parse##customSVs", SECONDARY_BUTTON_SIZE) then
        local regex = "(-?%d*%.?%d+)"
        local values = {}
        for value, _ in string.gmatch(customSVText, regex) do
            table.insert(values, tonumber(value))
        end
        if #values >= 1 then
            settingVars.svMultipliers = values
            settingVars.selectedMultiplierIndex = 1
            settingVars.svPoints = #values
            svsParsed = true
        end
        customSVText = "Import SV values here"
    end
    state.SetValue("customSVText", customSVText)
    helpMarker("Paste custom SV values in the box then hit the parse button (ex. 2 -1 2 -1)")
    return svsParsed
end
-- Updates SVs and SV info stored in the menu
-- Parameters
--    currentSVType : current type of SV being updated [String]
--    globalVars    : list of variables used globally across all menus [Table]
--    menuVars      : list of variables used for the place SV menu [Table]
--    settingVars   : list of variables used for the current SV menu [Table]
function updateMenuSVs(currentSVType, globalVars, menuVars, settingVars)
    local interlaceMultiplier = nil
    if menuVars.interlace then interlaceMultiplier = menuVars.interlaceRatio end
    menuVars.svMultipliers = generateSVMultipliers(currentSVType, settingVars, interlaceMultiplier)
    local svMultipliersNoEndSV = makeDuplicateList(menuVars.svMultipliers)
    table.remove(svMultipliersNoEndSV)
    menuVars.svDistances = calculateDistanceVsTime(globalVars, svMultipliersNoEndSV)
    
    updateFinalSV(settingVars.finalSVIndex, menuVars.svMultipliers, settingVars.customSV)
    updateSVStats(menuVars.svGraphStats, menuVars.svStats, menuVars.svMultipliers,
                  svMultipliersNoEndSV, menuVars.svDistances)
end
-- Updates the final SV of the precalculated menu SVs
-- Parameters
--    finalSVIndex  : index value for the type of final SV [Int]
--    svMultipliers : list of SV multipliers [Table]
--    customSV      : custom SV value [Int/Float]
function updateFinalSV(finalSVIndex, svMultipliers, customSV)
    local finalSVType = FINAL_SV_TYPES[finalSVIndex]
    if finalSVType == "Normal" then return end
    svMultipliers[#svMultipliers] = customSV
end
-- Updates stats for the current menu's SVs
-- Parameters
--    svGraphStats         : list of stats for the SV graphs [Table]
--    svStats              : list of stats for the current menu's SVs [Table]
--    svMultipliers        : list of sv multipliers [Table]
--    svMultipliersNoEndSV : list of sv multipliers, no end multiplier [Table]
--    svDistances          : list of distances calculated from SV multipliers [Table]
function updateSVStats(svGraphStats, svStats, svMultipliers, svMultipliersNoEndSV, svDistances)
    updateGraphStats(svGraphStats, svMultipliers, svDistances)
    svStats.minSV = round(calculateMinValue(svMultipliersNoEndSV), 2)
    svStats.maxSV = round(calculateMaxValue(svMultipliersNoEndSV), 2)
    svStats.avgSV = round(calculateAverage(svMultipliersNoEndSV, true), 3)
end
-- Updates scale stats for SV graphs
-- Parameters
--    graphStats : list of graph scale numbers [Table]
--    svMultipliers : list of SV multipliers[Table]
--    svDistances : list of SV distances [Table]
function updateGraphStats(graphStats, svMultipliers, svDistances)
    graphStats.minScale, graphStats.maxScale = calculatePlotScale(svMultipliers)
    graphStats.distMinScale, graphStats.distMaxScale = calculatePlotScale(svDistances)
end
-- Creates a new window with plots/graphs and stats of the current menu's SVs
-- Parameters
--    windowText      : name of the window [String]
--    svGraphStats    : stats of the SV graphs [Table]
--    svStats         : stats of the SV multipliers [Table]
--    svDistances     : distance vs time list [Table]
--    svMultipliers   : multiplier values of the SVs [Table]
--    stutterDuration : percent duration of first stutter (nil if not stutter SV) [Int]
function makeSVInfoWindow(windowText, svGraphStats, svStats, svDistances, svMultipliers,
                          stutterDuration)
    imgui.Begin(windowText, imgui_window_flags.AlwaysAutoResize)
    imgui.Text("Projected Note Motion:")
    helpMarker("Distance vs Time graph of notes")
    plotSVMotion(svDistances, svGraphStats.distMinScale, svGraphStats.distMaxScale)
    imgui.Text("Projected SVs:")
    plotSVs(svMultipliers, svGraphStats.minScale, svGraphStats.maxScale)
    if stutterDuration then
        displayStutterSVStats(svMultipliers, stutterDuration)
    else
        displaySVStats(svStats)
    end
    imgui.End()
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
    local firstText = table.concat({firstSV, "x  (", firstDuration, "%% duration)"})
    local secondText = table.concat({secondSV, "x  (", secondDuration, "%% duration)"})
    imgui.Text(firstText)
    imgui.Text(secondText)
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
-- Creates a new set of random SV multipliers for the random menu's SVs
-- Parameters
--    settingVars : list of variables used for the random SV menu [Table]
function generateRandomSetMenuSVs(settingVars)
    local randomType = RANDOM_TYPES[settingVars.randomTypeIndex]
    settingVars.svMultipliers = generateRandomSet(settingVars.svPoints + 1, randomType,
                                                  settingVars.randomScale)
end  
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
    if settingVars.svPoints >= #settingVars.svMultipliers then return end
      
    if settingVars.selectedMultiplierIndex > settingVars.svPoints then
        settingVars.selectedMultiplierIndex = settingVars.svPoints
    end
    local difference = #settingVars.svMultipliers - settingVars.svPoints
    for i = 1, difference do
        table.remove(settingVars.svMultipliers)
    end
end
-- Updates SVs and SV info stored in the stutter menu
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function updateStutterMenuSVs(settingVars)
    settingVars.svMultipliers = generateSVMultipliers("Stutter1", settingVars, nil)
    local svMultipliersNoEndSV = makeDuplicateList(settingVars.svMultipliers)
    table.remove(svMultipliersNoEndSV)
    
    settingVars.svMultipliers2 = generateSVMultipliers("Stutter2", settingVars, nil)
    local svMultipliersNoEndSV2 = makeDuplicateList(settingVars.svMultipliers2)
    table.remove(svMultipliersNoEndSV2)
    
    settingVars.svDistances = calculateStutterDistanceVsTime(svMultipliersNoEndSV, 
                                                             settingVars.stutterDuration,
                                                             settingVars.stuttersPerSection)
    settingVars.svDistances2 = calculateStutterDistanceVsTime(svMultipliersNoEndSV2, 
                                                             settingVars.stutterDuration,
                                                             settingVars.stuttersPerSection)
    
    if settingVars.linearlyChange then
        updateFinalSV(settingVars.finalSVIndex, settingVars.svMultipliers2, settingVars.customSV)
        table.remove(settingVars.svMultipliers)
    else
        updateFinalSV(settingVars.finalSVIndex, settingVars.svMultipliers, settingVars.customSV)
    end
    updateGraphStats(settingVars.svGraphStats, settingVars.svMultipliers, settingVars.svDistances)
    updateGraphStats(settingVars.svGraph2Stats, settingVars.svMultipliers2,
                     settingVars.svDistances2)
end
-- Makes the SV info windows for stutter SV
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function displayStutterSVWindows(settingVars)
    if settingVars.linearlyChange then
        startNextWindowNotCollapsed("svInfo2AutoOpen")
        makeSVInfoWindow("SV Info (Starting first SV)", settingVars.svGraphStats, nil,
                         settingVars.svDistances, settingVars.svMultipliers,
                         settingVars.stutterDuration)
        startNextWindowNotCollapsed("svInfo3AutoOpen")
        makeSVInfoWindow("SV Info (Ending first SV)", settingVars.svGraph2Stats, nil,
                         settingVars.svDistances2, settingVars.svMultipliers2,
                         settingVars.stutterDuration)
    else
        startNextWindowNotCollapsed("svInfo1AutoOpen")
        makeSVInfoWindow("SV Info", settingVars.svGraphStats, nil, settingVars.svDistances,
                         settingVars.svMultipliers, settingVars.stutterDuration)
    end
end
-- Adds or clears note times for the 2nd scroll for the splitscroll menu
-- Parameters
--    settingVars          : list of variables used for the current SV menu [Table]
--    noNoteTimesInitially : whether or not there were note times initially [Boolean]
function addOrClearNoteTimes(settingVars, noNoteTimesInitially)
    imgui.Text(#settingVars.noteTimes2.." note times assigned for 2nd scroll")
    
    local buttonText = "Assign selected note times to 2nd scroll"
    button(buttonText, ACTION_BUTTON_SIZE, addSelectedNoteTimes, nil, settingVars)
    
    if noNoteTimesInitially then return end
    if not imgui.Button("Clear all 2nd scroll note times", ACTION_BUTTON_SIZE) then return end
    settingVars.noteTimes2 = {}
end
-- Adds selected note times to the splitscroll 2nd scroll speed list
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function addSelectedNoteTimes(settingVars)
    for _, hitObject in pairs(state.SelectedHitObjects) do
        table.insert(settingVars.noteTimes2, hitObject.StartTime)
    end
    settingVars.noteTimes2 = removeDuplicateValues(settingVars.noteTimes2)
    settingVars.noteTimes2 = table.sort(settingVars.noteTimes2, sortAscending)
end
-- Makes buttons for adding and clearing SVs for the 1st scroll for the splitscroll menu
-- Parameters
--    settingVars    : list of variables used for the current SV menu [Table]
--    noSVsInitially : whether or not there were SVs initially [Boolean]
function buttonsForSVsInScroll1(settingVars, noSVsInitially)
    imgui.Text(#settingVars.svsInScroll1.." SVs assigned for 1st scroll")
    local function addFirstScrollSVs(settingVars)
        local buttonText = "Assign SVs between\nselected notes to 1st scroll"
        if not imgui.Button(buttonText, ACTION_BUTTON_SIZE) then return end
        local offsets = uniqueSelectedNoteOffsets()
        if #offsets < 2 then return end
        
        settingVars.svsInScroll1 = getSVsBetweenOffsets(offsets[1], offsets[#offsets])
    end
    if noSVsInitially then addFirstScrollSVs(settingVars) return end
    buttonClear1stScrollSVs(settingVars)
    imgui.SameLine(0, SAMELINE_SPACING)
    buttonPlace1stScrollSVs(settingVars)
end
-- Makes buttons for adding and clearing SVs for the 2nd scroll for the splitscroll menu
-- Parameters
--    settingVars    : list of variables used for the current SV menu [Table]
--    noSVsInitially : whether or not there were SVs initially [Boolean]
function buttonsForSVsInScroll2(settingVars, noSVsInitially)
    imgui.Text(#settingVars.svsInScroll2.." SVs assigned for 2nd scroll")
    local function addSecondScrollSVs(settingVars)
        local buttonText = "Assign SVs between\nselected notes to 2nd scroll"
        if not imgui.Button(buttonText, ACTION_BUTTON_SIZE) then return end
        local offsets = uniqueSelectedNoteOffsets()
        if #offsets < 2 then return end
        
        settingVars.svsInScroll2 = getSVsBetweenOffsets(offsets[1], offsets[#offsets])
    end
    if noSVsInitially then addSecondScrollSVs(settingVars) return end
    buttonClear2ndScrollSVs(settingVars)
    imgui.SameLine(0, SAMELINE_SPACING)
    buttonPlace2ndScrollSVs(settingVars)
end
-- Makes a button that clears SVs for the 1st scroll for the splitscroll menu
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function buttonClear1stScrollSVs(settingVars)
    local buttonText = "Clear assigned\n 1st scroll SVs"
    if not imgui.Button(buttonText, HALF_ACTION_BUTTON_SIZE) then return end
    settingVars.svsInScroll1 = {}
end
-- Makes a button that places SVs assigned for 1st scroll for the splitscroll menu
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function buttonPlace1stScrollSVs(settingVars)
    local buttonText = "Re-place assigned\n1st scroll SVs"
    if not imgui.Button(buttonText, HALF_ACTION_BUTTON_SIZE) then return end
    
    local svsToAdd = settingVars.svsInScroll1
    local startOffset = svsToAdd[1].StartTime
    local extraOffset = 1/128
    local endOffset = svsToAdd[#svsToAdd].StartTime + extraOffset
    local svsToRemove = getSVsBetweenOffsets(startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Makes a button that clears SVs for the 2nd scroll for the splitscroll menu
-- Parameters
--    settingVars    : list of variables used for the current SV menu [Table]
--    noSVsInitially : whether or not there were SVs initially [Boolean]
function buttonClear2ndScrollSVs(settingVars)
    local buttonText = "Clear assigned\n2nd scroll SVs"
    if not imgui.Button(buttonText, HALF_ACTION_BUTTON_SIZE) then return end
    settingVars.svsInScroll2 = {}
end
-- Makes a button that places SVs assigned for 2nd scroll for the splitscroll menu
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function buttonPlace2ndScrollSVs(settingVars)
    local buttonText = "Re-place assigned\n2nd scroll SVs"
    if not imgui.Button(buttonText, HALF_ACTION_BUTTON_SIZE) then return end
    
    local svsToAdd = settingVars.svsInScroll2
    local startOffset = svsToAdd[1].StartTime
    local extraOffset = 1/128
    local endOffset = svsToAdd[#svsToAdd].StartTime + extraOffset
    local svsToRemove = getSVsBetweenOffsets(startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Creates the export button for Place SV settings
-- Parameters
--    globalVars  : list of variables used globally across all menus [Table]
--    menuVars    : list of setting variables for the current menu [Table]
--    settingVars : list of setting variables for the current sv type [Table]
function exportPlaceSVButton(globalVars, menuVars, settingVars)
    local buttonText = "Export current settings for current menu"
    if not imgui.Button(buttonText, ACTION_BUTTON_SIZE) then return end
    
    local exportList = {}
    local placeType = PLACE_TYPES[globalVars.placeTypeIndex]
    local stillType = placeType == "Still"
    local regularType = placeType == "Standard" or stillType
    local specialType = placeType == "Special"
    local currentSVType
    if regularType then
        currentSVType = STANDARD_SVS[menuVars.svTypeIndex]
    elseif specialType then
        currentSVType = SPECIAL_SVS[menuVars.svTypeIndex]
    end
    exportList[1] = placeType
    exportList[2] = currentSVType
    if regularType then
        table.insert(exportList, tostring(menuVars.interlace))
        table.insert(exportList, menuVars.interlaceRatio)
    end
    if stillType then
        table.insert(exportList, menuVars.noteSpacing)
        table.insert(exportList, menuVars.stillTypeIndex)
        table.insert(exportList, menuVars.stillDistance)
    end
    if currentSVType == "Linear" then
        table.insert(exportList, settingVars.startSV)
        table.insert(exportList, settingVars.endSV)
        table.insert(exportList, settingVars.svPoints)
        table.insert(exportList, settingVars.finalSVIndex)
        table.insert(exportList, settingVars.customSV)
    elseif currentSVType == "Exponential" then
        table.insert(exportList, settingVars.behaviorIndex)
        table.insert(exportList, settingVars.intensity)
        table.insert(exportList, settingVars.verticalShift)
        table.insert(exportList, settingVars.avgSV)
        table.insert(exportList, settingVars.svPoints)
        table.insert(exportList, settingVars.finalSVIndex)
        table.insert(exportList, settingVars.customSV)
    elseif currentSVType == "Bezier" then
        table.insert(exportList, settingVars.x1)
        table.insert(exportList, settingVars.y1)
        table.insert(exportList, settingVars.x2)
        table.insert(exportList, settingVars.y2)
        table.insert(exportList, settingVars.verticalShift)
        table.insert(exportList, settingVars.avgSV)
        table.insert(exportList, settingVars.svPoints)
        table.insert(exportList, settingVars.finalSVIndex)
        table.insert(exportList, settingVars.customSV)
    elseif currentSVType == "Hermite" then
        table.insert(exportList, settingVars.startSV)
        table.insert(exportList, settingVars.endSV)
        table.insert(exportList, settingVars.verticalShift)
        table.insert(exportList, settingVars.avgSV)
        table.insert(exportList, settingVars.svPoints)
        table.insert(exportList, settingVars.finalSVIndex)
        table.insert(exportList, settingVars.customSV)
    elseif currentSVType == "Sinusoidal" then
        table.insert(exportList, settingVars.startSV)
        table.insert(exportList, settingVars.endSV)
        table.insert(exportList, settingVars.curveSharpness)
        table.insert(exportList, settingVars.verticalShift)
        table.insert(exportList, settingVars.periods)
        table.insert(exportList, settingVars.periodsShift)
        table.insert(exportList, settingVars.svsPerQuarterPeriod)
        table.insert(exportList, settingVars.svPoints)
        table.insert(exportList, settingVars.finalSVIndex)
        table.insert(exportList, settingVars.customSV)
    elseif currentSVType == "Circular" then
        table.insert(exportList, settingVars.behaviorIndex)
        table.insert(exportList, settingVars.arcPercent)
        table.insert(exportList, settingVars.avgSV)
        table.insert(exportList, settingVars.verticalShift)
        table.insert(exportList, settingVars.svPoints)
        table.insert(exportList, settingVars.finalSVIndex)
        table.insert(exportList, settingVars.customSV)
        table.insert(exportList, tostring(settingVars.dontNormalize))
    elseif currentSVType == "Random" then
        for i = 1, #settingVars.svMultipliers do
            table.insert(exportList, settingVars.svMultipliers[i])
        end
        table.insert(exportList, settingVars.randomTypeIndex)
        table.insert(exportList, settingVars.randomScale)
        table.insert(exportList, settingVars.svPoints)
        table.insert(exportList, settingVars.finalSVIndex)
        table.insert(exportList, settingVars.customSV)
        table.insert(exportList, tostring(settingVars.dontNormalize))
        table.insert(exportList, settingVars.avgSV)
        table.insert(exportList, settingVars.verticalShift)
    elseif currentSVType == "Custom" then
        for i = 1, #settingVars.svMultipliers do
            table.insert(exportList, settingVars.svMultipliers[i])
        end
        table.insert(exportList, settingVars.selectedMultiplierIndex)
        table.insert(exportList, settingVars.svPoints)
        table.insert(exportList, settingVars.finalSVIndex)
        table.insert(exportList, settingVars.customSV)
    elseif currentSVType == "Stutter" then
        table.insert(exportList, settingVars.startSV)
        table.insert(exportList, settingVars.endSV)
        table.insert(exportList, settingVars.stutterDuration)
        table.insert(exportList, settingVars.stuttersPerSection)
        table.insert(exportList, settingVars.avgSV)
        table.insert(exportList, settingVars.finalSVIndex)
        table.insert(exportList, settingVars.customSV)
        table.insert(exportList, tostring(settingVars.linearlyChange))
        table.insert(exportList, tostring(settingVars.controlLastSV))
    elseif currentSVType == "Teleport Stutter" then
        table.insert(exportList, settingVars.svPercent)
        table.insert(exportList, settingVars.svPercent2)
        table.insert(exportList, settingVars.distance)
        table.insert(exportList, settingVars.mainSV)
        table.insert(exportList, settingVars.mainSV2)
        table.insert(exportList, tostring(settingVars.useDistance))
        table.insert(exportList, tostring(settingVars.linearlyChange))
        table.insert(exportList, settingVars.avgSV)
        table.insert(exportList, settingVars.finalSVIndex)
        table.insert(exportList, settingVars.customSV)
    end
    globalVars.exportData = table.concat(exportList, "|")
end
-- Creates the export button for exporting as custom SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of setting variables for the current menu [Table]
function exportCustomSVButton(globalVars, menuVars)
    local buttonText = "Export current SVs as custom SV data"
    if not imgui.Button(buttonText, ACTION_BUTTON_SIZE) then return end
    
    local multipliersCopy = makeDuplicateList(menuVars.svMultipliers)
    table.remove(multipliersCopy)
    globalVars.exportCustomSVData = table.concat(multipliersCopy, " ")
end
-- Creates the import button for Place SV settings
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function importPlaceSVButton(globalVars)
    local buttonText = "Import settings from pasted data"
    if not imgui.Button(buttonText, ACTION_BUTTON_SIZE) then return end
    
    -- Variant of code based on 
    -- https://stackoverflow.com/questions/6075262/
    --    lua-table-tostringtablename-and-table-fromstringstringtable-functions
    local settingsTable = {}
    for str in string.gmatch(globalVars.importData, "([^|]+)") do
        local num = tonumber(str)
        if num ~= nil then
            str = num
        end
        if str == "false" then
            str = false
        elseif str == "true" then
            str = true
        end
        table.insert(settingsTable, str)
    end
    if #settingsTable < 2 then return end
    
    local placeType = table.remove(settingsTable, 1)
    local currentSVType = table.remove(settingsTable, 1)
    
    local standardPlaceType = placeType == "Standard"
    local specialPlaceType  = placeType == "Special"
    local stillPlaceType    = placeType == "Still"
    
    local menuVars
    if standardPlaceType then menuVars = getStandardPlaceMenuVars() end
    if specialPlaceType  then menuVars = getSpecialPlaceMenuVars() end
    if stillPlaceType    then menuVars = getStillPlaceMenuVars() end
    
    local linearSVType      = currentSVType == "Linear"
    local exponentialSVType = currentSVType == "Exponential"
    local bezierSVType      = currentSVType == "Bezier"
    local hermiteSVType     = currentSVType == "Hermite"
    local sinusoidalSVType  = currentSVType == "Sinusoidal"
    local circularSVType    = currentSVType == "Circular"
    local randomSVType      = currentSVType == "Random"
    local customSVType      = currentSVType == "Custom"
    local stutterSVType     = currentSVType == "Stutter"
    local tpStutterSVType   = currentSVType == "Teleport Stutter"
    
    local settingVars
    if standardPlaceType then
        settingVars = getSettingVars(currentSVType, "Standard")
    elseif stillPlaceType then
        settingVars = getSettingVars(currentSVType, "Still")
    elseif stutterSVType or tpStutterSVType then
        settingVars = getSettingVars(currentSVType, "Special")
    end
    
    if standardPlaceType then globalVars.placeTypeIndex = 1 end
    if specialPlaceType  then globalVars.placeTypeIndex = 2 end
    if stillPlaceType    then globalVars.placeTypeIndex = 3 end
    
    if linearSVType      then menuVars.svTypeIndex = 1 end
    if exponentialSVType then menuVars.svTypeIndex = 2 end
    if bezierSVType      then menuVars.svTypeIndex = 3 end
    if hermiteSVType     then menuVars.svTypeIndex = 4 end
    if sinusoidalSVType  then menuVars.svTypeIndex = 5 end
    if circularSVType    then menuVars.svTypeIndex = 6 end
    if randomSVType      then menuVars.svTypeIndex = 7 end
    if customSVType      then menuVars.svTypeIndex = 8 end
    
    if stutterSVType     then menuVars.svTypeIndex = 1 end
    if tpStutterSVType   then menuVars.svTypeIndex = 2 end
    
    if standardPlaceType or stillPlaceType then
        menuVars.interlace = table.remove(settingsTable, 1)
        menuVars.interlaceRatio = table.remove(settingsTable, 1)
    end
    if stillPlaceType then
        menuVars.noteSpacing = table.remove(settingsTable, 1)
        menuVars.stillTypeIndex = table.remove(settingsTable, 1)
        menuVars.stillDistance = table.remove(settingsTable, 1)
    end
    if linearSVType then
        settingVars.startSV = table.remove(settingsTable, 1)
        settingVars.endSV = table.remove(settingsTable, 1)
        settingVars.svPoints = table.remove(settingsTable, 1)
        settingVars.finalSVIndex = table.remove(settingsTable, 1)
        settingVars.customSV = table.remove(settingsTable, 1)
    elseif exponentialSVType then
        settingVars.behaviorIndex = table.remove(settingsTable, 1)
        settingVars.intensity = table.remove(settingsTable, 1)
        settingVars.verticalShift = table.remove(settingsTable, 1)
        settingVars.avgSV = table.remove(settingsTable, 1)
        settingVars.svPoints = table.remove(settingsTable, 1)
        settingVars.finalSVIndex = table.remove(settingsTable, 1)
        settingVars.customSV = table.remove(settingsTable, 1)
    elseif bezierSVType then
        settingVars.x1 = table.remove(settingsTable, 1)
        settingVars.y1 = table.remove(settingsTable, 1)
        settingVars.x2 = table.remove(settingsTable, 1)
        settingVars.y2 = table.remove(settingsTable, 1)
        settingVars.verticalShift = table.remove(settingsTable, 1)
        settingVars.avgSV = table.remove(settingsTable, 1)
        settingVars.svPoints = table.remove(settingsTable, 1)
        settingVars.finalSVIndex = table.remove(settingsTable, 1)
        settingVars.customSV = table.remove(settingsTable, 1)
    elseif hermiteSVType then
        settingVars.startSV = table.remove(settingsTable, 1)
        settingVars.endSV = table.remove(settingsTable, 1)
        settingVars.verticalShift = table.remove(settingsTable, 1)
        settingVars.avgSV = table.remove(settingsTable, 1)
        settingVars.svPoints = table.remove(settingsTable, 1)
        settingVars.finalSVIndex = table.remove(settingsTable, 1)
        settingVars.customSV = table.remove(settingsTable, 1)
    elseif sinusoidalSVType then
        settingVars.startSV = table.remove(settingsTable, 1)
        settingVars.endSV = table.remove(settingsTable, 1)
        settingVars.curveSharpness = table.remove(settingsTable, 1)
        settingVars.verticalShift = table.remove(settingsTable, 1)
        settingVars.periods = table.remove(settingsTable, 1)
        settingVars.periodsShift = table.remove(settingsTable, 1)
        settingVars.svsPerQuarterPeriod = table.remove(settingsTable, 1)
        settingVars.svPoints = table.remove(settingsTable, 1)
        settingVars.finalSVIndex = table.remove(settingsTable, 1)
        settingVars.customSV = table.remove(settingsTable, 1)
    elseif circularSVType then
        settingVars.behaviorIndex = table.remove(settingsTable, 1)
        settingVars.arcPercent = table.remove(settingsTable, 1)
        settingVars.avgSV = table.remove(settingsTable, 1)
        settingVars.verticalShift = table.remove(settingsTable, 1)
        settingVars.svPoints = table.remove(settingsTable, 1)
        settingVars.finalSVIndex = table.remove(settingsTable, 1)
        settingVars.customSV = table.remove(settingsTable, 1)
        settingVars.dontNormalize = table.remove(settingsTable, 1)
    elseif randomSVType then
        settingVars.verticalShift = table.remove(settingsTable)
        settingVars.avgSV = table.remove(settingsTable)
        settingVars.dontNormalize = table.remove(settingsTable)
        settingVars.customSV = table.remove(settingsTable)
        settingVars.finalSVIndex = table.remove(settingsTable)
        settingVars.svPoints = table.remove(settingsTable)
        settingVars.randomScale = table.remove(settingsTable)
        settingVars.randomTypeIndex = table.remove(settingsTable)
        settingVars.svMultipliers = settingsTable
    elseif customSVType then
        settingVars.customSV = table.remove(settingsTable)
        settingVars.finalSVIndex = table.remove(settingsTable)
        settingVars.svPoints = table.remove(settingsTable)
        settingVars.selectedMultiplierIndex = table.remove(settingsTable)
        settingVars.svMultipliers = settingsTable
    end
    
    if stutterSVType then
        settingVars.startSV = table.remove(settingsTable, 1)
        settingVars.endSV = table.remove(settingsTable, 1)
        settingVars.stutterDuration = table.remove(settingsTable, 1)
        settingVars.stuttersPerSection = table.remove(settingsTable, 1)
        settingVars.avgSV = table.remove(settingsTable, 1)
        settingVars.finalSVIndex = table.remove(settingsTable, 1)
        settingVars.customSV = table.remove(settingsTable, 1)
        settingVars.linearlyChange = table.remove(settingsTable, 1)
        settingVars.controlLastSV = table.remove(settingsTable, 1)
    elseif tpStutterSVType then
        settingVars.svPercent = table.remove(settingsTable, 1)
        settingVars.svPercent2 = table.remove(settingsTable, 1)
        settingVars.distance = table.remove(settingsTable, 1)
        settingVars.mainSV = table.remove(settingsTable, 1)
        settingVars.mainSV2 = table.remove(settingsTable, 1)
        settingVars.useDistance = table.remove(settingsTable, 1)
        settingVars.linearlyChange = table.remove(settingsTable, 1)
        settingVars.avgSV = table.remove(settingsTable, 1)
        settingVars.finalSVIndex = table.remove(settingsTable, 1)
        settingVars.customSV = table.remove(settingsTable, 1)
    end
    
    if standardPlaceType or stillPlaceType then
        updateMenuSVs(currentSVType, globalVars, menuVars, settingVars)
        local labelText = table.concat({currentSVType, "SettingsStandard"})
        saveVariables(labelText, settingVars)
    elseif stillPlaceType then
        updateMenuSVs(currentSVType, globalVars, menuVars, settingVars)
        local labelText = table.concat({currentSVType, "SettingsStill"})
        saveVariables(labelText, settingVars)
    elseif stutterSVType then
        updateStutterMenuSVs(settingVars)
        local labelText = table.concat({currentSVType, "SettingsSpecial"})
        saveVariables(labelText, settingVars)
    elseif tpStutterSVType then
        local labelText = table.concat({currentSVType, "SettingsSpecial"})
        saveVariables(labelText, settingVars)
    end
    
    if standardPlaceType then saveVariables("placeStandardMenu", menuVars) end
    if specialPlaceType  then saveVariables("placeSpecialMenu", menuVars) end
    if stillPlaceType    then saveVariables("placeStillMenu", menuVars) end
    
    globalVars.importData = ""
    globalVars.showExportImportMenu = false
end

---------------------------------------------------------------------------------------------------
-- General Utility Functions ----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------- Drawing

-- Checks and returns whether or not the frame number has changed [Boolean]
-- Parameters
--    currentTime : current in-game time of the plugin [Int/Float]
--    fps         : frames per second set by the user/plugin [Int]
function checkIfFrameChanged(currentTime, fps)
    local oldFrameInfo = {
        frameNumber = 0
    }
    getVariables("oldFrameInfo", oldFrameInfo)
    local newFrameNumber = math.floor(currentTime * fps) % fps
    local frameChanged = oldFrameInfo.frameNumber ~= newFrameNumber
    oldFrameInfo.frameNumber = newFrameNumber
    saveVariables("oldFrameInfo", oldFrameInfo)
    return frameChanged
end
--[[ may implement in the future when making mouse click effects
-- Checks and returns whether or not the mouse has been clicked [Boolean]
function checkIfMouseClicked()
    local mouseDownBefore = state.GetValue("wasMouseDown")
    local mouseDownNow = imgui.IsAnyMouseDown()
    state.SetValue("wasMouseDown", mouseDownNow)
    return (not mouseDownBefore) and mouseDownNow
end
--]]
-- Checks and returns whether or not the mouse position has changed [Boolean]
-- Parameters
--    currentMousePosition : current (x, y) coordinates of the mouse [Table]
function checkIfMouseMoved(currentMousePosition)
    local oldMousePosition = {
        x = 0,
        y = 0
    }
    getVariables("oldMousePosition", oldMousePosition)
    local xChanged = currentMousePosition.x ~= oldMousePosition.x
    local yChanged = currentMousePosition.y ~= oldMousePosition.y
    local mousePositionChanged = xChanged or yChanged
    oldMousePosition.x = currentMousePosition.x
    oldMousePosition.y = currentMousePosition.y
    saveVariables("oldMousePosition", oldMousePosition)
    return mousePositionChanged
end
-- Draws an equilateral triangle
-- Parameters
--    o           : imgui overlay drawlist [imgui.GetOverlayDrawList()]
--    centerPoint : center point of the triangle [Table]
--    size        : radius from triangle center to tip [Int/Float]
--    angle       : rotation angle of the triangle [Int/Float]
--    color       : color of the triangle represented as a uint [Int]
function drawEquilateralTriangle(o, centerPoint, size, angle, color)
    local angle2 = 2 * math.pi / 3 + angle
    local angle3 = 4 * math.pi / 3 + angle
    local x1 = centerPoint.x + size * math.cos(angle)
    local y1 = centerPoint.y + size * math.sin(angle)
    local x2 = centerPoint.x + size * math.cos(angle2)
    local y2 = centerPoint.y + size * math.sin(angle2)
    local x3 = centerPoint.x + size * math.cos(angle3)
    local y3 = centerPoint.y + size * math.sin(angle3)
    local p1 = {x1, y1}
    local p2 = {x2, y2}
    local p3 = {x3, y3}
    o.AddTriangleFilled(p1, p2, p3, color)
end
-- Draws a single glare
-- Parameters
--    o          : [imgui overlay drawlist]
--    coords     : (x, y) coordinates of the glare [Int/Float]
--    size       : size of the glare [Int/Float]
--    glareColor : uint color of the glare [Int]
--    auraColor  : uint color of the aura of the glare [Int]
function drawGlare(o, coords, size, glareColor, auraColor)
    local outerRadius = size
    local innerRadius = outerRadius / 7
    local innerPoints = {}
    local outerPoints = {}
    for i = 1, 4 do
        local angle = math.pi * ((2 * i + 1) / 4)
        local innerX = innerRadius * math.cos(angle)
        local innerY = innerRadius * math.sin(angle)
        local outerX = outerRadius * innerX
        local outerY = outerRadius * innerY
        innerPoints[i] = {innerX + coords[1], innerY + coords[2]}
        outerPoints[i] = {outerX + coords[1], outerY + coords[2]}
    end
    o.AddQuadFilled(innerPoints[1], outerPoints[2], innerPoints[3], outerPoints[4], glareColor)
    o.AddQuadFilled(outerPoints[1], innerPoints[2], outerPoints[3], innerPoints[4], glareColor)
    local circlePoints = 20
    local circleSize1 = size / 1.2
    local circleSize2 = size / 3
    o.AddCircleFilled(coords, circleSize1, auraColor, circlePoints)
    o.AddCircleFilled(coords, circleSize2, auraColor, circlePoints)
end
-- Draws a horizontal pill shape
-- Parameters
--    o              : imgui overlay drawlist [imgui.GetOverlayDrawList()]
--    point1         : (x, y) coordiates of the center of the pill's first circle [Table]
--    point2         : (x, y) coordiates of the center of the pill's second circle [Table]
--    radius         : radius of the circle of the pill [Int/Float]
--    color          : color of the pill represented as a uint [Int]
--    circleSegments : number of segments to draw for the circles in the pill [Int]
function drawHorizontalPillShape(o, point1, point2, radius, color, circleSegments)
    o.AddCircleFilled(point1, radius, color, circleSegments)
    o.AddCircleFilled(point2, radius, color, circleSegments)
    local rectangleStartCoords = relativePoint(point1, 0, radius)
    local rectangleEndCoords = relativePoint(point2, 0, -radius)
    o.AddRectFilled(rectangleStartCoords, rectangleEndCoords, color)
end
-- Returns a 2D (x, y) point [Table]
-- Parameters
--    x : x coordinate of the point [Int/Float]
--    y : y coordinate of the point [Int/Float]
function generate2DPoint(x, y) return {x = x, y = y} end
-- Generates and returns a particle [Table]
-- Parameters
--    x            : starting x coordiate of particle [Int/Float]
--    y            : starting y coordiate of particle [Int/Float]
--    xRange       : range of movement for the x coordiate of the particle [Int/Float]
--    yRange       : range of movement for the y coordiate of the particle [Int/Float]
--    endTime      : time to stop showing particle [Int/Float]
--    showParticle : whether or not to render/draw the particle [Boolean]
function generateParticle(x, y, xRange, yRange, endTime, showParticle)
    local particle = {
        x = x,
        y = y,
        xRange = xRange,
        yRange = yRange,
        endTime = endTime,
        showParticle = showParticle
    }
    return particle
end
-- Returns the current (x, y) coordinates of the mouse [Table]
function getCurrentMousePosition()
    local mousePosition = imgui.GetMousePos()
    return {x = mousePosition[1], y = mousePosition[2]}
end
-- Returns a point relative to a given point [Table]
-- Parameters
--    point   : (x, y) coordinates [Table]
--    xChange : change in x coordinate [Int]
--    yChange : change in y coordinate [Int]
function relativePoint(point, xChange, yChange)
    return {point[1] + xChange, point[2] + yChange}
end
-- Converts an RGBA color value into uint (unsigned integer) and returns the converted value [Int]
-- Parameters
--    r : red value [Int]
--    g : green value [Int]
--    b : blue value [Int]
--    a : alpha value [Int]
function rgbaToUint(r, g, b, a) return a*16^6 + b*16^4 + g*16^2 + r end

------------------------------------------------------------------------------- Notes, SVs, Offsets

-- Adds the final SV to the "svsToAdd" list if there isn't an SV at the end offset already
-- Parameters
--    svsToAdd     : list of SVs to add [Table]
--    endOffset    : millisecond time of the final SV [Int]
--    svMultiplier : the final SV's multiplier [Int/Float]
function addFinalSV(svsToAdd, endOffset, svMultiplier)
    local sv = map.GetScrollVelocityAt(endOffset) 
    local svExistsAtEndOffset = sv and (sv.StartTime == endOffset)
    if svExistsAtEndOffset then return end
    
    addSVToList(svsToAdd, endOffset, svMultiplier, true)
end
-- Adds an SV with the start offset into the list if there isn't an SV there already
-- Parameters
--    svs         : list of SVs [Table]
--    startOffset : start offset in milliseconds for the list of SVs [Int]
function addStartSVIfMissing(svs, startOffset)
    if #svs ~= 0 and svs[1].StartTime == startOffset then return end
    addSVToList(svs, startOffset, getSVMultiplierAt(startOffset), false) 
end
-- Creates and adds a new SV to an existing list of SVs
-- Parameters
--    svList     : list of SVs [Table]
--    offset     : offset in milliseconds for the new SV [Int/Float]
--    multiplier : multiplier for the new SV [Int/Float]
--    endOfList  : whether or not to add the SV to the end of the list (else, the front) [Boolean]
function addSVToList(svList, offset, multiplier, endOfList)
    local newSV = utils.CreateScrollVelocity(offset, multiplier)
    if endOfList then table.insert(svList, newSV) return end
    table.insert(svList, 1, newSV)
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
-- Calculates the total msx displacement over time for a given set of SVs
-- Returns a table of total displacements [Table]
-- Parameters
--    svs         : list of ordered svs to calculate displacement with [Table]
--    startOffset : starting time for displacement calculation [Int/Float]
--    endOffset   : ending time for displacement calculation [Int/Float]
function calculateDisplacementFromSVs(svs, startOffset, endOffset)
    return calculateDisplacementsFromSVs(svs, {startOffset, endOffset})[2]
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
    addSVToList(svs, lastOffset, 0, true)
    local j = 1
    for i = 1, (#svs - 1) do
        local lastSV = svs[i]
        local nextSV = svs[i + 1]
        local svTimeDifference = nextSV.StartTime - lastSV.StartTime
        while nextSV.StartTime > offsets[j] do
            local svToOffsetTime = offsets[j] - lastSV.StartTime
            local displacement = totalDisplacement
            if svToOffsetTime > 0 then
                displacement = displacement + lastSV.Multiplier * svToOffsetTime
            end
            table.insert(displacements, displacement)
            j = j + 1
        end
        if svTimeDifference > 0 then
            local thisDisplacement = svTimeDifference * lastSV.Multiplier
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
    if stillType == "End" or stillType == "Otua" then
        extraDisplacement = stillDistance - finalDisplacements[#finalDisplacements]
    end
    if stillType ~= "No" then
        for i = 1, #finalDisplacements do
            finalDisplacements[i] = finalDisplacements[i] + extraDisplacement
        end
    end
    return finalDisplacements
end
-- Checks to see if enough notes are selected (ONLY works for minimumNotes = 0, 1, or 2)
-- Returns whether or not there are enough notes [Boolean]
-- Parameters
--    minimumNotes : minimum number of notes needed to be selected [Int]
function checkEnoughSelectedNotes(minimumNotes)
    if minimumNotes == 0 then return true end
    local selectedNotes = state.SelectedHitObjects
    local numSelectedNotes = #selectedNotes
    if numSelectedNotes == 0 then return false end
    if minimumNotes == 1 then return true end
    if numSelectedNotes > map.GetKeyCount() then return true end
    return selectedNotes[1].StartTime ~= selectedNotes[numSelectedNotes].StartTime
end
-- Gets removable SVs that are in the map at the exact time where an SV will get added
-- Parameters
--    svsToRemove   : list of SVs to remove [Table]
--    svTimeIsAdded : list of SVs times added [Table]
--    startOffset   : starting offset to remove after [Int]
--    endOffset     : end offset to remove before [Int]
function getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    for _, sv in pairs(map.ScrollVelocities) do
        local svIsInRange = sv.StartTime >= startOffset - 1 and sv.StartTime <= endOffset + 1
        if svIsInRange then 
            local svIsRemovable = svTimeIsAdded[sv.StartTime]
            if svIsRemovable then table.insert(svsToRemove, sv) end
        end
    end
end
-- Returns the SV multiplier at a specified offset in the map [Int/Float]
-- Parameters
--    offset : millisecond time [Int/Float]
function getSVMultiplierAt(offset)
    local sv = map.GetScrollVelocityAt(offset) 
    if sv then return sv.Multiplier end
    return 1
end
-- Returns an chronologically ordered list of SVs between two offsets/times[Table]
-- Parameters
--    startOffset : start time in milliseconds [Int/Float]
--    endOffset   : end time in milliseconds [Int/Float]
function getSVsBetweenOffsets(startOffset, endOffset)
    local svsBetweenOffsets = {}
    for _, sv in pairs(map.ScrollVelocities) do
        local svIsInRange = sv.StartTime >= startOffset and sv.StartTime < endOffset
        if svIsInRange then table.insert(svsBetweenOffsets, sv) end
    end
    return table.sort(svsBetweenOffsets, sortAscendingStartTime)
end
-- Returns a usable displacement multiplier for a given offset [Int/Float]
--[[
-- Current implementation:
-- 64 until 2^18 = 262144 ms ~4.3 min, then —> 32
-- 32 until 2^19 = 524288 ms ~8.7 min, then —> 16
-- 16 until 2^20 = 1048576 ms ~17.4 min, then —> 8
-- 8 until 2^21 = 2097152 ms ~34.9 min, then —> 4
-- 4 until 2^22 = 4194304 ms ~69.9 min, then —> 2
-- 2 until 2^23 = 8388608 ms ~139.8 min, then —> 1
--]]
-- Parameters
--    offset: time in milliseconds [Int]
function getUsableDisplacementMultiplier(offset)
    local exponent = 23 - math.floor(math.log(math.abs(offset) + 1) / math.log(2))
    if exponent > 6 then exponent = 6 end
    return 2 ^ exponent
end
-- Adds a new displacing SV to a list of SVs to place and adds that SV time to a hash list
-- Parameters
--    svsToAdd               : list of displacing SVs to add to [Table]
--    svTimeIsAdded          : hash list indicating whether an SV time exists already [Table]
--    svTime                 : time to add the displacing SV at [Int/Float]
--    displacement           : amount that the SV will displace [Int/Float]
--    displacementMultiplier : displacement multiplier value [Int/Float]
function prepareDisplacingSV(svsToAdd, svTimeIsAdded, svTime, displacement, displacementMultiplier)
    svTimeIsAdded[svTime] = true
    local currentSVMultiplier = getSVMultiplierAt(svTime) 
    local newSVMultiplier = displacementMultiplier * displacement + currentSVMultiplier
    addSVToList(svsToAdd, svTime, newSVMultiplier, true)
end
-- Adds new displacing SVs to a list of SVs to place and adds removable SV times to another list
-- Parameters
--    offset             : general offset in milliseconds to displace SVs at [Int]
--    svsToAdd           : list of displacing SVs to add to [Table]
--    svTimeIsAdded      : hash list indicating whether an SV time exists already [Table]
--    beforeDisplacement : amount to displace before (nil value if not) [Int/Float]
--    atDisplacement     : amount to displace at (nil value if not) [Int/Float]
--    afterDisplacement  : amount to displace after (nil value if not) [Int/Float]
function prepareDisplacingSVs(offset, svsToAdd, svTimeIsAdded, beforeDisplacement, atDisplacement,
                              afterDisplacement)
    local displacementMultiplier = getUsableDisplacementMultiplier(offset)
    local duration = 1 / displacementMultiplier
    if beforeDisplacement then
        local timeBefore = offset - duration
        prepareDisplacingSV(svsToAdd, svTimeIsAdded, timeBefore, beforeDisplacement,
                            displacementMultiplier)
    end
    if atDisplacement then
        local timeAt = offset
        prepareDisplacingSV(svsToAdd, svTimeIsAdded, timeAt, atDisplacement,
                            displacementMultiplier)
    end
    if afterDisplacement then
        local timeAfter = offset + duration
        prepareDisplacingSV(svsToAdd, svTimeIsAdded, timeAfter, afterDisplacement,
                            displacementMultiplier)
    end
end
-- Removes and adds SVs
-- Parameters
--    svsToRemove : list of SVs to remove [Table]
--    svsT2oAdd    : list of SVs to add [Table]
function removeAndAddSVs(svsToRemove, svsToAdd)
    if #svsToAdd == 0 then return end
    local editorActions = {
        utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToRemove),
        utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svsToAdd)
    }
    actions.PerformBatch(editorActions)
end
-- Finds and returns a list of all unique offsets of notes between a start and an end time [Table]
-- Parameters
--    startOffset : start time in milliseconds [Int/Float]
--    endOffset   : end time in milliseconds [Int/Float]
function uniqueNoteOffsetsBetween(startOffset, endOffset)
    local noteOffsetsBetween = {}
    for _, hitObject in pairs(map.HitObjects) do
        if hitObject.StartTime >= startOffset and hitObject.StartTime <= endOffset then
            table.insert(noteOffsetsBetween, hitObject.StartTime)
        end
    end
    noteOffsetsBetween = removeDuplicateValues(noteOffsetsBetween)
    noteOffsetsBetween = table.sort(noteOffsetsBetween, sortAscending)
    return noteOffsetsBetween
end
-- Finds and returns a list of all unique offsets of notes between selected notes [Table]
function uniqueNoteOffsetsBetweenSelected()
    local selectedNoteOffsets = uniqueSelectedNoteOffsets()
    local startOffset = selectedNoteOffsets[1]
    local endOffset = selectedNoteOffsets[#selectedNoteOffsets]
    return uniqueNoteOffsetsBetween(startOffset, endOffset)
end
-- Finds unique offsets of all notes currently selected in the editor
-- Returns a list of unique offsets (in increasing order) of selected notes [Table]
function uniqueSelectedNoteOffsets()
    local offsets = {}
    for i, hitObject in pairs(state.SelectedHitObjects) do
        offsets[i] = hitObject.StartTime
    end
    offsets = removeDuplicateValues(offsets)
    offsets = table.sort(offsets, sortAscending)
    return offsets
end

---------------------------------------------------------------------------------------------- Math

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
-- Normalizes a set of values to achieve a target average
-- Parameters
--    values                    : set of numbers [Table]
--    targetAverage             : average value that is aimed for [Int/Float]
--    includeLastValueInAverage : whether or not to include the last value in the average [Boolean]
function normalizeValues(values, targetAverage, includeLastValueInAverage)
    local avgValue = calculateAverage(values, includeLastValueInAverage)
    if avgValue == 0 then return end
    for i = 1, #values do
        values[i] = (values[i] * targetAverage) / avgValue
    end
end
-- Rounds a number to a given amount of decimal places
-- Returns the rounded number [Int/Float]
-- Parameters
--    number        : number to round [Int/Float]
--    decimalPlaces : number of decimal places to round the number to [Int]
function round(number, decimalPlaces)
    local multiplier = 10 ^ decimalPlaces
    return math.floor(multiplier * number + 0.5) / multiplier
end
-- Evaluates a simplified one-dimensional cubic bezier expression with points (0, p2, p3, 1)
-- Returns the result of the bezier evaluation [Int/Float]
-- Parameters
--    p2 : second coordinate of the cubic bezier [Int/Float]
--    p3 : third coordinate of the cubic bezier [Int/Float]
--    t  : time to evaluate the cubic bezier at [Int/Float]
function simplifiedCubicBezier(p2, p3, t)
    return 3*t*(1-t)^2*p2 + 3*t^2*(1-t)*p3 + t^3
end
-- Evaluates a simplified one-dimensional quadratic bezier expression with points (0, p2, 1)
-- Returns the result of the bezier evaluation [Int/Float]
-- Parameters
--    p2 : second coordinate of the quadratic bezier [Int/Float]
--    t  : time to evaluate the quadratic bezier at [Int/Float]
function simplifiedQuadraticBezier(p2, t)
    return 2*t*(1-t)*p2 + t^2
end
-- Evaluates a simplified one-dimensional hermite related (?) spline for SV purposes
-- Returns the result of the hermite evaluation [Int/Float]
-- Parameters
--    m1 : slope at first point [Int/Float]
--    m2 : slope at second point [Int/Float]
--    y2 : y coordinate of second point [Int/Float]
--    t  : time to evaluate the hermite spline at [Int/Float]
function simplifiedHermite(m1, m2, y2, t)
    local a = m1 + m2 - 2 * y2
    local b = 3 * y2 - 2 * m1 - m2
    local c = m1
    return a * t^3 + b * t^2 + c * t 
end
-- Sorting function for numbers that returns whether a < b [Boolean]
-- Parameters
--    a : first number [Int/Float]
--    b : second number [Int/Float]
function sortAscending(a, b) return a < b end
-- Sorting function for SVs 'a' and 'b' that returns whether a.StartTime < b.StartTime [Boolean]
-- Parameters
--    a : first SV
--    b : second SV
function sortAscendingStartTime(a, b) return a.StartTime < b.StartTime end

-------------------------------------------------------------------------------- Graph/Plot Related

-- Calculates distance vs time values of a note given a set of SV values
-- Returns the list of distances [Table]
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    svValues   : set of SV values [Table]
function calculateDistanceVsTime(globalVars, svValues)
    local distance = 0
    local multiplier = 1
    if globalVars.upscroll then multiplier = -1 end
    local distancesBackwards = {multiplier * distance}
    local svValuesBackwards = getReverseList(svValues)
    for i = 1, #svValuesBackwards do
        distance = distance + (multiplier * svValuesBackwards[i])
        table.insert(distancesBackwards, distance)
    end
    return getReverseList(distancesBackwards)
end
-- Returns the minimum value from a list of values [Int/Float]
-- Parameters
--    values : list of numerical values [Table]
function calculateMinValue(values) return math.min(table.unpack(values)) end
-- Returns the maximum value from a list of values [Int/Float]
-- Parameters
--    values : list of numerical values [Table]
function calculateMaxValue(values) return math.max(table.unpack(values)) end
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
    return getReverseList(distancesBackwards)
end
-- Creates a distance vs time graph/plot of SV motion
-- Parameters
--    noteDistances : list of note distances [Table]
--    minScale      : minimum scale of the plot [Int/Float]
--    maxScale      : maximum scale of the plot [Int/Float]
function plotSVMotion(noteDistances, minScale, maxScale)
    local plotSize = PLOT_GRAPH_SIZE
    imgui.PlotLines("##motion", noteDistances, #noteDistances, 0, "", minScale, maxScale, plotSize)
end
-- Creates a bar graph/plot of SVs
-- Parameters
--    svVals   : list of numerical SV values [Table]    
--    minScale : minimum scale of the plot [Int/Float]
--    maxScale : maximum scale of the plot [Int/Float]
function plotSVs(svVals, minScale, maxScale)
    local plotSize = PLOT_GRAPH_SIZE
    imgui.PlotHistogram("##svplot", svVals, #svVals, 0, "", minScale, maxScale, plotSize)
end


-------------------------------------------------------------------------------------- Abstractions

-- Creates an imgui button
-- Parameters
--    text       : text on the button [String]
--    size       : dimensions of the button [Table]
--    func       : function to execute once button is pressed [Function]
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function button(text, size, func, globalVars, menuVars)
    if not imgui.Button(text, size) then return end
    if globalVars and menuVars then func(globalVars, menuVars) return end
    if globalVars then func(globalVars) return end
    if menuVars then func(menuVars) return end
    func()
end
-- Creates an imgui combo
-- Returns the updated index of the item in the list that is selected [Int]
-- Parameters
--    label     : label for the combo [String]
--    list      : list for the combo to use [Table]
--    listIndex : current index of the item from the list being selected in the combo [Int]
function combo(label, list, listIndex)
    local oldComboIndex = listIndex - 1
    local _, newComboIndex = imgui.Combo(label, oldComboIndex, list, #list)
    return newComboIndex + 1
end
-- Executes a function if a key is pressed
-- Parameters
--    key        : key to be pressed [keys.~, from Quaver's MonoGame.Framework.Input.Keys enum]
--    func       : function to execute once key is pressed [Function]
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function executeFunctionIfKeyPressed(key, func, globalVars, menuVars)
    if not utils.IsKeyPressed(key) then return end
    if globalVars and menuVars then func(globalVars, menuVars) return end
    if globalVars then func(globalVars) return end
    if menuVars then func(menuVars) return end
    func()
end
-- Constructs a new reverse-order list from an existing list
-- Returns the reversed list [Table]
-- Parameters
--    list : list to be reversed [Table]
function getReverseList(list)
    local reverseList = {}
    for i = 1, #list do
        table.insert(reverseList, list[#list + 1 - i])
    end
    return reverseList
end
-- Returns a new duplicate list [Table]
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
-- Creates a simple action menu + button that does SV things
-- Parameters
--    buttonText   : text on the button that appears [String]
--    minimumNotes : minimum number of notes to select before the action button appears [String]
--    actionfunc   : function to execute once button is pressed [Function]
--    globalVars   : list of variables used globally across all menus [Table]
--    menuVars     : list of variables used for the current menu [Table]
function simpleActionMenu(buttonText, minimumNotes, actionfunc, globalVars, menuVars)    
    local enoughSelectedNotes = checkEnoughSelectedNotes(minimumNotes)
    local infoText = table.concat({"Select ", minimumNotes, " or more notes"})
    if not enoughSelectedNotes then imgui.Text(infoText) return end
    
    button(buttonText, ACTION_BUTTON_SIZE, actionfunc, globalVars, menuVars)
    toolTip("Press ' T ' on your keyboard to do the same thing as this button")
    executeFunctionIfKeyPressed(keys.T, actionfunc, globalVars, menuVars)
end
-- Initializes and returns a default svGraphStats object [Table]
function createSVGraphStats()
    local svGraphStats = {
        minScale = 0,
        maxScale = 0,
        distMinScale = 0,
        distMaxScale = 0
    }
    return svGraphStats
end
-- Initializes and returns a default svStats object [Table]
function createSVStats()
    local svStats = {
            minSV = 0,
            maxSV = 0,
            avgSV = 0
        }
    return svStats
end

---------------------------------------------------------------------------------------------------
-- Choose Functions (Sorted Alphabetically) -------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Lets you choose the multipliers for adding combo SVs
-- Returns whether or not the multipliers changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseAddComboMultipliers(settingVars)
    local oldValues = {settingVars.comboMultiplier1, settingVars.comboMultiplier2}
    local _, newValues = imgui.InputFloat2("ax + by", oldValues, "%.2f")
    helpMarker("a = multiplier for SV Type 1, b = multiplier for SV Type 2")
    settingVars.comboMultiplier1 = newValues[1]
    settingVars.comboMultiplier2 = newValues[2]
    return oldValues[1] ~= newValues[1] or oldValues[2] ~= newValues[2]
end
-- Lets you choose the arc percent
-- Returns whether or not the arc percent changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseArcPercent(settingVars) 
    local oldPercent = settingVars.arcPercent
    local _, newPercent = imgui.SliderInt("Arc Percent", oldPercent, 1, 99, oldPercent.."%%")
    newPercent = clampToInterval(newPercent, 1, 99)
    settingVars.arcPercent = newPercent 
    return oldPercent ~= newPercent 
end
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
-- Lets you choose the color theme of the plugin
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseColorTheme(globalVars)
    globalVars.colorThemeIndex = combo("Color Theme", COLOR_THEMES, globalVars.colorThemeIndex)
    
    local currentTheme = COLOR_THEMES[globalVars.colorThemeIndex]
    local isRGBColorTheme = currentTheme == "Tobi's RGB Glass" or
                            currentTheme == "Glass + RGB" or  
                            currentTheme == "Incognito + RGB" or
                            currentTheme == "RGB Gamer Mode" or
                            currentTheme == "edom remag BGR" or
                            currentTheme == "BGR + otingocnI"
    if not isRGBColorTheme then return end
    
    chooseRGBPeriod(globalVars)
end
-- Lets you choose the combo SV phase number
-- Returns whether or not the phase number changed [Boolean]
-- Parameters
--    settingVars   : list of variables used for the current menu [Table]
--    maxComboPhase : maximum value allowed for combo phase [Int]
function chooseComboPhase(settingVars, maxComboPhase)
    local oldPhase = settingVars.comboPhase
    _, settingVars.comboPhase = imgui.InputInt("Combo Phase", oldPhase, 1, 1)
    settingVars.comboPhase = clampToInterval(settingVars.comboPhase, 0, maxComboPhase)
    return oldPhase ~= settingVars.comboPhase
end
-- Lets you choose the combo SV combo interaction type
-- Returns whether or not the interaction type changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseComboSVOption(settingVars)
    local oldIndex = settingVars.comboTypeIndex
    settingVars.comboTypeIndex = combo("Combo Type", COMBO_SV_TYPE, settingVars.comboTypeIndex)
    local currentComboType = COMBO_SV_TYPE[settingVars.comboTypeIndex]
    local addTypeChanged = false
    if currentComboType == "Add" then
        addTypeChanged = chooseAddComboMultipliers(settingVars)
    end
    return (oldIndex ~= settingVars.comboTypeIndex) or addTypeChanged
end
-- Lets you choose a constant amount to shift SVs
-- Returns whether or not the shift amount changed [Boolean]
-- Parameters
--    settingVars  : list of variables used for the current menu [Table]
--    defaultShift : default value for the shift when reset [Int/Float]
function chooseConstantShift(settingVars, defaultShift)
    local oldShift = settingVars.verticalShift
    if imgui.Button("Reset##verticalShift", SECONDARY_BUTTON_SIZE) then
        settingVars.verticalShift = defaultShift
    end
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.7 - SAMELINE_SPACING)
    local _, newShift = imgui.InputFloat("Vertical Shift", settingVars.verticalShift, 0, 0, "%.3fx")
    imgui.PopItemWidth()
    settingVars.verticalShift = newShift
    return oldShift ~= newShift
end
-- Lets you choose whether or not to control the second SV for stutter SV
-- Returns whether or not the choice changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseControlSecondSV(settingVars)
    local oldChoice = settingVars.controlLastSV
    imgui.AlignTextToFramePadding()
    imgui.Text("Control:")
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("First SV", not settingVars.controlLastSV) then
        settingVars.controlLastSV = false
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Last SV", settingVars.controlLastSV) then
        settingVars.controlLastSV = true
    end
    addPadding()
    local choiceChanged = oldChoice ~= settingVars.controlLastSV
    if choiceChanged then settingVars.stutterDuration = 100 - settingVars.stutterDuration end
    return choiceChanged
end
-- Lets you choose the cursor trail of the mouse
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseCursorTrail(globalVars)
    globalVars.cursorTrailIndex = combo("Cursor Trail", CURSOR_TRAILS, globalVars.cursorTrailIndex)
end
-- Lets you choose whether or not the cursor trail will gradually become transparent
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseCursorTrailGhost(globalVars)
    local currentTrail = CURSOR_TRAILS[globalVars.cursorTrailIndex]
    if currentTrail ~= "Snake" then return end
    
    _, globalVars.cursorTrailGhost = imgui.Checkbox("No Ghost", globalVars.cursorTrailGhost)
end
-- Lets you choose the number of points for the cursor trail
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseCursorTrailPoints(globalVars)
    local currentTrail = CURSOR_TRAILS[globalVars.cursorTrailIndex]
    if currentTrail ~= "Snake" then return end
    
    local label = "Trail Points"
    _, globalVars.cursorTrailPoints = imgui.InputInt(label, globalVars.cursorTrailPoints, 1, 1)
    local maxPoints = MAX_CURSOR_TRAIL_POINTS
    globalVars.cursorTrailPoints = clampToInterval(globalVars.cursorTrailPoints, 2, maxPoints)
end
-- Lets you choose the cursor trail shape type
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseCursorTrailShape(globalVars)
    local currentTrail = CURSOR_TRAILS[globalVars.cursorTrailIndex]
    if currentTrail ~= "Snake" then return end
    
    local label = "Trail Shape"
    globalVars.cursorTrailShapeIndex = combo(label, TRAIL_SHAPES, globalVars.cursorTrailShapeIndex)
end
-- Lets you choose the size of the cursor shapes
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseCursorShapeSize(globalVars)
    local currentTrail = CURSOR_TRAILS[globalVars.cursorTrailIndex]
    if currentTrail ~= "Snake" then return end
    
    local label = "Shape Size"
    _, globalVars.cursorTrailSize =  imgui.InputInt(label, globalVars.cursorTrailSize, 1, 1)
    globalVars.cursorTrailSize = clampToInterval(globalVars.cursorTrailSize, 1, 100)
end
-- Lets you choose SV curve sharpness
-- Returns whether or not the curve sharpness changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseCurveSharpness(settingVars)
    local oldSharpness = settingVars.curveSharpness
    if imgui.Button("Reset##curveSharpness", SECONDARY_BUTTON_SIZE) then
        settingVars.curveSharpness = 50
    end
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.7 - SAMELINE_SPACING)
    local _, newSharpness = imgui.DragInt("Curve Sharpness", settingVars.curveSharpness, 1, 1,
                                          100, "%d%%")
    imgui.PopItemWidth()
    newSharpness = clampToInterval(newSharpness, 1, 100)
    settingVars.curveSharpness = newSharpness
    return oldSharpness ~= newSharpness
end
-- Lets you choose custom multipliers for custom SV
-- Returns whether or not any custom multipliers changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseCustomMultipliers(settingVars)
    imgui.BeginChild("Custom Multipliers", {imgui.GetContentRegionAvailWidth(), 90}, true)
    for i = 1, #settingVars.svMultipliers do   
        local selectableText = table.concat({i, " )   ", settingVars.svMultipliers[i]})
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
-- Lets you choose a distance
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseDistance(menuVars)
    _, menuVars.distance = imgui.InputFloat("Distance", menuVars.distance, 0, 0, "%.3f msx")
end
-- Lets you choose the distance back for splitscroll
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseDistanceBack(settingVars)
    _, settingVars.distanceBack = imgui.InputFloat("Split Distance", settingVars.distanceBack,
                                                   0, 0, "%.3f msx")
    helpMarker("Splitscroll distance to separate the two scrolls planes\n(1,000,000 = default)")
end
-- Lets you choose whether or not to replace SVs when placing SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseDontReplaceSV(globalVars)
    local label = "Dont replace SVs when placing regular SVs"
    _, globalVars.dontReplaceSV = imgui.Checkbox(label, globalVars.dontReplaceSV)
end
-- Lets you choose whether or not to draw a capybara on screen
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseDrawCapybara(globalVars)
    _, globalVars.drawCapybara = imgui.Checkbox("Capybara", globalVars.drawCapybara)
    helpMarker("Draws a capybara at the bottom right of the screen")
end
-- Lets you choose whether or not to draw the second capybara on screen
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseDrawCapybara2(globalVars)
    _, globalVars.drawCapybara2 = imgui.Checkbox("Capybara 2", globalVars.drawCapybara2)
    helpMarker("Draws a capybara at the bottom left of the screen")
end
-- Lets you choose which edit tool to use
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseEditTool(globalVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Current Tool:")
    imgui.SameLine(0, SAMELINE_SPACING)
    globalVars.editToolIndex = combo("##edittool", EDIT_SV_TOOLS, globalVars.editToolIndex)
    
    local svTool = EDIT_SV_TOOLS[globalVars.editToolIndex]
    if svTool == "Add Teleport"     then toolTip("Add a large teleport SV to move far away") end
    if svTool == "Copy & Paste"     then toolTip("Copy SVs and paste them somewhere else") end
    if svTool == "Displace Note"    then toolTip("Move where notes are hit on the screen") end
    if svTool == "Displace View"    then toolTip("Temporarily displace the playfield view") end
    if svTool == "Fix LN Ends"      then toolTip("Fix flipped LN ends") end 
    if svTool == "Flicker"          then toolTip("Flash notes on and off the screen") end
    if svTool == "Measure"          then toolTip("Get stats about SVs in a section") end
    if svTool == "Merge"            then toolTip("Combine SVs that overlap") end
    if svTool == "Reverse Scroll"   then toolTip("Reverse the scroll direction using SVs") end
    if svTool == "Scale (Multiply)" then toolTip("Scale SV values by multiplying") end
    if svTool == "Scale (Displace)" then toolTip("Scale SV values by adding teleport SVs") end
    if svTool == "Swap Notes"       then toolTip("Swap positions of notes using SVs") end
end
-- Lets you choose the frames per second of a plugin cursor effect
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseEffectFPS(globalVars)
    local currentTrail = CURSOR_TRAILS[globalVars.cursorTrailIndex]
    if currentTrail ~= "Snake" then return end
    
    _, globalVars.effectFPS = imgui.InputInt("Effect FPS", globalVars.effectFPS, 1, 1)
    helpMarker("Set this to a multiple of UPS or FPS to make cursor effects smooth")
    globalVars.effectFPS = clampToInterval(globalVars.effectFPS, 2, 1000)
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
        imgui.PopItemWidth()
    else
        imgui.Indent(DEFAULT_WIDGET_WIDTH * 0.35 + 24)
    end
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.5)
    settingVars.finalSVIndex = combo("Final SV", FINAL_SV_TYPES, settingVars.finalSVIndex)
    helpMarker("Final SV won't be placed if there's already an SV at the end time")
    if finalSVType ~= "Custom" then
        imgui.Unindent(DEFAULT_WIDGET_WIDTH * 0.35 + 24)
    end
    imgui.PopItemWidth()
    return (oldIndex ~= settingVars.finalSVIndex) or (oldCustomSV ~= settingVars.customSV)
end
-- Lets you choose the first height/displacement for splitscroll
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseFirstHeight(settingVars)
    _, settingVars.height1 = imgui.InputFloat("1st Height", settingVars.height1, 0, 0, "%.3f msx")
    helpMarker("Height at which notes are hit at on screen for the 1st scroll speed")
end
-- Lets you choose the first scroll speed for splitscroll
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseFirstScrollSpeed(settingVars)
    local text = "1st Scroll Speed"
    _, settingVars.scrollSpeed1 = imgui.InputFloat(text, settingVars.scrollSpeed1, 0, 0, "%.2fx")
end
-- Lets you choose the flicker type
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseFlickerType(menuVars)
    menuVars.flickerTypeIndex = combo("Flicker Type", FLICKER_TYPES, menuVars.flickerTypeIndex)
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
-- Lets you choose the interlace
-- Returns whether or not the interlace settings changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseInterlace(menuVars)
    local oldInterlace = menuVars.interlace
    _, menuVars.interlace = imgui.Checkbox("Interlace", menuVars.interlace)
    local interlaceChanged = oldInterlace ~= menuVars.interlace
    if not menuVars.interlace then return interlaceChanged end
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.5)
    local oldRatio = menuVars.interlaceRatio
    _, menuVars.interlaceRatio = imgui.InputFloat("Ratio##interlace", menuVars.interlaceRatio,
                                                  0, 0, "%.2f")
    imgui.PopItemWidth()
    return interlaceChanged or oldRatio ~= menuVars.interlaceRatio
end
-- Lets you choose whether or not to linearly change a stutter over time
-- Returns whether or not the choice changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseLinearlyChange(settingVars)
    local oldChoice = settingVars.linearlyChange
    local _, newChoice = imgui.Checkbox("Change stutter over time", oldChoice)
    settingVars.linearlyChange = newChoice
    return oldChoice ~= newChoice
end
-- Lets you choose the main SV multiplier of a teleport stutter
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseMainSV(settingVars)
    local label = "Main SV"
    if settingVars.linearlyChange then label = label.." (start)" end
    _, settingVars.mainSV = imgui.InputFloat(label, settingVars.mainSV, 0, 0, "%.2fx")
    helpMarker("This SV will last ~99.99%% of the stutter")
    if not settingVars.linearlyChange then return end
    
   _, settingVars.mainSV2 = imgui.InputFloat("Main SV (end)", settingVars.mainSV2, 0, 0, "%.2fx")
end
-- Lets you choose a rounded or unrounded view of SV stats on the measure SV menu
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseMeasuredStatsView(menuVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("View values:")
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Rounded", not menuVars.unrounded) then
        menuVars.unrounded = false
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Unrounded", menuVars.unrounded) then
        menuVars.unrounded = true
    end
end
-- Lets you choose the mspf (milliseconds per frame) for splitscroll
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseMSPF(settingVars)
    local _, newMSPF = imgui.InputFloat("ms Per Frame", settingVars.msPerFrame, 0.5, 0.5, "%.1f")
    newMSPF = forceHalf(newMSPF)
    newMSPF = clampToInterval(newMSPF, 4, 1000)
    settingVars.msPerFrame = newMSPF
    helpMarker("Number of milliseconds splitscroll will display a set of SVs before jumping to "..
               "the next set of SVs")
end
-- Lets you choose to not normalize values
-- Returns whether or not the setting changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current SV menu [Table]
function chooseNoNormalize(settingVars)
    addPadding()
    local oldChoice = settingVars.dontNormalize
    local _, newChoice = imgui.Checkbox("Don't normalize to average SV", oldChoice)
    settingVars.dontNormalize = newChoice
    return oldChoice ~= newChoice
end
-- Lets you choose the note spacing
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseNoteSpacing(menuVars)
    _, menuVars.noteSpacing = imgui.InputFloat("Note Spacing", menuVars.noteSpacing, 0, 0, "%.2fx")
end
-- Lets you
-- Lets you choose the number of flickers
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseNumFlickers(menuVars)
    _, menuVars.numFlickers = imgui.InputInt("Flickers", menuVars.numFlickers, 1, 1)
    menuVars.numFlickers = clampToInterval(menuVars.numFlickers, 1, 9999)
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
-- Lets you choose the place SV type
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function choosePlaceSVType(globalVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("  Type : ")
    imgui.SameLine(0, SAMELINE_SPACING)
    globalVars.placeTypeIndex = combo("##placeType", PLACE_TYPES, globalVars.placeTypeIndex)
    local placeType = PLACE_TYPES[globalVars.placeTypeIndex]
    if placeType == "Still" then toolTip("Still keeps notes normal distance/spacing apart") end
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
    settingVars.randomTypeIndex = combo("Random Type", RANDOM_TYPES, settingVars.randomTypeIndex)
    return oldIndex ~= settingVars.randomTypeIndex
end
-- Lets you choose a ratio
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseRatio(menuVars)
    _, menuVars.ratio = imgui.InputFloat("Ratio", menuVars.ratio, 0, 0, "%.3f")
end
-- Lets you choose the length in seconds of one RGB color cycle
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseRGBPeriod(globalVars)
    _, globalVars.rgbPeriod = imgui.InputFloat("RGB cycle length", globalVars.rgbPeriod, 0, 0,
                                               "%.0f seconds")
    globalVars.rgbPeriod = clampToInterval(globalVars.rgbPeriod, MIN_RGB_CYCLE_TIME,
                                           MAX_RGB_CYCLE_TIME)
end
-- Lets you choose the second height/displacement for splitscroll
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseSecondHeight(settingVars)
    _, settingVars.height2 = imgui.InputFloat("2nd Height", settingVars.height2, 0, 0, "%.3f msx")
    helpMarker("Height at which notes are hit at on screen for the 2nd scroll speed")
end
-- Lets you choose the second scroll speed for splitscroll
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseSecondScrollSpeed(settingVars)
    local text = "2nd Scroll Speed"
    _, settingVars.scrollSpeed2 = imgui.InputFloat(text, settingVars.scrollSpeed2, 0, 0, "%.2fx")
end
-- Lets you choose the spot to displace when adding scaling SVs
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseScaleDisplaceSpot(menuVars)
    menuVars.scaleSpotIndex = combo("Displace Spot", DISPLACE_SCALE_SPOTS, menuVars.scaleSpotIndex)
end
-- Lets you choose how to scale SVs
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseScaleType(menuVars)
    local label = "Scale Type"
    menuVars.scaleTypeIndex = combo(label, SCALE_TYPES, menuVars.scaleTypeIndex)
    
    local scaleType = SCALE_TYPES[menuVars.scaleTypeIndex]
    if scaleType == "Average SV"        then chooseAverageSV(menuVars) end
    if scaleType == "Absolute Distance" then chooseDistance(menuVars) end
    if scaleType == "Relative Ratio"    then chooseRatio(menuVars) end
end
-- Lets you choose the "spring constant" for the snake
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseSnakeSpringConstant(globalVars)
    local currentTrail = CURSOR_TRAILS[globalVars.cursorTrailIndex]
    if currentTrail ~= "Snake" then return end
    
    local newValue = globalVars.snakeSpringConstant
    _, newValue = imgui.InputFloat("Reactiveness##snake", newValue, 0, 0, "%.2f")
    helpMarker("Pick any number from 0.01 to 1")
    globalVars.snakeSpringConstant = clampToInterval(newValue, 0.01, 1)
end
-- Lets you choose the special SV type
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseSpecialSVType(menuVars)
    local emoticonIndex = menuVars.svTypeIndex + #STANDARD_SVS
    local label = "  "..EMOTICONS[emoticonIndex]
    menuVars.svTypeIndex = combo(label, SPECIAL_SVS, menuVars.svTypeIndex)
end
-- Lets you choose the standard SV type
-- Returns whether or not the SV type changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseStandardSVType(menuVars)
    local oldIndex = menuVars.svTypeIndex
    local label = " "..EMOTICONS[oldIndex]
    menuVars.svTypeIndex = combo(label, STANDARD_SVS, menuVars.svTypeIndex)
    return oldIndex ~= menuVars.svTypeIndex
end
-- Lets you choose the standard SV types
-- Returns whether or not any of the SV types changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseStandardSVTypes(settingVars)
    local oldIndex1 = settingVars.svType1Index
    local oldIndex2 = settingVars.svType2Index
    settingVars.svType1Index = combo("SV type 1", STANDARD_SVS_COMBOLESS, settingVars.svType1Index)
    settingVars.svType2Index = combo("SV type 2", STANDARD_SVS_COMBOLESS, settingVars.svType2Index)
    return (oldIndex2 ~= settingVars.svType2Index) or (oldIndex1 ~= settingVars.svType1Index)
end
-- Lets you choose a start and an end SV
-- Returns whether or not the start or end SVs changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseStartEndSVs(settingVars)
    if settingVars.linearlyChange == false then
        local oldValue = settingVars.startSV
        local _, newValue = imgui.InputFloat("SV Value", oldValue, 0, 0, "%.2fx")
        settingVars.startSV = newValue
        return oldValue ~= newValue
    end
    local buttonPressed = imgui.Button("Swap", SECONDARY_BUTTON_SIZE)
    local oldValues = {settingVars.startSV, settingVars.endSV}
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.7 - SAMELINE_SPACING)
    local _, newValues = imgui.InputFloat2("Start/End SV", oldValues, "%.2fx")
    imgui.PopItemWidth()
    settingVars.startSV = newValues[1]
    settingVars.endSV = newValues[2]
    if buttonPressed then
        settingVars.startSV = oldValues[2]
        settingVars.endSV = oldValues[1]
    end
    return buttonPressed or oldValues[1] ~= newValues[1] or oldValues[2] ~= newValues[2]
end
-- Lets you choose a start SV percent
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseStartSVPercent(settingVars)
    local label1 = "Start SV %"
    if settingVars.linearlyChange then label1 = label1.." (start)" end
    _, settingVars.svPercent = imgui.InputFloat(label1, settingVars.svPercent, 1, 1, "%.2f%%")
    helpMarker("%% distance between notes") 
    if not settingVars.linearlyChange then return end
    
    local label2 = "Start SV % (end)"
    _, settingVars.svPercent2 = imgui.InputFloat(label2, settingVars.svPercent2, 1, 1, "%.2f%%")
end
-- Lets you choose the still type
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseStillType(menuVars)
    local stillType = STILL_TYPES[menuVars.stillTypeIndex]
    local dontChooseDistance = stillType == "No" or
                               stillType == "Auto" or
                               stillType == "Otua"
    local indentWidth = DEFAULT_WIDGET_WIDTH * 0.5 + 16
    if dontChooseDistance then
        imgui.Indent(indentWidth)
    else
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.6 - 5)
        _, menuVars.stillDistance = imgui.InputFloat("##still", menuVars.stillDistance, 0, 0,
                                                     "%.2f msx")
        imgui.SameLine(0, SAMELINE_SPACING)
        imgui.PopItemWidth()
    end
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.4)
    menuVars.stillTypeIndex = combo("Displacement", STILL_TYPES, menuVars.stillTypeIndex)
    
    if stillType == "No"    then toolTip("Don't use an initial or end displacement") end
    if stillType == "Start" then toolTip("Use an initial starting displacement for the still") end
    if stillType == "End"   then toolTip("Have a displacement to end at for the still") end
    if stillType == "Auto"  then toolTip("Use last displacement of the previous still to start") end
    if stillType == "Otua"  then toolTip("Use next displacement of the next still to end at") end
    
    if dontChooseDistance then
        imgui.Unindent(indentWidth)
    end
    imgui.PopItemWidth()
end
-- Lets you choose the duration of a stutter SV
-- Returns whether or not the duration changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseStutterDuration(settingVars)
    local oldDuration = settingVars.stutterDuration
    if settingVars.controlLastSV then oldDuration = 100 - oldDuration end
    local _, newDuration = imgui.SliderInt("Duration", oldDuration, 1, 99, oldDuration.."%%")
    newDuration = clampToInterval(newDuration, 1, 99)
    local durationChanged = oldDuration ~= newDuration
    if settingVars.controlLastSV then newDuration = 100 - newDuration end
    settingVars.stutterDuration = newDuration
    return durationChanged
end
-- Lets you choose the number of stutters per section
-- Returns whether or not the number of stutters changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseStuttersPerSection(settingVars)
    local oldNumber = settingVars.stuttersPerSection
    local _, newNumber = imgui.InputInt("Stutters", oldNumber, 1, 1)
    helpMarker("Number of stutters per section")
    newNumber = clampToInterval(newNumber, 1, 100)
    settingVars.stuttersPerSection = newNumber
    return oldNumber ~= newNumber
end
-- Lets you choose the style theme of the plugin
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseStyleTheme(globalVars)
    globalVars.styleThemeIndex = combo("Style Theme", STYLE_THEMES, globalVars.styleThemeIndex)
end
-- Lets you choose the behavior of SVs
-- Returns whether or not the behavior changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseSVBehavior(settingVars)
    local oldBehaviorIndex = settingVars.behaviorIndex
    imgui.AlignTextToFramePadding()
    imgui.Text("Behavior:")
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    local behavior = SV_BEHAVIORS[settingVars.behaviorIndex]
    local slowDownText = SV_BEHAVIORS[1]
    local speedUpText = SV_BEHAVIORS[2]
    local slowDown = behavior == slowDownText
    local speedUp = behavior == speedUpText
    if imgui.RadioButton(slowDownText, slowDown) then
        settingVars.behaviorIndex = 1
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton(speedUpText, speedUp) then
        settingVars.behaviorIndex = 2
    end
    addSeparator()
    return oldBehaviorIndex ~= settingVars.behaviorIndex
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
-- Lets you choose whether or not the plugin will do things upscroll
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseUpscroll(globalVars)
     _, globalVars.upscroll = imgui.Checkbox("Upscroll, not downscroll", globalVars.upscroll)
     helpMarker("Flips the distance vs time graph for upscroll players")
end
-- Lets you choose whether to use distance or not
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseUseDistance(settingVars)
    local label = "Use distance for start SV"
    _, settingVars.useDistance = imgui.Checkbox(label, settingVars.useDistance)
end

---------------------------------------------------------------------------------------------------
-- Doing SV Stuff ---------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------ Generating SVs

-- Returns generated sv multipliers [Table]
-- Parameters
--    svType              : type of SV to generate [String]
--    settingVars         : list of variables used for the current menu [Table]
--    interlaceMultiplier : interlace multiplier [Int/Float]
function generateSVMultipliers(svType, settingVars, interlaceMultiplier)
    local multipliers = {727, 69}
    if svType == "Linear" then
        multipliers = generateLinearSet(settingVars.startSV, settingVars.endSV, 
                                        settingVars.svPoints + 1)
    elseif svType == "Exponential" then
        local behavior = SV_BEHAVIORS[settingVars.behaviorIndex]
        multipliers = generateExponentialSet(behavior, settingVars.svPoints + 1, settingVars.avgSV,
                                             settingVars.intensity, settingVars.verticalShift)
    elseif svType == "Bezier" then
        multipliers = generateBezierSet(settingVars.x1, settingVars.y1, settingVars.x2,
                                        settingVars.y2, settingVars.avgSV, settingVars.svPoints + 1,
                                        settingVars.verticalShift)
    elseif svType == "Hermite" then
        multipliers = generateHermiteSet(settingVars.startSV, settingVars.endSV,
                                         settingVars.verticalShift, settingVars.avgSV, 
                                         settingVars.svPoints + 1)
    elseif svType == "Sinusoidal" then
        multipliers = generateSinusoidalSet(settingVars.startSV, settingVars.endSV,
                                            settingVars.periods, settingVars.periodsShift,
                                            settingVars.svsPerQuarterPeriod,
                                            settingVars.verticalShift, settingVars.curveSharpness)
    elseif svType == "Circular" then
        local behavior = SV_BEHAVIORS[settingVars.behaviorIndex]
        multipliers = generateCircularSet(behavior, settingVars.arcPercent, settingVars.avgSV, 
                                          settingVars.verticalShift, settingVars.svPoints + 1,
                                          settingVars.dontNormalize)
    elseif svType == "Random" then
        if #settingVars.svMultipliers == 0 then
            generateRandomSetMenuSVs(settingVars)
        end
        multipliers = getRandomSet(settingVars.svMultipliers, settingVars.avgSV,
                                   settingVars.verticalShift, settingVars.dontNormalize)
    elseif svType == "Custom" then
        multipliers = generateCustomSet(settingVars.svMultipliers)
    elseif svType == "Combo" then
        local svType1 = STANDARD_SVS[settingVars.svType1Index]
        local settingVars1 = getSettingVars(svType1, "Combo1")
        local multipliers1 = generateSVMultipliers(svType1, settingVars1, nil)
        local labelText1 = table.concat({svType1, "SettingsCombo1"})
        saveVariables(labelText1, settingVars1)
        local svType2 = STANDARD_SVS[settingVars.svType2Index]
        local settingVars2 = getSettingVars(svType2, "Combo2")
        local multipliers2 = generateSVMultipliers(svType2, settingVars2, nil)
        local labelText2 = table.concat({svType2, "SettingsCombo2"})
        saveVariables(labelText2, settingVars2)
        local comboType = COMBO_SV_TYPE[settingVars.comboTypeIndex]
        multipliers = generateComboSet(multipliers1, multipliers2, settingVars.comboPhase,
                                       comboType, settingVars.comboMultiplier1,
                                       settingVars.comboMultiplier2, settingVars.dontNormalize,
                                       settingVars.avgSV, settingVars.verticalShift)
    elseif svType == "Stutter1" then
        multipliers = generateStutterSet(settingVars.startSV, settingVars.stutterDuration,
                                         settingVars.avgSV, settingVars.controlLastSV)
    elseif svType == "Stutter2" then
        multipliers = generateStutterSet(settingVars.endSV, settingVars.stutterDuration,
                                         settingVars.avgSV, settingVars.controlLastSV)
    end
    if interlaceMultiplier then
        local newMultipliers = {}
        for i = 1 , #multipliers do
            table.insert(newMultipliers, multipliers[i])
            table.insert(newMultipliers, multipliers[i] * interlaceMultiplier)
        end
        if settingVars.avgSV and not settingVars.dontNormalize then
            normalizeValues(newMultipliers, settingVars.avgSV, false)
        end
        multipliers = newMultipliers
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
    if numValues < 2 then return linearSet end
    
    local increment = (endValue - startValue) / (numValues - 1)
    for i = 1, (numValues - 1) do
        table.insert(linearSet, startValue + i * increment)
    end
    return linearSet
end
-- Returns a set of exponential values [Table]
-- Parameters
--    behavior      : behavior of the values (increase/speed up, or decrease/slow down) [String]
--    numValues     : total number of values in the exponential set [Int]
--    avgValue      : average value of the set [Int/Float]
--    intensity     : value determining sharpness/rapidness of exponential change [Int/Float]
--    verticalShift : constant to add to each value in the set at very the end [Int/Float]
function generateExponentialSet(behavior, numValues, avgValue, intensity, verticalShift)
    avgValue = avgValue - verticalShift
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
    for i = 1, #exponentialSet do
        exponentialSet[i] = exponentialSet[i] + verticalShift
    end
    return exponentialSet
end
-- Returns a set of cubic bezier values [Table]
-- Parameters
--    x1            : x-coordinate of the first (inputted) cubic bezier point [Int/Float]
--    y1            : y-coordinate of the first (inputted) cubic bezier point [Int/Float]
--    x2            : x-coordinate of the second (inputted) cubic bezier point [Int/Float]
--    y2            : y-coordinate of the second (inputted) cubic bezier point [Int/Float]
--    avgValue      : average value of the set [Int/Float]
--    numValues     : total number of values in the bezier set [Int]
--    verticalShift : constant to add to each value in the set at very the end [Int/Float]
function generateBezierSet(x1, y1, x2, y2, avgValue, numValues, verticalShift)
    avgValue = avgValue - verticalShift
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
            local xPositionGuess = simplifiedCubicBezier(x1, x2, timeGuesses[j])
            if xPositionGuess < targetXPositions[j] then
                timeGuesses[j] = timeGuesses[j] + timeIncrement
            elseif xPositionGuess > targetXPositions[j] then
                timeGuesses[j] = timeGuesses[j] - timeIncrement
            end
        end
    end
    local yPositions = {0}
    for i = 1, #timeGuesses do
        local yPosition = simplifiedCubicBezier(y1, y2, timeGuesses[i])
        table.insert(yPositions, yPosition)
    end
    local bezierSet = {}
    for i = 1, #yPositions - 1 do
        local slope = (yPositions[i + 1] - yPositions[i]) * numValues
        table.insert(bezierSet, slope)
    end
    normalizeValues(bezierSet, avgValue, false)
    for i = 1, #bezierSet do
        bezierSet[i] = bezierSet[i] + verticalShift
    end
    return bezierSet
end
-- Returns a set of hermite spline related (?) values [Table]
-- Parameters
--    startValue    : intended first value of the set [Int/Float]
--    endValue      : intended last value of the set [Int/Float]
--    verticalShift : constant to add to each value in the set at very the end [Int/Float]
--    avgValue      : average value of the set [Int/Float]
--    numValues     : total number of values in the bezier set [Int]
function generateHermiteSet(startValue, endValue, verticalShift, avgValue, numValues)
    avgValue = avgValue - verticalShift
    local xCoords = generateLinearSet(0, 1, numValues)
    local yCoords = {}
    for i = 1, #xCoords do
        yCoords[i] = simplifiedHermite(startValue, endValue, avgValue, xCoords[i])
    end
    local hermiteSet = {}
    for i = 1, #yCoords - 1 do
        local startY = yCoords[i]
        local endY = yCoords[i + 1]
        hermiteSet[i] = (endY - startY) * (numValues - 1)
    end
    --normalizeValues(hermiteSet, avgValue, false)
    for i = 1, #hermiteSet do
        hermiteSet[i] = hermiteSet[i] + verticalShift
    end
    table.insert(hermiteSet, avgValue)
    return hermiteSet
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
    local totalValues = valuesPerQuarterPeriod * quarterPeriods
    local amplitudes = generateLinearSet(startAmplitude, endAmplitude, totalValues + 1)
    local normalizedSharpness
    if curveSharpness > 50 then
        normalizedSharpness = math.sqrt((curveSharpness - 50) * 2)
    else
        normalizedSharpness = (curveSharpness / 50) ^ 2
    end
    for i = 0, totalValues do
        local angle = (math.pi / 2) * ((i / valuesPerQuarterPeriod) + quarterPeriodsShift)
        local value = amplitudes[i + 1] * (math.abs(math.sin(angle))^(normalizedSharpness))
        value = value * getSignOfNumber(math.sin(angle)) + verticalShift
        table.insert(sinusoidalSet, value)
    end
    return sinusoidalSet
end
-- Returns a set of circular values [Table]
-- Parameters
--    behavior      : description of how the set changes (speeds up or slows down) [String]
--    arcPercent    : arc percent of a semicircle to generate values from [Int]
--    avgValue      : average value of the set [Int/Float]
--    verticalShift : constant to add to each value in the set at very the end [Int/Float]
--    numValues     : total number of values in the circular set [Int]
--    dontNormalize : Whether or not to normalize values to the target average value [Boolean]
function generateCircularSet(behavior, arcPercent, avgValue, verticalShift, numValues,
                             dontNormalize)
    local increaseValues = (behavior == "Speed up")
    avgValue = avgValue - verticalShift
    local startingAngle = math.pi * (arcPercent / 100)
    local angles = generateLinearSet(startingAngle, 0, numValues)
    local yCoords = {}
    for i = 1, #angles do
        local angle = round(angles[i], 8)
        local x = math.cos(angle)
        yCoords[i] = -avgValue * math.sqrt(1 - x^2)
    end
    local circularSet = {}
    for i = 1, #yCoords - 1 do
        local startY = yCoords[i]
        local endY = yCoords[i + 1]
        circularSet[i] = (endY - startY) * (numValues - 1)
    end
    if not increaseValues then circularSet = getReverseList(circularSet) end
    if not dontNormalize then normalizeValues(circularSet, avgValue, true) end
    for i = 1, #circularSet do
        circularSet[i] = circularSet[i] + verticalShift
    end
    table.insert(circularSet, avgValue)
    return circularSet
end
-- Returns a modified set of random values [Table]
-- Parameters
--    values        : list of random values [Table]
--    avgValue      : average value of the set [Int/Float]
--    verticalShift : constant to add to each value in the set at very the end [Int/Float]
--    dontNormalize : whether or not to normalize values to the avg value [Boolean]
function getRandomSet(values, avgValue, verticalShift, dontNormalize)
    avgValue = avgValue - verticalShift
    local randomSet = {}
    for i = 1, #values do
        table.insert(randomSet, values[i])
    end
    if not dontNormalize then
        normalizeValues(randomSet, avgValue, false)
    end
    for i = 1, #randomSet do
        randomSet[i] = randomSet[i] + verticalShift
    end
    return randomSet
end
-- Returns a set of random values [Table]
-- Parameters
--    numValues   : total number of values in the exponential set [Int]
--    randomType  : type of random distribution to use [String]
--    randomScale : how much to scale random values [Int/Float]
function generateRandomSet(numValues, randomType, randomScale)
    local randomSet = {}
    for i = 1, numValues do
        if randomType == "Uniform" then
            local randomValue = randomScale * 2 * (0.5 - math.random())
            table.insert(randomSet, randomValue)
        elseif randomType == "Normal" then
            -- Box-Muller transformation
            local u1 = math.random()
            local u2 = math.random()
            local randomIncrement = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
            local randomValue = randomScale * randomIncrement
            table.insert(randomSet, randomValue)
        end
    end
    return randomSet
end
-- Returns a set of custom values [Table]
-- Parameters
--    values : list of custom values [Table]
function generateCustomSet(values)
    local newValues = makeDuplicateList(values)
    local averageMultiplier = calculateAverage(newValues, true)
    table.insert(newValues, averageMultiplier)
    return newValues
end
-- Returns a set of combo values [Table]
-- Parameters
--    values1          : first set for the combo [Table]
--    values2          : second set for the combo [Table]
--    comboPhase       : amount to phase the second set of values into the first set [Int]
--    comboType        : type of combo for overlapping/phased values [String]
--    comboMultiplier1 : multiplying value for the first set in "Add" type combos [Int/Float]
--    comboMultiplier2 : multiplying value for the second set in "Add" type combos [Int/Float]
--    dontNormalize    : whether or not to normalize values to the avg value [Boolean]
--    avgValue         : average value of the set [Int/Float]
--    verticalShift    : constant to add to each value in the set at very the end [Int/Float]
function generateComboSet(values1, values2, comboPhase, comboType, comboMultiplier1,
                          comboMultiplier2, dontNormalize, avgValue, verticalShift)
    local lastValue1 = table.remove(values1)
    local lastValue2 = table.remove(values2)
    local comboValues = {}
    
    local endIndex1 = #values1 - comboPhase
    local startIndex1 = comboPhase + 1
    local endIndex2 = comboPhase - #values1
    local startIndex2 = #values1 + #values2 + 1 - comboPhase
    
    for i = 1, endIndex1 do
        table.insert(comboValues, values1[i])
    end
    for i = 1, endIndex2 do
        table.insert(comboValues, values2[i])
    end
    
    if comboType ~= "Remove" then
        local comboValues1StartIndex = endIndex1 + 1
        local comboValues1EndIndex = startIndex2 - 1
        local comboValues2StartIndex = endIndex2 + 1
        local comboValues2EndIndex = startIndex1 - 1
        
        local comboValues1 = {}
        for i = comboValues1StartIndex, comboValues1EndIndex do
            table.insert(comboValues1, values1[i])
        end
        local comboValues2 = {}
        for i = comboValues2StartIndex, comboValues2EndIndex do
            table.insert(comboValues2, values2[i])
        end
        for i = 1, #comboValues1 do
            local comboValue1 = comboValues1[i]
            local comboValue2 = comboValues2[i]
            local finalValue
            if comboType == "Add" then
                finalValue = comboMultiplier1 * comboValue1 + comboMultiplier2 * comboValue2
            elseif comboType == "Cross Multiply" then
                finalValue = comboValue1 * comboValue2
            elseif comboType == "Min" then
                finalValue = math.min(comboValue1, comboValue2)
            elseif comboType == "Max" then
                finalValue = math.max(comboValue1, comboValue2)
            end
            table.insert(comboValues, finalValue)
        end
    end
    
    for i = startIndex1, #values2 do
        table.insert(comboValues, values2[i])
    end
    for i = startIndex2, #values1 do
        table.insert(comboValues, values1[i])
    end
    
    if #comboValues == 0 then table.insert(comboValues, 1) end
    if (comboPhase - #values2 >= 0) then
        table.insert(comboValues, lastValue1)
    else
        table.insert(comboValues, lastValue2)
    end
    
    avgValue = avgValue - verticalShift
    if not dontNormalize then
        normalizeValues(comboValues, avgValue, false)
    end
    for i = 1, #comboValues do
        comboValues[i] = comboValues[i] + verticalShift
    end
    
    return comboValues
end
-- Returns a set of stutter values [Table]
-- Parameters
--    stutterValue     : value of the stutter [Int/Float]
--    stutterDuration  : duration of the stutter (out of 100) [Int]
--    avgValue         : average value [Int/Float]
--    controlLastValue : whether or not the provided SV is the second SV [Boolean]
function generateStutterSet(stutterValue, stutterDuration, avgValue, controlLastValue)
    local durationPercent = stutterDuration / 100
    if controlLastValue then durationPercent = 1 - durationPercent end
    local otherValue = (avgValue - stutterValue * durationPercent) / (1 - durationPercent)
    local stutterSet = {stutterValue, otherValue, avgValue}
    if controlLastValue then stutterSet = {otherValue, stutterValue, avgValue} end
    return stutterSet
end

------------------------------------------------------------------------------------- Acting on SVs

-- Places standard SVs between selected notes
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function placeSVs(globalVars, menuVars)
    local placingStillSVs = menuVars.noteSpacing ~= nil
    local numMultipliers = #menuVars.svMultipliers
    local offsets = uniqueSelectedNoteOffsets()
    if placingStillSVs then
        offsets = uniqueNoteOffsetsBetweenSelected()
    end
    local firstOffset = offsets[1]
    local lastOffset = offsets[#offsets]
    if placingStillSVs then offsets = {firstOffset, lastOffset} end
    local svsToAdd = {}
    local svsToRemove = getSVsBetweenOffsets(firstOffset, lastOffset)
    if (not placingStillSVs) and globalVars.dontReplaceSV then
        svsToRemove = {}
    end
    for i = 1, #offsets - 1 do
        local startOffset = offsets[i]
        local endOffset = offsets[i + 1]
        local svOffsets = generateLinearSet(startOffset, endOffset, #menuVars.svDistances)
        for j = 1, #svOffsets - 1 do
            local offset = svOffsets[j]
            local multiplier = menuVars.svMultipliers[j]
            addSVToList(svsToAdd, offset, multiplier, true)
        end
    end
    local lastMultiplier = menuVars.svMultipliers[numMultipliers]
    addFinalSV(svsToAdd, lastOffset, lastMultiplier)
    removeAndAddSVs(svsToRemove, svsToAdd)
    if placingStillSVs then placeStillSVs(menuVars) end
end
-- Places still SVs between selected notes
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function placeStillSVs(menuVars)
    local stillType = STILL_TYPES[menuVars.stillTypeIndex]
    local noteSpacing = menuVars.noteSpacing
    local stillDistance = menuVars.stillDistance
    local noteOffsets = uniqueNoteOffsetsBetweenSelected()
    local firstOffset = noteOffsets[1]
    local lastOffset = noteOffsets[#noteOffsets]
    if stillType == "Auto" then
        local multiplier = getUsableDisplacementMultiplier(firstOffset)
        local duration = 1 / multiplier
        local timeBefore = firstOffset - duration
        local multiplierBefore = getSVMultiplierAt(timeBefore)
        stillDistance = multiplierBefore * duration
    elseif stillType == "Otua" then
        local multiplier = getUsableDisplacementMultiplier(lastOffset)
        local duration = 1 / multiplier
        local timeAt = firstOffset
        local multiplierAt = getSVMultiplierAt(timeAt)
        stillDistance = -multiplierAt * duration
    end
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local svsBetweenOffsets = getSVsBetweenOffsets(firstOffset, lastOffset)
    local svDisplacements = calculateDisplacementsFromSVs(svsBetweenOffsets, noteOffsets)
    local nsvDisplacements = calculateDisplacementsFromNotes(noteOffsets, noteSpacing)
    local finalDisplacements = calculateStillDisplacements(stillType, stillDistance,
                                                           svDisplacements, nsvDisplacements)
    for i = 1, #noteOffsets do
        local noteOffset = noteOffsets[i]
        local beforeDisplacement = nil
        local atDisplacement = 0
        local afterDisplacement = nil
        if i ~= #noteOffsets then
            atDisplacement = -finalDisplacements[i]
            afterDisplacement = 0
        end
        if i ~= 1 then 
            beforeDisplacement = finalDisplacements[i]
        end
        prepareDisplacingSVs(noteOffset, svsToAdd, svTimeIsAdded, beforeDisplacement,
                             atDisplacement, afterDisplacement)
    end
    getRemovableSVs(svsToRemove, svTimeIsAdded, firstOffset, lastOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Places stutter SVs between selected notes
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function placeStutterSVs(settingVars)
    local lastFirstStutter = settingVars.startSV
    local lastMultiplier = settingVars.svMultipliers[3]
    if settingVars.linearlyChange then 
        lastFirstStutter = settingVars.endSV
        lastMultiplier = settingVars.svMultipliers2[3]
    end
    local offsets = uniqueSelectedNoteOffsets()
    local firstOffset = offsets[1]
    local lastOffset = offsets[#offsets]
    local totalNumStutters = (#offsets - 1) * settingVars.stuttersPerSection
    local firstStutterSVs = generateLinearSet(settingVars.startSV, lastFirstStutter,
                                              totalNumStutters)
    local svsToAdd = {}
    local svsToRemove = getSVsBetweenOffsets(firstOffset, lastOffset)
    local stutterIndex = 1
    for i = 1, #offsets - 1 do
        local startOffset = offsets[i]
        local endOffset = offsets[i + 1]
        local stutterOffsets =  generateLinearSet(startOffset, endOffset,
                                                  settingVars.stuttersPerSection + 1)
        for j = 1, #stutterOffsets - 1 do
            local svMultipliers = generateStutterSet(firstStutterSVs[stutterIndex],
                                                     settingVars.stutterDuration,
                                                     settingVars.avgSV,
                                                     settingVars.controlLastSV)
            local stutterStart = stutterOffsets[j]
            local stutterEnd = stutterOffsets[j + 1]
            local timeInterval = stutterEnd - stutterStart
            local secondSVOffset = stutterStart + timeInterval * settingVars.stutterDuration / 100
            addSVToList(svsToAdd, stutterStart, svMultipliers[1], true)
            addSVToList(svsToAdd, secondSVOffset, svMultipliers[2], true)
            stutterIndex = stutterIndex + 1
        end
    end
    addFinalSV(svsToAdd, lastOffset, lastMultiplier)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Places teleport stutter SVs between selected notes
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function placeTeleportStutterSVs(settingVars)
    local svPercent = settingVars.svPercent / 100
    local lastSVPercent = svPercent
    local lastMainSV = settingVars.mainSV
    if settingVars.linearlyChange then 
        lastSVPercent = settingVars.svPercent2 / 100
        lastMainSV = settingVars.mainSV2
    end
    local offsets = uniqueNoteOffsetsBetweenSelected()
    local firstOffset = offsets[1]
    local lastOffset = offsets[#offsets]
    local numTeleportSets = #offsets - 1
    local svsToAdd = {}
    local svsToRemove = getSVsBetweenOffsets(firstOffset, lastOffset)
    local svPercents = generateLinearSet(svPercent, lastSVPercent, numTeleportSets)
    local mainSVs = generateLinearSet(settingVars.mainSV, lastMainSV, numTeleportSets)
    
    removeAndAddSVs(svsToRemove, svsToAdd)
    for i = 1, numTeleportSets do
        local thisMainSV = mainSVs[i]
        local startOffset = offsets[i]
        local endOffset = offsets[i + 1]
        local offsetInterval = endOffset - startOffset
        local startMultiplier = getUsableDisplacementMultiplier(startOffset)
        local startDuration = 1 / startMultiplier
        local endMultiplier = getUsableDisplacementMultiplier(endOffset)
        local endDuration = 1 / endMultiplier
        local startDistance = offsetInterval * svPercents[i]
        if settingVars.useDistance then startDistance = settingVars.distance end
        local expectedDistance = offsetInterval * settingVars.avgSV
        local traveledDistance = offsetInterval * thisMainSV
        local endDistance = expectedDistance - startDistance - traveledDistance
        local sv1 = thisMainSV + startDistance * startMultiplier
        local sv2 = thisMainSV
        local sv3 = thisMainSV + endDistance * endMultiplier
        addSVToList(svsToAdd, startOffset, sv1, true)
        if sv2 ~= sv1 then addSVToList(svsToAdd, startOffset + startDuration, sv2, true) end
        if sv3 ~= sv2 then addSVToList(svsToAdd, endOffset - endDuration, sv3, true) end
    end
    local finalSVType = FINAL_SV_TYPES[settingVars.finalSVIndex]
    local finalMultiplier = settingVars.avgSV
    if finalSVType == "Custom" then
        finalMultiplier = settingVars.customSV
    end
    addFinalSV(svsToAdd, lastOffset, finalMultiplier)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Places split scroll SVs 
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function placeSplitScrollSVs(settingVars)
    local isNoteOffsetFor2nd = {}
    local offsets = uniqueNoteOffsetsBetweenSelected()
    for _, offset in pairs(settingVars.noteTimes2) do
        table.insert(offsets, offset)
        isNoteOffsetFor2nd[offset] = true
    end
    offsets = table.sort(offsets, sortAscending)
    local firstOffset = offsets[1]
    local lastOffset = offsets[#offsets]
    local totalTime = lastOffset - firstOffset
    local noteOffsets = uniqueNoteOffsetsBetween(firstOffset, lastOffset)
    local svsToAdd = {}
    local svsToRemove = getSVsBetweenOffsets(firstOffset, lastOffset + 2) -- a jank + 2, but meh...
    local scrollSpeed1 = settingVars.scrollSpeed1
    local height1 = settingVars.height1
    local scrollSpeed2 = settingVars.scrollSpeed2
    local height2 = settingVars.height2
    local initialDistance = settingVars.distanceBack
    local scrollDifference = scrollSpeed1 - scrollSpeed2
    local msPerFrame = settingVars.msPerFrame
    local numFrames = math.floor((totalTime - 1) / msPerFrame)
    local noteIndex = 2
    local goingFrom1To2 = false
    local currentScrollSpeed = scrollSpeed2
    local nextScrollSpeed = scrollSpeed1
    for i = 0, (numFrames + 1) do
        local timePassed = i * msPerFrame
        if i == numFrames + 1 then timePassed = totalTime end
        local tpDistance = initialDistance + timePassed * scrollDifference
        if i == 0 then tpDistance = 0 end
        local timeAt = firstOffset + timePassed
        local multiplier = getUsableDisplacementMultiplier(timeAt)
        local duration = 1 / multiplier
        local timeBefore = timeAt - duration
        local timeAfter = timeAt + duration
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
        if i == numFrames + 1 then
            nextScrollSpeed = scrollSpeed1
        end
        local noteOffset = noteOffsets[noteIndex]
        while noteOffset < timeAt do
            local noteMultiplier = getUsableDisplacementMultiplier(noteOffset)
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
                extraDisplacement = initialDistance + (noteOffset - firstOffset) * scrollDifference
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
        local sv2 = nextScrollSpeed + tpDistance * multiplier
        if noteOffset == timeAt then
            local thisHeight = height1
            if isNoteOffsetFor2nd[noteOffset] then
                thisHeight = height2
            end
            local noteInOtherScroll = (isNoteOffsetFor2nd[noteOffset] and goingFrom1To2) or
                                      (not isNoteOffsetFor2nd[noteOffset] and not goingFrom1To2)
            local sv1 = currentScrollSpeed + thisHeight * multiplier
            sv2 = nextScrollSpeed - thisHeight * multiplier
            if noteInOtherScroll then
                sv1 = sv1 + tpDistance * multiplier
                if i == numFrames + 1 and isNoteOffsetFor2nd[noteOffset] then
                    sv2 = sv2 - tpDistance * multiplier
                end
            else
                if i ~= numFrames + 1 or isNoteOffsetFor2nd[noteOffset] then
                    sv2 = sv2 + tpDistance * multiplier
                end
            end
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeBefore, sv1))
            noteIndex = noteIndex + 1
        end
        table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, sv2))
        table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, nextScrollSpeed))
        goingFrom1To2 = not goingFrom1To2
    end
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Places advanced split scroll SVs 
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function placeAdvancedSplitScrollSVs(menuVars)
    local isNoteOffsetFor2nd = {}
    local offsets = uniqueNoteOffsetsBetweenSelected()
    for _, offset in pairs(menuVars.noteTimes2) do
        table.insert(offsets, offset)
    end
    offsets = table.sort(offsets, function(a, b) return a < b end)
    local firstOffset = offsets[1]
    local lastOffset = offsets[#offsets]
    local totalTime = lastOffset - firstOffset
    local noteOffsets = uniqueNoteOffsetsBetween(firstOffset, lastOffset)
    for _, noteOffset in pairs(menuVars.noteTimes2) do
        isNoteOffsetFor2nd[noteOffset] = true
    end
    local svsToAdd = {}
    local svsToRemove = getSVsBetweenOffsets(firstOffset, lastOffset + 2) -- a jank + 2, but meh...
    local initialDistance = menuVars.distanceBack
    local msPerFrame = menuVars.msPerFrame
    local numFrames = math.floor((totalTime - 1) / msPerFrame)
    local noteIndex = 2
    local sv1Index = 1
    local sv2Index = 1
    local svsIn1 = menuVars.svsInScroll1
    local svsIn2 = menuVars.svsInScroll2
    if #svsIn1 == 0 or svsIn1[1].StartTime ~= firstOffset then
        local newStartSV = utils.CreateScrollVelocity(firstOffset, getSVMultiplierAt(firstOffset))
        table.insert(svsIn1, 1, newStartSV)
    end
    if #svsIn2 == 0 or svsIn2[1].StartTime ~= firstOffset then
        local newStartSV = utils.CreateScrollVelocity(firstOffset, getSVMultiplierAt(firstOffset))
        table.insert(svsIn2, 1, newStartSV)
    end
    local splitscrollOffsets = {}
    for i = 0, numFrames do
        local timePassed = i * msPerFrame
        table.insert(splitscrollOffsets, timePassed + firstOffset)
    end
    table.insert(splitscrollOffsets, lastOffset)
    local distancesIn1 = calculateDisplacementsFromSVs(svsIn1, splitscrollOffsets)
    local distancesIn2 = calculateDisplacementsFromSVs(svsIn2, splitscrollOffsets)
    local splitscrollDistances = {}
    for i = 1, #distancesIn1 do
        splitscrollDistances[i] = distancesIn1[i] - distancesIn2[i] + initialDistance
        if i % 2 == 0 then splitscrollDistances[i] = -splitscrollDistances[i] end
    end
    splitscrollDistances[1] = 0
    local goingFrom1To2 = false
    local noteDistancesIn1 = calculateDisplacementsFromSVs(svsIn1, noteOffsets)
    local noteDistancesIn2 = calculateDisplacementsFromSVs(svsIn2, noteOffsets)
    local noteDistances = {}
    for i = 1, #noteDistancesIn1 do
        noteDistances[i] = noteDistancesIn1[i] - noteDistancesIn2[i] + initialDistance
    end
    for i = 0, numFrames + 1 do
        local timeAt = splitscrollOffsets[i + 1]
        local multiplier = getUsableDisplacementMultiplier(timeAt)
        local duration = 1 / multiplier
        local timeBefore = timeAt - duration
        local timeAfter = timeAt + duration
        local noteOffset = noteOffsets[noteIndex]
        while noteOffset < timeAt do
            local noteInOtherScroll = (isNoteOffsetFor2nd[noteOffset] and goingFrom1To2) or
                                      (not isNoteOffsetFor2nd[noteOffset] and not goingFrom1To2)
            local noteMultiplier = getUsableDisplacementMultiplier(noteOffset)
            local noteDuration = 1 / noteMultiplier
            local noteTimeBefore = noteOffset - noteDuration
            local noteTimeAt = noteOffset
            local noteTimeAfter = noteOffset + noteDuration
            while sv1Index <= #svsIn1 and svsIn1[sv1Index].StartTime < noteTimeBefore do
                if goingFrom1To2 then
                    table.insert(svsToAdd, svsIn1[sv1Index])
                end
                sv1Index = sv1Index + 1
            end
            while sv2Index <= #svsIn2 and svsIn2[sv2Index].StartTime < noteTimeBefore do
                if not goingFrom1To2 then
                    table.insert(svsToAdd, svsIn2[sv2Index])
                end
                sv2Index = sv2Index + 1
            end
            if noteInOtherScroll then
                local sv1 = svsIn2[sv2Index - 1]
                local sv2 = svsIn2[sv2Index - 1]
                local sv3 = svsIn2[sv2Index - 1]
                if goingFrom1To2 then
                    sv1 = svsIn1[sv1Index - 1]
                    sv2 = svsIn1[sv1Index - 1]
                    sv3 = svsIn1[sv1Index - 1]
                end
                while sv1Index <= #svsIn1 and svsIn1[sv1Index].StartTime <= noteTimeAfter do
                    if goingFrom1To2 then
                        local svTime = svsIn1[sv1Index].StartTime 
                        if svTime <= noteTimeBefore then
                            sv1 = svsIn1[sv1Index]
                        end
                        if svTime <= noteTimeAt then
                            sv2 = svsIn1[sv1Index]
                        end
                        if svTime <= noteTimeAfter then
                            sv3 = svsIn1[sv1Index]
                        end
                    end
                    sv1Index = sv1Index + 1
                end
                while sv2Index <= #svsIn2 and svsIn2[sv2Index].StartTime <= noteTimeAfter do
                    if not goingFrom1To2 then
                        local svTime = svsIn2[sv2Index].StartTime 
                        if svTime <= noteTimeBefore then
                            sv1 = svsIn2[sv2Index]
                        end
                        if svTime <= noteTimeAt then
                            sv2 = svsIn2[sv2Index]
                        end
                        if svTime <= noteTimeAfter then
                            sv3 = svsIn2[sv2Index]
                        end
                    end
                    sv2Index = sv2Index + 1
                end
                local noteDistance = noteDistances[noteIndex]
                if goingFrom1To2 then noteDistance = -noteDistance end
                local svBefore = sv1.Multiplier + noteDistance * noteMultiplier
                local svAt = sv2.Multiplier - noteDistance * noteMultiplier
                local svAfter = sv3.Multiplier
                table.insert(svsToAdd, utils.CreateScrollVelocity(noteTimeBefore, svBefore))
                table.insert(svsToAdd, utils.CreateScrollVelocity(noteTimeAt, svAt))
                table.insert(svsToAdd, utils.CreateScrollVelocity(noteTimeAfter, svAfter))
            else
                while sv1Index <= #svsIn1 and svsIn1[sv1Index].StartTime <= noteTimeAfter do
                    if goingFrom1To2 then
                        table.insert(svsToAdd, svsIn1[sv1Index])
                    end
                    sv1Index = sv1Index + 1
                end
                while sv2Index <= #svsIn2 and svsIn2[sv2Index].StartTime <= noteTimeAfter do
                    if not goingFrom1To2 then
                        table.insert(svsToAdd, svsIn2[sv2Index])
                    end
                    sv2Index = sv2Index + 1
                end
            end
            noteIndex = noteIndex + 1
            noteOffset = noteOffsets[noteIndex]
        end
        while sv1Index <= #svsIn1 and svsIn1[sv1Index].StartTime < timeBefore do
            if goingFrom1To2 then
                table.insert(svsToAdd, svsIn1[sv1Index])
            end
            sv1Index = sv1Index + 1
        end
        while sv2Index <= #svsIn2 and svsIn2[sv2Index].StartTime < timeBefore do
            if not goingFrom1To2 then
                table.insert(svsToAdd, svsIn2[sv2Index])
            end
            sv2Index = sv2Index + 1
        end
        if noteOffset == timeAt then
            local noteInOtherScroll = (isNoteOffsetFor2nd[noteOffset] and goingFrom1To2) or
                                      (not isNoteOffsetFor2nd[noteOffset] and not goingFrom1To2)
            local sv1in1 = svsIn1[sv1Index - 1]
            local sv2in1 = svsIn1[sv1Index - 1]
            while sv1Index <= #svsIn1 and svsIn1[sv1Index].StartTime <= timeAfter do
                if svsIn1[sv1Index].StartTime <= timeBefore then sv1in1 = svsIn1[sv1Index] end
                if svsIn1[sv1Index].StartTime <= timeAt then sv2in1 = svsIn1[sv1Index] end
                sv1Index = sv1Index + 1
            end
            local sv3in1 = svsIn1[sv1Index - 1]
            local sv1in2 = svsIn2[sv2Index - 1]
            local sv2in2 = svsIn2[sv2Index - 1]
            while sv2Index <= #svsIn2 and svsIn2[sv2Index].StartTime <= timeAfter do
                if svsIn2[sv2Index].StartTime <= timeBefore then sv1in2 = svsIn2[sv2Index] end
                if svsIn2[sv2Index].StartTime <= timeAt then sv2in2 = svsIn2[sv2Index] end
                sv2Index = sv2Index + 1
            end
            local sv3in2 = svsIn2[sv2Index - 1]
            local svBefore = 0
            local svAt = 0
            local svAfter = 0
            if noteInOtherScroll then
                svBefore = svBefore + splitscrollDistances[i + 1] * multiplier
                if i == numFrames + 1 and isNoteOffsetFor2nd[noteOffset] then
                    svAt = svAt - splitscrollDistances[i + 1] * multiplier
                end
            else
                svAt = svAt + splitscrollDistances[i + 1] * multiplier
                if i == numFrames + 1 and not isNoteOffsetFor2nd[noteOffset] then
                    svAt = svAt - splitscrollDistances[i + 1] * multiplier
                end
            end
            if goingFrom1To2 then
                svBefore = svBefore + sv1in1.Multiplier
                svAt = svAt + sv2in2.Multiplier
                svAfter = sv3in2.Multiplier
            else
                svBefore = svBefore + sv1in2.Multiplier
                svAt = svAt + sv2in1.Multiplier
                svAfter = sv3in1.Multiplier
            end
            if i == numFrames + 1 then 
                svAfter = 1
            end
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeBefore, svBefore))
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, svAt))
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, svAfter))
            noteIndex = noteIndex + 1
        else
            while sv1Index <= #svsIn1 and svsIn1[sv1Index].StartTime < timeAt do
                if goingFrom1To2 then
                    table.insert(svsToAdd, svsIn1[sv1Index])
                end
                sv1Index = sv1Index + 1
            end
            while sv2Index <= #svsIn2 and svsIn2[sv2Index].StartTime < timeAt do
                if not goingFrom1To2 then
                    table.insert(svsToAdd, svsIn2[sv2Index])
                end
                sv2Index = sv2Index + 1
            end
            
            local sv1 = svsIn1[sv1Index - 1]
            if goingFrom1To2 then
                sv1 = svsIn2[sv2Index - 1]
            end
            while sv1Index <= #svsIn1 and svsIn1[sv1Index].StartTime <= timeAfter do
                if not goingFrom1To2 and svsIn1[sv1Index].StartTime <= timeAt then
                    sv1 = svsIn1[sv1Index]
                end
                sv1Index = sv1Index + 1
            end
            while sv2Index <= #svsIn2 and svsIn2[sv2Index].StartTime <= timeAfter do
                if goingFrom1To2 and svsIn2[sv2Index].StartTime <= timeAt then
                    sv1 = svsIn2[sv2Index]
                end
                sv2Index = sv2Index + 1
            end
            local sv2 = svsIn1[sv1Index - 1]
            if goingFrom1To2 then
                sv2 = svsIn2[sv2Index - 1]
            end
            local svMultiplierAt = sv1.Multiplier + splitscrollDistances[i + 1] * multiplier
            local svMultiplierAfter = sv2.Multiplier
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, svMultiplierAt))
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, svMultiplierAfter))
        end
        goingFrom1To2 = not goingFrom1To2
    end
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Adds teleport SVs at selected notes
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function addTeleportSVs(menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local offsets = uniqueSelectedNoteOffsets()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local displaceAmount = menuVars.distance
    for i = 1, #offsets do
        local noteOffset = offsets[i]
        local beforeDisplacement = nil
        local atDisplacement = displaceAmount
        local afterDisplacement = 0
        prepareDisplacingSVs(noteOffset, svsToAdd, svTimeIsAdded, beforeDisplacement,
                             atDisplacement, afterDisplacement)
    end
    
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Copies SVs between selected notes
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function copySVs(menuVars)
    menuVars.copiedSVs = {}
    local offsets = uniqueSelectedNoteOffsets()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local svsBetweenOffsets = getSVsBetweenOffsets(startOffset, endOffset)
    for _, sv in ipairs(svsBetweenOffsets) do
        local relativeTime = sv.StartTime - startOffset 
        local copiedSV = {
            relativeOffset = relativeTime,
            multiplier = sv.Multiplier
        }
        table.insert(menuVars.copiedSVs, copiedSV)
    end
end
-- Clears all copied SVs
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function clearCopiedSVs(menuVars)
    menuVars.copiedSVs = {}
end
-- Pastes copied SVs at selected notes
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars : list of variables used for the current menu [Table]
function pasteSVs(globalVars, menuVars)
    local offsets = uniqueSelectedNoteOffsets()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local lastCopiedSV = menuVars.copiedSVs[#menuVars.copiedSVs]
    local endRemoveOffset = endOffset + lastCopiedSV.relativeOffset + 1/128
    local svsToRemove = getSVsBetweenOffsets(startOffset, endRemoveOffset)
    if globalVars.dontReplaceSV then
        svsToRemove = {}
    end
    local svsToAdd = {}
    for i = 1, #offsets do
        local pasteOffset = offsets[i]
        for _, sv in ipairs(menuVars.copiedSVs) do
            local timeToPasteSV = pasteOffset + sv.relativeOffset
            addSVToList(svsToAdd, timeToPasteSV, sv.multiplier, true)
        end
    end
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Displaces selected notes with SVs
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function displaceNoteSVs(menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local offsets = uniqueSelectedNoteOffsets()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local displaceAmount = menuVars.distance
    for i = 1, #offsets do
        local noteOffset = offsets[i]
        local beforeDisplacement = displaceAmount
        local atDisplacement = -displaceAmount
        local afterDisplacement = 0
        prepareDisplacingSVs(noteOffset, svsToAdd, svTimeIsAdded, beforeDisplacement,
                             atDisplacement, afterDisplacement)
    end
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Displaces the playfield view with SVs between selected notes
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function displaceViewSVs(menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local offsets = uniqueNoteOffsetsBetweenSelected()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local displaceAmount = menuVars.distance
    for i = 1, #offsets do
        local noteOffset = offsets[i]
        local beforeDisplacement = nil
        local atDisplacement = displaceAmount
        local afterDisplacement = 0
        if i ~= 1 then beforeDisplacement = -displaceAmount end
        if i == #offsets then
            atDisplacement = 0
            afterDisplacement = nil
        end
        prepareDisplacingSVs(noteOffset, svsToAdd, svTimeIsAdded, beforeDisplacement,
                             atDisplacement, afterDisplacement)
    end
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Fixes flipped LN ends with SVs
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function fixFlippedLNEnds(menuVars)
    local svsToRemove = {}
    local svsToAdd = {}
    local svTimeIsAdded = {}
    local lnEndTimeFixed = {}
    local fixedLNEndsCount = 0
    for _, hitObject in pairs(map.HitObjects) do
        local lnEndTime = hitObject.EndTime
        local isLN = lnEndTime ~= 0 
        local endHasNegativeSV = (getSVMultiplierAt(lnEndTime) < 0)
        local hasntAlreadyBeenFixed = lnEndTimeFixed[lnEndTime] == nil
        if isLN and endHasNegativeSV and hasntAlreadyBeenFixed then
            lnEndTimeFixed[lnEndTime] = true
            local multiplier = getUsableDisplacementMultiplier(lnEndTime)
            local duration = 1 / multiplier
            local timeAt = lnEndTime
            local timeAfter = lnEndTime + duration
            local timeAfterAfter = lnEndTime + duration + duration
            svTimeIsAdded[timeAt] = true
            svTimeIsAdded[timeAfter] = true
            svTimeIsAdded[timeAfterAfter] = true
            local svMultiplierAt = getSVMultiplierAt(timeAt)
            local svMultiplierAfter = getSVMultiplierAt(timeAfter)
            local svMultiplierAfterAfter = getSVMultiplierAt(timeAfterAfter)
            local newMultiplierAt = 0
            local newMultiplierAfter = svMultiplierAt + svMultiplierAfter
            local newMultiplierAfterAfter = svMultiplierAfterAfter
            addSVToList(svsToAdd, timeAt, newMultiplierAt, true)
            addSVToList(svsToAdd, timeAfter, newMultiplierAfter, true)
            addSVToList(svsToAdd, timeAfterAfter, newMultiplierAfterAfter, true)
            fixedLNEndsCount = fixedLNEndsCount + 1
        end
    end
    local startOffset = map.HitObjects[1].StartTime
    local endOffset = map.HitObjects[#map.HitObjects].EndTime
    if endOffset == 0 then endOffset = map.HitObjects[#map.HitObjects].StartTime end
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
    
    menuVars.fixedText = table.concat({"Fixed ", fixedLNEndsCount, " flipped LN ends"})
end
-- Adds flicker SVs between selected notes
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function flickerSVs(menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local offsets = uniqueSelectedNoteOffsets()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local numTeleports = 2 * menuVars.numFlickers
    local isDelayedFlicker = FLICKER_TYPES[menuVars.flickerTypeIndex] == "Delayed"
    for i = 1, (#offsets - 1) do
        local flickerStartOffset = offsets[i]
        local flickerEndOffset = offsets[i + 1]
        local teleportOffsets = generateLinearSet(flickerStartOffset, flickerEndOffset,
                                                  numTeleports + 1)
        for j = 1, numTeleports do
            local offsetIndex = j
            if isDelayedFlicker then offsetIndex = offsetIndex + 1 end
            local teleportOffset = math.floor(teleportOffsets[offsetIndex])
            local isTeleportBack = j % 2 == 0
            if isDelayedFlicker then
                local beforeDisplacement = menuVars.distance
                local atDisplacement = 0
                if isTeleportBack then beforeDisplacement = -beforeDisplacement end
                prepareDisplacingSVs(teleportOffset, svsToAdd, svTimeIsAdded, beforeDisplacement,
                                     atDisplacement, 0)
            else
                local atDisplacement = menuVars.distance
                local afterDisplacement = 0
                if isTeleportBack then atDisplacement = -atDisplacement end
                prepareDisplacingSVs(teleportOffset, svsToAdd, svTimeIsAdded, nil, atDisplacement,
                                     afterDisplacement)
            end
        end
    end
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Measures SVs between selected notes
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function measureSVs(menuVars)
    local roundingDecimalPlaces = 5
    local offsets = uniqueSelectedNoteOffsets()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local svsBetweenOffsets = getSVsBetweenOffsets(startOffset, endOffset)
    addStartSVIfMissing(svsBetweenOffsets, startOffset)
    
    menuVars.roundedNSVDistance = endOffset - startOffset
    menuVars.nsvDistance = tostring(menuVars.roundedNSVDistance)
    
    local totalDistance = calculateDisplacementFromSVs(svsBetweenOffsets, startOffset, endOffset)
    menuVars.roundedSVDistance = round(totalDistance, roundingDecimalPlaces)
    menuVars.svDistance = tostring(totalDistance)
    
    local avgSV = totalDistance / menuVars.roundedNSVDistance
    menuVars.roundedAvgSV = round(avgSV, roundingDecimalPlaces)
    menuVars.avgSV = tostring(avgSV)
    
    local durationStart = 1 / getUsableDisplacementMultiplier(startOffset)
    local timeAt = startOffset
    local timeAfter = startOffset + durationStart
    local multiplierAt = getSVMultiplierAt(timeAt)
    local multiplierAfter = getSVMultiplierAt(timeAfter)
    local startDisplacement = -(multiplierAt - multiplierAfter) * durationStart
    menuVars.roundedStartDisplacement = round(startDisplacement, roundingDecimalPlaces)
    menuVars.startDisplacement = tostring(startDisplacement)
    
    local durationEnd = 1 / getUsableDisplacementMultiplier(startOffset)
    local timeBefore = endOffset - durationEnd
    local timeBeforeBefore = timeBefore - durationEnd
    local multiplierBefore = getSVMultiplierAt(timeBefore)
    local multiplierBeforeBefore = getSVMultiplierAt(timeBeforeBefore)
    local endDisplacement = (multiplierBefore - multiplierBeforeBefore) * durationEnd
    menuVars.roundedEndDisplacement = round(endDisplacement, roundingDecimalPlaces)
    menuVars.endDisplacement = tostring(endDisplacement)
    
    local trueDistance = totalDistance - endDisplacement + startDisplacement
    local trueAvgSV = trueDistance / menuVars.roundedNSVDistance
    menuVars.roundedAvgSVDisplaceless = round(trueAvgSV, roundingDecimalPlaces)
    menuVars.avgSVDisplaceless = tostring(trueAvgSV)
end
-- Merges overlapping SVs between selected notes
function mergeSVs()
    local offsets = uniqueSelectedNoteOffsets()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local svsToAdd = {}
    local svsToRemove = getSVsBetweenOffsets(startOffset, endOffset) 
    local svTimeToMultiplier = {}
    for _, sv in pairs(svsToRemove) do
        local currentMultiplier = svTimeToMultiplier[sv.StartTime]
        if currentMultiplier then
            svTimeToMultiplier[sv.StartTime] = currentMultiplier + sv.Multiplier
        else
            svTimeToMultiplier[sv.StartTime] = sv.Multiplier
        end
    end
    for svTime, svMultiplier in pairs(svTimeToMultiplier) do
        addSVToList(svsToAdd, svTime, svMultiplier, true)
    end
    local noSVsMerged = #svsToAdd == #svsToRemove
    if noSVsMerged then return end
    
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Reverses scroll direction by adding/modifying SVs between selected notes
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function reverseScrollSVs(menuVars)
    local offsets = uniqueNoteOffsetsBetweenSelected()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local svsToAdd = {}
    local almostSVsToAdd = {}
    local svsToRemove = getSVsBetweenOffsets(startOffset, endOffset + 2) -- a jank + 2, but meh...
    local svTimeIsAdded = {}
    local svsBetweenOffsets = getSVsBetweenOffsets(startOffset, endOffset)
    addStartSVIfMissing(svsBetweenOffsets, startOffset)
    local sectionDistance = calculateDisplacementFromSVs(svsBetweenOffsets, startOffset, endOffset)
    -- opposite-sign distances and displacements b/c flips SV multiplier signs at the end
    local msxSeparatingDistance = -10000
    local teleportDistance = -sectionDistance + msxSeparatingDistance
    local noteDisplacement = -menuVars.distance
    for i = 1, #offsets do
        local noteOffset = offsets[i]
        local beforeDisplacement = nil
        local atDisplacement = 0
        local afterDisplacement = 0
        if i ~= 1 then 
            beforeDisplacement = noteDisplacement
            atDisplacement = -noteDisplacement
        end
        if i == 1 or i == #offsets then
            atDisplacement = atDisplacement + teleportDistance 
        end
        prepareDisplacingSVs(noteOffset, almostSVsToAdd, svTimeIsAdded, beforeDisplacement,
                             atDisplacement, afterDisplacement)
    end
    for _, sv in ipairs(svsBetweenOffsets) do
        if (not svTimeIsAdded[sv.StartTime]) then
            table.insert(almostSVsToAdd, sv)
        end
    end
    for _, sv in ipairs(almostSVsToAdd) do
        local newSVMultiplier = -sv.Multiplier
        if sv.StartTime > endOffset then newSVMultiplier = sv.Multiplier end
        addSVToList(svsToAdd, sv.StartTime, newSVMultiplier, true)
    end
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Scales SVs by adding displacing SVs between selected notes
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function scaleDisplaceSVs(menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local offsets = uniqueSelectedNoteOffsets()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local isStartDisplace = DISPLACE_SCALE_SPOTS[menuVars.scaleSpotIndex] == "Start"
    for i = 1, (#offsets - 1) do
        local note1Offset = offsets[i]
        local note2Offset = offsets[i + 1]
        local svsBetweenOffsets = getSVsBetweenOffsets(note1Offset, note2Offset)
        addStartSVIfMissing(svsBetweenOffsets, note1Offset)
        local scaleType = SCALE_TYPES[menuVars.scaleTypeIndex]
        local currentDistance = calculateDisplacementFromSVs(svsBetweenOffsets, startOffset,
                                                             endOffset)
        local scalingDistance
        if scaleType == "Average SV" then
            local targetDistance = menuVars.avgSV * (note2Offset - note1Offset)
            scalingDistance = targetDistance - currentDistance
        elseif scaleType == "Absolute Distance" then
            scalingDistance = menuVars.distance - currentDistance
        elseif scaleType == "Relative Ratio" then
            scalingDistance = (menuVars.ratio - 1) * currentDistance
        end
        if isStartDisplace then
            local atDisplacement = scalingDistance
            local afterDisplacement = 0
            prepareDisplacingSVs(note1Offset, svsToAdd, svTimeIsAdded, nil, atDisplacement,
                                 afterDisplacement)
        else
            local beforeDisplacement = scalingDistance
            local atDisplacement = 0
            prepareDisplacingSVs(note2Offset, svsToAdd, svTimeIsAdded, beforeDisplacement,
                                 atDisplacement, nil)
        end
    end
    if isStartDisplace then addFinalSV(svsToAdd, endOffset, getSVMultiplierAt(endOffset)) end
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Scales SVs by multiplying SVs between selected notes
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function scaleMultiplySVs(menuVars)
    local offsets = uniqueSelectedNoteOffsets()
    local svsToAdd = {}
    local svsToRemove = getSVsBetweenOffsets(offsets[1], offsets[#offsets])
    for i = 1, (#offsets - 1) do
        local startOffset = offsets[i]
        local endOffset = offsets[i + 1]
        local svsBetweenOffsets = getSVsBetweenOffsets(startOffset, endOffset)
        addStartSVIfMissing(svsBetweenOffsets, startOffset)
        local scalingFactor = menuVars.ratio
        local currentDistance = calculateDisplacementFromSVs(svsBetweenOffsets, startOffset,
                                endOffset)
        local scaleType = SCALE_TYPES[menuVars.scaleTypeIndex]
        if scaleType == "Average SV" then
            local currentAvgSV = currentDistance / (endOffset - startOffset)
            scalingFactor = menuVars.avgSV / currentAvgSV
        elseif scaleType == "Absolute Distance" then
            scalingFactor = menuVars.distance / currentDistance
        end
        for _, sv in pairs(svsBetweenOffsets) do
            local newSVMultiplier = scalingFactor * sv.Multiplier
            addSVToList(svsToAdd, sv.StartTime, newSVMultiplier, true)
        end
    end
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Swap selected notes' position with SVs
function swapNoteSVs()
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local offsets = uniqueSelectedNoteOffsets()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local svsBetweenOffsets = getSVsBetweenOffsets(startOffset, endOffset)
    addStartSVIfMissing(svsBetweenOffsets, startOffset)
    local oldSVDisplacements = calculateDisplacementsFromSVs(svsBetweenOffsets, offsets)
    for i = 1, #offsets do
        local noteOffset = offsets[i]
        local currentDisplacement = oldSVDisplacements[i]
        local nextDisplacement = oldSVDisplacements[i + 1] or oldSVDisplacements[1]
        local newDisplacement = nextDisplacement - currentDisplacement
        
        local beforeDisplacement = newDisplacement
        local atDisplacement = -newDisplacement
        local afterDisplacement = 0
        prepareDisplacingSVs(noteOffset, svsToAdd, svTimeIsAdded, beforeDisplacement,
                             atDisplacement, afterDisplacement)
    end
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Deletes SVs between selected notes
function deleteSVs()
    local offsets = uniqueSelectedNoteOffsets()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local svsToRemove = getSVsBetweenOffsets(startOffset, endOffset)
    if #svsToRemove > 0 then actions.RemoveScrollVelocityBatch(svsToRemove) end
end