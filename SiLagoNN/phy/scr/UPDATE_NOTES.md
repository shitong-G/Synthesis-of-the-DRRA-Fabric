# Physical Synthesis Scripts - Update Notes

## 主要更新 (Based on Tutorial)

### 1. 库文件格式修复
- **问题**: Innovus 无法读取 `.db` 格式的库文件
- **解决**: 改用 `.lib.gz` 格式的库文件
- **路径**: `/opt/pdk/gfip/22FDX-EXT/.../model/timing/ccs/`

### 2. MMMC 配置更新
- 添加了 QRC technology files 用于 RC corner
- 正确设置了 operating conditions
- 使用三个 corner: BC (Best), TC (Typical), WC (Worst)

### 3. LEF 文件更新
- 现在包含两个 LEF 文件：
  - Tech LEF: `/opt/pdk/gf22/.../22FDSOI_10M_2Mx_4Cx_2Bx_2Jx_LB_104cpp_tech.lef`
  - Std Cell LEF: `/opt/pdk/gfip/.../GF22FDX_SC8T_104CPP_BASE_CSC28L.lef`

### 4. Floorplan Site 名称
- 从 `core` 改为 `SC8T_104CPP_CMOS22FDX` (GF22FDX 标准 site)

### 5. 分区层配置
- 更新为使用 9 层金属 (1-9)
- 匹配 GF22FDX 10 层金属工艺

## 文件更新列表

### 更新的文件
1. `global_variables.tcl` - 添加了所有必要的库路径和变量
2. `global_variables_hrchy.tcl` - 同步更新
3. `mmmc_gf22fdx.tcl` - 完全重写，使用正确的格式
4. `pnr_flat.tcl` - 更新 floorplan 和 power planning
5. `floorplan.tcl` - 更新 site 名称
6. `partition.tcl` - 更新层配置

## 关键变量说明

### 库文件变量
- `LIB_FILES_BC` - Best case (FF corner) 库文件
- `LIB_FILES_TC` - Typical case (TT corner) 库文件  
- `LIB_FILES_WC` - Worst case (SS corner) 库文件

### Operating Conditions
- `OP_COD_BC` - FFG_0P72V_0P00V_0P00V_0P00V_M40C
- `OP_COD_TC` - TT_0P80V_0P00V_0P00V_0P00V_25C
- `OP_COD_WC` - SSG_0P72V_0P00V_0P00V_0P00V_125C

### QRC 文件
- `QRC_FILE_BC` - FuncRCminDP (最小 RC)
- `QRC_FILE_TC` - nominal (典型 RC)
- `QRC_FILE_WC` - FuncRCmaxDP (最大 RC)

## 使用注意事项

1. **Power Planning**: 当前脚本中 power planning 部分被注释，建议通过 GUI 完成
2. **Floorplan 尺寸**: 可能需要根据实际设计调整
3. **库文件**: 确保所有库文件路径正确且文件存在

## 下一步

运行脚本前请确认：
- [ ] 所有库文件路径正确
- [ ] QRC 文件存在
- [ ] LEF 文件存在
- [ ] 综合结果文件 (netlist, SDC) 存在

