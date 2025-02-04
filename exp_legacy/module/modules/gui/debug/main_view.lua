local Gui = require("modules.exp_legacy.utils.gui") --- @dep utils.gui
local Color = require("modules/exp_util/include/color")

local Public = {}

local pages = {
    require("modules.exp_legacy.modules.gui.debug.redmew_global_view"),
    require("modules.exp_legacy.modules.gui.debug.expcore_datastore_view"),
    require("modules.exp_legacy.modules.gui.debug.expcore_gui_view"),
    require("modules.exp_legacy.modules.gui.debug.global_view"),
    require("modules.exp_legacy.modules.gui.debug.package_view"),
    require("modules.exp_legacy.modules.gui.debug._g_view"),
    require("modules.exp_legacy.modules.gui.debug.event_view"),
}

local main_frame_name = Gui.uid_name()
local close_name = Gui.uid_name()
local tab_name = Gui.uid_name()

function Public.open_debug(player)
    for i = 1, #pages do
        local page = pages[i]
        local callback = page.on_open_debug
        if callback then
            callback()
        end
    end

    local center = player.gui.center
    local frame = center[main_frame_name]
    if frame then
        return
    end

    --[[
        local screen_element = player.gui.screen

        frame = screen_element.add{type = 'frame', name = main_frame_name, caption = 'Debuggertron 3000'}
        frame.style.size = {900, 600}
        frame.auto_center = true
    ]]

    frame = center.add{ type = "frame", name = main_frame_name, caption = "Debuggertron 3002", direction = "vertical" }
    local frame_style = frame.style
    frame_style.height = 600
    frame_style.width = 900

    local tab_flow = frame.add{ type = "flow", direction = "horizontal" }
    local container = frame.add{ type = "flow" }
    container.style.vertically_stretchable = true

    local data = {}

    for i = 1, #pages do
        local page = pages[i]
        local tab_button = tab_flow.add{ type = "flow" }.add{ type = "button", name = tab_name, caption = page.name }
        local tab_button_style = tab_button.style

        Gui.set_data(tab_button, { index = i, frame_data = data })

        if i == 1 then
            tab_button_style.font_color = Color.orange

            data.selected_index = i
            data.selected_tab_button = tab_button
            data.container = container

            Gui.set_data(frame, data)
            page.show(container)
        end
    end

    frame.add{ type = "button", name = close_name, caption = "Close" }
end

Gui.on_click(
    tab_name,
    function(event)
        local element = event.element
        local data = Gui.get_data(element)

        local index = data.index
        local frame_data = data.frame_data
        local selected_index = frame_data.selected_index

        if selected_index == index then
            return
        end

        local selected_tab_button = frame_data.selected_tab_button
        selected_tab_button.style.font_color = Color.black

        frame_data.selected_tab_button = element
        frame_data.selected_index = index
        element.style.font_color = Color.orange

        local container = frame_data.container
        Gui.clear(container)
        pages[index].show(container)
    end
)

Gui.on_click(
    close_name,
    function(event)
        local frame = event.player.gui.center[main_frame_name]
        if frame then
            Gui.destroy(frame)
        end
    end
)

return Public
