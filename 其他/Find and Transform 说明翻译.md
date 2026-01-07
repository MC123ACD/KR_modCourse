
## 亮点

**v5.1.0 新增功能**：现在可以在同一个参数中多次使用 `${getInput}`。示例：
* `"find": "const ${getInput} = \\U${getInput}",` // 弹出两个输入提示框，将第二个输入的内容大写
* `"find": "$${ return ${getInput} * 3; }$$ $${ return ${getInput} * 4;} $$",`

* `"find": "(${CLIPBOARD}) (${selectedText})",`
* `"replace": "${1:+ ${getInput}} ${2:+ ${getInput}}"`
  // 注意：替换会针对每个匹配项单独运行，因此 **每个替换都会弹出两次提示**

**v5.0.0 新增功能**：`${getInput}` 现在可以在许多选项中使用——包括在 `$${ jsOperation }$$` 内部——并且新增了变量 `${/}`（表示路径分隔符）。现在也可以在 `find` 参数中使用 `$${ jsOperation }$$`。

**v4.8 新增功能**：`preserveSelections` 参数，以任何方式不移动光标或更改现有选择的位置。

**v4.7 新增功能**：`runWhen` 和 `ignoreWhiteSpace` 参数，`"restrictFind": "matchAroundCursor"` 选项以及 `"find": "${getFindInput}"` 变量。

**已弃用的选项**：`${getFindInput}` 正被 `${getInput}` 取代，因为现在它也可以在 `replace`、`run`、`postCommands`、`cursorMoveSelect`、`filesToInclude` 或 `filesToExclude` 值中使用，而不仅仅是 `find` 值。在 v5.0.0 中，两者都将继续工作，但只会为 `${getInput}` 提供智能感知补全。

**已弃用的选项**：`once` 作为 `restrictFind` 参数的值。它正被 `onceExcludeCurrentWord` 取代（其功能与 `once` 完全相同），以及 `onceIncludeCurrentWord`（其工作方式略有不同）。更多详情请参见下方 `once` restrictFind 值部分。

*   在单个文件中查找和转换文本，支持多种类型的转换。
*   使用预定义选项跨文件搜索。
*   在当前文件中执行一系列查找和替换。
*   跨文件执行一系列查找和一个替换，仅使用先前搜索的结果文件。参见[跨文件多次搜索](#)。
*   在替换项上执行 JavaScript 代码，如数学或字符串操作。
*   执行独立的 JavaScript 代码以产生副作用，参见下方示例。
*   在替换中使用 vscode API 或 node 包，如 `path`、`os`、`fs` 等。
*   支持在搜索面板或当前文件的查找中使用路径或片段变量。
*   替换可以包括大小写修饰符（如 `\U`）、条件语句（例如，如果找到捕获组 1 则添加其他文本）、类似片段的转换（如 `${1:/pascalcase}`）等。
*   保存命名的设置或键盘绑定，用于查找或搜索。
*   替换一些文本后，可以选择使用 `cursorMoveSelect` 将光标移动到下一个指定位置。
*   所有 `findInCurrentFile` 命令都可以用在 `"editor.codeActionsOnSave": []` 中。参见[在保存时运行命令](#)。
*   在光标处插入任何已解析的值，例如 JavaScript 数学或字符串操作。无需查找。
*   **我可以在 find 中放入编号的捕获组，例如 `$1` 吗？** 参见[使用光标进行简单查找](#)。
*   使用 `${getDocumentText}` 和 `${getTextLines:n}` 获取文档中任意位置的文本，用于替换项。
*   `${getInput}`：`"${getInput}"` 将触发一个输入框，用于输入查找查询、替换、`run`、`postCommands`、`cursorMoveSelect`、`filesToInclude` 和 `filesToExclude` 的文本，您可以输入字符串或正则表达式。甚至在 js 操作内部也可以。

下方您将找到关于使用 `findInCurrentFile` 命令的信息——该命令在当前文件中执行查找，类似于使用查找小部件，但能够将这些查找/替换保存为设置或键盘绑定，并支持更多变量和 JavaScript 操作。这里的一些信息对使用 `runInSearchPanel` 也很有用——因此您应该同时阅读两者。参见[使用面板搜索](#)。

## 目录
1.  preCommands 和 postCommands
2.  enableWarningDialog 设置
3.  使用换行符
4.  findInCurrentFile 参数
5.  在 find 中使用编号的捕获组
6.  如何在光标处插入值
7.  运行多次查找或替换
8.  在替换中运行 JavaScript 代码
    a. 替换中的数学运算
    b. 替换中的字符串操作
    c. 在替换中使用 vscode API 或其他包（如 path）
    d. 替换中的更多操作
9.  将 JavaScript 代码作为副作用运行
10. 特殊变量
    a. 路径变量：类似 Launch 或 Task 的变量
    b. 片段变量：类似 Snippet 的变量
    c. 大小写修饰符：`\\U$1`
    d. 条件替换：`${1:+add this text}`
    e. 片段转换：`${3:/capitalize}`
    f. 变量转换的更多示例
11. 将 restrictFind 与 matchAroundCursor 选项结合使用
12. 使用 restrictFind 和 cursorMoveSelect
    a. 一些 `"restrictFind": "next...` 选项示例
13. 设置示例
14. 键盘绑定示例
    a. lineNumber 和 lineIndex
    b. 光标处的最近单词
    c. 简单的查找和替换
    d. restrictFind: selections
    e. 有 find 参数但没有 replace
        i. 有 find，无 replace，restrictFind: selections
    f. 没有 find 参数但有 replace
15. 演示替换后的 cursorMoveSelect
16. matchNumber 和 matchIndex
17. reveal 选项
18. ignoreWhiteSpace 选项
19. preserveSelections 选项

## preCommands 和 postCommands

```json
{
  "key": "alt+r", // 您想要的任意键盘绑定
  "command": "findInCurrentFile",
  "args": {
    "preCommands": [ // 在查找/替换之前运行
      "cursorHome", // 将光标移动到文本开头
      {
        "command": "type", // 在光标处插入 "howdy "
        "args": {
          "text": "howdy " // 与键盘绑定具有相同的参数
        }
      },
      "cursorEndSelect" // 从光标处选择到行尾
    ],
    // ... 其他选项，如 find/replace 等
    // 您可以在 preCommands 中“查找”可能已插入的文本
    "postCommands": "editor.action.insertCursorAtEndOfEachLineSelected",
    "runPostCommands": "onceIfAMatch/onceOnNoMatches/onEveryMatch" // 默认是 "onceIfAMatch"
  }
}
```

以上是 `preCommands` 和 `postCommands` 参数的示例。

`preCommands` 在任何查找或替换发生之前运行。它可以是单个字符串、一个对象或字符串/对象的数组。`preCommands` 和 `postCommands` 参数可以出现在参数的任何位置。所有参数可以按任意顺序排列。

`postCommands` 在查找和任何替换发生后运行。`runPostCommands` 参数控制如何运行 `postCommands`：无论有多少查找匹配都只运行一次（这是默认值），仅在没有任何查找匹配时运行一次，或者为每个查找匹配运行一次 `postCommands` ——最后一个选项目前是**实验性的**，并非在所有可能的情况下都有效。

使用从 vscode 的键盘快捷键上下文菜单和"复制命令 ID"中获得的命令——与您在键盘绑定中使用的命令 ID 相同。每个命令的参数也是如此——参见上面的 `type` 示例。

`preCommands` 特别有用，当您想在执行其他操作之前将光标移动到不同的单词或插入点（例如将光标移动到行首然后插入某些内容）时。

例如，某些替换在首先选择当前行时更容易进行。这样，替换发生时将替换整行。否则，您必须先选择该行，然后运行键盘绑定。以下示例仅在首先选择了当前行时才有效。

在下面的示例中没有 `find` 参数。正如您将了解到的，在这种情况下，此扩展将从光标处的当前单词或当前选择生成查找。它也可以为多个光标执行此操作。

还要注意，在演示中，由于 `postCommand`，光标被放置在所有行的末尾。下面显示了演示中使用的键盘绑定。替换相当复杂——它是一个小的 JavaScript 代码，可以执行许多操作以创建复杂的替换。稍后将详细介绍 JavaScript 操作。

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "preCommands": [ // 选择有光标的整行
      "cursorHome",
      "cursorEndSelect"
    ],
    "postCommands": "editor.action.insertCursorAtEndOfEachLineSelected",
    "replace": [
      "$${", // 运行这些数学和字符串操作以创建替换
      "const ch = '/';",
      "const spacer = 3;", // 中间文本周围的空格
      "const textLength = '${TM_CURRENT_LINE}'.length;",
      "const isOdd = textLength % 2;",
      "const surround = Math.floor((80 - (2 * spacer) - textLength) / 2);",
      "let result = ch.padEnd(80, ch) + '\\n';",
      "result += ch.padEnd(surround, ch) + ''.padEnd(spacer, ' ');",
      "result += '${TM_CURRENT_LINE}'.padEnd(textLength + spacer, ' ') + ch.padEnd(surround, ch);",
      "if (isOdd) result += ch;", // 如果 textLength 是奇数则添加一个
      "result += '\\n' + ch.padEnd(80, ch);",
      "return result;",
      "}$$"
    ],
    "isRegex": true,
    "restrictFind": "line" // 仅在包含光标的行或行上运行
  }
}
```

[围绕所选文本填充]

### 贡献的设置

此扩展贡献了一个与 `findInCurrentFile` 设置和键盘绑定相关的设置：

*   `"find-and-transform.enableWarningDialog"` 默认值 = `true`

此设置控制扩展是否尝试在您的键盘绑定或设置参数键或值中查找错误。

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "find": "trouble",
    "replace": "howdy",
    "isRegex2": true, // 错误，没有 "isRegex2" 键，应该是 "isRegex"
    "restrictFind": "twice", // 错误，不允许 "restrictFind" 使用此值
    "matchCase": "true", // 错误，应该是布尔值而不是字符串
    "matchCase": true // 正确
  }
}
```

[启用警告对话框设置]

如果 `enableWarningDialog` 设置为 `true`，则在尝试运行键盘绑定、设置命令或在保存设置时如果有错误的参数，将在通知消息中显示错误。但并非所有错误都能被检测到，因此不要仅仅依赖于此。

键盘绑定的对话框是模态的，而设置的对话框是非模态的。然后可以运行或中止命令。

### 使用换行符

*   **查找**：使用 `\r?\n` 并将 `isRegex` 设置为 `true` 可能是跨操作系统最安全的方式。但在正则表达式字符类 `[...]` 中，只需使用 `[\n]`，而不是 `[\r?\n]`。
*   在 Windows 中，`[\n]` 将被替换为 `[\r\n]`，而 `\n`（不在字符类中）将被替换为 `\r?\n`。因此您可以使用 `\n` 来查找换行符。
*   **查找**：`\n` 和 `\\n` 应该作用相同。
*   **替换**：`\n` 可能就足够了，如果不行，在 Windows 中尝试 `\r\n`。
*   在 JavaScript 操作替换中，确保将其包含在反引号中，以便换行符被解释为字符串 `$${ ` 第一行 \n 第二行 ` }$$`。
*   如果您使用可能包含换行符的变量，如 `${getDocumentText}`，请用反引号包围该变量，如下例所示：

    ```json
    "replace": [
      "$${",
      "const previousLines = `${getTextLines:0-2}`;", // 或
      "return `${getDocumentText}`.toLocaleUpperCase();",
      "}$$"
    ]
    ```

以下形式适用于 jsOperation 替换或运行中的换行符：

*   `\\n` 在反引号内
*   `\n` 在反引号内
*   `'\\n'` 在单引号内，双重转义
*   `'\n'` （在单引号内）在 `"replace": "$${ jsOperation }$$"` 或 `"run": "$${ jsOperation }$$"` 中**不起作用**（但在简单替换中可以）。这是因为在 jsOperation 中，除非它在反引号中，否则 `\n` 需要双重转义。

```json
// 简单替换，即没有 $${ some jsOp }$$
// 仅使用单个转义的 \n 和 \t
"replace": "seed\nhow\ndy more\t\t\ttstuff",
```

有效和无效的换行符示例：

```json
"replace": "howdy\nthere", // 有效，简单替换

"replace": "$${return 'first line \n second line'; }$$", // \n 在 jsOp 中用单引号包围无效
"replace": "$${return 'first line \\n second line'; }$$", // \\n 用单引号包围有效
"replace": "$${return `first line \n second line`; }$$", // \n 用反引号包围有效
"replace": "$${return `first line \\n second line`; }$$", // \\n 用反引号包围有效
```

如果涉及换行符或制表符 `\t`，或者已解析的变量可能包含换行符或制表符，我建议在可能的情况下使用反引号。

如果您在替换中使用换行符，`cursorMoveSelect` 选项将尝试正确计算新的选择位置。这很棘手，特别是在替换后添加了换行符的选择（s）的末尾处——而之前没有换行符。

### findInCurrentFile 设置或键盘绑定可以使用哪些参数？

这些都在其他地方有更详细的讨论。

```json
{ // 在 keybindings.json 中
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "description": "一些字符串", // 仅用于您的信息，无功能

    "find": "(trouble)", // 可以是纯文本、正则表达式或特殊变量

    "preserveSelections": true, // 保持所有光标位置和选择不变，下文讨论

    "ignoreWhiteSpace": true, // 默认值 = false，使查找能够跨换行符和其他空白工作

    "replace": "\\U$1", // 文本、变量、条件、大小写修饰符、操作等

    "replace": "$${ someOperation }$$",

    "replace": [ // 运行代码，包括 vscode 扩展 API
      "$${", // 并使用结果进行替换
      "operation;", // 在光标处插入或替换选择
      "operation;",
      "operation;",
      "return result;",
      "}$$"
    ],

    "run": [ // 运行代码，包括 vscode 扩展 API
      "$${", // 但不使用结果进行替换
      "operation;",
      "operation;",
      "operation;",
      "}$$"
    ],

    "runWhen": "onceIfAMatch", // 默认，无论有多少匹配项，只触发一次 "run" 操作
    "runWhen": "onEveryMatch", // 为每个成功的查找匹配触发 "run" 操作
    "runWhen": "onceOnNoMatches", // 仅在没有任何查找匹配时触发 "run" 操作

    "isRegex": true, // 布尔值，将同时应用于 'cursorMoveSelect' 和查找查询
    "matchWholeWord": true, // 布尔值，同上
    "matchCase": true, // 布尔值，同上
    "restrictFind": "selections", // 将查找限制在文档、选择、行、once... 在行或下一个

    "reveal": "first/next/last", // 默认不显示

    "cursorMoveSelect": "^\\s*pa[rn]am" // 替换后选择此文本/正则表达式
  }
}
```

```json
"findInCurrentFile": { // 在 settings.json 中
  "upcaseSelectedKeywords": {
    "description": "一些字符串", // 仅用于您的信息，无功能

    "title": "Uppercase Selected Keywords", // 用于命令面板，必需

    "find": "(Hello) (World)",
    "replace": "\\U$1--${2:-WORLD}", // 条件，如果没有捕获组 2，添加 "WORLD"

    "isRegex": true, // 默认值 = false
    "matchCase": false, // 默认值 = false
    "matchWholeWord": true, // 默认值 = false
    "restrictFind": "selections", // 默认值 = document

    "cursorMoveSelect": "Select me"
  }
}
```

注意：`preserveCase` 选项尚不支持。

**默认值**：如果您未指定参数，则将应用其默认值。因此 `"matchCase": false` 与根本没有 `"matchCase"` 参数相同。

**重要提示**：此扩展将对 `findInCurrentFile` 和 `runInSearchPanel` 命令进行一些错误的参数键和值的检查。例如，如果您使用了 `"restrictFind": "selection"`（而不是正确的 `"restrictFind": "selections"`）或 `"matchCases": false`（应该是 `"matchCase": false`）——将会向输出（在下拉菜单 `find-and-transform` 选项下）打印错误消息，通知您错误，并且当前命令将被中止，不执行任何操作。因此，任何错误的参数选项都将停止执行，不会执行任何操作。

### 在 find 中使用编号的捕获组

示例：`"find": "\\$1(\\d+)"`

任何编号的捕获组，例如上面双重转义的 `\\$1`，将被当前文件中的第一个选择替换（`\\$2` 将被第二个选择替换，依此类推）。通过这种方式，您可以轻松地创建通用的查找正则表达式，这些表达式由您的选择决定，而不是先进行硬编码。替换这些之后，运行查找。

a. 这适用于文件中的查找或跨文件搜索、键盘绑定或设置。
b. 第一个选择（可以只是单词中的光标）实际上是文件中**第一个**被做出的选择——它可能实际出现在第二个选择之前或之后！
c. 选择可以是单词或更长的文本部分。
d. 如果您使用的编号捕获组高于选择的数量，这些捕获组将被替换为 `""`，即空字符串。

```json
{
  "key": "alt+r", // 作为 keybindings.json 中的键盘绑定
  "command": "findInCurrentFile", // 或 "runInSearchPanel" 以跨文件搜索
  "args": {
    "find": "\\$1(\\d+)", // 需要双重转义
    // "find": "(\\$1|\\$2)-${lineNumber}", // 组 1 或组 2 后跟其行号
    // "find": "\\$1(\\d+)\\$2", // 最多 9 个捕获组
    // "replace": "", // 如果没有 replace，匹配项将被高亮显示
    // "isRegex": true 如果 find 的其他部分使用正则表达式，如 \\d 等，则是必需的
    "isRegex": true // 对于 \\$n's + 其他纯文本则不需要
  }
}
```

```json
{
  "key": "alt+b",
  "command": "runInSearchPanel", // 使用搜索面板
  "args": {
    "find": "\\$1\\.decode\\([^)]+\\)",
    "triggerSearch": true
    // "replace": "?????", // 不需要
    // "filesToInclude": "${relativeFileDirname} 或其他路径变量",
    // "filesToExclude": "<其他路径变量>",
    // "onlyOpenEditors": true
    // 其他选项：matchCase/matchWholeWord/preserveCase/useExcludeSettingsAndIgnoreFiles
  }
}
```

将其设为设置：

```json
"findInCurrentFile": { // 在 settings.json 或 .code-workspace 文件（在其设置对象中）中
  "findRequireDecodeReferences": {
    "title": "Find in file: package function references",
    "find": "\\$1\\.decode\\([^)]+\\)",
    "isRegex": true
  }
}
```

```json
"runInSearchPanel": {
  "searchRequireDecodeReferences": {
    "title": "Search files: package function references",
    // "preCommands": "editor.action.clipboardCopyAction",
    "find": "\\$1\\.decode\\([^)]+\\)",
    "isRegex": true,
    "triggerSearch": true
    // "filesToInclude": "${fileDirname}"
    // "onlyOpenEditors": true
    // 以及更多选项
  }
}
```

然后可以通过命令面板或类似以下的键盘绑定触发这些设置命令：

```json
{
  "key": "alt+k",
  "command": "findInCurrentFile.findRequireDecodeReferences"
}
```

### 如何在光标处插入值

如果您不想查找并替换某些内容，而只是想插入一些值，请使用如下键盘绑定或设置：

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    // 没有 find 键！！
    "replace": "\\U${relativeFileDirname}", // 在光标处插入
    "replace": "Chapter ${matchNumber}", // 每个光标对应 Chapter 1、Chapter 2 等
    "replace": "Chapter $${ return ${matchNumber} * 10 }$$" // Chapter 10、Chapter 20 等
  }
}
```

有两种方式使用此功能——当没有 `find` 时：

1.  光标位于单词处（或选择了单词，情况相同）。查找将从该单词/选择生成，替换将替换任何匹配项。
2.  光标不在任何单词处——在空行上或与任何单词之间有空格。那么不会生成查找，替换将直接插入到光标（们）所在的位置。

使用 `"replace": "Chapter ${matchNumber}"` 且没有 find 的演示：

[在光标处插入演示]

上面解释：在第一种情况下，光标放在 `Chapter` 上，因此这就是查找，它的每个出现都被替换为 `Chapter ${matchNumber}`。在第二种情况下，多个光标放在空行上，因此没有查找，在这种情况下，`"Chapter ${matchNumber}"` 被插入到每个光标处。

### 使用单个键盘绑定或设置运行多次查找和替换

`find` 和 `replace` 字段可以是一个字符串或一个字符串数组。示例：

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "find": "(trouble)", // 单个字符串 - 运行一次
    "find": ["(trouble)"], // 允许一个字符串的数组 - 运行一次

    "replace": "\\U$1", // 将 "trouble" 替换为 "TROUBLE"

    "find": ["(trouble)", "(more trouble)"], // 任意多个逗号分隔的字符串

    "replace": ["\\U$1", "\\u$1"], // 将 "trouble" 替换为 "TROUBLE" 并且
    // 将 "more trouble" 替换为 "More trouble"

    "isRegex": true
  }
}
```

*   如果有比 `replace` 字符串更多的 `find` 字符串：那么最后一个 `replace` 值将用于任何剩余的运行。
*   如果有比 `find` 更多的 `replace`：那么将使用生成的查找（参见下方“光标处的单词”讨论）使用光标选择来用于任何剩余的运行。这通常是先前的替换文本。

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "find": ["(trouble)", "(more trouble)"], // 两个查找
    "replace": "\\U$1", // \\U$1 将用于两个替换，所以
    // 将 "trouble" 替换为 "TROUBLE" 并将 "more trouble" 替换为 "MORE TROUBLE"
    "isRegex": true
  }
}
```

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "find": "(trouble)", // 一个查找
    "replace": ["\\U$1", "\\u$1"], // 替换比查找多
    // 第一次运行将 "trouble" 替换为 "TROUBLE"，并且
    // 第二次运行将任何选中的单词替换为其首字母大写版本
    "isRegex": true
  }
}
```

您可能希望像这样按顺序运行两个或多个命令，以完成一些难以用一个正则表达式完成但使用序列中的两个查找/替换要简单得多的替换。例如：

```json
"find": ["(${relativeFile})", "(${fileExtname})"],
"replace": ["\\U$1", ""],
"isRegex": true
```

在上面第一个过程中，文件名将被大写。第二次运行时，文件扩展名（如 `.js`）将被匹配并替换为空（空字符串），因此将被删除。

```json
"find": ["(someWord)", "(WORD)"],
"replace": ["\\U$1", "-\\L$1"],
"isRegex": true,
"matchCase": true
```

在上面第一个过程中，`"someWord"` 将被替换为 `"SOMEWORD"`。第二个过程中，查找 `"WORD"` 并将其替换为 `"-word"`。因此，两次运行后，您将把 `"someWord"` 替换为 `"SOME-word"`。是的，您可以在一次运行中创建一个单独的正则表达式来做到这一点，但在更复杂的情况下，使用两次或多次运行可以使它更简单。

### 在替换中运行 JavaScript 代码

调试您在如下替换中编写的 JavaScript 代码的错误很困难。如果您的键盘绑定或设置产生错误，您将收到警告消息通知您失败。如果您检查输出选项卡，并选择下拉菜单中的 `find-and-transform`，您可能会获得关于错误性质的一些有用信息。

您还可以将 `console.log(...)` 语句放入替换代码中。它将被记录到您的帮助/切换开发者工具/控制台中。

#### 对替换进行数学运算

使用特殊语法 `$${<some math op>}$$` 作为替换或查找值。括号内的所有内容都将作为 JavaScript 函数求值，因此您可以执行比数学运算更多的操作，例如字符串操作（见下文）。这不使用 `eval()` 函数。示例：

```json
{
  "key": "alt+n",
  "command": "findInCurrentFile",
  "args": {
    "find": "(?<=<some preceding text>)(\\d+)(?=<some following text>)", // 正向向后/向前查找

    "find": "$${return ${getInput} * 3;}$$", // 对 getInput 进行数学运算并匹配它

    "find": "(howdy)-(${lineNumber})",
    "replace": "${1:/capitalize}-$${return $2 * 10;}$$", // howdy-3 => Howdy-30 (在第 3 行)

    "replace": "$${return $1 + $1}$$", // 将使捕获组 1 中找到的数字加倍
    "replace": "$${return 2 * $1 }$$", // 将使捕获组 1 中找到的数字加倍

    "replace": "$${return $1 + $2}$$", // 将捕获组 1 加到捕获组 2

    "replace": "$${return $1 * 2 + `,000` }$$", // 将组 1 加倍，附加 `,000`。1 => 2,000

    "replace": "$${return $1 * Math.PI }$$", // 将组 1 乘以 Math.PI

    "replace": "$${const date = new Date(Date.UTC(2020, 11, 20, 3, 23, 16, 738)); return new Intl.DateTimeFormat('en-GB', { dateStyle: 'full', timeStyle: 'long' }).format(date)}",
    // 插入：Saturday, 19 December 2020 at 20:23:16 GMT-7

    "replace": [ // 与上述输出相同
      "$${", // 将开头包装器 - '$${' 放在单独的行上！
      "const date = new Date(Date.UTC(2020, 11, 20, 3, 23, 16, 738));",
      "return new Intl.DateTimeFormat('en-GB', { dateStyle: 'full', timeStyle: 'long' }).format(date)",
      "}$$" // 将结尾包装器 - '}$$' 放在单独的行上！
    ],

    "isRegex": true
  }
}
```

**重要提示**：必须在语句末尾使用分号——除了最后的 return 语句（或者如果唯一的语句是 return something）。任何有多个语句的都必须使用分号。这些操作将被加载到一个使用 `"use strict"` 的 Function 中，这需要分号。

**作为语句数组编写的 jsOperation**：
如果您使用扩展形式的替换，并将 jsOperation 编写为数组（如上面的最后一个示例所示），则该整个数组将被转换为单个长数组项，如 `$${ <multiple statements> }$$`，因此它将成为一个替换数组项。所以这个替换：

```json
"replace": [
  "$${",
  "let a = 10;",
  "...",
  "return 'howdy';",
  "}$$",
  "$${",
  "let v = 12;",
  "...",
  "return 'pardner';",
  "}$$"
]
```

将变成：

```json
"replace": [
  "$${ let a = 10; ... return 'howdy'; }$$",
  "$${ let v = 12; ... return 'pardner'; }$$"
]
```

以上是 2 个替换。第一个将应用于第一个查找。第二个替换将应用于第二个查找。

#### 对替换进行字符串操作

您也可以在特殊语法 `$${<operations>}$$` 内部执行字符串操作。但您需要使用反引号、单引号或转义的双引号来“转换”字符串，如下所示：

```javascript
$${ return `$1`.substring(3) }$$  // 使用反引号（我推荐反引号）或
$${ return '$1'.substring(3) }$$  // 或使用单引号
$${ return \"$1\".includes('tro') }$$  // 转义双引号
```

如果值（如捕获组或某些变量）可能包含换行符，则必须使用上述之一。

您希望被解释为字符串的任何术语必须用反引号或引号括起来。因此，在下面的第一个示例中，要将匹配项替换为字符串 `howdy`，我使用了反引号。这仅在操作语法 `$${<operations>}$$` 中是必需的，否则它将被 JavaScript 解释为未知变量。

```json
{
  "key": "alt+n",
  "command": "findInCurrentFile",
  "args": {
    "find": "(trouble) (brewing)",

    "replace": "$${ return `howdy` }$$", // 将 trouble brewing => 替换为 howdy
    "replace": "howdy", // 与上述结果相同

    "replace": "$${ return `$1`.indexOf('b') * 3 }$$", // trouble brewing => 12

    "replace": "$${ return `$1`.toLocaleUpperCase() + ' C' + `$2`.substring(1).toLocaleUpperCase() }$$",
    // trouble brewing => TROUBLE CREWING

    "replace": "$${ return `$1`.replace('ou','e') }$$", // trouble => treble

    // 在 replace/replaceAll 中使用捕获组，参见下方注意
    "replace": "$${ return `$1`.replace('(ou)','-$1-') }$$",

    "replace": "$${ return '$1'.split('o')[1] }$$", // trouble => uble

    "find": "(tr\\w+ble)", // .includes() 返回 'true' 或 'false'
    "replace": "$${ return '$1'.includes('tro') }$$", // trouble 将被替换为 true，treble => false

    "find": "(tr\\w+ble)", // 可以在一个替换中有任意数量的 $${...}$$'s
    "replace": "$${ return '$1'.includes('tro') }$$--$${ return '$1'.includes('tre') }$$",
    // trouble => true--false, treble => false--true

    "isRegex": true
  }
}
```

**注意**：如果在 JavaScript 操作中，您有一个 `<string>.replace(/../, '$n')`（或 `replaceAll`），并且在替换中有捕获组，如：

```json
"replace": [
  "$${", // 将开头的 jsOperation 包装器放在单独的行上
  "if (`${fileBasenameNoExtension}`.includes('-')) {",
  "let groovy = `${fileBasenameNoExtension}`.replace(/(-)/g, \"*$1*\");", // 这里的 $1
  "console.log(groovy);", // 在切换开发者工具/控制台中检查值
  "return groovy[0].toLocaleUpperCase() + groovy.substring(1).toLocaleLowerCase();",
  "}",
  "else {",
  "let groovy = `${fileBasename}`.split('.');",
  "groovy = groovy.map(word => word[0].toLocaleUpperCase() + word.substring(1).toLocaleLowerCase());",
  "return groovy.join(' ');",
  "}",
  "}$$" // 将结尾的 jsOperation 包装器放在单独的行上
]
```

该捕获组将如您所期望的那样来自 `replace/replaceAll`。JavaScript 操作中的其他捕获组将反映来自 `find` 参数的捕获组。

您可以在 `$${<operations>}$$` 中组合数学或字符串操作。

#### 在替换中使用 vscode API

如果您希望在替换中使用 vscode API，可以轻松实现。例如，要插入大写的当前文件名，可以使用此键盘绑定：

```json
{
  "key": "alt+n",
  "command": "findInCurrentFile",
  "args": {
    "replace": [
      "$${",
      "const str = path.basename(document.fileName);",
      "return str.toLocaleUpperCase();",
      "}$$"
    ]
  }
}
```

*   `document = vscode.window.activeTextEditor.document` 并简单地以 `document` 提供。
*   任何其他 node API 都可以用作 `vscode.<more here>`。
*   不要执行 `const vscode = require('vscode');`；它已经被声明，您将收到此错误：`SyntaxError: Identifier 'vscode' has already been declared`。您可以将其声明为更简单的东西，如 `const vsc = require('vscode');`，只是不要再作为 `vscode`。
*   `path` 也已提供，无需导入。所以不要 `const path = require('path');` = 错误。
*   您应该能够需要 `typescript` 和 `jsonc-parser` 库，而无需在您的机器上安装它们。
*   如果您获得 `[object Promise]` 作为替换的输出，您正在尝试访问异步方法（或可 thenable 的返回）——这行不通。

```json
"replace": [
  "$${",
  "let str = '';",
  // 在活动选项卡组中打印打开的文档文件名列表
  "const tabs = vscode.window.tabGroups.activeTabGroup.tabs;",
  "tabs.forEach(tab => str += tab.label + '\\n');", // 注意双重转义的换行符
  "return str;",
  "}$$"
]
```

```json
{
  "key": "alt+c",
  "command": "findInCurrentFile",
  "args": {
    "replace": [
      // 按编辑器组打印打开的文本文档的完整路径列表
      "$${",
      "let str = '';",
      "const groups = vscode.window.tabGroups.all;",
      "groups.map((group, index) => {",
      "str += 'Group ' + (index + 1) + '\\n';",
      "group.tabs.map(tab => {",
      "if (tab.input instanceof vscode.TabInputText) str += '\\t' + tab.input.uri.fsPath + '\\n';",
      // "str += tab.label + '\\n';",
      "});",
      "str += '\\n';",
      "});",
      "vscode.env.clipboard.writeText(str);",
      "return '';",
      "}$$"
    ],
    // 创建新文件并粘贴到其中
    "postCommands": ["workbench.action.files.newUntitledFile", "editor.action.clipboardPasteAction"]
  }
}
```

对于上述打印完整路径的示例，没有 `find`，因此替换——只是一个空字符串——将直接插入到光标处。因此，请确保光标不在单词边界处或不在单词边界，否则该单词将被视为查找查询并被空字符串替换。光标必须不在任何单词处或与任何单词有空格。对于替换 JavaScript 操作，必须有某种 `return`。

如果您只是打算将其用作副作用（如此处将其存储在剪贴板中以粘贴到不同的文件中），那么将其放在 `"run"` 参数中可能更有意义。那么您就不关心光标在哪里或是否已经选择了任何文本。

上述替换在新创建文件中的输出：

```
Group 1
  c:\Users\Fred\AppData\Roaming\Code\User\keybindings.json
  c:\Users\Fred\AppData\Roaming\Code\User\settings.json
  c:\Users\Fred\OneDrive\Test Bed\test5.js
  c:\Users\Fred\OneDrive\Test Bed\zip\changed2.txt_bak
  c:\Users\Fred\OneDrive\Test Bed\zip\config.json

Group 2
  c:\Users\Fred\OneDrive\Test Bed\zip\test3.txt
```

```json
"find": "${getTextLines:(${lineIndex}-1)}", // 获取光标上方的行

"replace": [
  "$${", // 获取光标上方的行
  "const sel = vscode.window.activeTextEditor.selection;",
  "const previousLine = document.lineAt(new vscode.Position(sel.active.line - 1, 0)).text;",
  // 下面也有效
  // "const previousLine = document.getText(new vscode.Range(sel.active.line-1, 0, sel.active.line-1, 100));",
  // 下面是最简单的
  "const previousLine = document.lineAt(new vscode.Position(${lineIndex}-1, 0)).text;",
  "return previousLine.toUpperCase();",
  "}$$"
]
```

下面将获取光标上方的行，因为被 `()` 包围，将其放入捕获组中，并在整个文档中将其大写（由于没有 `restrictFind` 值，默认为 `document`）。

```json
{
  "key": "alt+n",
  "command": "findInCurrentFile",
  "args": {
    "description": "将光标上方的行在它出现的所有地方大写",
    "find": "(${getTextLines:(${lineIndex}-1)})",
    "replace": "\\U$1",
    "isRegex": true
  }
}
```

仅将前一行大写：

```json
{
  "key": "alt+n",
  "command": "findInCurrentFile",
  "args": {
    "description": "仅将前一行大写",
    "find": "(${getTextLines:(${lineIndex}-1)})",
    "replace": "\\U$1",
    "restrictFind": "previousSelect", // 这使其仅在前一行上工作，将在文件顶部换行
    // "restrictFind": "nextSelect",   // 将查找的下一个实例大写，将在文件末尾换行
    "isRegex": true // 必须在这里才能将 find 视为正则表达式
  }
}
```

```json
"replace": [
  "$${",
  "const os = require('os');",
  "return os.arch();",
  "}$$"
]
```

```json
"replace": [
  "$${",
  "const { basename } = require('path');", // 您可以重新导入以重命名或提取
  // "const path = require('path');",       // 错误：path 已声明
  "return basename(document.fileName);",
  "}$$"
]
```

```json
"replace": [
  "$${",
  // 更改当前编辑器的文件名
  "const fsp = require('node:fs/promises');",
  "fsp.rename(document.fileName, path.join(path.dirname(document.fileName), 'changed2.txt'));",
  "return '';", // 返回空字符串，否则将在光标处插入 "undefined"
  "}$$"
]
```

虽然最后一个示例有效，但使用查找和替换扩展来更改文件名并运行这些可能与文本替换或插入无关的命令似乎很奇怪。我能想到一种情况，您可能希望基于在当前文件中找到的某些文本来更改文件名……
最好使用内置的 `vscode.workspace.fs` 进行文件操作：

```json
"replace": [
  "$${",
  "const thisUri = vscode.Uri.file(document.fileName);",
  // 新的文件名可以源自当前文件中的某些文本
  "const newUri = vscode.Uri.file(document.fileName + '_bak');",
  // 这将重命名当前文件并保持其打开状态
  "vscode.workspace.fs.rename(thisUri, newUri);",
  "return '';", // 返回空字符串
  "}$$"
]
```

#### 对替换进行其他 JavaScript 操作

在替换中，`$${...}$$` 内部必须有一个或多个 `return` 语句，用于返回您想要返回的内容。

记住，如果您希望将变量或捕获组视为字符串，请用反引号或单引号将其包围。

`\\U$1` 在 JavaScript 操作中有效，`\\U`$1`` 无效。

```json
{
  "key": "alt+n",
  "command": "findInCurrentFile",
  "args": {
    "find": "(trouble) (brewing)",

    // 将查找匹配项替换为剪贴板文本长度
    "replace": "$${ return '${CLIPBOARD}'.length }$$",

    "find": "(trouble) (times) (\\d+)",
    // 将查找匹配项替换为捕获组 1 大写 + 捕获组 2 * 10
    // trouble times 10 => TROUBLE times 100
    "replace": "$${ return `\\U$1 $2 ` + ($3 * 10) }$$",

    "find": "(\\w+) (\\d+) (\\d+) (\\d+)",
    // dogs 1 3 7 => Total dogs: 11
    "replace": "$${ return `Total $1: ` + ($2 + $3 + $4) }$$",

    // 比较剪贴板文本长度与所选文本长度
    "replace": "$${ if (`${CLIPBOARD}`.length < `${selectedText}`.length) return true; else return false }$$",

    // 查找匹配项将被替换为：
    // 如果剪贴板匹配字符串，则返回捕获组 2 + 路径变量
    "replace": "$${ return `${CLIPBOARD}`.match(/(first) (pattern) (second)/)[2] + ` ${fileBasenameNoExtension}` }$$",

    "isRegex": true
  }
}
```

```json
"replace": [
  "$${", // 开头 jsOp 包装器单独一行
  "if (`${fileBasenameNoExtension}`.includes('-')) {",
  // 变量必须使用 let 或 const
  "let groovy = `${fileBasenameNoExtension}`.replace(/-/g, \" \");",
  "return groovy[0].toLocaleUpperCase() + groovy.substring(1).toLocaleLowerCase();",
  "}",
  // 空行无效，缩进无关紧要
  "else {",
  "let groovy = `${fileBasename}`.split('.');",
  "groovy = groovy.map(word => word[0].toLocaleUpperCase() + word.substring(1).toLocaleLowerCase());",
  "return groovy.join(' ');",
  "}",
  "}$$", // 结尾 jsOp 包装器单独一行

  "$${return 'second replacement'}$$", // 第二个替换

  "\\U$1" // 第三个替换
]
```

每组开头和结尾包装器之间的所有代码都将被视为一个 JavaScript 替换。如果您愿意，也可以将其全部放在一行上，如上面的 `"$${return 'second replacement'}$$"`。上面的替换将被视为：

```json
"replace": ["a long first replacement", "2nd replacement", "3rd replacement"]
```

只要您正确地包装代码块，就可以混合使用单个替换或其他代码块。您可以拥有任意多个。参见上文关于在系列中运行多次查找和替换的讨论。

settings.json 示例：

```json
"findInCurrentFile": { // 在 settings.json 中
  "addClassToHtmlElement": {
    "title": "Add Class to Html Element",
    "find": ">",
    "replace": [
      "$${",
      "return ' class=\"\\U${fileBasenameNoExtension}\">'",
      "}$$"
    ],
    "isRegex": true, // 这里实际上不是必需的
    "restrictFind": "selections" // 仅替换那些在选定内容中的 `>`
  }
}
```

上面解释：查找 `>` 并向其添加 `class="大写文件名">`。

### 将 JavaScript 代码作为副作用运行

您可能希望运行一些 JavaScript 代码，包括 vscode API，但**不**是为了替换任何内容。您可能希望构造一个字符串以粘贴到某处，或者收集文件名等。考虑这个示例（在您的 settings.json 中）：

```json
"findInCurrentFile": {
  "buildMarkdownTOC": {
    "title": "Build Markdown Table of Contents", // 将出现在命令面板中
    "find": "(?<=^###? )(.*)$", // 这些将被选中
    "run": [ // 这将在查找选择之后、任何替换之前运行
      "$${",
      "const headers = vscode.window.activeTextEditor.selections;",
      "let str = '';",
      "headers.forEach(header => {",
      "const selectedHeader = document.getText(header);",
      "str += `* [${selectedHeader}](#${selectedHeader.toLocaleLowerCase().split(' ').join('-')})\\n`;",
      "});",
      "str = str.slice(0, -1);", // 从 str 中移除最后一个 \n
      "vscode.env.clipboard.writeText(str);", // 注意：对于 "run"，return 语句不是必需的
      "}$$"
    ],
    "isRegex": true,
    "postCommands": ["cursorTop", "editor.action.insertLineAfter", "editor.action.insertLineAfter", "editor.action.clipboardPasteAction"]
  }
}
```

此设置将选择所有具有 2 个或更多 `##` 的标题，然后 `run` 代码将使用这些选择来构建目录。这将被保存到剪贴板。

最后，`postCommands` 将光标移动到顶部，插入 2 个空行，然后粘贴目录。

这在 Stack Overflow 上演示过：[对所选文本运行自定义代码](...)，其中也显示了键盘绑定。

这种模式——一个查找（将根据 `restrictFind` 选项限制所有匹配项），然后这些选择（或查找正则表达式中的捕获组）可以在 `run` 操作中被操作——是一个非常强大的方法。

`run` 参数将在任何查找和任何替换之后执行。因此，例如，您可以使用您的查找匹配和选择所产生的 `vscode.window.activeTextEditor.selections` 并操作这些新选择。

### 特殊变量

#### 此扩展定义的用于参数中的变量

*   `${resultsFiles}` **下方解释** 仅在 `runInSearchPanel` 命令中可用
*   `${getFindInput}` 已弃用，使用 `${getInput}`
*   `${getInput}` 通过输入框输入查找查询或替换文本或 cursorMoveSelect 文本或 postCommand 文本，或 filesToInclude 或 filesToExclude，而不是在键盘绑定/设置中
*   `${getDocumentText}` 获取当前文档的整个文本
*   `${getTextLines:n}` 获取行的文本，'n' 是基于 0 的索引，因此 `${getLineText:1}` 获取文件的第二行
*   `${getTextLines:n-p}` 获取从第 n 行到第 p 行（包含）的文本，示例 `${getTextLines:2-4}`
*   `${getTextLines:(n-n)}` 获取第 n-n 行的文本，示例 `${getTextLines:(${lineIndex}-1)}`：获取前一行
    使用括号，如果您想通过数学运算解析为一行。可以使用 `+-/*%`。
*   `${getTextLines:n,p,q,r}` 获取从第 `n` 行、第 `p` 列到第 `q` 行、第 `r` 列（包含）的文本，
    示例 `${getTextLines:2,0,4,15}`

**智能感知**：可以在键盘绑定或设置中使用，显示变量的使用位置。您还将获得未使用参数（如 find、isRegex、matchCase 等）的智能感知。您可以通过在许多位置的键盘绑定或设置中手动按 Ctrl/Cmd+Space 随时获得更多智能感知。

*   `${resultsFiles}` 是一个特殊创建的变量，它将下一次搜索的范围限定在先前搜索结果中的那些文件。通过这种方式，您可以运行连续搜索，每次都将范围缩小到先前搜索结果文件。参见[使用面板搜索](#)。

以下是使用 `${getDocumentText}` 的示例：

```json
{
  "key": "alt+e",
  "command": "findInCurrentFile",
  "args": {
    "replace": [
      "$${",
      // 注意变量应该用反引号括起来，以便它们被解释为字符串
      "const fullText = `${getDocumentText}`;",
      // "const fullText = `${vscode.window.activeTextEditor.document.getText()}`;", // 同上
      // "const fullText = `${document.getText()}`;", // 同上
      // "const fullText = `${getLineText:3}`;", // 如果您知道要获取哪一行
      "let foundClass = '';",
      "const match = fullText.match(/class ([^\\s]+) extends/);",
      "if (match?.length) foundClass = match[1];",
      "return `export default connect(mapStateToProps, mapDispatchToProps)(${foundClass})`;",
      "}$$"
    ],
    "postCommands": "cancelSelection"
  }
}
```

注意没有 `find`，因此替换的结果将插入到光标处。在这种情况下，替换将获取整个文本，然后使用正则表达式匹配，查找某个类名作为捕获组。如果找到，它将被添加到一个返回的值中。参见此 Stack Overflow 问题以查看此操作。

`${getDocumentText}` 变量允许您在文档中任何位置查找任何文本或文本组，这些文本可以用正则表达式找到。例如，您不仅限于当前行、剪贴板或选择。

以下是使用 `${getInput}` 的示例：

```json
{
  "key": "alt+c",
  "command": "findInCurrentFile",
  "args": {
    "description": "我想在输入框中输入查找查询。", // 您想要的任意文本
    "find": "${getInput}", // 在弹出输入框中输入纯文本或正则表达式
    "find": "${getInput} stuff \\U${getInput}", // 可以使用多个 ${getInput} 变量
    // 您可以将文本与将要输入的内容混合
    "find": "before ${getInput} after",
    // ${getInput} 在 js 操作内部
    "find": "$${return '${getInput}' + 'end';}$$", // 将 '${getInput}' 视为字符串并向其添加 'end' 并匹配
    "find": "(${getInput})", // 用捕获组包装以便稍后使用
    "isRegex": true, // 将 $1 视为捕获组并对其执行字符串操作
    "replace": "${BLOCK_COMMENT_START} $${return '$1'.toLocaleUpperCase();}$$ ${BLOCK_COMMENT_START}",
    // "replace": "${BLOCK_COMMENT_START} \\U$1 ${BLOCK_COMMENT_START}", // 更简单的上述版本
    "isRegex": true, // 如果您希望该输入被视为正则表达式 ***
    "replace": "everything is fine",
    "replace": "${getInput} is my replacement", // 输入文本添加到任何其他替换文本
    // 确保在 jsOperation 中，如果您希望将 '${getInput}' 值视为字符串，请用反引号将其包围
    "replace": "$${return '${getInput}' was added;}$$",
    // 没有用反引号包围 ${getInput}，因为我们将输入一个数字，输入字符串将是错误的
    "replace": "$${return ${getInput} * ${lineNumber};}$$",
    // 下方：在每个匹配项上都会呈现一个输入框，在那里输入的任何文本都将被写入新文件
    "run": [
      "$${",
      "vscode.env.clipboard.writeText('${getInput}');", // 获取输入并将其写入剪贴板
      "vscode.commands.executeCommand('workbench.action.files.newUntitledFile');", // 打开新文件
      "vscode.commands.executeCommand('editor.action.clipboardPasteAction');", // 粘贴到新文件
      "}$$"
    ],
    "runWhen": "onEveryMatch",
    // 下方：对于每个查找匹配项，将显示一个输入框，您输入的文本将插入到光标处
    "postCommands": [
      {
        "command": "type",
        "args": {
          "text": " from the input: ${getInput}"
        }
      }
    ],
    "runPostCommands": "onEveryMatch",
    "cursorMoveSelect": "${getInput}" // 输入文本将在任何替换后被选中
  }
}
```

在 `${getInput}` 中使用正则表达式时，不要双重转义任何字符，如 `\n` 或 `\s`。只需使用您将在查找小部件中使用的相同正则表达式。

#### 启动或任务变量：路径变量

这些可用于 `findInCurrentFile` 命令的 `find` 或 `replace` 字段，或 `runInSearchPanel` 命令的 `find`、`replace`，或许最重要的是，`filesToInclude` 和 `filesToExclude` 字段：

*   `${file}` 轻松将搜索限制为当前文件，完整路径
*   `${fileBasename}`
*   `${fileBasenameNoExtension}`
*   `${fileExtname}`
*   `${relativeFile}` 相对于 workspaceFolder 的当前文件
*   `${fileDirname}` 当前文件的父目录，完整路径
*   `${relativeFileDirname}` 仅当前文件的父目录
*   `${fileWorkspaceFolder}`
*   `${workspaceFolder}`
*   `${workspaceFolderBasename}`
*   `${pathSeparator}`
*   `${/}` 与 `${pathSeparator}` 相同
*   `${selectedText}` 可用于 find/replace/cursorMoveSelect 字段
*   `${CLIPBOARD}`
*   `${lineIndex}` 行索引从 0 开始
*   `${lineNumber}` 行号从 1 开始
*   `${columnNumber}` 行上的字符位置
*   `${matchIndex}` 基于 0，替换为查找匹配索引 - 第一个匹配、第二个等。
*   `${matchNumber}` 基于 1，替换为查找匹配编号

这些变量的解析值应与 [vscode 预定义变量文档](...) 中的值相同。

这些路径变量也可以在条件中使用，如 `${1:+${relativeFile}}`。如果找到捕获组 1，则插入相对文件名。

下面给出了使用 lineIndex/Number 和 matchIndex/Number 的示例。

#### 片段变量

*   `${TM_CURRENT_LINE}` 每个选择的当前行文本。
*   `${TM_CURRENT_WORD}` 每个选择的光标处的单词或空字符串。
*   `${CURRENT_YEAR}` 当前年份。
*   `${CURRENT_YEAR_SHORT}` 当前年份的最后两位数字。
*   `${CURRENT_MONTH}` 月份，两位数字（例如 '02'）。
*   `${CURRENT_MONTH_NAME}` 月份的完整名称（例如 'July'）。
*   `${CURRENT_MONTH_NAME_SHORT}` 月份的简称（例如 'Jul'）。
*   `${CURRENT_DATE}` 日期，两位数字（例如 '08'）。
*   `${CURRENT_DAY_NAME}` 星期几的名称（例如 'Monday'）。
*   `${CURRENT_DAY_NAME_SHORT}` 星期几的简称（例如 'Mon'）。
*   `${CURRENT_HOUR}` 当前小时，24 小时制格式。
*   `${CURRENT_MINUTE}` 当前分钟，两位数字。
*   `${CURRENT_SECOND}` 当前秒，两位数字。
*   `${CURRENT_SECONDS_UNIX}` 自 Unix 纪元以来的秒数。
*   `${CURRENT_TIMEZONE_OFFSET}` 修改自 `Date.prototype.getTimezoneOffset()`，并参见 [vscode issue #151220](...)。感谢 [microsoft/vscode PR #170518](...) 和 [MonadChains](...)。
*   `${RANDOM}` 六位随机十进制数字。
*   `${RANDOM_HEX}` 六位随机十六进制数字。
*   `${BLOCK_COMMENT_START}` 示例输出：在 PHP 中为 `/*`，在 HTML 中为 `<!--`。
*   `${BLOCK_COMMENT_END}` 示例输出：在 PHP 中为 `*/`，在 HTML 中为 `-->`。
*   `${LINE_COMMENT}` 示例输出：在 PHP 中为 `//`。

这些片段变量的使用方式与上面提到的路径变量相同。例如，使用 `\\U${CURRENT_MONTH_NAME}` 将当前月份名称大写。

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "replace": "$${ return ${CURRENT_HOUR} - 1 }$$"
  }
}
```

**解释**：上面的键盘绑定（或者它可能是一个命令）将在光标处插入（当前小时 - 1）的结果，如果光标不在单词处——即在空行上或光标与任何其他单词之间有空格。否则，如果光标在一个单词上，该单词将被视为查找，并且它的所有出现（在 restrictFind 范围内：整个文档/选择/onceIncludeCurrentWord/onceExcludeCurrentWord/行/下一个..）将被替换为（当前小时 - 1）。

要插入时间戳，请尝试此键盘绑定：

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "replace": "${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DATE}T${CURRENT_HOUR}:${CURRENT_MINUTE}:${CURRENT_SECOND}${CURRENT_TIMEZONE_OFFSET}"
  }
}
```

上述结果将是 `2023-02-24T03:52:55-08:00`，适用于 UTC-8 的区域设置。由于没有 `find` 参数，只需确保触发此操作时您的光标不在单词处（否则该单词将被替换，在某些情况下这可能正是您想要的）。

以及在您的 settings.json 中作为设置：

```json
"findInCurrentFile": {
  "AddTimeStampWithTimeZoneOffset": { // 此行不能有空格
    // 这将作为 'Find-Transform: Insert a timestamp with timezone offset' 出现在命令面板中
    "title": "Insert a timestamp with timezone offset", // 您想要的任意文本
    "replace": "${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DATE}T${CURRENT_HOUR}:${CURRENT_MINUTE}:${CURRENT_SECOND}${CURRENT_TIMEZONE_OFFSET}"
  }
}
```

以上设置将在重新加载后，作为 `Find-Transform: Insert a timestamp with timezone offset` 出现在命令面板中，您可以更改此文本。

注意，vscode 可以通过检查单个标记的语言来处理花哨的片段注释变量，如 `${LINE_COMMENT}`，以便例如，js 中的 css 会获得其正确的注释字符。此扩展无法做到这一点，并且只会获取文件类型的正确注释字符。

#### 大小写修饰符转换

查找查询和替换转换可以包括如下大小写修饰符：

可以在 `replace` 字段中使用：

*   `\\U$n` 将后面的整个捕获组大写，如 `\\U$1`
*   `\\u$n` 仅将后面捕获组的第一个字母大写：`\\u$2`
*   `\\L$n` 将后面的整个捕获组小写：`\\L$2`
*   `\\l$n` 仅将后面捕获组的第一个字母小写：`\\l$3`

可以在 `replace` 或 `find` 字段中使用：

*   `\\U${relativeFile}` 或上面列出的任何启动/任务类变量
*   `\\u${any launch variable}`
*   `\\L${any launch variable}`
*   `\\l${any launch variable}`

这些在 `findInCurrentFile` 和 `runInSearchPanel` 命令或键盘绑定中都有效。

示例：

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    // 查找相对文件名的小写版本
    "find": "(\\L${relativeFile})", // 注意外部捕获组
    "replace": "\\U$1", // 替换为捕获组 1 的大写版本
    "matchCase": true, // 必须设置此选项，否则查找时将忽略大小写！
    "isRegex": true
  }
}
```

注意，上述大小写修饰符必须在设置或键盘绑定中双重转义。因此，`\U$1` 在设置中应为 `\\U$1`。如果您不双重转义修饰符，VS Code 将显示错误（类似于其他转义的正则表达式项，如 `\\w`）。

#### findInCurrentFile 命令或键盘绑定中的条件替换

Vscode 片段允许您进行条件替换，参见 [vscode 片段语法文档](...)。但是，您不能在查找/替换小部件中使用这些。此扩展允许您在 `findInCurrentFile` 命令或键盘绑定中使用这些条件。条件类型及其含义：

*   `${1:+add this text}` 如果找到捕获组 1，则添加文本。`+` 表示 `if`
*   `${1:-add this text}` 如果**没有**捕获组 1，则添加文本。`-` 表示 `else`
*   `${1:add this text}` 与上面的 `else` 相同，可以省略 `-`
*   `${1:?yes:no}` 如果捕获组 1，则添加 `yes` 处的文本，否则添加 `no` 处的文本。`?` 表示 `if/else`

示例：

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "find": "(First)|(Second)|(Third)", // 带有可能捕获组的正则表达式
    "replace": "${3:-yada3} \\U$1", // 如果没有组 3，则添加 "yada3" 然后将组 1 大写
    // 条件内的组必须用反引号 `$2` 包围
    "replace": "${2:+abcd `\\U$2` efgh}", // 如果组 2，则添加大写的组 2 加周围的文本
    "replace": "${1:+aaa\\}bbb}", // 如果希望作为文本，必须双重转义闭合括号
    "replace": "\\U${1:+aaa-bbb}", // 将整个替换大写
    "replace": "${1:+*`$1``$1`*}${2:+*`$2``$2`*}", // 可以有很多组合
    "replace": "$0", // 可以使用整个匹配作为替换
    "replace": "", // 匹配将被替换为空，即空字符串
    "replace": "${2:?yada2:yada3}\\U$1", // 如果组 2，则添加 "yada2"，否则添加 "yada3"
    // 然后跟上大写的组 1
    "replace": "${2:?`$3`:`$1`}", // 如果组 2，则添加组 3，否则添加组 1
    "isRegex": true
  }
}
```

*   条件内的组（即使在 vscode 片段中也不可能）必须用反引号包围。
*   如果您想在条件内的替换中使用字符 `}`，必须双重转义 `\\}`。

#### 类似片段的转换：findInCurrentFile 命令或键盘绑定中的替换

以下可用于 `findInCurrentFile` 命令的 `replace` 字段：

*   `${1:/upcase}` 如果捕获组 1，将其转换为大写（同 `\\U$1`）
*   `${2:/downcase}` 如果捕获组 2，将其转换为小写（同 `\\L$1`）
*   `${3:/capitalize}` 如果捕获组 3，将其首字母大写（同 `\\u$1`）
*   `${1:/pascalcase}` 如果捕获组 1，将其转换为帕斯卡命名法
    （`first_second_third` => `FirstSecondThird` 或 `first second third` => `FirstSecondThird`）
*   `${1:/camelcase}` 如果捕获组 1，将其转换为驼峰命名法
    （`first_second_third` => `firstSecondThird` 或 `first second third` => `firstSecondThird`）
*   `${1:/snakecase}` 如果捕获组 1，将其转换为蛇形命名法
    （`firstSecondThird` => `first_second_third`，因此仅从驼峰命名法转换为蛇形命名法）

示例：
如果您想查找多个项目，然后逐个转换每个匹配：

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "find": "(first)|(Second)|(Third)",
    "replace": "${1:+ Found first!!}${2:/upcase}${3:/downcase}",
    "isRegex": true,
    "restrictFind": "nextSelect" // 一次一个匹配
    // 'nextMoveCursor' 作用相同，移动光标但不选择
  }
}
```

[逐个应用转换]

上面解释：

*   `"restrictFind": "nextSelect"` 逐个执行以下操作，依次选择每个
*   如果您想跳过转换匹配项，只需将光标移过它（右箭头）。
*   `${1:+ Found first!!}` 如果找到捕获组 1，则用文本 `"Found First!!"` 替换它
*   `${2:/upcase}` 如果找到捕获组 2，则将其大写
*   `${3:/downcase}` 如果找到捕获组 3，则将其小写

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "description": "将文本中的现有 fileBaseName 转换为 SCREAMING_SNAKE_CASE",
    "find": "(${fileBasenameNoExtension})",
    "replace": "\\U${1:/snakecase}",
    "isRegex": true // 必需，因为 {1:/snakecase} 需要引用某个捕获组
  }
}
```

这是一个巧妙的方法，可以在光标处插入 `${fileBasenameNoExtension}` 的 SCREAMING_SNAKE_CASE 版本：

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "description": "插入 fileBaseName 并更改为 SCREAMING_SNAKE_CASE",
    "replace": ["${fileBasenameNoExtension}", "\\U${1:/snakecase}"],
    "isRegex": true // 必需，因为 ${1:/snakecase} 需要引用某个捕获组
  }
}
```

上面的工作原理是执行 2 个替换（没有 find）。首先，在光标处插入 `${fileBasenameNoExtension}`，然后将其（因为它已预先选定）替换为大写的蛇形命名法版本。

[插入 SCREAMING_SNAKE_CASE 文件名]

**注意**：当 `isRegex` 设置为 `true` 并且您使用如下设置时：

```json
"args": {
  "find": "(trouble)", // 仅捕获组 1
  // "find": "trouble", // 没有捕获组！，同样糟糕的结果
  "replace": "\\U$2", // 但使用了捕获组 2！！，因此用空替换
  // "replace": "${2:/pascalcase}", // 同样糟糕的结果，引用了不存在的捕获组 2
  "isRegex": true
}
```

您实际上将匹配项 `trouble` 替换为空，因此所有匹配项将从您的代码中消失。这是正确的结果，因为您选择了匹配某些内容并用其他可能不存在的内容替换它。

如果 `isRegex` 设置为 `false`（与根本不设置相同），替换值，即使像 `\\U$2` 这样的值，也将被解释为字面纯文本。

### 将 restrictFind 与 matchAroundCursor 选项结合使用

键盘绑定示例：

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "find": "<(Element)(>[\\s\n\\S]*?<\/)(Element)>", // $1 和 $3 捕获组 = Element
    "isRegex": true,
    "replace": "<\\U$1$2\\U$3>", // \\U$1 = 将组 1 大写
    "restrictFind": "matchAroundCursor"
  }
}
```

上面的键盘绑定将选择整个 Element 并将组 1 和 3 大写，结果看起来像：

```html
<ELEMENT>
  stuff
  more stuff
</ELEMENT>
```

`matchAroundCursor` 将选择任何**围绕光标**的查找匹配项。在上面的示例中，光标只需位于与查找匹配的文本中的某个位置。此选项可用于使用单个正则表达式快速提取文本块。然后可以在 `replace` 或 `run` 参数中操作该文本块。

您还可以将 `cursorMoveSelect` 参数与 `matchAroundCursor` 的结果一起使用。

例如，这个 `run` 参数将获取所选文本——比如来自查找匹配的文本——并创建一个包含该粘贴文本的新文件：

```json
"run": [
  "$${",
  "let block = '```';", // 开始一个代码围栏
  "block += document.languageId;", // 使用当前编辑器的 languageId 作为代码围栏语言
  "block += `\\n\\t${selectedText}\\n`;", // 去掉尾随换行符？
  "block += '```';", // 结束代码围栏
  "vscode.env.clipboard.writeText(block);", // 将该文本写入剪贴板
  "vscode.commands.executeCommand('workbench.action.files.newUntitledFile');", // 打开新文件
  "vscode.commands.executeCommand('editor.action.clipboardPasteAction');", // 粘贴到新文件
  // 返回原始文件
  "vscode.commands.executeCommand('workbench.action.openPreviousRecentlyUsedEditor');",
  "}$$"
]
```

### restrictFind 和 cursorMoveSelect 参数的详细信息

键盘绑定示例：

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "find": "FIXME", // 或使用光标处的单词
    "replace": "DONE",
    "restrictFind": "nextDontMoveCursor"
    // "cursorMoveSelect": "FIXME" // 使用 'next...` 选项时将被忽略
  }
}
```

[更改设置后保存的通知]

所有这些都将显示替换，以便您可以看到更改，但不一定移动光标。

*   `"restrictFind": "nextDontMoveCursor"` 进行下一个替换，但将光标留在原始位置。
*   `"restrictFind": "nextMoveCursor"` 进行下一个替换并将光标移动到下一个替换匹配项的末尾。不选择。
*   `"restrictFind": "nextSelect"` 进行下一个替换并选择它。
*   `"restrictFind": "previousDontMoveCursor"` 进行上一个替换，但将光标留在原始位置。
*   `"restrictFind": "previousMoveCursor"` 进行上一个替换并将光标移动到上一个替换匹配项的开头。不选择。
*   `"restrictFind": "previousSelect"` 进行上一个替换并选择它。

`next...` 和 `previous...` 选项将**换行**。这意味着例如，如果在光标之后文档中没有匹配项，则将使用文档开头的第一个匹配项（当使用 `next...` 选项时）。

使用上述 `restrictFind` 选项时，将忽略 `cursorMoveSelect` 选项。

并且上述选项目前不适用于多个选择。只有文档中**第一个**选择将用作查找值——因此您进行选择的顺序很重要。如果您从文档底部向上进行多个选择，则将使用第一个选择（它将出现在其他选择之后）。

您可以将 `cursorMoveSelect` 选项与下面的 `restrictFind` 选项一起使用。

*   `"restrictFind": "document"` 默认，在文档中进行所有替换，选择所有替换项。
*   `"restrictFind": "onceIncludeCurrentWord"` 仅从当前单词的开头进行下一个替换，仅在同一行。
*   `"restrictFind": "onceExcludeCurrentWord"` 仅从光标之后进行下一个替换，仅在同一行。
*   `"restrictFind": "line"` 在光标所在的当前行进行所有替换。
*   `"restrictFind": "selections"` 仅在选定内容中进行所有替换。

请注意，对于上述所有情况，替换文本可能包含更多或更少的换行符，因此尽管查找发生在一行上，但 `cursorMoveSelect` 匹配实际上可能发生在不同的行上。这没关系，整个替换文本都将被匹配，无论其部分是否在同一行或后续行上。

**新的 `once...` restrictFind 值。`once` 已弃用**：

`restrictFind` 的 `once` 参数正在被弃用，取而代之的是两个相关值：`onceExcludeCurrentWord` 和 `onceIncludeCurrentWord`。`onceExcludeCurrentWord` 的功能与 `once` 完全相同，搜索文本严格从光标位置开始——即使光标在单词中间。这允许您在查找或替换中使用 `${TM_CURRENT_WORD}` 而不实际更改当前单词，而是更改下一个实例。但有时您确实希望更改当前单词，那么 `onceIncludeCurrentWord` 就是您想要的。然后光标处的整个单词成为搜索文本的一部分，它将根据您的键盘绑定/设置被选择或替换。

`cursorMoveSelect` 选项接受任何文本作为其值，包括解析为文本的任何内容，如 `$` 或任何变量。该文本（可以是先前替换的结果）将在替换后被搜索，光标将移动到那里并且该文本将被选择。如果您的命令/键盘绑定中有 `"isRegex": true`，那么 `cursorMoveSelect` 将被解释为正则表达式。`matchCase` 和 `matchWholeWord` 设置将同时适用于 `cursorMoveSelect` 和查找文本。

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "find": "(trouble)",
    "replace": "\\U$1",
    "isRegex": true,
    // "matchWholeWord": true,           // 同时适用于查找和 cursorMoveSelect
    // "matchCase": true,                // 同时适用于查找和 cursorMoveSelect
    // 仅当在行首时才选择：^
    "cursorMoveSelect": "^\\s*pa[rn]am", // 将被解释为正则表达式，因为 'isRegex' 为 true
    "restrictFind": "line", // 在进行替换后，在当前行上选择 'pa[rn]am'
    // "restrictFind": "selections",     // 仅在选定内容中选择 'pa[rn]am'
    //  "restrictFind": "line",
    // "cursorMoveSelect": "^"           // 光标将移动到行首
    // "cursorMoveSelect": "$"           // 光标将移动到行尾（替换后，可能包含换行符）
    //  "restrictFind": "onceIncludeCurrentWord/onceExcludeCurrentWord",
    // "cursorMoveSelect": "^"           // 光标将移动到第一个匹配项的开头（替换后）
    // "cursorMoveSelect": "$"           // 光标将移动到第一个匹配项的末尾（替换后）
    // "restrictFind": "selections",
    // "cursorMoveSelect": "^"           // 光标将移动到每个选择的开头
    // "cursorMoveSelect": "$"           // 光标将移动到每个选择的末尾
    // 选择是有方向的，
    // 光标将移动到开始或结束（结束是原始选择中光标的位置）
  }
}
```

注意 `^` 和 `$` 适用于 restrictFind 选择/行/onceIncludeCurrentWord/onceExcludeCurrentWord/文档。

*   `cursorMoveSelect` 将选择每个选择中的所有匹配项，前提是同一选择中存在匹配项。
*   `cursorMoveSelect` 将使用 `restrictFind : onceIncludeCurrentWord` 或 `onceExcludeCurrentWord` 选择第一个 `cursorMoveSelect` 匹配项，前提是在同一行上有查找匹配项，并且在 `cursorMoveSelect` 匹配项之前。因此，首先是查找匹配项，然后是同一行上之后的 `cursorMoveSelect` 匹配项。
*   `cursorMoveSelect` 将选择文档中的所有 `cursorMoveSelect` 匹配项，前提是有查找匹配项，并且仅在查找匹配项的范围内！这看起来像是一个限制，但它使得使用 `postCommands` 实现一些不错的功能成为可能。
*   `cursorMoveSelect` 将使用 `restrictFind : line` 选择行上的所有匹配项，前提是同一行上有匹配项。

当您将 `cursorMoveSelect` 参数用于 `restrictFind: document` 或 `restrictFind` 键的 `nextMoveCursor` 或 `nextSelect` 选项时，假定您确实想转到那里并查看结果。因此，如果该匹配行当前在编辑器的视口中不可见，编辑器将滚动以显示该行。对于选择/行/onceIncludeCurrentWord/onceExcludeCurrentWord，将不会发生滚动——假定您已经可以看到结果匹配（唯一可能不成立的情况是如果您有一个超出屏幕的长选择）。

**注意**：如果没有 `find` 并且没有 `replace`，或者有 `find` 但没有 `replace`，则忽略 `cursorMoveSelect` 参数。

### 一些 `"restrictFind": "next...` 选项示例

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "find": "FIXME",
    "replace": "DONE!",
    "restrictFind": "nextMoveCursor"
  }
}
```

[带有 find 和 replace 的 nextMoveCursor]

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    "find": "FIXME",
    "replace": "DONE!",
    "restrictFind": "nextSelect"
  }
}
```

[带有 find 和 replace 的 nextSelect]

```json
{
  "key": "alt+r",
  "command": "findInCurrentFile",
  "args": {
    // "find": "FIXME",                 // !! 没有 find 或 replace !!
    // "replace": "DONE",
    "restrictFind": "nextMoveCursor" // 或在此处尝试 `nextSelect`
  }
}
```

[没有 find 或 replace 的 nextMoveCursor]

上面解释：没有 `find` 参数时，将使用光标处最近的单词（更多信息见下文）作为查找值。因此，在上面的示例中，`FIXME` 将用作查找查询。并且使用 `nextMoveCursor` 光标将移动到下一个匹配项。这里也可以使用 `nextSelect`。

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    // "find": "$",             // 依次转到每一行的末尾 '$'
    // 转到非空行的末尾 '$' - 使用正向向后查找 - 一次一个
    "find": "(?<=\\w)$",
    "replace": "-${lineNumber}", // 在匹配项（行的末尾）插入行号（基于 1）
    // "replace": "${lineIndex}",   // 在匹配项（行的末尾）插入行索引（基于 0）
    "isRegex": true,
    "restrictFind": "nextSelect"
    // 注意在演示中，nextSelect/nextMoveCursor/nextDontMoveCursor 将换行回文件开头
  }
}
```

[演示在有内容的行末尾放置行号并换行回文件开头]

上面解释：查找非空行的末尾并追加 `-` 和该行号。`nextSelect` => 一次一个。

```json
{
  "key": "alt+n",
  "command": "findInCurrentFile",
  "args": {
    // "description": "将 'first' 或 'second' 一次一个地大写",
    "find": "(first|second)",
    "replace": "\\U$1",
    "isRegex": true,
    "matchCase": true, // 如果不移动光标则是必需的，因此不选择相同的条目
    "restrictFind": "nextSelect"
  }
}
```

### 示例设置

注意：您可以在设置中创建的命令，可以通过删除或注释掉相关设置并重新保存 settings.json 文件并重新加载 VS Code 来移除。

在您的 settings.json 中：

```json
"findInCurrentFile": { // 在当前文件或选择中执行查找/替换
  "upcaseSwap2": { // <== 可在键盘绑定中使用的“名称”，不能有空格
    "title": "swap iif <==> hello", // 将出现在命令面板中的标题
    "find": "(iif) (hello)",
    "replace": "_\\u$2_ _\\U$1_", // 双重转义的大小写修饰符
    "isRegex": true,
    "restrictFind": "selections"
  },
  "capitalizeIIF": {
    "title": "capitalize 'iif'", // 所有设置必须有 "title" 字段
    "find": "^(iif)",
    "replace": "\\U$1",
    "isRegex": true
  },
  "addClassToElement": {
    "title": "Add Class to Html Element",
    "find": ">",
    "replace": " class=\"@\">",
    "restrictFind": "selections",
    "cursorMoveSelect": "@" // 替换后，移动到此文本并选择它
  }
}
```

```json
// 使用搜索面板执行搜索/替换，可选地在当前文件/文件夹/工作区等中
"runInSearchPanel": { // 在键盘绑定中用作命令名的第一部分
  "removeDigits": { // 在键盘绑定中使用，因此不允许空格
    "title": "Remove digits from Art....",
    "find": "^Arturo \\+ \\d+", // 双重转义的 '+' 和 '\d'
    "replace": "",
    "triggerSearch": "true",
    "isRegex": true
  }
}
```

如果您不包含 `title` 值，将使用名称（如上面最后一个示例中的 `removeDigits`）创建一个。然后您可以在命令面板中查找 `Find-Transform:removeDigits`。由于在最后一个示例中提供了标题，您将在命令面板中看到 `Find-Transform: Remove digits from Art....`。所有命令都在 `Find-Transform:` 类别下分组。

在 .code-workspace 文件中（用于多根工作区）：

```json
{
  "folders": [
    {
      "path": ".."
    },
    {
      "path": "../../select-a-range"
    }
  ],
  "settings": {
    "findInCurrentFile": {
      "bumpSaveVersion": { // 在 codeActionsOnSave 设置中使用此名称
        "title": "bump the save version on each save",
        "find": "(?<=#### Save Version )(\\d+)",
        "replace": "$${ return $1 + 1 }$$",
        "isRegex": true,
        "ignoreWhiteSpace": false,
        "matchCase": false
      }
    },
    "runInSearchPanel": {
      "inSearchPanel": {
        "title": "some title",
        "ignoreWhiteSpace": false,
        "delay": 2000,
        "isRegex": true,
        "matchCase": false,
        "useExcludeSettingsAndIgnoreFiles": true,
        "triggerSearch": true
      }
    }
  }
}
```

### 示例键盘绑定

键盘绑定示例（在您的 keybindings.json 中）：

```json
// 下方：根据设置中的命令生成的键盘绑定
{
  "key": "alt+u",
  "command": "findInCurrentFile.upcaseKeywords" // 来自设置
} // 此处的任何 "args" 将被忽略，它们在设置中

// 下方：通用的 "findInCurrentFile" 键盘绑定命令，运行这些无需任何设置
{
  "key": "alt+y",
  "command": "findInCurrentFile", // 注意没有命令名的第二部分
  "args": { // 必须在此处设置 "args"，因为没有关联的设置命令
    "find": "^(this)", // 注意 ^ = 选择的开始，因为 restrictFind = selections
    // 或 ^ = 选择内行的开始
    // "find": "^(${CLIPBOARD})", // 如果剪贴板上有 'this'，则结果相同
    // 记住在您的 find 中使用匹配的捕获组！
    "replace": "\\U$1",
    // "replace": "${1:/upcase}", // 同 '\\U$1'
    "isRegex": true,
    "matchCase": true,
    "restrictFind": "selections",
    "cursorMoveSelect": "THIS" // 将选择此文本；"$" 转到所有选择的末尾
  }
}
```

#### 在 find 中使用 `${lineNumber}` 或 `${lineIndex}`：

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    "find": "(${lineNumber})", // 查找其行上匹配的行号
    // 因此查找第 1 行上的 1，查找第 20 行上的 20
    "replace": "$${ return `found ` + ($1 * 10) }$$",
    // 第 1 行上的 1 => 'found 10'
    // 第 20 行上的 20 => 'found 200'
    // 下方演示
    "replace": "$${ if ($1 <= 5) return $1 / 2; else return $1 * 2; }$$",
    // 如果数字在其行号上，例如第 5 行上的 5 = 查找匹配
    // 如果该匹配 <= 4 则返回该行号 / 2
    // 否则返回该行号 * 2
    "isRegex": true
  }
}
```

[行号匹配]

保存对设置的更改时，您将收到以下消息通知。此扩展将检测其设置的更改并创建相应的命令。如果不保存新设置并重新加载 vscode，命令将不会出现在命令面板中。

[更改设置后保存的通知]

没有关联设置的键盘绑定示例，在 keybindings.json 中：

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile", // 注意此处没有设置命令，如 findInCurrentFIle.removeDigits
  "args": {
    // 支持多行正则表达式 ^ 和 $，"m" 标志自动应用于所有搜索
    // 如果在选择中查找，'^' 指选择的开始，而不是行的开始
    // 如果在选择中查找，'$' 指选择的结束，而不是行的结束
    "find": "^([ \\t]*const\\s*)(\\w*)", // 注意双重转义
    "replace": "$1\\U$2", // 将 "const" 后面的单词大写
    "isRegex": true,
    "restrictFind": "selections" // 仅在选择中查找
  }
}
```

[通用 findInCurrentFile 键盘绑定演示]

通过这种方式，您可以指定一个键盘绑定来运行通用的 `findInCurrentFile` 命令，所有参数都直接在键盘绑定中，而不在其他任何地方。没有关联的设置，并且此版本无需重新加载 vscode 即可工作。您可以拥有无限数量的键盘绑定（当然，具有单独的触发键和/或 when 子句）使用 `findInCurrentFile` 版本。

此方法的缺点是，这些仅键盘绑定的 `findInCurrentFile` 版本无法通过命令面板找到。

#### “光标处的最近单词”

**重要提示**：什么是“光标处的最近单词”？在 VS Code 中，紧挨着单词或位于单词内的光标是一个选择（即使可能没有实际选择文本！）。此扩展利用这一点：如果您运行一个没有 `find` 参数的 `findInCurrentFile` 命令，它将把所有“光标处的最近单词”视为您要查找这些单词。实际选择和“光标处的最近单词”可以通过使用多个光标混合，它们都将在文档中搜索。似乎光标处的单词通常定义如下：`\b[a-zA-Z0-9_]\b`（请查阅给定语言中的单词分隔符），尽管某些语言可能定义不同。

如果光标在空行上或靠近非单词字符，根据定义没有“光标处的最近单词”，此扩展将简单地为此类光标返回空字符串。

因此，光标位于 `FIXME` 的开头或结尾或单词内的任何位置，`FIXME` 是光标处的单词。`FIXME-Soon` 由两个单词组成（在大多数语言中）。如果光标跟在 `FIXME*` 中的 `*` 后面，则 `FIXME` 不是光标处的单词。

这在下面的一些演示中展示。

#### 在 keybindings.json 中通用的运行命令，args 中没有 find 或 replace 键

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile"
}
```

[args 中没有 find 和没有 replace 键的演示]

上面解释：没有 `find` 键时，查找选择或光标处的最近单词的匹配项（多光标有效）并选择所有这些匹配项。蓝色文本是演示 gif 中的选择。

**重要提示**：如果没有 `find` 键并且有多个选择，则此扩展将使用所有这些选择创建查找查询。生成的查找将采用以下形式：`"find": "(word1|word2|other selected text)"`。注意使用了交替管道 `|`，因此可以找到任何这些选定的单词。因此，文件中的查找或跨文件查找必须启用正则表达式标志。因此，如果您有多个选择而没有 `find` 键，将自动设置 `"isRegex": true`——可能覆盖您在设置或键盘绑定中的设置。

只有当您选择的文本生成了本身包含正则表达式特殊字符（如 `.?*^$` 等）的查找项时，才会出现问题。它们将不会被当作文字字符，而是按其通常的正则表达式功能处理。

如果您不使用 `find` 但选择了希望被视为正则表达式的文本（如 `\n text (\d)`），请不要双重转义那些特殊的正则表达式字符。只需使用与查找小部件中相同的正则表达式。记住在这种情况下将 `isRegex` 设置为 `true`。

最后，如果您选择了同一文本的多个实例，生成的查找项将移除任何重复项。`Set.add()` 是一件美好的事情。

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    "matchCase": true,
    "restrictFind": "nextSelect"
  }
}
```

以上将重复选择光标下的下一个匹配单词（`'matchCase'` 选项由您决定）。

#### 有 find 和 replace 键但没有 restrictFind

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    "find": "(create|table|exists)",
    "replace": "\\U$1",
    "isRegex": true
  }
}
```

[args 中有 find 和 replace 键的演示]

上面解释：根据 args 字段中的值进行查找和替换每个。由于没有 `restrictFind` 键，将使用默认的 `document`。

#### 有 find 和 replace 且 `"restrictFind": "selections"`

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    "find": "(create|table|exists)", // 查找这些单词中的每一个
    "replace": "_\\U$1_", // 用 _捕获组 1_ 大写替换
    "isRegex": true,
    "restrictFind": "selections",
    "cursorMoveSelect": "TABLE" // 仅当 TABLE 在选择内时才会选择它
  }
}
```

[使用 restrictFind 'selection' 和 'cursorMoveSelect 的演示]

上面解释：使用 `restrictFind` 参数设置为 `selections`，查找将仅在任意选择内发生。选择可以是多个，并且选择确实包括“光标处的最近单词”。使用 `cursorMoveSelect` 选择所有 `TABLE` 的实例。

注意上面演示中的细微差别。如果您对单词进行实际的完整选择，则仅搜索该选择内的文本。但如果您进行“最近单词”类型的选择（光标在单词中或旁边），那么文档中的所有匹配单词都将被搜索，即使它们不在自己的选择中。如果您希望将搜索限制在某个选择中，请进行实际选择——不要依赖最近单词功能。

如果 `restrictFind` 未设置为任何值，则默认为 `document`。因此将搜索整个文档，并忽略任何选择，因为已设置了查找。请记住，如果没有设置 `find`，那么任何选择都将被解释为查找值。
上面的键盘绑定与此设置（在您的 settings.json 中）没有什么不同：

```json
"findInCurrentFile": {
  "upcaseSelectedKeywords": {
    "title": "Uppercase selected Keywords", // 设置中需要 "title"
    "find": "(create|table|exists)",
    "replace": "_\\U$1_",
    "isRegex": true,
    "restrictFind": "selections",
    "cursorMoveSelect": "TABLE"
  }
}
```

除了在使用此设置的生成命令之前需要重新加载 vscode（键盘绑定无需重新加载），并且标题（在本例中为 `"Uppercase selected Keywords"`）将出现并可在命令面板中搜索（对于键盘绑定“命令”则不成立）。

#### 有 find 但没有 replace 键

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    "find": "(create|table|exists)",
    "isRegex": true
  }
}
```

[有 find 但没有 replace 键的演示]

上面解释：将根据 `find` 值进行查找并选择所有匹配项。不替换。

#### 有 find 但没有 replace，且 `"restrictFind": "selections"`

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    "find": "(create|table|exists)",
    // "replace": "_\\U$1_",
    "isRegex": true,
    "restrictFind": "selections"
  }
}
```

[使用 restrictFind 参数为 'selection' 的演示]

上面解释：使用 `restrictFind` 参数设置为 `selections`，查找将仅在任意选择内发生。选择内的所有查找匹配项将被选择。

如果您设置了 `"restrictFind": "document"`，文件中任何实际选择都将被忽略，查找/替换将应用于整个文件。

#### 有 replace 键但**没有** find 键

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    // "find": "(create|table|exists)",
    "replace": "\\U$1",
    "isRegex": true,
    "matchWholeWord": true
  }
}
```

[有 replace 但没有 find 键的演示]

上面解释：没有 `find` 值时，查找光标处或选择的所有单词并应用替换。

在没有 `find` 但替换中有捕获组（如上一个示例）的键盘绑定/设置中，`isRegex` 参数可以以两种方式工作：

*   `true`：光标处的单词（或更可能是选择）被视为正则表达式。因此它可能包含特殊的正则表达式字符，如 `*^$?!.[]()\.`。示例：`find*me` 以便找到 `findme` 或 `finddddme` 或 `finme`。
*   `false`：光标处的单词（或更可能是选择）**不**被视为正则表达式。它被视为纯文本，因此任何特殊的正则表达式字符都将被转义，以便可以对该文本执行正则表达式匹配——因为替换中可能包含捕获组引用，如 `$1`。示例：`find*me` 变成 `find\*me`，以便搜索字面文本 `find*me`。

### 演示替换后的 cursorMoveSelect

```json
"findInCurrentFile": { // 在 settings.json 中
  "addClassToElement": {
    "title": "Add Class to Html Element",
    "find": ">",
    "replace": " class=\"@\">",
    "isRegex": true,
    "restrictFind": "onceExcludeCurrentWord",
    "cursorMoveSelect": "@" // 选择下一个 '@'
  }
}
```

```json
{ // 上述设置的键盘绑定
  "key": "alt+q", // 您想要的任意键
  // 输入 `findInCurrentFile.` 后应获得可用设置命令的智能感知
  "command": "findInCurrentFile.addClassToElement"
  // "when": ""                     // 可以在这里使用
  // "args": {}                     // 将被忽略，设置中的参数规则
}
```

[使用 cursorMoveSelect 参数和 restrictFind 为 'onceExcludeCurrentWord' 的演示]

上面解释：在选择中查找第一个 `>` 并将其替换为 `class=\"@\">`。然后将光标移动到 `@` 并选择它。`cursorMoveSelect` 值可以是任何文本，甚至是正则表达式分隔符 `^` 和 `$`。

*   `"restrictFind": "onceExcludeCurrentWord"` => 查找光标**之后**查找查询的第一个实例（因此如果光标在单词中间，则仅单词的一部分在光标之后），替换它，然后转到并选择 `cursorMoveSelect` 值（如果有）。多个光标同样有效。
*   `"restrictFind": "onceIncludeCurrentWord"` => 查找从当前单词**开头**开始的查找查询的第一个实例（因此如果光标在单词中间，将搜索整个单词），替换它，然后转到并选择 `cursorMoveSelect` 值（如果有）。多个光标同样有效。
*   `"restrictFind": "line"` => 查找有光标的整行上查找查询的所有实例，替换它们，然后转到并选择所有 `cursorMoveSelect` 值（如果有）。如果多个光标，则在每一行上工作。但它只考虑光标所在的行，因此如果有跨多行的选择，则只搜索有光标的行。

#### `${matchNumber}` 和 `${matchIndex}`

这些变量可以在替换和/或 `cursorMoveSelect` 位置使用。不能在 `find` 中使用它们。

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    "find": "text$", // 查找以 text 结尾的行
    "replace": "text_${matchIndex}", // 替换为 'text_' 然后是匹配索引（基于 0）
    "isRegex": true,
    "cursorMoveSelect": "${matchIndex}" // 现在选择每个匹配编号
    // 如果您不希望文本被选中，只需右箭头或左箭头以取消选择
    // 但保持所有多个光标。
  }
}
```

[使用 ${matchIndex} 和 cursorMoveSelect 的演示]

上面解释：这种情况下的匹配是 `"text$"`（行尾的 'text'）。匹配的第一个实例有 `matchNumber = 1`，这将用于替换。`${matchIndex}` 相同但是基于 0。

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    "find": "(text)", // 捕获组 1
    "replace": "\\U$1_${matchNumber}", // 将组 1 大写并添加 _ 然后是匹配编号
    "isRegex": true,
    "cursorMoveSelect": "${matchNumber}" // 选择每个实例的 matchNumber 部分
  }
}
```

[使用 ${matchNumber} 和大小写转换的演示]

### reveal 选项

`findInCurrentFile` 命令的 `reveal` 参数可以采用三个选项：

*   `"reveal": "first"` 将视口滚动到显示文档中的第一个查找匹配（如果需要）。
*   `"reveal": "next"` 将视口滚动到显示光标之后文档中的下一个查找匹配（如果需要）。
*   `"reveal": "last"` 将视口滚动到显示文档中的最后一个查找匹配（如果需要）。

如果您不希望编辑器滚动以显示任何查找匹配，只需根本不包含 `reveal` 选项。某些其他参数，如 `"restrictFind": "nextMoveCursor/previousMoveCursor/previousSelect/nextSelect/nextDontMoveCursor/previousDontMoveCursor"` 等将总是滚动显示，即使没有 `reveal` 参数。

**注意**：如果您的键盘绑定或设置中有 `cursorMoveSelect` 参数，`reveal` 参数将无效。`cursorMoveSelect` 将优先。

### 使用 ignoreWhiteSpace 参数

`ignoreWhiteSpace` 参数（布尔值）将更改 `find` 值，以便 `find` 中的任何空白都将被视为 `\s*`。并且将修改查找正则表达式，以便您不需要显式指定 `\n` 字符来识别换行符。换句话说，`find` 值中的任何空白字符都将导致查找正则表达式跨行工作。使用这些参数：

```json
"find": "someWord-A someWord-B",
"ignoreWhiteSpace": true,
"isRegex": true
```

将匹配如下文本：

```
someWord-A        someWord-B

  someWord-A

  someWorb-B
```

因此，它将匹配任何连续的 `'someWord-A'` 和 `'someWord-B'`，只要它们之间只有某种空白，无论是空格、制表符、换行符等。

`ignoreWhiteSpace` 参数也可以用于跨文件搜索。

### 使用 preserveSelections 参数

这是一个布尔选项——默认为 `false`。

通常，所有查找匹配项都被选中，从而丢失运行命令之前可能存在的任何光标位置或其他选择。这确实允许其他选项，如 `replace`、`run` 或甚至 `postCommands` 以许多有趣的方式使用这些查找匹配项（即选择）。

但是，您可能不需要该功能（这是默认功能）。也许您正在进行查找和替换，无需检查查找匹配项，因此希望保留所有现有选择和光标位置。如果是这样，请设置 `"preserveSelections: true"`。不过，选择查找匹配项的一个明显优势是使文档中实际发生更改的位置更加明显。

对于某些选项，`preserveSelections` 没有效果。例如，如果您有 `find` 但没有 `replace`（或没有 `find` 也没有 `replace`），则无论 `preserveSelections` 设置如何，都将选择查找匹配项。如果您使用 `cursorMoveSelect` 参数，那么其匹配项自然会被选择。如果您正在使用其中一个 `next/previous` 选项，则 `preserveSelections` 没有效果，因为这些选项要求新的选择或已经防止光标移动。

**注意**：非固定长度（有时也称为固定宽度）的正则表达式向后查找，如 `(?<=^Art[\w]*)`，在搜索面板中不受支持。但是，非固定长度的向后查找在 vscode 的文件内查找（如使用查找小部件）中受支持，因此可以在 `findInCurrentFile` 设置或键盘绑定中使用。

这有效：

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    "find": "(?<=^Art[\\w]*)\\d+", // 不是固定长度，但在 findInCurrentFile 中没问题
    "replace": "###",
    "isRegex": true
  }
}
```

但相同的键盘绑定在 `runInSearchPanel` 中将出错且不产生任何结果：

```json
{
  "key": "alt+y",
  "command": "runInSearchPanel", // runInSearchPanel
  "args": {
    "find": "(?<=^Art[\\w]*)\\d+", // 不是固定长度：错误，不会运行
    "replace": "###",
    "isRegex": true
  }
}
```

上面的命令将 `(?<=^Art[\w]*)\d+` 放入搜索面板查找输入，将 `###` 放入替换，但在实际触发时会出错。

### 匹配空行

您可以使用此键盘绑定匹配文档中的所有空行：

```json
{
  "key": "alt+l",
  "command": "findInCurrentFile",
  "args": {
    "replace": "Found empty line.  Match number: ${matchNumber}" // 替换是可选的
  }
}
```

并将光标放在任何空行上。它们将被匹配和替换。如果您没有 `replace`，则所有空行都将放置一个光标。这仅在搜索整个文档时有效。

使用以下键盘绑定，您可以轻松转到下一个匹配的单词（注意没有 `find`）。因此，如果您的光标从空行开始，它将匹配下一个空行。如果您的光标从单词开始，则光标将转到该单词。

```json
{
  "key": "alt+l",
  "command": "findInCurrentFile",
  "args": {
    // 也适用于 nextMoveCursor 或 nextDontMoveCursor 或 previousMoveCursor 或 previousDOntMoveCursor
    "restrictFind": "nextSelect", // 或 previousSelect 等
    "replace": "Found empty line." // 替换是可选的
    // 但移动到替换会改变“光标处的单词”，从而改变查找！！
    // 因此，如果您使用替换，'nextDontMoveCursor' 可能是更好的选择，以便光标
    // 停留在空行上（替换后）
  }
}
```

并且，如果您希望在您的选择内的所有空行上放置光标，请使用此键盘绑定：

```json
{
  "key": "alt+y",
  "command": "findInCurrentFile",
  "args": {
    "find": "^$",
    "isRegex": true,
    "restrictFind": "selections"
  }
}
```

如果您想查找两个连续的空行，请使用 `(^$)\n(^$)`。对于三个空行，请使用 `(^$)\n(^$)\n(^$)`。

### 待办事项

*   添加更多错误消息，例如，如果在替换中使用了捕获组，但查找中没有。
*   内部修改替换键名以避免 `string.replace` 的变通方法。
*   探索添加命令 `setCategory` 设置。为搜索面板命令单独的类别？
*   支持 `findInCurrentFile` 中的 `preserveCase` 选项。
*   检查 `cursorMoveSelect` 和 `${TM_CURRENT_LINE}` 交互。
*   处理冗余的“扩展已在磁盘上修改。请重新加载...”通知。
*   实现连续的 `${getFindInput}` 输入框。

### 发行说明

参见 CHANGELOG 获取先前版本的说明。

*   **5.3.0** 使 codeActions 更好地工作（包括多个操作）。- editBuilder awaits 已添加。
    *   5.3.1 - 添加 reveal 选项到 findAndSelect。
    *   5.3.3 - 修复空行查找。
    *   5.3.4 - 添加 columnNumber 变量。
*   **5.2.0** 从 CompletionProvider 切换到 JSON Schema 用于键盘绑定/设置。
    *   修复 `[\n]` 在正则表达式中被替换为 `[\r?\n]` 的问题。
    *   5.2.1 - 修复 next/previous ^/$/^$。在 resolveFind 中更多 vscode.EndOfLine.CRLF。
    *   5.2.2 - 添加通用的 next/previous 大小写处理回来。
    *   5.2.3 - 更好地处理字符类内外的 `[\n]`。
*   **5.1.0** 启用了在一个参数中多次使用 `${getInput}`。添加了 regex.js 用于常用正则表达式。
    *   修复 lineNumber/Index 匹配。
    *   修复 matchAroundCursor 错误 - 设置 regex true。
    *   5.1.3 修复 next/previous 错误 - 再次计算 cursorIndex。
*   **5.0.0** 大量工作使代码更异步。使用 replaceAsync。
    *   `${getInput}` 正在取代 `${getFindInput}`。它现在在 replace、run、postCommands、cursorMoveSelect、filesToInclude 和 filesToExclude 参数中有效。
    *   添加了 `${/}` 路径分隔符变量。
    *   处理匹配空行。
    *   处理跟踪带有换行符的多个替换。
*   **4.8.0** 添加了 preserveSelections 参数。补全在 .code-workspace（工作区设置）文件中有效。
    *   4.8.2 修复了使用 `${getFindInput}` 时的转义问题。
    *   4.8.3 减少不在 replace/run 中的变量替换的转义。
    *   4.8.4 处理没有 find 且 isRegex 为 true 或 false 时替换中的捕获组。
*   **4.7.0** 添加了 ignoreWhiteSpace 参数。
    *   添加了 `${getFindInput}` 变量用于查找查询。
    *   添加了 `runWhen` 参数以控制何时触发 run 操作。
    *   添加了 `"restrictFind": "matchAroundCursor"` 选项。
    *   4.7.1 添加了 runPostCommands 和 resolvePostCommandVariables。添加了命令以允许从补全详细信息打开 readme 锚点。
    *   4.7.2 添加了 .code-workspace 设置的智能感知。