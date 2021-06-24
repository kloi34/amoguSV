-- amoguSV v1 (24 June 2021)
-- by kloi34

-- Many SV tools and/or code snippets were stolen, so credit to those creators of the SV plugins:
--    iceSV       (by IceDynamix)         @ https://github.com/IceDynamix/iceSV
--    KeepStill   (by Illuminati-CRAZ)    @ https://github.com/Illuminati-CRAZ/KeepStill

---------------------------------------------------------------------------------------------------
-- Plugin Info
---------------------------------------------------------------------------------------------------

-- This is a mapping plugin for the ultimate community-driven, and open-source competitive rhythm
-- game Quaver. The plugin contains various tools for editing SVs (Slider Velocities) quickly and
-- efficiently. It's most similar to (i.e. 50% of SV features and code stolen from) iceSV.

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
    _, vars.startSV = imgui.DragFloat("", vars.startSV, 0.01, -1000, 1000, "%.2fx")
    imgui.SameLine(0, SAMELINE_SPACING + imgui.CalcTextSize(" ")[1])
    _, vars.endSV = imgui.DragFloat("Start/End SV", vars.endSV, 0.01, -1000, 1000, "%.2fx")
    if imgui.Button(" Swap End and Start ", {DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT}) then
        local temp = vars.startSV
        vars.startSV = vars.endSV
        vars.endSV = temp
    end
    imgui.PopItemWidth()
    spacing()
    
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    _, vars.svPoints = imgui.InputInt("SV points", vars.svPoints)
    vars.svPoints = mathClamp(vars.svPoints, 1, 1000)
    imgui.PopItemWidth()
    spacing()
    
    imgui.Text("Very last SV:")
    for i = 1, #END_SV_TYPES do
        _, vars.endSVOption = imgui.RadioButton(END_SV_TYPES[i], vars.endSVOption, i)
        if i ~= #END_SV_TYPES then
            imgui.SameLine(0, 3 * SAMELINE_SPACING)
        end
    end
    separator()
    
    _, vars.interlace = imgui.Checkbox("Interlace with different linear", vars.interlace)
    if vars.interlace then
        spacing()
        imgui.PushItemWidth(halfWidgetWidth - imgui.CalcTextSize(" ")[1] / 2)
        _, vars.interlaceStartSV = imgui.DragFloat(" ", vars.interlaceStartSV, 0.01, -1000, 1000,
                                                   "%.2fx")
        imgui.SameLine(0, 0)
        _, vars.interlaceEndSV = imgui.DragFloat(" Start/End SV ", vars.interlaceEndSV, 0.01,
                                                 -1000, 1000, "%.2fx")
        if imgui.Button("Swap End and Start", {DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT}) then
            local temp = vars.interlaceStartSV
            vars.interlaceStartSV = vars.interlaceEndSV
            vars.interlaceEndSV = temp
        end
        imgui.PopItemWidth()
        spacing()
    end
    separator()
    
    _, vars.addTeleport = imgui.Checkbox("Add teleport SV at start", vars.addTeleport)
    if vars.addTeleport then
        spacing()
        if imgui.RadioButton("Only at very start", vars.veryStartTeleport) then
            vars.veryStartTeleport = true
        end
        imgui.SameLine(0, 3 * SAMELINE_SPACING)
        if imgui.RadioButton("Every linear SV start", not vars.veryStartTeleport) then
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
        isExponential = false,
        svPoints = 16,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    if imgui.RadioButton("Exponential", vars.isExponential) then
        vars.isExponential = true
    end
    if imgui.RadioButton("Geometric", not vars.isExponential) then
        vars.isExponential = false
    end
    --[[if vars.isExponential then
          
    else
        
    end]]--
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    _, vars.svPoints = imgui.InputInt("SV points", vars.svPoints)
    vars.svPoints = mathClamp(vars.svPoints, 1, 1000)
    imgui.PopItemWidth()
    separator()
    if imgui.Button("Place SVs Between Selected Notes", {1.5 * DEFAULT_WIDGET_WIDTH - 25,
                    1.5 * DEFAULT_WIDGET_HEIGHT}) then
        local SVs = calculateExponentialSV()
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
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    
    saveStateVariables(menuID, vars)
end
-- Creates the "Bezier SV" menu
-- Parameters
--    menuID : name of the menu [String]
function bezierMenu(menuID)
    local vars = {
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    
    saveStateVariables(menuID, vars)
end
-- Creates the "Sinusoidal SV" menu
-- Parameters
--    menuID : name of the menu [String]
function sinusoidalMenu(menuID)
    local vars = {
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    
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
        svValue = 1
    }
    retrieveStateVariables(menuID, vars)
    
    _, vars.svBefore = imgui.Checkbox("Add SV before note", vars.svBefore)
    _, vars.svAfter = imgui.Checkbox("Add SV after note", vars.svAfter)
    spacing()
    _, vars.skipSVAtNote = imgui.Checkbox("Skip SV at note", vars.skipSVAtNote)
    separator()
    
    if vars.svBefore then
        _, vars.svValueBefore = imgui.DragFloat("SV before note", vars.svValueBefore, 0.01,
                                                -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE, "%.2fx")
        vars.svValueBefore = mathClamp(vars.svValueBefore, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        _, vars.incrementBefore = imgui.DragFloat("Time before note", vars.incrementBefore, 0.01,
                                                  MIN_DURATION, MAX_DURATION, "%.3f ms")
        vars.incrementBefore = mathClamp(vars.incrementBefore, MIN_DURATION, MAX_DURATION)
    end
    if not vars.skipSVAtNote then
        if vars.svBefore then
            spacing()
        end
        _, vars.svValue = imgui.DragFloat("SV at note", vars.svValue, 0.01, -MAX_TELEPORT_VALUE,
                                          MAX_TELEPORT_VALUE, "%.2fx")
        vars.svValue = mathClamp(vars.svValue, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
    end
    if vars.svAfter then
        if vars.svBefore or not vars.skipSVAtNote then
            spacing()
        end
        _, vars.svValueAfter = imgui.DragFloat("SV after note", vars.svValueAfter, 0.01,
                                               -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE, "%.2fx")
        vars.svValueAfter = mathClamp(vars.svValueAfter, -MAX_TELEPORT_VALUE, MAX_TELEPORT_VALUE)
        _, vars.incrementAfter = imgui.DragFloat("Time after note", vars.incrementAfter, 0.01,
                                                 MIN_DURATION, MAX_DURATION, "%.3f ms")
        vars.incrementAfter = mathClamp(vars.incrementAfter, MIN_DURATION, MAX_DURATION)
    end
    
    if vars.svBefore or (not vars.skipSVAtNote) or vars.svAfter then
        separator()
        if imgui.Button("Place SVs At Selected Notes", {DEFAULT_WIDGET_WIDTH,
                        DEFAULT_WIDGET_HEIGHT}) then
            local offsets = uniqueSelectedNoteOffsets()
            local SVs = {}
            for i = 1, #offsets do
                if vars.svBefore then
                    table.insert(SVs, utils.CreateScrollVelocity(offsets[i] - vars.incrementBefore,
                                 vars.svValueBefore))
                end
                if not vars.skipSVAtNote then
                     table.insert(SVs, utils.CreateScrollVelocity(offsets[i], vars.svValue))
                end
                if vars.svAfter then
                    table.insert(SVs, utils.CreateScrollVelocity(offsets[i] + vars.incrementAfter,
                                 vars.svValueAfter))
                end
            end
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
    
    if imgui.Button("Remove SVs") then
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
-- ** Code for next two functions for linear SV is copied from iceSV, but very modified **

-- Calculates all linear SVs to place and returns all the SVs
-- Parameters
--    startSV           : starting value of the linear SV [Int/Float] 
--    endSV             : ending value of the linear SV [Int/Float] 
--    svPoints          : number of SVs to place (excluding the very last SV) [Int]
--    endSVOption       : option number for the last SV (based on constant END_SV_TYPES) [Int]
--    interlace         : whether or not to interlace another linear SV [Bool]
--    interlaceStartSV  : starting value of the interlaced linear SV [Int/Float] 
--    interlaceEndSV    : ending value of the interlaced linear SV [Int/Float] 
--    addTeleport       : whether or not to add a teleport SV [Bool]
--    veryStartTeleport : whether or not the teleport SV is for the very start only [Bool]
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
        if i ~= #offsets - 1 then
            linearSVs = generateLinearSV(startOffset, timeInterval, startSV, svIncrement,
                                         svPoints, 2)
        else
            linearSVs = generateLinearSV(startOffset, timeInterval, startSV, svIncrement,
                                           svPoints, endSVOption)
        end
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
-- Returns a set of linear SVs
-- Parameters
--    startOffset  : start time of the linear SVs [Int]
--    timeInterval : time inbetween each consecutive SV [Int/Float]
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
function calculateExponentialSV()
    local SVs = {}
    return SVs
end
function generateExponentialSV()
    local SVs = {}
    return SVs
end
-- Returns the value for the last SV
-- Parameters
--    velocity    : default/usual SV value for the end SV [Int/Float]
--    endSVOption : option number for the last SV (based on global constant END_SV_TYPES) [Int]
function endSVValue(velocity, endSVOption)
    if endSVOption == 1 then
        return velocity
    elseif endSVOption == 2 then
        return nil
    else
        return 1
    end
end
-- Restricts a number to be within a closed interval
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
-- Returns the (unique) offsets of all currently selected notes sorted in ascending order
function uniqueSelectedNoteOffsets()
    local offsets = {}
    for i, hitObject in pairs(state.SelectedHitObjects) do
        offsets[i] = hitObject.StartTime
    end
    offsets = uniqueByTime(offsets)
    offsets = table.sort(offsets, function(a, b) return a < b end)
    return offsets
end
-- Takes in a list of offsets and returns the list only with offsets that are at a unique time
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
-- Concatenates two strings by sandwiching one string between two of the other string.
-- Parameters
--    string1 : string to put in the middle [String]
--    string2 : string to add on both sides [String]
function sandwichStrings(string1, string2)
    return string2..string1..string2
end

---------------------------------------------------------------------------------------------------
-- Global Constants
---------------------------------------------------------------------------------------------------

-- GUI
DEFAULT_WIDGET_HEIGHT = 26         -- value determining the height of GUI widgets
DEFAULT_WIDGET_WIDTH = 200         -- value determining the width of GUI widgets
SAMELINE_SPACING = 5               -- value determining spacing between GUI items on the same row

-- SV restrictions
MAX_TELEPORT_VALUE = 100000        -- maximum (absolute) teleport SV value allowed
MAX_TELEPORT_DURATION = 10         -- maximum teleport duration allowed (milliseconds)
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