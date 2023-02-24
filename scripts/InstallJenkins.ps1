#####
#
#   the following will not properly run as a script - it needs to wait for completion after some of the steps
#   I copy & execute the following line-by-line into a powershell terminal and verify each step manually
#
#####
#
# enable jenkins
#
kubectl apply -f $HOME\projects\minikube-jenkins-blue-ocean\manifests\devops
# get the initial admin pwd on clipboard, to paste on first access of jenkins
$pod =  (kubectl get pods -n devops | Select-String -Pattern "jenkins-[a-z0-9-]*" -AllMatches).Matches.Value
kubectl exec $pod --namespace=devops -- cat /var/jenkins_home/secrets/initialAdminPassword | Set-Clipboard
# initialize jenkins
Start-Process "http://jenkins.minikube"
