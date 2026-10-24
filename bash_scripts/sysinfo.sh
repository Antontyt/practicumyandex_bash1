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

main() {
    local parsed
    if ! parsed=$(getopt -o '' -l help -n "${0##*/}" -- "$@"); then
        usage >&2
        exit 2
    fi
    eval set -- "$parsed"

    while true; do
        case "$1" in
            --help) usage; exit 0 ;;
            --) shift; break ;;
            *) echo "Internal error while parsing options" >&2; exit 3 ;;
        esac
    done

    usage
}

main "$@"