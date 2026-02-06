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

## [1.0.3] - 2026-02-06

### Added
- 边界测试: axi_boundary_test.sv
  - 地址对齐测试
  - 最大/最小传输测试
  - 跨 4KB 边界测试
  - 保留地址测试

- 工具脚本:
  - scripts/wave/dump_waves.sh: 波形 dump
  - scripts/coverage_report.sh: 覆盖率报告

- Docker 支持:
  - Dockerfile: 容器环境
  - docker-compose.yml: 编排配置

### Changed
- Makefile: 添加新目标
  - boundary_test: 边界测试
  - docker-*: Docker 相关命令
  - coverage-*: 覆盖率相关命令
  - wave-*: 波形相关命令

### Added
- CODE_REVIEW.md: 代码审查报告

## [1.0.4] - 2026-02-06

### Added
- 社区文件:
  - CONTRIBUTING.md: 贡献指南
  - LICENSE: MIT 许可证
  - .gitignore: Git 忽略规则
  - .editorconfig: 编辑器配置
  - .gitattributes: Git 属性
  - .github/ISSUE_TEMPLATE/bug_report.md: Bug 报告模板
  - .github/ISSUE_TEMPLATE/feature_request.md: 功能请求模板
  - .github/PULL_REQUEST_TEMPLATE.md: PR 模板

- 文档:
  - docs/zh/README.md: 中文文档
  - docs/FAQ.md: 常见问题

- 工具脚本:
  - scripts/parse_log.py: 日志分析工具
  - regress/gen_html_report.py: HTML 回归报告

### Changed
- Makefile: 添加 parse-log, gen-report 目标
- filelist.f: 添加新脚本

## [1.1.0] - 2026-02-07

### Added
- AMBA 总线支持
  - AHB (Advanced High-performance Bus) 支持
    - ahb_transaction.sv: AHB 事务定义
    - ahb_agent.sv: AHB Agent (Driver + Monitor + Sequencer)
    - ahb_single_test.sv: AHB 测试用例
  
  - APB (Advanced Peripheral Bus) 支持
    - apb_transaction.sv: APB 事务定义
    - apb_agent.sv: APB Agent (Driver + Monitor + Sequencer)
    - apb_single_test.sv: APB 测试用例

- docs/AMBA.md: AMBA 总线协议文档

### Changed
- 测试用例总数: 11 (新增 AHB + APB 测试)
- Agent 总数: 3 (AXI + AHB + APB)

