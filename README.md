# ubi-starter

[![Build & Test](https://github.com/omaciel/ubi-starter/actions/workflows/build-test.yml/badge.svg)](https://github.com/omaciel/ubi-starter/actions/workflows/build-test.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

A starter kit for testing applications inside Red Hat Universal Base Image (UBI) containers, with proper user permissions and volume mounting — no Red Hat subscription required.

## Overview

`ubi-starter` provides ready-to-use containerized environments for RHEL 8, 9, and 10 (via UBI), letting you test your applications across RHEL versions without physical systems or virtual machines. Each container includes a non-root user with matching UID/GID from your host system, ensuring proper file permissions when working with mounted volumes.

## Prerequisites

### Required Software

You need either **Docker** or **Podman** installed on your system:

- **Docker**: [Installation instructions](https://docs.docker.com/get-docker/)
- **Podman**: [Installation instructions](https://podman.io/getting-started/installation)

The Makefile will automatically detect which container runtime is available (preferring Docker if both are installed).

### Operating System Requirements

Your host system needs:

- **Linux/macOS/Windows**: Any OS that supports Docker or Podman
- **User permissions**: Ability to run container commands (may require `sudo` or being in the `docker` group on Linux)

### RHEL Base Images

This starter kit uses Universal Base Images (UBI) from Red Hat, which are:

- Freely redistributable
- Available without a Red Hat subscription
- Based on RHEL packages

The Containerfiles use specific UBI image versions:

- `registry.access.redhat.com/ubi8/ubi:8.10` (RHEL 8)
- `registry.access.redhat.com/ubi9/ubi:9.7` (RHEL 9)
- `registry.access.redhat.com/ubi10/ubi:10.1` (RHEL 10)

These images will be pulled automatically during the build process. However, if you want to pre-pull them or use different versions, you can do so:

```bash
# Using Docker - images will be pulled automatically during build
docker pull registry.access.redhat.com/ubi8/ubi:8.10
docker pull registry.access.redhat.com/ubi9/ubi:9.7
docker pull registry.access.redhat.com/ubi10/ubi:10.1

# Or using Podman - images will be pulled automatically during build
podman pull registry.access.redhat.com/ubi8/ubi:8.10
podman pull registry.access.redhat.com/ubi9/ubi:9.7
podman pull registry.access.redhat.com/ubi10/ubi:10.1
```

**Note**: The images are pulled directly from Red Hat's registry during build, so no manual pulling or tagging is required unless you want to cache them beforehand.

## Quick Start

1. **Clone or download this repository**

2. **Build a container image** (e.g., for RHEL 9):

   ```bash
   make build-rhel9
   ```

3. **Run the container**:

   ```bash
   make run-rhel9
   ```

Your current directory will be mounted inside the container at `/home/flash/data` (or `/home/<USERNAME>/data` if you customized the username).

## Usage

### Available Make Targets

**Build containers:**

```bash
make build-rhel8    # Build RHEL 8 container
make build-rhel9    # Build RHEL 9 container
make build-rhel10   # Build RHEL 10 container
make build-all      # Build all RHEL containers
```

**Run containers:**

```bash
make run-rhel8      # Run RHEL 8 container
make run-rhel9      # Run RHEL 9 container
make run-rhel10     # Run RHEL 10 container
```

**Clean up:**

```bash
make clean-rhel8    # Remove RHEL 8 container image
make clean-rhel9    # Remove RHEL 9 container image
make clean-rhel10   # Remove RHEL 10 container image
make clean-all      # Remove all RHEL container images
```

**Help:**

```bash
make help           # Show all available targets
```

### Working with Mounted Volumes

When you run a container, your current directory is automatically mounted inside the container:

- **Host path**: Your current working directory (where you ran `make`)
- **Container path**: `/home/<USERNAME>/data` (default: `/home/flash/data`)

#### Example Workflow

1. Place your application code in this directory
2. Run a container:

   ```bash
   make run-rhel9
   ```

3. Inside the container, navigate to the data directory:

   ```bash
   cd ~/data
   ```

4. Test your application:

   ```bash
   # Example: Python application
   python3 my_app.py

   # Example: Compile and run C code
   gcc -o myapp myapp.c
   ./myapp

   # Example: Node.js application
   npm install
   npm start
   ```

All files created inside `/home/<USERNAME>/data` will be saved to your host directory with proper permissions.

## Configuration

### Customizing the Username

By default, containers create a user named `flash`. To use a different username, edit the `Makefile`:

```makefile
# User configuration
USERNAME := your_username_here
```

Or override it when running make commands:

```bash
make build-rhel9 USERNAME=developer
make run-rhel9 USERNAME=developer
```

### Customizing UID and GID

The containers automatically use your host system's UID and GID to ensure file permissions match. This happens automatically via:

```makefile
USER_UID := $(shell id -u)
USER_GID := $(shell id -g)
```

To use specific values, you can override them:

```bash
make build-rhel9 USER_UID=1001 USER_GID=1001
```

**Important**: Rebuild the container image after changing UID/GID values.

### Installing Optional Developer Tools

By default, containers include only essential packages (less, python3.12, sudo, vim, uv). You can install additional tool groups during build:

#### Available Tool Groups

1. **Development Tools** (`INSTALL_DEV_TOOLS=true`)
   - git, curl, wget, tar, unzip, zip
   - Use case: Version control and file downloads

2. **Build Tools** (`INSTALL_BUILD_TOOLS=true`)
   - gcc, gcc-c++, make, autoconf, automake, pkgconfig
   - Use case: Compiling C/C++ applications

3. **Network Tools** (`INSTALL_NET_TOOLS=true`)
   - jq, bind-utils, iproute, net-tools
   - Use case: Network debugging and JSON processing

#### Usage Examples

Install development tools:

```bash
make build-rhel9 INSTALL_DEV_TOOLS=true
```

Install multiple tool groups:

```bash
make build-rhel9 INSTALL_DEV_TOOLS=true INSTALL_BUILD_TOOLS=true
```

Install all optional tools:

```bash
make build-rhel9 INSTALL_DEV_TOOLS=true INSTALL_BUILD_TOOLS=true INSTALL_NET_TOOLS=true
```

Set as defaults in Makefile (lines 17-20):

```makefile
INSTALL_DEV_TOOLS ?= true
INSTALL_BUILD_TOOLS ?= true
INSTALL_NET_TOOLS ?= false
```

**Note**: Each tool group increases the container image size. Only install what you need.

### Why UID/GID Matter

Matching the container user's UID/GID with your host user prevents permission issues:

- ✅ **With matching UID/GID**: Files created in the container are owned by you on the host
- ❌ **Without matching UID/GID**: Files may be owned by root or unknown users, causing permission errors

## Container Runtime Selection

The Makefile automatically detects and uses the available container runtime:

1. **Docker** (preferred if available)
2. **Podman** (fallback)

To force a specific runtime:

```bash
make build-rhel9 CONTAINER_RUNTIME=podman
make run-rhel9 CONTAINER_RUNTIME=podman
```

## Project Structure

```bash
.
├── Makefile                # Build, run, and clean targets
├── RHEL8-Containerfile     # RHEL 8 container definition
├── RHEL9-Containerfile     # RHEL 9 container definition
├── RHEL10-Containerfile    # RHEL 10 container definition
└── README.md               # This file
```

## Common Use Cases

### Testing Python Applications

```bash
# Build the container
make build-rhel9

# Run and test your Python app
make run-rhel9

# Inside container:
cd ~/data
python3 --version
pip3 install -r requirements.txt
python3 your_app.py
```

### Testing Compiled Applications

```bash
make run-rhel9

# Inside container:
cd ~/data
gcc --version
gcc -o myapp myapp.c
./myapp
```

### Testing Across Multiple RHEL Versions

```bash
# Build all versions
make build-all

# Test on RHEL 8
make run-rhel8
# ... test your app ...
exit

# Test on RHEL 9
make run-rhel9
# ... test your app ...
exit

# Test on RHEL 10
make run-rhel10
# ... test your app ...
exit
```

## Troubleshooting

### Permission Denied Errors

If you get permission errors when accessing files:

1. Verify your UID/GID matches:

   ```bash
   # On host
   id

   # Inside container
   id
   ```

2. Rebuild with correct UID/GID:

   ```bash
   make clean-rhel9
   make build-rhel9
   ```

### Container Runtime Not Found

If you see `Neither docker nor podman found in PATH`:

1. Install Docker or Podman (see Prerequisites)
2. Ensure it's in your system PATH
3. On Linux, you may need to add your user to the docker group:

   ```bash
   sudo usermod -aG docker $USER
   # Log out and back in
   ```

### Base Image Not Found

If build fails with image not found:

1. Pull and tag the required UBI image (see Prerequisites)
2. Verify the image exists:

   ```bash
   docker images | grep ubi
   # or
   podman images | grep ubi
   ```

## Advanced Usage

### Installing Additional Packages

**Option 1: Use built-in tool groups** (recommended):

```bash
# Enable development, build, or network tools
make build-rhel9 INSTALL_DEV_TOOLS=true INSTALL_BUILD_TOOLS=true
```

See the "Installing Optional Developer Tools" section for available tool groups.

**Option 2: Manually edit Containerfiles** (for custom packages):

Edit the respective Containerfile (e.g., `RHEL9-Containerfile`) to add packages:

```dockerfile
RUN dnf install -y \
    python3 \
    python3-pip \
    gcc \
    make \
    your-package-here \
    && dnf clean all
```

Then rebuild:

```bash
make clean-rhel9
make build-rhel9
```

### Persisting Container Changes

To save changes made inside a container:

1. Keep the container running (don't exit)
2. In another terminal, commit the container:

   ```bash
   docker commit <container-id> localhost/ubi9/ubi-custom:latest
   # or
   podman commit <container-id> localhost/ubi9/ubi-custom:latest
   ```

### Running Without Auto-Remove

The default `make run-*` targets use `--rm` flag, which deletes the container on exit. To keep the container:

```bash
docker run -it -v $(pwd):/home/flash/data localhost/ubi9/ubi:latest
# or
podman run -it -v $(pwd):/home/flash/data localhost/ubi9/ubi:latest
```

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

## Contributing

Feel free to customize these Containerfiles and Makefile for your specific needs!
