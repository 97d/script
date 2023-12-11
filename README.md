在哪吒探针里快速查看ssh的端口号
```
curl -L https://raw.githubusercontent.com/97d/script/main/get_ssh_port.sh -o get_ssh_port.sh && chmod +x get_ssh_port.sh && sudo ./get_ssh_port.sh
```
Linux VPS一键添加/删除Swap虚拟内存

说明：很多人的VPS服务器由于内存太小，会导致很多进程被杀掉，这个时候就需要我们添加Swap虚拟内存了，这里就整了个一键脚本方便人或小白使用。

脚本提示：脚本不支持OpenVZ架构，安装会自动退出。

运行命令：
```
wget https://raw.githubusercontent.com/97d/script/main/swap.sh && bash swap.sh
```
然后根据选项进行操作，记得添加swap的时候填写纯数字，默认单位为M。
