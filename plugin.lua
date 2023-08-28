-- amoguSV v6.0 beta (28 August 2023)
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
MAX_ANIMATION_FRAMES = 999         -- maximum number of animation frames allowed

-------------------------------------------------------------------------------------- Menu related

ANIMATION_OPTIONS = {              -- ways to add note animation data
    "Manually Add",
    "Import/Export"
}
COLOR_THEMES = {                   -- available color themes for the plugin
    "Classic",
    "Strawberry",
    "Incognito",
    "Incognito + RGB",
    "Barbie",
    "Glass",
    "Glass + RGB",
    "RGB Gamer Mode"
}
CURSOR_EFFECTS_OPTIONS = {         -- cursor effect options
    "Off",
    "Shiny Box", 
    "Shiny Mouse Click",
    "Shiny Mouse Down",
    "Shiny Always On",
    "Circle"
}
DISPLACE_SCALE_SPOTS = {           -- places to scale SV sections by displacing
    "Start",
    "End"
}
DISPLACE_SCALE_TYPES = {           -- ways to scale SV sections by displacing
    "Average SV",
    "Absolute Distance"
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
    "Fix LN Ends",
    "Flicker",
    "Measure",
    "Merge",
    "Reverse Scroll",
    "Scale (Displace)",
    "Scale (Multiply)",
    "Swap Notes"
}
EMOTICONS = {                      -- emoticons to visually clutter the plugin and confuse users
    "( - _ - )",
    "( e . e )",
    "( * o * )",
    "( h . m )",
    "( ~ _ ~ )",
    "( C | D )",
    "( w . w )",
    "( ^ w ^ )",
    "( o _ 0 )",
    "[mwm]",
    "( > . < )",
    "( v . ^ )",
    "( ^ o v )",
    "( ; A ; )"
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
SCALE_TYPES = {                    -- ways to scale SV multipliers by multiplying
    "Average SV",
    "Start/End Ratio",
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
    "Splitscroll (Basic)",
    "Splitscroll (Advanced)",
    "Animate"
}
STANDARD_SVS = {                   -- types of standard SVs
    "Linear",
    "Exponential",
    "Bezier",
    "Hermite",
    "Sinusoidal",
    "Circular",
    "Random",
    "Custom"
}
STILL_TYPES = {                    -- types of still displacements
    "No",
    "Start",
    "End",
    "Auto",
    "Capy",
    "Bara"
}
STUTTER_CONTROLS = {               -- parts of a stutter SV to control
    "First SV",
    "Second SV"
}
STYLE_THEMES = {                   -- available style/appearance themes for the plugin
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
-- Plugin Appearance, Styles and Colors -----------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Returns coordinates relative to the plugin window [Table]
-- Parameters
--    x : x coordinate relative to the plugin window [Int]
--    y : y coordinate relative to the plugin window [Int]
function coordsRelativeToWindow(x, y)
    local newX = x + imgui.GetWindowPos()[1]
    local newY = y + imgui.GetWindowPos()[2]
    return {newX, newY}
end
-- Draws a capybara on the bottom right of the screen
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function drawCapybara(globalVars)
    if not globalVars.drawCapybara then return end
    local o = imgui.GetOverlayDrawList()
    --local m = imgui.GetMousePos()
    --local t = imgui.GetTime()
    local sz = state.WindowSize
    local headWidth = 50
    local headHeight = 20
    local eyeWidth = 10
    local eyeHeight = 3
    local head1 = {sz[1] - 100, sz[2] - 100}
    local head2 = {head1[1] - headWidth, head1[2]}
    local eye1 = {head1[1] - 10, head1[2] - 10}
    local eye2 = {eye1[1] - eyeWidth, eye1[2]}
    local ear = {head1[1] + 12, head1[2] - headHeight + 5}
    local capyBrown = rgbaToUint(220, 150, 80, 255)
    local capyBlack = rgbaToUint(30, 20, 35, 255)
    local capyEar = rgbaToUint(150, 100, 50, 255)
    o.AddCircleFilled(ear, 12, capyEar)
    o.AddCircleFilled(head1, headHeight, capyBrown, 12)
    o.AddCircleFilled(head2, headHeight, capyBrown, 12)
    o.AddRectFilled({head1[1], head1[2] + headHeight}, {head2[1], head2[2] - headHeight}, capyBrown)
    o.AddCircleFilled(eye1, eyeHeight, capyBlack, 12)
    o.AddCircleFilled(eye2, eyeHeight, capyBlack, 12)
    o.AddRectFilled({eye1[1], eye1[2] + eyeHeight}, {eye2[1], eye2[2] - eyeHeight}, capyBlack)
    local p1 = sz
    local p2 = {head1[1], sz[2]}
    local p3 = {head1[1], head1[2]}
    local p4 = {sz[1], head1[2]}
    o.AddQuadFilled(p1, p2, p3, p4, capyBrown)
end
-- Draws the selected cursor effect if enabled
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function drawCursorEffect(globalVars)
    local cursorEffect = CURSOR_EFFECTS_OPTIONS[globalVars.cursorEffectIndex]
    if cursorEffect == "Off" then return end
    local effectResetAvailable = isEffectResetAvailable(cursorEffect)
    
    local o = imgui.GetOverlayDrawList()
    local m = imgui.GetMousePos()
    local t = imgui.GetTime()
    local sz = state.WindowSize
    
    if cursorEffect == "Shiny Box" then drawCoinGetEffect(effectResetAvailable, o, m, t) end
    local isGlareEffect = cursorEffect == "Shiny Mouse Click" or
                          cursorEffect == "Shiny Mouse Down" or
                          cursorEffect == "Shiny Always On"
    if isGlareEffect then drawGlareEffect(effectResetAvailable, o, m, t) end
    if cursorEffect == "Circle" then drawRingEffect(effectResetAvailable, o, m, t) end
    
end
-- Parameters
--    effectResetAvailable : whether or not the effect can be reset [Boolean]
--    o                    : imgui overlay drawlist
--    m                    : mouse position/coordinates {x, y} [Table]
--    t                    : imgui time [Float]
function drawCoinGetEffect(effectResetAvailable, o, m, t)
    local function generateGlare(m, t)
        return {m, 0, t}
    end
    
    local maxNumGlares = 1
    local glareInfo = {}
    if not state.GetValue("startBoxEffect") then
        for i = 1, maxNumGlares do
            glareInfo[i] = generateGlare(m, t)
        end
        state.SetValue("startBoxEffect", true)
    else
        for i = 1, maxNumGlares do
            glareInfo[i] = {}
        end
    end
    getVariables("cursorBoxEffect", glareInfo)
    
    local timeSpeed = 2
    for i = 1, maxNumGlares do
        local glareCoordinates = glareInfo[i][1]
        local glareAngle = glareInfo[i][2]
        local glareStartTime = glareInfo[i][3]
        local timeElapsed = t - glareStartTime
        local phaseTime = 0.8 + timeSpeed * timeElapsed
        if phaseTime >= 2 and effectResetAvailable then
            glareInfo[i] = generateGlare(m, t)
        elseif phaseTime >= 0 and phaseTime < 2 then
            drawSingleGlare(o, phaseTime, glareAngle, glareCoordinates, 3)
            local spacing = 20
            local newCoords1 = {glareCoordinates[1] + spacing, glareCoordinates[2] + spacing}
            local newCoords2 = {glareCoordinates[1] + spacing, glareCoordinates[2] - spacing}
            local newCoords3 = {glareCoordinates[1] - spacing, glareCoordinates[2] + spacing}
            local newCoords4 = {glareCoordinates[1] - spacing, glareCoordinates[2] - spacing}
            local smallGlareSize = 1.5
            local smallTimeOffset = 0.5
            drawSingleGlare(o, phaseTime - smallTimeOffset, glareAngle, newCoords1, smallGlareSize)
            drawSingleGlare(o, phaseTime - smallTimeOffset, glareAngle, newCoords2, smallGlareSize)
            drawSingleGlare(o, phaseTime - smallTimeOffset, glareAngle, newCoords3, smallGlareSize)
            drawSingleGlare(o, phaseTime - smallTimeOffset, glareAngle, newCoords4, smallGlareSize)
            local newX = glareCoordinates[1]
            local newY = glareCoordinates[2] -- + 4 * (timeElapsed - 0.2)
            glareInfo[i][1] = {newX, newY}
        end
    end
    saveVariables("cursorBoxEffect", glareInfo)
end
-- Draws the glare cursor effect
-- Parameters
--    effectResetAvailable : whether or not the effect can be reset [Boolean]
--    o                    : imgui overlay drawlist
--    m                    : mouse position/coordinates {x, y} [Table]
--    t                    : imgui time [Float]
function drawGlareEffect(effectResetAvailable, o, m, t)
    local cursorRadius = 50
    
    local function generateRandomGlare(cursorRadius, t)
        local randomCoordAngle = 2 * math.pi * math.random()
        local randomXNearCursor = m[1] + cursorRadius * math.cos(randomCoordAngle)
        local randomYNearCursor = m[2] + cursorRadius * math.sin(randomCoordAngle)
        local randomCoordNearCursor = {randomXNearCursor, randomYNearCursor}
        local randomAngle = (math.pi / 2) * math.random()
        local randomStartTime = t + math.random() / 4
        return {randomCoordNearCursor, randomAngle, randomStartTime}
    end
    
    local maxNumGlares = 2
    local glareInfo = {}
    if not state.GetValue("startCursorEffect") then
        for i = 1, maxNumGlares do
            glareInfo[i] = generateRandomGlare(cursorRadius, t)
        end
        state.SetValue("startCursorEffect", true)
    else
        for i = 1, maxNumGlares do
            glareInfo[i] = {}
        end
    end
    getVariables("cursorGlares", glareInfo)
    
    local timeSpeed = 3
    for i = 1, maxNumGlares do
        local glareCoordinates = glareInfo[i][1]
        local glareAngle = glareInfo[i][2]
        local glareStartTime = glareInfo[i][3]
        local timeElapsed = t - glareStartTime
        local phaseTime = timeSpeed * timeElapsed
        if phaseTime >= 2 and effectResetAvailable then
            glareInfo[i] = generateRandomGlare(cursorRadius, t)
        elseif phaseTime >= 0 and phaseTime < 2 then
            drawSingleGlare(o, phaseTime, glareAngle, glareCoordinates, 3)
        end
    end
    saveVariables("cursorGlares", glareInfo)
end
-- Draws the ring cursor effect
-- Parameters
--    effectResetAvailable : whether or not the effect can be reset [Boolean]
--    o                    : imgui overlay drawlist
--    m                    : mouse position/coordinates {x, y} [Table]
--    t                    : imgui time [Float]
function drawRingEffect(effectResetAvailable, o, m, t)
    local function generateRing(t, m)
        local ringInfo = {
            startTime = t,
            maxRadius = state.WindowSize[2] / 30,
            coords = m
        }
        return ringInfo
    end
    
    local maxNumRings = 10
    local ringInfo = {}
    if not state.GetValue("startRingEffect") then
        for i = 1, maxNumRings do
            ringInfo[i] = generateRing(t - 20, m)
        end
        state.SetValue("startRingEffect", true)
    else
        for i = 1, maxNumRings do
            ringInfo[i] = {}
        end
    end
    getVariables("ringInfo", ringInfo)
    
    local ringTotalTime = 0.7
    local ringColor = rgbaToUint(255, 255, 255, 127)
    local updatedOneRing = false
    for i = 1, maxNumRings do
        local thisRing = ringInfo[i]
        local timeElapsed = t - thisRing.startTime
        if timeElapsed >= 0 and timeElapsed < ringTotalTime then
            local percentTimeElapsed = (ringTotalTime - timeElapsed) / ringTotalTime
            local bezierMultiplier = simplifiedOneDimensionalBezier(0, 1.5, percentTimeElapsed)
            local currentRadius = thisRing.maxRadius * bezierMultiplier
            o.AddCircleFilled(thisRing.coords, currentRadius, ringColor, 20)
        elseif effectResetAvailable and (not updatedOneRing) and timeElapsed >= ringTotalTime then
            updatedOneRing = true
            ringInfo[i] = generateRing(t, m)
        end
    end
    saveVariables("ringInfo", ringInfo)
end
-- Draws a single glare
-- Parameters
--    o                : imgui overlay drawlist
--    phaseTime        : phase time of the glare [Int/Float]
--    glareAngle       : angle of the glare [Int/Float]
--    glareCoordinates : coordinates of the glare [Table]
--    innerMaxRadius   : inner radius of glare [Int/Float]
function drawSingleGlare(o, phaseTime, glareAngle, glareCoordinates, innerMaxRadius)
    local white = rgbaToUint(255, 255, 255, 255)
    local yellowTint = rgbaToUint(255, 255, 100, 30)
    local actualMaxInnerRadius = innerMaxRadius
    local innerRadius = actualMaxInnerRadius * math.abs(((phaseTime + 1) % 2) - 1)
    local outerRadiusRatio = 8
    local innerPoints = {}
    local outerPoints = {}
    for j = 1, 4 do
        local currentAngle = glareAngle + (math.pi / 2) * j
        local innerX = innerRadius * math.cos(currentAngle)
        local innerY = innerRadius * math.sin(currentAngle)
        local outerX = outerRadiusRatio * innerX
        local outerY = outerRadiusRatio * innerY
        innerPoints[j] = {innerX + glareCoordinates[1], innerY + glareCoordinates[2]}
        outerPoints[j] = {outerX + glareCoordinates[1], outerY + glareCoordinates[2]}
    end
    o.AddQuadFilled(innerPoints[1], outerPoints[2], innerPoints[3], outerPoints[4], white)
    o.AddQuadFilled(outerPoints[1], innerPoints[2], outerPoints[3], innerPoints[4], white)
    local circleSize1 = innerRadius * outerRadiusRatio / 1.2
    local circleSize2 = innerRadius * outerRadiusRatio / 3
    local numPointsOnCircle = 40
    o.AddCircleFilled(glareCoordinates, circleSize1, yellowTint, numPointsOnCircle)
    o.AddCircleFilled(glareCoordinates, circleSize2, yellowTint, numPointsOnCircle)
end
-- Returns whether or not an effect reset is available to do
-- Parameters
--    cursorEffect: type of cursor effect [String]
function isEffectResetAvailable(cursorEffect)
    local mouseDownBefore = state.GetValue("isMouseDown")
    local mouseDownNow = imgui.IsAnyMouseDown()
    state.SetValue("isMouseDown", mouseDownNow)
    local mouseClicked = not mouseDownBefore and mouseDownNow
    local effectResetAvailable = true
    if cursorEffect == "Shiny Box"         then effectResetAvailable = mouseClicked end
    if cursorEffect == "Shiny Mouse Click" then effectResetAvailable = mouseClicked end
    if cursorEffect == "Shiny Mouse Down"  then effectResetAvailable = mouseDownNow end
    if cursorEffect == "Circle"            then effectResetAvailable = mouseClicked end
    return effectResetAvailable
end
-- Converts an RGBA color value into uint (unsigned integer) and returns the converted value [Int]
-- Parameters
--    r : red value [Int]
--    g : green value [Int]
--    b : blue value [Int]
--    a : alpha value [Int]
function rgbaToUint(r, g, b, a) return a*16^6 + b*16^4 + g*16^2 + r end
-- Configures the plugin GUI appearance
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function setPluginAppearance(globalVars)
    local colorTheme = COLOR_THEMES[globalVars.colorThemeIndex]
    local styleTheme = STYLE_THEMES[globalVars.styleThemeIndex]
    
    setPluginAppearanceStyles(styleTheme)
    setPluginAppearanceColors(globalVars, colorTheme)
    
    local rgbColorTheme = colorTheme == "RGB Gamer Mode" or colorTheme == "Glass + RGB" or
                          colorTheme == "Incognito + RGB"
    if rgbColorTheme and (not globalVars.rgbPaused) then updateRGBColors(globalVars) end
end
-- Configures the plugin GUI styles
-- Parameters
--    styleTheme : name of the desired style theme [String]
function setPluginAppearanceStyles(styleTheme)
    local boxed = styleTheme == "Boxed" or styleTheme == "Boxed + Border"
    local cornerRoundnessValue = 5 -- up to 12, 14 for WindowRounding and 16 for ChildRounding
    if boxed then cornerRoundnessValue = 0 end
    
    local addBorder = styleTheme == "Rounded + Border" or styleTheme == "Boxed + Border"
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
    
    -- not working? TabBorderSize doesn't exist? But it's changeable in the style editor demo?
    -- imgui.PushStyleVar( imgui_style_var.TabBorderSize,      borderSize           ) 
end
-- Configures the plugin GUI colors
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    colorTheme : name of the target color theme [String]
function setPluginAppearanceColors(globalVars, colorTheme)
    if colorTheme == "Classic" then
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
        imgui.PushStyleColor( imgui_col.Text,                   { 1.00, 1.00, 1.00, 1.00 } )
        imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 0.81, 0.88, 1.00, 0.40 } )
        imgui.PushStyleColor( imgui_col.ScrollbarGrab,          { 0.31, 0.38, 0.50, 1.00 } )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   { 0.41, 0.48, 0.60, 1.00 } )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    { 0.51, 0.58, 0.70, 1.00 } )
        imgui.PushStyleColor( imgui_col.PlotLines,              { 0.61, 0.61, 0.61, 1.00 } )
        imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 1.00, 0.43, 0.35, 1.00 } )
        imgui.PushStyleColor( imgui_col.PlotHistogram,          { 0.90, 0.70, 0.00, 1.00 } )
        imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 1.00, 0.60, 0.00, 1.00 } )
    elseif colorTheme == "Strawberry" then
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
        imgui.PushStyleColor( imgui_col.Text,                   { 1.00, 1.00, 1.00, 1.00 } )
        imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 1.00, 0.81, 0.88, 0.40 } )
        imgui.PushStyleColor( imgui_col.ScrollbarGrab,          { 0.50, 0.31, 0.38, 1.00 } )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   { 0.60, 0.41, 0.48, 1.00 } )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    { 0.70, 0.51, 0.58, 1.00 } )
        imgui.PushStyleColor( imgui_col.PlotLines,              { 0.61, 0.61, 0.61, 1.00 } )
        imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 1.00, 0.43, 0.35, 1.00 } )
        imgui.PushStyleColor( imgui_col.PlotHistogram,          { 0.90, 0.70, 0.00, 1.00 } )
        imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 1.00, 0.60, 0.00, 1.00 } )
    elseif colorTheme == "Incognito" then
        local black = {0.00, 0.00, 0.00, 1.00}
        local white = {1.00, 1.00, 1.00, 1.00}
        local grey = {0.20, 0.20, 0.20, 1.00}
        local whiteTint = {1.00, 1.00, 1.00, 0.40}
        local red = {1.00, 0.00, 0.00, 1.00}
        
        imgui.PushStyleColor( imgui_col.WindowBg,               black     )
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
    elseif colorTheme == "Incognito + RGB" then
        local black = {0.00, 0.00, 0.00, 1.00}
        local white = {1.00, 1.00, 1.00, 1.00}
        local grey = {0.20, 0.20, 0.20, 1.00}
        local whiteTint = {1.00, 1.00, 1.00, 0.40}
        local rgbColor = {globalVars.red, globalVars.green, globalVars.blue, 0.8}
        
        imgui.PushStyleColor( imgui_col.WindowBg,               black     )
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
    elseif colorTheme == "Barbie" then
        local pink = {0.79, 0.31, 0.55, 1.00}
        local white = {0.95, 0.85, 0.87, 1.00}
        local blue = {0.37, 0.64, 0.84, 1.00}
        local pinkTint = {1.00, 0.86, 0.86, 0.40}
        
        imgui.PushStyleColor( imgui_col.WindowBg,               pink     )
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
    elseif colorTheme == "Glass" then
        local transparent = {0.00, 0.00, 0.00, 0.25}
        local transparentWhite = {1.00, 1.00, 1.00, 0.70}
        local whiteTint = {1.00, 1.00, 1.00, 0.30}
        local white = {1.00, 1.00, 1.00, 1.00}
        
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
        imgui.PushStyleColor( imgui_col.Text,                   white            )
        imgui.PushStyleColor( imgui_col.TextSelectedBg,         whiteTint        )
        imgui.PushStyleColor( imgui_col.ScrollbarGrab,          whiteTint        )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   transparentWhite )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    transparentWhite )
        imgui.PushStyleColor( imgui_col.PlotLines,              whiteTint        )
        imgui.PushStyleColor( imgui_col.PlotLinesHovered,       transparentWhite )
        imgui.PushStyleColor( imgui_col.PlotHistogram,          whiteTint        )
        imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   transparentWhite )
    elseif colorTheme == "Glass + RGB" then
        local transparent = {0.00, 0.00, 0.00, 0.25}
        local activeColor = {globalVars.red, globalVars.green, globalVars.blue, 0.8}
        local colorTint = {globalVars.red, globalVars.green, globalVars.blue, 0.3}
        local white = {1.00, 1.00, 1.00, 1.00}
        
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
        imgui.PushStyleColor( imgui_col.Text,                   white       )
        imgui.PushStyleColor( imgui_col.TextSelectedBg,         colorTint   )
        imgui.PushStyleColor( imgui_col.ScrollbarGrab,          colorTint   )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   activeColor )
        imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    activeColor )
        imgui.PushStyleColor( imgui_col.PlotLines,              activeColor )
        imgui.PushStyleColor( imgui_col.PlotLinesHovered,       colorTint   )
        imgui.PushStyleColor( imgui_col.PlotHistogram,          activeColor )
        imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   colorTint   )
    elseif colorTheme == "RGB Gamer Mode" then
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
        colorThemeIndex = 1,
        styleThemeIndex = 1,
        cursorEffectIndex = 1,
        red = 0,
        green = 1,
        blue = 1,
        rgbPaused = false,
        drawCapybara = false,
        showNoteMover = false,
        editToolIndex = 1,
        placeTypeIndex = 1,
        debugText = "debuggy capybara"
    }
    getVariables("globalVars", globalVars)
    setPluginAppearance(globalVars)
    setWindowFocusIfHotkeysPressed()
    initializeNextWindowNotCollapsed("mainCollapsed")
    drawCapybara(globalVars)
    drawCursorEffect(globalVars)
    
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
    local ctrlPressedDown = utils.IsKeyDown(keys.LeftControl) or utils.IsKeyDown(keys.RightControl)
    local shiftPressedDown = utils.IsKeyDown(keys.LeftShift) or utils.IsKeyDown(keys.RightShift)
    local tabPressed = utils.IsKeyPressed(keys.Tab)
    if not (ctrlPressedDown and shiftPressedDown and tabPressed) then return end
    
    local windowWidth, windowHeight = table.unpack(state.WindowSize)
    local pluginWidth, pluginHeight = table.unpack(imgui.GetWindowSize())
    local centeringX = (windowWidth - pluginWidth) / 2
    local centeringY = (windowHeight - pluginHeight) / 2
    local coordinatesToCenter = {centeringX, centeringY}
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
    explainHowToUsePlugin()
    showShortcuts()
    showInfoLinks()
    choosePluginBehavior(globalVars)
    choosePluginAppearance(globalVars)
end
-- Explains how to use the plugin
function explainHowToUsePlugin()
    if not imgui.CollapsingHeader("How to amoguSV") then return end
    local indentAmount = 10
    imgui.Indent(indentAmount)
    imgui.Text("1. ) Select an SV tool")
    imgui.Text("2. ) Change the tool's settings")
    imgui.Text("3. ) Select notes")
    imgui.Text("4. ) Press ' T ' (or click the button that appears)")
    imgui.Unindent(indentAmount)
    addPadding()
end
-- Lists shortcuts for the plugin
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
    toolTip("Use this to do SV stuff for a quick workflow")
    addPadding()
    imgui.Unindent(indentWidth)
end
-- Provides links relevant to the plugin
function showInfoLinks()
    if not imgui.CollapsingHeader("Links") then return end
    provideLink("Quaver SV Guide", "https://kloi34.github.io/QuaverSVGuide")
    provideLink("GitHub Repository", "https://github.com/kloi34/amoguSV")
end
-- Lets you choose global plugin behavior settings
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function choosePluginBehavior(globalVars)
    if not imgui.CollapsingHeader("Plugin Behavior") then return end
    addPadding()
    chooseSVSelection(globalVars)
    addSeparator()
    choosePlaceBehavior(globalVars)
    chooseShowNoteMover(globalVars)
    addPadding()
end
-- Lets you choose global plugin appearance settings
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function choosePluginAppearance(globalVars)
    if not imgui.CollapsingHeader("Plugin Appearance") then return end
    addPadding()
    chooseStyleTheme(globalVars)
    chooseColorTheme(globalVars)
    chooseCursorEffect(globalVars)
    chooseRGBPause(globalVars)
    chooseDrawCapybara(globalVars)
    addSeparator()
    explainHowToChangeDefaults()
end
-- Explains to the user how to change default settings
function explainHowToChangeDefaults()
    imgui.TextDisabled("How to permanently change default settings?")
    if not imgui.IsItemHovered() then return end
    imgui.BeginTooltip()
    imgui.BulletText("Open the plugin file (\"plugin.lua\") in a text editor or code editor")
    imgui.BulletText("Find the line with \"local globalVars = { \"")
    imgui.BulletText("Edit values in globalVars that correspond to a plugin setting")
    imgui.BulletText("Save the file with changes and reload the plugin")
    imgui.Text("Example: change \"colorThemeIndex = 1,\" to \"colorThemeIndex = 2,\"")
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
    if toolName == "Add Teleport"     then addTeleportMenu(globalVars) end
    if toolName == "Copy & Paste"     then copyNPasteMenu(globalVars) end
    if toolName == "Displace Note"    then displaceNoteMenu(globalVars) end
    if toolName == "Displace View"    then displaceViewMenu(globalVars) end
    if toolName == "Fix LN Ends"      then fixLNEndsMenu(globalVars) end
    if toolName == "Flicker"          then flickerMenu(globalVars) end
    if toolName == "Measure"          then measureSVMenu(globalVars) end
    if toolName == "Merge"            then simpleActionMenu("Merge", mergeSVs, globalVars, nil) end
    if toolName == "Reverse Scroll"   then reverseScrollEditMenu(globalVars) end
    if toolName == "Scale (Multiply)" then scaleMultiplySVMenu(globalVars) end
    if toolName == "Scale (Displace)" then scaleDisplaceSVMenu(globalVars) end
    if toolName == "Swap Notes"       then simpleActionMenu("Swap note", swapNoteSVs, globalVars,
                                                            nil) end
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
        svGraphStats = createSVGraphStats(),
        svStats = createSVStats(),
        interlace = false,
        interlaceRatio = -0.5
    }
    getVariables("placeStandardMenu", menuVars)
    local needSVUpdate = #menuVars.svMultipliers == 0
    
    needSVUpdate = chooseStandardSVType(menuVars) or needSVUpdate
    addSeparator()
    
    settingsGraphsAndPlaceMenu(globalVars, menuVars, needSVUpdate)
    saveVariables("placeStandardMenu", menuVars)
end
-- Creates part of the menu for placing standard or still SVs: settings, graphs, and place button
-- Parameters
--    globalVars   : list of variables used globally across all menus [Table]
--    menuVars     : list of setting variables for the current menu [Table]
--    needSVUpdate : whether or not SV info needs to be updated [Boolean]
function settingsGraphsAndPlaceMenu(globalVars, menuVars, needSVUpdate)
    local currentSVType = STANDARD_SVS[menuVars.svTypeIndex]
    local settingVars = getSettingVars(currentSVType)
    local menuFunctionName = string.lower(currentSVType).."SettingsMenu"
    needSVUpdate = _G[menuFunctionName](settingVars) or needSVUpdate
    
    addSeparator()
    needSVUpdate = chooseInterlace(menuVars) or needSVUpdate
    if needSVUpdate then updateMenuSVs(currentSVType, menuVars, settingVars) end
    initializeNextWindowNotCollapsed("infoCollapsed")
    makeSVInfoWindow("SV Info", menuVars.svGraphStats, menuVars.svStats, menuVars.svDistances,
                     menuVars.svMultipliers, nil)
    
    addSeparator()
    simpleActionMenu("Place", placeSVs, globalVars, menuVars)
    saveVariables(currentSVType.."Settings", settingVars)
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
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this exponential menu [Table]
function exponentialSettingsMenu(settingVars)
    local settingsChanged = false
    settingsChanged = chooseSVBehavior(settingVars) or settingsChanged
    settingsChanged = chooseIntensity(settingVars) or settingsChanged
    settingsChanged = chooseConstantShift(settingVars, 0) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for bezier SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this bezier menu [Table]
function bezierSettingsMenu(settingVars)
    local settingsChanged = false
    settingsChanged = provideBezierWebsiteLink(settingVars) or settingsChanged
    settingsChanged = chooseBezierPoints(settingVars) or settingsChanged
    settingsChanged = chooseConstantShift(settingVars, 0) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for hermite SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this bezier menu [Table]
function hermiteSettingsMenu(settingVars)
    local settingsChanged = false
    settingsChanged = chooseStartEndSVs(settingVars) or settingsChanged
    helpMarker("Target Start/End SVs. If you increase the number of SV points or manually "..
               "adjust vertical shift, you can get closer to those targets")
    settingsChanged = chooseConstantShift(settingVars, 0) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for sinusoidal SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this sinusoidal menu [Table]
function sinusoidalSettingsMenu(settingVars)
    local settingsChanged = false
    imgui.Text("Amplitude:")
    settingsChanged = chooseStartEndSVs(settingVars) or settingsChanged
    settingsChanged = chooseCurveSharpness(settingVars) or settingsChanged
    settingsChanged = chooseConstantShift(settingVars, 1) or settingsChanged
    settingsChanged = chooseNumPeriods(settingVars) or settingsChanged
    settingsChanged = choosePeriodShift(settingVars) or settingsChanged
    settingsChanged = chooseSVPerQuarterPeriod(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for circular SV settings
-- Returns whether settings have changed or not [Boolean]
-- Parameters
--    settingVars : list of setting variables for this sinusoidal menu [Table]
function circularSettingsMenu(settingVars)
    local settingsChanged = false
    settingsChanged = chooseSVBehavior(settingVars) or settingsChanged
    settingsChanged = chooseArcPercent(settingVars) or settingsChanged
    settingsChanged = chooseAverageSV(settingVars) or settingsChanged
    settingsChanged = chooseConstantShift(settingVars, 0) or settingsChanged
    settingsChanged = chooseSVPoints(settingVars) or settingsChanged
    settingsChanged = chooseFinalSV(settingVars) or settingsChanged
    settingsChanged = chooseNoNormalize(settingVars) or settingsChanged
    return settingsChanged
end
-- Creates the menu for random SV settings
-- Returns whether settings have changed or not [Boolean]
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
-- Returns whether settings have changed or not [Boolean]
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
    if currentSVType == "Stutter"                then stutterMenu(globalVars) end
    if currentSVType == "Teleport Stutter"       then telportStutterMenu(globalVars) end
    if currentSVType == "Reverse Scroll"         then reverseScrollMenu(globalVars) end
    if currentSVType == "Splitscroll (Basic)"    then splitScrollBasicMenu(globalVars) end
    if currentSVType == "Splitscroll (Advanced)" then splitScrollAdvancedMenu(globalVars) end
    if currentSVType == "Animate"                then animateMenu(globalVars) end
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
        controlLastSV = false,
        svMultipliers = {},
        svDistances = {},
        svGraphStats = createSVGraphStats(),
        svMultipliers2 = {},
        svDistances2 = {},
        svGraph2Stats = createSVGraphStats()
    }
    getVariables("stutterMenu", menuVars)
    
    local settingsChanged = #menuVars.svMultipliers == 0
    settingsChanged = chooseControlSecondSV(menuVars) or settingsChanged
    settingsChanged = chooseStartEndSVs(menuVars) or settingsChanged
    settingsChanged = chooseStutterDuration(menuVars) or settingsChanged
    settingsChanged = chooseLinearlyChange(menuVars) or settingsChanged
    
    addSeparator()
    settingsChanged = chooseStuttersPerSection(menuVars) or settingsChanged
    settingsChanged = chooseAverageSV(menuVars) or settingsChanged
    settingsChanged = chooseFinalSV(menuVars) or settingsChanged
    if settingsChanged then updateStutterMenuSVs(menuVars) end
    displayStutterSVWindows(menuVars)
    
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
        svPercent2 = 0,
        distance = 50,
        mainSV = 0.5,
        mainSV2 = 0,
        useDistance = false,
        linearlyChange = false,
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
    chooseLinearlyChange(menuVars)
    
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
    helpMarker("Height at which reverse scroll notes are hit")
    
    addSeparator()
    simpleActionMenu("Place", placeReverseScrollSVs, globalVars, menuVars)
    saveVariables("reverseScrollMenu", menuVars)
end
-- Creates the menu for basic splitscroll SV
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function splitScrollBasicMenu(globalVars)
    local menuVars = {
        scrollSpeed1 = 0.9,
        height1 = 0,
        scrollSpeed2 = -0.9,
        height2 = 400,
        distanceBack = 1000000,
        msPerFrame = 16,
        noteTimes2 = {},
    }
    getVariables("splitScrollBasicMenu", menuVars)
    makeNoteMoverWindow(globalVars)
    
    addPadding()
    chooseFirstScrollSpeed(menuVars)
    chooseFirstHeight(menuVars)
    chooseSecondScrollSpeed(menuVars)
    chooseSecondHeight(menuVars)
    chooseMSPF(menuVars)
    
    addSeparator()
    local noNoteTimesInitially = #menuVars.noteTimes2 == 0
    addOrClearNoteTimes(menuVars, noNoteTimesInitially)
    saveVariables("splitScrollBasicMenu", menuVars)
    if noNoteTimesInitially then return end
    
    addSeparator()
    simpleActionMenu("Place Splitscroll", placeSplitScrollSVs, globalVars, menuVars)
end
-- Creates the menu for advanced splitscroll SV
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function splitScrollAdvancedMenu(globalVars)
    local menuVars = {
        distanceBack = 1000000,
        msPerFrame = 16,
        noteTimes2 = {},
        svsInScroll2 = {}
    }
    getVariables("splitScrollAdvancedMenu", menuVars)
    makeNoteMoverWindow(globalVars)
    
    addPadding()
    chooseDistanceBack(menuVars)
    chooseMSPF(menuVars)
    
    addSeparator()
    local noNoteTimesInitially = #menuVars.noteTimes2 == 0
    addOrClearNoteTimes(menuVars, noNoteTimesInitially)
    if noNoteTimesInitially then saveVariables("splitScrollAdvancedMenu", menuVars) return end
    
    addSeparator()
    local noSVsInitially = #menuVars.svsInScroll2 == 0
    addOrClearSVs(menuVars, noSVsInitially)
    saveVariables("splitScrollAdvancedMenu", menuVars) 
    if noSVsInitially then return end
    
    addSeparator()
    simpleActionMenu("Place Splitscroll", placeAdvancedSplitScrollSVs, globalVars, menuVars)
end
-- Creates the menu for animation SV
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function animateMenu(globalVars)
    local menuVars = {
        numFrames = 5,
        frameTimes = {},
        laneCounts = zerosList(map.GetKeyCount()),
        selectedTimeIndex = 1,
        currentFrame = 1,
        frameDistance = 2000,
        addNoteDataIndex = 1,
        exportText = "",
        importText = ""
    }
    getVariables("animateMenu", menuVars)
    imgui.BeginTabBar("SV tabs")
    if imgui.BeginTabItem("Settings") then
        addPadding()
        makeNoteMoverWindow(globalVars)
        chooseNumFrames(menuVars)
        chooseFrameDistance(menuVars)
        chooseNoteAnimationData(menuVars)
        addSeparator()
        local behavior = ANIMATION_OPTIONS[menuVars.addNoteDataIndex]
        if behavior == "Manually Add" then
            displayLaneNoteCounts(menuVars)
            addFrameTimes(menuVars)
            button("Clear/Reset All Notes", ACTION_BUTTON_SIZE, resetFrameTimes,
                   globalVars, menuVars)
        elseif behavior == "Import/Export" then
            importAnimationMenu(globalVars, menuVars)
            addSeparator()
            exportAnimationMenu(globalVars, menuVars)
        end
        imgui.EndTabItem()
    end
    local frameTimesExist = #menuVars.frameTimes ~= 0
    if frameTimesExist and imgui.BeginTabItem("Notes & Frames") then
        addPadding()
        imgui.Columns(2, "Times + Frames", false)
        displayFrameTimes(menuVars)
        chooseFrameTimeData(menuVars)
        imgui.NextColumn()
        chooseCurrentFrame(menuVars)
        drawCurrentFrame(menuVars)
        imgui.Columns(1)
        imgui.PushItemWidth(2 * (ACTION_BUTTON_SIZE[1] + 1.5 * SAMELINE_SPACING))
        local text = "sv stands for scroll veleocity"
        imgui.InputText("##capybara", text, #text, imgui_input_text_flags.AutoSelectAll)
        imgui.PopItemWidth()
        imgui.EndTabItem()
    end
    if frameTimesExist and imgui.BeginTabItem("Finish") then
        addPadding()
        imgui.TextWrapped("Select the last note BEFORE ALL ANIMATION NOTES to begin animation at")
        addSeparator()
        simpleActionMenu("Begin animation", placeAnimationSVs, globalVars, menuVars)
        imgui.EndTabItem()
    end
    imgui.EndTabBar()
    saveVariables("animateMenu", menuVars)
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
        prePlaceDistances = {},
        svMultipliers = {},
        svDistances = {},
        svGraphStats = createSVGraphStats(),
        svStats = createSVStats(),
        interlace = false,
        interlaceRatio = -0.5
    }
    getVariables("placeStillMenu", menuVars)
    local needSVUpdate = #menuVars.svMultipliers == 0
    
    needSVUpdate = chooseStandardSVType(menuVars) or needSVUpdate
    addPadding()
    imgui.Text("Still Settings:")
    chooseNoteSpacing(menuVars)
    chooseStillType(menuVars)
    addSeparator()
    
    settingsGraphsAndPlaceMenu(globalVars, menuVars, needSVUpdate)
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
    toolTip("You can also press ' T ' on your keyboard to paste SVs at selected notes")
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
-- Creates the fix flipped LN ends menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function fixLNEndsMenu(globalVars)
    local menuVars = {
        fixedLNEndsAmount = 0
    }
    getVariables("fixLNEndsMenu", menuVars)
    imgui.Text("Fixed "..menuVars.fixedLNEndsAmount.." flipped LN ends")
    helpMarker("If there is a negative SV at an LN end, the LN end will be flipped. This is "..
              "noticable especially for arrow skins and is jarring. This tool will fix that.")
    addSeparator()
    button("Fix flippped LN ends", ACTION_BUTTON_SIZE, fixFlippedLNEnds, globalVars, menuVars)
    toolTip("You can also press ' T ' on your keyboard to do the same thing as this button")
    ifKeyPressedThenExecute(keys.T, fixFlippedLNEnds, globalVars, menuVars)
    saveVariables("fixLNEndsMenu", menuVars)
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
-- Creates the reverse scroll (edit) menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function reverseScrollEditMenu(globalVars)
    local menuVars = {
        distance = 400
    }
    getVariables("reverseScrollEditMenu", menuVars)
    
    imgui.TextWrapped("NOTE: the only way to undo this effect is to do two undos (Ctrl + Z twice)")
    
    addSeparator()
    chooseDistance(menuVars)
    helpMarker("Height at which reverse scroll notes are hit")
    
    addSeparator()
    simpleActionMenu("Reverse scroll", editReverseScrollSVs, globalVars, menuVars)
    saveVariables("reverseScrollEditMenu", menuVars)
end
-- Creates the scale (displace) menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function scaleDisplaceSVMenu(globalVars)
    local menuVars = {
        scaleTypeIndex = 1,
        avgSV = 0.6,
        distance = 100,
        scaleSpotIndex = 1
    }
    getVariables("scaleDisplaceMenu", menuVars)
    chooseSVScaleDisplace(menuVars)
    chooseSVScaleDisplaceSpot(menuVars)
    addSeparator()
    simpleActionMenu("Scale", scaleDisplaceSVs, globalVars, menuVars)
    saveVariables("scaleDisplaceMenu", menuVars)
end
-- Creates the scale (mxultiply) menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function scaleMultiplySVMenu(globalVars)
    local menuVars = {
        scaleTypeIndex = 1,
        avgSV = 0.6,
        startSV = 1,
        endSV = 0.5,
        distance = 100,
        ratio = 0.6,
        sectionIndex = 1
    }
    getVariables("scaleMultiplyMenu", menuVars)
    chooseSVScale(menuVars)
    chooseSection(globalVars, menuVars)
    addSeparator()
    simpleActionMenu("Scale", scaleMultiplySVs, globalVars, menuVars)
    saveVariables("scaleMultiplyMenu", menuVars)
end

-------------------------------------------------------------------------------------- Menu related

-- Creates a button that adds frameTime objects to the list for the animate menu
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function addFrameTimes(menuVars)
    if not imgui.Button("Assign selected notes for animation", ACTION_BUTTON_SIZE) then return end
    
    menuVars.laneCounts = zerosList(map.GetKeyCount())
    local hasAlreadyAddedLaneTime = {}
    for i = 1, map.GetKeyCount() do
        table.insert(hasAlreadyAddedLaneTime, {})
    end
    local frameTimeToIndex = {}
    local totalTimes = #menuVars.frameTimes
    for i = 1, totalTimes do
        local frameTime = menuVars.frameTimes[i]
        local time = frameTime.time
        local lanes = frameTime.lanes
        frameTimeToIndex[time] = i
        for j = 1, #lanes do
            local lane = lanes[j]
            hasAlreadyAddedLaneTime[lane][time] = true
            menuVars.laneCounts[lane] = menuVars.laneCounts[lane] + 1
        end
    end
    for _, hitObject in pairs(state.SelectedHitObjects) do
        local lane = hitObject.Lane
        local time = hitObject.StartTime
        if (not hasAlreadyAddedLaneTime[lane][time]) then
            hasAlreadyAddedLaneTime[lane][time] = true
            menuVars.laneCounts[lane] = menuVars.laneCounts[lane] + 1
            if frameTimeToIndex[time] then
                local index = frameTimeToIndex[time]
                local frameTime = menuVars.frameTimes[index]
                table.insert(frameTime.lanes, lane)
                frameTime.lanes = table.sort(frameTime.lanes, function(a, b) return a < b end)
            else
                table.insert(menuVars.frameTimes, createFrameTime(time, {lane}, 1, 0))
                frameTimeToIndex[time] = #menuVars.frameTimes
            end  
        end
    end
    menuVars.frameTimes = table.sort(menuVars.frameTimes, function(a, b) return a.time < b.time end)
end
-- Adds or clears note times for the 2nd scroll for the splitscroll menu
-- Parameters
--    menuVars             : list of variables used for the current SV menu [Table]
--    noNoteTimesInitially : whether or not there were note times initially [Boolean]
function addOrClearNoteTimes(menuVars, noNoteTimesInitially)
    imgui.Text(#menuVars.noteTimes2.." note times assigned for 2nd scroll")
    if imgui.Button("Assign selected note times to 2nd scroll", ACTION_BUTTON_SIZE) then
        addSelectedNoteTimes(menuVars)
    end
    
    if noNoteTimesInitially then return end
    if not imgui.Button("Clear all 2nd scroll note times", ACTION_BUTTON_SIZE) then return end
    menuVars.noteTimes2 = {}
end
-- Adds or clears SVs for the 2nd scroll for the splitscroll menu
-- Parameters
--    menuVars       : list of variables used for the current SV menu [Table]
--    noSVsInitially : whether or not there were SVs initially [Boolean]
function addOrClearSVs(menuVars, noSVsInitially)
    imgui.Text(#menuVars.svsInScroll2.." SVs assigned for 2nd scroll")
    helpMarker("Steps:\n1. ) Place SVs for 2nd scroll:\n2. ) Assign SVs to 2nd scroll with the "..
               "button\n3. ) Delete all SVs used for 2nd scroll (use \"Delete SVs\" tab)\n4. "..
               ") Place SVs for 1st scroll\n5. ) Place splitscroll SVs")
    local function addSecondScrollSVs(menuVars)
        if imgui.Button("Assign SVs between selected\nnotes for 2nd scroll", ACTION_BUTTON_SIZE) then
            local offsets = uniqueSelectedNoteOffsets()
            if #offsets < 2 then return end
            menuVars.svsInScroll2 = getSVsBetweenOffsets(offsets[1], offsets[#offsets])
        end
    end
    if noSVsInitially then addSecondScrollSVs(menuVars) return end
    if not imgui.Button("Clear assigned 2nd scroll SVs", ACTION_BUTTON_SIZE) then return end
    menuVars.svsInScroll2 = {}
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
-- Creates a frameTime object
-- Returns the frameTime object [Table]
-- Parameters
--    thisTime     : time in milliseconds [Int]
--    thisLanes    : note lanes [Table]
--    thisFrame    : frame number [Int]
--    thisPosition : msx position (height) on the frame [Int/Float]
function createFrameTime(thisTime, thisLanes, thisFrame, thisPosition)
    local frameTime = {
        time = thisTime,
        lanes = thisLanes,
        frame = thisFrame,
        position = thisPosition
    }
    return frameTime
end
-- Initializes a default svGraphStats object
-- Returns the svGraphStats object [Table]
function createSVGraphStats()
    local svGraphStats = {
        minScale = 0,
        maxScale = 0,
        distMinScale = 0,
        distMaxScale = 0
    }
    return svGraphStats
end
-- Initializes a default svStats object
-- Returns the svStats object [Table]
function createSVStats()
    local svStats = {
            minSV = 0,
            maxSV = 0,
            avgSV = 0
        }
    return svStats
end
-- Displays all existing frameTimes for the animate menu
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function displayFrameTimes(menuVars)
    imgui.Text("time | lanes | frame | position")
    addPadding()
    imgui.BeginChild("Times", {ACTION_BUTTON_SIZE[1], 200}, true)
    for i = 1, #menuVars.frameTimes do
        local tempList = {}
        local frameTime = menuVars.frameTimes[i]
        tempList[1] = frameTime.time
        tempList[2] = table.concat(frameTime.lanes, ", ")
        tempList[3] = frameTime.frame
        tempList[4] = frameTime.position
        local text = table.concat(tempList, " | ")
        if imgui.Selectable(text, menuVars.selectedTimeIndex == i) then
            menuVars.selectedTimeIndex = i
        end
    end
    imgui.EndChild()
end
-- Displays note counts of frame notes for the animate menu
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function displayLaneNoteCounts(menuVars)
    local countText = {"Lane note counts: { "}
    local totalNotes = 0
    for i = 1,  #menuVars.laneCounts do
        countText[2 * i] = menuVars.laneCounts[i]
        countText[2 * i + 1] = " "
        totalNotes = totalNotes + menuVars.laneCounts[i]
    end
    countText[#countText + 1] = "}"
    local laneCountText = table.concat(countText)
    imgui.Text("Total # of frame notes assigned: "..totalNotes)
    imgui.Text(laneCountText)
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
-- Makes the SV info windows for stutter SV
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function displayStutterSVWindows(menuVars)
    if menuVars.linearlyChange then
        initializeNextWindowNotCollapsed("info2Collapsed")
        makeSVInfoWindow("SV Info (Starting first SV)", menuVars.svGraphStats, nil,
                         menuVars.svDistances, menuVars.svMultipliers, menuVars.stutterDuration)
        initializeNextWindowNotCollapsed("info3Collapsed")
        makeSVInfoWindow("SV Info (Ending first SV)", menuVars.svGraph2Stats, nil,
                         menuVars.svDistances2, menuVars.svMultipliers2, menuVars.stutterDuration)
    else
        initializeNextWindowNotCollapsed("infoCollapsed")
        makeSVInfoWindow("SV Info", menuVars.svGraphStats, nil, menuVars.svDistances,
                         menuVars.svMultipliers, menuVars.stutterDuration)
    end
end
-- Draws notes from the current selected frame for the animate menu
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function drawCurrentFrame(menuVars)
    local mapKeyCount = map.GetKeyCount() 
    local childHeight = 250
    imgui.BeginChild("Frame", {ACTION_BUTTON_SIZE[1], childHeight}, true)
    local drawlist = imgui.GetWindowDrawList()
    local whiteColor = rgbaToUint(255, 255, 255, 255)
    local blueColor = rgbaToUint(53, 200, 255, 255)
    local noteWidth = 200 / mapKeyCount
    local noteHeight = round(2 * noteWidth / 5, 0)
    for _, frameTime in pairs(menuVars.frameTimes) do 
        if frameTime.frame == menuVars.currentFrame then
            for _, lane in pairs(frameTime.lanes) do
                local x1 = 10 + (noteWidth + 5) * (lane - 1)
                local y1 = (childHeight - 10) - (frameTime.position / 2)
                local x2 = x1 + noteWidth
                local y2 = y1 - noteHeight
                local p1 = coordsRelativeToWindow(x1, y1)
                local p2 = coordsRelativeToWindow(x2, y2)
                local colorNum = lane
                if mapKeyCount % 2 == 0 and colorNum > mapKeyCount / 2 then colorNum = lane + 1 end
                local color = whiteColor
                if colorNum % 2 == 0 then color = blueColor end
                drawlist.AddRectFilled(p1, p2, color)
            end
        end
    end
    imgui.EndChild()
end
-- Exports animation settings + frames, turning the data into a string
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
function exportAnimationFrames(globalVars, menuVars)
    local exportList = {}
    for i = 1, #menuVars.frameTimes do
        local tempList1 = {}
        local frameTime = menuVars.frameTimes[i]
        tempList1[1] = frameTime.time
        tempList1[2] = table.concat(frameTime.lanes, ", ")
        tempList1[3] = frameTime.frame
        tempList1[4] = frameTime.position
        local tempList2 = {}
        tempList2[1] = "{ "
        tempList2[2] = table.concat(tempList1, " | ")
        tempList2[3] = " }\n"
        exportList[i] = table.concat(tempList2)
    end
    menuVars.exportText = table.concat(exportList)
end
-- Menu that lets you export animation settings + frames
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
function exportAnimationMenu(globalVars, menuVars)
    if #menuVars.frameTimes == 0 then imgui.Text("No note/frame data to export") return end
    imgui.Text("Copy exported data + paste somewhere safe")
    imgui.InputTextMultiline("##animationExport", menuVars.exportText, #menuVars.exportText,
                             {ACTION_BUTTON_SIZE[1], 50}, imgui_input_text_flags.ReadOnly)
    button("Export Animation Data", ACTION_BUTTON_SIZE, exportAnimationFrames,
           globalVars, menuVars)
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
            verticalShift = 0,
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
            verticalShift = 0,
            avgSV = 1,
            svPoints = 16,
            finalSVIndex = 3,
            customSV = 1
        }
    elseif svType == "Hermite" then
        settingVars = {
            startSV = 0,
            endSV = 0,
            verticalShift = 0,
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
    elseif svType == "Circular" then
        settingVars = {
            behaviorIndex = 1,
            arcPercent = 50,
            avgSV = 1,
            verticalShift = 0,
            svPoints = 16,
            finalSVIndex = 3,
            customSV = 1,
            dontNormalize = false
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
-- Imports animation settings + frames from a string
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
function importAnimationFrames(globalVars, menuVars)
    resetFrameTimes(globalVars, menuVars)
    local maxKeyframe = 1
    for timeInfo in string.gmatch(menuVars.importText, "{.-}.-") do
        local captures = {}
        for capture, _ in string.gmatch(timeInfo, "%d+") do
            table.insert(captures, tonumber(capture))
        end
        local lanes = {}
        for i = 2, #captures - 2 do
            local lane = captures[i]
            lanes[i - 1] = lane
            menuVars.laneCounts[lane] = menuVars.laneCounts[lane] + 1
        end
        local time = captures[1]
        local frame = captures[#captures - 1]
        local position = captures[#captures]
        table.insert(menuVars.frameTimes, createFrameTime(time, lanes, frame, position))
        maxKeyframe = math.max(maxKeyframe, captures[#captures - 1])
    end
    if maxKeyframe > 1 then
        menuVars.numFrames = maxKeyframe
    end
    menuVars.importText = ""
end
-- Menu that lets you import animation settings + frames
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
function importAnimationMenu(globalVars, menuVars)
    imgui.Text("Paste exported note/frame data here")
    _, menuVars.importText = imgui.InputTextMultiline("##animationImport", menuVars.importText,
                                                      999999, {ACTION_BUTTON_SIZE[1], 50})
    button("Import Animation Data", ACTION_BUTTON_SIZE, importAnimationFrames,
           globalVars, menuVars)
end
-- Creates a button that lets you move notes
-- Parameters
--    milliseconds : how many milliseconds to move notes [String]
function makeNoteMoverButton(milliseconds)
    if milliseconds == 0 then return end
    local enoughtNotesSelected = checkEnoughSelectedNotes(1)
    if not enoughtNotesSelected then imgui.Text("Select 1 or more notes") return end
    if not imgui.Button("Move notes "..milliseconds.." ms") then return end
    
    local notesToRemove = state.SelectedHitObjects
    local notesToAdd = {}
    for _, note in pairs(notesToRemove) do
        local newStartTime = note.StartTime + milliseconds
        local newEndTime = note.EndTime
        if note.EndTime ~= 0 then newEndTime = note.EndTime + milliseconds end
        table.insert(notesToAdd, utils.CreateHitObject(newStartTime, note.Lane, newEndTime,
                                                       note.HitSound, note.EditorLayer))
    end
    local editorActions = {
        utils.CreateEditorAction(action_type.RemoveHitObjectBatch, notesToRemove),
        utils.CreateEditorAction(action_type.PlaceHitObjectBatch, notesToAdd)
    }
    actions.PerformBatch(editorActions)
    actions.SetHitObjectSelection(notesToAdd)
end
-- Creates a new window that lets you move notes
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function makeNoteMoverWindow(globalVars)
    if not globalVars.showNoteMover then return end
    initializeNextWindowNotCollapsed("noteMoverCollapsed")
    imgui.Begin("NoteMover", imgui_window_flags.AlwaysAutoResize)
    imgui.PushItemWidth(100)
    local menuVars = {
        msToMove = 1
    }
    getVariables("NoteMover", menuVars)
    _, menuVars.msToMove = imgui.InputInt("ms", menuVars.msToMove, 1, 1)
    makeNoteMoverButton(menuVars.msToMove)
    saveVariables("NoteMover", menuVars)
    imgui.End()
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
-- Resets frameTimes for the animate menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current SV menu [Table]
function resetFrameTimes(globalVars, menuVars)
    menuVars.frameTimes = {}
    menuVars.laneCounts = zerosList(map.GetKeyCount())
    menuVars.selectedTimeIndex = 1
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
-- Updates scale stats for SV graphs
-- Parameters
--    graphStats : list of graph scale numbers [Table]
--    svMultipliers : list of SV multipliers[Table]
--    svDistances : list of SV distances [Table]
function updateGraphStats(graphStats, svMultipliers, svDistances)
    graphStats.minScale, graphStats.maxScale = calculatePlotScale(svMultipliers)
    graphStats.distMinScale, graphStats.distMaxScale = calculatePlotScale(svDistances)
end
-- Updates SVs and SV info stored in the menu
-- Parameters
--    currentSVType : current type of SV being updated [String]
--    menuVars      : list of variables used for the place SV menu [Table]
--    settingVars   : list of variables used for the current SV menu [Table]
function updateMenuSVs(currentSVType, menuVars, settingVars)
    local interlaceMultiplier = nil
    if menuVars.interlace then interlaceMultiplier = menuVars.interlaceRatio end
    menuVars.svMultipliers = generateSVMultipliers(currentSVType, settingVars, interlaceMultiplier)
    local svMultipliersNoEndSV = makeDuplicateList(menuVars.svMultipliers)
    table.remove(svMultipliersNoEndSV)
    menuVars.svDistances = calculateDistanceVsTime(svMultipliersNoEndSV)
    
    updateFinalSV(settingVars.finalSVIndex, menuVars.svMultipliers, settingVars.customSV)
    updateSVStats(menuVars.svGraphStats, menuVars.svStats, menuVars.svMultipliers,
                  svMultipliersNoEndSV, menuVars.svDistances)
end
-- Updates SVs and SV info stored in the stutter menu
-- Parameters
--    menuVars : list of variables used for the current SV menu [Table]
function updateStutterMenuSVs(menuVars)
    menuVars.svMultipliers = generateSVMultipliers("Stutter1", menuVars, nil)
    local svMultipliersNoEndSV = makeDuplicateList(menuVars.svMultipliers)
    table.remove(svMultipliersNoEndSV)
    
    menuVars.svMultipliers2 = generateSVMultipliers("Stutter2", menuVars, nil)
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
    updateGraphStats(menuVars.svGraphStats, menuVars.svMultipliers, menuVars.svDistances)
    updateGraphStats(menuVars.svGraph2Stats, menuVars.svMultipliers2, menuVars.svDistances2)
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
-- Returns the set of selected offsets to be used for SV stuff [Table]
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
-- Returns a list of SVs between two offsets/times [Table]
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
-- Creates a list of all zeros
-- Returns the list of all zeros [Table]
-- Parameters
--    numZeros : number of zeros for the list [Int/Float]
function zerosList(numZeros)
    local list = {}
    for i = 1, numZeros do
        table.insert(list, 0)
    end
    return list
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
    if stillType == "End" or stillType == "Bara" then
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
    if valuesAverage == 0 then return end
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
-- Returns the result of the bezier evaluation [Int/Float]
-- Parameters
--    p2 : second coordinate of the actual cubic bezier, first for the SV plugin input [Int/Float]
--    p3 : third coordinate of the actual cubic bezier, second for the SV plugin input [Int/Float]
--    t  : time to evaluate the cubic bezier at [Int/Float]
function simplifiedOneDimensionalBezier(p2, p3, t)
    -- this simplified 1-D cubic bezier has points (0, p2, p3, 1) rather than (p1, p2, p3, p4)
    -- this plugin evaluates those points for both x and y: (0, x1, x2, 1), (0, y1, y2, 1)
    return 3*t*(1-t)^2*p2 + 3*t^2*(1-t)*p3 + t^3
end
-- Evaluates a simplified one-dimensional hermite related (?) spline for SV purposes
-- Returns the result of the hermite evaluation [Int/Float]
-- Parameters
--    m1 : slope at first point [Int/Float]
--    m2 : slope at second point [Int/Float]
--    y2 : y coordinate of second point [Int/Float]
--    t  : time to evaluate the hermite spline at [Int/Float]
function simplifiedOneDimensionalHermite(m1, m2, y2, t)
    local a = m1 + m2 - 2 * y2
    local b = 3 * y2 - 2 * m1 - m2
    local c = m1
    return a * t^3 + b * t^2 + c * t 
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
    elseif actionName == "Begin animation" then    
        minimumNotes = 1
        actionThing = "at"
        onlyStartOffset = true
    elseif actionName == "Swap note" then
        actionThing = "at"
    end
    
    chooseStartEndOffsets(globalVars, onlyStartOffset)
    local enoughSelectedNotes = checkEnoughSelectedNotes(minimumNotes)
    local needToSelectNotes = not (globalVars.useManualOffsets or enoughSelectedNotes)
    if needToSelectNotes then imgui.Text("Select "..minimumNotes.." or more notes") return end
    
    local actionItem = "selected notes"
    if minimumNotes == 1 then actionItem = "selected note(s)" end
    if globalVars.useManualOffsets then actionItem = "offsets" end
    local buttonText = actionName.." SVs "..actionThing.." "..actionItem
    button(buttonText, ACTION_BUTTON_SIZE, actionfunc, globalVars, menuVars)
    toolTip("You can also press ' T ' on your keyboard to do the same thing as this button")
    ifKeyPressedThenExecute(keys.T, actionfunc, globalVars, menuVars)
end
-- Checks to see if enough notes are selected
-- Returns whether or not there are enough notes [Boolean]
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

-- Lets you choose the arc percent
-- Returns whether or not the percent changed [Boolean]
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
    local comboIndex = globalVars.colorThemeIndex - 1
    _, comboIndex = imgui.Combo("Color Theme", comboIndex, COLOR_THEMES, #COLOR_THEMES)
    globalVars.colorThemeIndex = comboIndex + 1
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
-- Lets you choose whether or not to control the second SV
-- Returns whether or not the choice changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseControlSecondSV(menuVars)
    local oldChoice = menuVars.controlLastSV
    local newChoice
    local comboIndex = 0
    if oldChoice then comboIndex = 1 end
    _, comboIndex = imgui.Combo("Control SV", comboIndex, STUTTER_CONTROLS, #STUTTER_CONTROLS)
    if comboIndex == 1 then newChoice = true else newChoice = false end
    menuVars.controlLastSV = newChoice
    local choiceChanged = oldChoice ~= newChoice
    if choiceChanged then menuVars.stutterDuration = 100 - menuVars.stutterDuration end
    return choiceChanged
end
-- Lets you choose the current frame
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseCurrentFrame(menuVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Previewing current frame:")
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(35)
    imgui.PushButtonRepeat(true)
    if imgui.ArrowButton("##leftFrame", imgui_dir.Left) then
        menuVars.currentFrame = menuVars.currentFrame - 1
    end
    imgui.SameLine(0, SAMELINE_SPACING)
    _, menuVars.currentFrame = imgui.InputInt("##currentFrame", menuVars.currentFrame, 0, 0)
    imgui.SameLine(0, SAMELINE_SPACING)
    if imgui.ArrowButton("##rightFrame", imgui_dir.Right) then
        menuVars.currentFrame = menuVars.currentFrame + 1
    end
    imgui.PopButtonRepeat()
    menuVars.currentFrame = wrapToInterval(menuVars.currentFrame, 1, menuVars.numFrames)
    imgui.PopItemWidth()
end
-- Lets you choose the cursor effect option
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseCursorEffect(globalVars)
    local comboIndex = globalVars.cursorEffectIndex - 1
    _, comboIndex = imgui.Combo("Cursor Effect", comboIndex, CURSOR_EFFECTS_OPTIONS,
                                #CURSOR_EFFECTS_OPTIONS)
    globalVars.cursorEffectIndex = comboIndex + 1
end
-- Lets you choose a c
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
    newSharpness = clampToInterval(newSharpness, 1, 100)
    settingVars.curveSharpness = newSharpness
    imgui.PopItemWidth()
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
-- Lets you choose the distance back for splitscroll
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseDistanceBack(menuVars)
    _, menuVars.distanceBack = imgui.InputFloat("Split Distance", menuVars.distanceBack,
                                                0, 0, "%.3f msx")
    helpMarker("Splitscroll distance to separate the two scrolls planes\n(1,000,000 = default)")
end
-- Lets you choose whether or not to draw a capybara on screen
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseDrawCapybara(globalVars)
    _, globalVars.drawCapybara = imgui.Checkbox("Capybara", globalVars.drawCapybara)
    helpMarker("Draws a capybara on bottom right screen")
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
    local svTool = EDIT_SV_TOOLS[globalVars.editToolIndex]
    if svTool == "Add Teleport"     then toolTip("Add a large teleport SV to move far away") end
    if svTool == "Copy & Paste"     then toolTip("Copy SVs and paste them somewhere else") end
    if svTool == "Displace Note"    then toolTip("Move where notes are hit on the screen") end
    if svTool == "Displace View"    then toolTip("Temporarily displace the playfield view") end
    if svTool == "Fix LN Ends"      then toolTip("Fix flipped LN ends") end 
    if svTool == "Flicker"          then toolTip("Flash notes on and off the screen") end
    if svTool == "Measure"          then toolTip("Get info/stats about SVs in a section") end
    if svTool == "Merge"            then toolTip("Combine SVs that overlap") end
    if svTool == "Reverse Scroll"   then toolTip("Reverse SV scroll direction (IRREVERSABLE)") end
    if svTool == "Scale (Multiply)" then toolTip("Scale SV values to change note spacing") end
    if svTool == "Scale (Displace)" then toolTip("Scale SV values to change note spacing") end
    if svTool == "Swap Notes"       then toolTip("Swap positions of notes using SVs") end
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
    local comboIndex = oldIndex - 1
    _, comboIndex = imgui.Combo("Final SV", comboIndex, FINAL_SV_TYPES, #FINAL_SV_TYPES)
    if finalSVType ~= "Custom" then
        imgui.Unindent(DEFAULT_WIDGET_WIDTH * 0.35 + 24)
    end
    settingVars.finalSVIndex = comboIndex + 1
    imgui.PopItemWidth()
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
-- Lets you choose the interlace
-- Returns whether or not the interlace settings changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseInterlace(menuVars)
    local oldInterlace = menuVars.interlace
    _, menuVars.interlace = imgui.Checkbox("Interlace", menuVars.interlace)
    if not menuVars.interlace then return oldInterlace ~= menuVars.interlace end
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.5)
    local oldRatio = menuVars.interlaceRatio
    _, menuVars.interlaceRatio = imgui.InputFloat("Ratio##interlace", menuVars.interlaceRatio,
                                                  0, 0, "%.2f")
    imgui.PopItemWidth()
    return oldInterlace ~= menuVars.interlace or oldRatio ~= menuVars.interlaceRatio
end
-- Lets you choose the main SV multiplier of a teleport stutter
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseMainSV(menuVars)
    local text = "Main SV"
    if menuVars.linearlyChange then text = text.." (start)" end
    _, menuVars.mainSV = imgui.InputFloat(text, menuVars.mainSV, 0, 0, "%.2fx")
    if not menuVars.linearlyChange then 
        helpMarker("This SV will last ~99.99%% of the stutter") return
    end
   _, menuVars.mainSV2 = imgui.InputFloat("Main SV (end)", menuVars.mainSV2, 0, 0, "%.2fx")
end
-- Lets you choose the mspf (milliseconds per frame) for splitscroll
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseMSPF(menuVars)
    local _, newMSPF = imgui.InputFloat("ms Per Frame", menuVars.msPerFrame, 0.5, 0.5, "%.1f")
    newMSPF = forceHalf(newMSPF)
    newMSPF = clampToInterval(newMSPF, 4, 1000)
    menuVars.msPerFrame = newMSPF
    helpMarker("Number of milliseconds splitscroll will display a set of SVs before jumping to "..
               "the next set of SVs")
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
-- Lets you choose the distance between frames
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseFrameDistance(menuVars)
    _, menuVars.frameDistance = imgui.InputFloat("Distance", menuVars.frameDistance, 0, 0,
                                                 "%.0f msx")
    helpMarker("Distance between each consecutive frame")
    menuVars.frameDistance = clampToInterval(menuVars.frameDistance, 1000, 100000)
end
-- Lets you choose the numbers/data for a frameTime
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseFrameTimeData(menuVars)
    if #menuVars.frameTimes == 0 then return end
    local frameTime = menuVars.frameTimes[menuVars.selectedTimeIndex]
    _, frameTime.frame = imgui.InputInt("Frame #", frameTime.frame)
    frameTime.frame = clampToInterval(frameTime.frame, 1, menuVars.numFrames)
    _, frameTime.position = imgui.InputInt("Note height", frameTime.position)
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
-- Lets you choose the way to get note data for note animation
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseNoteAnimationData(menuVars)
    local comboIndex = menuVars.addNoteDataIndex - 1
    _, comboIndex = imgui.Combo("Notes/Frames", comboIndex, ANIMATION_OPTIONS, #ANIMATION_OPTIONS)
    menuVars.addNoteDataIndex = comboIndex + 1
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
-- Lets you choose the number of flickers
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseNumFlickers(menuVars)
    _, menuVars.numFlickers = imgui.InputInt("Flickers", menuVars.numFlickers, 1, 1)
    menuVars.numFlickers = clampToInterval(menuVars.numFlickers, 1, 100)
end
-- Lets you choose the number of frames
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseNumFrames(menuVars)
    _, menuVars.numFrames = imgui.InputInt("Total # Frames", menuVars.numFrames)
    menuVars.numFrames = clampToInterval(menuVars.numFrames, 1, MAX_ANIMATION_FRAMES)
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
    _, globalVars.rgbPaused = imgui.Checkbox("Pause RGB color changing", globalVars.rgbPaused)
    helpMarker("If you have a RGB color theme selected, stops the colors from cycling/changing")
end
-- Lets you choose whether or not to show the note mover window
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseShowNoteMover(globalVars)
    _, globalVars.showNoteMover = imgui.Checkbox("Show note mover window", globalVars.showNoteMover)
    helpMarker("For splitscroll and animate, note mover helps separate chord notes. "..
               "This is useful if notes are at the same time but need to be at different places")
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
        local _, newValue = imgui.InputFloat("SV Value", oldValue, 0, 0, "%.2fx")
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
    local text = "Start SV %"
    if menuVars.linearlyChange then text = text.." (start)" end
    _, menuVars.svPercent = imgui.InputFloat(text, menuVars.svPercent, 1, 1, "%.2f%%")
    if not menuVars.linearlyChange then helpMarker("%% distance between notes") return end
    _, menuVars.svPercent2 = imgui.InputFloat("Start SV % (end)", menuVars.svPercent2, 1, 1,
                                              "%.2f%%")
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
        imgui.PopItemWidth()
    end
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * 0.4)
    local comboIndex = menuVars.stillTypeIndex - 1
    _, comboIndex = imgui.Combo("Displacement", comboIndex, STILL_TYPES, #STILL_TYPES)
    menuVars.stillTypeIndex = comboIndex + 1
    
    if stillType == "No"    then toolTip("Don't use an initial or end displacement") end
    if stillType == "Start" then toolTip("Use an initial starting displacement for the still") end
    if stillType == "End"   then toolTip("Have a displacement to end at for the still") end
    if stillType == "Auto"  then toolTip("Use last displacement of a previous still to start") end
    if stillType == "Capy"  then toolTip("Keeps original note displacements with new start") end
    if stillType == "Bara"  then toolTip("Keeps original note displacements with new end") end
    
    if dontChooseDistance then
        imgui.Unindent(indentWidth)
    end
    imgui.PopItemWidth()
end
-- Lets you choose the duration of the first stutter SV
-- Returns whether or not the duration changed [Boolean]
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseStutterDuration(menuVars)
    local oldDuration = menuVars.stutterDuration
    if menuVars.controlLastSV then oldDuration = 100 - oldDuration end
    local _, newDuration = imgui.SliderInt("Duration", oldDuration, 1, 99, oldDuration.."%%")
    newDuration = clampToInterval(newDuration, 1, 99)
    local durationChanged = oldDuration ~= newDuration
    if menuVars.controlLastSV then newDuration = 100 - newDuration end
    menuVars.stutterDuration = newDuration
    return durationChanged
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
-- Lets you choose the style theme of the plugin
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseStyleTheme(globalVars)
    local comboIndex = globalVars.styleThemeIndex - 1
    _, comboIndex = imgui.Combo("Style Theme", comboIndex, STYLE_THEMES, #STYLE_THEMES)
    globalVars.styleThemeIndex = comboIndex + 1
end
-- Lets you choose the behavior of SVs
-- Returns whether or not the behavior changed [Boolean]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseSVBehavior(settingVars)
    local oldBehaviorIndex = settingVars.behaviorIndex
    local comboIndex = settingVars.behaviorIndex - 1
    _, comboIndex = imgui.Combo("Behavior", comboIndex, SV_BEHAVIORS, #SV_BEHAVIORS)
    settingVars.behaviorIndex = comboIndex + 1
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
-- Lets you choose how to scale SVs when multiplying
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseSVScale(menuVars)
    local comboIndex =  menuVars.scaleTypeIndex - 1
    _, comboIndex = imgui.Combo("Scale Type", comboIndex, SCALE_TYPES, #SCALE_TYPES)
    menuVars.scaleTypeIndex = comboIndex + 1
    local scaleType = SCALE_TYPES[menuVars.scaleTypeIndex]
    if scaleType == "Average SV"        then chooseAverageSV(menuVars) end
    if scaleType == "Start/End Ratio"   then chooseStartEndSVs(menuVars) end
    if scaleType == "Absolute Distance" then chooseDistance(menuVars) end
    if scaleType == "Relative Ratio"    then chooseRatio(menuVars) end
end
-- Lets you choose how to scale SVs when displacing
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseSVScaleDisplace(menuVars)
    local comboIndex =  menuVars.scaleTypeIndex - 1
    _, comboIndex = imgui.Combo("Displace Metric", comboIndex, DISPLACE_SCALE_TYPES,
                                #DISPLACE_SCALE_TYPES)
    menuVars.scaleTypeIndex = comboIndex + 1
    local scaleType = DISPLACE_SCALE_TYPES[menuVars.scaleTypeIndex]
    if scaleType == "Average SV"        then chooseAverageSV(menuVars) end
    if scaleType == "Absolute Distance" then chooseDistance(menuVars) end
end
-- Lets you choose the spot to displace when adding scaling SVs
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseSVScaleDisplaceSpot(menuVars)
    local comboIndex =  menuVars.scaleSpotIndex - 1
    _, comboIndex = imgui.Combo("Displace Spot", comboIndex, DISPLACE_SCALE_SPOTS,
                                #DISPLACE_SCALE_SPOTS)
    menuVars.scaleSpotIndex = comboIndex + 1
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
-- Lets you choose whether to use distance or not
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
--    svType              : type of SV to generate [String]
--    settingVars         : list of variables used for the current menu [Table]
--    interlaceMultiplier : interlace multiplier
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
        local randomType = RANDOM_TYPES[settingVars.randomTypeIndex]
        multipliers = generateRandomSet(settingVars.avgSV, settingVars.svPoints + 1, randomType,
                                        settingVars.randomScale)
    elseif svType == "Custom" then
        multipliers = generateCustomSet(settingVars.svMultipliers)
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
        if settingVars.avgSV then
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
    for i = 1, numValues - 1 do
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
-- Returns a set of bezier values [Table]
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
        yCoords[i] = simplifiedOneDimensionalHermite(startValue, endValue, avgValue, xCoords[i])
    end
    local hermiteSet = {}
    for i = 1, #yCoords - 1 do
        local startY = yCoords[i]
        local endY = yCoords[i + 1]
        hermiteSet[i] = (endY - startY) * (numValues - 1)
    end
    --  normalizeValues(hermiteSet, avgValue, false)
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
-- Returns a set of sinusoidal values [Table]
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
    if not increaseValues then circularSet = getReverseTable(circularSet) end
    if not dontNormalize then normalizeValues(circularSet, avgValue, true) end
    for i = 1, #circularSet do
        circularSet[i] = circularSet[i] + verticalShift
    end
    table.insert(circularSet, avgValue)
    return circularSet
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
--    stutterValue     : value of the stutter [Int/Float]
--    stutterDuration  : duration of the stutter (out of 100) [Int]
--    avgValue         : average value [Int/Float]
--    controlLastValue : whether or not the provided SV is the second SV
function generateStutterSet(stutterValue, stutterDuration, avgValue, controlLastValue)
    local durationPercent = stutterDuration / 100
    if controlLastValue then durationPercent = 1 - durationPercent end
    local otherValue = (avgValue - stutterValue * durationPercent) / (1 - durationPercent)
    local stutterSet = {stutterValue, otherValue, avgValue}
    if controlLastValue then stutterSet = {otherValue, stutterValue, avgValue} end
    return stutterSet
end

------------------------------------------------------------------------------------- Acting on SVs

-- Gets removable SVs
-- Parameters
--    svsToRemove   : list of SVs to remove [Table]
--    svTimeIsAdded : list of SVs times added [Table]
--    startOffset   : starting offset to remove after [Int]
--    endOffset     : end offset to remove before [Int]
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
                                                     menuVars.stutterDuration, menuVars.avgSV,
                                                     menuVars.controlLastSV)
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
    local svPercent = menuVars.svPercent / 100
    local lastSVPercent = svPercent
    local lastMainSV = menuVars.mainSV
    if menuVars.linearlyChange then 
        lastSVPercent = menuVars.svPercent2 / 100
        lastMainSV = menuVars.mainSV2
    end
    local svPercents = generateLinearSet(svPercent, lastSVPercent, #offsets - 1)
    local mainSVs = generateLinearSet(menuVars.mainSV, lastMainSV, #offsets - 1)
    for i = 1, #offsets - 1 do
        local thisMainSV = mainSVs[i]
        local startOffset = offsets[i]
        local endOffset = offsets[i + 1]
        local offsetInterval = endOffset - startOffset
        local startMultiplier = getUsableOffsetMultiplier(startOffset)
        local startDuration = 1 / startMultiplier
        local endMultiplier = getUsableOffsetMultiplier(endOffset)
        local endDuration = 1 / endMultiplier

        local startDistance = menuVars.distance
        if not menuVars.useDistance then startDistance = offsetInterval * svPercents[i] end
        local expectedDistance = offsetInterval * menuVars.avgSV
        local traveledDistance = offsetInterval * thisMainSV
        local endDistance = expectedDistance - startDistance - traveledDistance
        local sv1 = thisMainSV + startDistance * startMultiplier
        local sv2 = thisMainSV
        local sv3 = thisMainSV + endDistance * endMultiplier
        table.insert(svsToAdd, utils.CreateScrollVelocity(startOffset, sv1))
        if sv2 ~= sv1 then
            table.insert(svsToAdd, utils.CreateScrollVelocity(startOffset + startDuration, sv2))
        end
        table.insert(svsToAdd, utils.CreateScrollVelocity(endOffset - endDuration, sv3))
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
    if placingStillSVs then
        offsets = {firstOffset, lastOffset}
        for i = 1, #offsets do
            local currentOffset = offsets[i]
            local multiplier = getUsableOffsetMultiplier(currentOffset)
            local duration = 1 / multiplier
            local timeBefore = currentOffset - duration
            local timeAt = currentOffset
            local svMultiplierBefore = getSVMultiplierAt(timeBefore)
            local svMultiplierAt = getSVMultiplierAt(timeAt)
            menuVars.prePlaceDistances[i] = {svMultiplierBefore, svMultiplierAt}
        end
    end
      
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
    local capybaraStill = stillType == "Capy" or stillType == "Bara" 
    local noteSpacing = menuVars.noteSpacing
    if capybaraStill then
        noteSpacing = 0
    end
    local noteOffsets = uniqueNoteOffsets(firstOffset, lastOffset)
    local svsToAdd = {}
    local svsToRemove = {}
    local svTimeIsAdded = {}
    local svsBetweenOffsets = getSVsBetweenOffsets(firstOffset, lastOffset)
    local svDisplacements = calculateDisplacementsFromSVs(svsBetweenOffsets, noteOffsets)
    local nsvDisplacements = calculateDisplacementsFromNotes(noteOffsets, noteSpacing)
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
            if capybaraStill then
                newMultiplierAt = newMultiplierAt + menuVars.prePlaceDistances[i][2]
            end
            local newMultiplierAfter = svMultiplierAfter
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, newMultiplierAt))
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, newMultiplierAfter))
        end
        if i ~= 1 then
            local timeBefore = noteOffset - duration
            svTimeIsAdded[timeBefore] = true
            local svMultiplierBefore = getSVMultiplierAt(timeBefore)
            local newMultiplierBefore = finalDisplacements[i] * multiplier + svMultiplierBefore
            if capybaraStill then
                newMultiplierBefore = newMultiplierBefore + menuVars.prePlaceDistances[i][1]
            end
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
    local scrollDifference = scrollSpeed1 - scrollSpeed2
    local millisecondsPerFrame = menuVars.msPerFrame
    local numFrames = math.floor((totalTime - 1) / millisecondsPerFrame)
    local noteIndex = 2
    local goingFrom1To2 = false
    local currentScrollSpeed = scrollSpeed2
    local nextScrollSpeed = scrollSpeed1
    for i = 0, (numFrames + 1) do
        local timePassed = i * millisecondsPerFrame
        if i == numFrames + 1 then timePassed = totalTime end
        local tpDistance = initialDistance + timePassed * scrollDifference
        if i == 0 then tpDistance = 0 end
        local timeAt = firstOffset + timePassed
        local multiplier = getUsableOffsetMultiplier(timeAt)
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
    
    local placeBehavior = PLACE_BEHAVIORS[globalVars.placeBehaviorIndex]
    if placeBehavior == "Replace old SVs" then
        svsToRemove = getSVsBetweenOffsets(firstOffset, lastOffset)
    end
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Places advanced split scroll SVs 
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function placeAdvancedSplitScrollSVs(globalVars, menuVars)
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
    local initialDistance = menuVars.distanceBack
    local millisecondsPerFrame = menuVars.msPerFrame
    local numFrames = math.floor((totalTime - 1) / millisecondsPerFrame)
    local noteIndex = 2
    local sv1Index = 1
    local sv2Index = 1
    local svsIn1 = getSVsBetweenOffsets(firstOffset, lastOffset)
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
        local timePassed = i * millisecondsPerFrame
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
        local multiplier = getUsableOffsetMultiplier(timeAt)
        local duration = 1 / multiplier
        local timeBefore = timeAt - duration
        local timeAfter = timeAt + duration
        local noteOffset = noteOffsets[noteIndex]
        while noteOffset < timeAt do
            local noteInOtherScroll = (isNoteOffsetFor2nd[noteOffset] and goingFrom1To2) or
                                      (not isNoteOffsetFor2nd[noteOffset] and not goingFrom1To2)
            local noteMultiplier = getUsableOffsetMultiplier(noteOffset)
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
    local placeBehavior = PLACE_BEHAVIORS[globalVars.placeBehaviorIndex]
    if placeBehavior == "Replace old SVs" then
        svsToRemove = getSVsBetweenOffsets(firstOffset, lastOffset)
    end
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Places animation SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function placeAnimationSVs(globalVars, menuVars)
    local svsToAdd = {}
    local svsToRemove = {}
    local distanceFromStartToEnd = menuVars.numFrames * menuVars.frameDistance
    local startAnimationOffset = globalVars.startOffset
    if not globalVars.useManualOffsets then
        startAnimationOffset = uniqueSelectedNoteOffsets()[1]
    end
    local frameTime1 = menuVars.frameTimes[1]
    local firstOffset = frameTime1.time
    local lastOffset = menuVars.frameTimes[#menuVars.frameTimes].time
    if startAnimationOffset >= firstOffset then return end
    
    local firstDistance = (frameTime1.frame - 1) * menuVars.frameDistance + frameTime1.position
    local startMultiplier = getUsableOffsetMultiplier(startAnimationOffset)
    local startDuration = 1 / startMultiplier
    local startMultiplier2 =  getUsableOffsetMultiplier(firstOffset)
    local startDuration2 = 1 / startMultiplier2
    local firstSV = (distanceFromStartToEnd + menuVars.frameDistance) * startMultiplier
    local secondSV = (firstDistance - distanceFromStartToEnd) * startMultiplier2
    table.insert(svsToAdd, utils.CreateScrollVelocity(startAnimationOffset, firstSV))
    table.insert(svsToAdd, utils.CreateScrollVelocity(startAnimationOffset + startDuration, 0))
    table.insert(svsToAdd, utils.CreateScrollVelocity(firstOffset - startDuration2, secondSV))
    
    for i = 2, #menuVars.frameTimes do
        local lastFrameTime = menuVars.frameTimes[i - 1]
        local lastTime = lastFrameTime.time
        local lastFrame = lastFrameTime.frame
        local lastPosition = lastFrameTime.position
        local distanceFromStartFrame = (lastFrame - 1) * menuVars.frameDistance + lastPosition
        local toEndDifference = distanceFromStartToEnd - distanceFromStartFrame
        
        local nextFrameTime = menuVars.frameTimes[i]
        local nextTime = nextFrameTime.time
        local nextFrame = nextFrameTime.frame
        local nextPosition = nextFrameTime.position
        local keyframeDifference = nextFrame - lastFrame
        local positionDifference = nextPosition - lastPosition
        local toNextDifference = keyframeDifference * menuVars.frameDistance + positionDifference
        
        local lastMultiplier = getUsableOffsetMultiplier(lastTime)
        local lastDuration = 1 / lastMultiplier
        local nextMultiplier = getUsableOffsetMultiplier(nextTime)
        local nextDuration = 1 / nextMultiplier
        
        local sv1 = toEndDifference * lastMultiplier
        local sv2 = 0
        local sv3 = (toNextDifference - toEndDifference) * nextMultiplier
        table.insert(svsToAdd, utils.CreateScrollVelocity(lastTime, sv1))
        table.insert(svsToAdd, utils.CreateScrollVelocity(lastTime + lastDuration, sv2))
        table.insert(svsToAdd, utils.CreateScrollVelocity(nextTime - nextDuration, sv3))
        if i == #menuVars.frameTimes then
            table.insert(svsToAdd, utils.CreateScrollVelocity(nextTime, -sv3))
            table.insert(svsToAdd, utils.CreateScrollVelocity(nextTime + nextDuration, 1))
        end
    end

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
-- Reverses the scroll of current SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function editReverseScrollSVs(globalVars, menuVars)
    local svsToAdd1 = {}
    local svsToAdd2 = {}
    local svsToRemove1 = {}
    local svsToRemove2 = {}
    local svTimeIsAdded = {}
    local selectedOffsets = {globalVars.startOffset, globalVars.endOffset}
    if not globalVars.useManualOffsets then
        selectedOffsets = uniqueSelectedNoteOffsets()
    end
    local offsets = uniqueNoteOffsets(selectedOffsets[1], selectedOffsets[#selectedOffsets])
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local svs = getSVsBetweenOffsets(startOffset, endOffset)
    for _, sv in pairs(svs) do
        table.insert(svsToRemove1, sv)
    end
    if #svs == 0 or svs[1].StartTime ~= startOffset then
        local multiplierAtStartOffset = getSVMultiplierAt(startOffset)
        table.insert(svs, 1, utils.CreateScrollVelocity(startOffset, multiplierAtStartOffset))
    end
    local distanceTraveled = calculateDisplacementFromSVs(svs, endOffset)
    local msxSeparatingDistance = 10000
    local noteDisplacement = menuVars.distance
    local teleportDistance = msxSeparatingDistance + distanceTraveled
    for _, sv in pairs(svs) do
        table.insert(svsToAdd1, utils.CreateScrollVelocity(sv.StartTime, -sv.Multiplier))
    end
    removeAndAddSVs(svsToRemove1, svsToAdd1)
    for i = 1, #offsets do
        local noteOffset = offsets[i]
        local multiplier = getUsableOffsetMultiplier(noteOffset)
        local duration = 1 / multiplier
        local timeBefore = noteOffset - duration
        local timeAt = noteOffset
        local timeAfter = noteOffset + duration
        local svMultiplierBefore = getSVMultiplierAt(timeBefore)
        local svMultiplierAt = getSVMultiplierAt(timeAt)
        local svMultiplierAfter = getSVMultiplierAt(timeAfter)
        if i == 1 then
            svTimeIsAdded[timeAt] = true
            svTimeIsAdded[timeAfter] = true
            local newMultiplierAt = teleportDistance * multiplier + svMultiplierAt
            local newMultiplierAfter = svMultiplierAfter
            table.insert(svsToAdd2, utils.CreateScrollVelocity(timeAt, newMultiplierAt))
            table.insert(svsToAdd2, utils.CreateScrollVelocity(timeAfter, newMultiplierAfter))
        elseif i == #offsets then
            svTimeIsAdded[timeBefore] = true
            svTimeIsAdded[timeAt] = true
            svTimeIsAdded[timeAfter] = true
            local newMultiplierBefore = noteDisplacement * multiplier + svMultiplierBefore
            local newMultiplierAt = (teleportDistance - noteDisplacement) * multiplier + svMultiplierAt
            local newMultiplierAfter = svMultiplierAfter
            if svMultiplierAfter ~= 1 then newMultiplierAfter = 1 end
            table.insert(svsToAdd2, utils.CreateScrollVelocity(timeBefore, newMultiplierBefore))
            table.insert(svsToAdd2, utils.CreateScrollVelocity(timeAt, newMultiplierAt))
            table.insert(svsToAdd2, utils.CreateScrollVelocity(timeAfter, newMultiplierAfter))
        else
            svTimeIsAdded[timeBefore] = true
            svTimeIsAdded[timeAt] = true
            svTimeIsAdded[timeAfter] = true
            local newMultiplierBefore = noteDisplacement * multiplier + svMultiplierBefore
            local newMultiplierAt = -noteDisplacement * multiplier + svMultiplierAt
            local newMultiplierAfter = svMultiplierAfter
            table.insert(svsToAdd2, utils.CreateScrollVelocity(timeBefore, newMultiplierBefore))
            table.insert(svsToAdd2, utils.CreateScrollVelocity(timeAt, newMultiplierAt))
            table.insert(svsToAdd2, utils.CreateScrollVelocity(timeAfter, newMultiplierAfter))
        end
    end
    getRemovableSVs(svsToRemove2, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove2, svsToAdd2)
end
-- Scales SVs by adding displacing SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function scaleDisplaceSVs(globalVars, menuVars)
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
    local isStartDisplace = DISPLACE_SCALE_SPOTS[menuVars.scaleSpotIndex] == "Start"
    
    for i = 1, #offsets - 1 do
        local note1Offset = offsets[i]
        local note2Offset = offsets[i + 1]
        local multiplier = getUsableOffsetMultiplier(note2Offset)
        local duration = 1 / multiplier
        local timeAt1 = note1Offset
        local timeAfter1 = note1Offset + duration
        local timeBefore2 = note2Offset - duration
        local timeAt2 = note2Offset
        if isStartDisplace then
            svTimeIsAdded[timeAt1] = true
            svTimeIsAdded[timeAfter1] = true
        else
            svTimeIsAdded[timeBefore2] = true
            svTimeIsAdded[timeAt2] = true
        end
        local svMultiplierAt1 = getSVMultiplierAt(timeAt1)
        local svMultiplierAfter1 = getSVMultiplierAt(timeAfter1)
        local svMultiplierBefore2 = getSVMultiplierAt(timeBefore2)
        local svMultiplierAt2 = getSVMultiplierAt(timeAt2)
        
        local svs = getSVsBetweenOffsets(note1Offset, note2Offset)
        if #svs == 0 or svs[1].StartTime ~= note1Offset then
            local multiplierAtStartOffset = getSVMultiplierAt(note1Offset)
            table.insert(svs, 1, utils.CreateScrollVelocity(note1Offset, multiplierAtStartOffset))
        end
        local scaleType = DISPLACE_SCALE_TYPES[menuVars.scaleTypeIndex]
        local scalingDistance
        if scaleType == "Average SV" then
            local svAverage = calculateAvgSV(svs, note2Offset)
            scalingDistance = (svAverage - menuVars.avgSV) * (note1Offset - note2Offset)
        elseif scaleType == "Absolute Distance" then
            local distanceTraveled = calculateDisplacementFromSVs(svs, note2Offset)
            scalingDistance = menuVars.distance - distanceTraveled
        end
        
        if isStartDisplace then
            local newMultiplierAt = scalingDistance * multiplier + svMultiplierAt1
            local newMultiplierAfter = svMultiplierAfter1
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt1, newMultiplierAt))
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter1, newMultiplierAfter))
        else
            local newMultiplierBefore = scalingDistance * multiplier + svMultiplierBefore2
            local newMultiplierAt = svMultiplierAt2
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeBefore2, newMultiplierBefore))
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt2, newMultiplierAt))
        end
    end
    local sv = map.GetScrollVelocityAt(endOffset) 
    local svExistsAtEndOffset = sv and (sv.StartTime == endOffset)
    if not svExistsAtEndOffset then
        table.insert(svsToAdd, utils.CreateScrollVelocity(endOffset, getSVMultiplierAt(endOffset)))
    end
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Scales SVs by multiplying
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function scaleMultiplySVs(globalVars, menuVars)
    editSVs(globalVars, menuVars, getSVsToScale, true)
end
-- Swap note positions with SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function swapNoteSVs(globalVars, menuVars)
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
    local svsBetweenOffsets = getSVsBetweenOffsets(startOffset, endOffset)
    if #svsBetweenOffsets == 0 or svsBetweenOffsets[1].StartTime ~= startOffset then
        local newStartSV = utils.CreateScrollVelocity(startOffset, getSVMultiplierAt(startOffset))
        table.insert(svsBetweenOffsets, 1, newStartSV)
    end
    local oldSVDisplacements = calculateDisplacementsFromSVs(svsBetweenOffsets, offsets)
    local newSVDisplacements = {}
    for i = 1, #oldSVDisplacements do
        local index = i + 1
        if i == #oldSVDisplacements then index = 1 end
        newSVDisplacements[i] = oldSVDisplacements[index] - oldSVDisplacements[i]
    end
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
        local newMultiplierBefore = newSVDisplacements[i] * multiplier
        local newMultiplierAt = -newSVDisplacements[i] * multiplier
        local newMultiplierAfter = svMultiplierAfter
        newMultiplierBefore = newMultiplierBefore + svMultiplierBefore
        newMultiplierAt = newMultiplierAt + svMultiplierAt
        table.insert(svsToAdd, utils.CreateScrollVelocity(timeBefore, newMultiplierBefore))
        table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, newMultiplierAt))
        table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, newMultiplierAfter))
    end
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
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
        table.insert(svsToAdd, utils.CreateScrollVelocity(endOffset, getSVMultiplierAt(endOffset)))
    end
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
end
-- Fixes flipped LN ends by adding specific SVs
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function fixFlippedLNEnds(globalVars, menuVars)
    local fixedLNEndsCount = 0
    local fixedLNEndTimes = {}
    local svsToRemove = {}
    local svsToAdd = {}
    local svTimeIsAdded = {}
    for _, hitObject in pairs(map.HitObjects) do
        local lnEndTime = hitObject.EndTime
        local isLN = lnEndTime ~= 0 
        local lnHasNegativeSV = (getSVMultiplierAt(lnEndTime) < 0)
        local hasntAlreadyBeenFixed = fixedLNEndTimes[lnEndTime] == nil
        if isLN and lnHasNegativeSV and hasntAlreadyBeenFixed then
            fixedLNEndTimes[lnEndTime] = true
            local multiplier = getUsableOffsetMultiplier(lnEndTime)
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
            local newMultiplierAfterAFter = svMultiplierAfterAfter
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAt, newMultiplierAt))
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfter, newMultiplierAfter))
            table.insert(svsToAdd, utils.CreateScrollVelocity(timeAfterAfter,
                                                              newMultiplierAfterAFter))
            fixedLNEndsCount = fixedLNEndsCount + 1
        end
    end
    local startOffset = map.HitObjects[1].StartTime
    local endOffset = map.HitObjects[#map.HitObjects].EndTime
    if endOffset == 0 then endOffset = map.HitObjects[#map.HitObjects].StartTime end
    getRemovableSVs(svsToRemove, svTimeIsAdded, startOffset, endOffset)
    removeAndAddSVs(svsToRemove, svsToAdd)
    menuVars.fixedLNEndsAmount = fixedLNEndsCount
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
        if scaleType == "Start/End Ratio" then
            local timeRatio = (sv.StartTime - startOffset) / (endOffset - startOffset)
            scalingFactor = menuVars.startSV * (1 - timeRatio) + menuVars.endSV * timeRatio
        end
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