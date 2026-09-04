-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.wallpaper = os.getenv("HOME").."/.config/awesome/themes/bands.svg"

-- Phosphor: a sharp terminal palette shared by every desktop surface.
local palette = {
    canvas     = "#16181d",
    bar        = "#1c1f25",
    surface    = "#23272e",
    surface_2  = "#2c313a",
    border     = "#3a404a",
    foreground = "#e6e9ed",
    secondary  = "#b7bec8",
    muted      = "#7b838f",
    green      = "#ffb340",
    sage       = "#98c379",
    cyan       = "#5ed3f3",
    blue       = "#5b9dff",
    violet     = "#d67cff",
    amber      = "#ffd866",
    red        = "#ff4d6d",
}

for _, k in ipairs({
    "layout_tile", "layout_tileleft", "layout_tilebottom", "layout_tiletop",
    "layout_fairv", "layout_fairh", "layout_spiral", "layout_dwindle",
    "layout_max", "layout_fullscreen", "layout_magnifier", "layout_floating",
    "layout_cornernw", "layout_cornerne", "layout_cornersw", "layout_cornerse",
}) do
    if beautiful[k] then
        beautiful[k] = gears.color.recolor_image(beautiful[k], palette.blue)
    end
end

beautiful.font = "InputMono Nerd Font 9"
beautiful.bg_normal = palette.bar
beautiful.bg_focus = palette.surface_2
beautiful.bg_urgent = "#3a1c24"
beautiful.fg_normal = palette.foreground
beautiful.fg_focus = "#e6e9ed"
beautiful.fg_urgent = palette.red
beautiful.border_width = 2
beautiful.border_normal = palette.border
beautiful.border_focus = "#e6e9ed"
beautiful.border_marked = palette.green
beautiful.useless_gap = 3
beautiful.gap_single_client = true
beautiful.taglist_shape = gears.shape.rectangle
beautiful.tasklist_shape = gears.shape.rectangle
beautiful.tooltip_font = "InputMono Nerd Font 9"
beautiful.tooltip_bg = palette.surface
beautiful.tooltip_fg = palette.foreground
beautiful.tooltip_border_width = 1
beautiful.tooltip_border_color = "#e6e9ed"
beautiful.tooltip_shape = gears.shape.rectangle
beautiful.notification_bg = palette.surface
beautiful.notification_fg = palette.foreground
beautiful.notification_border_width = 1
beautiful.notification_border_color = "#e6e9ed"
beautiful.notification_shape = gears.shape.rectangle
beautiful.menu_bg_normal = palette.surface
beautiful.menu_bg_focus = palette.surface_2
beautiful.menu_fg_normal = palette.foreground
beautiful.menu_fg_focus = "#e6e9ed"
beautiful.menu_border_width = 1
beautiful.menu_border_color = "#e6e9ed"
beautiful.menu_shape = gears.shape.rectangle
beautiful.taglist_squares_sel = nil
beautiful.taglist_squares_unsel = nil
beautiful.taglist_squares_sel_empty = nil
beautiful.taglist_squares_unsel_empty = nil

-- This is used later as the default terminal and editor to run.
terminal = "term"   -- bin/term: reuses the running alacritty, cold-starts if none
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

-- Keyboard layout configuration (single source of truth).
local keyboard_layouts = "us,il,de"
local keyboard_toggle_option = "grp:alt_shift_toggle"

local function apply_keyboard_layout()
    awful.spawn.with_shell(
        "setxkbmap -layout " .. keyboard_layouts ..
        " -option '' -option " .. keyboard_toggle_option
    )
end

local function ensure_keyboard_layout()
    awful.spawn.easy_async_with_shell(
        "setxkbmap -query | awk '/^layout:/{l=$2} /^options:/{o=$2} END{print l \"|\" o}'",
        function(stdout)
            local layout, options = stdout:match("^([^|]+)|([^\n]*)")
            local has_toggle = options and options:match("(^|,)" .. keyboard_toggle_option .. "(,|$)")
            if layout ~= keyboard_layouts or not has_toggle then
                apply_keyboard_layout()
            end
        end
    )
end

local keyboard_layout_guard = gears.timer({
    timeout = 10,
    autostart = true,
    call_now = false,
    callback = ensure_keyboard_layout
})
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

local launcher_textbox = wibox.widget {
    markup = string.format("<span foreground='%s'>▣</span>", palette.blue),
    font = "InputMono Nerd Font 11",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
mylauncher = wibox.widget {
    launcher_textbox,
    left = 10,
    right = 6,
    widget = wibox.container.margin,
}
mylauncher:buttons(gears.table.join(
    awful.button({}, 1, function() mymainmenu:toggle() end)
))

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- ponytail: flat bar. `background` is kept in the signature for the callers but unused.
local function make_module(widget, background, left, right)
    return wibox.widget {
        widget,
        left = left or 8,
        right = right or 8,
        widget = wibox.container.margin,
    }
end

local function make_labeled_widget(icon, widget)
    return wibox.widget {
        {
            markup = string.format("<span foreground='%s'>%s</span>", palette.blue, gears.string.xml_escape(icon)),
            font = "InputMono Nerd Font 9",
            widget = wibox.widget.textbox,
        },
        widget,
        spacing = 6,
        layout = wibox.layout.fixed.horizontal,
    }
end

-- Weather capsule -----------------------------------------------------------
-- ipinfo.io geolocates the public IP to coordinates, Open-Meteo turns those
-- into a live reading (wttr.in served stale data). One timer updates the
-- widgets on every screen so multi-monitor setups only make one request.
local weather_views = {}
local weather_timer
local weather_refreshing = false
local weather_details = "Weather data is loading…"

-- geo lookup then forecast, emitting "temp|wmo_code|city" on one line
local weather_command = { "/bin/sh", "-c", [[
    set -e
    geo=$(curl -sf --max-time 8 https://ipinfo.io/json)
    loc=$(printf '%s' "$geo" | grep -o '"loc": *"[^"]*"' | cut -d'"' -f4)
    city=$(printf '%s' "$geo" | grep -o '"city": *"[^"]*"' | cut -d'"' -f4)
    lat=${loc%,*}; lon=${loc#*,}
    wx=$(curl -sf --max-time 8 "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code")
    temp=$(printf '%s' "$wx" | grep -o '"temperature_2m": *[-0-9.]*' | grep -o '[-0-9.]*$')
    code=$(printf '%s' "$wx" | grep -o '"weather_code": *[0-9]*' | grep -o '[0-9]*$')
    printf '%s|%s|%s\n' "$temp" "$code" "$city"
]] }

-- WMO weather codes → icon + label
local wmo_conditions = {
    [0] = { "☀️", "Clear sky" },
    [1] = { "🌤️", "Mostly clear" },
    [2] = { "⛅", "Partly cloudy" },
    [3] = { "☁️", "Overcast" },
    [45] = { "🌫️", "Fog" }, [48] = { "🌫️", "Rime fog" },
    [51] = { "🌦️", "Light drizzle" }, [53] = { "🌦️", "Drizzle" }, [55] = { "🌦️", "Heavy drizzle" },
    [56] = { "🌦️", "Freezing drizzle" }, [57] = { "🌦️", "Freezing drizzle" },
    [61] = { "🌧️", "Light rain" }, [63] = { "🌧️", "Rain" }, [65] = { "🌧️", "Heavy rain" },
    [66] = { "🌧️", "Freezing rain" }, [67] = { "🌧️", "Freezing rain" },
    [71] = { "🌨️", "Light snow" }, [73] = { "🌨️", "Snow" }, [75] = { "🌨️", "Heavy snow" },
    [77] = { "🌨️", "Snow grains" },
    [80] = { "🌦️", "Light showers" }, [81] = { "🌦️", "Showers" }, [82] = { "🌦️", "Heavy showers" },
    [85] = { "🌨️", "Snow showers" }, [86] = { "🌨️", "Snow showers" },
    [95] = { "⛈️", "Thunderstorm" }, [96] = { "⛈️", "Thunderstorm, hail" }, [99] = { "⛈️", "Thunderstorm, hail" },
}

local function trim(value)
    return value and value:match("^%s*(.-)%s*$") or nil
end

local function update_weather()
    if weather_refreshing then
        return
    end
    weather_refreshing = true

    awful.spawn.easy_async(weather_command, function(stdout, stderr, _, exit_code)
        weather_refreshing = false
        local temp, code, location = stdout:match("^([^|]+)|([^|]+)|([^\r\n]*)")

        temp = tonumber(trim(temp))
        code = tonumber(trim(code))
        location = trim(location)

        local wmo = wmo_conditions[code]
        local icon = wmo and wmo[1]
        local condition = wmo and wmo[2]
        local temperature = temp and string.format("%.0f°C", temp)

        if exit_code ~= 0 or not temperature then
            local error_message = trim(stderr)
            weather_details = "Weather unavailable"
            if error_message and error_message ~= "" then
                weather_details = weather_details .. "\n" .. error_message
            end
            weather_details = weather_details .. "\nClick to retry"

            for _, view in ipairs(weather_views) do
                view.icon:set_markup(string.format("<span foreground='%s'>☁️</span>", palette.cyan))
                view.temperature:set_text("--°")
                view.tooltip:set_text(weather_details)
            end
            return
        end

        weather_details = string.format(
            "%s\n%s\nUpdated %s • click to refresh",
            condition or "Current weather",
            location or "Automatic location",
            os.date("%H:%M")
        )

        local weather_color = (code and code <= 2) and palette.amber or palette.cyan
        for _, view in ipairs(weather_views) do
            view.icon:set_markup(string.format("<span foreground='%s'>%s</span>", weather_color, icon or "☁️"))
            view.temperature:set_text(temperature)
            view.tooltip:set_text(weather_details)
        end
    end)
end

local function make_weather_widget()
    local icon = wibox.widget {
        markup = string.format("<span foreground='%s'>☁️</span>", palette.cyan),
        font = "InputMono Nerd Font 9",
        widget = wibox.widget.textbox,
    }
    local temperature = wibox.widget {
        text = "--°",
        font = "InputMono Nerd Font 9",
        widget = wibox.widget.textbox,
    }
    local contents = wibox.widget {
        icon,
        temperature,
        spacing = 5,
        layout = wibox.layout.fixed.horizontal,
    }
    local container = make_module(contents, palette.surface, 9, 9)
    local tooltip = awful.tooltip {
        objects = { container },
        text = weather_details,
        delay_show = 0.25,
        bg = palette.surface,
        fg = palette.foreground,
        shape = gears.shape.rectangle,
    }

    container:buttons(gears.table.join(
        awful.button({}, 1, update_weather)
    ))

    table.insert(weather_views, {
        icon = icon,
        temperature = temperature,
        tooltip = tooltip,
    })

    if not weather_timer then
        weather_timer = gears.timer {
            timeout = 900,
            autostart = true,
            call_now = true,
            callback = update_weather,
        }
    end

    return container
end

-- Battery capsule -----------------------------------------------------------
-- One timer feeds every screen, so multi-monitor setups do not poll sysfs or
-- emit low-battery notifications more than once.
local battery_views = {}
local battery_timer
local battery_details = "Battery data is loading…"
local battery_alert_level
-- Last time the low-battery blip played (os.time seconds); rate-limited to 10 min.
local battery_blip_last = 0

local battery_command = [[
for battery in /sys/class/power_supply/BAT*; do
    [ -r "$battery/capacity" ] || continue
    capacity=$(cat "$battery/capacity" 2>/dev/null)
    battery_state=$(cat "$battery/status" 2>/dev/null)
    now=$(cat "$battery/energy_now" 2>/dev/null)
    [ -n "$now" ] || now=$(cat "$battery/charge_now" 2>/dev/null)
    full=$(cat "$battery/energy_full" 2>/dev/null)
    [ -n "$full" ] || full=$(cat "$battery/charge_full" 2>/dev/null)
    rate=$(cat "$battery/power_now" 2>/dev/null)
    [ -n "$rate" ] || rate=$(cat "$battery/current_now" 2>/dev/null)
    printf '%s|%s|%s|%s|%s\n' "$capacity" "$battery_state" "$now" "$full" "$rate"
    break
done
]]

local function battery_icon(capacity, status)
    if status == "Charging" then
        return "󰂄"
    end

    local icons = {
        "󰂎", "󰁺", "󰁻", "󰁼", "󰁽",
        "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹",
    }
    local index = math.min(11, math.max(1, math.floor(capacity / 10) + 1))
    return icons[index]
end

local function battery_color(capacity, status)
    if status == "Charging" or capacity > 40 then
        return palette.sage
    elseif capacity >= 15 then
        return palette.amber
    else
        return palette.red
    end
end

local function format_duration(minutes)
    if not minutes or minutes <= 0 then
        return nil
    end

    local hours = math.floor(minutes / 60)
    local mins = minutes % 60
    if hours > 0 then
        return string.format("%dh %02dm", hours, mins)
    end
    return string.format("%dm", mins)
end

local function update_battery()
    awful.spawn.easy_async({ "/bin/sh", "-c", battery_command }, function(stdout)
        local capacity_s, status, now_s, full_s, rate_s =
            stdout:match("^(%d+)|([^|]*)|(%d*)|(%d*)|(%d*)")
        local capacity = tonumber(capacity_s)

        if not capacity then
            battery_details = "No battery detected"
            for _, view in ipairs(battery_views) do
                view.container:set_visible(false)
            end
            return
        end

        local now = tonumber(now_s)
        local full = tonumber(full_s)
        local rate = tonumber(rate_s)
        local remaining_minutes

        if rate and rate > 0 then
            if status == "Discharging" and now then
                remaining_minutes = math.floor((now / rate) * 60 + 0.5)
            elseif status == "Charging" and now and full then
                remaining_minutes = math.floor(((full - now) / rate) * 60 + 0.5)
            end
        end

        local duration = format_duration(remaining_minutes)
        local suffix = ""
        if duration then
            suffix = status == "Charging"
                and " • " .. duration .. " until full"
                or " • " .. duration .. " remaining"
        end

        battery_details = string.format("%s%s", status, suffix)
        local color = battery_color(capacity, status)
        local icon = battery_icon(capacity, status)

        for _, view in ipairs(battery_views) do
            view.container:set_visible(true)
            view.icon:set_markup(string.format(
                "<span foreground='%s'>%s</span>",
                color,
                icon
            ))
            local percent_text = string.format("%d%%", capacity)
            if capacity <= 15 then
                percent_text = string.format(
                    "<span foreground='%s'>%s</span>",
                    palette.red,
                    percent_text
                )
            end
            view.percent:set_markup(percent_text)
            view.tooltip:set_text(
                string.format("Battery %d%%\n%s", capacity, battery_details)
            )
        end

        if status == "Discharging" then
            if capacity <= 15 then
                local now_ts = os.time()
                if now_ts - battery_blip_last >= 600 then
                    battery_blip_last = now_ts
                    awful.spawn({"/home/guy/dotfiles/bin/blip", "lowbatt"}, false)
                end
            end
            local alert_level = capacity <= 7 and 7 or capacity <= 15 and 15
            if alert_level and (not battery_alert_level or alert_level < battery_alert_level) then
                naughty.notify {
                    preset = alert_level == 7
                        and naughty.config.presets.critical
                        or naughty.config.presets.normal,
                    title = alert_level == 7 and "Battery critically low" or "Battery running low",
                    text = string.format("%d%% • %s", capacity, battery_details),
                    timeout = 8,
                }
                battery_alert_level = alert_level
            elseif capacity > 20 then
                battery_alert_level = nil
            end
        else
            battery_alert_level = nil
        end
    end)
end

local function make_battery_widget()
    local icon = wibox.widget {
        font = "InputMono Nerd Font 9",
        widget = wibox.widget.textbox,
    }
    local percent = wibox.widget {
        text = "--%",
        font = "InputMono Nerd Font 9",
        widget = wibox.widget.textbox,
    }

    local contents = wibox.widget {
        icon,
        percent,
        spacing = 6,
        layout = wibox.layout.fixed.horizontal,
    }
    local container = make_module(contents, palette.surface, 10, 10)
    container:set_visible(false)

    local tooltip = awful.tooltip {
        objects = { container },
        text = battery_details,
        delay_show = 0.25,
        bg = palette.surface,
        fg = palette.foreground,
        shape = gears.shape.rectangle,
    }

    container:buttons(gears.table.join(
        awful.button({}, 1, function()
            naughty.notify {
                title = "Battery",
                text = battery_details,
                timeout = 5,
            }
        end)
    ))

    table.insert(battery_views, {
        icon = icon,
        percent = percent,
        container = container,
        tooltip = tooltip,
    })

    if not battery_timer then
        battery_timer = gears.timer {
            timeout = 15,
            autostart = true,
            call_now = true,
            callback = update_battery,
        }
    end

    return container
end

-- CPU + memory capsules -----------------------------------------------------
-- /proc is cheap to read directly; a single timer updates every screen.
local system_views = {}
local system_timer
local previous_cpu_total
local previous_cpu_idle

local function read_first_line(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end

    local line = file:read("*l")
    file:close()
    return line
end

local function read_all(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end

    local contents = file:read("*a")
    file:close()
    return contents
end

local function resource_color(usage, normal, warning_at, critical_at)
    return normal
end

local function update_system_stats()
    local cpu_line = read_first_line("/proc/stat")
    local meminfo = read_all("/proc/meminfo")
    if not cpu_line or not meminfo then
        return
    end

    local cpu_values = {}
    for value in cpu_line:gmatch("%d+") do
        table.insert(cpu_values, tonumber(value))
    end

    local cpu_total = 0
    for index = 1, math.min(8, #cpu_values) do
        cpu_total = cpu_total + cpu_values[index]
    end
    local cpu_idle = (cpu_values[4] or 0) + (cpu_values[5] or 0)
    local total_delta = previous_cpu_total and cpu_total - previous_cpu_total or cpu_total
    local idle_delta = previous_cpu_idle and cpu_idle - previous_cpu_idle or cpu_idle
    previous_cpu_total = cpu_total
    previous_cpu_idle = cpu_idle

    local cpu_usage = 0
    if total_delta > 0 then
        cpu_usage = math.floor(
            ((total_delta - idle_delta) / total_delta) * 100 + 0.5
        )
    end
    cpu_usage = math.max(0, math.min(100, cpu_usage))

    local mem_total = tonumber(meminfo:match("MemTotal:%s+(%d+)"))
    local mem_available = tonumber(meminfo:match("MemAvailable:%s+(%d+)"))
    if not mem_total or not mem_available then
        return
    end

    local mem_used = mem_total - mem_available
    local mem_usage = math.floor((mem_used / mem_total) * 100 + 0.5)
    local load_line = read_first_line("/proc/loadavg") or ""
    local load_1, load_5, load_15 =
        load_line:match("^(%S+)%s+(%S+)%s+(%S+)")
    local cpu_details = string.format(
        "CPU %d%%\nLoad  %s  %s  %s\nClick to open htop",
        cpu_usage,
        load_1 or "–",
        load_5 or "–",
        load_15 or "–"
    )
    local mem_details = string.format(
        "Memory %d%%\n%.1f GiB used  •  %.1f GiB available\n%.1f GiB total\nClick to open htop",
        mem_usage,
        mem_used / 1048576,
        mem_available / 1048576,
        mem_total / 1048576
    )

    local cpu_icon_color = cpu_usage > 90 and palette.red or palette.cyan
    local mem_icon_color = mem_usage > 90 and palette.red or palette.violet

    for _, view in ipairs(system_views) do
        view.cpu_icon:set_markup(string.format(
            "<span foreground='%s'></span>",
            cpu_icon_color
        ))
        view.cpu_value:set_markup(string.format("%d%%", cpu_usage))
        view.cpu_tooltip:set_text(cpu_details)

        view.mem_icon:set_markup(string.format(
            "<span foreground='%s'>󰍛</span>",
            mem_icon_color
        ))
        view.mem_value:set_markup(string.format("%d%%", mem_usage))
        view.mem_tooltip:set_text(mem_details)
    end
end

local function make_resource_capsule()
    local icon = wibox.widget {
        font = "InputMono Nerd Font 9",
        widget = wibox.widget.textbox,
    }
    local value = wibox.widget {
        text = "--%",
        font = "InputMono Nerd Font 9",
        widget = wibox.widget.textbox,
    }
    local contents = wibox.widget {
        icon,
        value,
        spacing = 6,
        layout = wibox.layout.fixed.horizontal,
    }

    return {
        icon = icon,
        value = value,
        container = make_module(contents, palette.surface, 9, 9),
    }
end

local function make_system_widgets()
    local cpu = make_resource_capsule()
    local memory = make_resource_capsule()
    local cpu_tooltip = awful.tooltip {
        objects = { cpu.container },
        text = "CPU data is loading…",
        delay_show = 0.25,
        bg = palette.surface,
        fg = palette.foreground,
        shape = gears.shape.rectangle,
    }
    local mem_tooltip = awful.tooltip {
        objects = { memory.container },
        text = "Memory data is loading…",
        delay_show = 0.25,
        bg = palette.surface,
        fg = palette.foreground,
        shape = gears.shape.rectangle,
    }
    local open_monitor = function()
        awful.spawn(terminal .. " -e htop")
    end

    cpu.container:buttons(gears.table.join(
        awful.button({}, 1, open_monitor)
    ))
    memory.container:buttons(gears.table.join(
        awful.button({}, 1, open_monitor)
    ))

    table.insert(system_views, {
        cpu_icon = cpu.icon,
        cpu_value = cpu.value,
        cpu_tooltip = cpu_tooltip,
        mem_icon = memory.icon,
        mem_value = memory.value,
        mem_tooltip = mem_tooltip,
    })

    if not system_timer then
        system_timer = gears.timer {
            timeout = 3,
            autostart = true,
            call_now = true,
            callback = update_system_stats,
        }
    end

    return cpu.container, memory.container
end

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function client_glyph(c)
    local identity = table.concat({
        c.class or "",
        c.instance or "",
        c.name or "",
    }, " "):lower()

    if identity:find("slack", 1, true) then
        return ""
    elseif identity:find("discord", 1, true) then
        return ""
    elseif identity:find("spotify", 1, true) then
        return ""
    elseif identity:find("firefox", 1, true) then
        return "󰈹"
    elseif identity:find("chrom", 1, true) or identity:find("edge", 1, true) then
        return ""
    elseif identity:find("nvim", 1, true) or identity:find("code", 1, true) then
        return ""
    elseif identity:find("wezterm", 1, true)
        or identity:find("alacritty", 1, true)
        or identity:find("kitty", 1, true) then
        return ""
    elseif identity:find("thunar", 1, true)
        or identity:find("nautilus", 1, true)
        or identity:find("dolphin", 1, true) then
        return ""
    elseif identity:find("claude", 1, true) then
        return "✦"
    end

    return ""
end

local function tag_client_summary(t)
    local clients = t:clients()
    local glyphs = {}
    local seen = {}

    for _, c in ipairs(clients) do
        local glyph = client_glyph(c)
        if not seen[glyph] and #glyphs < 2 then
            table.insert(glyphs, glyph)
            seen[glyph] = true
        end
    end

    local suffix = #clients > 1 and " ·" .. #clients or ""
    return table.concat(glyphs, " ") .. suffix, clients
end

local function tag_tooltip_text(t, clients)
    if #clients == 0 then
        return string.format("Workspace %s • empty", t.name)
    end

    local lines = {
        string.format(
            "Workspace %s • %d window%s",
            t.name,
            #clients,
            #clients == 1 and "" or "s"
        ),
    }
    for index, c in ipairs(clients) do
        if index > 6 then
            table.insert(lines, string.format("• …and %d more", #clients - 6))
            break
        end

        local title = (c.name or c.class or "Untitled"):gsub("[\r\n]+", " ")
        local class = c.class and "  [" .. c.class .. "]" or ""
        table.insert(lines, "• " .. title .. class)
    end
    return table.concat(lines, "\n")
end

local function update_tag_widget(self, t, index)
    local summary, clients = tag_client_summary(t)
    local number = self:get_children_by_id("number_role")[1]
    local number_color = t.urgent and palette.red
        or t.selected and palette.green
        or #clients > 0 and palette.foreground
        or palette.muted
    local underline = self:get_children_by_id("underline_role")[1]
    if underline then
        underline.color = t.urgent and palette.red
            or t.selected and palette.green
            or #clients > 0 and palette.foreground
            or palette.bar
    end

    number:set_markup(string.format(
        "<span foreground='%s'><b>%s</b></span>",
        number_color,
        gears.string.xml_escape(t.name or tostring(index))
    ))

    if self._tag_tooltip then
        self._tag_tooltip:set_text(tag_tooltip_text(t, clients))
    end
end

local tag_widget_template = {
    {
        {
            {
                {
                    id = "number_role",
                    font = "InputMono Nerd Font Bold 9",
                    widget = wibox.widget.textbox,
                },
                spacing = 5,
                layout = wibox.layout.fixed.horizontal,
            },
            id = "underline_role",
            bottom = 2,
            color = palette.bar,
            widget = wibox.container.margin,
        },
        left = 9,
        right = 9,
        top = 2,
        widget = wibox.container.margin,
    },
    id = "background_role",
    shape = gears.shape.rectangle,
    widget = wibox.container.background,
    create_callback = function(self, t, index)
        self._tag_tooltip = awful.tooltip {
            objects = { self },
            text = "Workspace " .. t.name,
            delay_show = 0.3,
            bg = palette.surface,
            fg = palette.foreground,
            shape = gears.shape.rectangle,
        }
        update_tag_widget(self, t, index)
    end,
    update_callback = update_tag_widget,
}

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table. Start every workspace in the regular
    -- tiled layout; the layout switcher can still reach all layouts above.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.suit.tile)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        style = {
            shape = gears.shape.rectangle,
            bg_focus = palette.bar,
            fg_focus = palette.green,
            bg_occupied = palette.bar,
            fg_occupied = palette.foreground,
            bg_empty = palette.bar,
            fg_empty = palette.muted,
            bg_urgent = palette.bar,
            fg_urgent = palette.red,
            shape_border_width = 0,
            shape_border_width_focus = 0,
        },
        layout = {
            spacing = 0,
            layout = wibox.layout.fixed.horizontal,
        },
        widget_template = tag_widget_template,
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style = {
            shape = gears.shape.rectangle,
            bg_normal = palette.bar,
            fg_normal = palette.foreground,
            bg_focus = palette.bar,
            fg_focus = palette.foreground,
            bg_minimize = palette.bar,
            fg_minimize = palette.secondary,
            shape_border_width = 0,
            shape_border_width_focus = 0,
        },
        layout = {
            spacing = 16,
            layout = wibox.layout.flex.horizontal,
        },
    }

    -- Create the wibox
    s.mywibox = awful.wibar {
        position = "top",
        screen = s,
        height = 30,
        bg = palette.bar,
        fg = palette.foreground,
        border_width = 0,
    }

    local keyboard_layout = awful.widget.keyboardlayout()
    local keyboard = make_module(
        make_labeled_widget("󰌌", keyboard_layout),
        palette.surface
    )
    local systray = wibox.widget.systray()
    systray:set_base_size(18)
    local tray = make_module(systray, palette.surface, 8, 8)
    tray:set_visible(s == screen.primary)
    local clock = make_module(
        wibox.widget.textclock(
            "<span font='InputMono Nerd Font 9' foreground='" .. palette.blue .. "'>󰥔 </span>" ..
            "<span font='InputMono Nerd Font 9' foreground='" .. palette.secondary .. "'>%a %d %b  </span>" ..
            "<span font='InputMono Nerd Font 9' foreground='" ..
                palette.foreground .. "'>%H:%M</span>"
        ),
        palette.surface
    )
    local layout = make_module(
        wibox.widget {
            s.mylayoutbox,
            top = 7,
            bottom = 7,
            widget = wibox.container.margin,
        },
        palette.surface,
        8,
        8
    )
    s.mycpuwidget, s.mymemorywidget = make_system_widgets()
    s.myweatherwidget = make_weather_widget()
    s.mybatterywidget = make_battery_widget()

    -- Add widgets to the wibox
    local hairline = function()
        return wibox.widget.separator {
            orientation = "vertical",
            thickness = 1,
            span_ratio = 0.5,
            color = palette.border,
            widget = wibox.widget.separator,
        }
    end
    s.mywibox:setup {
        {
        layout = wibox.layout.align.horizontal,
        {
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                spacing = 4,
                mylauncher,
                s.mytaglist,
                s.mypromptbox,
            },
            left = 8,
            top = 3,
            bottom = 3,
            widget = wibox.container.margin,
        },
        {
            s.mytasklist, -- Middle widget
            left = 10,
            right = 10,
            top = 3,
            bottom = 3,
            widget = wibox.container.margin,
        },
        {
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                spacing = 1,
                spacing_widget = hairline(),
                keyboard,
                tray,
                layout,
                s.mycpuwidget,
                s.mymemorywidget,
                clock,
                s.myweatherwidget,
                s.mybatterywidget,
            },
            right = 8,
            top = 3,
            bottom = 3,
            widget = wibox.container.margin,
        },
        },
        bottom = 1,
        color = "#e6e9ed",
        widget = wibox.container.margin,
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(

    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- Shrink default floating window size to 40% of screen
    if c.floating or (c.first_tag and c.first_tag.layout == awful.layout.suit.floating) then
        local sg = c.screen.geometry
        local w = math.floor(sg.width * 0.4)
        local h = math.floor(sg.height * 0.4)
        c:geometry({ width = w, height = h })
        awful.placement.centered(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
-- client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus 
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)
client.connect_signal("property::urgent", function(c)
    if c.urgent then
        awful.spawn({"/home/guy/dotfiles/bin/blip", "attn"}, false)
    end
end)
-- One cue per tag switch: the deselect of the old tag is ignored, and blip's
-- own rate limit swallows the extra event when several screens follow along.
tag.connect_signal("property::selected", function(t)
    if t.selected then
        awful.spawn({"/home/guy/dotfiles/bin/blip", "tag"}, false)
    end
end)
client.connect_signal("manage", function(c)
    if awesome.startup then return end
    awful.spawn({"/home/guy/dotfiles/bin/blip", "window"}, false)
end)
awesome.connect_signal("startup", function()
    awful.spawn({"/home/guy/dotfiles/bin/blip", "start"}, false)
end)
-- }}}

-- {{{ Autostart
awful.spawn.with_shell("xbindkeys")
awful.spawn({"/home/guy/dotfiles/bin/htop", "--daemon"}, false)
apply_keyboard_layout()
ensure_keyboard_layout()
-- }}}
