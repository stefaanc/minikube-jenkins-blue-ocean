#
# the following will most probably not properly run as a script - it needs to wait for completion after some steps
# I copy & execute the following line-by-line into a powershell teminal and verify each step manually
#

#
# start minikube
#
Get-NetAdapter
New-VMSwitch -Name "External Switch" -NetAdapterName "Ethernet"
minikube start --vm-driver hyperv --hyperv-virtual-switch "External Switch" --mount --mount-string "${HOME}:/host"
# test
minikube ssh

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
kubectl apply -f $HOME\projects\minikube-jenkins-blue-ocean\manifests\kubernetes-dashboard

#
# enable ingress-dns
#
minikube addons enable ingress-dns
Get-DnsClientNrptRule | Where-Object {$_.Namespace -eq '.minikube'} | Remove-DnsClientNrptRule -Force
Add-DnsClientNrptRule -Namespace ".minikube" -NameServers "$(minikube ip)"
# test
Start-Process "http://dashboard.minikube"
