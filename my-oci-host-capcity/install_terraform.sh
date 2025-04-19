#!/bin/bash

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Terraform not found. Installing..."
    
    # Add HashiCorp GPG key and repository
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    
    # Install Terraform
    sudo apt-get update && sudo apt-get install -y terraform
    
    # Check if installation was successful
    if ! terraform version &> /dev/null; then
        echo "Terraform installation failed!"
        exit 1
    fi
    
    echo "Terraform installed successfully."
fi

# Initialize Terraform working directory
echo "Initializing Terraform..."
terraform init

# Loop running terraform apply until successful
while true; do
    echo "Running terraform apply..."
    # No longer need to pass variables via -var, Terraform will automatically load terraform.tfvars
    TERRAFORM_OUTPUT=$(terraform apply -auto-approve 2>&1)

    TERRAFORM_EXIT_CODE=$?

    if [ $TERRAFORM_EXIT_CODE -eq 0 ]; then
        echo "Apply successful!"
        break
    else
        # First, output the original error message
        echo "$TERRAFORM_OUTPUT"
        
        if echo "$TERRAFORM_OUTPUT" | grep -q "Too Many Requests\|429"; then
            echo "Rate limit hit. Waiting 600 seconds..."
            sleep 600
        elif echo "$TERRAFORM_OUTPUT" | grep -q "500" && echo "$TERRAFORM_OUTPUT" | grep -q "InternalError" && echo "$TERRAFORM_OUTPUT" | grep -q "Out of host capacity"; then
            echo "Out of capacity error. Waiting 10 seconds before retrying..."
            sleep 10
        else
            echo "Other error. Exiting script..."
            exit 1
        fi
    fi
done

echo "ARM instance created successfully!"