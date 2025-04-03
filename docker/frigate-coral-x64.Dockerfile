name: Build and Push Frigate to GHCR

on:
  push:
    branches:
      - dev

env:
  IMAGE_NAME: frigate

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      packages: write
      contents: read

    steps:
      - name: Checkout full repository
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Show runner architecture and base info
        run: |
          echo "GitHub runner platform:"
          uname -a
          cat /etc/os-release

      - name: Debug: List contents of frigate/
        run: |
          echo "== Contents of frigate/ =="
          ls -alh frigate/
          echo ""
          echo "== Contents of frigate/config/camera/ =="
          ls -alh frigate/config/camera/ || true

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ secrets.GHCR_USERNAME }}
          password: ${{ secrets.CR_PAT }}

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Extract short commit SHA
        run: echo "COMMIT_SHA=$(git rev-parse --short HEAD)" | tee -a $GITHUB_ENV

      - name: Build and push Frigate image (debug enabled)
        uses: docker/build-push-action@v5
        with:
          context: .
          file: docker/frigate-coral-x64.Dockerfile
          platforms: linux/amd64
          push: true
          no-cache: true
          provenance: false
          sbom: false
          outputs: type=registry
          build-args: |
            PROGRESS=plain
          secrets: |
            "GITHUB_TOKEN=${{ secrets.GITHUB_TOKEN }}"
          tags: |
            ghcr.io/${{ secrets.GHCR_USERNAME }}/${{ env.IMAGE_NAME }}:0.16-dev
            ghcr.io/${{ secrets.GHCR_USERNAME }}/${{ env.IMAGE_NAME }}:0.16-dev-${{ env.COMMIT_SHA }}
            ghcr.io/${{ secrets.GHCR_USERNAME }}/${{ env.IMAGE_NAME }}:latest
