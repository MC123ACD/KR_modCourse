## Visual Studio Code 的本地 Lua 调试器
一个简单的 Lua 调试器，无需额外依赖。

### 重大变更通知
从 0.3.0 版本开始，对于使用 Sourcemap 来调试从其他语言（例如 TypescriptToLua）转译而来的代码的项目，必须在启动配置中指定 `scriptFiles` 选项，才能在原始源文件中使用断点。这允许在启动时（而非运行时）解析这些文件，从而显著提高性能。

### 功能特性
*   使用独立解释器或自定义可执行文件调试 Lua
*   支持 Lua 5.1、5.2、5.3 版本以及 LuaJIT
*   基本调试功能（单步执行、检查变量、断点等）
*   条件断点
*   将协程作为独立线程进行调试
*   对 Source map 的基础支持（例如由 TypescriptToLua 生成的）

### 使用方法
#### Lua 独立解释器
要使用独立解释器调试 Lua 程序，请在用户或工作区设置中设置 `lua-local.interpreter`：

`"lua-local.interpreter": "lua5.1"`

或者，您也可以在 `launch.json` 中设置解释器和要运行的文件：

```json
{
    "configurations": [
        {
            "type": "lua-local",
            "request": "launch",
            "name": "Debug",
            "program": {
                "lua": "lua5.1",
                "file": "main.lua"
            }
        }
    ]
}
```

#### 自定义 Lua 环境
要使用自定义的 Lua 可执行文件进行调试，您必须在 `launch.json` 中设置可执行文件的名称/路径以及任何可能需要的额外参数。

```json
{
    "configurations": [
        {
            "type": "lua-local",
            "request": "launch",
            "name": "Debug Custom Executable",
            "program": {
                "command": "executable"
            },
            "args": [
                "${workspaceFolder}"
            ]
        }
    ]
}
```

然后您必须在您的 Lua 代码中手动启动调试器：

`require("lldebugger").start()`

请注意，`lldebugger` 的路径将自动附加到 `LUA_PATH` 环境变量中，因此 Lua 能够找到它。

### 要求与限制
*   Lua 环境必须支持通过 stdio 或管道进行通信（Windows 上为命名管道，Linux 上为 fifo）。
*   某些环境可能需要命令行选项来支持 stdio 通信（例如 Solar2D 需要 `/no-console` 标志）。
*   在 stdio 模式下，使用 `io.read` 或其他需要用户输入的函数调用会导致问题。可将 `program.communication` 设置为 `pipe` 来解决此问题。
*   Lua 环境必须内置 debug 库，且没有其他代码尝试设置调试钩子。
*   当程序正在运行时，您不能手动暂停调试。
*   在 Lua 5.1 和 LuaJIT 中，当在协程内部暂停时，无法访问主线程。

### 使用技巧
*   为了方便起见，调试器的全局引用始终以 `lldebugger` 的形式存储。
*   您可以通过检查环境变量 `LOCAL_LUA_DEBUGGER_VSCODE` 来检测调试器扩展是否已附加。这对于在自定义环境中条件性地启动调试器非常有用。
```lua
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end
```
*   某些自定义环境不会在未捕获的运行时错误时中断。要捕获运行时错误，您可以使用 `lldebugger.call()` 包装代码：
```lua
lldebugger.call(function()
  -- 引发运行时错误的代码
end)
```
*   某些环境不会从标准文件系统加载所需的文件。在这种情况下，您可以使用存储在 `LOCAL_LUA_DEBUGGER_FILEPATH` 中的文件路径手动加载调试器：
```lua
package.loaded["lldebugger"] = assert(loadfile(os.getenv("LOCAL_LUA_DEBUGGER_FILEPATH")))()
require("lldebugger").start()
```

### 其他配置选项
#### `scriptRoots`
一个备用路径列表，用于查找 Lua 脚本。这对于像 LÖVE 这样的环境非常有用，它们使用自定义解析器来查找位于 `package.config` 指定路径之外的其他位置的脚本。

#### `scriptFiles`
一个 glob 模式列表，用于标识调试时在工作区中查找 Lua 脚本的位置。对于在 sourcemap 映射的文件（例如使用 TypescriptToLua 时的 'ts' 脚本）中放置断点是必需的，因为必须提前查找源文件以便解析断点。

示例：`scriptFiles: ["**/*.lua"]`

#### `ignorePatterns`
一个 Lua 模式列表，指定单步执行代码时要跳过的文件。

示例：`ignorePatterns: ["^/usr"]`

#### `stepUnmappedLines`
在单步执行 sourcemap 映射的代码且当前行没有可用映射时，单步进入 Lua 代码。

#### `breakInCoroutines`
当协程内部发生错误时中断进入调试器。
*   用 `coroutine.wrap` 创建的协程将始终中断，无论此选项如何设置。
*   在 Lua 5.1 中，中断将发生在协程被恢复的位置，并且消息将包含错误发生的实际位置。

#### `stopOnEntry`
在设置调试钩子后，自动在首行中断。

#### `cwd`
指定启动可执行文件时的工作目录。默认为项目目录。

#### `args`
启动时传递给 Lua 脚本或自定义环境的参数列表。

#### `env`
指定启动可执行文件时要设置的环境变量。

#### `program.communication`
指定扩展程序与调试器通信的方式。

可能的值：
*   `stdio` （默认）：消息嵌入在 stdin 和 stdout 中。
*   `pipe`：创建管道来传递消息（Windows 上为命名管道，Linux 上为 fifo）。如果您的环境在使用 stdio 通信时出现问题，请使用此方式。

#### `verbose`
启用调试器的详细输出。仅在尝试识别调试器本身的问题时有用。

### 自定义环境示例
#### LÖVE
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug Love",
            "type": "lua-local",
            "request": "launch",
            "program": {
                "command": "love"
            },
            "args": [
                "game"
            ],
            "scriptRoots": [
                "game"
            ]
        }
    ]
}
```

```lua
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

function love.load()
  ...
```
请注意，在 `conf.lua` 中 `console` 必须设置为 false（默认值），否则调试器将无法与运行中的程序通信。

`game/conf.lua`
```lua
function love.conf(t)
  t.console = false
end
```

#### Busted
请注意，即使通过 Lua 解释器使用 busted，也必须将其设置为自定义环境才能正常工作。

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug Busted CLI",
            "type": "lua-local",
            "request": "launch",
            "program": {
                "command": "busted"
            },
            "args": [
                "test/start-cli.lua"
            ],
            "ignorePatterns": "^/usr"
        },
        {
            "name": "Debug Busted via Lua Interpreter",
            "type": "lua-local",
            "request": "launch",
            "program": {
                "command": "lua"
            },
            "args": [
                "test/start-interpreter.lua"
            ],
            "ignorePatterns": "^/usr"
        }
    ]
}
```
`test/start-cli.lua`
```lua
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

describe("a test", function()
  ...
end)
```
`test/start-interpreter.lua`
```lua
-- 应在挂钩调试器之前引入 busted，以避免双重挂钩
require("busted.runner")()

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

describe("a test", function()
  ...
end)
```

#### Defold
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug",
            "type": "lua-local",
            "request": "launch",
            "program": {
                "command": "dmengine"
            },
            "args": [
                "./build/default/game.projectc"
            ],
            "scriptRoots": [
                "."
            ] // 调试器查找脚本所必需
        }
    ]
}
```

```lua
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  local lldebugger = loadfile(os.getenv("LOCAL_LUA_DEBUGGER_FILEPATH"))()
  lldebugger.start()
end

function init(self)
  ...
end
```
有关为您的平台下载 `dmengine` 的信息可以在[这里](Information on downloading dmengine for your platform can be found here.)找到。

#### Solar2D / Corona
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug",
            "type": "lua-local",
            "request": "launch",
            "windows": {
                "program": {
                    "command": "C:\\Program Files (x86)\\Corona Labs\\Corona\\Corona Simulator.exe",
                },
                "args": [
                    "/no-console",
                    "/debug",
                    "${workspaceFolder}\\main.lua"
                ]
            },
            "osx": {
                "program": {
                    "command": "/Applications/Corona/CoronaSimulator.app/Contents/MacOS/CoronaSimulator",
                },
                "args": [
                    "-no-console""YES""-debug""1""-project""${workspaceFolder}/main.lua"
                ]
            }
        }
    ]
}
```

```lua
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  local lldebugger = loadfile(os.getenv("LOCAL_LUA_DEBUGGER_FILEPATH"))()
  lldebugger.start()
end

...
```

#### TypescriptToLua（自定义环境）
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug TSTL",
            "type": "lua-local",
            "request": "launch",
            "program": {
                "command": "my_custom_environment"
            },
            "args": [
        ...
            ],
            "scriptFiles": [
                "**/*.lua"
            ] // 使 ts 文件中的断点正常工作所必需
        }
    ]
}
```

```lua
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

...
```
`tsconfig.json`
```json
{
    "compilerOptions": {
        "sourceMap": true,
    ...
    },
    "tstl": {
        "noResolvePaths": [
            "lldebugger"
        ] // 必需，以便 TSTL 忽略缺失的依赖项
    }
}
```