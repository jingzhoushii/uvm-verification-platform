# AMBA 总线支持

## 概述

UVM Verification Platform 支持 AMBA 总线协议，包括：
- **AHB** (Advanced High-performance Bus)
- **APB** (Advanced Peripheral Bus)
- **AXI** (Advanced eXtensible Interface)

## AHB 总线

### 特性

- 高速总线
- 支持突发传输
- 支持分片和重试
- 32 位数据宽度

### 组件

| 组件 | 文件 | 说明 |
|------|------|------|
| Transaction | ahb_transaction.sv | 事务定义 |
| Driver | ahb_agent.sv | 驱动器 |
| Monitor | ahb_agent.sv | 监视器 |
| Sequencer | ahb_agent.sv | 序列器 |
| Agent | ahb_agent.sv | 代理 |

### 测试用例

| 测试 | 文件 | 说明 |
|------|------|------|
| ahb_single_test | ahb_single_test.sv | 单次传输测试 |

### 使用示例

```systemverilog
// 创建 AHB 序列
ahb_single_seq seq;
seq = ahb_single_seq::type_id::create("seq");
seq.addr = 32'h1000;
seq.data = 32'hA5A5_A5A5;
seq.start(env.ahb_agnt.sequencer);
```

## APB 总线

### 特性

- 低功耗外设总线
- 简单接口
- 适合低速外设
- 32 位数据宽度

### 组件

| 组件 | 文件 | 说明 |
|------|------|------|
| Transaction | apb_transaction.sv | 事务定义 |
| Driver | apb_agent.sv | 驱动器 |
| Monitor | apb_agent.sv | 监视器 |
| Sequencer | apb_agent.sv | 序列器 |
| Agent | apb_agent.sv | 代理 |

### 测试用例

| 测试 | 文件 | 说明 |
|------|------|------|
| apb_single_test | apb_single_test.sv | 单次传输测试 |

### 使用示例

```systemverilog
// 创建 APB 序列
apb_single_seq seq;
seq = apb_single_seq::type_id::create("seq");
seq.paddr = 32'h4000_0000;
seq.pwdata = 32'h5A5A_5A5A;
seq.pwrite = 1'b1;
seq.start(env.apb_agnt.sequencer);
```

## AXI 总线

参见主文档 [README.md](../README.md)

## 性能对比

| 特性 | AHB | APB | AXI |
|------|-----|-----|-----|
| 速度 | 高 | 低 | 最高 |
| 复杂度 | 中 | 低 | 高 |
| 突发传输 | 支持 | 不支持 | 支持 |
| 通道分离 | 否 | 否 | 是 |

## 后续扩展

- [ ] AHB Burst 测试
- [ ] APB 多次传输
- [ ] AHB-Lite 支持
- [ ] AXI4 Full 支持

## 许可证

MIT License
