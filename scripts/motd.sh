#!/bin/sh
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FNXNT (Fenix' Networking Tools) - Message of the Day
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Check if lolcat is available and stdout is a terminal
fnxnt_print_banner() {
    cat <<BANNER

    ███████╗███╗   ██╗██╗  ██╗███╗   ██╗████████╗
    ██╔════╝████╗  ██║╚██╗██╔╝████╗  ██║╚══██╔══╝
    █████╗  ██╔██╗ ██║ ╚███╔╝ ██╔██╗ ██║   ██║
    ██╔══╝  ██║╚██╗██║ ██╔██╗ ██║╚██╗██║   ██║
    ██║     ██║ ╚████║██╔╝ ██╗██║ ╚████║   ██║
    ╚═╝     ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝

    🔥 Fenix' Networking Tools v@@FNXNT_VERSION@@ 🔥
    Enterprise Network Diagnostics Platform
    
    Built on Alpine Linux 3.24.4 | Multi-Architecture Support
    "Rise from the ashes of network issues"

    ✅ netshoot-equivalent toolkit + curated enhancements

    ═════════════════════════════════════════════════════════════════════════

    📦 COMPREHENSIVE TOOLKIT INVENTORY
    ─────────────────────────────────────────────────────────────────────────
    
    📡 Connectivity Testing
       • Basic: ping, curl, wget, netcat, socat
       • Advanced: websocat, httpie
    
    🔍 DNS Resolution & Analysis
       • Tools: drill, dig, nslookup, host
       • Libraries: dnspython
    
    📊 Performance & Load Testing
       • Bandwidth: iperf, iperf3
       • HTTP: fortio, hey, apache2-utils (ab)
       • Analysis: speedtest-cli
    
    🔎 Network Scanning & Discovery
       • Port Scanning: nmap, nping
       • Host Discovery: fping
       • Packet Filtering: ngrep
    
    📈 Traffic Monitoring & Analysis
       • Packet Capture: tcpdump, tshark
       • Interactive: termshark (TUI)
       • Live Monitoring: iftop, iptraf-ng
    
    🛣️  Routing & Path Analysis
       • Standard: ip, traceroute
       • Enhanced: mtr, trippy
       • Visualization: Advanced TUI support
    
    🐛 System & Network Debugging
       • Process: strace, ltrace, lsof
       • Network: netstat, ss
       • Connection Tracking: conntrack-tools
    
    🔐 Security & Firewall Management
       • Firewall: iptables, ip6tables, nftables
       • IP Sets: ipset
       • Load Balancing: ipvsadm
    
    🌐 Application Protocol Testing
       • HTTP/REST: httpie, curl, ab
       • gRPC: grpcurl
       • WebSocket: websocat
       • SMTP: swaks
    
    📦 Container & Orchestration
       • Container Metrics: ctop
       • Kubernetes: kubectl, kubecolor, kubectx, kubens, kubelogin
       • Calico CNI: calicoctl
    
    🐍 Python Networking Libraries
       • Packet Crafting: scapy
       • Packet Analysis: pyshark
       • Network Info: netifaces2, netaddr
       • DNS: dnspython
       • HTTP: requests
    
    ☁️  Additional Utilities
       • System Monitor: btop, nmon
       • System Info: fastfetch
       • File Manager: mc
       • BGP/Routing: bird
       • Archive Tools: bsdtar, bsdcpio, bsdcat, bsdunzip

    ─────────────────────────────────────────────────────────────────────────

    💡 QUICK START GUIDE
    ─────────────────────────────────────────────────────────────────────────
    
    # 🌐 Basic Connectivity
    ping -c 4 google.com                    # ICMP connectivity test
    curl -I https://example.com             # HTTP header inspection
    
    # 🔍 DNS Diagnostics
    drill example.com @8.8.8.8              # DNS query with specific server
    dig +trace example.com                  # DNS resolution path tracing
    
    # 🔎 Port Scanning
    nmap -p 80,443,8080 target.com          # Scan specific ports
    nmap -sV -sC target.com                 # Service version detection
    
    # 📈 Packet Analysis
    tcpdump -i eth0 -nn -w capture.pcap     # Capture packets to file
    termshark -r capture.pcap               # Interactive packet analysis
    
    # 📊 Performance Testing
    iperf3 -c server_ip -t 30               # Network bandwidth test
    fortio load -qps 1000 -t 30s http://target  # HTTP load testing
    ab -n 1000 -c 10 http://example.com/    # Apache benchmark
    
    # 🌐 HTTP Testing
    http GET https://api.example.com/health # HTTPie GET request
    curl -X POST https://api.example.com/data -d '{"key":"value"}'
    
    # 🛣️  Route Analysis
    mtr -b -c 100 google.com                # MTR with report mode
    trippy google.com                       # Modern traceroute TUI
    
    # 📦 Container & K8s
    ctop                                    # Container metrics viewer
    kubectl get pods -A                     # List all pods
    k get pods -A                           # Same as above with kubecolor
    kubectx                                 # Switch Kubernetes contexts
    kubens                                  # Switch Kubernetes namespaces
    kubelogin                               # Authenticate to clusters (OIDC)
    calicoctl node status                   # Calico node status
    
    # 🐛 Network Debugging
    ss -tulpn                               # Show listening sockets
    netstat -tulanp                         # All network connections
    lsof -i                                 # Files opened by network processes
    
    # 🔌 Advanced Protocol Testing
    grpcurl -plaintext localhost:50051 list # List gRPC services
    websocat ws://echo.websocket.events     # WebSocket testing
    swaks --to user@example.com --server smtp.example.com  # SMTP test

    ─────────────────────────────────────────────────────────────────────────

    🎯 PRODUCTIVITY ALIASES
    ─────────────────────────────────────────────────────────────────────────
    
    📊 System & Info              📂 File Operations
    • ff         → fastfetch      • ll         → ls -lah
    • sysinfo    → btop            • la         → ls -A
    • lle        → eza --long --git --icons -lahgHF --group-directories-first
    • k          → kubecolor (kubectl with colors)
    
    🌐 Network Shortcuts          🚀 Quick Actions
    • ports      → netstat -tulanp • c          → clear
    • listening  → ss -tulpn       • e          → exit
    • routes     → ip route show   • h          → history
    • myip       → curl -s ifconfig.me
    • connections → ss -tanp
    • help        → Show FNXNT toolkit guide

    ─────────────────────────────────────────────────────────────────────────

    📊 TOOL VERSIONS (Latest as of November 2026)
    ─────────────────────────────────────────────────────────────────────────
    
    • ctop       v0.7.7          • grpcurl     v1.9.4
    • calicoctl  v3.33.0         • fortio      v1.76.0
    • termshark  v2.4.0          • websocat    v1.14.1
    • trippy     v0.13.0         • hey         v0.1.5
    • kubectl    latest stable   • Alpine      3.24.4
    • kubecolor  v0.8.0          • kubectx    v0.11.0
    • kubens     v0.11.0         • kubelogin  v1.36.4

    ─────────────────────────────────────────────────────────────────────────

    🔗 RESOURCES & DOCUMENTATION
    ─────────────────────────────────────────────────────────────────────────
    
    • Upstream Project: nicolaka/netshoot
      └─ https://github.com/nicolaka/netshoot
    
    • FNXNT Enhancements: Production optimizations, curated extras
      └─ Multi-stage builds, security hardening, modern tools
    
    • License Information: /usr/share/licenses/fnxnt/
      └─ cat /usr/share/licenses/fnxnt/README

    ─────────────────────────────────────────────────────────────────────────

    📜 LICENSING
    ─────────────────────────────────────────────────────────────────────────
    
    • Original netshoot components  → Apache License 2.0 (nicolaka)
    • FNXNT enhancements           → MIT License (Daniel G. Cosenza from FNX Labs)
    • Third-party tools            → Various OSS licenses (see docs)

    ═════════════════════════════════════════════════════════════════════════
    
    💬 Ready to debug! Type 'help' to reopen this guide, press <Tab> to explore completions.

BANNER
}

if command -v lolcat >/dev/null 2>&1 && [ -t 1 ]; then
    fnxnt_print_banner | lolcat -f
else
    fnxnt_print_banner
fi
