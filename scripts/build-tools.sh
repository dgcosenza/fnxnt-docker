#!/usr/bin/env bash
# Build the FNXNT toolkit from official pinned sources with the patched Go
# toolchain. Every Go module with a published security fix is advanced to a
# fixed release before compiling; nothing is downloaded as an unverified
# prebuilt Go binary.
set -euo pipefail

ARCH="${TARGETARCH:-amd64}"
export CGO_ENABLED=0 GOOS=linux GOARCH="${ARCH}" GOTOOLCHAIN=local GOPROXY=https://proxy.golang.org,direct
mkdir -p /out /src

# Modules with published fixes for findings present in the older upstream pins.
PATCH_MODULES=(
  golang.org/x/net@v0.63.0
  golang.org/x/crypto@v0.59.0
  golang.org/x/text@v0.44.0
  golang.org/x/sys@v0.50.0
  go.opentelemetry.io/otel/trace@v1.47.0
  github.com/go-jose/go-jose/v4@v4.1.9
  github.com/klauspost/compress@v1.20.5
  github.com/sirupsen/logrus@v1.10.2
  github.com/gogo/protobuf@v1.3.2
  github.com/opencontainers/image-spec@v1.1.1
  github.com/opencontainers/selinux@v1.15.1
  github.com/cyphar/filepath-securejoin@v0.7.0
  github.com/cilium/ebpf@v0.22.0
  gopkg.in/yaml.v3@v3.0.1
  github.com/antchfx/xpath@v1.3.9
  google.golang.org/protobuf@v1.36.12
)

patch_and_build() {
  local name="$1" repo="$2" ref="$3" path="$4" package="${5:-.}"
  echo "==> building ${name} from ${repo}@${ref}"
  git clone --quiet --depth 1 --branch "${ref}" "https://github.com/${repo}.git" "/src/${name}"
  cd "/src/${name}/${path}"
  rm -rf vendor
  go mod download 2>/dev/null || true
  go get "${PATCH_MODULES[@]}"
  go build -mod=mod -trimpath -ldflags='-s -w' -o "/out/${name}" "${package}"
  test -x "/out/${name}"
  echo "==> ok ${name}"
  cd /src
}

# ctop's 2021 docker client imports APIs that were removed from newer
# docker/docker releases. Move it to the maintained client first so the
# patched container stack is API-compatible.
echo "==> building ctop"
git clone --quiet --depth 1 --branch v0.7.7 https://github.com/bcicen/ctop.git /src/ctop
cd /src/ctop
go mod download 2>/dev/null || true
go get github.com/fsouza/go-dockerclient@v1.13.3 github.com/opencontainers/runc@v1.5.3 github.com/containerd/containerd@v1.7.36
go mod edit -droprequire=github.com/docker/docker
go get "${PATCH_MODULES[@]}"
go build -mod=mod -trimpath -ldflags='-s -w' -o /out/ctop .
test -x /out/ctop
echo "==> ok ctop"
cd /src
patch_and_build grpcurl fullstorydev/grpcurl v1.9.4 ./cmd/grpcurl .
patch_and_build fortio fortio/fortio v1.77.0 . .
patch_and_build kubecolor kubecolor/kubecolor v0.9.0 . .
patch_and_build kubelogin int128/kubelogin v1.36.4 . .
patch_and_build yq mikefarah/yq v4.54.3 . .
patch_and_build termshark gcla/termshark v2.4.0 ./cmd/termshark .

# hey: pinned upstream commit.
echo "==> building hey"
git clone --quiet https://github.com/rakyll/hey.git /src/hey
git -C /src/hey fetch --quiet --depth 1 origin e64ec7a3ad1ef8bc828fe61e1fb324cc2e74c604
git -C /src/hey checkout --quiet --detach e64ec7a3ad1ef8bc828fe61e1fb324cc2e74c604
cd /src/hey
go mod download 2>/dev/null || true
go get "${PATCH_MODULES[@]}"
go build -mod=mod -trimpath -ldflags='-s -w' -o /out/hey .
echo "==> ok hey"
cd /src

# kubectx / kubens: use the official shell implementations (no embedded Go code).
echo "==> installing kubectx and kubens scripts"
git clone --quiet --depth 1 --branch v0.11.0 https://github.com/ahmetb/kubectx.git /src/kubectx
install -m 0755 /src/kubectx/kubectx /out/kubectx
install -m 0755 /src/kubectx/kubens /out/kubens

# calicoctl: Calico's official release source.
patch_and_build calicoctl projectcalico/calico v3.33.1 ./calicoctl/calicoctl .

# kubectl: Kubernetes official release source (vendored modules removed so the
# patched dependency versions from PATCH_MODULES are actually used).
patch_and_build kubectl kubernetes/kubernetes v1.37.3 . ./cmd/kubectl

# Rust static binaries and the swaks script keep SHA-256 verification.
verify_download() {
  local url="$1" sha="$2" out="$3"
  curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "$url" -o "/tmp/${out}"
  echo "${sha}  /tmp/${out}" | sha256sum -c -
  install -m 0755 "/tmp/${out}" "/out/${out}"
  rm -f "/tmp/${out}"
}

case "${ARCH}" in
  amd64)
    websocat_sha=cd26f92cb507f620e2d54fe6e126f4dc191f3eee90f2b53bccf07eac0645ec84
    trippy_sha=aa2b7b2a0773f3cc04da691100419049950b690fe3736d25e24ac955b63d6056
    websocat_asset=x86_64-unknown-linux-musl
    trippy_asset=x86_64-unknown-linux-musl
    ;;
  arm64)
    websocat_sha=cdd6b0bee24c81c537cb9ef257b433625355e0bbe002235f8df1e70acbd2c1dd
    trippy_sha=73af939aa94e9e0f07cac2b3c8177e02a6b1c3be88299d85988e02be81ae7004
    websocat_asset=aarch64-unknown-linux-musl
    trippy_asset=aarch64-unknown-linux-musl
    ;;
  *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
esac

verify_download "https://github.com/vi/websocat/releases/download/v1.14.2/websocat.${websocat_asset}" "${websocat_sha}" websocat
verify_download "https://github.com/fujiapple852/trippy/releases/download/0.13.0/trippy-0.13.0-${trippy_asset}.tar.gz" "${trippy_sha}" trippy.tar.gz
tar -xzf /out/trippy.tar.gz -C /src
install -m 0755 "/src/trippy-0.13.0-${trippy_asset}/trip" /out/trippy
rm -f /out/trippy.tar.gz
verify_download "https://raw.githubusercontent.com/jetmore/swaks/v20240103.0/swaks" 37f3a34d3c414e8d95b285ad5752990861423e51bfe4918d748add06b5c4afa7 swaks

echo "==> toolchain build complete for ${ARCH}"
