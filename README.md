A Rails 7 Spendings tracker featuring Turbo, designed to practice end-to-end modern cloud workflows: MCP (AI → SQL), AWS ECR for image storage, and EC2 for app hosting. Includes a real cloud database (RDS eu-north-1), elastic ip, deployment scripts, and production access via Amazon IAM policies—mirroring real-world production setups.

---

## Development

Use this to run the app locally.

1. **Copy env and start stack**
   ```bash
   cp .env.example .env
   # Edit GEMINI_API_KEY needed
   docker compose up -d
   ```
2. **Useful commands**
   ```bash
   docker compose exec web rails c
   docker compose run web <one-off-command>
   ```

**References:** [ruby-openai](https://github.com/alexrudall/ruby-openai), [Gemini API](https://ai.google.dev/gemini-api/docs/models).

---

## Deployment

Deploy runs via **ECR** (image store) and **EC2** (run the container). AWS and SSH access required.

### One-time setup (per deployer / per server)

- **Local:** AWS CLI configured (`aws configure`), Docker, and SSH key for EC2.
- **EC2:** Install Docker and AWS CLI; create `~/.env.production` with production secrets (see **Production env** below). Copy `server-deploy.sh` to the server (e.g. `/home/ec2-user/`) and `chmod +x server-deploy.sh`.

### Deploy flow

1. **On your machine (build and push image)**
   ```bash
   ./deploy.sh
   ```

2. **On the EC2 instance (pull and run)**
   ```bash
   ssh -i /path/to/your-key.pem ec2-user@<EC2_PUBLIC_IP>
   ./server-deploy.sh
   ```

3. **Check logs**
   ```bash
   docker logs aws-practice
   ```

### Production env (on EC2)

Create `/home/ec2-user/.env.production` (or set `ENV_FILE` when running `server-deploy.sh`) with at least:

- `RAILS_ENV=production`
- `SECRET_KEY_BASE` (e.g. `openssl rand -hex 64`)
- `DATABASE_HOST`, `DATABASE_USER`, `DATABASE_PASSWORD`, `DATABASE_NAME` (from RDS/Postgres in eu-north-1)
- `GEMINI_API_KEY`, `GEMINI_ENDPOINT` required

---

## Project layout (Docker / deploy)

| File | Purpose |
|------|--------|
| `Dockerfile` | Production image (Rails, assets, entrypoint). |
| `docker-compose.yml` | Local dev: app + Postgres + Redis. |
| `.env.example` | Template for local `.env`; do not commit `.env` or `.env.production`. |
| `deploy.sh` | Run locally: build image, push to ECR. |
| `server-deploy.sh` | Run on EC2: ECR login, pull, stop/start app container with `--env-file`. |
| `.dockerignore` | Keeps secrets and junk out of the image build context. |
