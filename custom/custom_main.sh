#!/bin/bash
# 自定义工具箱主入口
# 版本: 1.0.0

# 颜色定义（与上游保持一致）
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_bai='\033[0m'
gl_zi='\033[35m'
gl_kjlan='\033[96m'

# 获取脚本所在目录
CUSTOM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="${CUSTOM_DIR}/tools"
CONFIG_DIR="${CUSTOM_DIR}/config"

# 加载配置文件
load_config() {
    if [ -f "${CONFIG_DIR}/settings.conf" ]; then
        source "${CONFIG_DIR}/settings.conf"
    fi
}

# 自定义工具箱主菜单
custom_toolbox_menu() {
    while true; do
        clear
        echo -e "${gl_kjlan}"
        echo "╔═══════════════════════════════╗"
        echo "║    自定义工具箱 v1.0.0        ║"
        echo "╚═══════════════════════════════╝"
        echo -e "${gl_bai}"
        echo -e "${gl_kjlan}------------------------${gl_bai}"
        echo -e "${gl_kjlan}1.   ${gl_bai}服务器管理工具箱"
        echo -e "${gl_kjlan}2.   ${gl_bai}Vast.ai GPU容器管理"
        echo -e "${gl_kjlan}3.   ${gl_bai}自定义工具 3"
        echo -e "${gl_kjlan}4.   ${gl_bai}配置管理"
        echo -e "${gl_kjlan}------------------------${gl_bai}"
        echo -e "${gl_kjlan}0.   ${gl_bai}返回上级菜单"
        echo -e "${gl_kjlan}------------------------${gl_bai}"
        read -e -p "请输入你的选择: " choice

        case $choice in
            1)
                if [ -f "${TOOLS_DIR}/tool1.sh" ]; then
                    bash "${TOOLS_DIR}/tool1.sh"
                else
                    echo -e "${gl_hong}工具脚本不存在！${gl_bai}"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "${TOOLS_DIR}/vast.sh" ]; then
                    bash "${TOOLS_DIR}/vast.sh"
                else
                    echo -e "${gl_hong}工具脚本不存在！${gl_bai}"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "${TOOLS_DIR}/tool3.sh" ]; then
                    bash "${TOOLS_DIR}/tool3.sh"
                else
                    echo -e "${gl_hong}工具脚本不存在！${gl_bai}"
                    sleep 2
                fi
                ;;
            4)
                config_menu
                ;;
            0)
                break
                ;;
            *)
                echo -e "${gl_hong}无效的输入！${gl_bai}"
                sleep 1
                ;;
        esac
    done
}

# 配置管理菜单
config_menu() {
    clear
    echo -e "${gl_kjlan}配置管理${gl_bai}"
    echo "功能开发中..."
    sleep 2
}

# 加载配置并启动主菜单
load_config
custom_toolbox_menu
