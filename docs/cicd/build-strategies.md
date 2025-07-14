# Build Strategies

Optimize your application builds with various strategies supported by Hexabase.AI's CI/CD platform.

## Overview

Hexabase.AI supports multiple build strategies to optimize for speed, security, and resource efficiency. Choose the right strategy based on your application requirements.

## Container Build Strategies

### 1. Docker Build

Traditional Docker builds with optimization features:

```yaml
# .hexabase/pipeline.yml
stages:
  - name: build
    jobs:
      - name: docker-build
        type: docker
        config:
          dockerfile: ./Dockerfile
          context: .
          target: production  # Multi-stage build target
          buildArgs:
            - NODE_ENV=production
            - VERSION=${GIT_TAG}
          cache:
            - type: registry
              ref: myapp:buildcache
            - type: local
              path: /tmp/buildcache
```

### 2. Buildpack Build

Cloud Native Buildpacks for automatic containerization:

```yaml
stages:
  - name: build
    jobs:
      - name: buildpack-build
        type: buildpack
        config:
          builder: gcr.io/buildpacks/builder:v1
          env:
            - BP_NODE_VERSION=18.*
            - BP_NODE_RUN_SCRIPTS=build
          buildpacks:
            - paketo-buildpacks/nodejs
```

### 3. Kaniko Build

Daemon-less container builds for enhanced security:

```yaml
stages:
  - name: build
    jobs:
      - name: kaniko-build
        type: kaniko
        config:
          dockerfile: ./Dockerfile
          cache:
            enabled: true
            ttl: 168h  # 7 days
          registry:
            insecure: false
            mirror: registry-mirror.hexabase.ai
```

### 4. Source-to-Image (S2I)

Direct source code to container image:

```yaml
stages:
  - name: build
    jobs:
      - name: s2i-build
        type: s2i
        config:
          builderImage: registry.access.redhat.com/ubi8/nodejs-16
          scripts: .s2i/bin/
          incremental: true
```

## Multi-Architecture Builds

### Cross-Platform Support

Build for multiple architectures:

```yaml
stages:
  - name: build
    jobs:
      - name: multi-arch-build
        type: docker
        config:
          platforms:
            - linux/amd64
            - linux/arm64
            - linux/arm/v7
          push: true
```

## Caching Strategies

### 1. Layer Caching

Optimize Docker layer caching:

```dockerfile
# Dockerfile with optimized layers
FROM node:18-alpine AS dependencies
WORKDIR /app
# Cache dependencies
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
CMD ["node", "dist/index.js"]
```

### 2. Dependency Caching

```yaml
cache:
  paths:
    - node_modules/
    - .npm/
    - vendor/
    - .gradle/
  key: ${GIT_BRANCH}-${CHECKSUM("package-lock.json")}
  policy: pull-push
```

### 3. Build Cache Mounting

```yaml
stages:
  - name: build
    jobs:
      - name: cached-build
        volumes:
          - name: npm-cache
            path: /root/.npm
          - name: build-cache
            path: /app/.cache
```

## Parallel Build Strategies

### Matrix Builds

Test multiple versions simultaneously:

```yaml
stages:
  - name: build
    strategy:
      matrix:
        node: [14, 16, 18]
        os: [alpine, debian]
    jobs:
      - name: build-matrix
        image: node:${matrix.node}-${matrix.os}
        commands:
          - npm install
          - npm run build
```

### Monorepo Builds

Efficient monorepo build strategies:

```yaml
stages:
  - name: detect-changes
    jobs:
      - name: change-detection
        commands:
          - hb monorepo detect --base main
  
  - name: build
    jobs:
      - name: build-api
        when: changes.includes("packages/api")
        workdir: packages/api
        commands:
          - npm run build
      
      - name: build-web
        when: changes.includes("packages/web")
        workdir: packages/web
        commands:
          - npm run build
```

## Security-First Builds

### 1. Minimal Base Images

```dockerfile
# Use distroless for minimal attack surface
FROM gcr.io/distroless/nodejs18-debian11
COPY --from=build /app/dist /app
WORKDIR /app
CMD ["index.js"]
```

### 2. Build-Time Security Scanning

```yaml
stages:
  - name: build
    jobs:
      - name: secure-build
        commands:
          - docker build -t myapp:${GIT_COMMIT} .
          - trivy image myapp:${GIT_COMMIT}
          - snyk container test myapp:${GIT_COMMIT}
        failOn:
          - severity: high
          - cvss: 7.0
```

### 3. Signed Images

```yaml
stages:
  - name: sign
    jobs:
      - name: sign-image
        commands:
          - cosign sign --key cosign.key myapp:${GIT_COMMIT}
          - cosign verify --key cosign.pub myapp:${GIT_COMMIT}
```

## Optimization Techniques

### 1. Build Time Optimization

- **Use specific versions**: Pin all dependencies
- **Minimize layers**: Combine RUN commands
- **Order matters**: Put least-changing layers first
- **Clean as you go**: Remove temporary files

### 2. Size Optimization

```dockerfile
# Multi-stage build for size optimization
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o app

FROM scratch
COPY --from=builder /app/app /
CMD ["/app"]
```

### 3. Build Performance

```yaml
build:
  resources:
    cpu: 4
    memory: 8Gi
  parallel: true
  timeout: 30m
```

## Language-Specific Strategies

### Node.js

```yaml
build:
  type: node
  config:
    packageManager: npm  # or yarn, pnpm
    script: build
    prune: production
    cache:
      - .npm
      - node_modules
```

### Go

```yaml
build:
  type: go
  config:
    version: 1.21
    ldflags: "-s -w"
    env:
      - CGO_ENABLED=0
      - GOOS=linux
      - GOARCH=amd64
```

### Python

```yaml
build:
  type: python
  config:
    version: 3.11
    requirements: requirements.txt
    wheelhouse: true  # Pre-build wheels
```

### Java

```yaml
build:
  type: java
  config:
    version: 17
    tool: gradle  # or maven
    goals: [clean, build]
    cache:
      - .gradle
      - .m2
```

## Best Practices

1. **Choose the Right Strategy**
   - Docker for flexibility
   - Buildpacks for standardization
   - Kaniko for security
   - S2I for simplicity

2. **Optimize for Cache**
   - Structure Dockerfiles for layer reuse
   - Use cache mounts for dependencies
   - Implement smart cache invalidation

3. **Security Considerations**
   - Scan during build
   - Use minimal base images
   - Sign and verify images
   - Never include secrets in images

4. **Performance Tips**
   - Parallelize when possible
   - Use appropriate resource limits
   - Implement incremental builds
   - Monitor build metrics

## Monitoring Build Performance

```bash
# View build metrics
hb pipeline metrics --stage build

# Analyze build times
hb pipeline analyze --optimization-suggestions

# Set up alerts
hb alert create --metric build.duration --threshold 10m
```