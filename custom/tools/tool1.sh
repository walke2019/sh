#!/bin/bash
# 现代化服务器管理工具箱
# 版本: 1.0.0

VERSION="1.0.0"

# 颜色定义
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
WHITE='\033[37m'
RESET='\033[0m'

# 全局变量
PERMISSION_GRANTED="false"
ENABLE_STATS="true"

# 日志函数
log_info() {
    echo -e "${CYAN}[INFO]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${RESET} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

# 统计函数（可选）
send_stats() {
    if [ "$ENABLE_STATS" == "false" ]; then
        return
    fi
    # 这里可以添加统计代码
}

# 用户许可协议
user_agreement() {
    clear
    echo -e "${CYAN}=== 欢迎使用服务器管理工具箱 ===${RESET}"
    echo "版本: $VERSION"
    echo ""
    echo "使用条款:"
    echo "1. 本工具仅供学习和合法用途使用"
    echo "2. 使用者需对使用本工具造成的后果负责"
    echo "3. 建议在使用前备份重要数据"
    echo ""
    read -p "是否同意以上条款？(y/n): " agreement
    
    if [[ "$agreement" =~ ^[Yy]$ ]]; then
        PERMISSION_GRANTED="true"
        log_success "已同意用户协议"
        sleep 1
    else
        log_info "已取消操作"
        exit 0
    fi
}

# 检查首次运行
check_first_run() {
    if [ "$PERMISSION_GRANTED" == "false" ]; then
        user_agreement
    fi
}

# 获取IP地址
get_ip_info() {
    IPV4=$(curl -s -4 https://ipinfo.io/ip 2>/dev/null || echo "未获取到IPv4")
    IPV6=$(curl -s -6 https://ipinfo.io/ip 2>/dev/null || echo "未获取到IPv6")
    LOCATION=$(curl -s https://ipinfo.io/country 2>/dev/null || echo "未知")
}

# 通用安装函数
install_package() {
    local packages="$@"
    
    for package in $packages; do
        if ! command -v "$package" &>/dev/null; then
            log_info "正在安装 $package..."
            
            if command -v apt &>/dev/null; then
                apt update -y && apt install -y "$package"
            elif command -v yum &>/dev/null; then
                yum install -y "$package"
            elif command -v dnf &>/dev/null; then
                dnf install -y "$package"
            elif command -v apk &>/dev/null; then
                apk add "$package"
            elif command -v pacman &>/dev/null; then
                pacman -Sy --noconfirm "$package"
            else
                log_error "不支持的包管理器"
                return 1
            fi
            
            log_success "$package 安装完成"
        fi
    done
}

# 卸载软件包
remove_package() {
    local packages="$@"
    
    for package in $packages; do
        log_info "正在卸载 $package..."
        
        if command -v apt &>/dev/null; then
            apt purge -y "$package"
        elif command -v yum &>/dev/null; then
            yum remove -y "$package"
        elif command -v dnf &>/dev/null; then
            dnf remove -y "$package"
        elif command -v apk &>/dev/null; then
            apk del "$package"
        elif command -v pacman &>/dev/null; then
            pacman -R --noconfirm "$package"
        fi
        
        log_success "$package 已卸载"
    done
}

# Docker相关函数
install_docker() {
    if command -v docker &>/dev/null; then
        log_info "Docker 已安装"
        return 0
    fi
    
    log_info "正在安装 Docker..."
    
    if command -v apt &>/dev/null; then
        apt update
        apt install -y ca-certificates curl gnupg
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
        
        echo \
          "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
          tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        apt update
        apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    else
        curl -fsSL https://get.docker.com | sh
    fi
    
    systemctl enable docker
    systemctl start docker
    
    log_success "Docker 安装完成"
}

# Docker容器管理
docker_container_menu() {
    while true; do
        clear
        echo -e "${CYAN}=== Docker 容器管理 ===${RESET}"
        docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        echo "1. 创建新容器"
        echo "2. 启动容器"
        echo "3. 停止容器"
        echo "4. 重启容器"
        echo "5. 删除容器"
        echo "6. 进入容器"
        echo "7. 查看容器日志"
        echo "8. 查看容器资源使用"
        echo "9. 启动所有容器"
        echo "10. 停止所有容器"
        echo "0. 返回主菜单"
        echo ""
        read -p "请选择操作: " choice
        
        case $choice in
            1)
                read -p "请输入 docker run 命令: " docker_cmd
                eval $docker_cmd
                ;;
            2)
                read -p "请输入容器名称: " container_name
                docker start $container_name
                ;;
            3)
                read -p "请输入容器名称: " container_name
                docker stop $container_name
                ;;
            4)
                read -p "请输入容器名称: " container_name
                docker restart $container_name
                ;;
            5)
                read -p "请输入容器名称: " container_name
                read -p "确认删除容器 $container_name? (y/n): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    docker rm -f $container_name
                fi
                ;;
            6)
                read -p "请输入容器名称: " container_name
                docker exec -it $container_name /bin/bash || docker exec -it $container_name /bin/sh
                ;;
            7)
                read -p "请输入容器名称: " container_name
                docker logs -f $container_name
                ;;
            8)
                docker stats --no-stream
                ;;
            9)
                docker start $(docker ps -a -q)
                ;;
            10)
                docker stop $(docker ps -q)
                ;;
            0)
                return
                ;;
            *)
                log_error "无效选择"
                ;;
        esac
        
        read -p "按回车键继续..."
    done
}

# Docker镜像管理
docker_image_menu() {
    while true; do
        clear
        echo -e "${CYAN}=== Docker 镜像管理 ===${RESET}"
        docker images
        echo ""
        echo "1. 拉取镜像"
        echo "2. 删除镜像"
        echo "3. 清理未使用镜像"
        echo "4. 查看镜像详情"
        echo "0. 返回主菜单"
        echo ""
        read -p "请选择操作: " choice
        
        case $choice in
            1)
                read -p "请输入镜像名称: " image_name
                docker pull $image_name
                ;;
            2)
                read -p "请输入镜像ID或名称: " image_id
                docker rmi $image_id
                ;;
            3)
                read -p "确认清理所有未使用镜像? (y/n): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    docker image prune -a
                fi
                ;;
            4)
                read -p "请输入镜像ID或名称: " image_id
                docker inspect $image_id
                ;;
            0)
                return
                ;;
            *)
                log_error "无效选择"
                ;;
        esac
        
        read -p "按回车键继续..."
    done
}

# 系统信息
show_system_info() {
    clear
    echo -e "${CYAN}=== 系统信息 ===${RESET}"
    echo ""
    echo -e "${YELLOW}操作系统:${RESET} $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "${YELLOW}内核版本:${RESET} $(uname -r)"
    echo -e "${YELLOW}CPU架构:${RESET} $(uname -m)"
    echo -e "${YELLOW}主机名:${RESET} $(hostname)"
    echo ""
    
    get_ip_info
    echo -e "${YELLOW}IPv4地址:${RESET} $IPV4"
    echo -e "${YELLOW}IPv6地址:${RESET} $IPV6"
    echo -e "${YELLOW}地理位置:${RESET} $LOCATION"
    echo ""
    
    echo -e "${YELLOW}CPU信息:${RESET}"
    lscpu | grep "Model name" | sed 's/Model name://g'
    echo -e "${YELLOW}CPU核心数:${RESET} $(nproc)"
    echo ""
    
    echo -e "${YELLOW}内存信息:${RESET}"
    free -h | grep -E "Mem|Swap"
    echo ""
    
    echo -e "${YELLOW}磁盘使用:${RESET}"
    df -h | grep -E "^/dev/"
    echo ""
    
    read -p "按回车键继续..."
}

# 防火墙管理
firewall_menu() {
    while true; do
        clear
        echo -e "${CYAN}=== 防火墙管理 ===${RESET}"
        echo ""
        echo "当前防火墙规则:"
        iptables -L INPUT -n --line-numbers 2>/dev/null || echo "无法获取规则"
        echo ""
        echo "1. 开放端口"
        echo "2. 关闭端口"
        echo "3. 允许IP访问"
        echo "4. 禁止IP访问"
        echo "5. 清除所有规则"
        echo "6. 保存规则"
        echo "0. 返回主菜单"
        echo ""
        read -p "请选择操作: " choice
        
        case $choice in
            1)
                read -p "请输入要开放的端口: " port
                iptables -I INPUT -p tcp --dport $port -j ACCEPT
                iptables -I INPUT -p udp --dport $port -j ACCEPT
                log_success "端口 $port 已开放"
                ;;
            2)
                read -p "请输入要关闭的端口: " port
                iptables -D INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null
                iptables -D INPUT -p udp --dport $port -j ACCEPT 2>/dev/null
                log_success "端口 $port 已关闭"
                ;;
            3)
                read -p "请输入要允许的IP: " ip
                iptables -I INPUT -s $ip -j ACCEPT
                log_success "IP $ip 已加入白名单"
                ;;
            4)
                read -p "请输入要禁止的IP: " ip
                iptables -I INPUT -s $ip -j DROP
                log_success "IP $ip 已加入黑名单"
                ;;
            5)
                read -p "确认清除所有规则? (y/n): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    iptables -F
                    iptables -X
                    log_success "规则已清除"
                fi
                ;;
            6)
                if command -v netfilter-persistent &>/dev/null; then
                    netfilter-persistent save
                elif command -v iptables-save &>/dev/null; then
                    iptables-save > /etc/iptables/rules.v4
                fi
                log_success "规则已保存"
                ;;
            0)
                return
                ;;
            *)
                log_error "无效选择"
                ;;
        esac
        
        read -p "按回车键继续..."
    done
}

# SSL证书管理
ssl_menu() {
    while true; do
        clear
        echo -e "${CYAN}=== SSL证书管理 ===${RESET}"
        echo ""
        echo "1. 申请Let's Encrypt证书"
        echo "2. 查看证书信息"
        echo "3. 续期证书"
        echo "4. 删除证书"
        echo "0. 返回主菜单"
        echo ""
        read -p "请选择操作: " choice
        
        case $choice in
            1)
                if ! command -v certbot &>/dev/null; then
                    install_package certbot
                fi
                read -p "请输入域名: " domain
                certbot certonly --standalone -d $domain
                ;;
            2)
                read -p "请输入域名: " domain
                if [ -f "/etc/letsencrypt/live/$domain/fullchain.pem" ]; then
                    openssl x509 -in /etc/letsencrypt/live/$domain/fullchain.pem -noout -text
                else
                    log_error "证书不存在"
                fi
                ;;
            3)
                certbot renew
                ;;
            4)
                read -p "请输入域名: " domain
                certbot delete --cert-name $domain
                ;;
            0)
                return
                ;;
            *)
                log_error "无效选择"
                ;;
        esac
        
        read -p "按回车键继续..."
    done
}

# 系统优化
system_optimization() {
    clear
    echo -e "${CYAN}=== 系统优化 ===${RESET}"
    echo ""
    echo "1. 优化内核参数"
    echo "2. 清理系统垃圾"
    echo "3. 优化SSH配置"
    echo "4. 设置交换空间"
    echo "0. 返回主菜单"
    echo ""
    read -p "请选择操作: " choice
    
    case $choice in
        1)
            log_info "正在优化内核参数..."
            cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_tw_reuse = 1
net.core.somaxconn = 1024
EOF
            sysctl -p
            log_success "内核参数优化完成"
            ;;
        2)
            log_info "正在清理系统..."
            if command -v apt &>/dev/null; then
                apt autoremove -y
                apt autoclean -y
            elif command -v yum &>/dev/null; then
                yum clean all
            fi
            log_success "系统清理完成"
            ;;
        3)
            log_info "正在优化SSH配置..."
            sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
            sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
            systemctl restart sshd
            log_success "SSH优化完成"
            ;;
        4)
            read -p "请输入交换空间大小(MB): " swap_size
            fallocate -l ${swap_size}M /swapfile
            chmod 600 /swapfile
            mkswap /swapfile
            swapon /swapfile
            echo '/swapfile none swap sw 0 0' >> /etc/fstab
            log_success "交换空间设置完成"
            ;;
        0)
            return
            ;;
        *)
            log_error "无效选择"
            ;;
    esac
    
    read -p "按回车键继续..."
}

# 软件包管理菜单
package_menu() {
    while true; do
        clear
        echo -e "${CYAN}=== 软件包管理 ===${RESET}"
        echo ""
        echo "1. 安装软件包"
        echo "2. 卸载软件包"
        echo "3. 更新系统软件包"
        echo "4. 搜索软件包"
        echo "5. 查看已安装软件"
        echo "0. 返回主菜单"
        echo ""
        read -p "请选择操作: " choice
        
        case $choice in
            1)
                echo ""
                echo "常用软件包："
                echo "  基础工具: curl wget git vim nano htop"
                echo "  网络工具: net-tools traceroute nmap"
                echo "  压缩工具: zip unzip tar gzip"
                echo "  开发工具: gcc make python3 nodejs"
                echo ""
                read -p "请输入要安装的软件包名(多个用空格分隔): " packages
                if [ -n "$packages" ]; then
                    install_package $packages
                    log_success "安装完成"
                fi
                ;;
            2)
                echo ""
                read -p "请输入要卸载的软件包名(多个用空格分隔): " packages
                if [ -n "$packages" ]; then
                    read -p "确认卸载 $packages ? (y/n): " confirm
                    if [[ "$confirm" =~ ^[Yy]$ ]]; then
                        remove_package $packages
                        log_success "卸载完成"
                    fi
                fi
                ;;
            3)
                log_info "正在更新系统软件包..."
                if command -v apt &>/dev/null; then
                    apt update && apt upgrade -y
                elif command -v yum &>/dev/null; then
                    yum update -y
                elif command -v dnf &>/dev/null; then
                    dnf update -y
                elif command -v pacman &>/dev/null; then
                    pacman -Syu --noconfirm
                fi
                log_success "系统更新完成"
                ;;
            4)
                read -p "请输入要搜索的软件包名: " keyword
                if [ -n "$keyword" ]; then
                    if command -v apt &>/dev/null; then
                        apt search "$keyword"
                    elif command -v yum &>/dev/null; then
                        yum search "$keyword"
                    elif command -v dnf &>/dev/null; then
                        dnf search "$keyword"
                    elif command -v pacman &>/dev/null; then
                        pacman -Ss "$keyword"
                    fi
                fi
                ;;
            5)
                echo ""
                echo "已安装的软件包："
                if command -v apt &>/dev/null; then
                    dpkg -l | grep ^ii | awk '{print $2}' | head -50
                    echo ""
                    echo "(仅显示前50个，使用 dpkg -l 查看全部)"
                elif command -v yum &>/dev/null; then
                    yum list installed | head -50
                elif command -v dnf &>/dev/null; then
                    dnf list installed | head -50
                elif command -v pacman &>/dev/null; then
                    pacman -Q | head -50
                fi
                ;;
            0)
                return
                ;;
            *)
                log_error "无效选择"
                ;;
        esac
        
        read -p "按回车键继续..."
    done
}

# 主菜单
main_menu() {
    while true; do
        clear
        echo -e "${CYAN}"
        echo "╔═══════════════════════════════════════╗"
        echo "║   服务器管理工具箱 v${VERSION}          ║"
        echo "╚═══════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        echo -e "${YELLOW}系统管理${RESET}"
        echo "1. 系统信息"
        echo "2. 系统优化"
        echo ""
        echo -e "${YELLOW}Docker管理${RESET}"
        echo "3. 安装Docker"
        echo "4. Docker容器管理"
        echo "5. Docker镜像管理"
        echo ""
        echo -e "${YELLOW}安全管理${RESET}"
        echo "6. 防火墙管理"
        echo "7. SSL证书管理"
        echo ""
        echo -e "${YELLOW}其他${RESET}"
        echo "8. 软件安装/卸载"
        echo ""
        echo "0. 退出"
        echo ""
        read -p "请选择操作: " choice
        
        case $choice in
            1) show_system_info ;;
            2) system_optimization ;;
            3) install_docker ;;
            4) docker_container_menu ;;
            5) docker_image_menu ;;
            6) firewall_menu ;;
            7) ssl_menu ;;
            8) package_menu ;;
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

# 主程序入口
check_first_run
main_menu
