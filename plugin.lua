-- amoguSV v1 (20 June 2021)
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
-- can the constant be declared  with references to those functions. Including this constant
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
    imgui.BeginChild("SV Menu", {300, 310}, false)
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
        intermediatePoints = 16,
        interlace = false,
        interlaceStartSV = -1,
        interlaceEndSV = 0
    }
    retrieveStateVariables(menuID, vars)
    
    local halfWidgetWidth = (DEFAULT_WIDGET_WIDTH - SAMELINE_SPACING) / 2
    
    imgui.PushItemWidth(halfWidgetWidth)
    _, vars.startSV = imgui.DragFloat("", vars.startSV, 0.01, -1000, 1000, "%.2fx")
    imgui.SameLine(0, SAMELINE_SPACING)
    _, vars.endSV = imgui.DragFloat("Start/End SV", vars.endSV, 0.01, -1000, 1000, "%.2fx")
    if imgui.Button("Swap End and Start", {DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT}) then
        local temp = vars.startSV
        vars.startSV = vars.endSV
        vars.endSV = temp
    end
    imgui.PopItemWidth()
    spacing()
    
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    _, vars.intermediatePoints = imgui.InputInt("SV Points", vars.intermediatePoints)
    vars.intermediatePoints = forcePositive(vars.intermediatePoints)
    imgui.PopItemWidth()
    spacing()
    
    imgui.Text("Last SV:")
    for i = 1, #END_SV_TYPES do
        _, vars.endSVOption = imgui.RadioButton(END_SV_TYPES[i], vars.endSVOption, i)
        if i ~= #END_SV_TYPES then
            imgui.SameLine(0, 3 * SAMELINE_SPACING)
        end
    end
    spacing()
    
    _, vars.interlace = imgui.Checkbox("Interlace with different linear", vars.interlace)
    
    if vars.interlace then
        imgui.PushItemWidth(halfWidgetWidth)
        _, vars.interlaceStartSV = imgui.DragFloat(" ", vars.interlaceStartSV, 0.01, -1000, 1000, "%.2fx")
        imgui.SameLine(0, SAMELINE_SPACING)
        _, vars.interlaceEndSV = imgui.DragFloat(" Start/End SV ", vars.interlaceEndSV, 0.01, -1000, 1000, "%.2fx")
        if imgui.Button(" Swap End and Start ", {DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT}) then
            local temp = vars.interlaceStartSV
            vars.interlaceStartSV = vars.interlaceEndSV
            vars.interlaceEndSV = temp
        end
        imgui.PopItemWidth()
        spacing()
    end
    separator()
    
    if imgui.Button("Place SVs Between Selected Notes") then
        local offsets = uniqueSelectedNoteOffsets()
        local SVs = {}
        for i = 1, #offsets - 1 do
            local someSVs = calculateLinearSV(vars.startSV, vars.endSV, offsets[i], offsets[i + 1],
                                              vars.intermediatePoints, vars.endSVOption, vars.interlace,
                                              vars.interlaceStartSV, vars.interlaceEndSV)
            -- if we aren't placing the last set of linear SVs and haven't skipped the last SV yet
            if i ~= #offsets - 1 and vars.endSVOption ~= 2 then
                -- don't place the last SV
                table.remove(someSVs, #someSVs)
            end
            for j = 1, #someSVs do
                table.insert(SVs, someSVs[j])
            end
        end
        if #SVs > 0 then
            actions.PlaceScrollVelocityBatch(SVs)
        end
    end
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
        startOffset = 0,
        endOffset = 0
    }
    retrieveStateVariables(menuID, vars)
    
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
        svsToRemove = {}
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
function calculateLinearSV(startSV, endSV, startOffset, endOffset, intermediatePoints, endSVOption,
                           interlace, interlaceStartSV, interlaceEndSV)
    local timeInterval = (endOffset - startOffset)/intermediatePoints
    local velocityInterval = (endSV - startSV)/intermediatePoints
    local interlaceVelocityInterval = (interlaceEndSV - interlaceStartSV)/intermediatePoints

    local SVs = {}

    if interlace then
        for step = 0, intermediatePoints - 1 do
            local offset = step * timeInterval + startOffset + (timeInterval * 0.5)
            local velocity = step * interlaceVelocityInterval + interlaceStartSV
            table.insert(SVs, utils.CreateScrollVelocity(offset, velocity))
        end
    end
    if endSVOption == 2 then
        intermediatePoints = intermediatePoints - 1
    end
    for step = 0, intermediatePoints do
        local offset = step * timeInterval + startOffset
        local velocity = step * velocityInterval + startSV
        if (step == intermediatePoints and endSVOption == 3) then
            velocity = 1
        end
        table.insert(SVs, utils.CreateScrollVelocity(offset, velocity))
    end
    return SVs
end

function forcePositive(num)
    if num > 0 then
        return num
    end
    return 1
end

-- Returns the (unique) offsets of the selected notes
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
TOOL_OPTIONS = {                        -- list of available tools for editing SVs
    "Linear",
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