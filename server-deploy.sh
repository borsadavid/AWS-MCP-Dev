#!/bin/bash
set -e

# Configuration
AWS_ACCOUNT_ID="865091756103"
REGION="eu-north-1"
REPO_NAME="aws-practice"
IMAGE_URI="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest"
ENV_FILE="/home/ec2-user/.env.production"

echo "=== Logging into ECR ==="
aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "=== Pulling latest image ==="
docker pull $IMAGE_URI

echo "=== Stopping old container ==="
docker stop $(docker ps -q) 2>/dev/null || echo "No running containers"

echo "=== Removing old containers ==="
docker rm $(docker ps -aq) 2>/dev/null || echo "No containers to remove"

echo "=== Starting new container ==="
docker run -d -p 3000:3000 \
  --name aws-practice \
  --restart unless-stopped \
  --env-file $ENV_FILE \
  $IMAGE_URI

echo "=== Waiting for startup ==="
sleep 5

echo "=== Checking logs ==="
docker logs aws-practice

echo "=== Deploy complete! ==="