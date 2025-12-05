# dc_flat.tcl 使用说明

## 📋 概述

`dc_flat.tcl` 是用于 Task 2 - Flat logic synthesis 的综合脚本，用于综合 DRRA_wrapper 设计。

## 🚀 使用方法

### 方法 1: 从 exe 目录运行（推荐）

```bash
# 进入 exe 目录
cd exe

# 运行综合（使用默认 100ns 时钟周期）
dc_shell -f ../syn/scr/dc_flat.tcl

# 或指定时钟周期
export CLOCK_PERIOD=100.0
dc_shell -f ../syn/scr/dc_flat.tcl
```

### 方法 2: 从项目根目录运行

```bash
# 从项目根目录
cd exe && dc_shell -f ../syn/scr/dc_flat.tcl
```

### 方法 3: 使用不同的时钟周期进行 PPA 评估

```bash
# 创建 exe 目录（如果不存在）
mkdir -p exe
cd exe

# 使用大时钟周期（快速综合）
export CLOCK_PERIOD=100.0
dc_shell -f ../syn/scr/dc_flat.tcl

# 逐步减小时钟周期
export CLOCK_PERIOD=50.0
dc_shell -f ../syn/scr/dc_flat.tcl

export CLOCK_PERIOD=20.0
dc_shell -f ../syn/scr/dc_flat.tcl

export CLOCK_PERIOD=10.0
dc_shell -f ../syn/scr/dc_flat.tcl
```

## 📁 目录结构要求

```
project_top_folder/
├── exe/          # 运行目录（临时文件存储在这里）
├── rtl/          # RTL 代码
│   └── drra_wrapper_hierarchy.txt
├── syn/          # 综合相关文件
│   ├── scr/
│   │   └── dc_flat.tcl
│   ├── synopsys_dc.setup
│   ├── constraints.sdc (可选)
│   ├── db/       # 输出：综合后的设计
│   └── rpt/      # 输出：报告文件
└── ...
```

## ⚙️ 脚本功能

1. **加载库配置** - 从 `synopsys_dc.setup` 加载标准单元库
2. **读取设计** - 从 `rtl/drra_wrapper_hierarchy.txt` 读取所有 VHDL 文件
3. **设置约束** - 创建时钟约束（可覆盖 SDC 文件中的设置）
4. **综合** - 使用 Design Compiler 进行综合
5. **生成报告** - 生成时序、面积、资源报告
6. **保存设计** - 保存为 DDC 和 Verilog 格式

## 📊 输出文件

综合完成后，在 `syn/` 目录下生成：

### 报告文件 (`syn/rpt/`)
- `drra_wrapper_timing_<period>ns.rpt` - 时序报告
- `drra_wrapper_area_<period>ns.rpt` - 面积报告
- `drra_wrapper_resources_<period>ns.rpt` - 资源使用报告
- `drra_wrapper_design_<period>ns.rpt` - 设计总结

### 设计文件 (`syn/db/`)
- `drra_wrapper_<period>ns.ddc` - DC 数据库文件
- `drra_wrapper_<period>ns.v` - Verilog 网表

## 🔧 参数说明

### CLOCK_PERIOD

- **默认值**: 100.0 ns
- **设置方法**: 环境变量 `export CLOCK_PERIOD=50.0`
- **建议**: 
  - 首次运行使用大周期（100ns 或更大）快速验证脚本
  - 逐步减小周期进行 PPA 评估

## ⚠️ 注意事项

1. **综合时间**: 设计很大，综合可能需要很长时间（几小时）
2. **警告 vs 错误**: 
   - 可以忽略警告（warnings）
   - 必须修复错误（errors）- 会停止综合
3. **路径问题**: 确保从正确的目录运行脚本
4. **库配置**: 确保 `synopsys_dc.setup` 正确配置

## 📈 PPA 评估

### Performance (性能)
- 查看时序报告中的 **Slack**
  - `slack (MET)` = 满足时序 ✅
  - `slack (VIOLATED)` = 时序违例 ❌

### Power (功耗)
- 需要启用功耗报告（脚本中已注释）
- 或根据面积估算

### Area (面积)
- 查看面积报告中的 **Total cell area**

### 评估步骤

1. 用多个时钟周期综合（100ns, 50ns, 20ns, 10ns）
2. 提取每个周期的 PPA 数据
3. 创建对比表格
4. 分析权衡关系

## 🐛 常见问题

### 问题 1: 找不到文件

**错误**: `Unable to open file 'rtl/hw_setting.vhd'`

**解决**: 
- 确保从 `exe` 目录运行脚本
- 检查 `rtl/drra_wrapper_hierarchy.txt` 是否存在
- 检查文件路径是否正确

### 问题 2: 库配置错误

**错误**: `Can't read link_library file`

**解决**: 
- 检查 `synopsys_dc.setup` 中的库路径
- 确保库文件存在

### 问题 3: 时钟周期不生效

**解决**: 
- 脚本会自动覆盖 SDC 文件中的时钟周期
- 检查环境变量是否正确设置

## 📝 Task 2 检查清单

- [ ] 成功读取所有设计文件
- [ ] 综合完成（没有 fatal 错误）
- [ ] 生成时序报告
- [ ] 生成面积报告
- [ ] 用多个时钟周期综合
- [ ] 对比不同时钟周期的 PPA
- [ ] 理解设计权衡（速度 vs 面积）

## 💡 提示

1. **从大时钟开始**: 先用 100ns 验证脚本，再减小
2. **保存中间结果**: 每次综合都会保存 .ddc 文件
3. **耐心等待**: 大设计综合需要时间
4. **查看日志**: 注意错误信息，忽略警告

