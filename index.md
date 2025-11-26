
| ![[Pasted image 20250803100142.png\|700]] | ![[Pasted image 20250803100333.png\|700]] |
| ----------------------------------------- | ----------------------------------------- |
> 相关链接：
> [本文档 Github 仓库](https://github.com/MC123ACD/KR_modCourse)
> [中文维基](https://kingdomrush.huijiwiki.com/p/1)
> [中文百科全集](https://www.bilibili.com/read/readlist/rl141527)

# 导言
**本文档适用于电脑版**的**一、二、三、五代**，请注意版本（安卓版部分可用）
由于本人正处于学习阶段，所以错误在所难免，欢迎提出意见，以及提 request

**本文档将默认您已了解并掌握 Lua 编程语言与 Love2d**
如未了解请先观看以下教程：
> 观看大约需要 3-4 小时
> 1. [Lua教程-入门—哔哩哔哩](https://www.bilibili.com/video/BV1vf4y1L7Rb/)
> 2. [Lua教程-进阶—哔哩哔哩](https://www.bilibili.com/video/BV1WR4y1E7ud/)
> 3. [Love2d-教程](https://blog.csdn.net/qq_44918090/category_11757733.html)

注：本教程主要以总结为目的，所以教程都是重要知识点，其他修改方法类比一下即可

如有疑问建议先问 AI 再向他人寻求帮助

# 说明
本文档使用伪代码类型注解：

| 类型注解    | <center>说明</center>            |
| ------- | ------------------------------ |
| `float` | 小数（浮点）                         |
| `int`   | 整数（整形）                         |
| `num`   | 小数与整数                          |
| `str`   | 字符串 `"abc"`                    |
| `table` | 表 `table{ num, str }`          |
| `func`  | 函数                             |
| `vec2`  | 二维向量 `table{ x: num， y: num }` |
| `...`   | 不定参数                           |
| `->`    | 返回值，返回 `nil` 时省略               |
| \|      | 或                              |
| `?`     | 选填项                            |

# 免责声明
本文档可能具有编写错误导致的误导性内容请仔细甄别

**<font color="#ff0000">该文档仅限学习交流，禁止用于商业用途</font>**
除商业用途之外可随意分发

**<font color="#ff0000">请购买正版游戏后再进行修改。若修改盗版出现任何问题，均与作者以及文档无关</font>**
