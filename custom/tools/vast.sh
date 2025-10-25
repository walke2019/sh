#!/bin/bash
# Vast.ai GPU容器专用管理工具
# 版本: 2.1.0
# 适配: Docker虚拟环境 / Vast.ai平台

VERSION="2.1.0"

# 颜色定义
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
MAGENTA='\033[35m'
WHITE='\033[37m'
RESET='\033[0m'

# 日志函数
log_info() {
    echo -e "${CYAN}[INFO]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${RESET} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${RESET} $1"
}

log_error() {
    echo -e "${RED}[✗]${RESET} $1"
}

# 按键继续
press_enter() {
    echo ""
    read -p "按回车键继续..."
}

# 检测环境信息
detect_environment() {
    clear
    echo -e "${CYAN}=== 正在检测环境信息 ===${RESET}"
    echo ""
    
    # 检测是否在Docker容器中
    if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
        IN_DOCKER=true
        log_info "检测到Docker容器环境"
    else
        IN_DOCKER=false
        log_warning "非Docker环境"
    fi
    
    # 检测CUDA版本
    if command -v nvidia-smi &>/dev/null; then
        CUDA_VERSION=$(nvidia-smi | grep "CUDA Version" | awk '{print $9}')
        DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)
        GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
        GPU_COUNT=$(nvidia-smi --list-gpus | wc -l)
        HAS_GPU=true
    else
        CUDA_VERSION="未检测到"
        DRIVER_VERSION="未检测到"
        GPU_NAME="未检测到"
        GPU_COUNT=0
        HAS_GPU=false
    fi
    
    # 检测nvcc版本（编译工具）
    if command -v nvcc &>/dev/null; then
        NVCC_VERSION=$(nvcc --version | grep "release" | awk '{print $5}' | cut -d',' -f1)
    else
        NVCC_VERSION="未安装"
    fi
    
    # 检测Python版本
    if command -v python3 &>/dev/null; then
        PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    elif command -v python &>/dev/null; then
        PYTHON_VERSION=$(python --version | awk '{print $2}')
    else
        PYTHON_VERSION="未安装"
    fi
    
    # 检测PyTorch
    PYTORCH_VERSION=$(python3 -c "import torch; print(torch.__version__)" 2>/dev/null || echo "未安装")
    if [ "$PYTORCH_VERSION" != "未安装" ]; then
        PYTORCH_CUDA=$(python3 -c "import torch; print(torch.version.cuda)" 2>/dev/null || echo "未知")
        PYTORCH_GPU=$(python3 -c "import torch; print(torch.cuda.is_available())" 2>/dev/null || echo "False")
    else
        PYTORCH_CUDA="N/A"
        PYTORCH_GPU="N/A"
    fi
    
    # 检测TensorFlow
    TF_VERSION=$(python3 -c "import tensorflow as tf; print(tf.__version__)" 2>/dev/null || echo "未安装")
    if [ "$TF_VERSION" != "未安装" ]; then
        TF_GPU_COUNT=$(python3 -c "import tensorflow as tf; print(len(tf.config.list_physical_devices('GPU')))" 2>/dev/null || echo "0")
    else
        TF_GPU_COUNT="N/A"
    fi
    
    # 检测其他常用库
    NUMPY_VERSION=$(python3 -c "import numpy; print(numpy.__version__)" 2>/dev/null || echo "未安装")
    PANDAS_VERSION=$(python3 -c "import pandas; print(pandas.__version__)" 2>/dev/null || echo "未安装")
    OPENCV_VERSION=$(python3 -c "import cv2; print(cv2.__version__)" 2>/dev/null || echo "未安装")
    
    # 检测GPU推理工具
    ONNXRUNTIME_VERSION=$(python3 -c "import onnxruntime; print(onnxruntime.__version__)" 2>/dev/null || echo "未安装")
    TENSORRT_VERSION=$(python3 -c "import tensorrt; print(tensorrt.__version__)" 2>/dev/null || echo "未安装")
    OPENVINO_VERSION=$(python3 -c "import openvino; print(openvino.__version__)" 2>/dev/null || echo "未安装")
    TRITON_VERSION=$(python3 -c "import tritonclient; print('已安装')" 2>/dev/null || echo "未安装")
    
    # 检测模型加速库
    DEEPSPEED_VERSION=$(python3 -c "import deepspeed; print(deepspeed.__version__)" 2>/dev/null || echo "未安装")
    VLLM_VERSION=$(python3 -c "import vllm; print(vllm.__version__)" 2>/dev/null || echo "未安装")
    TRTLLM_VERSION=$(python3 -c "import tensorrt_llm; print('已安装')" 2>/dev/null || echo "未安装")
    XFORMERS_VERSION=$(python3 -c "import xformers; print(xformers.__version__)" 2>/dev/null || echo "未安装")
    BITSANDBYTES_VERSION=$(python3 -c "import bitsandbytes; print(bitsandbytes.__version__)" 2>/dev/null || echo "未安装")
    FLASHATTN_VERSION=$(python3 -c "import flash_attn; print(flash_attn.__version__)" 2>/dev/null || echo "未安装")
    SAGEATTENTION_VERSION=$(python3 -c "import sageattention; print('已安装')" 2>/dev/null || echo "未安装")
    
    # 检测LLM推理框架
    LLAMA_CPP_VERSION=$(python3 -c "import llama_cpp; print(llama_cpp.__version__)" 2>/dev/null || echo "未安装")
    CTRANSFORMERS_VERSION=$(python3 -c "import ctransformers; print(ctransformers.__version__)" 2>/dev/null || echo "未安装")
    
    # 检测Conda环境
    if command -v conda &>/dev/null; then
        CONDA_VERSION=$(conda --version | awk '{print $2}')
        CONDA_ENV=$(conda info --envs | grep '*' | awk '{print $1}')
        CONDA_INSTALLED=true
    else
        CONDA_VERSION="未安装"
        CONDA_ENV="N/A"
        CONDA_INSTALLED=false
    fi
    
    # 保存到全局变量
    export CUDA_VERSION DRIVER_VERSION GPU_NAME GPU_COUNT NVCC_VERSION
    export PYTHON_VERSION PYTORCH_VERSION PYTORCH_CUDA PYTORCH_GPU
    export TF_VERSION TF_GPU_COUNT NUMPY_VERSION PANDAS_VERSION OPENCV_VERSION
    export ONNXRUNTIME_VERSION TENSORRT_VERSION OPENVINO_VERSION TRITON_VERSION
    export DEEPSPEED_VERSION VLLM_VERSION TRTLLM_VERSION XFORMERS_VERSION BITSANDBYTES_VERSION
    export FLASHATTN_VERSION SAGEATTENTION_VERSION
    export LLAMA_CPP_VERSION CTRANSFORMERS_VERSION
    export CONDA_VERSION CONDA_ENV CONDA_INSTALLED
    export IN_DOCKER HAS_GPU
}

# 显示环境信息
show_environment() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║        Vast.ai 环境信息报告               ║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${RESET}"
    echo ""
    
    echo -e "${YELLOW}=== 系统环境 ===${RESET}"
    echo -e "运行环境: ${GREEN}$([ "$IN_DOCKER" = true ] && echo "Docker容器" || echo "物理机")${RESET}"
    echo -e "操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "内核版本: $(uname -r)"
    echo -e "Python版本: ${GREEN}$PYTHON_VERSION${RESET}"
    echo -e "Conda版本: ${GREEN}$CONDA_VERSION${RESET}"
    [ "$CONDA_INSTALLED" = true ] && echo -e "当前环境: ${GREEN}$CONDA_ENV${RESET}"
    echo ""
    
    echo -e "${YELLOW}=== GPU信息 ===${RESET}"
    echo -e "GPU数量: ${GREEN}$GPU_COUNT${RESET}"
    echo -e "GPU型号: ${GREEN}$GPU_NAME${RESET}"
    echo -e "驱动版本: ${GREEN}$DRIVER_VERSION${RESET}"
    echo -e "CUDA版本: ${GREEN}$CUDA_VERSION${RESET}"
    echo -e "NVCC版本: ${GREEN}$NVCC_VERSION${RESET}"
    
    if [ "$HAS_GPU" = true ]; then
        echo ""
        echo -e "${YELLOW}=== 实时GPU状态 ===${RESET}"
        nvidia-smi --query-gpu=index,name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader | \
        while IFS=',' read -r idx name temp util mem_used mem_total; do
            echo -e "${CYAN}GPU $idx:${RESET} $name"
            echo -e "  温度: $temp | 使用率: $util"
            echo -e "  显存: $mem_used / $mem_total"
        done
    fi
    echo ""
    
    echo -e "${YELLOW}=== PyTorch ===${RESET}"
    echo -e "PyTorch版本: ${GREEN}$PYTORCH_VERSION${RESET}"
    echo -e "PyTorch CUDA: ${GREEN}$PYTORCH_CUDA${RESET}"
    echo -e "GPU可用: ${GREEN}$PYTORCH_GPU${RESET}"
    echo ""
    
    echo -e "${YELLOW}=== TensorFlow ===${RESET}"
    echo -e "TensorFlow版本: ${GREEN}$TF_VERSION${RESET}"
    echo -e "可用GPU数: ${GREEN}$TF_GPU_COUNT${RESET}"
    echo ""
    
    echo -e "${YELLOW}=== 常用库 ===${RESET}"
    echo -e "NumPy: ${GREEN}$NUMPY_VERSION${RESET}"
    echo -e "Pandas: ${GREEN}$PANDAS_VERSION${RESET}"
    echo -e "OpenCV: ${GREEN}$OPENCV_VERSION${RESET}"
    echo ""
    
    echo -e "${YELLOW}=== GPU推理工具 ===${RESET}"
    echo -e "ONNX Runtime: ${GREEN}$ONNXRUNTIME_VERSION${RESET}"
    echo -e "TensorRT: ${GREEN}$TENSORRT_VERSION${RESET}"
    echo -e "OpenVINO: ${GREEN}$OPENVINO_VERSION${RESET}"
    echo -e "Triton Client: ${GREEN}$TRITON_VERSION${RESET}"
    echo ""
    
    echo -e "${YELLOW}=== 模型加速库 ===${RESET}"
    echo -e "DeepSpeed: ${GREEN}$DEEPSPEED_VERSION${RESET}"
    echo -e "vLLM: ${GREEN}$VLLM_VERSION${RESET}"
    echo -e "TensorRT-LLM: ${GREEN}$TRTLLM_VERSION${RESET}"
    echo -e "xFormers: ${GREEN}$XFORMERS_VERSION${RESET}"
    echo -e "Flash-Attention: ${GREEN}$FLASHATTN_VERSION${RESET}"
    echo -e "SageAttention: ${GREEN}$SAGEATTENTION_VERSION${RESET}"
    echo -e "BitsAndBytes: ${GREEN}$BITSANDBYTES_VERSION${RESET}"
    echo ""
    
    echo -e "${YELLOW}=== LLM推理框架 ===${RESET}"
    echo -e "llama.cpp: ${GREEN}$LLAMA_CPP_VERSION${RESET}"
    echo -e "CTransformers: ${GREEN}$CTRANSFORMERS_VERSION${RESET}"
    echo ""
    
    # 显示磁盘和内存
    echo -e "${YELLOW}=== 系统资源 ===${RESET}"
    echo "磁盘使用:"
    df -h / | tail -1 | awk '{print "  总容量: "$2" | 已用: "$3" | 可用: "$4" | 使用率: "$5}'
    echo ""
    echo "内存使用:"
    free -h | grep Mem | awk '{print "  总内存: "$2" | 已用: "$3" | 可用: "$7}'
    echo ""
    
    press_enter
}

# Conda环境管理
conda_manager() {
    while true; do
        clear
        echo -e "${CYAN}=== Conda 环境管理 ===${RESET}"
        echo ""
        
        if [ "$CONDA_INSTALLED" = true ]; then
            echo -e "${GREEN}● Conda已安装: $CONDA_VERSION${RESET}"
            echo -e "${GREEN}● 当前环境: $CONDA_ENV${RESET}"
            echo ""
            echo "现有环境列表:"
            conda env list
        else
            echo -e "${RED}○ Conda未安装${RESET}"
        fi
        
        echo ""
        echo "------------------------"
        echo "1. 安装Miniconda到/home目录"
        echo "2. 创建新的Python环境"
        echo "3. 激活指定环境"
        echo "4. 删除指定环境"
        echo "5. 列出所有环境"
        echo "6. 导出当前环境配置"
        echo "7. 从配置文件创建环境"
        echo "8. 更新Conda"
        echo "9. 清理Conda缓存"
        echo "0. 返回主菜单"
        echo ""
        read -p "请选择: " choice
        
        case $choice in
            1)
                install_miniconda
                ;;
            2)
                if [ "$CONDA_INSTALLED" = false ]; then
                    log_error "请先安装Conda"
                    press_enter
                    continue
                fi
                create_conda_env
                ;;
            3)
                if [ "$CONDA_INSTALLED" = false ]; then
                    log_error "请先安装Conda"
                    press_enter
                    continue
                fi
                
                conda env list
                echo ""
                read -p "请输入要激活的环境名: " env_name
                
                echo ""
                log_info "激活环境的命令:"
                echo -e "${YELLOW}conda activate $env_name${RESET}"
                echo ""
                log_warning "注意: 需要在新的shell中手动执行上述命令"
                press_enter
                ;;
            4)
                if [ "$CONDA_INSTALLED" = false ]; then
                    log_error "请先安装Conda"
                    press_enter
                    continue
                fi
                
                conda env list
                echo ""
                read -p "请输入要删除的环境名: " env_name
                read -p "确认删除环境 $env_name? (y/n): " confirm
                
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    conda env remove -n $env_name
                    log_success "环境已删除"
                fi
                press_enter
                ;;
            5)
                conda env list
                press_enter
                ;;
            6)
                if [ "$CONDA_INSTALLED" = false ]; then
                    log_error "请先安装Conda"
                    press_enter
                    continue
                fi
                
                read -p "输出文件名 (默认environment.yml): " filename
                filename=${filename:-environment.yml}
                
                conda env export > $filename
                log_success "环境配置已导出到 $filename"
                press_enter
                ;;
            7)
                if [ "$CONDA_INSTALLED" = false ]; then
                    log_error "请先安装Conda"
                    press_enter
                    continue
                fi
                
                read -p "请输入配置文件路径: " config_file
                
                if [ ! -f "$config_file" ]; then
                    log_error "文件不存在"
                    press_enter
                    continue
                fi
                
                conda env create -f $config_file
                log_success "环境创建完成"
                press_enter
                ;;
            8)
                if [ "$CONDA_INSTALLED" = false ]; then
                    log_error "请先安装Conda"
                    press_enter
                    continue
                fi
                
                log_info "更新Conda..."
                conda update -n base -c defaults conda
                log_success "Conda更新完成"
                press_enter
                ;;
            9)
                if [ "$CONDA_INSTALLED" = false ]; then
                    log_error "请先安装Conda"
                    press_enter
                    continue
                fi
                
                log_info "清理Conda缓存..."
                conda clean --all -y
                log_success "缓存清理完成"
                press_enter
                ;;
            0)
                return
                ;;
            *)
                log_error "无效选择"
                sleep 1
                ;;
        esac
        
        # 重新检测环境
        detect_environment
    done
}

# 安装Miniconda
install_miniconda() {
    clear
    echo -e "${CYAN}=== 安装 Miniconda ===${RESET}"
    echo ""
    
    if [ "$CONDA_INSTALLED" = true ]; then
        log_warning "Conda已安装: $CONDA_VERSION"
        read -p "是否重新安装? (y/n): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    INSTALL_DIR="/home/miniconda3"
    
    log_info "Miniconda将安装到: $INSTALL_DIR"
    echo ""
    
    # 检测系统架构
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    elif [ "$ARCH" = "aarch64" ]; then
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
    else
        log_error "不支持的架构: $ARCH"
        press_enter
        return
    fi
    
    log_info "下载Miniconda安装脚本..."
    wget -O /tmp/miniconda.sh $MINICONDA_URL
    
    if [ $? -ne 0 ]; then
        log_error "下载失败"
        press_enter
        return
    fi
    
    log_info "安装Miniconda..."
    bash /tmp/miniconda.sh -b -p $INSTALL_DIR
    
    if [ $? -ne 0 ]; then
        log_error "安装失败"
        press_enter
        return
    fi
    
    rm /tmp/miniconda.sh
    
    # 配置环境变量
    log_info "配置环境变量..."
    
    CONDA_INIT="
# >>> conda initialize >>>
__conda_setup=\"\$('$INSTALL_DIR/bin/conda' 'shell.bash' 'hook' 2> /dev/null)\"
if [ \$? -eq 0 ]; then
    eval \"\$__conda_setup\"
else
    if [ -f \"$INSTALL_DIR/etc/profile.d/conda.sh\" ]; then
        . \"$INSTALL_DIR/etc/profile.d/conda.sh\"
    else
        export PATH=\"$INSTALL_DIR/bin:\$PATH\"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
"
    
    # 添加到bashrc
    if ! grep -q "conda initialize" ~/.bashrc; then
        echo "$CONDA_INIT" >> ~/.bashrc
    fi
    
    # 添加到bash_profile
    if [ -f ~/.bash_profile ]; then
        if ! grep -q "conda initialize" ~/.bash_profile; then
            echo "$CONDA_INIT" >> ~/.bash_profile
        fi
    fi
    
    # 立即生效
    export PATH="$INSTALL_DIR/bin:$PATH"
    source $INSTALL_DIR/etc/profile.d/conda.sh
    
    # 初始化conda
    conda init bash
    
    # 配置conda
    log_info "配置Conda..."
    conda config --set auto_activate_base false
    
    log_success "Miniconda安装完成！"
    echo ""
    log_info "安装路径: $INSTALL_DIR"
    log_info "请执行以下命令使环境生效:"
    echo -e "${YELLOW}source ~/.bashrc${RESET}"
    echo ""
    
    press_enter
    
    # 重新检测环境
    detect_environment
}

# 创建Conda环境
create_conda_env() {
    clear
    echo -e "${CYAN}=== 创建 Conda 环境 ===${RESET}"
    echo ""
    
    read -p "请输入新环境名称: " env_name
    
    if [ -z "$env_name" ]; then
        log_error "环境名不能为空"
        press_enter
        return
    fi
    
    echo ""
    echo "选择Python版本:"
    echo "1. Python 3.12"
    echo "2. Python 3.11"
    echo "3. Python 3.10"
    read -p "请选择 (默认3.11): " py_choice
    
    case $py_choice in
        1) python_version="3.12" ;;
        2) python_version="3.11" ;;
        3) python_version="3.10" ;;
        "")
            python_version="3.11"
            log_info "使用默认版本: Python 3.11"
            ;;
        *)
            log_error "无效选择"
            press_enter
            return
            ;;
    esac
    
    echo ""
    log_info "创建环境: $env_name (Python $python_version)"
    
    conda create -n $env_name python=$python_version -y
    
    if [ $? -eq 0 ]; then
        log_success "环境创建成功！"
        echo ""
        log_info "激活环境:"
        echo -e "${YELLOW}conda activate $env_name${RESET}"
        echo ""
        
        read -p "是否在新环境中安装基础包? (y/n): " install_basics
        
        if [[ "$install_basics" =~ ^[Yy]$ ]]; then
            log_info "安装基础包..."
            conda run -n $env_name pip install numpy pandas matplotlib ipython jupyter
            log_success "基础包安装完成"
        fi
    else
        log_error "环境创建失败"
    fi
    
    press_enter
}

# 快速创建常用环境
quick_env_menu() {
    clear
    echo -e "${CYAN}=== 快速创建常用环境 ===${RESET}"
    echo ""
    echo "1. PyTorch环境 (Python 3.10 + PyTorch + CUDA)"
    echo "2. TensorFlow环境 (Python 3.10 + TensorFlow + CUDA)"
    echo "3. 数据科学环境 (Python 3.10 + 数据分析全家桶)"
    echo "4. LLM推理环境 (Python 3.10 + vLLM + Transformers)"
    echo "0. 返回"
    echo ""
    read -p "请选择: " choice
    
    case $choice in
        1)
            log_info "创建PyTorch环境..."
            conda create -n pytorch python=3.10 -y
            conda run -n pytorch pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
            conda run -n pytorch pip install numpy pandas matplotlib jupyter
            log_success "PyTorch环境创建完成！使用: conda activate pytorch"
            ;;
        2)
            log_info "创建TensorFlow环境..."
            conda create -n tensorflow python=3.10 -y
            conda run -n tensorflow pip install tensorflow[and-cuda]
            conda run -n tensorflow pip install numpy pandas matplotlib jupyter
            log_success "TensorFlow环境创建完成！使用: conda activate tensorflow"
            ;;
        3)
            log_info "创建数据科学环境..."
            conda create -n datascience python=3.10 -y
            conda run -n datascience pip install numpy pandas matplotlib seaborn scikit-learn jupyter jupyterlab
            log_success "数据科学环境创建完成！使用: conda activate datascience"
            ;;
        4)
            log_info "创建LLM推理环境..."
            conda create -n llm python=3.10 -y
            conda run -n llm pip install vllm transformers accelerate bitsandbytes
            log_success "LLM推理环境创建完成！使用: conda activate llm"
            ;;
        0)
            return
            ;;
    esac
    
    press_enter
}

# 智能推荐并安装PyTorch
smart_install_pytorch() {
    clear
    echo -e "${CYAN}=== 智能安装 PyTorch ===${RESET}"
    echo ""
    
    if [ "$HAS_GPU" = false ]; then
        log_error "未检测到GPU，无法安装GPU版本"
        press_enter
        return
    fi
    
    log_info "当前CUDA版本: $CUDA_VERSION"
    log_info "正在分析最佳匹配..."
    echo ""
    
    # 根据CUDA版本推荐PyTorch
    CUDA_MAJOR=$(echo $CUDA_VERSION | cut -d'.' -f1)
    CUDA_MINOR=$(echo $CUDA_VERSION | cut -d'.' -f2)
    
    if [ "$CUDA_MAJOR" = "12" ]; then
        if [ "$CUDA_MINOR" -ge "1" ]; then
            RECOMMENDED_TORCH="torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121"
            TORCH_DESC="PyTorch 2.x (CUDA 12.1+)"
        else
            RECOMMENDED_TORCH="torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118"
            TORCH_DESC="PyTorch 2.x (CUDA 11.8) [向下兼容]"
        fi
    elif [ "$CUDA_MAJOR" = "11" ]; then
        if [ "$CUDA_MINOR" -ge "8" ]; then
            RECOMMENDED_TORCH="torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118"
            TORCH_DESC="PyTorch 2.x (CUDA 11.8)"
        else
            RECOMMENDED_TORCH="torch==1.13.1+cu117 torchvision==0.14.1+cu117 torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cu117"
            TORCH_DESC="PyTorch 1.13 (CUDA 11.7)"
        fi
    else
        log_error "不支持的CUDA版本: $CUDA_VERSION"
        press_enter
        return
    fi
    
    echo -e "${GREEN}推荐安装:${RESET} $TORCH_DESC"
    echo -e "${YELLOW}安装命令:${RESET} pip3 install $RECOMMENDED_TORCH"
    echo ""
    
    read -p "是否安装推荐版本? (y/n): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        log_info "正在安装..."
        pip3 install $RECOMMENDED_TORCH
        
        # 验证安装
        echo ""
        log_info "验证安装..."
        python3 << EOF
import torch
print(f"PyTorch版本: {torch.__version__}")
print(f"CUDA可用: {torch.cuda.is_available()}")
print(f"CUDA版本: {torch.version.cuda}")
print(f"GPU数量: {torch.cuda.device_count()}")
if torch.cuda.is_available():
    for i in range(torch.cuda.device_count()):
        print(f"GPU {i}: {torch.cuda.get_device_name(i)}")
EOF
        log_success "PyTorch安装完成！"
    fi
    
    press_enter
}

# 智能推荐并安装TensorFlow
smart_install_tensorflow() {
    clear
    echo -e "${CYAN}=== 智能安装 TensorFlow ===${RESET}"
    echo ""
    
    if [ "$HAS_GPU" = false ]; then
        log_error "未检测到GPU，无法安装GPU版本"
        press_enter
        return
    fi
    
    log_info "当前CUDA版本: $CUDA_VERSION"
    log_info "正在分析最佳匹配..."
    echo ""
    
    # 根据CUDA版本推荐TensorFlow
    CUDA_MAJOR=$(echo $CUDA_VERSION | cut -d'.' -f1)
    
    if [ "$CUDA_MAJOR" = "12" ] || [ "$CUDA_MAJOR" = "11" ]; then
        RECOMMENDED_TF="tensorflow[and-cuda]"
        TF_DESC="TensorFlow 2.15+ (自动匹配CUDA)"
    else
        log_error "不支持的CUDA版本: $CUDA_VERSION"
        press_enter
        return
    fi
    
    echo -e "${GREEN}推荐安装:${RESET} $TF_DESC"
    echo -e "${YELLOW}安装命令:${RESET} pip3 install $RECOMMENDED_TF"
    echo ""
    
    read -p "是否安装推荐版本? (y/n): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        log_info "正在安装..."
        pip3 install $RECOMMENDED_TF
        
        # 验证安装
        echo ""
        log_info "验证安装..."
        python3 << EOF
import tensorflow as tf
print(f"TensorFlow版本: {tf.__version__}")
print(f"GPU列表: {tf.config.list_physical_devices('GPU')}")
print(f"内置CUDA: {tf.test.is_built_with_cuda()}")
EOF
        log_success "TensorFlow安装完成！"
    fi
    
    press_enter
}

# 批量安装深度学习环境
batch_install_dl() {
    clear
    echo -e "${CYAN}=== 一键安装深度学习环境 ===${RESET}"
    echo ""
    
    log_warning "将安装以下组件："
    echo "- PyTorch (匹配当前CUDA)"
    echo "- TensorFlow (匹配当前CUDA)"
    echo "- 常用科学计算库"
    echo "- 数据处理库"
    echo "- 可视化工具"
    echo ""
    
    read -p "确认安装? (y/n): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        return
    fi
    
    # 更新pip
    log_info "更新pip..."
    pip3 install --upgrade pip
    
    # 安装PyTorch
    log_info "安装PyTorch..."
    CUDA_MAJOR=$(echo $CUDA_VERSION | cut -d'.' -f1)
    if [ "$CUDA_MAJOR" = "12" ]; then
        pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    elif [ "$CUDA_MAJOR" = "11" ]; then
        pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    fi
    
    # 安装TensorFlow
    log_info "安装TensorFlow..."
    pip3 install tensorflow[and-cuda]
    
    # 安装科学计算库
    log_info "安装科学计算库..."
    pip3 install numpy scipy scikit-learn
    
    # 安装数据处理
    log_info "安装数据处理库..."
    pip3 install pandas matplotlib seaborn pillow opencv-python
    
    # 安装深度学习工具
    log_info "安装深度学习工具..."
    pip3 install transformers datasets accelerate
    
    # 安装Jupyter
    log_info "安装Jupyter..."
    pip3 install jupyterlab ipywidgets
    
    log_success "环境安装完成！"
    press_enter
}

# 依赖库管理
library_manager() {
    while true; do
        clear
        echo -e "${CYAN}=== 依赖库管理 ===${RESET}"
        echo ""
        echo "1. 智能安装PyTorch (自动匹配CUDA)"
        echo "2. 智能安装TensorFlow (自动匹配CUDA)"
        echo "3. 安装JAX"
        echo "4. 安装常用科学计算库"
        echo "5. 安装图像处理库"
        echo "6. 安装NLP工具库"
        echo "7. 一键安装完整环境"
        echo "------------------------"
        echo "8. GPU推理工具管理"
        echo "9. 查看已安装库"
        echo "10. 卸载指定库"
        echo "0. 返回主菜单"
        echo ""
        read -p "请选择: " choice
        
        case $choice in
            1)
                smart_install_pytorch
                ;;
            2)
                smart_install_tensorflow
                ;;
            3)
                log_info "安装JAX..."
                CUDA_MAJOR=$(echo $CUDA_VERSION | cut -d'.' -f1)
                if [ "$CUDA_MAJOR" = "12" ]; then
                    pip3 install --upgrade "jax[cuda12_pip]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
                elif [ "$CUDA_MAJOR" = "11" ]; then
                    pip3 install --upgrade "jax[cuda11_pip]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
                fi
                log_success "JAX安装完成"
                press_enter
                ;;
            4)
                log_info "安装科学计算库..."
                pip3 install numpy scipy scikit-learn pandas matplotlib seaborn
                log_success "安装完成"
                press_enter
                ;;
            5)
                log_info "安装图像处理库..."
                pip3 install pillow opencv-python opencv-contrib-python albumentations
                log_success "安装完成"
                press_enter
                ;;
            6)
                log_info "安装NLP工具库..."
                pip3 install transformers datasets tokenizers sentencepiece
                log_success "安装完成"
                press_enter
                ;;
            7)
                batch_install_dl
                ;;
            8)
                inference_tools_menu
                ;;
            9)
                clear
                echo -e "${CYAN}=== 已安装的库 ===${RESET}"
                pip3 list | grep -E "torch|tensorflow|numpy|pandas|jax|transformers|onnx|tensorrt|vllm|deepspeed"
                press_enter
                ;;
            10)
                read -p "请输入要卸载的库名: " lib_name
                pip3 uninstall -y $lib_name
                log_success "已卸载 $lib_name"
                press_enter
                ;;
            0)
                return
                ;;
            *)
                log_error "无效选择"
                sleep 1
                ;;
        esac
    done
}

# GPU监控
gpu_monitor() {
    clear
    echo -e "${CYAN}=== GPU 实时监控 ===${RESET}"
    echo "按 Ctrl+C 退出监控"
    echo ""
    sleep 2
    
    if [ "$HAS_GPU" = true ]; then
        watch -n 1 nvidia-smi
    else
        log_error "未检测到GPU"
        press_enter
    fi
}

# GPU性能测试
gpu_benchmark() {
    clear
    echo -e "${CYAN}=== GPU 性能测试 ===${RESET}"
    echo ""
    
    if [ "$PYTORCH_VERSION" = "未安装" ]; then
        log_error "请先安装PyTorch"
        press_enter
        return
    fi
    
    log_info "创建测试脚本..."
    cat > /tmp/gpu_benchmark.py << 'EOF'
import torch
import time
import sys

print("="*50)
print("GPU性能测试")
print("="*50)
print(f"\nPyTorch版本: {torch.__version__}")
print(f"CUDA版本: {torch.version.cuda}")
print(f"CUDA可用: {torch.cuda.is_available()}")

if not torch.cuda.is_available():
    print("错误: CUDA不可用!")
    sys.exit(1)

print(f"\nGPU数量: {torch.cuda.device_count()}")
for i in range(torch.cuda.device_count()):
    print(f"GPU {i}: {torch.cuda.get_device_name(i)}")
    props = torch.cuda.get_device_properties(i)
    print(f"  显存: {props.total_memory / 1024**3:.2f} GB")
    print(f"  计算能力: {props.major}.{props.minor}")

# 测试不同矩阵大小
sizes = [1000, 5000, 10000]
device = torch.device("cuda:0")

print("\n" + "="*50)
print("矩阵乘法性能测试")
print("="*50)

for size in sizes:
    print(f"\n测试矩阵大小: {size}x{size}")
    
    a = torch.randn(size, size, device=device, dtype=torch.float32)
    b = torch.randn(size, size, device=device, dtype=torch.float32)
    
    # 预热
    for _ in range(3):
        _ = torch.matmul(a, b)
    torch.cuda.synchronize()
    
    # 正式测试
    times = []
    for _ in range(10):
        start = time.time()
        c = torch.matmul(a, b)
        torch.cuda.synchronize()
        times.append(time.time() - start)
    
    avg_time = sum(times) / len(times)
    flops = 2 * size**3 / avg_time / 1e9
    
    print(f"  平均时间: {avg_time*1000:.2f} ms")
    print(f"  性能: {flops:.2f} GFLOPS")
    
    # 显存使用
    memory_allocated = torch.cuda.memory_allocated(device) / 1024**2
    memory_reserved = torch.cuda.memory_reserved(device) / 1024**2
    print(f"  显存使用: {memory_allocated:.2f} MB (已分配) / {memory_reserved:.2f} MB (已保留)")

print("\n测试完成!")
EOF

    python3 /tmp/gpu_benchmark.py
    press_enter
}

# Jupyter管理
jupyter_manager() {
    while true; do
        clear
        echo -e "${CYAN}=== Jupyter 管理 ===${RESET}"
        echo ""
        echo "1. 安装JupyterLab"
        echo "2. 启动Jupyter (后台)"
        echo "3. 查看Jupyter状态"
        echo "4. 停止Jupyter"
        echo "5. 设置Jupyter密码"
        echo "0. 返回主菜单"
        echo ""
        read -p "请选择: " choice
        
        case $choice in
            1)
                log_info "安装JupyterLab及扩展..."
                pip3 install jupyterlab ipywidgets jupyter-resource-usage
                jupyter labextension install @jupyter-widgets/jupyterlab-manager
                log_success "安装完成"
                press_enter
                ;;
            2)
                read -p "端口号 (默认8888): " port
                port=${port:-8888}
                
                log_info "启动Jupyter on port $port..."
                nohup jupyter lab --ip=0.0.0.0 --port=$port --allow-root --no-browser > /tmp/jupyter.log 2>&1 &
                sleep 3
                
                log_success "Jupyter已启动"
                echo ""
                echo "查看Token:"
                jupyter lab list
                press_enter
                ;;
            3)
                jupyter lab list
                press_enter
                ;;
            4)
                pkill -f jupyter
                log_success "Jupyter已停止"
                press_enter
                ;;
            5)
                jupyter lab password
                press_enter
                ;;
            0)
                return
                ;;
            *)
                log_error "无效选择"
                sleep 1
                ;;
        esac
    done
}

# 快速启动常用容器
quick_start_containers() {
    clear
    echo -e "${CYAN}=== 快速启动项目模板 ===${RESET}"
    echo ""
    echo "1. 启动PyTorch训练环境"
    echo "2. 启动TensorFlow训练环境"
    echo "3. 启动Jupyter Notebook"
    echo "4. 启动Stable Diffusion WebUI"
    echo "5. 启动ComfyUI"
    echo "0. 返回"
    echo ""
    read -p "请选择: " choice
    
    case $choice in
        1)
            log_info "创建PyTorch训练目录..."
            mkdir -p ~/workspace/pytorch-project
            cd ~/workspace/pytorch-project
            
            cat > train.py << 'EOF'
import torch
import torch.nn as nn

print("PyTorch环境就绪!")
print(f"CUDA可用: {torch.cuda.is_available()}")
print(f"GPU数量: {torch.cuda.device_count()}")
EOF
            
            log_success "项目已创建在 ~/workspace/pytorch-project"
            ;;
        2)
            log_info "创建TensorFlow训练目录..."
            mkdir -p ~/workspace/tensorflow-project
            cd ~/workspace/tensorflow-project
            
            cat > train.py << 'EOF'
import tensorflow as tf

print("TensorFlow环境就绪!")
print(f"GPU列表: {tf.config.list_physical_devices('GPU')}")
EOF
            
            log_success "项目已创建在 ~/workspace/tensorflow-project"
            ;;
        3)
            jupyter_manager
            return
            ;;
        4)
            log_info "克隆Stable Diffusion WebUI..."
            cd ~
            if [ ! -d "stable-diffusion-webui" ]; then
                git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
            fi
            cd stable-diffusion-webui
            log_info "启动WebUI..."
            bash webui.sh --listen --port 7860
            ;;
        5)
            log_info "克隆ComfyUI..."
            cd ~
            if [ ! -d "ComfyUI" ]; then
                git clone https://github.com/comfyanonymous/ComfyUI.git
            fi
            cd ComfyUI
            pip3 install -r requirements.txt
            log_info "启动ComfyUI..."
            python3 main.py --listen 0.0.0.0 --port 8188
            ;;
        0)
            return
            ;;
    esac
    
    press_enter
}

# 主菜单
main_menu() {
    while true; do
        clear
        echo -e "${CYAN}"
        echo "╔════════════════════════════════════════════╗"
        echo "║   Vast.ai GPU容器管理工具 v${VERSION}        ║"
        echo "╚════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        # 快速状态显示
        if [ "$HAS_GPU" = true ]; then
            echo -e "${GREEN}● GPU状态:${RESET} $GPU_COUNT x $GPU_NAME"
            echo -e "${GREEN}● CUDA:${RESET} $CUDA_VERSION | ${GREEN}PyTorch:${RESET} $PYTORCH_VERSION | ${GREEN}TensorFlow:${RESET} $TF_VERSION"
        else
            echo -e "${RED}○ 未检测到GPU${RESET}"
        fi
        echo ""
        
        echo -e "${YELLOW}环境管理${RESET}"
        echo "1. 🖥️  一键显示环境信息"
        echo "2. 📦 Conda环境管理"
        echo "3. 🔧 智能依赖库管理"
        echo "4. ⚡ 一键安装完整环境"
        echo "5. 🚀 快速创建常用环境"
        echo "6. 🛠️  GPU推理工具管理"
        echo ""
        echo -e "${YELLOW}GPU监控${RESET}"
        echo "7. 📊 GPU实时监控"
        echo "8. 🎯 GPU性能测试"
        echo "9. ✅ 推理工具测试"
        echo ""
        echo -e "${YELLOW}开发工具${RESET}"
        echo "10. 📓 Jupyter管理"
        echo "11. 🎨 快速启动项目"
        echo ""
        echo -e "${YELLOW}系统工具${RESET}"
        echo "12. 🔄 刷新环境检测"
        echo "13. 💻 系统信息"
        echo ""
        echo "0. 退出"
        echo ""
        read -p "请选择操作: " choice
        
        case $choice in
            1) show_environment ;;
            2) conda_manager ;;
            3) library_manager ;;
            4) batch_install_dl ;;
            5) quick_env_menu ;;
            6) inference_tools_menu ;;
            7) gpu_monitor ;;
            8) gpu_benchmark ;;
            9) test_inference_tools ;;
            10) jupyter_manager ;;
            11) quick_start_containers ;;
            12) 
                log_info "正在刷新环境信息..."
                detect_environment
                log_success "环境信息已刷新"
                sleep 1
                ;;
            13)
                clear
                echo -e "${CYAN}=== 系统详细信息 ===${RESET}"
                echo ""
                echo -e "${YELLOW}系统信息:${RESET}"
                uname -a
                echo ""
                echo -e "${YELLOW}磁盘使用:${RESET}"
                df -h
                echo ""
                echo -e "${YELLOW}内存使用:${RESET}"
                free -h
                echo ""
                echo -e "${YELLOW}网络信息:${RESET}"
                ip addr show | grep -E "inet |inet6 " | head -5
                press_enter
                ;;
            0)
                log_info "感谢使用！"
                exit 0
                ;;
            *)
                log_error "无效选择"
                sleep 1
                ;;
        esac
    done
}

# GPU推理工具管理菜单
inference_tools_menu() {
    while true; do
        clear
        echo -e "${CYAN}=== GPU推理工具管理 ===${RESET}"
        echo ""
        
        echo -e "${YELLOW}当前已安装:${RESET}"
        echo "ONNX Runtime: ${GREEN}$ONNXRUNTIME_VERSION${RESET}"
        echo "TensorRT: ${GREEN}$TENSORRT_VERSION${RESET}"
        echo "OpenVINO: ${GREEN}$OPENVINO_VERSION${RESET}"
        echo "vLLM: ${GREEN}$VLLM_VERSION${RESET}"
        echo "DeepSpeed: ${GREEN}$DEEPSPEED_VERSION${RESET}"
        echo "xFormers: ${GREEN}$XFORMERS_VERSION${RESET}"
        echo "Flash-Attention: ${GREEN}$FLASHATTN_VERSION${RESET}"
        echo ""
        
        echo "------------------------"
        echo "1. 安装 ONNX Runtime GPU"
        echo "2. 安装 TensorRT"
        echo "3. 安装 OpenVINO"
        echo "4. 安装 vLLM (LLM高速推理)"
        echo "5. 安装 DeepSpeed (分布式训练)"
        echo "6. 安装 TensorRT-LLM"
        echo "7. 安装 xFormers (注意力加速)"
        echo "8. 安装 Flash-Attention"
        echo "9. 安装 SageAttention"
        echo "10. 安装 BitsAndBytes (量化)"
        echo "11. 安装 llama.cpp Python绑定"
        echo "12. 安装 CTransformers"
        echo "13. 安装 Triton推理服务器客户端"
        echo "------------------------"
        echo "14. 一键安装推理工具套件"
        echo "15. 测试所有推理工具"
        echo "0. 返回主菜单"
        echo ""
        read -p "请选择: " choice
        
        case $choice in
            1)
                log_info "安装 ONNX Runtime GPU..."
                pip3 install onnxruntime-gpu
                log_success "安装完成"
                press_enter
                ;;
            2)
                log_info "安装 TensorRT..."
                log_warning "TensorRT需要从NVIDIA官网下载对应版本"
                echo "下载地址: https://developer.nvidia.com/tensorrt"
                press_enter
                ;;
            3)
                log_info "安装 OpenVINO..."
                pip3 install openvino openvino-dev
                log_success "安装完成"
                press_enter
                ;;
            4)
                log_info "安装 vLLM..."
                pip3 install vllm
                log_success "安装完成"
                press_enter
                ;;
            5)
                log_info "安装 DeepSpeed..."
                pip3 install deepspeed
                log_success "安装完成"
                press_enter
                ;;
            6)
                log_info "安装 TensorRT-LLM..."
                log_warning "TensorRT-LLM需要特定环境，请参考官方文档"
                echo "GitHub: https://github.com/NVIDIA/TensorRT-LLM"
                press_enter
                ;;
            7)
                log_info "安装 xFormers..."
                pip3 install xformers
                log_success "安装完成"
                press_enter
                ;;
            8)
                log_info "安装 Flash-Attention..."
                pip3 install flash-attn --no-build-isolation
                log_success "安装完成"
                press_enter
                ;;
            9)
                log_info "安装 SageAttention..."
                pip3 install sageattention
                log_success "安装完成"
                press_enter
                ;;
            10)
                log_info "安装 BitsAndBytes..."
                pip3 install bitsandbytes
                log_success "安装完成"
                press_enter
                ;;
            11)
                log_info "安装 llama-cpp-python (CUDA支持)..."
                CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip3 install llama-cpp-python
                log_success "安装完成"
                press_enter
                ;;
            12)
                log_info "安装 CTransformers..."
                pip3 install ctransformers
                log_success "安装完成"
                press_enter
                ;;
            13)
                log_info "安装 Triton客户端..."
                pip3 install tritonclient[all]
                log_success "安装完成"
                press_enter
                ;;
            14)
                log_info "一键安装推理工具套件..."
                pip3 install onnxruntime-gpu vllm deepspeed xformers bitsandbytes
                log_success "套件安装完成"
                press_enter
                ;;
            15)
                test_inference_tools
                ;;
            0)
                return
                ;;
            *)
                log_error "无效选择"
                sleep 1
                ;;
        esac
        
        # 重新检测环境
        detect_environment
    done
}

# 测试推理工具
test_inference_tools() {
    clear
    echo -e "${CYAN}=== 测试推理工具 ===${RESET}"
    echo ""
    
    log_info "测试 ONNX Runtime..."
    python3 << 'EOF'
try:
    import onnxruntime as ort
    print(f"✓ ONNX Runtime {ort.__version__}")
    print(f"  Providers: {ort.get_available_providers()}")
except Exception as e:
    print(f"✗ ONNX Runtime: {e}")
print()
EOF

    log_info "测试 TensorRT..."
    python3 << 'EOF'
try:
    import tensorrt as trt
    print(f"✓ TensorRT {trt.__version__}")
except Exception as e:
    print(f"✗ TensorRT: {e}")
print()
EOF

    log_info "测试 OpenVINO..."
    python3 << 'EOF'
try:
    import openvino as ov
    print(f"✓ OpenVINO {ov.__version__}")
except Exception as e:
    print(f"✗ OpenVINO: {e}")
print()
EOF

    log_info "测试 vLLM..."
    python3 << 'EOF'
try:
    import vllm
    print(f"✓ vLLM {vllm.__version__}")
except Exception as e:
    print(f"✗ vLLM: {e}")
print()
EOF

    log_info "测试 DeepSpeed..."
    python3 << 'EOF'
try:
    import deepspeed
    print(f"✓ DeepSpeed {deepspeed.__version__}")
except Exception as e:
    print(f"✗ DeepSpeed: {e}")
print()
EOF

    log_info "测试 xFormers..."
    python3 << 'EOF'
try:
    import xformers
    print(f"✓ xFormers {xformers.__version__}")
except Exception as e:
    print(f"✗ xFormers: {e}")
print()
EOF

    log_info "测试 Flash-Attention..."
    python3 << 'EOF'
try:
    import flash_attn
    print(f"✓ Flash-Attention {flash_attn.__version__}")
except Exception as e:
    print(f"✗ Flash-Attention: {e}")
print()
EOF

    log_info "测试 BitsAndBytes..."
    python3 << 'EOF'
try:
    import bitsandbytes as bnb
    print(f"✓ BitsAndBytes {bnb.__version__}")
except Exception as e:
    print(f"✗ BitsAndBytes: {e}")
print()
EOF

    log_info "测试 llama.cpp..."
    python3 << 'EOF'
try:
    import llama_cpp
    print(f"✓ llama-cpp-python {llama_cpp.__version__}")
except Exception as e:
    print(f"✗ llama-cpp-python: {e}")
print()
EOF

    log_info "测试 CTransformers..."
    python3 << 'EOF'
try:
    import ctransformers
    print(f"✓ CTransformers {ctransformers.__version__}")
except Exception as e:
    print(f"✗ CTransformers: {e}")
print()
EOF

    press_enter
}

# 初始化
clear
echo -e "${CYAN}正在初始化...${RESET}"
detect_environment
sleep 1

# 运行主菜单
main_menu