#!/bin/bash
Green="\033[32m"
Font="\033[0m"
Red="\033[31m" 

LOGFILE="/var/log/swap_script.log"
exec > >(tee -a $LOGFILE) 2>&1

#root权限
root_need(){
    if [[ $EUID -ne 0 ]]; then
        echo -e "${Red}Error: This script must be run as root!${Font}"
        exit 1
    fi
}

#检测ovz
ovz_no(){
    if [[ -d "/proc/vz" ]]; then
        echo -e "${Red}Your VPS is based on OpenVZ, not supported!${Font}"
        exit 1
    fi
}

# 添加 swap
add_swap(){
    mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    recommended_swap=$(($mem / 1024 * 2))
    echo -e "${Green}请输入需要添加的 swap，建议为内存的 2 倍（推荐：${recommended_swap}MB）！${Font}"
    read -e -p "请输入 swap 数值:" swapsize

    if ! [[ $swapsize =~ ^[0-9]+$ ]]; then
        echo -e "${Red}Error: 输入无效，请输入数字！${Font}"
        exit 1
    fi

    # 检查是否存在 swapfile
    grep -q "swapfile" /etc/fstab
    if [ $? -ne 0 ]; then
        echo -e "${Green}swapfile 未发现，正在为其创建 swapfile${Font}"
        
        if ! command -v fallocate &> /dev/null; then
            echo -e "${Green}fallocate 不可用，使用 dd 创建 swap 文件${Font}"
            dd if=/dev/zero of=/swapfile bs=1M count=${swapsize}
        else
            fallocate -l ${swapsize}M /swapfile
        fi

        chmod 600 /swapfile
        mkswap /swapfile && swapon /swapfile
        echo '/swapfile none swap defaults 0 0' >> /etc/fstab
        echo -e "${Green}swap 创建成功，并查看信息：${Font}"
        cat /proc/swaps
        cat /proc/meminfo | grep Swap
    else
        echo -e "${Red}swapfile 已存在，swap 设置失败，请先删除 swap 后重新设置！${Font}"
    fi
}

# 删除 swap
del_swap(){
    grep -q "swapfile" /etc/fstab
    if [ $? -eq 0 ]; then
        echo -e "${Green}swapfile 已发现，正在将其移除...${Font}"
        sed -i '/swapfile/d' /etc/fstab
        swapoff -a
        rm -f /swapfile
        echo -e "${Green}swap 已删除！${Font}"
    else
        echo -e "${Red}swapfile 未发现，swap 删除失败！${Font}"
    fi
}

# 开始菜单
main(){
    root_need
    ovz_no
    while true; do
        clear
        echo -e "———————————————————————————————————————"
        echo -e "${Green}Linux VPS 一键添加/删除 swap 脚本${Font}"
        echo -e "${Green}1、添加 swap${Font}"
        echo -e "${Green}2、删除 swap${Font}"
        echo -e "———————————————————————————————————————"
        read -e -p "请输入数字 [1-2]:" num
        case "$num" in
            1)
            add_swap
            break
            ;;
            2)
            del_swap
            break
            ;;
            *)
            echo -e "${Red}请输入正确的数字 [1-2]${Font}"
            sleep 2
            ;;
        esac
    done
}

main
