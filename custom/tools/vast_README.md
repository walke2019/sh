# Vast.ai GPU容器专用管理工具

## 📋 简介

这是一个专为 **Vast.ai** 平台设计的GPU容器管理工具，提供完整的环境检测、依赖安装、GPU监控和推理工具管理功能。

## 🎯 核心特性

### 1. 智能环境检测 🔍

- **自动识别Docker容器环境**
- **完整的CUDA环境检测**
  - CUDA版本（驱动CUDA）
  - NVCC版本（编译CUDA）
  - GPU型号、数量、驱动版本
- **深度学习框架检测**
  - PyTorch版本及CUDA支持
  - TensorFlow版本及GPU可用性
  - JAX、MXNet等其他框架
- **GPU推理工具检测**
  - ONNX Runtime、TensorRT、OpenVINO
  - vLLM、DeepSpeed、TensorRT-LLM
  - xFormers、Flash-Attention、BitsAndBytes
  - llama.cpp、CTransformers

### 2. 智能依赖匹配 🧠

根据当前CUDA版本自动推荐最佳匹配的深度学习框架：

```bash
当前CUDA 12.1 → 推荐 PyTorch (CUDA 12.1)
当前CUDA 11.8 → 推荐 PyTorch (CUDA 11.8)
```

### 3. Conda环境管理 📦

- 安装Miniconda到/home目录
- 创建/删除/激活Python环境
- 快速创建常用环境模板
- 环境配置导入/导出

### 4. GPU推理工具管理 🛠️

完整的推理工具安装和测试：

- **ONNX Runtime GPU** - 通用模型推理引擎
- **TensorRT** - NVIDIA高性能推理
- **OpenVINO** - Intel推理优化
- **vLLM** - 高性能LLM推理引擎
- **DeepSpeed** - 分布式训练/推理
- **TensorRT-LLM** - LLM专用TensorRT
- **xFormers** - 注意力机制加速
- **Flash-Attention** - 高效注意力实现
- **SageAttention** - 新一代注意力加速
- **BitsAndBytes** - 模型量化工具
- **llama.cpp** - CPU/GPU混合推理
- **CTransformers** - C++后端Transformers
- **Triton** - 推理服务器客户端

### 5. GPU监控与测试 📊

- **实时GPU监控** - nvidia-smi实时显示
- **GPU性能测试** - 矩阵运算性能测试
- **推理工具测试** - 一键测试所有工具

### 6. Jupyter管理 📓

- 安装JupyterLab及扩展
- 启动/停止Jupyter服务
- 密码配置和Token查看

### 7. 快速启动项目 🚀

- PyTorch训练环境
- TensorFlow训练环境
- Jupyter Notebook
- Stable Diffusion WebUI
- ComfyUI

---

## 🚀 使用方法

### 启动工具

```bash
# 方法1：通过主菜单
bash custom/custom_main.sh
# 选择 "2. Vast.ai GPU容器管理"

# 方法2：直接运行
bash custom/tools/vast.sh
```

### 首次使用建议流程

1. **查看环境信息**
   ```
   选择: 1. 🖥️ 一键显示环境信息
   ```
   查看当前GPU、CUDA、PyTorch、TensorFlow等所有环境信息

2. **安装Conda（可选）**
   ```
   选择: 2. 📦 Conda环境管理
   选择: 1. 安装Miniconda到/home目录
   ```

3. **智能安装深度学习框架**
   ```
   选择: 3. 🔧 智能依赖库管理
   选择: 1. 智能安装PyTorch (自动匹配CUDA)
   ```

4. **安装GPU推理工具**
   ```
   选择: 6. 🛠️ GPU推理工具管理
   选择: 14. 一键安装推理工具套件
   ```

5. **测试环境**
   ```
   选择: 9. ✅ 推理工具测试
   ```

---

## 📖 功能详解

### 环境信息显示

显示内容包括：
- 系统环境（Docker/物理机）
- GPU信息（型号、数量、驱动、CUDA版本）
- 实时GPU状态（温度、使用率、显存）
- PyTorch和TensorFlow版本及GPU支持
- 所有已安装的推理工具和加速库
- 系统资源（磁盘、内存）

### Conda环境管理

```bash
# 安装Miniconda
安装路径: /home/miniconda3
自动配置环境变量

# 创建环境
支持Python 3.8/3.9/3.10/3.11
可选安装基础包

# 快速创建常用环境
- PyTorch环境
- TensorFlow环境
- 数据科学环境
- LLM推理环境
```

### 智能依赖安装

#### PyTorch安装示例

```bash
# 检测CUDA 12.1
推荐: PyTorch 2.x (CUDA 12.1)
命令: pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# 检测CUDA 11.8
推荐: PyTorch 2.x (CUDA 11.8)
命令: pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

#### TensorFlow安装示例

```bash
# 自动匹配CUDA
推荐: TensorFlow 2.15+ (自动匹配CUDA)
命令: pip3 install tensorflow[and-cuda]
```

### GPU推理工具安装

#### 单个工具安装

```bash
# ONNX Runtime GPU
pip3 install onnxruntime-gpu

# vLLM (LLM高速推理)
pip3 install vllm

# xFormers (注意力加速)
pip3 install xformers

# Flash-Attention
pip3 install flash-attn --no-build-isolation

# llama.cpp (CUDA支持)
CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip3 install llama-cpp-python
```

#### 一键安装套件

```bash
pip3 install onnxruntime-gpu vllm deepspeed xformers bitsandbytes
```

### GPU性能测试

测试不同矩阵大小的性能：
- 1000x1000
- 5000x5000
- 10000x10000

输出指标：
- 平均时间（ms）
- 性能（GFLOPS）
- 显存使用

### 推理工具测试

一键测试所有已安装的推理工具：

```bash
✓ ONNX Runtime 1.16.3
  Providers: ['CUDAExecutionProvider', 'CPUExecutionProvider']
✓ vLLM 0.2.7
✓ xFormers 0.0.23
✓ Flash-Attention 2.5.0
✓ BitsAndBytes 0.41.3
```

---

## 💡 使用场景

### 场景1：快速搭建训练环境

```bash
1. 查看环境信息（确认GPU和CUDA）
2. 智能安装PyTorch
3. 安装常用科学计算库
4. 启动Jupyter Notebook
5. 开始训练
```

### 场景2：LLM推理部署

```bash
1. 查看环境信息
2. 创建LLM推理环境（Conda）
3. 安装vLLM和推理工具
4. 测试推理工具
5. 部署模型
```

### 场景3：模型优化加速

```bash
1. 安装xFormers和Flash-Attention
2. 安装BitsAndBytes（量化）
3. 测试性能提升
4. 优化推理速度
```

---

## ⚠️ 注意事项

### Vast.ai平台特性

1. **Docker容器环境**
   - 工具会自动检测Docker环境
   - 某些系统级操作可能受限

2. **持久化存储**
   - 建议将重要数据保存在 `/workspace` 目录
   - Conda安装在 `/home` 目录

3. **GPU资源**
   - 按小时计费，注意资源使用
   - 使用GPU监控查看实时状态

### 安装建议

1. **优先使用Conda**
   - 环境隔离更好
   - 依赖管理更方便

2. **智能安装功能**
   - 自动匹配CUDA版本
   - 避免版本冲突

3. **推理工具选择**
   - 根据需求选择合适的工具
   - 不是所有工具都需要安装

---

## 🔧 故障排除

### 问题1：CUDA版本不匹配

```bash
# 查看驱动CUDA版本
nvidia-smi

# 查看编译CUDA版本
nvcc --version

# 使用智能安装功能自动匹配
```

### 问题2：PyTorch无法使用GPU

```bash
# 测试GPU可用性
python3 -c "import torch; print(torch.cuda.is_available())"

# 重新安装匹配的PyTorch版本
使用工具的智能安装功能
```

### 问题3：推理工具安装失败

```bash
# 检查CUDA环境
# 更新pip
pip3 install --upgrade pip

# 使用工具的一键安装功能
```

---

## 📚 参考资源

- **Vast.ai官网**: https://vast.ai/
- **PyTorch官网**: https://pytorch.org/
- **TensorFlow官网**: https://www.tensorflow.org/
- **vLLM GitHub**: https://github.com/vllm-project/vllm
- **Flash-Attention**: https://github.com/Dao-AILab/flash-attention

---

## 🆕 版本历史

### v2.1.0 (2025-01-25)
- ✅ 完整的GPU推理工具检测和管理
- ✅ 智能CUDA版本匹配
- ✅ Conda环境管理
- ✅ GPU性能测试
- ✅ 推理工具测试功能

---

**最后更新**: 2025-01-25
