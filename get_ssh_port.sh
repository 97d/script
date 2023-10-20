#!/bin/bash  
  
# 获取当前SSH配置文件路径  
config_file="/etc/ssh/sshd_config"  
  
# 检查配置文件是否存在  
if [ ! -f "$config_file" ]; then  
    echo "SSH配置文件不存在！"  
    exit 1  
fi  
  
# 读取配置文件并查找SSH端口号  
port_line=$(grep "Port" "$config_file")  
if [ -z "$port_line" ]; then  
    echo "未找到SSH端口号！"  
else  
    # 提取端口号  
    port=$(echo "$port_line" | awk '{print $NF}')  
    echo "当前SSH端口号：$port"  
fi
