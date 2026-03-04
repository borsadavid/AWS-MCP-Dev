docker-compose exec web rails c #or something else to stay in terminal
docker-compose run web something #for one run

Build using docs:
https://github.com/alexrudall/ruby-openai
https://ai.google.dev/gemini-api/docs/models


Simple Rails 7 Spendings app using Turbo, with the purpose of practicing MCP implementation (using AI to convert text into sql) and AWS services.

DB is on eu-north-1

# to run the project on development instead of production (without aws db connection, delete commented line in docker-compose)

# TODO NEXT
# Containerization & Deployment via Amazon ECR and EC2.

# Connect to EC2 instance:
ssh -i ~/.ssh/aws-practice-key.pem ec2-user@56.228.17.136 

REBUILD AND REDEPLOY:
# On your local machine
docker build -t aws_practice .
docker tag aws_practice:latest 865091756103.dkr.ecr.eu-north-1.amazonaws.com/aws-practice:latest
docker push 865091756103.dkr.ecr.eu-north-1.amazonaws.com/aws-practice:latest

# Connect to EC2
ssh -i ~/.ssh/aws-practice-key.pem ec2-user@56.228.17.136 

ON EC2:
docker stop CONTAINER_ID
docker pull 865091756103.dkr.ecr.eu-north-1.amazonaws.com/aws-practice:latest


docker logs CONTAINER_ID

# TODO NEXT, FIX ALL ENVs, none are viisble and i have to run eveything with env passed on run, they should be set up on aws