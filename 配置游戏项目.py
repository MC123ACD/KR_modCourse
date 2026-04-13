import traceback, subprocess, re
from pathlib import Path


input_path = Path("input")
output_path = Path("output")

def run_decompiler(file_path):
    print("🔧 反编译中请耐心等待")

    subprocess.run([
        "luajit-decompiler-v2.exe",
        file_path,
        "-s",
        "-f",
        "-o",
        "src"
    ], capture_output=True)

    print("🔧 反编译成功")

def reset_file(file_path, func):
    with open(file_path, "r", encoding="utf-8") as f:
        file = f.read()

    file = func(file)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(file)

def main():
    run_decompiler("src")
    src = Path("src")

    def reset_version(file):
        return file.replace("RELEASE", "DEBUG", 1)
    
    reset_file(src / "version.lua", reset_version)

    print("🔧 开启 DEBUG 模式")

    def reset_conf(file):
        return file.replace("t.console = true", "t.console = false", 1)
    
    reset_file(src / "conf.lua", reset_conf)

    print("🔧 关闭游戏自带控制台")

    def reset_main(file):
        new_text = """\tif LLDEBUGGER then
		LLDEBUGGER.start()
	end

    while true do
        love.event.pump()"""

        return file.replace("""\twhile true do
\t\tlove.event.pump()""", new_text, 1)

    reset_file(src / "main.lua", reset_main)

    print("🔧 开启报错自动断点")

    def reset_sys(file):
        return file.replace("error ~= nil", "not success")
    
    reset_file(src / "all" / "systems.lua", reset_sys)

    print("🔧 修复调试 Bug")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        traceback.print_exc()

    input("程序运行完毕, 按回车键退出> ")