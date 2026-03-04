#!/bin/bash
set -e

# Configuration
AWS_ACCOUNT_ID="865091756103"
REGION="eu-north-1"
REPO_NAME="aws-practice"
IMAGE_URI="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME"

echo "=== Building Docker image ==="
docker build -t $REPO_NAME .

echo "=== Logging into ECR ==="
aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "=== Tagging image ==="
docker tag $REPO_NAME:latest $IMAGE_URI:latest

echo "=== Pushing to ECR ==="
docker push $IMAGE_URI:latest

echo "=== Done! Now SSH into EC2 and run: ./server-deploy.sh ==="