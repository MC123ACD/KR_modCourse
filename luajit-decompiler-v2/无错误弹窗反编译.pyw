import os
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

class LuaJITDecompiler:
    def __init__(self, root):
        self.root = root
        self.root.title("无错误弹窗反编译文件夹")
        self.root.geometry("400x150")
        
        # 自动查找同目录下的反编译器
        self.decompiler_path = self.find_decompiler()
        
        if not self.decompiler_path:
            messagebox.showerror("错误", "未找到 luajit-decompiler-v2.exe")
            root.destroy()
            return
        
        # 创建UI
        ttk.Label(root, text="选择包含LuaJIT字节码的文件夹:").pack(pady=10)
        
        self.folder_entry = ttk.Entry(root, width=40)
        self.folder_entry.pack()
        
        ttk.Frame(root, height=10).pack()  # 空白间隔
        
        btn_frame = ttk.Frame(root)
        btn_frame.pack()
        
        ttk.Button(btn_frame, text="浏览...", command=self.browse_folder).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="开始反编译", command=self.run_decompiler).pack(side=tk.LEFT, padx=5)
    
    def find_decompiler(self):
        # 在当前目录查找反编译器
        for file in os.listdir():
            if file.lower() == "luajit-decompiler-v2.exe":
                return os.path.abspath(file)
        return None
    
    def browse_folder(self):
        folder = filedialog.askdirectory(title="选择包含LuaJIT字节码的文件夹")
        if folder:
            self.folder_entry.delete(0, tk.END)
            self.folder_entry.insert(0, folder)
    
    def run_decompiler(self):
        target_folder = self.folder_entry.get()
        
        if not target_folder or not os.path.isdir(target_folder):
            messagebox.showerror("错误", "请选择有效的文件夹")
            return
        
        try:
            subprocess.run([
                self.decompiler_path,
                target_folder,
                "-e", ".lua",  # 只反编译.lua文件
                "-s"    # 禁用错误窗口
            ], creationflags=subprocess.CREATE_NO_WINDOW)
            messagebox.showinfo("完成", "反编译完毕")
        except Exception as e:
            messagebox.showerror("错误", f"无法进行反编译: {str(e)}")

if __name__ == "__main__":
    root = tk.Tk()
    # 使用ttk样式
    style = ttk.Style()
    style.configure("TButton", padding=6)
    style.configure("TEntry", padding=5)
    
    app = LuaJITDecompiler(root)
    root.mainloop()