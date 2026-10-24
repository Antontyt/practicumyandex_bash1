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

print_host_info() {
    echo "=== Host information ==="
}

print_user_info() {
    echo "=== User information ==="
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
