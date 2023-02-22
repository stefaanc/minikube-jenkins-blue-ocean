#
# the following will most probably not properly run as a script - it needs to wait for completion after some of the steps
# I copy & execute the following line-by-line into a powershell terminal and verify each step manually
#
Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope Process

$NetAdapter = "Ethernet 2"
Get-NetAdapter -Name $NetAdapter

  # TODO:
  # - check NetAdapter is Up and has access to internet

#
# create a new virtual switch
#
New-VMSwitch -Name "Minikube Switch" -SwitchType Internal
if ($Null -eq (Get-InstalledModule -Name PSInternetConnectionSharing -ErrorAction Ignore)) {
  Install-Module -Name PSInternetConnectionSharing -Scope CurrentUser -Force
}
Disable-Ics
Set-Ics -PublicConnectionName $NetAdapter -PrivateConnectionName "vEthernet (Minikube Switch)"
Set-NetConnectionProfile -InterfaceAlias "vEthernet (Minikube Switch)" -NetworkCategory Private

#
# start minikube
#
# note on shared folders:
# - add read/write permission for Everyone on the shared folder
# - turn on File and Printer Sharing for private networks
# - turn off Password Protected Sharing for all networks
#
# note on ssh:
# - to be able to use the command history, use
#   - ssh: "ssh -i "~\.ssh\minikube\id_rsa docker@$( minikube ip )"
#   - putty: host "minikube", user "docker", password "tcuser" or private key converted from "~\.ssh\minikube\id_rsa" to .ppk format using puttygen
#
minikube start --vm-driver hyperv --hyperv-virtual-switch "Minikube Switch" --mount --mount-string "\\$( hostname )\USERS\Stefaan\MinikubeData:/mnt/hostdata"
if ( !( Test-Path -path "~\.ssh\minikube" ) ) { New-Item "~\.ssh\minikube" -Type Directory }
Get-ChildItem -Path "~\.minikube\machines\minikube" -Filter "id_rsa*" | Copy-Item -Destination "~\.ssh\minikube"
# test
minikube ssh
ls -la /mnt/hostdata

  # TODO: 
  # - have multiple nodes
  # - load new kubectl when it's version is different from kubernetes
  # - Disable-Ics doesn't disble it when virtual switch was deleted

#
# enable dashboard
#
minikube addons enable metrics-server
minikube addons enable dashboard
# test
minikube dashboard

#
# enable ingress
#
minikube addons enable ingress

  # TODO: 
  # - after checking it works OK, delete jobs (& pods) with labels:
  #   - app.kubernetes.io/component: admission-webhook
  #     app.kubernetes.io/name: ingress-nginx

#
# enable ingress-dns
#
minikube addons enable ingress-dns
Get-DnsClientNrptRule | Where-Object {$_.Namespace -eq '.minikube'} | Remove-DnsClientNrptRule -Force
Add-DnsClientNrptRule -Namespace ".minikube" -NameServers "$(minikube ip)"
# test
kubectl apply -f $HOME\projects\minikube-jenkins-blue-ocean\manifests\kubernetes-dashboard
Start-Process "http://dashboard.minikube"

  # TODO: 
  # - add tls to ingress
