# Multi-Architecture Docker Images Repository

This repository provides a flexible GitHub Actions workflow for building custom Docker images across multiple architectures (x86, x86_64, ARM32, ARM64). Perfect for creating base images for projects that need specific architecture support or aren't publicly available.

PS : This repository are largely built using LLM so expect failures here and there

## 🏗️ Supported Architectures

- **linux/amd64** (x86_64) - Standard 64-bit Intel/AMD
- **linux/arm64** (ARM64) - Apple Silicon, AWS Graviton, etc.
- **linux/arm/v7** (ARM32) - Raspberry Pi, embedded devices
- **linux/386** (x86) - Legacy 32-bit Intel

## 🚀 Quick Start

### Method 1: Manual Build (Workflow Dispatch)

1. Go to **Actions** tab in your repository
2. Select **Multi-Architecture Docker Image Builder**
3. Click **Run workflow**
4. Fill in the parameters:
   - **Image name**: `my-custom-image`
   - **Dockerfile path**: `./Dockerfile` or `./examples/Dockerfile.flutter-arm64`
   - **Architectures**: Select from dropdown
   - **Build context**: `.` (usually)
   - **Registry**: `docker.io` or `ghcr.io`
   - **Push to registry**: `true`
   - **Tag latest**: `true`

### Method 2: Branch-Based Automatic Builds

Create branches with specific patterns to trigger automatic builds:

```bash
# Create a branch for Flutter ARM64 builds
git checkout -b build/flutter-arm64
# or
git checkout -b flavors/flutter-arm64

# Add your Dockerfile
cp examples/Dockerfile.flutter-arm64 ./Dockerfile.flutter-arm64

# Commit and push
git add .
git commit -m "Add Flutter ARM64 Dockerfile"
git push origin build/flutter-arm64
```

The workflow will automatically:
- Detect the branch pattern
- Find corresponding Dockerfiles
- Determine target architecture from filename/branch name
- Build and push the image

## 📁 Directory Structure

```
.
├── Dockerfile                              # Default multi-arch base image
├── examples/
│   ├── Dockerfile.flutter-arm64           # Flutter for ARM64
│   ├── Dockerfile.nodejs-arm32            # Node.js for ARM32
│   └── Dockerfile.python-x86              # Python for x86
├── .github/
│   └── workflows/
│       └── docker-images.yml              # Main workflow
└── README.md
```

## 🏷️ Naming Conventions

### Branch Naming
- `build/<flavor>` - e.g., `build/flutter-arm64`
- `flavors/<flavor>` - e.g., `flavors/nodejs-arm32`

### Dockerfile Naming
- `Dockerfile` - Default base image
- `Dockerfile.<name>` - e.g., `Dockerfile.flutter-arm64`
- `Dockerfile.<name>-<arch>` - e.g., `Dockerfile.nodejs-arm32`

### Image Tagging
Images are automatically tagged with:
- `latest` (for main branch)
- `<branch-name>` (for feature branches)
- `<branch-name>-<commit-sha>`
- `<git-tag>` (for tagged releases)

## 🔧 Workflow Features

### Architecture Detection
The workflow automatically detects target architectures based on:
1. Manual selection (workflow_dispatch)
2. Branch name patterns (`*arm64*`, `*arm32*`, `*x86*`, etc.)
3. Dockerfile name patterns
4. Default to multi-arch (`linux/amd64,linux/arm64`)

### Smart Change Detection
- Only builds when relevant files change (Dockerfiles, dependencies)
- Manual triggers always build
- Supports multiple Dockerfiles per branch

### Registry Support
- **Docker Hub**: `docker.io` (requires `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets)
- **GitHub Container Registry**: `ghcr.io` (uses `GITHUB_TOKEN` automatically)

### Caching
- Uses GitHub Actions cache for faster builds
- Layer caching across builds
- QEMU setup for cross-platform builds

## 📋 Examples

### Example 1: Flutter ARM64 Development Image

```bash
# Create branch
git checkout -b build/flutter-arm64

# Use example Dockerfile
cp examples/Dockerfile.flutter-arm64 ./Dockerfile

# Commit and push
git add Dockerfile
git commit -m "Add Flutter ARM64 image"
git push origin build/flutter-arm64
```

Result: `yourusername/flutter-arm64:latest` built for `linux/arm64`

### Example 2: Multi-Architecture Node.js

**Manual workflow dispatch:**
- Image name: `nodejs-multi`
- Dockerfile path: `./examples/Dockerfile.nodejs-arm32`
- Architectures: `linux/amd64,linux/arm64,linux/arm/v7`

Result: `yourusername/nodejs-multi:latest` built for all three architectures

### Example 3: Custom Python x86

```bash
# Create custom branch
git checkout -b flavors/python-legacy

# Create custom Dockerfile
cat > Dockerfile.python-legacy << EOF
FROM python:3.8-slim
# ... your custom configuration
EOF

# Push
git add .
git commit -m "Add legacy Python image"
git push origin flavors/python-legacy
```

Result: `yourusername/python-legacy:python-legacy` built for `linux/386`

## ⚙️ Configuration

### Required Secrets

For Docker Hub:
```
DOCKERHUB_USERNAME=your-dockerhub-username
DOCKERHUB_TOKEN=your-dockerhub-access-token
```

For GitHub Container Registry:
- No additional secrets needed (uses `GITHUB_TOKEN`)

### Workflow Inputs (Manual Trigger)

| Input | Description | Default | Options |
|-------|-------------|---------|---------|
| `image_name` | Image name without registry prefix | `custom-base` | Any string |
| `dockerfile_path` | Path to Dockerfile | `./Dockerfile` | Any valid path |
| `architectures` | Target architectures | `linux/amd64,linux/arm64` | See dropdown options |
| `build_context` | Build context path | `.` | Any directory |
| `registry` | Container registry | `docker.io` | `docker.io`, `ghcr.io` |
| `push_to_registry` | Whether to push | `true` | `true`, `false` |
| `tag_latest` | Tag as latest | `true` | `true`, `false` |

## 🔍 Troubleshooting

### Build Fails for Specific Architecture
- Check if the base image supports the target architecture
- Verify QEMU emulation is working
- Some packages may not be available for all architectures

### Image Not Found
- Verify registry credentials are correct
- Check image name doesn't contain invalid characters
- Ensure push_to_registry is set to true

### Slow Builds
- ARM32/ARM64 builds are slower due to emulation
- Use layer caching effectively
- Consider building on native runners for ARM architectures

## 🎯 Best Practices

1. **Use multi-stage builds** to reduce image size
2. **Pin base image versions** for reproducibility
3. **Include health checks** in your Dockerfiles
4. **Use .dockerignore** to exclude unnecessary files
5. **Test images locally** before pushing to branches
6. **Use semantic versioning** for tags
7. **Document architecture-specific quirks** in Dockerfiles

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Add your Dockerfile to the appropriate location
4. Test the build locally
5. Commit and push: `git commit -am 'Add my feature'`
6. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Useful Links

- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Buildx](https://docs.docker.com/buildx/)
- [QEMU User Emulation](https://www.qemu.org/docs/master/user/main.html)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)