# LocalBoost Backend VPS Deployment (No Docker)

This guide deploys Django + DRF + PostgreSQL on a Linux VPS using Gunicorn + Nginx + systemd.

## 1) Target Folder Structure

Use this exact structure on the server:

```text
/srv/localboost/
  backend/                       # this repository's backend folder
  .venv/                         # python virtual environment

/etc/localboost/
  localboost-backend.env         # production environment variables

/var/log/
  journalctl logs for systemd services
```

## 2) DNS And Server Preparation

1. Create an A record: `api.localboost.com -> <VPS_PUBLIC_IP>`.
2. SSH into VPS as sudo user.
3. Copy deployment templates from this repository:
   - `deploy/systemd/localboost-backend.service`
   - `deploy/nginx/localboost-backend.conf`
   - `deploy/env/localboost-backend.env.example`
   - `deploy/scripts/bootstrap_vps.sh`
   - `deploy/scripts/deploy_backend.sh`

## 3) Install Base Packages

Run as root:

```bash
cd /path/to/localboost/backend
bash deploy/scripts/bootstrap_vps.sh
```

This installs:
- PostgreSQL
- Python, pip, venv
- Nginx
- Certbot
- UFW and fail2ban

## 4) PostgreSQL Setup

Run as root:

```bash
sudo -u postgres psql
```

In psql:

```sql
CREATE DATABASE localboost;
CREATE USER localboost WITH ENCRYPTED PASSWORD 'CHANGE_ME_STRONG_PASSWORD';
ALTER ROLE localboost SET client_encoding TO 'utf8';
ALTER ROLE localboost SET default_transaction_isolation TO 'read committed';
ALTER ROLE localboost SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE localboost TO localboost;
\q
```

## 5) App Code And Virtual Environment

Run as root:

```bash
mkdir -p /srv/localboost
chown -R localboost:localboost /srv/localboost
```

Clone code as `localboost` user:

```bash
sudo -u localboost -H bash -lc '
  cd /srv/localboost
  git clone <YOUR_REPO_URL> .
'
```

## 6) Production Environment Variables

Create env file:

```bash
sudo cp /srv/localboost/backend/deploy/env/localboost-backend.env.example /etc/localboost/localboost-backend.env
sudo nano /etc/localboost/localboost-backend.env
```

Set at minimum:
- `DJANGO_SECRET_KEY`
- `DJANGO_ALLOWED_HOSTS`
- `DJANGO_CSRF_TRUSTED_ORIGINS`
- `DJANGO_CORS_ALLOWED_ORIGINS`
- `POSTGRES_PASSWORD`
- `DJANGO_SETTINGS_MODULE=config.settings.production`

Secure permissions:

```bash
sudo chown root:root /etc/localboost/localboost-backend.env
sudo chmod 600 /etc/localboost/localboost-backend.env
```

## 7) Systemd (Gunicorn)

Install service file:

```bash
sudo cp /srv/localboost/backend/deploy/systemd/localboost-backend.service /etc/systemd/system/localboost-backend.service
sudo systemctl daemon-reload
```

## 8) Nginx Setup

Install site config:

```bash
sudo cp /srv/localboost/backend/deploy/nginx/localboost-backend.conf /etc/nginx/sites-available/localboost-backend
sudo ln -sf /etc/nginx/sites-available/localboost-backend /etc/nginx/sites-enabled/localboost-backend
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

Ensure `server_name` in config matches your domain.

## 9) First Deployment

Run:

```bash
cd /srv/localboost/backend
sudo bash deploy/scripts/deploy_backend.sh
```

This does:
- create/update virtualenv
- install requirements
- `migrate`
- `collectstatic`
- `check --deploy`
- restart gunicorn service
- reload nginx

## 10) HTTPS With Let's Encrypt

After HTTP works:

```bash
sudo certbot --nginx -d api.localboost.com
```

Verify renewal timer:

```bash
systemctl list-timers | grep certbot
```

Test dry-run renewal:

```bash
sudo certbot renew --dry-run
```

## 11) Static And Media Serving

Nginx serves:
- `/static/` from `/srv/localboost/backend/staticfiles/`
- `/media/` from `/srv/localboost/backend/media/`

`collectstatic` is executed by deploy script.

## 12) Firewall And Security Basics

Already applied by bootstrap script:
- UFW enabled
- `OpenSSH` allowed
- `Nginx Full` allowed

Recommended additional hardening:
1. Disable password SSH login and use keys only (`/etc/ssh/sshd_config`).
2. Keep system updated: `apt update && apt -y upgrade`.
3. Keep secrets only in `/etc/localboost/localboost-backend.env`.
4. Review logs regularly:
   - `journalctl -u localboost-backend -f`
   - `sudo tail -f /var/log/nginx/error.log`

## 13) Update Workflow (Post-Launch)

For each release:

```bash
sudo -u localboost -H bash -lc '
  cd /srv/localboost
  git pull
'
sudo bash /srv/localboost/backend/deploy/scripts/deploy_backend.sh
```

## 14) Rollback Quick Path

If deploy fails after update:

1. `cd /srv/localboost && git log --oneline`
2. `git checkout <last-known-good-commit>`
3. `sudo bash /srv/localboost/backend/deploy/scripts/deploy_backend.sh`

