# UVM Verification Platform

一个专业级的 UVM 验证环境模板，适用于芯片验证工程师。

## 📁 目录结构

```
uvm-verification-platform/
├── src/                        # Design RTL 源码
│   ├── defines.v               # 全局参数定义
│   ├── bus_if.sv               # 总线接口定义
│   └── [IP]/                   # 按模块分组的 IP
│       ├── axi_master.v
│       ├── axi_slave.v
│       └── axi_bridge.v
│
├── tb/                         # Testbench
│   ├── config/
│   │   ├── uvm_config.sv      # UVM 配置对象
│   │   └── test_config.sv     # 测试配置
│   ├── component/
│   │   ├── predictor.sv        # Reference Model
│   │   ├── checker.sv         # 结果检查器
│   │   └── coverage.sv        # 覆盖率模型
│   ├── env/
│   │   ├── uvm_env.sv         # 顶层 Environment
│   │   ├── axi_env.sv         # AXI 环境
│   │   └── sub_env.sv         # 子模块环境
│   ├── agent/
│   │   ├── axi_agent.sv       # AXI Agent
│   │   ├── axi_driver.sv      # Driver
│   │   ├── axi_monitor.sv      # Monitor
│   │   └── axi_sequencer.sv   # Sequencer
│   ├── seq/
│   │   ├── base_seq.sv        # 基类序列
│   │   ├── axi_seq.sv         # AXI 序列库
│   │   └── demo_seq.sv        # 示例序列
│   ├── test/
│   │   ├── base_test.sv       # 基类测试
│   │   ├── demo_test.sv       # 示例测试
│   │   └── smoke_test.sv      # 冒烟测试
│   └── tb_top.sv              # Testbench 顶层
│
├── sim/                        # 仿真脚本
│   ├── vcs/                   # VCS 相关
│   │   ├── compile.sh         # 编译脚本
│   │   └── run.sh             # 运行脚本
│   ├── ncsim/                 # NCsim 相关
│   │   ├── compile.sh
│   │   └── run.sh
│   └── xcelium/               # Xcelium 相关
│       ├── compile.sh
│       └── run.sh
│
├── regress/                    # 回归测试
│   ├── testlist.yaml          # 测试列表
│   ├── run_regress.sh         # 回归脚本
│   └── results/               # 结果输出
│
├── docs/                       # 文档
│   ├── verification_plan.md   # 验证计划
│   ├── coverage_plan.md       # 覆盖率计划
│   └── test_spec.md           # 测试规格说明
│
├── scripts/                    # 辅助脚本
│   ├── gen_coverage_report.sh # 覆盖率报告
│   ├── parse_log.py           # 日志解析
│   └── wave_viewer.py         # 波形查看脚本
│
├── .github/
│   └── workflows/
│       └── ci.yml             # GitHub Actions CI
│
├── Makefile                   # 顶层 Makefile
├── Makefile.defs             # 编译选项定义
├── filelist.f                # VCS 文件列表
├── filelist.flib             # 库文件列表
└── README.md                 # 本文档
```

## 🚀 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/你的用户名/uvm-verification-platform.git
cd uvm-verification-platform
```

### 2. 设置环境变量

```bash
# 编辑 Makefile.defs 或设置环境变量
export VCS_HOME=/path/to/vcs
export UVM_HOME=/path/to/uvm-1800.2-2021
```

### 3. 运行冒烟测试

```bash
# 编译
make compile

# 运行冒烟测试
make run TEST=smoke_test

# 查看波形
make view_wave TEST=smoke_test
```

### 4. 运行回归测试

```bash
# 运行所有测试
make regress

# 运行指定测试
make run TEST=demo_test
```

## 📋 测试列表 (testlist.yaml)

```yaml
smoke_test:
  name: smoke_test
  desc: "冒烟测试，验证基本功能"
  cmd: "./sim/vcs/run.sh +uvm_testname=smoke_test"
  timeout: 300
  passes: 1
  
demo_test:
  name: demo_test
  desc: "功能演示测试"
  cmd: "./sim/vcs/run.sh +uvm_testname=demo_test"
  timeout: 600
  passes: 1
  
axi_write_read_test:
  name: axi_write_read_test
  desc: "AXI 读写功能测试"
  cmd: "./sim/vcs/run.sh +uvm_testname=axi_write_read_test"
  timeout: 600
  passes: 1
```

## 🔧 编译选项

### Makefile 使用

```bash
# 查看所有目标
make help

# 编译目标
make compile TOOL=vcs          # 使用 VCS 编译
make compile TOOL=ncsim        # 使用 NCsim 编译

# 运行测试
make run TEST=smoke_test SEED=12345

# 生成覆盖率报告
make coverage

# 清理
make clean                     # 清理仿真文件
make distclean                # 清理所有生成文件
```

### filelist.f 文件格式

```systemverilog
// UVM 库文件
+incdir+$UVM_HOME/src
$UVM_HOME/src/uvm.sv

// Design 文件
src/defines.v
src/bus_if.sv
src/dut.v

// Testbench 文件
tb/tb_top.sv
tb/config/uvm_config.sv
tb/component/coverage.sv
tb/env/uvm_env.sv
tb/agent/axi_agent.sv
tb/seq/base_seq.sv
tb/test/base_test.sv
```

## 📊 覆盖率模型

### 功能覆盖率示例

```systemverilog
class axi_coverage extends uvm_component;
  `uvm_component_utils(axi_coverage)
  
  // 覆盖率组
  covergroup axi_cg with function sample(axi_transaction tr);
    // 覆盖点定义
    cp_cmd: coverpoint tr.cmd {
      bins READ = {0};
      bins WRITE = {1};
    }
    cp_len: coverpoint tr.len {
      bins BURST[] = {[0:15]};
    }
    cp_size: coverpoint tr.size {
      bins SIZE[] = {[0:3]};
    }
    // 交叉覆盖
    cmd_x_size: cross cp_cmd, cp_size;
    len_x_size: cross cp_len, cp_size;
  endgroup
  
  virtual function void sample_transaction(axi_transaction tr);
    axi_cg.sample(tr);
  endfunction
endclass
```

## 🔄 GitHub Actions CI/CD

.github/workflows/ci.yml:

```yaml
name: UVM Regression

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  vcs-sim:
    runs-on: ubuntu-latest
    container: ghcr.io/.../vcs-env:latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Compile
      run: make compile TOOL=vcs
      
    - name: Run Smoke Test
      run: make run TEST=smoke_test
      
    - name: Run Full Regression
      run: make regress
      
    - name: Upload Coverage
      uses: actions/upload-artifact@v4
      with:
        name: coverage_report
        path: regress/results/
```

## 📝 开发流程

### 1. 创建功能分支

```bash
git checkout -b feature/add-new-sequence
```

### 2. 开发与测试

```bash
# 开发新功能
# 修改代码后

git add .
git commit -m "feat: add axi write burst sequence"

# 推送
git push origin feature/add-new-sequence
```

### 3. 发起 Pull Request

在 GitHub 网站上发起 PR，添加 reviewers，进行代码审查。

### 4. 合并到主分支

审查通过后，合并 PR，删除功能分支。

## 🛠 支持的工具

| 工具 | 版本 | 说明 |
|------|------|------|
| VCS | 2023+ | Synopsys 仿真器 |
| NCsim | 2023+ | Cadence 仿真器 |
| Xcelium | 2023+ | Cadence 仿真器 |
| Questa | 2023+ | Siemens 仿真器 |

## 📚 文档

- [验证计划](docs/verification_plan.md)
- [覆盖率计划](docs/coverage_plan.md)
- [测试规格说明](docs/test_spec.md)

## 🤝 贡献

1. Fork 本仓库
2. 创建功能分支
3. 提交你的更改
4. 发起 Pull Request

## 📄 许可证

MIT License

## 👤 作者

你的名字 | 芯片验证工程师

---

**Happy Verification! 🎉**

## 🚀 快速开始

### 1. 设置环境变量

```bash
export VCS_HOME=/path/to/vcs
export UVM_HOME=/path/to/uvm-1800.2-2021
```

### 2. 编译

```bash
make compile
```

### 3. 运行冒烟测试

```bash
make smoke
```

### 4. 运行回归测试

```bash
make regress
```

## 📋 测试列表

| 测试名称 | 描述 | 优先级 |
|----------|------|--------|
| smoke_test | 冒烟测试 | P0 |
| base_test | 基础测试 | P1 |
| demo_test | 功能演示 | P1 |
| axi_single_test | 单次传输测试 | P1 |
| axi_burst_test | 突发传输测试 | P1 |
| axi_random_test | 随机测试 (100次) | P1 |
| axi_error_test | 错误注入测试 | P2 |
| axi_reg_test | 寄存器读写测试 | P1 |

## 🔧 Makefile 使用

```bash
# 编译
make compile

# 运行单个测试
make run TEST=smoke_test

# 运行冒烟测试
make smoke

# 运行所有测试
make regress

# 快速测试 (P0 + P1)
make quick_test

# 压力测试
make stress_test

# 清理
make clean
make distclean
```

## 📊 回归测试

### 运行回归测试

```bash
cd regress
./run_regress.sh

# 详细输出
./run_regress.sh -v

# 只运行冒烟测试
./run_regress.sh --skip-compile

# 运行特定测试
./run_regress.sh -p "*smoke*"
```

### 测试结果

测试结果保存在 `regress/results/` 目录：
- `*.log` - 每个测试的日志
- `summary.log` - 测试汇总
- `report.html` - HTML 报告

## 📝 测试配置

测试配置在 `regress/testlist.yaml` 文件：

```yaml
smoke_test:
  name: smoke_test
  desc: "冒烟测试"
  cmd: "./sim/vcs/run.sh +uvm_testname=smoke_test"
  timeout: 300
  priority: P0
```


