# UVM 验证平台 - 中文文档

## 📖 目录

- [简介](#简介)
- [快速开始](#快速开始)
- [目录结构](#目录结构)
- [测试用例](#测试用例)
- [开发指南](#开发指南)
- [常见问题](#常见问题)

## 简介

UVM Verification Platform 是一个专业级的 UVM 验证环境模板，适用于芯片验证工程师。

### 主要特性

- ✅ UVM 1.2 标准兼容
- ✅ 完整的 AXI4-Lite Agent
- ✅ 丰富的测试用例库
- ✅ 自动化回归测试
- ✅ Docker 支持

## 快速开始

### 环境要求

- Linux/macOS
- VCS 或 NCsim 仿真器
- Python 3.6+

### 安装

```bash
# 克隆仓库
git clone https://github.com/jingzhoushii/uvm-verification-platform.git
cd uvm-verification-platform

# 设置环境变量
export VCS_HOME=/path/to/vcs
export UVM_HOME=/path/to/uvm
```

### 编译

```bash
make compile
```

### 运行测试

```bash
# 运行冒烟测试
make smoke

# 运行所有测试
make regress
```

## 目录结构

```
uvm-verification-platform/
├── tb/                     # Testbench
│   ├── agent/              # AXI Agent
│   ├── component/          # 组件
│   ├── env/                # 环境
│   ├── seq/                # 序列
│   └── test/               # 测试用例
├── sim/                    # 仿真脚本
├── regress/               # 回归测试
├── scripts/                # 工具脚本
├── docs/                   # 文档
└── Makefile               # 构建脚本
```

## 测试用例

| 测试名称 | 描述 | 优先级 |
|----------|------|--------|
| smoke_test | 冒烟测试 | P0 |
| base_test | 基础测试 | P1 |
| demo_test | 演示测试 | P1 |
| axi_single_test | 单次传输 | P1 |
| axi_burst_test | 突发传输 | P1 |
| axi_random_test | 随机测试 | P1 |
| axi_error_test | 错误注入 | P2 |
| axi_reg_test | 寄存器读写 | P1 |
| axi_boundary_test | 边界测试 | P1 |

## 开发指南

### 添加新测试

1. 在 `tb/test/` 创建新文件
2. 继承 `base_test` 类
3. 实现 `run_phase` 任务
4. 更新 `regress/testlist.yaml`

示例：

```systemverilog
class my_test extends base_test;
  `uvm_component_utils(my_test)
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // 测试代码
    phase.drop_objection(this);
  endtask
endclass
```

### 添加新序列

1. 在 `tb/seq/` 创建新文件
2. 继承 `uvm_sequence`
3. 实现 `body` 任务

## 常见问题

### Q: 编译报错？

A: 检查环境变量是否设置正确：
```bash
echo $VCS_HOME
echo $UVM_HOME
```

### Q: 仿真器不识别？

A: 确保已安装商业仿真器（VCS/NCsim/Xcelium）

### Q: 如何查看波形？

A: 使用 Verdi 或 DVE：
```bash
verdi -ssf waves.vcd
dve -vpd waves.vpd &
```

## 许可证

MIT License
