if arg[2] == "debug" then
    require("lldebugger").start()
end

require("main_globals")
local features = require("features")

if KR_GAME ~= "kr5" then
    features.platform_services = nil -- 关闭验证
else
    local PS = require("platform_services_steam")

    local o = PS.get_dlcs
    PS.get_dlcs = function(self, owned)
        local t = o(self, owned)

        for _, dlc in pairs(PS.dlcs) do
            table.insert(t, dlc.id)
        end

        return t
    end
end

-- 按 0 手动断点
local l_kp = love.keypressed
function love.keypressed(key, scancode, isrepeat)
    l_kp(key, scancode, isrepeat)
    if key == "0" then
        print("Break-point")    --断点打这里
	end
end

-- 启动参数
local r = {
    log_level = 5,  -- 日志等级 5：调试控制台显示完整信息
    -- screen = "slots",   -- 跳过开屏 logo，与开局设置

    -- screen = "game_editor", -- 进入关卡编辑器
    -- custom = 1,  -- 要编辑的关卡
}

local result = {}
for key, value in pairs(r) do
    table.insert(result, "-" .. key)
    if value then
        table.insert(result, value)
    end
end

return result

