local E = require("entity_db")

local function T(t)
    return E:get_template(t)
end

local function vv(v1)
    return {
        x = v1,
        y = v1
    }
end

if KR_GAME == "kr1" then
    require("kr1.game_templates")
elseif KR_GAME == "kr2" then
    require("kr2.game_templates")
elseif KR_GAME == "kr3" then
    require("kr3.game_templates")
end

if not IS_KR5 then
    local scale_scale = 0.7
    T("editor_wave_flag").render.sprites[1].scale = vv(scale_scale)
    T("editor_wave_flag").render.sprites[2].scale = vv(scale_scale)
    T("editor_wave_flag").render.sprites[3].scale = vv(scale_scale)
    T("editor_rally_point").render.sprites[1].scale = vv(scale_scale)
    T("editor_rally_point").render.sprites[2].scale = vv(scale_scale)
    T("editor_rally_point").image_width = 180
end

