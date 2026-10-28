param(
    [Parameter(Mandatory=$false)]
    [string]$Token
)

if (-not $Token) {
    $Token = Read-Host "Por favor, ingresa tu SONAR_TOKEN generado en SonarQube"
}

if (-not $Token) {
    Write-Error "El token es obligatorio para ejecutar el analisis."
    exit 1
}

Write-Host "Ejecutando escaneo de SonarQube para CuidartePlus..." -ForegroundColor Cyan

docker run --rm `
  -e SONAR_HOST_URL="http://host.docker.internal:9000" `
  -e SONAR_TOKEN="$Token" `
  -e SONAR_LOGIN="$Token" `
  -v "${PWD}:/usr/src" `
  sonarsource/sonar-scanner-cli
