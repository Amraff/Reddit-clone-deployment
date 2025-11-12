@echo off
echo Setting up GitHub Actions workflow...

mkdir .github 2>nul
mkdir .github\workflows 2>nul

copy github-workflows-deploy.yml .github\workflows\deploy.yml

echo GitHub Actions workflow setup complete!
echo File moved to: .github\workflows\deploy.yml