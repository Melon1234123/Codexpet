# Terminal Gremlin

Terminal Gremlin 是一个给 Codex Desktop 使用的自定义宠物。它是 hatch-pet 标准格式的产物，包含 `pet.json` 和 `spritesheet.webp` 两个核心文件，安装后会作为 `custom:terminal-gremlin` 出现在 Codex 的宠物系统里。

## 它可以做什么

Terminal Gremlin 不是一个独立运行的程序，也不会替你执行命令。它的作用是作为 Codex 界面里的动态陪伴角色，根据 Codex 当前状态展示不同动画，让你更直观地看到任务进度。

它包含 9 组状态动画。机身整体保持黑灰终端外壳，状态差异主要体现在屏幕和表情的主色上：

| 状态 | 主状态色 | 用途 |
|---|---|---|
| `idle` | 睡眠蓝，约 `#80B0FF` | 空闲时待机，保持轻微呼吸和屏幕感的动态。 |
| `running-right` | 终端青，约 `#10E0E0` | 宠物在界面中向右移动或被拖动时使用。 |
| `running-left` | 终端青，约 `#10E0E0` | 宠物在界面中向左移动或被拖动时使用。 |
| `waving` | 亮绿色，约 `#10D010` | 打招呼或给出轻量反馈时使用。 |
| `jumping` | 霓虹紫，约 `#B050F0` | 完成动作、确认反馈或强调状态变化时使用。 |
| `failed` | 故障红，约 `#FF1010` | 任务失败、命令报错或遇到阻塞时使用。 |
| `waiting` | 琥珀橙，约 `#FFB000` | Codex 等待用户输入、确认或下一步指令时使用。 |
| `running` | 工作橙，约 `#FFA000` | Codex 正在工作、思考、运行任务或处理文件时使用。 |
| `review` | 审核绿，约 `#80F050` | Codex 正在检查代码、阅读内容、做 review 或核对结果时使用。 |

换句话说，它会把 Codex 的“正在工作、等待你、检查结果、失败了、打招呼”等状态变成一个小终端宠物的动画反馈。

## 一键配置

安装脚本会自动完成三件事：

1. 找到 Codex 配置目录：优先使用 `CODEX_HOME`，否则使用当前用户的 `.codex` 目录。
2. 把宠物复制到 `${CODEX_HOME:-$HOME/.codex}/pets/terminal-gremlin/`。
3. 把 Codex Desktop 的宠物选择设置为 `custom:terminal-gremlin`。

安装后重启 Codex Desktop 即可生效。

### Windows

在 PowerShell 里运行：

```powershell
irm https://raw.githubusercontent.com/Melon1234123/Codexpet/main/install.ps1 | iex
```

### macOS / Linux

在终端里运行：

```bash
curl -fsSL https://raw.githubusercontent.com/Melon1234123/Codexpet/main/install.sh | sh
```

## 手动安装

如果你不想运行脚本，也可以手动安装：

1. 下载或克隆这个仓库。
2. 把 `terminal-gremlin` 文件夹复制到 Codex 的宠物目录。

Windows 默认路径：

```text
%USERPROFILE%\.codex\pets\terminal-gremlin
```

macOS / Linux 默认路径：

```text
~/.codex/pets/terminal-gremlin
```

最终目录应该是这样：

```text
.codex/
  pets/
    terminal-gremlin/
      pet.json
      spritesheet.webp
```

然后在 Codex Desktop 里选择 `Terminal Gremlin`，或把配置中的 `selected-avatar-id` 设置为：

```toml
[desktop]
selected-avatar-id = "custom:terminal-gremlin"
```

## 文件说明

```text
terminal-gremlin/
  pet.json
  spritesheet.webp
install.ps1
install.sh
README.md
```

- `terminal-gremlin/pet.json`：宠物清单，定义宠物 ID、显示名称、描述和 spritesheet 路径。
- `terminal-gremlin/spritesheet.webp`：宠物动画图集。
- `install.ps1`：Windows 一键安装脚本。
- `install.sh`：macOS / Linux 一键安装脚本。

## hatch-pet 格式

这个宠物包遵循 hatch-pet 的 Codex pet contract：

- 图集格式：WebP。
- 图集尺寸：`1536x1872`。
- 网格：`8` 列 x `9` 行。
- 单格尺寸：`192x208`。
- 背景：透明。
- 自定义宠物目录：`${CODEX_HOME:-$HOME/.codex}/pets/<pet-name>/`。

`pet.json` 内容：

```json
{
  "id": "terminal-gremlin",
  "displayName": "Terminal Gremlin",
  "description": "A small terminal-screen companion that breathes, thinks, waits, works, celebrates, and glitches through Codex tasks.",
  "spritesheetPath": "spritesheet.webp"
}
```

## 更新

重新运行一键安装命令即可更新到仓库里的最新版本。脚本会覆盖 `terminal-gremlin/pet.json` 和 `terminal-gremlin/spritesheet.webp`，不会删除其他宠物。

## 卸载

删除这个目录即可：

Windows：

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.codex\pets\terminal-gremlin"
```

macOS / Linux：

```bash
rm -rf "${CODEX_HOME:-$HOME/.codex}/pets/terminal-gremlin"
```

如果卸载前正在使用它，建议先在 Codex Desktop 里切换到其他宠物，或者把 `selected-avatar-id` 改成其他值。

## 排错

- 安装后没有出现：重启 Codex Desktop。
- 仍然没有出现：确认 `pet.json` 和 `spritesheet.webp` 是否在 `.codex/pets/terminal-gremlin/` 目录下。
- 多台电脑路径不同：设置 `CODEX_HOME` 后重新运行安装命令。
- 想恢复默认宠物：在 Codex Desktop 里重新选择其他宠物即可。
