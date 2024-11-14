# Using the IP-Cert Docker Image

## Overview

This image helps generate SSL certificates with ZeroSSL using custom configurations. You can control the behavior through environment variables or use a configuration file to define the settings for generating certificates.

## Prerequisites

- Docker installed
- Docker Compose installed (optional, if you prefer to use Compose)
- [ZeroSSL API key](https://app.zerossl.com/developer) (Note: ZeroSSL free accounts are limited to a maximum of 3 IP certificates at a time)


## Quick Start

To use the IP-Cert Docker image, you need to configure the container either using environment variables or an existing configuration file. This guide will walk you through both options.

### 1. Running with Environment Variables

To generate the configuration dynamically using environment variables, you can set the variables directly in your Docker Compose file or use the `docker run` command.

#### Using Docker Compose

Create a `docker-compose.yml` file with the following content:

```yaml
services:
  ip-cert:
    image: registry.kyzdt.com/tools/ip-cert:latest
    container_name: ip-cert
    restart: unless-stopped
    ports:
      - "80:80"
    environment:
      IP_CERT_MODE: "env" # Use environment variables to generate the config
      # IP_CERT_HOST_IP: "your-public-ip" # Must be a public IP address, if empty, get by (curl -s -4 ifconfig.me) 
      IP_CERT_API_KEY: "your-zerossl-api-key" # Set your ZeroSSL API key here
      IP_CERT_COUNTRY: "US" # Optional CSR details
      IP_CERT_PROVINCE: "CA"
      IP_CERT_CITY: "San Francisco"
      IP_CERT_ORGANIZATION: "My Organization"
      IP_CERT_ORG_UNIT: "My Unit"
    volumes:
      - ./log:/log
      - ./certs:/certs
      # if you want to use your own config.yaml
      # - ./config/config.yaml:/config.yaml
      # if you want to customize post-host.sh
      # -./config/post-hook.sh}:/hook/post-hook.sh:ro
      # Uncomment if you need to restart other containers
      # - /var/run/docker.sock:/var/run/docker.sock
```

Run the container using Docker Compose:

```bash
docker-compose up -d
```

#### Using Docker Run Command

You can also run the container directly using Docker CLI:

```bash
docker run -d \
  --name ip-cert \
  -e IP_CERT_HOST_IP="PUBLIC_IP" \
  -e IP_CERT_MODE="env" \
  -e IP_CERT_API_KEY="your-zerossl-api-key" \
  -e IP_CERT_COUNTRY="US" \
  -e IP_CERT_PROVINCE="CA" \
  -e IP_CERT_CITY="San Francisco" \
  -e IP_CERT_ORGANIZATION="My Organization" \
  -e IP_CERT_ORG_UNIT="My Unit" \
  -v ./log:/log \
  -v ./certs:/certs \
  -v ./config:/config \
  registry.kyzdt.com/tools/ip-cert:latest
```

### 2. Running with Existing Configuration File

If you prefer to use an existing configuration file, set the `IP_CERT_MODE` environment variable to `file` and provide the `config.yaml` file.

Ensure your `docker-compose.yml` file looks like this:

```yaml
version: "3.8"

services:
  ip-cert:
    image: registry.kyzdt.com/tools/ip-cert:latest
    container_name: ip-cert
    restart: unless-stopped
    ports:
      - "80:80"
    environment:
      IP_CERT_MODE: "file" # Use an existing config file
    volumes:
      - ./log:/log
      - ./certs:/certs
      - ./config/config.yaml:/config.yaml:ro # Mount the existing config.yaml file
```

Run with Docker Compose:

```bash
docker-compose up -d
```

## Environment Variables

### Summary of Environment Variables
| Variable Name                    | Default Value      | Required | Description |
|----------------------------------|--------------------|----------|-------------|
| **IP_CERT_MODE**                 | env                | No       | Define how to configure the container (`env` or `file`). Default is `env`. |
| **IP_CERT_HOST_IP**              | Obtained via `curl`| NO       | Your public IP. If empty, it will be retrieved using `curl -s -4 ifconfig.me`. |
| **IP_CERT_API_KEY**              | N/A                | Yes      | Your ZeroSSL API key. Mandatory when `IP_CERT_MODE=env`. |
| **IP_CERT_COUNTRY**              | US                 | No       | CSR country information. Optional when generating the certificate. |
| **IP_CERT_PROVINCE**             | CA                 | No       | CSR province information. Optional when generating the certificate. |
| **IP_CERT_CITY**                 | San Francisco      | No       | CSR city information. Optional when generating the certificate. |
| **IP_CERT_ORGANIZATION**         | Earth              | No       | CSR organization information. Optional when generating the certificate. |
| **IP_CERT_ORG_UNIT**             | Development        | No       | CSR organizational unit. Optional when generating the certificate. |
| **IP_CERT_CLEAN_UNFINISHED**     | true               | No       | Set to `true` to clean up unfinished ZeroSSL certificates. |
| **IP_CERT_OUTPUT_CONFIG**        | false              | No       | Set to `true` to output the generated configuration file for verification. |
| **IP_CERT_RESRAT_CONTAINER_NAME**| N/A                | No       | Space-separated list of container names to be restarted after certificate issuance. |
| **EXEC_CRON_UNIT**               | day                | No       | Frequency unit for certificate renewal checks (`day`, `hour`, etc.). Default is `day`. |
| **EXEC_CRON_UNMBER**             | 10                 | No       | Frequency value for certificate renewal checks. Default is `10` days. |

## Volumes

- **/log**: Logs from the container.
- **/certs**: Stores generated certificates.
- **/config.yaml**: The configuration file if using the `file` mode.

## Example Use Cases

### 4. Restarting Other Containers
If `IP_CERT_RESRAT_CONTAINER_NAME` is provided, the script will automatically attempt to restart each specified container after issuing certificates. This can be useful when other services depend on the new certificates.

### 1. Custom CSR Information
You can set the `IP_CERT_COUNTRY`, `IP_CERT_PROVINCE`, etc., to provide custom CSR (Certificate Signing Request) information when generating certificates.

### 2. Automating Container Restart
If you need to restart other containers after the certificates are generated, you can mount the Docker socket by uncommenting the volume mapping for `/var/run/docker.sock`.

### 3. Using Post-Hook Scripts
If you have a custom script that needs to run after certificate issuance, you can provide a custom `post-hook.sh` by mounting it to `/hook/post-hook.sh`.

## Debugging

# Check if the variable is empty
if [ -z "$IP_CERT_RESRAT_CONTAINER_NAME" ]; then
    echo "No containers specified in RESRAT_CONTAINER_NAME. Exiting."
    exit 0
fi

# Loop through container names
for container in $IP_CERT_RESRAT_CONTAINER_NAME; do
    echo "Restarting Docker container: $container"
    docker-action "$container" restart
    if [ $? -eq 0 ]; then
        echo "Successfully restarted: $container"
    else
        echo "Failed to restart: $container"
    fi
done
To debug the container, you can set `LOG_DEBUG` to `"true"` in the environment variables to enable verbose logging.

## Generating Configuration Manually
If you want to generate a `config.yaml` manually, you can use the provided `generate_config.sh` script. Ensure you have set all required environment variables before running the script.

```bash
export CONFIG_FILE="./config/config.yaml"
export IP_CERT_API_KEY="API_KEY"
chmod +x generate_config.sh
./scripts/generate_config.sh
```
This will create `config.yaml` with the values from your environment variables.

## License
This Docker image and related scripts are licensed under the Apache License, Version 2.0.

## Dependencies

This project utilizes the `zerossl-ip-cert` executable for certificate-related operations. 

- Project: [zerossl-ip-cert](https://github.com/tinkernels/zerossl-ip-cert)
- License: [Apache License 2.0](https://github.com/tinkernels/zerossl-ip-cert/blob/master/LICENSE)

## Troubleshooting

### Common Issues

1. **Cannot Obtain Public IP**: 
   - If the container cannot obtain the public IP address, ensure that the server has internet access, and the `curl` command works properly.
   - You can also manually set `IP_CERT_HOST_IP` to avoid this issue.

2. **Missing API Key**:
   - Ensure `IP_CERT_API_KEY` is provided. This value is mandatory for certificate issuance.

3. **Permission Issues**:
   - If you encounter permission issues while accessing the mounted volumes, ensure that the directories (`log`, `certs`, `config`) have appropriate read/write permissions for Docker.

## Updating the Docker Image

To pull the latest version of the IP-Cert Docker image:

```bash
docker pull registry.kyzdt.com/tools/ip-cert:latest
```
After pulling the updated image, restart the container using Docker Compose or Docker CLI:

```bash
docker-compose down && docker-compose up -d
```

This ensures you are using the latest version with all recent improvements and bug fixes.
