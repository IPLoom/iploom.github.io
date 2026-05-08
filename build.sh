#!/bin/bash

# HNMS Documentation Build & Deploy Script (Root Version)
# This script manages the compilation of the Vue project in 'app/' 
# and deploys the static files to the root of the 'Docs' folder.

echo "🚀 Starting HNMS Documentation Build..."

appDir="app"
publicDir="$appDir/public"

# 1. Prepare Temporary Assets for Compilation
echo "📦 Preparing temporary assets..."
mkdir -p "$publicDir/docs"
mkdir -p "$publicDir/Brand"

# Copy the raw docs and Brand to app/public temporarily so Vite can see them
cp -r docs/* "$publicDir/docs/"
cp -r Brand/* "$publicDir/Brand/"

# 2. Run Compilation
echo "🛠️ Running Vite build..."
cd "$appDir"
npm run build
buildStatus=$?
cd ..

if [ $buildStatus -eq 0 ]; then
    echo "✅ Build successful. Deploying static files..."
    
    # 3. Deploy to root
    [ -d "$appDir/dist/assets" ] && cp -r "$appDir/dist/assets" .
    [ -f "$appDir/dist/.nojekyll" ] && cp "$appDir/dist/.nojekyll" .
    
    # Copy the compiled HTML and rename it to index.html
    if [ -f "$appDir/dist/index.template.html" ]; then
        cp "$appDir/dist/index.template.html" index.html
    fi

    # 4. Cleanup Post-Build
    echo "🧹 Cleaning up temporary files..."
    rm -rf "$appDir/dist"
    rm -rf "$publicDir/docs"
    rm -rf "$publicDir/Brand"
    
    echo "✨ Documentation is now updated and ready at the root!"
else
    echo "❌ Build failed. Please check the errors above."
    exit $buildStatus
fi
