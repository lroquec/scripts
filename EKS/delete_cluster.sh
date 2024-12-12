## DELETE NODE GROUP AND CLUSTER
#!/bin/bash
## Define the clusters variables
CLUSTER_NAME="eksdemo1"
NODE_GROUP="ng-$CLUSTER_NAME"
REGION="us-east-1"
KEY_PAIR="eks-keypair"

## Delete the Node Group
eksctl delete nodegroup --cluster="$CLUSTER_NAME" --name="$NODE_GROUP"

## Delete the Cluster
eksctl delete cluster --name="$CLUSTER_NAME"

## Verify the cluster deletion
eksctl get cluster

## Delete the IAM OIDC Provider
eksctl utils disassociate-iam-oidc-provider --region="$REGION" --cluster="$CLUSTER_NAME" --approve

## Delete the EKS Key Pair
aws ec2 delete-key-pair --key-name "$KEY_PAIR"

## IMPORTANT: eksctl works with cloudformation, so it may take a few minutes to delete the resources and you have to make sure that its core components
## are in the same state since creation, which means we have to roll back all the changes we have done to security groups or IAM roles, etc, before 
## deleting the cluster.