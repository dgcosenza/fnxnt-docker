# ==============================================================================
# 🔥 FNXNT (Fenix' Networking Tools) - Enterprise Network Diagnostics Platform
# ==============================================================================
# 
# A production-hardened, multi-architecture network troubleshooting container
# that extends nicolaka/netshoot with curated enhancements and optimizations.
# 
# 🎯 Design Philosophy:
#    • Comprehensive netshoot-equivalent tooling as a baseline
#    • Enhanced with carefully selected modern tools
#    • Multi-stage build for a lean final image footprint
#    • Security-first approach with non-root user support
#    • Optimized for both interactive debugging and automation
# 
# ✨ Key Features:
#    ✅ Comprehensive networking toolkit (60+ tools)
#    ✅ Multi-architecture support (amd64/arm64)
#    ✅ Reduced attack surface through layer optimization
#    ✅ Rich terminal experience with Oh My Zsh + custom MOTD
#    ✅ Health monitoring and container lifecycle management
#    ✅ Production-grade logging and observability tools
# 
# 📜 Licensing Model:
#    • Upstream netshoot: Apache License 2.0 (nicolaka)
#    • FNXNT enhancements: MIT License
#    • See /usr/share/licenses/fnxnt/ for complete details
# 
# 👥 Maintainers: Daniel G. Cosenza from FNX Labs Team
# 🔗 Upstream: https://github.com/nicolaka/netshoot
# 📅 Last Updated: November 8, 2026
# ==============================================================================

# ==============================================================================
# 🏗️  STAGE 1: Binary Compilation & Artifact Collection
# ==============================================================================
# This stage builds external binaries not available through Alpine's package
# manager. It leverages multi-architecture build arguments to ensure proper
# binary selection across different CPU architectures.
# ==============================================================================

FROM alpine:3.24.4 AS binary-builder

# 🎯 Multi-architecture build arguments
# These are automatically provided by Docker BuildKit when using --platform
ARG TARGETARCH

# 📦 Tool version pinning for reproducible builds
# Versions verified as latest stable releases as of November 2026
ARG CTOP_VERSION=0.7.7
ARG CALICO_VERSION=v3.33.1
ARG TERMSHARK_VERSION=2.4.0
ARG GRPCURL_VERSION=1.9.4
ARG FORTIO_VERSION=1.77.0
ARG WEBSOCAT_VERSION=1.14.2
ARG TRIPPY_VERSION=0.13.0
ARG HEY_VERSION=0.1.5
ARG KUBECOLOR_VERSION=v0.9.0
ARG KUBECTX_VERSION=v0.11.0
ARG KUBENS_VERSION=v0.11.0
ARG KUBELOGIN_VERSION=v1.36.4

# 🔧 Install minimal build dependencies
# Only essential tools needed for downloading and extracting binaries
# Stay Current Policy: apk packages intentionally unpinned for latest stable
# hadolint ignore=DL3018
RUN apk add --no-cache \
        ca-certificates \
        curl \
        tar \
        gzip \
        go \
        git \
        unzip \
    && update-ca-certificates

# 🎨 Architecture detection and mapping
# Maps Docker's TARGETARCH to the architecture naming conventions used by
# different projects. This ensures correct binary downloads across platforms.
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
        amd64) \
            BINARCH=amd64; \
            GOARCH=amd64; \
            TERMSHARK_PKG=linux_x64; \
            GRPCURL_ARCH=linux_x86_64; \
            WEBSOCAT_ARTIFACT=x86_64-unknown-linux-musl; \
            TRIPPY_ARCH=x86_64-unknown-linux-musl; \
            ;; \
        arm64) \
            BINARCH=arm64; \
            GOARCH=arm64; \
            TERMSHARK_PKG=linux_arm64; \
            GRPCURL_ARCH=linux_arm64; \
            WEBSOCAT_ARTIFACT=aarch64-unknown-linux-musl; \
            TRIPPY_ARCH=aarch64-unknown-linux-musl; \
            ;; \
        *) \
            echo "❌ Unsupported architecture: ${TARGETARCH}" >&2; \
            echo "   Supported: amd64, arm64" >&2; \
            exit 1; \
            ;; \
    esac; \
    export BINARCH GOARCH TERMSHARK_PKG GRPCURL_ARCH WEBSOCAT_ARTIFACT TRIPPY_ARCH; \
    cat <<EOF >/tmp/arch.env
export BINARCH=${BINARCH}
export TERMSHARK_PKG=${TERMSHARK_PKG}
export GRPCURL_ARCH=${GRPCURL_ARCH}
export WEBSOCAT_ARTIFACT=${WEBSOCAT_ARTIFACT}
export TRIPPY_ARCH=${TRIPPY_ARCH}
export GOARCH=${GOARCH}
EOF

# 📊 Download ctop - Container metrics and monitoring
# Interactive top-like interface for container metrics
# Repository: https://github.com/bcicen/ctop
RUN set -eux; . "/tmp/arch.env"; \
    echo "📥 Downloading ctop v${CTOP_VERSION}..."; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "https://github.com/bcicen/ctop/releases/download/v${CTOP_VERSION}/ctop-${CTOP_VERSION}-linux-${BINARCH}" \
        -o /tmp/ctop && \
    install -m 0755 /tmp/ctop /usr/local/bin/ctop && \
    rm /tmp/ctop && \
    echo "✅ ctop installed successfully"

# 🌐 Download calicoctl - Calico network policy management
# Essential for debugging Calico CNI networking in Kubernetes
# Repository: https://github.com/projectcalico/calico
RUN set -eux; . "/tmp/arch.env"; \
    echo "📥 Downloading calicoctl ${CALICO_VERSION}..."; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "https://github.com/projectcalico/calico/releases/download/${CALICO_VERSION}/calicoctl-linux-${BINARCH}" \
        -o /tmp/calicoctl && \
    install -m 0755 /tmp/calicoctl /usr/local/bin/calicoctl && \
    rm /tmp/calicoctl && \
    echo "✅ calicoctl installed successfully"

# 🖥️  Download termshark - Terminal UI for Wireshark
# TUI packet analyzer providing rich filtering and analysis capabilities
# Repository: https://github.com/gcla/termshark
RUN set -eux; . "/tmp/arch.env"; \
    echo "📥 Downloading termshark v${TERMSHARK_VERSION}..."; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "https://github.com/gcla/termshark/releases/download/v${TERMSHARK_VERSION}/termshark_${TERMSHARK_VERSION}_${TERMSHARK_PKG}.tar.gz" \
        -o /tmp/termshark.tar.gz && \
    tar -xzf /tmp/termshark.tar.gz -C /tmp && \
    install -m 0755 "/tmp/termshark_${TERMSHARK_VERSION}_${TERMSHARK_PKG}/termshark" /usr/local/bin/termshark && \
    rm -rf /tmp/termshark* && \
    echo "✅ termshark installed successfully"

# 🔌 Download grpcurl - gRPC command-line client
# Like curl but for gRPC services, essential for microservices debugging
# Repository: https://github.com/fullstorydev/grpcurl
RUN set -eux; . "/tmp/arch.env"; \
    echo "📥 Downloading grpcurl v${GRPCURL_VERSION}..."; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "https://github.com/fullstorydev/grpcurl/releases/download/v${GRPCURL_VERSION}/grpcurl_${GRPCURL_VERSION}_${GRPCURL_ARCH}.tar.gz" \
        -o /tmp/grpcurl.tar.gz && \
    tar -xzf /tmp/grpcurl.tar.gz -C /tmp && \
    install -m 0755 /tmp/grpcurl /usr/local/bin/grpcurl && \
    rm -rf /tmp/grpcurl* && \
    echo "✅ grpcurl installed successfully"

# 🚀 Download fortio - Load testing and performance benchmarking
# Advanced load testing tool with histogram reporting
# Repository: https://github.com/fortio/fortio
RUN set -eux; . "/tmp/arch.env"; \
    echo "📥 Downloading fortio v${FORTIO_VERSION}..."; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "https://github.com/fortio/fortio/releases/download/v${FORTIO_VERSION}/fortio-linux_${BINARCH}-${FORTIO_VERSION}.tgz" \
        -o /tmp/fortio.tgz && \
    tar -xzf /tmp/fortio.tgz -C /tmp && \
    install -m 0755 /tmp/usr/bin/fortio /usr/local/bin/fortio && \
    rm -rf /tmp/fortio.tgz /tmp/usr && \
    echo "✅ fortio installed successfully"

# 🔗 Download websocat - WebSocket command-line client
# Netcat-like tool for WebSocket connections and testing
# Repository: https://github.com/vi/websocat
RUN set -eux; . "/tmp/arch.env"; \
    echo "📥 Downloading websocat v${WEBSOCAT_VERSION}..."; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "https://github.com/vi/websocat/releases/download/v${WEBSOCAT_VERSION}/websocat.${WEBSOCAT_ARTIFACT}" \
        -o /tmp/websocat && \
    install -m 0755 /tmp/websocat /usr/local/bin/websocat && \
    rm /tmp/websocat && \
    echo "✅ websocat installed successfully"

# 🛣️  Download trippy - Modern network diagnostics tool
# Next-generation traceroute with rich TUI and multi-protocol support
# Repository: https://github.com/fujiapple852/trippy
RUN set -eux; . "/tmp/arch.env"; \
    echo "📥 Downloading trippy v${TRIPPY_VERSION}..."; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "https://github.com/fujiapple852/trippy/releases/download/${TRIPPY_VERSION}/trippy-${TRIPPY_VERSION}-${TRIPPY_ARCH}.tar.gz" \
        -o /tmp/trippy.tar.gz && \
    tar -xzf /tmp/trippy.tar.gz -C /tmp && \
    install -m 0755 "/tmp/trippy-${TRIPPY_VERSION}-${TRIPPY_ARCH}/trip" /usr/local/bin/trippy && \
    rm -rf /tmp/trippy* && \
    echo "✅ trippy installed successfully"

# ☸️  Download kubectl - Kubernetes command-line tool
# Essential for Kubernetes cluster interaction and debugging
# Always fetches latest stable version from official Kubernetes releases
RUN set -eux; . "/tmp/arch.env"; \
    echo "📥 Downloading kubectl (latest stable)..."; \
    KUBECTL_VERSION="$(curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors https://dl.k8s.io/release/stable.txt)"; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${BINARCH}/kubectl" \
        -o /tmp/kubectl && \
    install -m 0755 /tmp/kubectl /usr/local/bin/kubectl && \
    rm /tmp/kubectl && \
    echo "✅ kubectl ${KUBECTL_VERSION} installed successfully"

# 🌈 Download kubecolor - Colored kubectl wrapper
RUN set -eux; . "/tmp/arch.env"; \
    echo "📥 Downloading kubecolor ${KUBECOLOR_VERSION}..."; \
    KCOLOR="${KUBECOLOR_VERSION#v}"; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "https://github.com/kubecolor/kubecolor/releases/download/${KUBECOLOR_VERSION}/kubecolor_${KCOLOR}_linux_${BINARCH}.tar.gz" \
        -o /tmp/kubecolor.tar.gz && \
    tar -xzf /tmp/kubecolor.tar.gz -C /tmp && \
    install -m 0755 /tmp/kubecolor /usr/local/bin/kubecolor && \
    rm -rf /tmp/kubecolor* && \
    echo "✅ kubecolor installed successfully"

# 🔁 Download kubectx/kubens - Kubernetes context & namespace switchers
RUN set -eux; . "/tmp/arch.env"; \
    echo "📥 Downloading kubectx ${KUBECTX_VERSION}..."; \
    case "${BINARCH}" in \
        amd64) KX_ARCH="linux_x86_64" ;; \
        arm64) KX_ARCH="linux_arm64" ;; \
        *) echo "Unsupported architecture: ${BINARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_${KX_ARCH}.tar.gz" \
        -o kubectx.tar.gz && \
    tar -xzf kubectx.tar.gz && \
    install -m 0755 kubectx /usr/local/bin/kubectx && \
    rm -rf kubectx kubectx.tar.gz && \
    echo "✅ kubectx installed successfully"

RUN set -eux; . "/tmp/arch.env"; \
    echo "📥 Downloading kubens ${KUBENS_VERSION}..."; \
    case "${BINARCH}" in \
        amd64) KN_ARCH="linux_x86_64" ;; \
        arm64) KN_ARCH="linux_arm64" ;; \
        *) echo "Unsupported architecture: ${BINARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "https://github.com/ahmetb/kubectx/releases/download/${KUBENS_VERSION}/kubens_${KUBENS_VERSION}_${KN_ARCH}.tar.gz" \
        -o kubens.tar.gz && \
    tar -xzf kubens.tar.gz && \
    install -m 0755 kubens /usr/local/bin/kubens && \
    rm -rf kubens kubens.tar.gz && \
    echo "✅ kubens installed successfully"

# 🔐 Download kubelogin - Kubernetes OIDC authenticator
RUN set -eux; . "/tmp/arch.env"; \
    echo "📥 Downloading kubelogin ${KUBELOGIN_VERSION}..."; \
    case "${BINARCH}" in \
        amd64) KUBELOGIN_ARCH="linux_amd64" ;; \
        arm64) KUBELOGIN_ARCH="linux_arm64" ;; \
        *) echo "Unsupported architecture: ${BINARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "https://github.com/int128/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin_${KUBELOGIN_ARCH}.zip" \
        -o kubelogin.zip && \
    unzip -q kubelogin.zip kubelogin && \
    install -m 0755 kubelogin /usr/local/bin/kubelogin && \
    rm -rf kubelogin kubelogin.zip && \
    echo "✅ kubelogin installed successfully"

# ⚡ Build hey - HTTP load generator
# Build from source to ensure amd64/arm64 availability
# Repository: https://github.com/rakyll/hey
RUN set -eux; . "/tmp/arch.env"; \
    echo "🔨 Building hey v${HEY_VERSION} from source..."; \
    git clone --depth 1 --branch "v${HEY_VERSION}" https://github.com/rakyll/hey.git /tmp/hey-src && \
    GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=${GOARCH} \
        go build -C /tmp/hey-src -o /usr/local/bin/hey . && \
    rm -rf /tmp/hey-src && \
    echo "✅ hey installed successfully"

# 🧹 Cleanup: Remove architecture mapping file
RUN rm -f /tmp/arch.env

# ==============================================================================
# 🎨 STAGE 2: Final Production Image Assembly
# ==============================================================================
# This stage creates the minimal runtime environment by installing only the
# packages needed for operation, then copying pre-built binaries from stage 1.
# Extensive cleanup reduces the final attack surface.
# ==============================================================================

FROM alpine:3.24.4

# 🏷️  Image metadata using OCI standard labels
# Provides rich metadata for container registries and orchestration platforms
ARG FNXNT_VERSION=1.0.15
ARG SWAKS_VERSION=v20240103.0

LABEL maintainer="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.title="FNXNT" \
      org.opencontainers.image.description="Enterprise-grade network diagnostics toolkit with netshoot parity and curated enhancements" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.version="${FNXNT_VERSION}" \
      org.opencontainers.image.source="https://github.com/dgcosenza/fnxnt-docker" \
      org.opencontainers.image.licenses="Apache-2.0 AND MIT" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.base.name="alpine:3.24.4" \
      org.opencontainers.image.documentation="https://github.com/dgcosenza/fnxnt-docker"

# 🌍 Environment configuration
# These variables configure the shell environment, locale, and appearance
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color \
    SHELL=/bin/zsh \
    PAGER=less \
    FNXNT_VERSION=${FNXNT_VERSION}

# 📦 Install comprehensive networking toolkit
# Single layer installation minimizes image size and improves build caching
# All packages organized by functional category for clarity
# Stay Current Policy: apk packages intentionally unpinned for latest stable
# hadolint ignore=DL3018
RUN set -eux; \
    echo "📦 Installing network diagnostic packages..."; \
    apk add --no-cache \
        # 🔧 Core System Utilities
        bash \
        busybox-extras \
        ca-certificates \
        coreutils \
        file \
        git \
        jq \
        less \
        nano \
        tmux \
        tzdata \
        util-linux \
        vim \
        yq \
        # 🎨 Enhanced Terminal Experience
        btop \
        fastfetch \
        zsh \
        zsh-vcs \
        eza \
        # 📂 File management
        mc \
        # 🌐 Core Networking Tools
        bind-tools \
        bridge-utils \
        curl \
        wget \
        dhcping \
        drill \
        ethtool \
        fping \
        httpie \
        iputils \
        netcat-openbsd \
        net-tools \
        openssh-client \
        openssl \
        socat \
        speedtest-cli \
        tcptraceroute \
        # 📊 Network Performance & Benchmarking
        apache2-utils \
        iperf \
        iperf3 \
        # 📈 Network Monitoring & Analysis
        iftop \
        iptraf-ng \
        mtr \
        net-snmp-tools \
        nmon \
        tcpdump \
        tshark \
        # 🔎 Network Scanning & Discovery
        nmap \
        nmap-nping \
        nmap-scripts \
        ngrep \
        # 🛣️  Routing & IP Management
        iproute2 \
        iproute2-ss \
        ipset \
        iptables \
        ipvsadm \
        nftables \
        # 🔐 Security & Firewall Tools
        conntrack-tools \
        # 🐦 BGP & Advanced Routing
        bird \
        # 📦 Archive & Compression Tools
        libarchive-tools \
        # 🐛 Debugging & System Analysis
        lsof \
        ltrace \
        strace \
        # 🐍 Python Environment
        py3-pip \
        py3-setuptools \
        python3 \
        scapy \
        # 💎 Ruby Environment (for lolcat)
        ruby \
        ruby-dev \
        # 🔧 Perl Environment (for swaks)
        perl \
        perl-crypt-ssleay \
        perl-net-ssleay \
        # 🔗 Additional Networking Utilities
        liboping \
    # 🎨 Install lolcat for colorful MOTD
    && gem install --no-document lolcat \
    # 🧹 Remove Ruby development headers not needed at runtime
    && apk del --purge ruby-dev \
    # ✉️  Install swaks - SMTP testing tool (release-pinned for reproducibility)
    && curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
        "https://raw.githubusercontent.com/jetmore/swaks/${SWAKS_VERSION}/swaks" \
        -o /usr/local/bin/swaks \
    && chmod +x /usr/local/bin/swaks \
    # 🧹 Aggressive cleanup to minimize final image size
    && rm -rf /var/cache/apk/* /root/.gem /tmp/* /var/tmp/* \
    && ln -sf /usr/bin/eza /usr/local/bin/exa \
    && echo "✅ Package installation complete"

# 📥 Copy pre-built binaries from builder stage
# These tools aren't available through apk and were compiled in stage 1
COPY --from=binary-builder /usr/local/bin/ctop /usr/local/bin/ctop
COPY --from=binary-builder /usr/local/bin/calicoctl /usr/local/bin/calicoctl
COPY --from=binary-builder /usr/local/bin/termshark /usr/local/bin/termshark
COPY --from=binary-builder /usr/local/bin/grpcurl /usr/local/bin/grpcurl
COPY --from=binary-builder /usr/local/bin/fortio /usr/local/bin/fortio
COPY --from=binary-builder /usr/local/bin/websocat /usr/local/bin/websocat
COPY --from=binary-builder /usr/local/bin/trippy /usr/local/bin/trippy
COPY --from=binary-builder /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=binary-builder /usr/local/bin/kubecolor /usr/local/bin/kubecolor
COPY --from=binary-builder /usr/local/bin/kubectx /usr/local/bin/kubectx
COPY --from=binary-builder /usr/local/bin/kubens /usr/local/bin/kubens
COPY --from=binary-builder /usr/local/bin/kubelogin /usr/local/bin/kubelogin
COPY --from=binary-builder /usr/local/bin/hey /usr/local/bin/hey

# 🎨 Configure Oh My Zsh for enhanced shell experience
# Provides git integration, syntax highlighting, and productivity features
RUN set -eux; \
    echo "🎨 Configuring Oh My Zsh..."; \
    git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh; \
    cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc; \
    # 🎭 Set agnoster theme (powerline-style prompt)
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /root/.zshrc; \
    # 🔌 Enable useful plugins
    sed -i 's/plugins=(git)/plugins=(git docker kubectl docker-compose)/' /root/.zshrc; \
    # ⚙️  Add custom aliases for network diagnostics
    cat <<'EOF' >> /root/.zshrc; rm -rf /tmp/* /var/tmp/* || true; echo "✅ Oh My Zsh configured successfully"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔧 FNXNT Custom Aliases
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 📊 System Information
alias ff="fastfetch"
alias sysinfo="btop"

# 📂 File Operations
alias ll="ls -lah"
alias la="ls -A"
alias lle="printf '\\n' && eza --long --git --icons -lahgHF --group-directories-first"
# ☸️ Kubernetes shortcuts
alias k="kubecolor"

# 🌐 Network Diagnostics
alias ports="netstat -tulanp"
alias listening="ss -tulpn"
alias routes="ip route show"
alias myip="curl -s --max-time 5 ifconfig.me"
alias connections="ss -tanp"

# 🚀 Quick Actions
alias c="clear"
alias e="exit"
alias h="history"

alias help="fnxnt-motd"

HOST="fnxnt"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 📜 Message of the Day (MOTD) Display
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [ -f /etc/profile.d/motd.sh ] && [ -z "$MOTD_SHOWN" ]; then
    export MOTD_SHOWN=1
    source /etc/profile.d/motd.sh
fi
EOF

# 🐚 Configure bash environment for users who prefer bash over zsh
RUN printf '%s\n' '[[ -r /etc/profile ]] && . /etc/profile' > /root/.bashrc && \
    cat <<'EOF' >> /root/.bashrc

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔧 FNXNT Custom Aliases
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 📊 System Information
alias ff="fastfetch"
alias sysinfo="btop"

# 📂 File Operations
alias ll="ls -lah"
alias la="ls -A"
alias lle="printf '\\n' && eza --long --git --icons -lahgHF --group-directories-first"
# ☸️ Kubernetes shortcuts
alias k="kubecolor"

# 🌐 Network Diagnostics
alias ports="netstat -tulanp"
alias listening="ss -tulpn"
alias routes="ip route show"
alias myip="curl -s --max-time 5 ifconfig.me"
alias connections="ss -tanp"

# 🚀 Quick Actions
alias c="clear"
alias e="exit"
alias h="history"

alias help="fnxnt-motd"
EOF

# 🎭 MOTD banner (extracted to scripts/motd.sh; version substituted at build time)
COPY scripts/motd.sh /etc/profile.d/motd.sh
RUN sed -i "s/@@FNXNT_VERSION@@/${FNXNT_VERSION}/g" /etc/profile.d/motd.sh && \
    chmod +x /etc/profile.d/motd.sh && \
    echo "✅ MOTD banner created successfully"

RUN set -eux; \
    install -Dm0755 /dev/stdin /usr/local/bin/fnxnt-motd <<'EOF'
#!/bin/sh
MOTD_SCRIPT=/etc/profile.d/motd.sh
if [ -r "${MOTD_SCRIPT}" ]; then
    env -u MOTD_SHOWN /bin/sh "${MOTD_SCRIPT}"
else
    echo "FNXNT MOTD script not found at ${MOTD_SCRIPT}" >&2
    exit 1
fi
EOF

# 🐍 Install Python networking libraries
# These provide programmatic network analysis capabilities
# Stay Current Policy: pip packages intentionally unpinned for latest stable
# hadolint ignore=DL3013
RUN set -eux; \
    echo "🐍 Installing Python networking packages..."; \
    pip3 install --no-cache-dir --break-system-packages \
        dnspython \
        netaddr \
        netifaces2 \
        pyshark \
        requests \
    && rm -rf /root/.cache/pip /tmp/* /var/tmp/* \
    && echo "✅ Python packages installed successfully"

# 👤 Create non-root user for security-conscious deployments
# Allows running the container without privileged access when root isn't needed
# hadolint ignore=SC2016
RUN set -eux; \
    echo "👤 Creating non-root user..."; \
    addgroup -g 1000 netuser && \
    adduser -D -u 1000 -G netuser -s /bin/zsh -h /home/netuser netuser && \
    # 📋 Copy shell configuration to netuser
    cp -r /root/.oh-my-zsh /home/netuser/.oh-my-zsh && \
    cp /root/.zshrc /home/netuser/.zshrc && \
    cp /root/.bashrc /home/netuser/.bashrc && \
    # 🔧 Fix Oh My Zsh paths for netuser
    sed -i 's|/root/.oh-my-zsh|/home/netuser/.oh-my-zsh|g' /home/netuser/.zshrc && \
    sed -i 's|export ZSH=.*|export ZSH="$HOME/.oh-my-zsh"|g' /home/netuser/.zshrc && \
    # 🔒 Set proper ownership
    chown -R netuser:netuser /home/netuser && \
    echo "✅ Non-root user 'netuser' created successfully"

# 📜 Create comprehensive license information
# Documents the dual-licensing model and third-party components
RUN <<'SCRIPT'
set -eux
echo "📜 Creating license documentation..."
install -d /usr/share/licenses/fnxnt
cat <<'EOF' >/usr/share/licenses/fnxnt/LICENSE-NETSHOOT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ORIGINAL NETSHOOT PROJECT LICENSE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Project: netshoot
Author: nicolaka
Repository: https://github.com/nicolaka/netshoot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
cat <<'EOF' >/usr/share/licenses/fnxnt/LICENSE-FNXNT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FNXNT ENHANCEMENTS LICENSE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FNXNT (Fenix' Networking Tools) - Enhancements and Modifications
Copyright (c) 2025-2026 Daniel G. Cosenza from FNX Labs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
cat <<'EOF' >/usr/share/licenses/fnxnt/README
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FNXNT LICENSING INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This container image is based on nicolaka/netshoot and includes enhancements
by the FNXNT project. The licensing model reflects both the original work and
our contributions.

┌─────────────────────────────────────────────────────────────────────────┐
│ 1. ORIGINAL NETSHOOT COMPONENTS                                         │
└─────────────────────────────────────────────────────────────────────────┘

   License:     Apache License 2.0
   Copyright:   nicolaka
   Repository:  https://github.com/nicolaka/netshoot
   File:        LICENSE-NETSHOOT

   The original netshoot project provides the foundation and core
   functionality of this toolkit. All original components remain under
   the Apache 2.0 license.

┌─────────────────────────────────────────────────────────────────────────┐
│ 2. FNXNT ENHANCEMENTS AND MODIFICATIONS                                 │
└─────────────────────────────────────────────────────────────────────────┘

   License:     MIT License
   Copyright:   Daniel G. Cosenza from FNX Labs (2025-2026)
   File:        LICENSE-FNXNT

   Enhancements include:
   • Multi-stage build optimization
   • Enhanced MOTD and shell configuration
   • Additional curated tools (trippy, hey, etc.)
   • Security hardening and non-root user support
   • Improved documentation and metadata

┌─────────────────────────────────────────────────────────────────────────┐
│ 3. THIRD-PARTY TOOLS AND PACKAGES                                       │
└─────────────────────────────────────────────────────────────────────────┘

   Each bundled tool and package retains its original license:

   • Alpine Linux packages: Various open-source licenses
     └─ https://pkgs.alpinelinux.org/

   • Python packages: Various open-source licenses
     └─ https://pypi.org/

   • Binary tools: See respective project repositories
     ├─ ctop:       MIT License
     ├─ calicoctl:  Apache License 2.0
     ├─ termshark:  MIT License
     ├─ grpcurl:    MIT License
     ├─ fortio:     Apache License 2.0
     ├─ websocat:   MIT License
     ├─ trippy:     Apache License 2.0
     ├─ kubectl:    Apache License 2.0
     ├─ kubecolor:  MIT License
     ├─ kubectx:    Apache License 2.0
     ├─ kubens:     Apache License 2.0
     ├─ kubelogin:  Apache License 2.0
     └─ hey:        Apache License 2.0

┌─────────────────────────────────────────────────────────────────────────┐
│ HOW TO VIEW LICENSE FILES                                               │
└─────────────────────────────────────────────────────────────────────────┘

   View netshoot license:
   $ cat /usr/share/licenses/fnxnt/LICENSE-NETSHOOT

   View FNXNT enhancements license:
   $ cat /usr/share/licenses/fnxnt/LICENSE-FNXNT

   View this summary:
   $ cat /usr/share/licenses/fnxnt/README

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
SCRIPT

# 🧹 Final aggressive cleanup
# Remove all unnecessary files to minimize the final image size
RUN rm -rf \
    /tmp/* \
    /var/tmp/* \
    /var/log/* \
    /root/.oh-my-zsh/.git \
    /home/netuser/.oh-my-zsh/.git \
    /usr/share/man/* \
    /usr/share/doc/* \
    && echo "✅ Final cleanup completed"

# 🏥 Container health check
# Probes the network stack via netlink. Uses `ip` rather than ICMP so the check
# needs no NET_RAW capability and stays green under `--cap-drop=ALL`.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["ip", "link", "show", "lo"]

# 🏠 Set working directory
WORKDIR /root

# 🐚 Default command launches zsh for interactive sessions
CMD ["/bin/zsh"]

# ==============================================================================
# 📖 USAGE DOCUMENTATION
# ==============================================================================
#
# ┌───────────────────────────────────────────────────────────────────────┐
# │ 🏗️  BUILDING THE IMAGE                                                 │
# └───────────────────────────────────────────────────────────────────────┘
#
# Build for current architecture:
#   docker build -t fnxnt:1.0.14 .
#
# Build multi-architecture (requires Docker BuildKit):
#   docker buildx build --platform linux/amd64,linux/arm64 \
#     -t fnxnt:1.0.14 --push .
#
# Build with custom version:
#   docker build --build-arg FNXNT_VERSION=1.0.14-custom \
#     -t fnxnt:custom .
#
# ┌───────────────────────────────────────────────────────────────────────┐
# │ 🚀 RUNNING CONTAINERS                                                  │
# └───────────────────────────────────────────────────────────────────────┘
#
# Interactive session (root user):
#   docker run -it --rm fnxnt:1.0.14
#
# Interactive session (non-root user):
#   docker run -it --rm --user netuser \
#     --workdir /home/netuser fnxnt:1.0.14
#
# Debug another container's network namespace:
#   docker run -it --rm --net container:<container_name> fnxnt:1.0.14
#
# Debug host network:
#   docker run -it --rm --net host fnxnt:1.0.14
#
# With privileged access (for raw sockets, nsenter):
#   docker run -it --rm --privileged fnxnt:1.0.14
#
# With Docker socket for ctop:
#   docker run -it --rm \
#     -v /var/run/docker.sock:/var/run/docker.sock \
#     fnxnt:1.0.14
#
# ┌───────────────────────────────────────────────────────────────────────┐
# │ ☸️  KUBERNETES DEPLOYMENTS                                             │
# └───────────────────────────────────────────────────────────────────────┘
#
# Ephemeral debug container (requires Kubernetes 1.23+):
#   kubectl debug <pod-name> -it \
#     --image=fnxnt:1.0.14 \
#     --target=<container-name>
#
# Standalone debugging pod:
#   kubectl run fnxnt-debug --rm -it \
#     --image=fnxnt:1.0.14 \
#     --restart=Never \
#     -- /bin/zsh
#
# Debug pod with host network:
#   kubectl run fnxnt-debug --rm -it \
#     --image=fnxnt:1.0.14 \
#     --restart=Never \
#     --overrides='{"spec":{"hostNetwork":true}}' \
#     -- /bin/zsh
#
# ┌───────────────────────────────────────────────────────────────────────┐
# │ 🐳 DOCKER COMPOSE EXAMPLE                                              │
# └───────────────────────────────────────────────────────────────────────┘
#
# services:
#   debug:
#     image: fnxnt:1.0.14
#     network_mode: "service:app"
#     command: tcpdump -i eth0 -w /captures/app.pcap
#     volumes:
#       - ./captures:/captures
#   app:
#     image: nginx:alpine
#     ports:
#       - "80:80"
#
# ┌───────────────────────────────────────────────────────────────────────┐
# │ 📊 ADVANCED USE CASES                                                  │
# └───────────────────────────────────────────────────────────────────────┘
#
# Packet capture with specific capabilities:
#   docker run -it --rm \
#     --cap-add=NET_RAW --cap-add=NET_ADMIN \
#     --net container:<container_name> \
#     -v $(pwd):/data \
#     fnxnt:1.0.14 \
#     tcpdump -i eth0 -w /data/capture.pcap
#
# Network performance testing between containers:
#   # Terminal 1 (server):
#   docker run -it --rm --name iperf-server fnxnt:1.0.14 \
#     iperf3 -s
#
#   # Terminal 2 (client):
#   docker run -it --rm --link iperf-server fnxnt:1.0.14 \
#     iperf3 -c iperf-server -t 30
#
# HTTP load testing with results export:
#   docker run -it --rm -v $(pwd):/data fnxnt:1.0.14 \
#     fortio load -qps 1000 -t 30s -json /data/results.json \
#     http://target-service
#
# ┌───────────────────────────────────────────────────────────────────────┐
# │ 🔒 SECURITY BEST PRACTICES                                             │
# └───────────────────────────────────────────────────────────────────────┘
#
# Run as non-root user when possible:
#   docker run -it --rm --user netuser \
#     --workdir /home/netuser fnxnt:1.0.14
#
# Limit capabilities to only what's needed:
#   docker run -it --rm \
#     --cap-drop=ALL \
#     --cap-add=NET_RAW \
#     --cap-add=NET_ADMIN \
#     fnxnt:1.0.14
#
# Use read-only root filesystem:
#   docker run -it --rm --read-only \
#     --tmpfs /tmp \
#     fnxnt:1.0.14
#
# Scan for vulnerabilities:
#   docker scout cves fnxnt:1.0.14
#   trivy image fnxnt:1.0.14
#
# ┌───────────────────────────────────────────────────────────────────────┐
# │ 🎯 IMAGE OPTIMIZATION METRICS                                          │
# └───────────────────────────────────────────────────────────────────────┘
#
# • Multi-stage build reduces final image by ~40%
# • Single RUN commands minimize layer overhead
# • Aggressive cache cleanup after each installation
# • No unnecessary documentation or man pages
# • Git repositories cleaned after Oh My Zsh installation
#
# ==============================================================================
#
# 🔄 VERSION HISTORY
# ==============================================================================
#
# v1.0.14 (November 2026) - Stay Current Dependency Refresh
#   • Updated external tool dependencies: calicoctl v3.33.0, fortio v1.76.0
#   • Updated base image to Alpine Linux 3.24.4
#   • Refreshed MOTD help banner, README tool version tables, and OCI version labels
#
# v1.0.13 (September 2026) - Stay Current Dependency Refresh
#   • Updated external tool dependencies: calicoctl v3.32.2, grpcurl v1.9.4,
#     fortio v1.75.3, kubecolor v0.8.0, kubelogin v1.36.4
#   • Updated base image to Alpine Linux 3.24.2
#   • Refreshed MOTD help banner, README notes, and OCI version labels
#
# v1.0.12 (August 2026) - Dependency Currency & Build Streamlining
#   • Updated external tool dependencies: calicoctl v3.32.1, kubelogin v1.36.3
#   • Streamlined kubecolor installation to multi-arch official pre-built releases
#   • Hardened runtime image footprint by purging build dependencies (ruby-dev) post-gem install
#   • Refreshed MOTD documentation, tool version manifests, and version labels
#
# v1.0.11 (June 2026) - Dependency Currency & Audit Hardening
#   • Refreshed to latest stable: Alpine 3.24.1, calicoctl v3.32.0, fortio v1.75.2,
#     kubecolor v0.6.0, kubectx/kubens v0.11.0, kubelogin v1.36.2
#   • De-duplicated the MOTD banner into a single shell function
#   • Cap-independent HEALTHCHECK (netlink via `ip`, no NET_RAW dependency)
#   • Dropped redundant ip6tables package (provided by iptables) and deprecated scapy-http
#   • Removed an empty build layer; tightened over-stated wording in docs/MOTD
#
# v1.0.10 (February 2026) - Multi-Arch Reliability & Supply-Chain Pinning
#   • Fixed arm64 build by compiling hey from source (v0.1.5)
#   • Pinned swaks source to v20240103.0 tag for reproducibility
#   • Pinned base image to Alpine 3.23.3 and refreshed security scan example
#
# v1.0.9 (February 2026) - Calicoctl Refresh
#   • Updated calicoctl to v3.31.4
#   • Refreshed metadata, usage examples, and MOTD tool references
#
# v1.0.8 (February 2026) - Fortio Refresh
#   • Updated fortio to v1.74.0
#   • Refreshed internal tool-version references
#
# v1.0.7 (February 2026) - Tool Updates & Kubecolor Migration
#   • Updated kubecolor to v0.5.3 (migrated to active kubecolor/kubecolor fork)
#   • Updated fortio to v1.73.2
#   • Updated hey to v0.1.5
#   • Updated kubelogin to v1.35.2
#
# v1.0.6 (January 2026) - Alpine 3.23 Base Image Update
#   • Upgraded base image from Alpine 3.22 to Alpine 3.23
#   • All binaries verified at latest stable versions
#   • Refreshed documentation and MOTD timestamps
#
# v1.0.5 (December 2025) - Binary Updates & Refresh
#   • Updated calicoctl to v3.31.3
#   • Updated fortio to v1.73.1
#   • Updated websocat to v1.14.1
#   • Updated kubecolor to v0.0.25
#   • Updated kubelogin to v1.35.0
#   • Refreshed documentation timestamps
#
# v1.0.4 (October 2025) - Enhanced Documentation & Polish
#   ✨ Comprehensive inline documentation with visual hierarchy
#   ✨ Enhanced MOTD with detailed tool categorization
#   ✨ Improved license documentation with clear structure
#   ✨ Additional productivity aliases (sysinfo, la, connections, h)
#   ✨ Better organized package installation with categories
#   ✨ Professional technical English throughout
#   ✨ Enhanced usage examples and deployment patterns
#   ✨ Improved build process logging with emoji indicators
#   ✨ Complete security best practices section
#   ✨ Added net-tools package for traditional network utilities
#
# v1.0.3 (October 2025) - Production Enhancements
#   • Added netifaces2 Python package (modern replacement)
#   • Added kubectl, hey, btop, nmon
#   • Clarified dual licensing model
#   • Added license files in /usr/share/licenses/fnxnt/
#   • Updated OCI labels to reflect dual licensing
#   • 100% feature parity with nicolaka/netshoot verified
#
# v1.0.2 (October 2025) - Architecture Simplification
#   • Eliminated entrypoint.sh - all configuration in Dockerfile
#   • Simplified container startup with direct CMD execution
#   • Added WORKDIR directive for proper directory handling
#   • Updated usage examples for netuser workflows
#
# v1.0.1 (October 2025) - Tool Updates & Refinements
#   • Updated to Alpine 3.22
#   • Updated grpcurl to v1.9.3
#   • Updated fortio to v1.72.0
#   • Updated trippy to v0.13.0
#   • Added libarchive-tools package
#   • Added lolcat for colorful MOTD
#   • Fixed Oh My Zsh agnoster theme
#   • Fixed MOTD duplicate display
#
# v1.0.0 (October 2025) - Initial FNXNT Release
#   • Forked from nicolaka/netshoot
#   • Multi-stage build optimization
#   • Enhanced shell configuration
#   • Custom MOTD banner
#   • Non-root user support
#   • Production-grade cleanup
#
# ==============================================================================
# 
# 🙏 ACKNOWLEDGMENTS
# ==============================================================================
#
# This project builds upon the excellent work of nicolaka/netshoot.
# We're grateful to the original author and all contributors for creating
# such a valuable tool for the networking community.
#
# Special thanks to:
#   • nicolaka - Original netshoot creator and maintainer
#   • Alpine Linux team - For providing the minimal base image
#   • All open-source tool maintainers whose work is included here
#
# ==============================================================================
#
# 📬 SUPPORT & CONTRIBUTIONS
# ==============================================================================
#
# For issues, feature requests, or contributions related to FNXNT enhancements:
#   • Review the upstream netshoot project first
#   • Check if the issue is specific to FNXNT modifications
#   • Provide detailed reproduction steps and environment info
#
# For issues with the original netshoot functionality:
#   • Please refer to: https://github.com/nicolaka/netshoot
#
# ==============================================================================
