# Cuidarte+ — Sistema de Gestión Clínica

Proyecto desarrollado para la asignatura **ISY1102 – Calidad y Seguridad en el Desarrollo de Software** (Caso A: *Sistema de Gestión Cuidarte+*).

Cuidarte+ permite a **médicos** registrar pacientes y exámenes médicos, a **pacientes** visualizar su información clínica y a **administradores** supervisar, auditar y administrar usuarios y datos, cumpliendo la normativa de protección de datos y los estándares de seguridad.

> **Contexto académico:** el código de la aplicación contiene vulnerabilidades **intencionales** para ejercicios de análisis estático (SAST) y dinámico (DAST). El endurecimiento descrito en este documento se aplica a la **infraestructura y los contenedores**, no corrige esas vulnerabilidades del código.

---

## Índice

1. [Gestión del proyecto (PMBOK)](#1-gestión-del-proyecto-pmbok)
2. [Arquitectura](#2-arquitectura)
3. [Seguridad y calidad de los contenedores](#3-seguridad-y-calidad-de-los-contenedores)
4. [Variables de entorno](#4-variables-de-entorno)
5. [Despliegue en AWS EC2](#5-despliegue-en-aws-ec2)
6. [Integración y despliegue continuo (GitHub Actions)](#6-integración-y-despliegue-continuo-github-actions)
7. [Guía para desarrolladores](#7-guía-para-desarrolladores)

---

## 1. Gestión del proyecto (PMBOK)

### 1.1 Acta de constitución

| Elemento | Descripción |
|---|---|
| **Nombre** | Cuidarte+ — Sistema de Gestión Clínica |
| **Propósito** | Centralizar el registro de pacientes, exámenes y documentos clínicos con trazabilidad y control de acceso por rol. |
| **Justificación** | Los datos de salud son datos sensibles (Ley 19.628 y Ley 21.719 de protección de datos personales en Chile); su gestión exige confidencialidad, integridad, disponibilidad y auditoría. |
| **Objetivo general** | Entregar un sistema web desplegado en AWS que cumpla los requisitos funcionales del Caso A y que haya sido evaluado con prácticas de calidad y seguridad. |
| **Objetivos específicos** | 1) Implementar la gestión de pacientes, exámenes, documentos, usuarios y roles. 2) Ejecutar análisis SAST/DAST y documentar los hallazgos. 3) Desplegar en EC2 con contenedores endurecidos y CI/CD. 4) Mantener secretos fuera del repositorio. |
| **Criterios de éxito** | Pipeline de CI en verde; despliegue automático en EC2; base de datos y API sin exposición pública; hallazgos de seguridad documentados con su plan de remediación. |
| **Restricciones** | Plazo del semestre académico; presupuesto de AWS Free Tier o créditos académicos; stack definido (React + Vite, Node.js + Express, PostgreSQL). |
| **Supuestos** | El equipo dispone de cuentas de GitHub y AWS; la instancia EC2 tiene acceso a internet para descargar las imágenes desde GHCR. |

### 1.2 Alcance

**Dentro del alcance**
- Frontend SPA (React + Vite + MUI) servido por nginx.
- API REST (Express) con autenticación JWT y documentación OpenAPI/Swagger.
- Base de datos PostgreSQL con script de inicialización.
- Módulos: autenticación, usuarios, roles, pacientes, exámenes, tipos de examen, documentos y auditoría.
- Contenerización, pipeline CI/CD y despliegue en AWS EC2.
- Análisis de calidad y seguridad del código.

**Fuera del alcance**
- Integración con sistemas clínicos externos (HL7/FHIR).
- Alta disponibilidad multi-zona, autoescalado y bases de datos gestionadas (RDS).
- Aplicación móvil nativa.

### 1.3 Interesados (stakeholders)

| Interesado | Rol / interés | Influencia |
|---|---|---|
| Docente de ISY1102 | Patrocinador y evaluador; valida entregables y cumplimiento. | Alta |
| Equipo de desarrollo | Diseño, construcción, pruebas y despliegue. | Alta |
| Médicos (usuario final) | Registrar pacientes y exámenes de forma ágil y segura. | Media |
| Pacientes (usuario final) | Consultar su información clínica con privacidad. | Media |
| Administradores (usuario final) | Gestionar usuarios y auditar el sistema. | Media |
| Regulador / normativa | Cumplimiento de la protección de datos personales y sensibles. | Alta |

### 1.4 Estructura de desglose del trabajo (EDT)

```
1. Cuidarte+
├── 1.1 Gestión del proyecto ........ acta, plan, riesgos, seguimiento
├── 1.2 Análisis y diseño ........... requisitos, modelo de datos, arquitectura
├── 1.3 Construcción
│   ├── 1.3.1 Backend (API REST, JWT, OpenAPI)
│   ├── 1.3.2 Frontend (SPA React)
│   └── 1.3.3 Base de datos (esquema, datos iniciales)
├── 1.4 Calidad y seguridad ......... SAST, DAST, revisión de dependencias, informe
├── 1.5 Infraestructura y despliegue  Docker, GitHub Actions, AWS EC2
└── 1.6 Cierre ...................... documentación, presentación, lecciones aprendidas
```

### 1.5 Cronograma de hitos

| # | Hito | Entregable | Criterio de aceptación |
|---|---|---|---|
| H1 | Inicio | Acta de constitución y repositorio | Repositorio creado con estructura base |
| H2 | Entorno reproducible | `docker-compose` funcional | `docker compose up` levanta los 3 servicios |
| H3 | Análisis estático | Informe SAST | Hallazgos clasificados por severidad |
| H4 | Análisis dinámico | Informe DAST | Hallazgos con evidencia y recomendación |
| H5 | Despliegue | App en EC2 con CI/CD | Push a `main` despliega automáticamente |
| H6 | Cierre | Documentación final y presentación | Aprobación del docente |

### 1.6 Gestión de la calidad

| Práctica | Herramienta / mecanismo | Cuándo |
|---|---|---|
| Revisión de código | Pull requests hacia `main` | Cada cambio |
| Linting | ESLint (`FRONTEND`: `npm run lint`) | Antes de cada PR |
| Build verificable | GitHub Actions construye ambas imágenes | Cada push y PR |
| Análisis estático (SAST) | p. ej. SonarQube/SonarCloud, Semgrep, `npm audit` | Hito H3 y continuo |
| Análisis dinámico (DAST) | p. ej. OWASP ZAP sobre el entorno local | Hito H4 |
| Imágenes reproducibles | `npm ci` con `package-lock.json`, imágenes etiquetadas por commit | Cada build |

**Definición de terminado (DoD):** el código compila y pasa el lint, el pipeline está en verde, no introduce secretos en el repositorio y su documentación está actualizada.

### 1.7 Gestión de riesgos

| ID | Riesgo | Prob. | Impacto | Respuesta |
|---|---|---|---|---|
| R1 | Filtración de secretos (JWT, contraseñas) en el repositorio | Media | Alto | `.env` fuera de git, plantillas `.env.example`, secretos en GitHub Secrets; rotar si se filtran. |
| R2 | Exposición pública de la base de datos o la API | Media | Alto | Red Docker interna; solo nginx publica puerto; Security Group mínimo. |
| R3 | Vulnerabilidades en dependencias | Alta | Medio | `npm audit`, actualización periódica, imágenes base mantenidas (`node:20-alpine`). |
| R4 | Pérdida de datos clínicos | Baja | Alto | Volumen persistente de PostgreSQL y respaldos con `pg_dump` (ver §5.6). |
| R5 | Falta de memoria en una instancia pequeña al compilar | Media | Medio | Las imágenes se construyen en GitHub Actions; EC2 solo las descarga. |
| R6 | Cambio de IP pública de EC2 | Media | Bajo | Usar Elastic IP. |
| R7 | Tráfico sin cifrar (HTTP) | Alta | Alto | Habilitar HTTPS (dominio + certificado) antes de usar datos reales. |

### 1.8 Comunicaciones

| Qué | Canal | Frecuencia | Responsable |
|---|---|---|---|
| Avance del proyecto | Reunión de equipo | Semanal | Jefe/a de proyecto |
| Cambios de código | Pull requests en GitHub | Continuo | Desarrolladores |
| Estado del despliegue | Pestaña *Actions* de GitHub | Cada push a `main` | Responsable DevOps |
| Incidentes y hallazgos | Issues de GitHub (etiqueta `security`) | Al detectarse | Quien lo detecte |
| Entregas formales | Plataforma académica | Según hitos | Jefe/a de proyecto |

---

## 2. Arquitectura

```
                 Internet
                    │  HTTP :80 (o :3333 en local)
                    ▼
        ┌───────────────────────┐   red: cuidarteplus-public
        │ frontend (nginx)      │
        │  /       → SPA React  │
        │  /api/*  → backend    │──────────┐
        └───────────────────────┘          │
                                           ▼
                              ┌───────────────────────┐
                              │ backend (Express :4000)│  sin puertos publicados
                              └───────────────────────┘
                                           │  red: cuidarteplus-private (internal)
                                           ▼
                              ┌───────────────────────┐
                              │ PostgreSQL :5432       │  sin puertos publicados
                              └───────────────────────┘
```

| Carpeta / archivo | Contenido |
|---|---|
| `BACKEND/` | API Node.js + Express, scripts SQL (`sql/`), Dockerfile |
| `FRONTEND/` | SPA React + Vite, `nginx.conf` (proxy `/api/`), Dockerfile multi-etapa |
| `docker-compose.yml` | Definición base: redes, volúmenes y servicios endurecidos |
| `docker-compose.dev.yml` | Override local: publica la BD y la API **solo en 127.0.0.1** |
| `docker-compose.prod.yml` | Override de producción: usa las imágenes de GHCR |
| `.github/workflows/deploy.yml` | Pipeline de CI/CD |
| `.env.example` | Plantilla de variables (el `.env` real nunca se versiona) |

---

## 3. Seguridad y calidad de los contenedores

| Control | Implementación |
|---|---|
| **Base de datos privada** | Sin `ports`; solo está en `cuidarteplus-private`, una red `internal: true` sin salida a internet. |
| **API privada** | Sin `ports`; solo es alcanzable por nginx en `/api/`. |
| **Único punto de entrada** | nginx publica un solo puerto (`PORT_FRONTEND`). |
| **Secretos obligatorios** | `docker compose` falla si faltan `POSTGRES_PASSWORD` o `JWT_SECRET` (sin valores por defecto inseguros). |
| **Usuario sin privilegios** | El backend corre como `node` (no root). |
| **Mínimos privilegios** | `no-new-privileges` en todos los servicios; `cap_drop: ALL` en el backend. |
| **Imagen mínima** | `node:20-alpine` con `npm ci --omit=dev` (sin dependencias de desarrollo). |
| **Healthchecks** | PostgreSQL (`pg_isready`) y backend (`GET /`); el arranque respeta las dependencias. |
| **Cabeceras HTTP** | `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`; `server_tokens off`. |
| **Trazabilidad** | Cada imagen se etiqueta con el SHA del commit que la generó. |
| **Build fuera del servidor** | EC2 no compila código: solo descarga imágenes construidas en CI. |

---

## 4. Variables de entorno

Los archivos `.env` **no se versionan**. Cada carpeta tiene un `.env.example` que sirve de plantilla:

| Archivo | Uso |
|---|---|
| `.env` (raíz) | Docker Compose (local y EC2) |
| `BACKEND/.env` | Ejecutar la API sin Docker (`npm run dev`) |
| `FRONTEND/.env` | Ejecutar el frontend sin Docker (`npm run dev`) |

Variables de la raíz:

| Variable | Obligatoria | Descripción |
|---|---|---|
| `POSTGRES_PASSWORD` | ✅ | Contraseña de PostgreSQL. Generar con `openssl rand -hex 24`. |
| `JWT_SECRET` | ✅ | Llave de firma de los JWT. Generar con `openssl rand -hex 32`. |
| `POSTGRES_USER` / `POSTGRES_DB` | — | Por defecto `postgres` / `cuidarteplus`. |
| `PORT_FRONTEND` | — | Puerto público de nginx (local `3333`, EC2 `80`). |
| `FRONTEND_URL` | — | URL pública del frontend. |
| `PORT_POSTGRES` / `PORT_BACKEND` | — | Solo con `docker-compose.dev.yml` (ligados a 127.0.0.1). |
| `NODE_ENV` | — | `production` por defecto. |

> Si un secreto llega a publicarse (en un commit, un issue, un chat…), **rótalo**: quitarlo del repositorio no lo elimina del historial de git.

---

## 5. Despliegue en AWS EC2

### 5.1 Crear la instancia

1. **EC2 → Launch instance**
   - AMI: **Ubuntu Server 24.04 LTS**.
   - Tipo: `t3.micro` / `t2.micro` (Free Tier) o superior.
   - Key pair: crea una nueva llave (`.pem`) y guárdala en un lugar seguro. **Nunca** la subas al repositorio.
   - Almacenamiento: 20 GB gp3.
2. **Security Group** (reglas de entrada):

   | Puerto | Origen | Motivo |
   |---|---|---|
   | 22 (SSH) | `0.0.0.0/0`* | Administración y despliegue desde GitHub Actions |
   | 80 (HTTP) | `0.0.0.0/0` | Aplicación (nginx) |
   | 443 (HTTPS) | `0.0.0.0/0` | Solo si habilitas TLS |

   \* El SSH queda protegido solo por la llave. Los runners de GitHub usan IPs variables; si restringes el 22 a tu IP, el despliegue automático fallará (alternativa más segura: AWS Systems Manager).
   **No abras** los puertos 4000, 4444, 5432 ni 15442: la API y la base de datos son privadas.
3. **Elastic IP**: asígnala a la instancia para que la IP no cambie al reiniciar.

### 5.2 Preparar el servidor (una sola vez)

```bash
ssh -i vm.pem ubuntu@<ELASTIC_IP>

# Docker y git
sudo apt update && sudo apt -y upgrade
sudo apt install -y docker.io docker-compose-v2 git
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
exit   # vuelve a conectarte para aplicar el grupo docker
```

```bash
# Código (compose + scripts SQL de inicialización)
git clone https://github.com/SolgreyDuocUC/CuidartePlus.git ~/CuidartePlus
cd ~/CuidartePlus

# Variables de entorno de producción
cp .env.example .env
sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$(openssl rand -hex 24)|" .env
sed -i "s|^JWT_SECRET=.*|JWT_SECRET=$(openssl rand -hex 32)|" .env
sed -i "s|^PORT_FRONTEND=.*|PORT_FRONTEND=80|" .env
sed -i "s|^FRONTEND_URL=.*|FRONTEND_URL=http://<ELASTIC_IP>|" .env
chmod 600 .env

mkdir -p BACKEND/uploads/documentos
```

> Si el repositorio es **privado**, agrega una *Deploy key* de solo lectura (GitHub → Settings → Deploy keys) y clona por SSH.

### 5.3 Configurar GitHub

En **Settings → Secrets and variables → Actions**:

| Tipo | Nombre | Valor |
|---|---|---|
| Secret | `EC2_HOST` | Elastic IP o DNS público |
| Secret | `EC2_USER` | `ubuntu` |
| Secret | `EC2_SSH_KEY` | Contenido completo del archivo `.pem` |
| Variable | `DEPLOY_ENABLED` | `true` |
| Variable | `DEPLOY_PATH` | *(opcional)* por defecto `~/CuidartePlus` |

Crea además el entorno **`production`** (Settings → Environments). Ahí puedes exigir una aprobación manual antes de cada despliegue.

### 5.4 Desplegar

Cada **push a `main`** construye las imágenes, las publica en GHCR y las despliega en EC2. También puedes lanzarlo manualmente desde **Actions → Build & Deploy Cuidarte+ → Run workflow**.

Despliegue manual en el servidor (sin CI):

```bash
cd ~/CuidartePlus
git pull
echo <GITHUB_PAT_read:packages> | docker login ghcr.io -u <usuario> --password-stdin
docker compose -f docker-compose.yml -f docker-compose.prod.yml pull
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --no-build
```

La aplicación queda disponible en `http://<ELASTIC_IP>/` y la API en `http://<ELASTIC_IP>/api/`.

### 5.5 Verificación

```bash
docker compose ps                         # todos "healthy" / "running"
curl -s http://localhost/api/             # {"name":"cuidarteplus","status":"ok"}
sudo ss -tlnp | grep -E '5432|4000'       # no debe aparecer nada: BD y API son privadas
```

### 5.6 Operación

```bash
# Logs
docker compose logs -f cuidarteplus-backend-ev

# Respaldo de la base de datos
docker exec cuidarteplus-postgres-ev pg_dump -U postgres cuidarteplus | gzip > backup_$(date +%F).sql.gz

# Restaurar
gunzip -c backup_AAAA-MM-DD.sql.gz | docker exec -i cuidarteplus-postgres-ev psql -U postgres cuidarteplus
```

**HTTPS (recomendado antes de usar datos reales):** apunta un dominio a la Elastic IP y termina TLS con un Application Load Balancer + AWS Certificate Manager, o con Certbot (Let's Encrypt) delante de nginx.

---

## 6. Integración y despliegue continuo (GitHub Actions)

Archivo: [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml)

| Job | Disparador | Qué hace |
|---|---|---|
| `build` | push y PR a `main` | Construye las imágenes `backend` y `frontend`. En `main` las publica en `ghcr.io/solgreyduocuc/cuidarteplus-{backend,frontend}` con las etiquetas `latest` y `<sha>`. |
| `deploy` | push a `main` con `DEPLOY_ENABLED=true` | Se conecta por SSH a EC2, actualiza el repositorio, descarga las imágenes del commit y reinicia los servicios. |

Para volver a una versión anterior, despliega un SHA previo:

```bash
IMAGE_TAG=<sha_anterior> docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --no-build
```

---

## 7. Guía para desarrolladores

### 7.1 Requisitos

- Git
- Docker Desktop (o Docker Engine + Compose v2)
- Node.js 20+ (solo para desarrollo sin Docker)

### 7.2 Primer uso

```bash
git clone https://github.com/SolgreyDuocUC/CuidartePlus.git
cd CuidartePlus
cp .env.example .env              # completa POSTGRES_PASSWORD y JWT_SECRET
```

### 7.3 Levantar con Docker

```bash
# Como en producción: solo se expone el frontend
docker compose up -d --build
#   App: http://localhost:3333     API: http://localhost:3333/api/

# Modo análisis (SAST/DAST, clientes SQL, Swagger directo)
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
#   API:     http://127.0.0.1:4444  (Swagger en /docs)
#   BD:      127.0.0.1:15442  db=cuidarteplus  usuario=postgres  pass=<POSTGRES_PASSWORD>

# Detener / borrar también los datos
docker compose down
docker compose down -v
```

> El script SQL inicial solo se ejecuta cuando el volumen está vacío. Si cambias `POSTGRES_PASSWORD` con un volumen existente, ejecuta `docker compose down -v` (**borra los datos**) o cambia la contraseña dentro de PostgreSQL.

### 7.4 Levantar sin Docker

```bash
# Backend (requiere un PostgreSQL local con BACKEND/sql/init.sql cargado)
cd BACKEND
cp .env.example .env              # ajusta DATABASE_URL y JWT_SECRET
npm ci
npm run dev                       # http://localhost:4000  (Swagger: /docs)

# Frontend
cd FRONTEND
cp .env.example .env              # VITE_API_URL=http://localhost:4000
npm ci
npm run dev                       # http://localhost:5173
npm run lint
```

### 7.5 Flujo de trabajo

1. Crea una rama desde `main`: `git checkout -b feature/<descripcion>`.
2. Haz commits pequeños y descriptivos.
3. Antes de abrir el PR: `npm run lint` en `FRONTEND`, prueba la app con Docker y revisa que no haya secretos (`git diff --staged`).
4. Abre un pull request hacia `main`; el pipeline debe quedar en verde.
5. Al hacer merge, el despliegue a EC2 es automático.

### 7.6 Reglas de seguridad para el equipo

- **Nunca** subir `.env`, llaves `.pem`, tokens ni contraseñas. Usa `.env.example` para documentar variables nuevas.
- No publicar puertos de la base de datos ni de la API en `docker-compose.yml`; para análisis local usa `docker-compose.dev.yml` (ligado a `127.0.0.1`).
- Revisar las dependencias con `npm audit` antes de agregar paquetes.
- Reportar vulnerabilidades como issue con la etiqueta `security`, sin incluir datos sensibles.
