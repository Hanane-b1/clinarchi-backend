# 🏥 ClinArchi — Backend API

REST API for **ClinArchi**, an AI-assisted spatial programming platform for hospitals and clinics.
It stores generated projects and securely proxies AI report generation to the Claude API, so the API key never reaches the browser.

> Built during my Full Stack Developer internship at **Groupe Vitalys Santé** (March – April 2026).
> Frontend: [clinarchi-frontend](https://github.com/Hanane-b1/clinarchi-frontend)

## 🛠️ Tech stack

- **Laravel 10** (PHP 8.1+), Laravel Sanctum
- **PostgreSQL** (MySQL also works locally)
- **Claude API** (Anthropic) via Laravel HTTP client
- **Docker** — Dockerfile ready for deployment on Render

## 🔌 API endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/projects` | List saved projects |
| `POST` | `/api/projects` | Save a generated project (summary, floors, departments, report) |
| `GET` | `/api/projects/{id}` | Get one project |
| `PUT` | `/api/projects/{id}` | Update a project |
| `DELETE` | `/api/projects/{id}` | Delete a project |
| `GET` | `/api/departments` | List department types |
| `POST` | `/api/generate-report` | Generate the functional report with Claude |

## 🚀 Getting started

**Prerequisites:** PHP 8.1+, Composer, PostgreSQL or MySQL.

```bash
git clone https://github.com/Hanane-b1/clinarchi-backend.git
cd clinarchi-backend
composer install
cp .env.example .env
php artisan key:generate
```

Set your database and Anthropic key in `.env`:

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=clinarchi
DB_USERNAME=postgres
DB_PASSWORD=

ANTHROPIC_API_KEY=your-key-here
```

Then run the migrations and start the server:

```bash
php artisan migrate
php artisan serve
```

The API runs on http://localhost:8000. A full PostgreSQL schema is also available in `ClinArchi.sql`.

### With Docker

```bash
docker build -t clinarchi-backend .
docker run -p 8000:8000 -e PORT=8000 --env-file .env clinarchi-backend
```

## 👩‍💻 Author

**Hanane Belhadi** — Full Stack Developer · [GitHub](https://github.com/Hanane-b1)
