# Changelog

## [Unreleased]
## [1.0.2] - 2026-02-06

### Added
- 5个新的测试用例:
  - axi_single_test: 单次传输测试
  - axi_burst_test: 突发传输测试
  - axi_random_test: 随机测试 (100次)
  - axi_error_test: 错误注入测试
  - axi_reg_test: 寄存器读写测试

### Changed
- 更新 filelist.f - 添加新测试文件

### Fixed
- N/A

### Removed
- N/A


## [1.0.1] - 2026-02-06

### Added
- 完整的 AXI Agent Driver 实现 (drive_write, drive_read)
- 完整的 AXI Agent Monitor 实现
- 示例 DUT: axi_reg_file (AXI4-Lite 寄存器文件)
  - 4个32位通用寄存器
  - 1个状态寄存器
  - 1个控制寄存器
- 支持字节使能的写操作

### Changed
- 更新 axi_agent.sv - 移除 TODO，完整实现
- 更新 tb_top.sv - 替换简单的 my_dut 为完整的 axi_reg_file

### Fixed
- N/A

### Removed
- N/A

## [1.0.0] - 2026-02-05

### Added
- 初始 UVM 验证平台
- 基础架构 (Agent, Sequencer, Monitor)
- 基础测试 (smoke_test, demo_test)
- 编译和运行脚本
- 验证计划文档

[Unreleased]: https://github.com/jingzhoushii/uvm-verification-platform/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/jingzhoushii/uvm-verification-platform/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/jingzhoushii/uvm-verification-platform/releases/tag/v1.0.0
