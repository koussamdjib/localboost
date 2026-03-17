# LocalBoost Backend

## Local development

1. Create `.env` from `.env.example`.
2. Install deps: `pip install -r requirements.txt`.
3. Run migrations: `python manage.py migrate`.
4. Start API: `python manage.py runserver`.

Local settings module is `config.settings.local`.

## Production deployment (Linux VPS)

Use:
- `DEPLOYMENT_VPS.md` for exact server setup and deployment steps.
- `.env.production.example` as production env reference.
- `deploy/systemd/localboost-backend.service` for Gunicorn service.
- `deploy/nginx/localboost-backend.conf` for Nginx reverse proxy.
- `deploy/scripts/bootstrap_vps.sh` and `deploy/scripts/deploy_backend.sh` for setup and updates.

Production settings module is `config.settings.production`.
