#!/bin/bash
# 将自定义工具箱集成到主脚本的辅助脚本
# 使用方法：bash custom/integrate.sh

echo "================================"
echo "  自定义工具箱集成向导"
echo "================================"
echo ""

# 颜色定义
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NC='\033[0m' # No Color

# 检查是否在正确的目录
if [ ! -f "kejilion.sh" ]; then
    echo -e "${RED}错误：请在项目根目录下运行此脚本！${NC}"
    exit 1
fi

# 检查自定义工具箱是否存在
if [ ! -f "custom/custom_main.sh" ]; then
    echo -e "${RED}错误：找不到自定义工具箱！${NC}"
    exit 1
fi

echo -e "${BLUE}检测到以下文件：${NC}"
echo "  ✓ kejilion.sh (上游主脚本)"
echo "  ✓ custom/custom_main.sh (自定义工具箱)"
echo ""

# 检查是否已经集成
if grep -q "自定义工具箱" kejilion.sh 2>/dev/null; then
    echo -e "${YELLOW}自定义工具箱已经集成到主脚本！${NC}"
    echo ""
    read -p "是否重新集成？(y/n): " choice
    if [ "$choice" != "y" ]; then
        echo "操作已取消。"
        exit 0
    fi
fi

echo -e "${YELLOW}注意：此操作将修改 kejilion.sh 文件${NC}"
echo ""
read -p "是否继续？(y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "操作已取消。"
    exit 0
fi

# 备份原始脚本
echo ""
echo -e "${BLUE}正在备份原始脚本...${NC}"
cp kejilion.sh kejilion.sh.backup.$(date +%Y%m%d_%H%M%S)
echo -e "${GREEN}✓ 备份完成${NC}"

echo ""
echo -e "${BLUE}集成说明：${NC}"
echo ""
echo "请手动编辑 kejilion.sh 文件，添加以下内容："
echo ""
echo -e "${YELLOW}1. 在主菜单显示部分（约 14546 行附近）添加：${NC}"
echo '   echo -e "${gl_kjlan}16.  ${gl_bai}自定义工具箱"'
echo ""
echo -e "${YELLOW}2. 在 case 语句部分（约 14573 行附近）添加：${NC}"
echo '   16) bash custom/custom_main.sh ;;'
echo ""
echo -e "${YELLOW}3. 或者创建快捷命令（推荐）：${NC}"
echo '   在 ~/.bashrc 中添加：'
echo '   alias ctool="bash $(pwd)/custom/custom_main.sh"'
echo ""

# 询问是否创建快捷命令
read -p "是否创建快捷命令 'ctool'？(y/n): " create_alias

if [ "$create_alias" = "y" ]; then
    CUSTOM_PATH="$(pwd)/custom/custom_main.sh"
    
    # 检查是否已存在别名
    if grep -q "alias ctool=" ~/.bashrc 2>/dev/null; then
        echo -e "${YELLOW}别名已存在，正在更新...${NC}"
        sed -i '/alias ctool=/d' ~/.bashrc
    fi
    
    # 添加别名
    echo "" >> ~/.bashrc
    echo "# 自定义工具箱快捷命令" >> ~/.bashrc
    echo "alias ctool='bash ${CUSTOM_PATH}'" >> ~/.bashrc
    
    echo -e "${GREEN}✓ 快捷命令创建成功！${NC}"
    echo ""
    echo "请运行以下命令使其生效："
    echo "  source ~/.bashrc"
    echo ""
    echo "然后可以直接使用 'ctool' 命令启动自定义工具箱"
fi

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  集成向导完成！${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "启动方式："
echo "  1. 直接运行：bash custom/custom_main.sh"
if [ "$create_alias" = "y" ]; then
    echo "  2. 快捷命令：ctool (需要先 source ~/.bashrc)"
fi
echo ""
