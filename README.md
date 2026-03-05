Built a Rails 7 Spendings tracker to practice AI in apps and modern cloud workflows: MCP (AI → SQL), AWS ECR + EC2, RDS (eu-north-1), **GitHub Actions CD** (auto-deploy on push to `main`), **Elastic IP**, and **Nginx** as a reverse proxy—mirroring real-world production setups. Most learning and guidance was from Claude AI.

---

## Development

I use this to run the app locally.

1. **Copy env and start stack**  
   Copying `.env.example` to `.env` and running `docker compose up -d` will start the stack (edit `GEMINI_API_KEY` in `.env` is needed (free version has enough tokens)).
2. **Useful commands**  
   `docker compose exec web rails c` will open a Rails console; `docker compose run web <one-off-command>` will run a one-off command in the web container.

**References I used:** [ruby-openai](https://github.com/alexrudall/ruby-openai), [Gemini API](https://ai.google.dev/gemini-api/docs/models).

---

## Deployment

I deploy via **ECR** (image store) and **EC2** (run the container). That will require AWS and SSH access.

### One-time setup (per server)

- **Local:** I have AWS CLI configured (`aws configure`), Docker, and an SSH key for EC2.
- **EC2:** I installed Docker and AWS CLI on the instance; I created `~/.env.production` with production secrets (see **Production env** below). Copying `server-deploy.sh` to the server (`/home/ec2-user/`) and running `chmod +x server-deploy.sh` will make it runnable.

I attached an **Elastic IP** to the EC2 instance so the public IP stays fixed; I use that IP for SSH and for the GitHub secret `EC2_HOST` so CD keeps working.

### Continuous deployment (GitHub Actions)

Pushing to `main` will trigger an automatic deploy: the workflow will build the Docker image, push it to ECR, SSH into EC2, and run `./server-deploy.sh` (that will pull the new image and restart the container).

**GitHub secrets I set** (Settings → Secrets and variables → Actions):

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | IAM user with ECR push access. |
| `AWS_SECRET_ACCESS_KEY` | Corresponding secret key. |
| `EC2_HOST` | EC2 public IP. |
| `EC2_SSH_KEY` | The private key (`.pem`) used to SSH as `ec2-user`. |

Workflow file: `.github/workflows/deploy.yml`.

### Manual deploy

1. **On my machine (build and push image)**  
   Running `./deploy.sh` will build the image and push it to ECR.
2. **On the EC2 instance (pull and run)**  
   After SSHing in (`ssh -i /path/to/your-key.pem ec2-user@<EC2_PUBLIC_IP>`), running `./server-deploy.sh` will pull the latest image and restart the app container.
3. **Check logs**  
   `docker logs aws-practice` will show the app logs.

### Nginx on EC2

The app container listens on port 3000. I use Nginx as a reverse proxy so the app is served on port 80.

1. I installed Nginx on the EC2 instance (`sudo yum install nginx`).
2. Copying the project’s config into Nginx and reloading will enable it, e.g.:
   ```bash
   sudo cp nginx_ec2.conf /etc/nginx/conf.d/aws-practice.conf
   sudo nginx -t && sudo systemctl reload nginx
   ```
3. Opening port 80 in the instance security group will make the app reachable at `http://<EC2_PUBLIC_IP>`.
4. For HTTPS, **Certbot** would be used with a domain pointing to the Elastic IP; that would configure Nginx for TLS (I don’t have a domain set up for that).

Config reference: `nginx_ec2.conf`.

