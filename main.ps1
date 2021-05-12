
Set-Location $PSScriptRoot

$dnspod_id = "234851"
$dnspod_token = "f4c3d32c5f5e62ca3e82080f70a5b194"
$dnspod_domain_name = "lvhang.site"
$dnspod_record_name = "home"

$dnspod_idtoken = "$dnspod_id,$dnspod_token"


$log_file_name = "logs_{0}.txt" -f (Get-Date -Format "yyyyMMddHH" )

function AddLog ($log_string) {
    Write-Host $log_string
    Add-Content -Encoding utf8 $log_file_name $log_string
}

function UpdateRecord($record_id,$record_value) {

    AddLog("调用dnspod ddns api, ip地址:$record_value")
    $ddns_resp = curl -X POST https://dnsapi.cn/Record.Ddns -d "login_token=$dnspod_idtoken&format=json&domain_id=$domain_id&record_id=$record_id&sub_domain=$dnspod_record_name&record_line=%E9%BB%98%E8%AE%A4" | ConvertFrom-Json

    #检查结果
    if ($ddns_resp.status.code -eq "1") {

        $latest_dnspod_called_time = Get-Date
        $dns_ip = $current_ip

        Write-Host ("ddns调用返回消息:{0}" -f $ddns_resp.status.message)
        Write-Host ("ddns设置ip地址:{0}" -f $ddns_resp.record.value)

    }
    else {
        throw $ddns_resp.status.message
    }
}


AddLog("开始执行，$(Get-Date)")

#设置domain_id与record_id
$domain_id = ""
$record_A_id = ""
$record_AAAA_id = ""

#获取 domain_id
$domain_resp = curl -X POST https://dnsapi.cn/Domain.List -d "login_token=$dnspod_idtoken&format=json" | ConvertFrom-Json


#检查请求是否成功
if ($domain_resp.status.code -ne "1") {
    AddLog($domain_resp.status.message)
    return 1
}

foreach ($domain in $domain_resp.domains) {

    if ($domain.punycode -eq $dnspod_domain_name) {

        $domain_id = $domain.id

        break

    }

}

if ($domain_id -eq "") {
    AddLog("无法找到你配置的域名 $dnspod_domain_name 对应的domain_id,请检查你的配置")
    return 1
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
    return 1
}



#显示获取的domain_id和record_id
AddLog("获取domain_id:$domain_id")
AddLog("获取record_id:$record_id")

#获取本机ipv4与ipv6地址
$host_ipv4 = ""
$host_ipv6 = ""

    #获取本机的公网v4 ip地址
    $current_v4_ip = Invoke-RestMethod https://lvhang.site/apps/mirror/ip | Select-Object -ExpandProperty ip
    #$current_ip = Invoke-RestMethod http://ipinfo.io/json | Select-Object -ExpandProperty ip
    #检查地址是否改变


#若获取到了record_A_id，开始处理ipv4记录
if ($record_A_id -ne "") {

    #获取当前A记录的ip
    $current_dns_info = curl -X POST https://dnsapi.cn/Record.Info -d "login_token=$dnspod_idtoken&format=json&domain_id=$domain_id&record_id=$record_id" | ConvertFrom-Json
    $dns_A_ip = $current_dns_info.record.value
    AddLog("当前dnspod中 $dnspod_record_name A记录的IP为: $dns_A_ip")


    if ($dns_A_ip -ne $current_v4_ip) {


    }
    else {

        Write-Host "当前ip:$current_ip"
        Write-Host "之前ip:$dns_ip"
        Write-Host "上次ddns调用时间:$latest_dnspod_called_time"
        Write-Host ("当前时间:{0}" -f $(Get-Date))
    
    }

}



#若获取到了record_AAAA_id，开始处理ipv6记录
if ($record_AAAA_id -ne "") {
    # http://v4.ipv6-test.com/api/myip.php
    # http://v6.ipv6-test.com/api/myip.php
    # http://v4v6.ipv6-test.com/api/myip.php
    # http://v4.ipv6-test.com/api/myip.php?json
}