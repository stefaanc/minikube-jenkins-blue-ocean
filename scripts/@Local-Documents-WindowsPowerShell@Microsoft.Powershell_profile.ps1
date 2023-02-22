#
# powershell completions
#
kubectl completion powershell | Out-String | Invoke-Expression

#
# bash completions
#
if ($Null -eq (Get-InstalledModule -Name PSBashCompletions -ErrorAction Ignore)) {
    Install-Module -Name PSBashCompletions -Scope CurrentUser -Force
}
Register-BashArgumentCompleter minikube C:\Users\Stefaan\.bash_data\completions\minikube_completions.sh
