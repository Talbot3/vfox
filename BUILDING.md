# Building VFox

This document provides instructions for building VFox from source.

## Prerequisites

- Go 1.21 or later
- Git

## Quick Build

```bash
git clone https://github.com/version-fox/vfox.git
cd vfox
make build
```

## Build Commands

### Using Make (Recommended)

```bash
# Production build (optimized)
make build

# Development build (with debug info)
make build-dev

# Clean build artifacts
make clean

# Run tests
make test

# Format code
make fmt

# Lint code
make lint

# Install to /usr/local/bin
make install

# Build release binaries for all platforms
make release
```

### Manual Build

```bash
# Standard build
CGO_ENABLED=0 go build -o vfox main.go

# With optimization flags (smaller binary)
CGO_ENABLED=0 go build -ldflags="-s -w" -o vfox main.go
```

## Important Notes

### CGO_ENABLED=0

VFox is built with `CGO_ENABLED=0` to:

1. **Avoid macOS LC_UUID issues**: Prevents "dyld: missing LC_UUID load command" errors on macOS
2. **Produce static binaries**: No external C dependencies
3. **Smaller executables**: Reduces binary size
4. **Faster builds**: No C compilation step
5. **Better portability**: Binaries work across more systems

### Platform Support

VFox supports the following platforms:

- **Linux**: amd64, arm64, 386, arm, loong64
- **macOS**: amd64, arm64 (Apple Silicon)
- **Windows**: amd64, 386

## Development Setup

```bash
# Clone the repository
git clone https://github.com/version-fox/vfox.git
cd vfox

# Install dependencies
make deps

# Run tests
make test

# Build for development
make build-dev

# Run locally
./vfox --version
```

## Troubleshooting

### macOS Build Issues

If you encounter "dyld: missing LC_UUID load command" error:

```bash
# Use the Makefile (recommended)
make build

# Or manually set CGO_ENABLED
CGO_ENABLED=0 go build -o vfox main.go
```

### Permission Issues

If you get permission errors when installing:

```bash
# Use sudo
sudo make install

# Or install to user directory
mkdir -p ~/bin
cp vfox ~/bin/
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc  # or ~/.bashrc
```

### Clean Build

If you have build issues, try a clean build:

```bash
make clean
go clean -cache
make build
```

## Contributing

When contributing to VFox:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting:
   ```bash
   make test
   make fmt
   make lint
   ```
5. Submit a pull request

## Release Build

To build release binaries for all platforms:

```bash
# Using Make
make release

# Or using GoReleaser
goreleaser release --snapshot
```

This will create binaries in the `dist/` directory for all supported platforms.