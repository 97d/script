#!/bin/bash  
  
# 函数：检查并安装jq  
install_jq() {  
    # 检查jq是否已安装  
    if ! command -v jq &> /dev/null; then  
        # 检测操作系统并安装jq  
        if [[ $(uname) == 'Darwin' ]]; then  
            # macOS 系统  
            echo "正在安装 jq for macOS..."  
            # 使用Homebrew安装jq  
            if ! brew list --versions jq &> /dev/null; then  
                brew install jq  
            fi  
        elif [[ $(id -u) -eq 0 ]]; then  
            # Linux 系统，且当前用户为root  
            echo "正在安装 jq for Linux..."  
            # 使用apt-get（适用于Debian/Ubuntu等）  
            if ! dpkg -l | grep -q '^ii  jq'; then  
                apt-get update  
                apt-get install -y jq  
            fi  
        elif [[ -x $(command -v yum) ]]; then  
            # 使用yum（适用于CentOS/RedHat等较老版本）  
            echo "正在安装 jq for CentOS/RedHat..."  
            if ! yum list installed | grep -q jq; then  
                yum install -y jq  
            fi  
        elif [[ -x $(command -v dnf) ]]; then  
            # 使用dnf（适用于Fedora等新版本）  
            echo "正在安装 jq for Fedora..."  
            if ! dnf list installed | grep -q jq; then  
                dnf install -y jq  
            fi  
        elif [[ -x $(command -v pacman) ]]; then  
            # 使用pacman（适用于Arch Linux等）  
            echo "正在安装 jq for Arch Linux..."  
            if ! pacman -Q | grep -q jq; then  
                pacman -S --noconfirm jq  
            fi  
        else  
            echo "无法确定操作系统类型或jq的安装方式。"  
            exit 1  
        fi  
    else  
        echo "jq已经安装，跳过安装步骤。"  
    fi  
}  
  
# 安装jq  
install_jq  

run_script() {  

# 提示用户输入TARGET_PATH  
echo "请输入你想要搜索的目标路径:"  
read TARGET_PATH  
  
# 检查TARGET_PATH是否为空  
if [ -z "$TARGET_PATH" ]; then  
    echo "路径不能为空，请重新输入。"  
    echo "实例：/var/lib/docker/overlay2/0cb5e1dc62abb14a6382c02180c0cf2f643cda53dcd77c3430b1420593a6e4a6"
    exit 1  
fi  
  
# 获取所有容器的ID  
docker ps -aq | while read -r container_id; do  
    # 使用docker inspect获取容器的详细信息  
    container_info=$(docker inspect "$container_id" --format='{{json .}}')  
      
    # 解析容器的JSON信息以获取名称  
    container_name=$(echo "$container_info" | jq -r '.Name')  
      
    # 提取没有前缀的容器名称  
    if [[ $container_name == /* ]]; then  
        container_name=${container_name#/}  
    fi  
      
    # 使用docker inspect获取容器的存储路径信息  
    container_path=$(docker inspect --format='{{.GraphDriver.Data.WorkDir}}' "$container_id")  
  
    # 检查存储路径是否匹配目标路径  
    if [[ "$container_path" == *"$TARGET_PATH"* ]]; then  
        echo "容器名称: $container_name (ID: $container_id) 的存储路径匹配目标路径 $TARGET_PATH"  
    fi  
done
read -p "按回车继续执行脚本或按Ctrl+C退出: " input  
  
    # 检查用户是否按下了Ctrl+C（即发送了SIGINT信号）  
    if [[ "$input" == "" ]]; then  
        # 用户按下了回车，重新执行脚本  
        exec "$0"  
    fi  
}  
  
# 执行脚本的主要逻辑  
run_script