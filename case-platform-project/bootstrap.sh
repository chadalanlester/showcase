#!/bin/bash
set -e

echo "📦 Bootstrapping Terraform environment..."

# Check Terraform
if ! command -v terraform &> /dev/null; then
  echo "Terraform not found. Installing with Homebrew..."
  brew install terraform
else
  echo "✅ Terraform is already installed: $(terraform version | head -n 1)"
fi

# Optional: Add other tools here

