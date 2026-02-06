# 常见问题 (FAQ)

## 📋 目录

- [编译相关](#编译相关)
- [运行相关](#运行相关)
- [仿真相关](#仿真相关)
- [工具相关](#工具相关)

---

## 编译相关

### Q: 编译报错 "command not found: vcs"

A: 请检查环境变量：
```bash
# 设置 VCS 环境
source /path/to/vcs/setup.sh

# 验证
which vcs
```

### Q: 报错 "UVM version not found"

A: 设置 UVM_HOME 环境变量：
```bash
export UVM_HOME=/path/to/uvm-1800.2-2021
```

### Q: Makefile 报错 "missing separator"

A: 确保 Makefile 使用 TAB 缩进，不是空格：
```bash
# 查看是否有问题
cat -A Makefile | grep -E "^\t"
```

---

## 运行相关

### Q: 运行测试时报错 "TEST not found"

A: 检查测试名称是否正确：
```bash
# 列出所有可用测试
ls tb/test/*_test.sv

# 运行测试
make run TEST=smoke_test
```

### Q: 仿真卡住不动

A: 检查是否缺少随机种子：
```bash
make run TEST=smoke_test SEED=12345
```

### Q: 测试失败怎么办？

A: 查看日志：
```bash
cat sim/vcs/simv.log
```

---

## 仿真相关

### Q: 如何查看波形？

A: 编译时添加 dump 选项：
```bash
# VCS
make compile COV_FLAGS="-cm line+cond"

# 运行后查看
verdi -ssf waves.vcd
dve -vpd waves.vpd &
```

### Q: 如何生成覆盖率报告？

A: 运行覆盖率测试：
```bash
make coverage
make coverage-report
```

### Q: 覆盖率不理想怎么办？

A: 1. 运行更多随机测试 2. 添加边界测试 3. 检查未覆盖分支

---

## 工具相关

### Q: 如何使用 Docker？

A: 
```bash
# 构建镜像
make docker-build

# 运行容器
make docker-run

# 进入容器
make docker-bash
```

### Q: 如何运行回归测试？

A:
```bash
cd regress
./run_regress.sh

# 或使用 Makefile
make regress
```

### Q: 如何添加新测试？

A:
```bash
# 1. 在 tb/test/ 创建新文件
# 2. 更新 regress/testlist.yaml
# 3. 更新 filelist.f
# 4. 提交并测试
```

---

## 💡 提示

### 提高效率

1. 使用 `make quick_test` 只运行 P0/P1 测试
2. 使用 `SEED` 固定随机种子复现问题
3. 使用 `-cm tgl` 添加翻转覆盖率

### 调试技巧

1. 使用 `+uvm_set_severity` 调整错误级别
2. 使用 `+ntb_random_seed` 固定随机种子
3. 使用 `UVM_VERBOSITY=UVM_DEBUG` 查看详细信息

---

## 📞 获取帮助

- GitHub Issues: https://github.com/jingzhoushii/uvm-verification-platform/issues
- 文档: docs/
- 示例: tb/test/
