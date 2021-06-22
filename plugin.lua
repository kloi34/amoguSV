-- amoguSV v1 (21 June 2021)
-- by kloi34

-- Many SV tools and/or code snippets were stolen, so credit to those creators of the SV plugins:
--    iceSV       (by IceDynamix)         @ https://github.com/IceDynamix/iceSV
--    KeepStill   (by Illuminati-CRAZ)    @ https://github.com/Illuminati-CRAZ/KeepStill

---------------------------------------------------------------------------------------------------
-- Plugin Info
---------------------------------------------------------------------------------------------------

-- This is a mapping plugin for the ultimate community-driven, and open-source competitive rhythm
-- game Quaver. The plugin contains various tools for editing SVs (Slider Velocities) quickly and
-- efficiently. It's most similar to (i.e. 80% of SV features and functionality stolen from) iceSV.

-- ** Coding Side Note **
-- The 'Global Constants' section is located at the bottom of the code instead of here at the top
-- because one of the constants uses references to functions; only after the functions are declared
-- can the constant be declared with references to those functions. Including this constant
-- reduces redundancies and increases future code maintainability.

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
    local menuID = "Main"
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
    imgui.Text(TOOL_OPTIONS[vars.optionNum].." SV")
    spacing()
    
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

-- Creates the linear SV menu
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
    vars.svPoints = forcePositive(vars.svPoints)
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
        _, vars.teleportValue = imgui.DragFloat("Teleport SV", vars.teleportValue, 0.01, -100000,
                                                100000, "%.2fx")
        _, vars.teleportDuration = imgui.DragFloat("Duration", vars.teleportDuration, 0.01,
                                                   0, 10, "%.3f ms")
    end
    separator()
       
    if imgui.Button("Place SVs Between Selected Notes", {1.5 * DEFAULT_WIDGET_WIDTH - 25, 1.5 * DEFAULT_WIDGET_HEIGHT}) then
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

function exponentialMenu(menuID)
    local vars = {
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    
    saveStateVariables(menuID, vars)
end

-- Creates the stutter SV menu
function stutterMenu(menuID)
    local vars = {
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    
    saveStateVariables(menuID, vars)
end

-- Creates the bezier SV menu
function bezierMenu(menuID)
    local vars = {
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    
    saveStateVariables(menuID, vars)
end

-- Creates the single SV menu
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
    _, vars.skipSVAtNote = imgui.Checkbox("Skip SV at note", vars.skipSVAtNote)
    separator()
    if vars.svBefore then
        _, vars.svValueBefore = imgui.DragFloat("SV before note", vars.svValueBefore, 0.01, -100000,
                                                100000, "%.2fx")
        _, vars.incrementBefore = imgui.DragFloat("Time before note", vars.incrementBefore, 0.01, 0,
                                                  100000, "%.3f ms")
    end
    if not vars.skipSVAtNote then
        if vars.svBefore then
            spacing()
        end
        _, vars.svValue = imgui.DragFloat("SV at note", vars.svValue, 0.01, -100000, 100000, "%.2fx")
    end
    if vars.svAfter then
        if vars.svBefore or not vars.skipSVAtNote then
            spacing()
        end
        _, vars.svValueAfter = imgui.DragFloat("SV after note", vars.svValueAfter, 0.01, -100000,
                                               100000, "%.2fx")
        _, vars.incrementAfter = imgui.DragFloat("Time after note", vars.incrementAfter, 0.01, 0,
                                                 100000, "%.3f ms")
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

-- Creates the remove SV menu
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
--    menuID    : name of the tab menu that the variables are from (String)
--    variables : table that contains variables and values (Table)
function retrieveStateVariables(menuID, variables)
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(menuID..key) or value
    end
end

-- Saves variables to the state
-- Parameters
--    menuID    : name of the tab menu that the variables are from (String)
--    variables : table that contains variables and values (Table)
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

-- Copied + modified from iceSV
function calculateLinearSV(startSV, endSV, svPoints, endSVOption, interlace, interlaceStartSV,
                           interlaceEndSV, addTeleport, veryStartTeleport, teleportValue,
                           teleportDuration)
    local offsets = uniqueSelectedNoteOffsets()
    local SVs = {}
    for i = 1, #offsets - 1 do
        local someSVs = {}
        local startOffset = offsets[i]
        local svPointsTemp = svPoints
        if addTeleport then
            if not (veryStartTeleport and i ~= 1) then
                table.insert(someSVs, utils.CreateScrollVelocity(startOffset, teleportValue))
                startOffset = startOffset + teleportDuration
            end
        end
        local endOffset = offsets[i + 1]
        local timeInterval = (endOffset - startOffset) / svPointsTemp
        local velocityInterval = (endSV - startSV) / svPointsTemp
        local interlaceVelocityInterval = (interlaceEndSV - interlaceStartSV) / svPointsTemp

        if interlace then
            for step = 0, svPointsTemp - 1 do
                local offset = step * timeInterval + startOffset + (timeInterval * 0.5)
                local velocity = step * interlaceVelocityInterval + interlaceStartSV
                table.insert(someSVs, utils.CreateScrollVelocity(offset, velocity))
            end
        end
        -- if skip end SV is selected
        if endSVOption == 2 then
            svPointsTemp = svPointsTemp - 1
        end
        for step = 0, svPointsTemp do
            local offset = step * timeInterval + startOffset
            local velocity = step * velocityInterval + startSV
            if (step == svPoints and endSVOption == 3) then
                velocity = 1
            end
            table.insert(someSVs, utils.CreateScrollVelocity(offset, velocity))
        end
        -- if we aren't placing the last set of linear SVs and haven't skipped the last SV yet
        -- in the calculateLinearSV function
        if i ~= #offsets - 1 and endSVOption ~= 2 then
            -- skip the last SV
            table.remove(someSVs, #someSVs)
        end
        for j = 1, #someSVs do
            table.insert(SVs, someSVs[j])
        end
    end
    return SVs
end

function generateLinearSV()
    SVs = {}
    return SVs
end

-- Makes a number positive by returning the same number or returning positive one 
-- Parameters
--    x : the number to force positive (Int or Float)
function forcePositive(x)
    if x > 0 then
        return x
    end
    return 1
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
--    offsets : list of offsets (Table)
function uniqueByTime(offsets)
    local hash = {}
    -- new list of unique offsets
    local uniqueTimes = {}
    
    for _, value in ipairs(offsets) do
        -- if the offset is not already on the new list of offsets
        if (not hash[value]) then
          -- add offset to the new list
            uniqueTimes[#uniqueTimes + 1] = value
            hash[value] = true
        end
    end
    return uniqueTimes
end

---------------------------------------------------------------------------------------------------
-- Global Constants
---------------------------------------------------------------------------------------------------

DEFAULT_WIDGET_HEIGHT = 26         -- value determining the height of GUI widgets
DEFAULT_WIDGET_WIDTH = 200         -- value determining the width of GUI widgets
SAMELINE_SPACING = 5               -- value determining spacing between GUI items on the same row
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
    "Single",
    "Remove"
}
MENUS = {}                         -- table of references to Lua functions for menus

-- Adds references to functions for each SV menu into the table 'MENUS'
for i = 1, #TOOL_OPTIONS do
    local functionName = string.lower(TOOL_OPTIONS[i]).."Menu"
    table.insert(MENUS, _G[functionName])
end