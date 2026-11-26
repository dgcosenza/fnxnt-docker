# syntax=docker/dockerfile:1.7
# FNXNT — Fenix' Networking Tools: network diagnostics toolbox with netshoot parity.
# Built on the current Debian stable slim release, rebuilt and scanned daily.
# Upstream: https://github.com/nicolaka/netshoot (Apache-2.0)
# Maintainer: Daniel G. Cosenza from FNX Labs

ARG GO_BASE=golang:1.27.4-trixie@sha256:430985542100b871e108ccc00e8dcc5eef08ca14ee5825e98ebf563d8ffec4ee
ARG DEBIAN_BASE=debian:13.8-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0
ARG FNXNT_VERSION=1.0.15
ARG IMAGE_CREATED=1970-01-01T00:00:00Z
ARG IMAGE_REVISION=dev
ARG IMAGE_SOURCE=https://github.com/dgcosenza/fnxnt-docker

# ==============================================================================
# Stage 1: compile upstream tools with the patched Go toolchain
# ==============================================================================
FROM ${GO_BASE} AS binary-builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends git ca-certificates curl tar gzip unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY scripts/build-tools.sh /usr/local/bin/build-tools.sh
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    chmod +x /usr/local/bin/build-tools.sh && /usr/local/bin/build-tools.sh

# ==============================================================================
# Stage 2: Debian stable slim runtime with the full netshoot-equivalent toolkit
# ==============================================================================
FROM ${DEBIAN_BASE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG FNXNT_VERSION
ARG IMAGE_CREATED
ARG IMAGE_REVISION
ARG IMAGE_SOURCE

LABEL maintainer="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.title="FNXNT network diagnostics toolbox" \
      org.opencontainers.image.description="Debian-based, multi-architecture network troubleshooting container with netshoot tool parity, daily CVE-gated builds, and a non-root user, maintained by Daniel G. Cosenza from FNX Labs." \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.version="${FNXNT_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/fnxnt" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.licenses="Apache-2.0 AND MIT" \
      org.opencontainers.image.base.name="debian:13.8-slim" \
      io.github.dgcosenza.fnxnt.version="${FNXNT_VERSION}"

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color \
    SHELL=/bin/zsh \
    PAGER=less \
    FNXNT_VERSION=${FNXNT_VERSION} \
    DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends \
        apache2-utils bash bind9-dnsutils bird2 bridge-utils btop busybox-static \
        ca-certificates conntrack coreutils curl dhcping eza fastfetch file fping \
        git gnupg httpie iftop iperf iperf3 iproute2 ipset iptables iptraf-ng \
        iputils-arping iputils-ping iputils-tracepath ipvsadm jq ldnsutils less \
        libarchive-tools libcrypt-ssleay-perl libnet-ssleay-perl liboping0 lolcat \
        lsof ltrace mc mtr nano ncat nftables nmap nmon net-tools netcat-openbsd \
        ngrep openssh-client openssl perl python3 python3-pip python3-scapy \
        python3-setuptools ruby snmp socat speedtest-cli strace tcpdump \
        tcptraceroute telnet tini tmux traceroute tshark tzdata util-linux vim \
        wget yq zsh zsh-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "Debian package installation complete"

COPY --from=binary-builder /out/ /usr/local/bin/

RUN set -eux; \
    git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh; \
    cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc; \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /root/.zshrc; \
    sed -i 's/plugins=(git)/plugins=(git docker kubectl docker-compose)/' /root/.zshrc; \
    cat <<'EOF' >> /root/.zshrc

# FNXNT custom aliases
alias ff="fastfetch"
alias sysinfo="btop"
alias ll="ls -lah"
alias la="ls -A"
alias lle="printf '\\n' && eza --long --git --icons -lahgHF --group-directories-first"
alias k="kubecolor"
alias ports="netstat -tulanp"
alias listening="ss -tulpn"
alias routes="ip route show"
alias myip="curl -s --max-time 5 ifconfig.me"
alias connections="ss -tanp"
alias c="clear"
alias e="exit"
alias h="history"
alias help="fnxnt-motd"
HOST="fnxnt"
if [ -f /etc/profile.d/motd.sh ] && [ -z "$MOTD_SHOWN" ]; then
    export MOTD_SHOWN=1
    source /etc/profile.d/motd.sh
fi
EOF

RUN printf '%s\n' '[[ -r /etc/profile ]] && . /etc/profile' > /root/.bashrc && \
    cat <<'EOF' >> /root/.bashrc

# FNXNT custom aliases
alias ff="fastfetch"
alias sysinfo="btop"
alias ll="ls -lah"
alias la="ls -A"
alias lle="printf '\\n' && eza --long --git --icons -lahgHF --group-directories-first"
alias k="kubecolor"
alias ports="netstat -tulanp"
alias listening="ss -tulpn"
alias routes="ip route show"
alias myip="curl -s --max-time 5 ifconfig.me"
alias connections="ss -tanp"
alias c="clear"
alias e="exit"
alias h="history"
alias help="fnxnt-motd"
EOF

COPY scripts/motd.sh /etc/profile.d/motd.sh
RUN sed -i "s/@@FNXNT_VERSION@@/${FNXNT_VERSION}/g" /etc/profile.d/motd.sh && \
    chmod +x /etc/profile.d/motd.sh && \
    install -m 0755 /dev/stdin /usr/local/bin/fnxnt-motd <<'EOF'
#!/bin/sh
MOTD_SCRIPT=/etc/profile.d/motd.sh
if [ -r "${MOTD_SCRIPT}" ]; then
    env -u MOTD_SHOWN /bin/sh "${MOTD_SCRIPT}"
else
    echo "FNXNT MOTD script not found at ${MOTD_SCRIPT}" >&2
    exit 1
fi
EOF

# hadolint ignore=DL3013
RUN set -eux; \
    pip3 install --no-cache-dir --break-system-packages \
        dnspython netaddr netifaces2 pyshark requests; \
    rm -rf /root/.cache/pip /tmp/* /var/tmp/*

# hadolint ignore=SC2016
RUN set -eux; \
    groupadd -g 1000 netuser; \
    useradd -u 1000 -g netuser -m -d /home/netuser -s /bin/zsh netuser; \
    cp -r /root/.oh-my-zsh /home/netuser/.oh-my-zsh; \
    cp /root/.zshrc /home/netuser/.zshrc; \
    cp /root/.bashrc /home/netuser/.bashrc; \
    sed -i 's|/root/.oh-my-zsh|/home/netuser/.oh-my-zsh|g' /home/netuser/.zshrc; \
    sed -i 's|export ZSH=.*|export ZSH="$HOME/.oh-my-zsh"|g' /home/netuser/.zshrc; \
    chown -R netuser:netuser /home/netuser

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

   • Debian packages: Various open-source licenses
     └─ https://packages.debian.org/

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

RUN rm -rf \
    /tmp/* \
    /var/tmp/* \
    /var/log/* \
    /root/.oh-my-zsh/.git \
    /home/netuser/.oh-my-zsh/.git \
    /usr/share/man/* \
    /usr/share/doc/*

# Capability-independent probe: no NET_RAW or privileged mode required.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["ip", "link", "show", "lo"]

WORKDIR /root
CMD ["/bin/zsh"]
