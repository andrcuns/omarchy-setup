local NAME = "terminal"
local WORKSPACE = "special:" .. NAME
local SIDE_GAP = 5
local TOP_GAP = 4
local HEIGHT_PERCENT = 70

hl.bind("CTRL + return", hl.dsp.workspace.toggle_special(NAME), { description = "Drop-Down Terminal" })

hl.on("workspace.created", function(ws)
    if ws and ws.name == WORKSPACE and ws.is_empty then
        -- The placement rule follows the spawned process, so launch a fresh Kitty.
        hl.exec_cmd("kitty --class Terminal", { workspace = WORKSPACE .. " silent" })
    end
end)

local last_gaps

local function has_output(monitor)
    local scale = monitor and monitor.scale
    return scale and scale > 0
end

local function fit(monitor)
    if not has_output(monitor) then
        return false
    end

    -- Quarter turns swap the axes. Reservations and gaps are already logical.
    local height = monitor.transform % 2 == 1 and monitor.width or monitor.height
    local logical_height = height / monitor.scale
    local reserved = monitor.reserved
    local target_height = math.floor(logical_height * HEIGHT_PERCENT / 100)
    local gaps = {
        top = TOP_GAP,
        right = math.max(0, math.ceil(SIDE_GAP - reserved.right)),
        bottom = math.max(0, math.floor(logical_height - reserved.top - reserved.bottom - TOP_GAP - target_height)),
        left = math.max(0, math.ceil(SIDE_GAP - reserved.left)),
    }
    if last_gaps and last_gaps.right == gaps.right and last_gaps.bottom == gaps.bottom and last_gaps.left == gaps.left then
        return false
    end

    hl.workspace_rule({
        workspace = WORKSPACE,
        gaps_in = 0,
        gaps_out = gaps,
        no_border = true,
    })
    last_gaps = gaps
    return true
end

local function terminal_monitor()
    local ws = hl.get_workspace(WORKSPACE)
    local monitor = ws and ws.visible and ws.monitor
    if has_output(monitor) then
        return monitor
    end
    return hl.get_active_monitor()
end

local function refit(monitor)
    if fit(monitor) then
        hl.exec_scheduled_prop_refresh_immediately()
    end
end

local function on_output_change()
    refit(terminal_monitor())
end

local function on_workspace_change(ws, monitor)
    if ws and ws.name == WORKSPACE then
        refit(monitor)
    end
end

fit(terminal_monitor())
hl.on("monitor.layout_changed", on_output_change)
hl.on("monitor.focused", on_output_change)
hl.on("workspace.special_active", on_workspace_change)
hl.on("workspace.move_to_monitor", on_workspace_change)
