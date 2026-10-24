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

print_host_info() {
    echo "=== Host information ==="
    echo "CPU cores: $(get_cpu_cores)"
    echo "Memory total: $(get_memory_mb MemTotal) MB"
    echo "Memory available: $(get_memory_mb MemAvailable) MB"
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
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
