#!/usr/bin/env bash
# sysinfo.sh - print information about the host and its users.

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: sysinfo.sh [OPTIONS]

Options:
  --host    print host information
  --user    print user information
  --help    show this help

Without options this help is printed.
EOF
}

get_cpu_cores() {
    grep -c '^processor' /proc/cpuinfo
}

get_memory_mb() {
    local field=$1
    awk -v f="${field}:" '$1 == f { printf "%d\n", $2 / 1024 }' /proc/meminfo
}

get_memory_used_mb() {
    awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {printf "%d\n", (t-a)/1024}' /proc/meminfo
}

get_disks() {
    df -P -x tmpfs -x devtmpfs -x overlay -x squashfs -x 9p -x drvfs -x rootfs |
        awk 'NR > 1 { printf "%s on %s: size %d MB, free %d%%\n", $1, $6, $2/1024, 100 - $5 }'
}

get_disk_io_errors() {
    if ! dmesg >/dev/null 2>&1; then
        echo "unavailable (no access to dmesg)"
        return
    fi
    dmesg | grep -ci 'i/o error'
}

get_network_info() {
    local path iface state ip4
    for path in /sys/class/net/*; do
        iface=${path##*/}
        state=$(cat "$path/operstate")
        ip4=$(ip -o -4 addr show dev "$iface" | awk '{print $4}' | paste -sd, -)
        echo "$iface: state=$state ip=${ip4:-none} rx_packets=$(cat "$path/statistics/rx_packets") tx_packets=$(cat "$path/statistics/tx_packets") errors(rx/tx)=$(cat "$path/statistics/rx_errors")/$(cat "$path/statistics/tx_errors")"
    done
}

get_listening_ports() {
    ss -tuln | awk 'NR > 1 { print $1, $5 }' | sort -u
}

print_host_info() {
    echo "=== Host information ==="
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Current time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Uptime: $(uptime -p)"
    echo "Load average: $(cut -d' ' -f1-3 /proc/loadavg)"
    echo "CPU cores: $(get_cpu_cores)"
    echo "Memory total: $(get_memory_mb MemTotal) MB"
    echo "Memory available: $(get_memory_mb MemAvailable) MB"
    echo "Memory used: $(get_memory_used_mb) MB"
    echo "Disks:"
    get_disks | sed 's/^/  /'
    echo "Disk I/O errors (kernel log): $(get_disk_io_errors)"
    echo "Network interfaces:"
    get_network_info | sed 's/^/  /'
    echo "Listening ports:"
    get_listening_ports | sed 's/^/  /'
}

get_all_users() {
    cut -d: -f1 /etc/passwd
}

get_root_users() {
    awk -F: '$3 == 0 { print $1 }' /etc/passwd
}

get_logged_in_users() {
    who | awk '{ print $1 }' | sort -u
}

print_user_info() {
    echo "=== User information ==="
    echo "All users:"
    get_all_users | sed 's/^/  /'
    echo "Root users (UID 0):"
    get_root_users | sed 's/^/  /'
    echo "Logged-in users:"
    get_logged_in_users | sed 's/^/  /'
}

main() {
    local parsed
    if ! parsed=$(getopt -o '' -l host,user,help -n "${0##*/}" -- "$@"); then
        usage >&2
        exit 2
    fi
    eval set -- "$parsed"

    local show_host=0 show_user=0

    while true; do
        case "$1" in
            --host) show_host=1; shift ;;
            --user) show_user=1; shift ;;
            --help) usage; exit 0 ;;
            --) shift; break ;;
            *) echo "Internal error while parsing options" >&2; exit 3 ;;
        esac
    done

    if (( ! show_host && ! show_user )); then
        usage
        exit 0
    fi

    if (( show_host )); then
        print_host_info
    fi
    if (( show_user )); then
        print_user_info
    fi
}

main "$@"
