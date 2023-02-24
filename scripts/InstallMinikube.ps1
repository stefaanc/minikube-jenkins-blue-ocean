#####
#
#   the following will not properly run as a script - it needs to wait for completion after some of the steps
#   I copy & execute the following line-by-line into a powershell terminal and verify each step manually
#
#####
Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope Process

$NetAdapter = "Ethernet 2"
Get-NetAdapter -Name $NetAdapter

  ## TODO:
  ## - check that the netadapter exists, is Up and connected to the internet
  ## - make sure you only use wired adapters when planning to mount shared folders

#
# create a new virtual switch
#
# note on switch type:
# - instead of an external switch, you can use an internal switch with internet connection sharing or with a NAT network
#   problem is that this seems to lead to an "Unidentifed" network with a "Public" network profile
#   there are ways to get this to work but there seems to be no way to make this reliably persist after a restart
#
New-VMSwitch -Name "External Switch" -NetAdapterName $NetAdapter

  ## TODO:
  ## - check that the switch doesn't exist already
  ##   - don't delete it if it does, because other VMs may be connected to it
  ##   - instead, check if netadapter is the one we need
  ##   - don't delete it if it isn't
  ##   - instead, needs manual check, so exit script here

#
# start minikube
#
# note on mounting filesystems:
# - after restarting your computer, you loose your mounted filesystems
#   - for shared folders: run "minikube start" to re-mount any previously mounted filesystems 
#
# note on shared folders on windows host:
# - add read/write permission for Everyone on the shared folder
# - set the Network profile to private for the network adapter
# - turn on Network discovery and turn on File and printer sharing for private networks
# - turn on Public folder sharing and turn off Password Protected Sharing for all networks
#
# note on ssh:
# - to be able to use the command history, use
#   - ssh: "ssh -i "~\.ssh\minikube\id_rsa docker@minikube.local"
#   - putty: host "minikube.local", user "docker", password "tcuser" or private key file for authentication converted from "~\.ssh\minikube\id_rsa" to .ppk format using puttygen
#
minikube start --vm-driver hyperv --hyperv-virtual-switch "External Switch" --mount --mount-string "\\$( hostname )\USERS\Stefaan\MinikubeData:/mnt/smbdata"
minikube ssh "sudo mkdir -p /mnt/nfsdata && sudo mount -t nfs -o nfsvers=3,proto=udp $( hostname ):/nfsdata /mnt/nfsdata"
if ( !( Test-Path -path "~\.ssh\minikube" ) ) { New-Item "~\.ssh\minikube" -Type Directory }
Get-ChildItem -Path "~\.minikube\machines\minikube" -Filter "id_rsa*" | Copy-Item -Destination "~\.ssh\minikube"
# test
minikube ssh
ls -la /mnt/hostdata

  ## TODO: 
  ## - have multiple nodes
  ## - load new kubectl when it's version is different from kubernetes
  ## - check/set settings for shared folders

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

  ## TODO: 
  ## - after checking it works OK, delete jobs (& pods) with labels:
  ##   - app.kubernetes.io/component: admission-webhook
  ##     app.kubernetes.io/name: ingress-nginx

#
# enable ingress-dns
#
minikube addons enable ingress-dns
Get-DnsClientNrptRule | Where-Object {$_.Namespace -eq '.minikube'} | Remove-DnsClientNrptRule -Force
Add-DnsClientNrptRule -Namespace ".minikube" -NameServers "$(minikube ip)"
# test
kubectl apply -f $HOME\projects\minikube-jenkins-blue-ocean\manifests\kubernetes-dashboard
Start-Process "http://dashboard.minikube"

  ## TODO: 
  ## - add tls to ingress
