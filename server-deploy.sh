#YOU MUST CREATE THIS ON EC2 INSTANCE, NOT USEFUL ON LOCAL MACHINE
#MAKE SURE .env.production exists on the server.

#!/bin/bash
set -e

# Configuration
AWS_ACCOUNT_ID="865091756103"
REGION="eu-north-1"
REPO_NAME="aws-practice"
IMAGE_URI="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest"
CONTAINER_NAME="aws-practice"
ENV_FILE="/home/ec2-user/.env.production"

#Quit if no env.production file
if [[ ! -f "$ENV_FILE" ]] || [[ ! -r "$ENV_FILE" ]]; then
  echo "ERROR: Production env file missing or not readable: $ENV_FILE" >&2
  echo "Create it on this EC2 instance with DATABASE_*, SECRET_KEY_BASE, etc. (see .env.example for names)." >&2
  exit 1
fi

echo "=== Logging into ECR ==="
aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "=== Pulling latest image ==="
docker pull $IMAGE_URI

echo "=== Stopping and removing old container ==="
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

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