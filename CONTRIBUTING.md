# 贡献指南

感谢您对 UVM Verification Platform 的兴趣！我们欢迎各种形式的贡献。

## 📋 目录

- [如何贡献](#如何贡献)
- [提交规范](#提交规范)
- [代码风格](#代码风格)
- [测试要求](#测试要求)
- [文档要求](#文档要求)

## 🤝 如何贡献

### 1. Fork 仓库

点击右上角的 **Fork** 按钮，或者运行：

```bash
git clone https://github.com/YOUR_USERNAME/uvm-verification-platform.git
cd uvm-verification-platform
```

### 2. 创建分支

```bash
git checkout -b feature/your-feature-name
```

### 3. 开发

- 编写代码
- 添加测试
- 更新文档

### 4. 提交

```bash
git add .
git commit -m "feat: 添加新功能"
```

### 5. Push

```bash
git push origin feature/your-feature-name
```

### 6. 创建 Pull Request

在 GitHub 上创建 PR，描述您的更改。

## 📝 提交规范

### 提交类型

| 类型 | 描述 |
|------|------|
| feat | 新功能 |
| fix | Bug 修复 |
| docs | 文档更新 |
| style | 代码格式（不影响功能） |
| refactor | 重构 |
| test | 测试相关 |
| chore | 构建/工具相关 |

### 提交格式

```
<类型>: <简短描述>

<详细描述（可选）>

关闭的 Issue（可选）
```

### 示例

```
feat: 添加 AHB Adapter 支持

- 支持 AHB-Lite 协议
- 添加 AHB Agent
- 添加 AHB 测试用例

Closes #123
```

## 🎨 代码风格

### SystemVerilog

- 使用 4 空格缩进
- 命名规范：
  - 类名：`PascalCase`（如 `axi_agent`）
  - 信号：`snake_case`（如 `axi_valid`）
  - 常量：`UPPER_CASE`（如 `MAX_LEN`）
- 每个文件添加文件头注释

```systemverilog
// ============================================================
// File: filename.sv
// Description: 简短描述
// Author: Your Name
// Created: YYYY-MM-DD
// ============================================================
```

### Shell 脚本

- 使用 `#!/bin/bash`
- 添加 `set -e` 错误处理
- 使用 `#!/bin/bash` 开头

```bash
#!/bin/bash
set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
```

## ✅ 测试要求

### 新功能必须包含

1. **单元测试**
   - 新增测试用例
   - 边界条件测试

2. **回归测试**
   - 更新 `regress/testlist.yaml`
   - 确保所有测试通过

### 测试命令

```bash
# 运行所有测试
make regress

# 运行单个测试
make run TEST=your_test

# 边界测试
make boundary_test
```

## 📖 文档要求

### 新增功能必须包含

1. **README 更新**
   - 功能描述
   - 使用方法
   - 示例

2. **API 文档**
   - 函数说明
   - 参数说明
   - 返回值说明

3. **CHANGELOG**
   - 在 `[Unreleased]` 部分添加条目

## 🐛 报告 Bug

### 提交 Issue 时请包含

- Bug 描述
- 复现步骤
- 期望行为
- 实际行为
- 环境信息（操作系统、仿真器版本等）
- 日志/截图

### Issue 模板

```markdown
## Bug 描述

## 复现步骤

## 期望行为

## 实际行为

## 环境

## 日志
```

## 💡 提出新功能

### Feature Request 模板

```markdown
## 功能描述

## 使用场景

## 期望的实现

## 相关截图/示例
```

## 📜 许可证

通过贡献代码，您同意您的代码在 MIT 许可证下发布。

## 🙏 感谢

感谢您的贡献！
