# power-ddns

## 2023年1月16日 更新

添加了在linux(Ubuntu22.04)上测试通过的脚本 dnspod-ddns-ipv6-linux.ps1， 该脚本支持配置多个子域名，仅支持ipv6. 在linux上安装powershell 后便可运行。[安装文档](https://learn.microsoft.com/zh-cn/powershell/scripting/install/install-ubuntu?view=powershell-7.2)

部署：  
运行crontab -e, 在其中添加如下的一行内容便可没十分钟运行一次。

*/10 * * * * pwsh /home/leon/ddns_argo_lvhang_wang.ps1

## windows版
一个用于更新dnspod ddns的powershell脚本，支持ipv4和ipv6。  
主要功能：  
1)自动获取domain id 和 record_id  
2)ipv4使用 record.ddns 接口 ipv6使用 record.modify 接口  
3)ip重复检查，避免频繁调用修改接口  
4)输出日志  

使用：  
使用本脚本需要先获取dnspod密钥中的id和token,然后需要在你的域名解析中添加A或AAAA记录，然后将记录名称配置到脚本中。  
配置如下：  
$dnspod_id = "123456" #dnspod 密钥 id  
$dnspod_token = "43965weradfasdfasd1b9cadfasdc6" #dnspod 密钥token  
$dnspod_domain_name = "yourdomain.net" #你的域名  
$dnspod_record_name = "subdomain" #你的记录名，子域名  

该脚本可同时更新ipv4和ipv6  
该脚本只运行一次，所以需要配合如windows中的计划任务来保证持续的更新。  
可参考如下图所示的计划任务配置：  
![1](https://user-images.githubusercontent.com/936437/118104821-36640b00-b40e-11eb-8fd6-1144fdf1fd47.png)  
![2](https://user-images.githubusercontent.com/936437/118104830-395efb80-b40e-11eb-9764-1e56e591e295.png)  
![3](https://user-images.githubusercontent.com/936437/118104835-3b28bf00-b40e-11eb-9465-250546129c2a.png)  
