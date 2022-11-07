# eks_controlplane

This module creates an eks controlplane cluster. It also creates security groups for workers nodes

### Setting up AWS EKS ControlPlane:-

1. Download kubectl
2. Download aws-iam-authenticator/heptio-authenticator-aws
3. Update below parameters in terraform.tfvars file
     a. name_prefix,businessunit,vpc_id,public_subnets,worker_subnets
4. Verify IAM Roles "eks_mgmtplane_master" and "eks_mgmtplane_worker" are created.
5. terraform init
6. terraform apply
7. terraform output kubeconfig # save output in ~/.kube/config
8. kubectl get nodes
     a. output : "No resource found"
