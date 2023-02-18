#
# the following will most probably not properly run as a script - it needs to wait for completion after some steps
# I copy & execute the following line-by-line into a powershell teminal and verify each step manually
#

#
# start minikube
#
Get-NetAdapter
New-VMSwitch -Name "Minikube Switch" -NetAdapterName "Ethernet"
minikube start --vm-driver hyperv --hyperv-virtual-switch "Minikube Switch" --mount --mount-string "${HOME}:/mnt/host"
# test
minikube ssh
ls -la /mnt/host

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

# TODO: after checking it works OK, delete jobs (& pods) with labels:
# - app.kubernetes.io/component: admission-webhook
#   app.kubernetes.io/name: ingress-nginx

#
# enable ingress-dns
#
minikube addons enable ingress-dns
Get-DnsClientNrptRule | Where-Object {$_.Namespace -eq '.minikube'} | Remove-DnsClientNrptRule -Force
Add-DnsClientNrptRule -Namespace ".minikube" -NameServers "$(minikube ip)"
# test
kubectl apply -f $HOME\projects\minikube-jenkins-blue-ocean\manifests\kubernetes-dashboard
Start-Process "http://dashboard.minikube"

# TODO: add tls to ingress
