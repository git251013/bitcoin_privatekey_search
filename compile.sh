#!/bin/bash

echo "=== Bitcoin Private Key Search Compilation ==="
echo "Target Address: 19YZECXj3SxEZMoUeJ1yiPsw8xANe7M7QR"
echo ""

# 检查CUDA编译器
if ! command -v nvcc &> /dev/null; then
    echo "错误: 未找到 nvcc。请安装CUDA工具包。"
    echo "安装命令: sudo apt install nvidia-cuda-toolkit"
    exit 1
fi

# 检查OpenSSL
if ! pkg-config --exists openssl; then
    echo "错误: 未找到OpenSSL开发库。"
    echo "安装命令: sudo apt install libssl-dev"
    exit 1
fi

# 获取GPU架构信息
echo "检测GPU架构..."
GPU_ARCH=$(nvidia-smi --query-gpu=compute_cap --format=csv,noheader | head -1 | sed 's/\.//')
if [ -z "$GPU_ARCH" ]; then
    echo "警告: 无法自动检测GPU架构，使用默认架构sm_70"
    GPU_ARCH="70"
else
    echo "检测到GPU架构: sm_${GPU_ARCH}"
fi

# 编译参数
NVCC_FLAGS="-O3 -std=c++14 -arch=sm_${GPU_ARCH}"
NVCC_FLAGS+=" -Xcompiler -fopenmp -Wno-deprecated-gpu-targets"

# 链接库
LIBS="-lcrypto -lssl"

# 源文件
SOURCE="bitcoin_search.cu"

# 输出文件
OUTPUT="bitcoin_search"

echo ""
echo "编译参数: $NVCC_FLAGS"
echo "开始编译..."

# 执行编译
nvcc $NVCC_FLAGS $SOURCE -o $OUTPUT $LIBS

# 检查编译结果
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 编译成功!"
    echo "生成的可执行文件: ./$OUTPUT"
    echo ""
    echo "运行命令: ./$OUTPUT"
    
    # 显示文件信息
    echo ""
    echo "文件信息:"
    ls -lh $OUTPUT
else
    echo ""
    echo "❌ 编译失败!"
    exit 1
fi
