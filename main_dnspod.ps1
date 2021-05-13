
Set-Location $PSScriptRoot

$dnspod_id = "123456"
$dnspod_token = "439655flksfjgdaffapoefjcf167c6"
$dnspod_domain_name = "xxxxx.cn"
$dnspod_record_name = "subdomain"

$dnspod_idtoken = "$dnspod_id,$dnspod_token"

$log_file_name = "logs_{0}.txt" -f (Get-Date -Format "yyyyMMddHH" )

function AddLog ($log_string) {
    Write-Host $log_string
    Add-Content -Encoding utf8 $log_file_name $log_string
}

function End($isSuccess) {
    if ($isSuccess) {
        AddLog("脚本执行完成")
    }
    else {
        AddLog("脚本执行结束，发生错误")
    }
    exit
}

function UpdateRecordDnns($rid) {
    AddLog("调用dnspod ddns api")

    $ddns_resp = curl -X POST https://dnsapi.cn/Record.Ddns -d "login_token=$dnspod_idtoken&format=json&domain_id=$domain_id&record_id=$rid&sub_domain=$dnspod_record_name&record_line=%E9%BB%98%E8%AE%A4" | ConvertFrom-Json

    #检查结果
    if ($ddns_resp.status.code -eq "1") {
        AddLog("ddns调用返回消息:{0}" -f $ddns_resp.status.message)
        AddLog("ddns设置ip地址:{0}" -f $ddns_resp.record.value)
    }
    else {
        AddLog($ddns_resp.status.code)
        AddLog($ddns_resp.status.message)
        End($false)
    }
}

AddLog("===================开始执行，$(Get-Date)===================")

#设置domain_id与record_id
$domain_id = ""
$record_A_id = ""
$record_AAAA_id = ""

#获取 domain_id
$domain_resp = curl -X POST https://dnsapi.cn/Domain.List -d "login_token=$dnspod_idtoken&format=json" | ConvertFrom-Json

#检查请求是否成功
if ($domain_resp.status.code -ne "1") {
    AddLog($domain_resp.status.message)
    End($false)
}

#获取domain_id
foreach ($domain in $domain_resp.domains) {
    if ($domain.punycode -eq $dnspod_domain_name) {
        $domain_id = $domain.id
        break
    }
}

if ($domain_id -eq "") {
    AddLog("无法找到你配置的域名 $dnspod_domain_name 对应的domain_id,请检查你的配置")
    End($false)
}


#获取 record_id
$record_resp = curl -X POST https://dnsapi.cn/Record.List -d "login_token=$dnspod_idtoken&format=json&domain_id=$domain_id" | ConvertFrom-Json

foreach ($record in $record_resp.records) {
    if ($record.name -eq $dnspod_record_name) {
        if ($record.type -eq "A") {
            $record_A_id = $record.id
        }
        if ($record.type -eq "AAAA") {
            $record_AAAA_id = $record.id
        }
    }
}


if ($record_id -eq "") {
    AddLog("无法找到你配置的记录名 $dnspod_record_name 对应的record_id,请检查你的配置")
    End($false)
}


#显示获取的domain_id和record_id
AddLog("domain_id:$domain_id")
AddLog("A记录：record_id:$record_A_id")
AddLog("AAAA记录：record_id:$record_AAAA_id")


#若获取到了record_A_id，开始处理ipv4记录
if ($record_A_id -ne "") {

    #获取本机的公网v4 ip地址
    $host_ipv4 = Invoke-RestMethod http://v4.ipv6-test.com/api/myip.php?json | Select-Object -ExpandProperty address
    #获取当前A记录的ip
    $current_dns_info = curl -X POST https://dnsapi.cn/Record.Info -d "login_token=$dnspod_idtoken&format=json&domain_id=$domain_id&record_id=$record_A_id" | ConvertFrom-Json
    $dns_A_ip = $current_dns_info.record.value
    AddLog("当前dnspod中 $dnspod_record_name A记录的IP为: $dns_A_ip")

    if ($dns_A_ip -ne $host_ipv4) {
        UpdateRecordDnns($record_A_id)
    }
    else {
        AddLog("当前主机ip与dns ip相同:$dns_A_ip,无需更新")
        AddLog("当前时间:{0}" -f $(Get-Date))
    }

}


#若获取到了record_AAAA_id，开始处理ipv6记录
if ($record_AAAA_id -ne "") {

    #获取本机的公网v6 ip地址
    $host_ipv6 = Invoke-RestMethod http://v6.ipv6-test.com/api/myip.php?json | Select-Object -ExpandProperty address
    #获取当前AAAA记录的ip
    $current_dns_info = curl -X POST https://dnsapi.cn/Record.Info -d "login_token=$dnspod_idtoken&format=json&domain_id=$domain_id&record_id=$record_AAAA_id" | ConvertFrom-Json
    $dns_AAAA_ip = $current_dns_info.record.value
    AddLog("当前dnspod中 $dnspod_record_name AAAA记录的IP为: $dns_AAAA_ip")

    
    if ($dns_AAAA_ip -ne $host_ipv6) {
        AddLog("调用dnspod modify api")

        $ddns_resp = curl -X POST https://dnsapi.cn/Record.Modify -d "login_token=$dnspod_idtoken&format=json&domain_id=$domain_id&record_id=$record_AAAA_id&sub_domain=$dnspod_record_name&value=$host_ipv6&record_type=AAAA&record_line=%E9%BB%98%E8%AE%A4" | ConvertFrom-Json

        #检查结果
        if ($ddns_resp.status.code -eq "1") {
            AddLog("modify调用返回消息:{0}" -f $ddns_resp.status.message)
            AddLog("modify设置ip地址:{0}" -f $ddns_resp.record.value)
        }
        else {
            AddLog($ddns_resp.status.code)
            AddLog($ddns_resp.status.message)
            End($false)
        }
    }
    else {
        AddLog("当前主机ipv6与dnsip相同:$dns_AAAA_ip,无需更新")
        AddLog("当前时间:{0}" -f $(Get-Date))
    }

}


End($true)