# power-ddns

一个用于更新dnspod ddns的powershell脚本，支持ipv4和ipv6。  
主要功能：  
1)自动获取domain id 和 record_id  
2)ipv4使用 record.ddns 接口 ipv6使用 record.modify 接口  
3)ip重复检查，频繁调用修改接口  
4)输出日志  

使用：  
使用本脚本需要先获取dnspod密钥中的id和token,然后需要在你的域名解析中添加A或AAAA记录，然后将记录名称配置到脚本中。  
配置如下所示：  


该脚本可同时更新ipv4和ipv6  
该脚本只运行一次，所以需要配合如windows中的计划任务来保证持续的更新。  
可参考如下图所示的计划任务配置：  
