# CoCo Agent Docker Image — GitHub Actions variant
# Same as gitlab-ext-agents/Dockerfile but with gh CLI instead of glab.
#
# Build:  docker build -t <registry>/cortex-code-agent:latest .
# Push:   docker push <registry>/cortex-code-agent:latest

FROM ubuntu:24.04

# ── System dependencies ──────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
  curl \
  perl \
  git \
  build-essential \
  python3-dev \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# ── uv (fast Python toolchain) ───────────────────────────────────────────────
RUN curl -LsSf https://astral.sh/uv/0.7.12/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# ── gh (GitHub CLI — used to create issues, PRs, and post comments) ──────────
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt-get update && apt-get install -y gh \
  && rm -rf /var/lib/apt/lists/*

# ── Cortex Code CLI ───────────────────────────────────────────────────────────
# SKIP_PODMAN=1       — no container-in-container needed in CI
# NON_INTERACTIVE=1   — suppress all prompts during install
# CLI_CACHE_BUST      — bump this date to force a reinstall on next build
ARG CLI_CACHE_BUST=2026-06-16
RUN curl -LsS https://ai.snowflake.com/static/cc-scripts/install.sh -o /tmp/install.sh \
  && SKIP_PODMAN=1 NON_INTERACTIVE=1 sh /tmp/install.sh \
  && rm /tmp/install.sh

# ── Verify install ────────────────────────────────────────────────────────────
RUN cortex --version

WORKDIR /workspace
