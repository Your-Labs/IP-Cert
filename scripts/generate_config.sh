#!/bin/bash

# Set default mode if not provided
IP_CERT_MODE=${IP_CERT_MODE:-"env"}

# Check if mode is set to 'file' to use existing configuration file
if [ "$IP_CERT_MODE" = "file" ]; then
    echo "Using the existing config file."
    exit 0
fi

# Define the output configuration file
CONFIG_FILE=${CONFIG_FILE:-"/config.yaml"}

# Ensure required environment variables are set
if [ -z "$IP_CERT_API_KEY" ]; then
    echo "Error: IP_CERT_API_KEY is empty. It must be set."
    exit 1
fi

# Set IP_CERT_HOST_IP if not provided
if [ -z "$IP_CERT_HOST_IP" ]; then
    echo "IP_CERT_HOST_IP is empty, trying to get public IP using curl"
    IP_CERT_HOST_IP=$(curl -s -4 ifconfig.me)
    if [ -z "$IP_CERT_HOST_IP" ]; then
        echo "Error: Cannot obtain public IP, exiting."
        exit 1
    else
        echo "Successfully retrieved IP_CERT_HOST_IP: ${IP_CERT_HOST_IP}"
    fi
fi

# Initialize the YAML configuration
cat <<EOF > "$CONFIG_FILE"
dataDir: /certs # Data directory for containing the status and temporary files
logFile: /log/log.txt # Log file
cleanUnfinished: ${IP_CERT_CLEAN_UNFINISHED:-true} # Clean zerossl certificates that are not finished issuing.
certConfigs:
EOF

# Generate certConfigs entry from environment variables
cat <<EOF >> "$CONFIG_FILE"
  - commonName: ${IP_CERT_HOST_IP}
    confId: ${IP_CERT_HOST_IP} # Mandatory field to identify the certificate configuration
    apiKey: ${IP_CERT_API_KEY} # ZeroSSL API key
    ######## CSR INFO ########
    country: ${IP_CERT_COUNTRY:-"US"}
    province: ${IP_CERT_PROVINCE:-"CA"}
    city: ${IP_CERT_CITY:-"San Francisco"}
    locality: ${IP_CERT_LOCALITY:-"San Francisco"}
    organization: ${IP_CERT_ORGANIZATION:-"Earth"}
    organizationUnit: ${IP_CERT_ORG_UNIT:-"Development"}
    ######## CSR INFO ########
    days: ${IP_CERT_DAYS:-90} # Certificate validity in days
    keyType: ${IP_CERT_KEY_TYPE:-"ecdsa"} # Key type, ecdsa or rsa
    keyBits: ${IP_CERT_KEY_BITS:-2048} # RSA key bits (only used if keyType is rsa)
    keyCurve: ${IP_CERT_KEY_CURVE:-"P-256"} # ECDSA curve, P-256 or P-384
    sigAlg: ${IP_CERT_SIG_ALG:-"ECDSA-SHA256"} # Signature algorithm, e.g., ECDSA-SHA256
    strictDomains: 1 # Fixed value
    verifyMethod: HTTP_CSR_HASH # Fixed value
    verifyHook: /hook/verify-hook.sh # Verify hook executable, called before verifying domains
    postHook: /hook/post-hook.sh # Post hook executable, called after certificates arrival
    certFile: ${IP_CERT_CERT_FILE:-"/certs/cert.pem"} # Certificate store path
    keyFile: ${IP_CERT_KEY_FILE:-"/certs/key.pem"} # Key store path
EOF

# Output success message
echo "Configuration file generated: $CONFIG_FILE"

# Optionally output the generated configuration
if [ "$IP_CERT_OUTPUT_CONFIG" = "true" ]; then
    echo "The generated config.yaml is as follows:"
    cat "$CONFIG_FILE"
fi
