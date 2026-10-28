# Guía de Ejecución de SonarQube en Rama QA (CuidartePlus)

> **Nota:** Esta rama está destinada exclusivamente a tareas de **Aseguramiento de Calidad (QA)**, análisis estático de código, detección de vulnerabilidades y buenas prácticas.

---

## Requisitos Previos

1. **Docker Desktop** instalado y en ejecución en tu equipo.
2. Terminal **PowerShell** (o terminal con soporte Docker en Windows).
3. Asegurarse de tener libre el puerto **9000** en `localhost`.

---

## Paso 1: Levantar el Servidor de SonarQube

El proyecto cuenta con un archivo Docker Compose dedicado: [`docker-compose.sonar.yml`](file:///C:/Users/GAMER/Desktop/Proyectos%20Semestrales/CuidartePlus/docker-compose.sonar.yml).

1. Abre una terminal en la raíz del proyecto (`CuidartePlus`).
2. Ejecuta el siguiente comando para iniciar SonarQube en segundo plano:

```powershell
docker compose -f docker-compose.sonar.yml up -d
```

3. Espera entre **1 y 2 minutos** mientras el contenedor inicializa el servicio y la base de datos interna. Puedes verificar el estado con:

```powershell
docker logs -f sonarqube
```
*(Presiona `Ctrl + C` para salir de los logs una vez que indique `SonarQube is operational`).*

---

## Paso 2: Primer Acceso y Cambio de Contraseña

1. Abre tu navegador web y entra a:
   **[http://localhost:9000](http://localhost:9000)**
2. Inicia sesión con las credenciales por defecto:
   - **Login:** `admin`
   - **Password:** `admin`
3. SonarQube te solicitará obligatoriamente cambiar la contraseña:
   - Ingresa la contraseña anterior (`admin`) y define tu nueva contraseña segura.

---

## Paso 3: Crear el Proyecto y Generar el Token

1. En la pantalla principal de SonarQube, haz clic en **"Create Project"** y selecciona **"Manually"**.
2. Completa los campos con la configuración del proyecto:
   - **Project display name:** `CuidartePlus`
   - **Project key:** `cuidarteplus` *(debe ser idéntico al valor en [`sonar-project.properties`](file:///C:/Users/GAMER/Desktop/Proyectos%20Semestrales/CuidartePlus/sonar-project.properties))*
3. En la configuración de nueva rama / baseline, selecciona **"Use the global setting"** y haz clic en **"Create project"**.
4. En la pantalla *"How do you want to analyze your repository?"*, selecciona **"Locally"**.
5. En la sección **"Provide a token"**:
   - Selecciona **"Generate a token"**.
   - Ingresa un nombre descriptivo (ej: `qa-scanner-token`).
   - Elige expiración (ej: `30 days` o según prefieras).
   - Haz clic en **"Generate"**.
   - **Copia y guarda el token generado** (ejemplo: `sqp_1234567890abcdef...`), ya que no volverá a mostrarse.

---

## Paso 4: Ejecutar el Análisis de Código

### Opción A: Usando scripts automatizados (Recomendado)

- **Si estás en CMD (Símbolo del sistema):**
  ```cmd
  run-sonar-scanner.bat
  ```
  *(O pasando tu token directo: `run-sonar-scanner.bat tu_token_generado`)*

- **Si estás en PowerShell:**
  ```powershell
  .\run-sonar-scanner.ps1
  ```
  *(O pasando tu token directo: `.\run-sonar-scanner.ps1 -Token "tu_token_generado"`)*

Ambos scripts te solicitarán pegar el token de SonarQube si no lo pasas como argumento.

---

### Opción B: Ejecución directa con Docker CLI

Asegúrate de reemplazar `TU_TOKEN_GENERADO` por el token real que obtuviste en el Paso 3 (ej: `sqp_1234567890abcdef...`).

- **En CMD (Símbolo del sistema en Windows):**
  ```cmd
  docker run --rm -e SONAR_HOST_URL="http://host.docker.internal:9000" -e SONAR_TOKEN="TU_TOKEN_GENERADO" -e SONAR_LOGIN="TU_TOKEN_GENERADO" -v "%cd%:/usr/src" sonarsource/sonar-scanner-cli
  ```

- **En PowerShell:**
  ```powershell
  docker run --rm `
    -e SONAR_HOST_URL="http://host.docker.internal:9000" `
    -e SONAR_TOKEN="TU_TOKEN_GENERADO" `
    -e SONAR_LOGIN="TU_TOKEN_GENERADO" `
    -v "${PWD}:/usr/src" `
    sonarsource/sonar-scanner-cli
  ```

> **Nota importante:** En CMD se utiliza `%cd%` para la ruta actual, mientras que en PowerShell se usa `${PWD}`. La configuración del escáner (`backend/src`, `frontend/src`, exclusiones de `node_modules`, etc.) es leída automáticamente desde [`sonar-project.properties`](file:///C:/Users/GAMER/Desktop/Proyectos%20Semestrales/CuidartePlus/sonar-project.properties).

---

## Paso 5: Consultar Resultados en el Dashboard

Una vez terminado el escaneo (verás el mensaje `EXECUTION SUCCESS` en tu terminal):

1. Dirígete a:
   **[http://localhost:9000/dashboard?id=cuidarteplus](http://localhost:9000/dashboard?id=cuidarteplus)**
2. Podrás evaluar:
   - **Quality Gate:** Estado general (Passed / Failed).
   - **Bugs y Vulnerabilidades:** Problemas de seguridad o errores de ejecución.
   - **Security Hotspots:** Zonas críticas de código para revisión manual.
   - **Code Smells & Technical Debt:** Oportunidades de refactorización y deuda técnica.
   - **Duplicaciones:** Código redundante entre frontend y backend.

---

## Paso 6: Detener o Limpiar SonarQube

- **Para pausar/detener el servidor preservando tus datos y análisis previos:**
  ```powershell
  docker compose -f docker-compose.sonar.yml down
  ```

- **Para reiniciar el servidor más adelante:**
  ```powershell
  docker compose -f docker-compose.sonar.yml up -d
  ```

- **Para eliminar completamente los datos y comenzar desde cero:**
  ```powershell
  docker compose -f docker-compose.sonar.yml down -v
  ```

---

## Solución a Problemas Frecuentes

1. **`Not authorized. Please check the properties sonar.login and sonar.password`:**
   - **Causa:** Dejaste el valor de ejemplo `"TU_TOKEN_AQUI"` en lugar de colocar el token real generado en la interfaz web de SonarQube, o el token expiró.
   - **Solución:** Ve a `http://localhost:9000` > Tu perfil (esquina superior derecha) > **My Account** > **Security** > Genera un nuevo token con nombre `sonar-token` y cópialo. Luego ejecútalo con ese token.

2. **`create ${PWD}: invalid characters for a local volume name`:**
   - **Causa:** Estás ejecutando el comando en **CMD (Símbolo del sistema)** en lugar de PowerShell. En CMD la variable `${PWD}` no existe.
   - **Solución:** Usa `%cd%` en lugar de `${PWD}`, o simplemente ejecuta `run-sonar-scanner.bat`.

---

## Archivos Relacionados en esta Rama

| Archivo | Propósito |
|---|---|
| [`docker-compose.sonar.yml`](file:///C:/Users/GAMER/Desktop/Proyectos%20Semestrales/CuidartePlus/docker-compose.sonar.yml) | Definición del contenedor SonarQube LTS Community y sus volúmenes persistentes. |
| [`sonar-project.properties`](file:///C:/Users/GAMER/Desktop/Proyectos%20Semestrales/CuidartePlus/sonar-project.properties) | Propiedades del proyecto (`projectKey`, fuentes `backend/src,frontend/src`, exclusiones). |
| [`run-sonar-scanner.bat`](file:///C:/Users/GAMER/Desktop/Proyectos%20Semestrales/CuidartePlus/run-sonar-scanner.bat) | Script para CMD (Símbolo del sistema) para ejecutar el escaneo fácilmente en Windows. |
| [`run-sonar-scanner.ps1`](file:///C:/Users/GAMER/Desktop/Proyectos%20Semestrales/CuidartePlus/run-sonar-scanner.ps1) | Script PowerShell para ejecutar `sonar-scanner-cli` dentro de un contenedor efímero. |
| [`sonarInstructions.md`](file:///C:/Users/GAMER/Desktop/Proyectos%20Semestrales/CuidartePlus/sonarInstructions.md) | Guía paso a paso de uso para el equipo de QA. |

