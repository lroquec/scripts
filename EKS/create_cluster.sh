#!/bin/bash

## Define the clusters variables
CLUSTER_NAME="eksdemo1"
REGION="us-east-1"
ZONES="us-east-1a,us-east-1b"
KEY_PAIR="eks-keypair"
NODE_TYPE="t4g.medium"
TAGS="env=dev,team=devops,owner=lroque"
NODE_LABELS="env=dev"
DESIRED_CAPACITY="2"
MIN_CAPACITY="1"
MAX_CAPACITY="3"
VOLUME_SIZE="20"

## Execute the eksctl command with the variable
eksctl create cluster --name="$CLUSTER_NAME" \
                      --region="$REGION" \
                      --zones="$ZONES" \
                      --without-nodegroup

## Verify the cluster creation
eksctl get cluster

## Create & Associate IAM OIDC Provider for our EKS Cluster
eksctl utils associate-iam-oidc-provider --region="$REGION" --cluster="$CLUSTER_NAME" --approve

## Create Node Group with additional Add-Ons in Public Subnets
eksctl create nodegroup --cluster="$CLUSTER_NAME" \
                        --region="$REGION" \
                        --name="ng-$CLUSTER_NAME" \
                        --node-type="$NODE_TYPE" \
                        --nodes="$DESIRED_CAPACITY" \
                        --nodes-min="$MIN_CAPACITY" \
                        --nodes-max="$MAX_CAPACITY" \
                        --node-volume-size="$VOLUME_SIZE" \
                        --ssh-access \
                        --ssh-public-key="$KEY_PAIR" \
                        --managed \
                        --asg-access \
                        --external-dns-access \
                        --full-ecr-access \
                        --appmesh-access \
                        --alb-ingress-access \
                        --enable-ssm \
                        --region="$REGION" \
                        --node-labels="$NODE_LABELS" \
                        --tags="$TAGS"

