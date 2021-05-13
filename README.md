# power-ddns
一个用于更新dnspod ddns的powershell脚本，支持ipv4和ipv6
主要功能：
自动获取domain id 和 record_id
ipv4使用 record.ddns 接口 ipv6使用 record.modify 接口
ip重复检查，频繁调用修改接口
输入日志

使用：
使用本脚本需要先获取dnspod的密钥中的id和token,然后需要现在你的域名中添加A和AAAA记录。
