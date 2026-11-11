# ClinArchi · API

API REST de ClinArchi, plateforme de programmation architecturale pour cliniques et hôpitaux. Elle enregistre les projets générés et rédige le rapport fonctionnel par intelligence artificielle, sans jamais exposer la clé d'API au navigateur.

Projet réalisé pendant mon stage de développeuse full stack chez Groupe Vitalys Santé (mars à avril 2026). L'interface se trouve dans [clinarchi-frontend](https://github.com/Hanane-b1/clinarchi-frontend).

## Fonctionnalités

| Méthode | Route | Rôle |
|---|---|---|
| `GET` | `/api/projects` | Lister les projets enregistrés |
| `POST` | `/api/projects` | Enregistrer un projet généré |
| `GET` | `/api/projects/{id}` | Consulter un projet |
| `PUT` | `/api/projects/{id}` | Modifier un projet |
| `DELETE` | `/api/projects/{id}` | Supprimer un projet |
| `GET` | `/api/departments` | Lister les types de départements |
| `POST` | `/api/generate-report` | Générer le rapport fonctionnel par IA |

## Technologies

Laravel 10 (PHP 8.1), Laravel Sanctum, PostgreSQL, API d'IA générative, Docker

## Installation

Prérequis : PHP 8.1+, Composer, PostgreSQL ou MySQL.

```bash
git clone https://github.com/Hanane-b1/clinarchi-backend.git
cd clinarchi-backend
composer install
cp .env.example .env
php artisan key:generate
```

Renseigner la base de données et la clé d'API dans `.env` :

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=clinarchi
DB_USERNAME=postgres
DB_PASSWORD=

ANTHROPIC_API_KEY=
```

Puis lancer les migrations et le serveur :

```bash
php artisan migrate
php artisan serve
```

L'API est disponible sur http://localhost:8000. Le schéma PostgreSQL complet est fourni dans `ClinArchi.sql`.

### Avec Docker

```bash
docker build -t clinarchi-backend .
docker run -p 8000:8000 -e PORT=8000 --env-file .env clinarchi-backend
```

## Auteur

Hanane Belhadi
