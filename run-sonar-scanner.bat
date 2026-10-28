@echo off
setlocal

set "TOKEN=%~1"

if "%TOKEN%"=="" (
    set /p "TOKEN=Por favor, ingresa tu SONAR_TOKEN generado en SonarQube: "
)

if "%TOKEN%"=="" (
    echo [ERROR] El token es obligatorio para ejecutar el analisis.
    exit /b 1
)

echo Ejecutando escaneo de SonarQube para CuidartePlus...

docker run --rm ^
  -e SONAR_HOST_URL="http://host.docker.internal:9000" ^
  -e SONAR_TOKEN="%TOKEN%" ^
  -e SONAR_LOGIN="%TOKEN%" ^
  -v "%cd%:/usr/src" ^
  sonarsource/sonar-scanner-cli

endlocal
