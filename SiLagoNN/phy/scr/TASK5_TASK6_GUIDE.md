# Task 5 & Task 6 运行指南

## 📋 任务关系

### Task 5: Floorplanning
- **目标**: 创建 floorplan 和 partitions
- **输出**: 分区定义和位置约束
- **脚本**: `create_partitions.tcl`

### Task 6: Hierarchical Physical Synthesis
- **目标**: 完整的层次化物理综合流程
- **包含**: Task 5 + 分区 P&R + 顶层 P&R + 组装
- **脚本**: `run_hierarchical_pnr.sh` (自动化) 或手动步骤

### ⚠️ 重要：运行顺序

**Task 5 和 Task 6 必须顺序运行，不能同时运行！**

**原因：**
1. Task 5 创建 partitions 和 floorplan
2. Task 6 需要 Task 5 的输出（partitions）才能继续
3. Task 6 的步骤 1 就是 Task 5 的内容

**关系图：**
```
Task 5: Floorplanning
    ↓
    ├─ 创建 floorplan
    ├─ 创建 partitions
    └─ 设置 boundary constraints
    ↓
Task 6: Hierarchical Physical Synthesis
    ├─ Step 1: 创建 partitions (Task 5)
    ├─ Step 2: 分区 P&R (并行)
    ├─ Step 3: 顶层 P&R
    └─ Step 4: 组装设计
```

---

## 🚀 运行方式

### 方式 1: 只运行 Task 5 (Floorplanning)

如果你想**只创建 floorplan 和 partitions**（不进行 P&R）：

```bash
cd exe
innovus -stylus -batch -files ../phy/scr/create_partitions.tcl \
    -log "../log/create_partitions_$(date +%Y%m%d_%H%M%S)"
```

**输出：**
- 分区定义保存在 `phy/db/part/`
- Floorplan 和 boundary constraints 已设置

---

### 方式 2: 运行完整 Task 6 (推荐)

如果你想运行**完整的层次化物理综合流程**（包含 Task 5）：

```bash
cd phy/scr
./run_hierarchical_pnr.sh
```

**这个脚本会自动执行：**
1. ✅ Step 1: 创建 partitions (Task 5 的内容)
2. ✅ Step 2: 对每个 partition 进行 P&R
3. ✅ Step 3: 顶层 P&R
4. ✅ Step 4: 组装设计

---

### 方式 3: 手动运行 Task 6 的各个步骤

如果你想**手动控制每个步骤**：

#### Step 1: 创建 Partitions (Task 5)
```bash
cd exe
innovus -stylus -batch -files ../phy/scr/create_partitions.tcl \
    -log "../log/create_partitions_$(date +%Y%m%d_%H%M%S)"
```

#### Step 2: 分区 P&R (可以并行运行)

**选项 A: 使用自动化脚本**
```bash
cd phy/db/part
bash ../../../phy/scr/pnr_partition.sh
```

**选项 B: 手动运行每个分区**
```bash
cd phy/db/part
# 对每个分区目录运行
cd divider_pipe
innovus -stylus -batch -files ../../../phy/scr/pnr_partition.tcl \
    -log "../../../log/pnr_divider_pipe_$(date +%Y%m%d_%H%M%S)"

cd ../silego
innovus -stylus -batch -files ../../../phy/scr/pnr_partition.tcl \
    -log "../../../log/pnr_silego_$(date +%Y%m%d_%H%M%S)"

# ... 对其他分区重复
```

**注意：** 不同分区可以**并行运行**（使用不同的终端或后台运行）

#### Step 3: 顶层 P&R
```bash
cd exe
innovus -stylus -batch -files ../phy/scr/pnr_top.tcl \
    -log "../log/pnr_top_$(date +%Y%m%d_%H%M%S)"
```

#### Step 4: 组装设计
```bash
cd exe
innovus -stylus -batch -files ../phy/scr/assemble_design.tcl \
    -log "../log/assemble_design_$(date +%Y%m%d_%H%M%S)"
```

---

## 📊 并行运行说明

### ✅ 可以并行运行的部分

**Step 2 中的不同分区 P&R 可以并行运行：**
- 每个分区是独立的
- 可以同时运行多个分区的 P&R
- 节省总运行时间

**示例（并行运行 4 个分区）：**
```bash
# 终端 1
cd phy/db/part/divider_pipe
innovus -stylus -batch -files ../../../phy/scr/pnr_partition.tcl &

# 终端 2
cd phy/db/part/silego
innovus -stylus -batch -files ../../../phy/scr/pnr_partition.tcl &

# 终端 3
cd phy/db/part/Silago_top
innovus -stylus -batch -files ../../../phy/scr/pnr_partition.tcl &

# 终端 4
cd phy/db/part/Silago_bot
innovus -stylus -batch -files ../../../phy/scr/pnr_partition.tcl &

# 等待所有后台任务完成
wait
```

### ❌ 不能并行运行的部分

**以下步骤必须顺序运行：**
1. Step 1 (创建 partitions) → Step 2 (分区 P&R)
2. Step 2 (分区 P&R) → Step 3 (顶层 P&R)
3. Step 3 (顶层 P&R) → Step 4 (组装)

**原因：**
- 每个步骤依赖前一步的输出
- 必须等待前一步完成才能继续

---

## 🔧 配置要求

### 运行前检查

1. **更新分区信息** (`design_variables.tcl`)
   ```tcl
   set all_partition_hinst_list {
       # 添加所有分区实例名称
   }
   set master_partition_module_list {
       # 添加主分区模块名称
   }
   ```

2. **检查源文件路径** (`global_variables_hrchy.tcl`)
   - Netlist 文件路径
   - SDC 文件路径
   - LEF 文件路径

3. **确保 Task 3 完成**
   - 需要 bottom-up synthesis 的结果
   - Netlist 应该在 `syn/db/task3/` 或相应目录

---

## 📁 输出文件位置

### Task 5 输出
- **分区定义**: `phy/db/part/`
- **Floorplan**: 保存在 Innovus database 中

### Task 6 输出
- **分区 P&R 结果**: `phy/db/part/{partition_name}/`
- **ILM 文件**: `phy/db/part/{partition_name}/ilm/`
- **顶层 P&R 结果**: `phy/db/part/${TOP_NAME}/pnr`
- **最终组装设计**: `phy/db/part/${TOP_NAME}/`
- **报告**: `phy/rpt/`

---

## ⏱️ 运行时间估算

### Task 5 (创建 Partitions)
- **时间**: 约 5-15 分钟
- **主要操作**: Floorplan, Power planning, Partition creation

### Task 6 (完整流程)
- **Step 1 (创建 partitions)**: 5-15 分钟
- **Step 2 (分区 P&R)**: 
  - 每个分区: 10-30 分钟
  - 如果并行: 总时间 = 最慢的分区时间
  - 如果串行: 总时间 = 所有分区时间之和
- **Step 3 (顶层 P&R)**: 30-60 分钟
- **Step 4 (组装)**: 5-10 分钟

**总时间估算**: 
- 串行运行: 1-3 小时
- 并行运行: 30-90 分钟

---

## 🐛 常见问题

### Q1: 可以跳过 Task 5 直接运行 Task 6 吗？
**A:** 不可以。Task 6 的第一步就是创建 partitions，所以 Task 5 是必需的。

### Q2: 运行 Task 5 后，可以单独运行 Task 6 的其他步骤吗？
**A:** 可以。如果已经运行了 Task 5，可以从 Step 2 开始运行 Task 6。

### Q3: 如何知道 Task 5 是否成功完成？
**A:** 检查 `phy/db/part/` 目录，应该包含分区定义文件。

### Q4: 分区 P&R 失败怎么办？
**A:** 
- 检查分区定义是否正确
- 检查 ILM 文件是否生成
- 查看日志文件找出错误原因

### Q5: 如何重新运行某个步骤？
**A:** 
- 删除对应的输出文件
- 重新运行该步骤的脚本

---

## 📝 运行示例

### 完整流程示例

```bash
# 1. 进入脚本目录
cd /home/shitongg/IL2225/SiLagoNN/phy/scr

# 2. 运行完整 Task 6（包含 Task 5）
./run_hierarchical_pnr.sh

# 或者分步运行：

# Step 1: 创建 partitions (Task 5)
cd ../../exe
innovus -stylus -batch -files ../phy/scr/create_partitions.tcl \
    -log "../log/create_partitions_$(date +%Y%m%d_%H%M%S)"

# Step 2: 分区 P&R（并行）
cd ../phy/db/part
bash ../../../phy/scr/pnr_partition.sh

# Step 3: 顶层 P&R
cd ../../exe
innovus -stylus -batch -files ../phy/scr/pnr_top.tcl \
    -log "../log/pnr_top_$(date +%Y%m%d_%H%M%S)"

# Step 4: 组装
innovus -stylus -batch -files ../phy/scr/assemble_design.tcl \
    -log "../log/assemble_design_$(date +%Y%m%d_%H%M%S)"
```

---

## ✅ 总结

1. **Task 5 和 Task 6 必须顺序运行**
2. **Task 6 包含 Task 5**（Step 1）
3. **推荐使用 `run_hierarchical_pnr.sh`** 自动化运行
4. **分区 P&R 可以并行运行**，节省时间
5. **其他步骤必须顺序运行**

