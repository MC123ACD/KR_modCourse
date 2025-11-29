-- 启动参数
local r = {
    log_level = 5, -- 日志等级 5：调试控制台显示完整信息
    -- screen = "slots",   -- 跳过开屏 logo，与开局设置

    -- screen = "game_editor", -- 进入关卡编辑器
    -- custom = 1,  -- 要编辑的关卡
}

if arg[2] == "debug" then
    LLDEBUGGER = require("lldebugger")
    LLDEBUGGER.start()
end

require("main_globals")
local features = require("features")

if KR_GAME ~= "kr5" then
    features.platform_services = nil -- 关闭验证
else
    local success, err = pcall(require, "platform_services_steam")
    if success then
        local PS = require("platform_services_steam")

        local o = PS.get_dlcs
        PS.get_dlcs = function(self, owned)
            local t = o(self, owned)

            for _, dlc in pairs(PS.dlcs) do
                table.insert(t, dlc.id)
            end

            return t
        end

        local PSU = require("platform_services_utils")

        function PSU:get_library_path()
            if love.filesystem.isFused() then
                return ""
            else
                local osname = love.system.getOS()
                local path = love.filesystem.getSourceBaseDirectory() .. "/platform/bin"

                if osname == "Windows" then
                    return ""
                elseif osname == "OS X" then
                    return string.format("%s/macOS", path)
                elseif osname == "iOS" then
                    return string.format("%s/iOS", path)
                elseif osname == "Linux" or osname == "Android" then
                    return string.format("%s/%s", path, osname)
                else
                    return name
                end
            end
        end

        function PSU:get_library_file(name)
            local osname = love.system.getOS()

            if love.filesystem.isFused() then
                if osname == "Windows" then
                    return name .. ".dll"
                else
                    return name
                end
            else
                local path = self:get_library_path()

                if osname == "Windows" then
                    return name .. ".dll"
                elseif osname == "OS X" then
                    return string.format("%s/lib%s.dylib", path, name)
                elseif osname == "iOS" then
                    return string.format("%s/lib%s.a", path, name)
                elseif osname == "Linux" or osname == "Android" then
                    return string.format("%s/lib%s.so", path, name)
                else
                    return name
                end
            end
        end
        
        local services = require("platform_services")

        function services.update()
            return true
        end
    end
end

-- 按 0 手动断点
local l_kp = love.keypressed
function love.keypressed(key, scancode, isrepeat)
    l_kp(key, scancode, isrepeat)
    if key == "0" then
        if LLDEBUGGER then
            LLDEBUGGER.start()
        end
    end
end

local result = {}
for key, value in pairs(r) do
    table.insert(result, "-" .. key)
    if value then
        table.insert(result, value)
    end
end

return result

