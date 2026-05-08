# HNMS Documentation Build & Deploy Script (Root Version)
# This script manages the compilation of the Vue project in 'app/' 
# and deploys the static files to the root of the 'Docs' folder.

Write-Host "Starting HNMS Documentation Build..." -ForegroundColor Cyan

$appDir = "app"
$publicDir = "$appDir\public"

# 1. Prepare Temporary Assets for Compilation
Write-Host "Preparing temporary assets..." -ForegroundColor Gray

# Ensure app/public exists and is clean of junctions/folders
if (!(Test-Path $publicDir)) { 
    New-Item -ItemType Directory -Path $publicDir -Force 
} else {
    # Remove existing junctions or folders to ensure a clean copy
    if (Test-Path "$publicDir\docs") { Remove-Item -Path "$publicDir\docs" -Recurse -Force -ErrorAction SilentlyContinue }
    if (Test-Path "$publicDir\Brand") { Remove-Item -Path "$publicDir\Brand" -Recurse -Force -ErrorAction SilentlyContinue }
}

# Copy the raw docs and Brand to app/public temporarily so Vite can see them
Write-Host "Copying docs and Brand to $publicDir..." -ForegroundColor Gray
New-Item -ItemType Directory -Path "$publicDir\docs" -Force | Out-Null
New-Item -ItemType Directory -Path "$publicDir\Brand" -Force | Out-Null
Copy-Item -Path "docs\*" -Destination "$publicDir\docs" -Recurse -Force
Copy-Item -Path "Brand\*" -Destination "$publicDir\Brand" -Recurse -Force

# 2. Run Compilation
Write-Host "Running Vite build..." -ForegroundColor Cyan
$oldDir = Get-Location
Set-Location -Path $appDir
npm run build
$buildStatus = $LASTEXITCODE
Set-Location -Path $oldDir

if ($buildStatus -eq 0) {
    Write-Host "Build successful. Deploying static files..." -ForegroundColor Green
    
    # 3. Deploy to root
    if (Test-Path "$appDir\dist\assets") { 
        Copy-Item -Path "$appDir\dist\assets" -Destination "." -Recurse -Force 
    }
    if (Test-Path "$appDir\dist\.nojekyll") {
        Copy-Item -Path "$appDir\dist\.nojekyll" -Destination "." -Force
    }
    
    # Copy the compiled HTML and rename it to index.html
    if (Test-Path "$appDir\dist\index.template.html") {
        Copy-Item -Path "$appDir\dist\index.template.html" -Destination "index.html" -Force
    }

    # 4. Cleanup Post-Build
    Write-Host "Cleaning up temporary files..." -ForegroundColor Gray
    Remove-Item -Path "$appDir\dist" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$publicDir\docs" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$publicDir\Brand" -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "Documentation is now updated and ready at the root!" -ForegroundColor Blue
} else {
    Write-Host "Build failed. Please check the errors above." -ForegroundColor Red
    exit $buildStatus
}
