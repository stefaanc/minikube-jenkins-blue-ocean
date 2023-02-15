# minikube-jenkins-blue-ocean
deploying Jenkins and Blue Ocean on minikube

### Prerequisites
- minikube (tested version 1.29.0 with kubernetes 1.26.1)
- minikube addons
  - ingress
  - ingress-dns          (run the UpdateDNS.ps1 script to redirect the '.minikube' namespace to the ingress DNS)
  - kubernetes-dashboard (optional; you can apply the manifest to test the ingress DNS)
