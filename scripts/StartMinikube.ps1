#
# Start minikube
#
Get-NetAdapter
New-VMSwitch -Name "External Switch" -NetAdapterName "Ethernet"

#minikube start --vm-driver hyperv --hyperv-virtual-switch "External Switch"
#minikube mount "${HOME}:/host"
### or
minikube start --vm-driver hyperv --hyperv-virtual-switch "External Switch" --mount --mount-string "${HOME}:/host"

minikube ssh

#
# enable dashboard
#
minikube addons enable metrics-server
minikube addons enable dashboard
minikube dashboard

#
# enable ingress
#
minikube addons enable ingress

#
# enable ingress-dns
#
minikube addons enable ingress-dns
Get-DnsClientNrptRule | Where-Object {$_.Namespace -eq '.minikube'} | Remove-DnsClientNrptRule -Force
Add-DnsClientNrptRule -Namespace ".minikube" -NameServers "$(minikube ip)"

# test with dashboard
kubectl apply -f $HOME\projects\minikube-jenkins-blue-ocean\manifests\kubernetes-dashboard
