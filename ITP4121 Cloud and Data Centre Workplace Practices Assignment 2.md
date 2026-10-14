# ITP4121 Cloud and Data Centre Workplace Practices

# Deploy and manage Multi Cloud Kubernetes with Terraform

**This document may add more details and please check it weekly\!** 

# Background

You have to form a group of 3-4 students and create multiple public cloud infrastructure and Kubernetes deployment with Terraform or CDK-TF. 

## Online Group Application 

[https://docs.google.com/forms/d/e/1FAIpQLSc3s1OfgtBJUHJMYAUN2VOY9SXnzfxtc9gk9c-Id6Ottlizvw/viewform?usp=sf\_link](https://docs.google.com/forms/d/e/1FAIpQLSc3s1OfgtBJUHJMYAUN2VOY9SXnzfxtc9gk9c-Id6Ottlizvw/viewform?usp=sf_link)   
Prepare for your GitHub project before registration  
**Submit it on or before 21 Feb 2025**

# Preparation

Create a GitHub repo and add kitson-marking as a member.

Learn the basic:  
Azure  
[https://www.youtube.com/playlist?list=PLtgJR0xD2TPe6fFcVhFLcg-0T\_8JJmD\_n](https://www.youtube.com/playlist?list=PLtgJR0xD2TPe6fFcVhFLcg-0T_8JJmD_n)  
[https://www.youtube.com/playlist?list=PLtgJR0xD2TPeSoK97Gf-dUvcz5kbD6yne](https://www.youtube.com/playlist?list=PLtgJR0xD2TPeSoK97Gf-dUvcz5kbD6yne)  
GCP  
[https://www.youtube.com/playlist?list=PLtgJR0xD2TPcKZtXqk1xpbSVN3Ze6ast-](https://www.youtube.com/playlist?list=PLtgJR0xD2TPcKZtXqk1xpbSVN3Ze6ast-)

# Deadline

(Demo druing lab class in the week of 16 April 2025\)  
You have to submit your final source code to moodle by 25 April 2025 

# Requirements

1. Deploy to AWS, Azure and GCP (at least 2 cloud providers\!). Don’t use AWS if you worry about the charge or use AWS Academy Learn lab but you must hit a permission problem. For Azure and GCP, you can use the trial account and it is fine as you do everything with code and you can move to a new free account easily\!  
2. Kubernetes must deploy inside a VPC and 2 VM run in 2 private subnets.  
3. Include Cluster AutoScaler and demo it can add VM according to loading.  
4. Deploy and connect application to Progress Database with stateful set.  
5. Make use of Kubernetes secret to save confidential information such as Database Password.  
6. Using cloud native load balancer by means of ingress.  
7. Include SSL/TLS.  
8. Send Application log data to cloud logging services such as AWS CloudWatch Log, Azure Insight, and GCP Stackdriver.  
9. Make use of DNS, CDN or any other global construct to create high availability infrastructure with 2 or 3 public cloud providers.

## Kubernetes Applications

1. Most of you should form the same team as your final year project and in this case, you have to deploy your FYP project as the K8s application **if it contains a database**.  
2. For other cases, please discuss with the lecturer and propose other applications which are not able to find the simple YAML or Terraform from the internet.

If you found that is too hard to take above 2 options for whatever reason, then you can deploy the sample application  
[https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/](https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/)   
Translate it to Terraform and deploy it, but the mark will be deduced.

# Marking

Basic for passing mark  
Fix the AKS workshop.  
[https://docs.microsoft.com/en-us/learn/modules/aks-workshop/](https://docs.microsoft.com/en-us/learn/modules/aks-workshop/) 

Demo 

1. Deploy the whole infrastructure with code and complete the multiple cloud deployment within 15 minutes.  
2. Question & Answer

GitHub  
All Team members should contribute code and mark will be based on individual contribution.

## Marking Rubric 

Group Mark: 80

| Task | Max Mark | Mark |
| :---- | :---- | :---- |
| Setup GitHub Project and shared to lecturer | 5 |  |
| Using multiple Cloud Providers (only 1 ZERO mark) | 15 |  |
| Multiple VMs in VPC and 2 private subnets | 5 |  |
| Unique Kubernetes Application with database | 5 |  |
| Cluster AutoScaler | 5 |  |
| Connect to Database  | 5 |  |
| Using Kubernetes Secret properly | 5 |  |
| Using Cloud native load balancer | 5 |  |
| With SSL/TLS | 5 |  |
| Stream application log data to cloud logging services | 5 |  |
| Multiple Cloud High Availability | 5 |  |
| Demo deployment during Lab | 15 |  |

Individual Mark: 20

| Task | Max Mark | Mark |
| :---- | :---- | :---- |
| Present and report for Code Contribution | 15 |  |
| Question & Answer | 5 |  |

## Work Division:

For 3 member teams,   
Member 1: Terraform for 1st cloud providers   
Member 2: Terraform for 2nd cloud providers   
Member 3: Terraform for Kubernetes 

For 4 member teams,   
Member 1: Terraform for 1st cloud providers   
Member 2: Terraform for 2nd cloud providers   
Member 3: Terraform for 3nd cloud providers   
Member 4: Terraform for Kubernetes 

## Hints:

Deploy and manage Infrastructure as Code with Terraform Assignment Hints  
[https://youtu.be/tFArOivZFuc](https://youtu.be/tFArOivZFuc)

1. You need to have a development platform to install the following tools:  
   1. AWS \- Create access key pair with Admin permission, and setup AWS CLI.  
      [https://aws-quickstart.github.io/workshop-terraform-modules/40\_setup\_cloud9\_ide.html](https://aws-quickstart.github.io/workshop-terraform-modules/40_setup_cloud9_ide.html)   
   2. Azure \- Install and login Azure CLI, and Services Principal  
      [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)   
      [https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest\#az-ad-sp-create-for-rbac](https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create-for-rbac)   
   3. GCP \- Install and login Google Cloud CLI.  
      [https://cloud.google.com/sdk/docs/install-sdk\#linux](https://cloud.google.com/sdk/docs/install-sdk#linux)   
   4. Install Terraform CLI  
      [https://learn.hashicorp.com/tutorials/terraform/install-cli](https://learn.hashicorp.com/tutorials/terraform/install-cli)  
2. Reference \- Deploy Federated Multi-Cloud Kubernetes Clusters  
   [https://learn.hashicorp.com/tutorials/terraform/multicloud-kubernetes](https://learn.hashicorp.com/tutorials/terraform/multicloud-kubernetes)  
   Create a Fork in your team GitHub.  
   1. It will not work and it will need you to call “terraform init **\-upgrade**”, then you will hit some errors, because the API is changed. Google the error modules and you have to update the code.  
      [https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/17.10.0](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/17.10.0)   
   2. You have to upgrade all providers to the latest version.  
      [https://registry.terraform.io/providers/hashicorp/aws/latest/docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)  
3. Add a folder gcp and follow the eks and aks structure for GCP.  
   [https://registry.terraform.io/providers/hashicorp/google/latest/docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs)   
   1. Reference \- Provision a GKE Cluster (Google Cloud)  
      [https://learn.hashicorp.com/tutorials/terraform/gke](https://learn.hashicorp.com/tutorials/terraform/gke)   
   2. When you try to deploy GCP, you will hit the error to enable some APIs.  
      You need to use  
      [https://stackoverflow.com/questions/59055395/can-i-automatically-enable-apis-when-using-gcp-cloud-with-terraform](https://stackoverflow.com/questions/59055395/can-i-automatically-enable-apis-when-using-gcp-cloud-with-terraform)   
      [https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google\_project\_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service)   
      1. compute.googleapis.com  
      2. container.googleapis.com  
   3. The sample code uses GCP project name, as the prefix of some resource names. You have to change it to something else.  
4. Rename folder aks to azure, eks to aws. Add main.tf to run all cloud modules. And, the folder structure should look like::  
   ![][image1]  
5. You have to use the Hong Kong Region for all 3 cloud providers.

Load Balancer:   
[https://blog.searce.com/3-ways-to-load-balance-multi-cloud-workloads-from-google-cloud-27195285faaf](https://blog.searce.com/3-ways-to-load-balance-multi-cloud-workloads-from-google-cloud-27195285faaf)  
[https://ikala.cloud/gcp-aws-load-balancing-comparison/](https://ikala.cloud/gcp-aws-load-balancing-comparison/)

[image1]: <data:image/png;base64,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>