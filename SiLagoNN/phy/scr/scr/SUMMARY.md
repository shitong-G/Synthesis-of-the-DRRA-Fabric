# Physical Synthesis Scripts - Summary

## ✅ 完成状态

### Task 4 - Flat Physical Synthesis
- ✅ `pnr_flat.tcl` - 完整的 flat P&R 流程
- ✅ `run_flat_pnr.sh` - 自动化运行脚本
- ✅ 不进行分区，单层 flat 设计

### Task 5 - Floorplanning
- ✅ `floorplan.tcl` - 创建 floorplan 和 boundary constraints
- ✅ `powerplan.tcl` - 电源规划
- ✅ `create_partitions.tcl` - 创建分区的完整流程

### Task 6 - Hierarchical Physical Synthesis
- ✅ `create_partitions.tcl` - 创建分区
- ✅ `pnr_partition.tcl` - 分区级别的 P&R
- ✅ `pnr_top.tcl` - 顶层 P&R 和 ILM flattening
- ✅ `assemble_design.tcl` - 组装设计
- ✅ `run_hierarchical_pnr.sh` - 自动化运行脚本

## 📁 文件清单

### 核心脚本
- `global_variables.tcl` - Flat synthesis 变量
- `global_variables_hrchy.tcl` - Hierarchical synthesis 变量
- `design_variables.tcl` - 设计特定参数
- `mmmc.tcl` - TSMC90 MMMC 设置（保留）
- `mmmc_gf22fdx.tcl` - GF22FDX MMMC 设置（当前使用）
- `read_design.tcl` - 读取设计文件

### Task 4 文件
- `pnr_flat.tcl` - Flat physical synthesis 主脚本
- `run_flat_pnr.sh` - 自动化脚本

### Task 5 & 6 文件
- `create_partitions.tcl` - 创建分区
- `floorplan.tcl` - Floorplan 创建
- `powerplan.tcl` - 电源规划
- `partition.tcl` - 分区配置
- `pnr_partition.tcl` - 分区 P&R
- `pnr_partition.sh` - 分区 P&R 自动化
- `pnr_top.tcl` - 顶层 P&R
- `assemble_design.tcl` - 设计组装
- `run_hierarchical_pnr.sh` - 完整流程自动化

### 文档
- `README.md` - 使用指南
- `CHANGELOG.md` - 更新日志
- `ANALYSIS_REPORT.md` - 问题分析
- `SUMMARY.md` - 本文件

## 🔧 配置说明

### 技术库
- **当前使用**: GF22FDX（与逻辑综合匹配）
- **LEF 文件**: `/opt/pdk/gfip/22FDX-EXT/.../GF22FDX_SC8T_104CPP_BASE_CSC28L.lef`
- **MMMC 文件**: `mmmc_gf22fdx.tcl`

### 源文件目录
- **Flat synthesis**: `syn/db/task2` (flat synthesis 结果)
- **Hierarchical synthesis**: `syn/db/task3` (bottom-up synthesis 结果)

### 需要更新的配置

1. **分区实例名称** (`global_variables_hrchy.tcl`)
   - 更新 `all_partition_hinst_list` 为实际设计中的实例名称
   - 更新 `master_partition_module_list` 为唯一模块名称

2. **Floorplan 尺寸** (`pnr_flat.tcl`, `floorplan.tcl`)
   - 根据实际设计大小调整
   - 考虑利用率目标

3. **SDC 文件路径**
   - 确保 SDC 文件存在于正确位置
   - 脚本会自动尝试多个路径

## 🚀 快速开始

### Task 4 - Flat Physical Synthesis
```bash
cd phy/scr
./run_flat_pnr.sh
```

### Task 5 & 6 - Hierarchical Physical Synthesis
```bash
cd phy/scr
./run_hierarchical_pnr.sh
```

## ⚠️ 注意事项

1. **库文件格式**
   - GF22FDX 使用 .db 格式（CCS）
   - 某些 Innovus 版本可能需要 .lib 格式
   - 如有问题，检查 Innovus 版本兼容性

2. **分区配置**
   - 必须根据实际设计层次更新实例名称
   - Master partition 必须正确识别

3. **文件路径**
   - 所有脚本假设从 `exe/` 目录运行
   - 相对路径基于此假设

## 📊 输出文件

### Flat Synthesis
- 报告: `phy/rpt/flat/`
- 输出: `phy/db/flat/`
- 日志: `log/flat_pnr_*.log`

### Hierarchical Synthesis
- 报告: `phy/rpt/`
- 输出: `phy/db/part/`
- 日志: `log/*_*.log`

## 🔍 故障排除

### 常见问题

1. **找不到库文件**
   - 检查 LEF 和 MMMC 文件路径
   - 验证库文件是否存在

2. **分区错误**
   - 检查实例名称是否正确
   - 验证设计层次结构

3. **SDC 文件错误**
   - 检查 SDC 文件路径
   - 验证约束文件格式

4. **路径错误**
   - 确保从正确的目录运行脚本
   - 检查相对路径设置

