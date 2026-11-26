# syntax=docker/dockerfile:1.7
# FNXNT — Fenix' Networking Tools: network diagnostics toolbox with netshoot parity.
# Built on the current Debian stable slim release, rebuilt and scanned daily.
# Upstream: https://github.com/nicolaka/netshoot (Apache-2.0)
# Maintainer: Daniel G. Cosenza from FNX Labs

ARG DEBIAN_BASE=debian:13.8-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0
ARG FNXNT_VERSION=1.0.15
ARG IMAGE_CREATED=1970-01-01T00:00:00Z
ARG IMAGE_REVISION=dev
ARG IMAGE_SOURCE=https://github.com/dgcosenza/fnxnt-docker

# ==============================================================================
# Stage 1: verify and collect upstream release binaries
# ==============================================================================
FROM ${DEBIAN_BASE} AS binary-builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

# Pinned upstream releases (CI verifies these against the official release API).
ARG CTOP_VERSION=0.7.7
ARG CALICO_VERSION=v3.33.1
ARG TERMSHARK_VERSION=2.4.0
ARG GRPCURL_VERSION=1.9.4
ARG FORTIO_VERSION=1.77.0
ARG WEBSOCAT_VERSION=1.14.2
ARG TRIPPY_VERSION=0.13.0
ARG KUBECOLOR_VERSION=v0.9.0
ARG KUBECTX_VERSION=v0.11.0
ARG KUBENS_VERSION=v0.11.0
ARG KUBELOGIN_VERSION=v1.36.4
ARG YQ_VERSION=v4.54.3
ARG HEY_COMMIT=e64ec7a3ad1ef8bc828fe61e1fb324cc2e74c604

# SHA-256 digests of the official release assets (computed from the pinned versions).
ARG CTOP_SHA_AMD64=b78374734ebe3d14b6edee3d5512c911c250d7fa7f3f964cb00acd3bc5a02a09
ARG CTOP_SHA_ARM64=d8d91e0fea53a8c78fa81192f078272e5a92f0ea6c4f0e38ec7c944d76e6f02f
ARG CALICO_SHA_AMD64=e62f41d354061c78d8099c61fca9efb675228df153ecc14dc90e896a215528ac
ARG CALICO_SHA_ARM64=9bbad53d92c719334bdc75a3574787d1c8e4a8a09ae2b55a6e6a89cec9059f41
ARG TERMSHARK_SHA_AMD64=a28b2ab534ba8bf2297bbe9846281e62aa0010832b75773369e0d48912acef74
ARG TERMSHARK_SHA_ARM64=6dc3003a48291c463f057d0151727e0d21e295d804f082f3d35d72fd94d0a56e
ARG GRPCURL_SHA_AMD64=97e13d58d2733a0e62cd2571d1d5f0c02823f0d25282f08bddedf1ad9c5d1736
ARG GRPCURL_SHA_ARM64=ad66227d90631da5428b4a5ccf28d63846f0f15649d8b2367df044a59edbb617
ARG FORTIO_SHA_AMD64=30f126c7107efe90056b8343bf1db1e32e59c8fcd982e0383605e2fdf6de98d7
ARG FORTIO_SHA_ARM64=ee441a3e9070db49e8bab6416f87a1030fe4f2d267ea2dc0eae4c2a7345bb4a1
ARG WEBSOCAT_SHA_AMD64=cd26f92cb507f620e2d54fe6e126f4dc191f3eee90f2b53bccf07eac0645ec84
ARG WEBSOCAT_SHA_ARM64=cdd6b0bee24c81c537cb9ef257b433625355e0bbe002235f8df1e70acbd2c1dd
ARG TRIPPY_SHA_AMD64=aa2b7b2a0773f3cc04da691100419049950b690fe3736d25e24ac955b63d6056
ARG TRIPPY_SHA_ARM64=73af939aa94e9e0f07cac2b3c8177e02a6b1c3be88299d85988e02be81ae7004
ARG KUBECOLOR_SHA_AMD64=286ef7abc25a1c7b136761b32303b64838929bee83a2ed12e74c67531d7221f2
ARG KUBECOLOR_SHA_ARM64=78a3d101436dc99b506bb0233d45d008eac8b94635ae641b1154e4ed31101c83
ARG KUBECTX_SHA_AMD64=08e031c54fbffb3f100e904e4eae94bba2730fedf4869921fda79e4d7a8f5d4c
ARG KUBECTX_SHA_ARM64=1dac2072216689e773325cb7587b858ea7415706ebcf04e23bf80e7e70555340
ARG KUBENS_SHA_AMD64=326c021c7b35468ed9a187b361198d0f22ae32828139c65eb6670c0d8301cc09
ARG KUBENS_SHA_ARM64=37058abe82ef20c93b44f3dc8ca2382dbb95d416cec958fbf7b8f79f011be86c
ARG KUBELOGIN_SHA_AMD64=9e8baeb4905d35a301304af2548324997add512fe94ab20e65993d167212bf85
ARG KUBELOGIN_SHA_ARM64=669c2d3bcc6766351ad5a7b03971792b4e7a55117b335a12d9858d43a525d9dc
ARG YQ_SHA_AMD64=129534601871538efe0ba4c5e62a34fb1d5f469bcb975c4fddeb467d82974973
ARG YQ_SHA_ARM64=89f69310b61b68d1245065a1241d1fc843f7a36cd6103ffd77ad987613bd1b67
ARG SWAKS_SHA=37f3a34d3c414e8d95b285ad5752990861423e51bfe4918d748add06b5c4afa7

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl tar gzip unzip git golang-go \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Map BuildKit's TARGETARCH to each project's release naming convention.
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
        amd64) \
            BINARCH=amd64; GOARCH=amd64; TERMSHARK_PKG=linux_x64; \
            GRPCURL_ARCH=linux_x86_64; WEBSOCAT_ARTIFACT=x86_64-unknown-linux-musl; \
            TRIPPY_ARTIFACT=x86_64-unknown-linux-musl; KUBECTX_ARCH=linux_x86_64; \
            KUBELOGIN_ARCH=linux_amd64; YQ_ARTIFACT=yq_linux_amd64 ;; \
        arm64) \
            BINARCH=arm64; GOARCH=arm64; TERMSHARK_PKG=linux_arm64; \
            GRPCURL_ARCH=linux_arm64; WEBSOCAT_ARTIFACT=aarch64-unknown-linux-musl; \
            TRIPPY_ARTIFACT=aarch64-unknown-linux-musl; KUBECTX_ARCH=linux_arm64; \
            KUBELOGIN_ARCH=linux_arm64; YQ_ARTIFACT=yq_linux_arm64 ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    { \
        echo "export BINARCH=${BINARCH}"; \
        echo "export GOARCH=${GOARCH}"; \
        echo "export TERMSHARK_PKG=${TERMSHARK_PKG}"; \
        echo "export GRPCURL_ARCH=${GRPCURL_ARCH}"; \
        echo "export WEBSOCAT_ARTIFACT=${WEBSOCAT_ARTIFACT}"; \
        echo "export TRIPPY_ARTIFACT=${TRIPPY_ARTIFACT}"; \
        echo "export KUBECTX_ARCH=${KUBECTX_ARCH}"; \
        echo "export KUBELOGIN_ARCH=${KUBELOGIN_ARCH}"; \
        echo "export YQ_ARTIFACT=${YQ_ARTIFACT}"; \
        case "${BINARCH}" in \
            amd64) \
                echo "export CTOP_SHA=${CTOP_SHA_AMD64}"; \
                echo "export CALICO_SHA=${CALICO_SHA_AMD64}"; \
                echo "export TERMSHARK_SHA=${TERMSHARK_SHA_AMD64}"; \
                echo "export GRPCURL_SHA=${GRPCURL_SHA_AMD64}"; \
                echo "export FORTIO_SHA=${FORTIO_SHA_AMD64}"; \
                echo "export WEBSOCAT_SHA=${WEBSOCAT_SHA_AMD64}"; \
                echo "export TRIPPY_SHA=${TRIPPY_SHA_AMD64}"; \
                echo "export KUBECOLOR_SHA=${KUBECOLOR_SHA_AMD64}"; \
                echo "export KUBECTX_SHA=${KUBECTX_SHA_AMD64}"; \
                echo "export KUBENS_SHA=${KUBENS_SHA_AMD64}"; \
                echo "export KUBELOGIN_SHA=${KUBELOGIN_SHA_AMD64}"; \
                echo "export YQ_SHA=${YQ_SHA_AMD64}" ;; \
            arm64) \
                echo "export CTOP_SHA=${CTOP_SHA_ARM64}"; \
                echo "export CALICO_SHA=${CALICO_SHA_ARM64}"; \
                echo "export TERMSHARK_SHA=${TERMSHARK_SHA_ARM64}"; \
                echo "export GRPCURL_SHA=${GRPCURL_SHA_ARM64}"; \
                echo "export FORTIO_SHA=${FORTIO_SHA_ARM64}"; \
                echo "export WEBSOCAT_SHA=${WEBSOCAT_SHA_ARM64}"; \
                echo "export TRIPPY_SHA=${TRIPPY_SHA_ARM64}"; \
                echo "export KUBECOLOR_SHA=${KUBECOLOR_SHA_ARM64}"; \
                echo "export KUBECTX_SHA=${KUBECTX_SHA_ARM64}"; \
                echo "export KUBENS_SHA=${KUBENS_SHA_ARM64}"; \
                echo "export KUBELOGIN_SHA=${KUBELOGIN_SHA_ARM64}"; \
                echo "export YQ_SHA=${YQ_SHA_ARM64}" ;; \
        esac; \
    } > /tmp/arch.env

RUN set -eux; . /tmp/arch.env; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://github.com/bcicen/ctop/releases/download/v${CTOP_VERSION}/ctop-${CTOP_VERSION}-linux-${BINARCH}" -o /tmp/ctop; \
    echo "${CTOP_SHA}  /tmp/ctop" | sha256sum -c -; \
    install -m 0755 /tmp/ctop /usr/local/bin/ctop; rm -f /tmp/ctop

RUN set -eux; . /tmp/arch.env; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://github.com/projectcalico/calico/releases/download/${CALICO_VERSION}/calicoctl-linux-${BINARCH}" -o /tmp/calicoctl; \
    echo "${CALICO_SHA}  /tmp/calicoctl" | sha256sum -c -; \
    install -m 0755 /tmp/calicoctl /usr/local/bin/calicoctl; rm -f /tmp/calicoctl

RUN set -eux; . /tmp/arch.env; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://github.com/gcla/termshark/releases/download/v${TERMSHARK_VERSION}/termshark_${TERMSHARK_VERSION}_${TERMSHARK_PKG}.tar.gz" -o /tmp/termshark.tar.gz; \
    echo "${TERMSHARK_SHA}  /tmp/termshark.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/termshark.tar.gz -C /tmp; \
    install -m 0755 "/tmp/termshark_${TERMSHARK_VERSION}_${TERMSHARK_PKG}/termshark" /usr/local/bin/termshark; \
    rm -rf /tmp/termshark*

RUN set -eux; . /tmp/arch.env; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://github.com/fullstorydev/grpcurl/releases/download/v${GRPCURL_VERSION}/grpcurl_${GRPCURL_VERSION}_${GRPCURL_ARCH}.tar.gz" -o /tmp/grpcurl.tar.gz; \
    echo "${GRPCURL_SHA}  /tmp/grpcurl.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/grpcurl.tar.gz -C /tmp; \
    install -m 0755 /tmp/grpcurl /usr/local/bin/grpcurl; rm -rf /tmp/grpcurl*

RUN set -eux; . /tmp/arch.env; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://github.com/fortio/fortio/releases/download/v${FORTIO_VERSION}/fortio-linux_${BINARCH}-${FORTIO_VERSION}.tgz" -o /tmp/fortio.tgz; \
    echo "${FORTIO_SHA}  /tmp/fortio.tgz" | sha256sum -c -; \
    tar -xzf /tmp/fortio.tgz -C /tmp; \
    install -m 0755 /tmp/usr/bin/fortio /usr/local/bin/fortio; rm -rf /tmp/fortio.tgz /tmp/usr

RUN set -eux; . /tmp/arch.env; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://github.com/vi/websocat/releases/download/v${WEBSOCAT_VERSION}/websocat.${WEBSOCAT_ARTIFACT}" -o /tmp/websocat; \
    echo "${WEBSOCAT_SHA}  /tmp/websocat" | sha256sum -c -; \
    install -m 0755 /tmp/websocat /usr/local/bin/websocat; rm -f /tmp/websocat

RUN set -eux; . /tmp/arch.env; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://github.com/fujiapple852/trippy/releases/download/${TRIPPY_VERSION}/trippy-${TRIPPY_VERSION}-${TRIPPY_ARTIFACT}.tar.gz" -o /tmp/trippy.tar.gz; \
    echo "${TRIPPY_SHA}  /tmp/trippy.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/trippy.tar.gz -C /tmp; \
    install -m 0755 "/tmp/trippy-${TRIPPY_VERSION}-${TRIPPY_ARTIFACT}/trip" /usr/local/bin/trippy; \
    rm -rf /tmp/trippy*

# kubectl: verify against the publisher's own SHA-256 file for the resolved version.
RUN set -eux; . /tmp/arch.env; \
    KUBECTL_VERSION="$(curl -fsSL --retry 5 https://dl.k8s.io/release/stable.txt)"; \
    curl -fsSL --retry 5 --retry-all-errors \
      "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${BINARCH}/kubectl" -o /tmp/kubectl; \
    curl -fsSL --retry 5 \
      "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${BINARCH}/kubectl.sha256" -o /tmp/kubectl.sha256; \
    echo "$(cat /tmp/kubectl.sha256)  /tmp/kubectl" | sha256sum -c -; \
    install -m 0755 /tmp/kubectl /usr/local/bin/kubectl; rm -f /tmp/kubectl /tmp/kubectl.sha256

RUN set -eux; . /tmp/arch.env; \
    KCOLOR="${KUBECOLOR_VERSION#v}"; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://github.com/kubecolor/kubecolor/releases/download/${KUBECOLOR_VERSION}/kubecolor_${KCOLOR}_linux_${BINARCH}.tar.gz" -o /tmp/kubecolor.tar.gz; \
    echo "${KUBECOLOR_SHA}  /tmp/kubecolor.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/kubecolor.tar.gz -C /tmp; \
    install -m 0755 /tmp/kubecolor /usr/local/bin/kubecolor; rm -rf /tmp/kubecolor*

RUN set -eux; . /tmp/arch.env; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_${KUBECTX_ARCH}.tar.gz" -o /tmp/kubectx.tar.gz; \
    echo "${KUBECTX_SHA}  /tmp/kubectx.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/kubectx.tar.gz -C /tmp; \
    install -m 0755 /tmp/kubectx /usr/local/bin/kubectx; rm -rf /tmp/kubectx*

RUN set -eux; . /tmp/arch.env; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://github.com/ahmetb/kubectx/releases/download/${KUBENS_VERSION}/kubens_${KUBENS_VERSION}_${KUBECTX_ARCH}.tar.gz" -o /tmp/kubens.tar.gz; \
    echo "${KUBENS_SHA}  /tmp/kubens.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/kubens.tar.gz -C /tmp; \
    install -m 0755 /tmp/kubens /usr/local/bin/kubens; rm -rf /tmp/kubens*

RUN set -eux; . /tmp/arch.env; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://github.com/int128/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin_${KUBELOGIN_ARCH}.zip" -o /tmp/kubelogin.zip; \
    echo "${KUBELOGIN_SHA}  /tmp/kubelogin.zip" | sha256sum -c -; \
    unzip -q /tmp/kubelogin.zip kubelogin -d /tmp; \
    install -m 0755 /tmp/kubelogin /usr/local/bin/kubelogin; rm -rf /tmp/kubelogin*

RUN set -eux; . /tmp/arch.env; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_ARTIFACT}" -o /tmp/yq; \
    echo "${YQ_SHA}  /tmp/yq" | sha256sum -c -; \
    install -m 0755 /tmp/yq /usr/local/bin/yq; rm -f /tmp/yq

# hey: built from a pinned upstream commit for both architectures.
RUN set -eux; . /tmp/arch.env; \
    git clone --depth 1 https://github.com/rakyll/hey.git /tmp/hey-src; \
    git -C /tmp/hey-src fetch --depth 1 origin "${HEY_COMMIT}"; \
    git -C /tmp/hey-src checkout --detach "${HEY_COMMIT}"; \
    GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH="${GOARCH}" \
      go build -C /tmp/hey-src -o /usr/local/bin/hey .; \
    rm -rf /tmp/hey-src

RUN set -eux; \
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors \
      "https://raw.githubusercontent.com/jetmore/swaks/v20240103.0/swaks" -o /tmp/swaks; \
    echo "${SWAKS_SHA}  /tmp/swaks" | sha256sum -c -; \
    install -m 0755 /tmp/swaks /usr/local/bin/swaks; rm -f /tmp/swaks; \
    rm -f /tmp/arch.env

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
COPY --from=binary-builder /usr/local/bin/yq /usr/local/bin/yq
COPY --from=binary-builder /usr/local/bin/hey /usr/local/bin/hey
COPY --from=binary-builder /usr/local/bin/swaks /usr/local/bin/swaks

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
