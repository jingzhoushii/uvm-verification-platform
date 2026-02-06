# CI/CD 设置指南

## 概述

GitHub Actions CI/CD 工作流已配置完成，包含以下检查：

1. **lint** - 语法检查
2. **compile** - 编译检查
3. **documentation** - 文档检查
4. **quality** - 代码质量
5. **report** - 生成报告

## 当前状态

由于 UVM 需要商业仿真器 (VCS/NCsim)，当前 CI 只进行静态检查。

## 启用完整 CI/CD

### 方案1: 使用自托管 Runner

在有 VCS 的机器上配置自托管 runner：

```bash
# 在 GitHub 仓库设置中添加 runner
# Settings > Actions > Runners > New self-hosted runner

# 选择 Linux x64
```

### 方案2: 使用 Secrets (需要商业授权)

设置以下 secrets：

| Secret 名称 | 说明 | 示例 |
|------------|------|------|
| VCS_HOME_PATH | VCS 安装路径 | /opt/synopsys/vcs |
| UVM_HOME_PATH | UVM 库路径 | /opt/uvm-1800.2-2021 |
| NCSIM_HOME_PATH | NCsim 路径 (可选) | /opt/cadence/ncsim |

设置方式：
```
GitHub > Settings > Secrets and variables > Actions
```

### 方案3: 编译脚本示例

创建 `.github/workflows/compile.yml`：

```yaml
name: Compile

on:
  workflow_dispatch:
  schedule:
    - cron: '0 0 * * 0'  # 每周日编译检查

jobs:
  compile:
    runs-on: [self-hosted, linux]
    container:
      image: ubuntu:20.04
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup environment
        run: |
          source /opt/synopsys/vcs/setup.sh
          source $UVM_HOME/setup.sh
      
      - name: Compile
        run: |
          cd sim/vcs
          ./compile.sh
      
      - name: Run smoke test
        run: |
          cd sim/vcs
          ./run.sh +uvm_testname=smoke_test
```

## CI/CD 最佳实践

### 1. 提交前检查

```bash
# 本地运行检查
make help
make clean
make compile
```

### 2. Pull Request 检查

确保 PR 包含：
- [ ] 代码变更已编译
- [ ] 新测试已通过
- [ ] 文档已更新
- [ ] CHANGELOG 已记录

### 3. 版本发布

```bash
# 创建 tag
git tag v1.0.2
git push origin v1.0.2

# GitHub Actions 会自动触发发布流程
```

## 监控 CI/CD

查看执行历史：
```
GitHub > Actions > UVM Verification Platform CI
```

## 常见问题

### Q: CI 失败怎么办？

1. 检查 lint 结果
2. 查看编译错误
3. 确认文件路径正确

### Q: 如何跳过 CI？

```bash
# 在 commit message 中添加 [skip ci]
git commit -m "docs: update [skip ci]"
```

### Q: 如何手动触发 CI？

```
GitHub > Actions > UVM Verification Platform CI > Run workflow
```
