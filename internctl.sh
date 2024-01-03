#!/bin/bash

# internsctl - Custom Linux command
# Version: v0.1.0

function show_help() {
    echo "Usage: internsctl [options] <command>"
    echo "Options:"
    echo "  --help           Show help information"
    echo "  --version        Show version information"
    echo "Commands:"
    echo "  cpu getinfo      Get CPU information"
    echo "  memory getinfo   Get memory information"
    echo "  user create      Create a new user"
    echo "  user list        List all regular users"
    echo "  user list --sudo-only List users with sudo permissions"
    echo "  file getinfo     Get information about a file"
    echo "  file getinfo [options] <file-name>"
    echo "    --size, -s             Print file size"
    echo "    --permissions, -p      Print file permissions"
    echo "    --owner, -o            Print file owner"
    echo "    --last-modified, -m    Print last modified time"
}

function show_version() {
    echo "internsctl v0.1.0"
}

function get_cpu_info() {
    lscpu
}

function get_memory_info() {
    free
}

function create_user() {
    if [ $# -eq 2 ]; then
        sudo useradd -m $2
        echo "User $2 created successfully."
    else
        echo "Usage: internsctl user create <username>"
    fi
}

function list_users() {
    if [ "$2" == "--sudo-only" ]; then
        getent passwd | grep -E 'sudo|admin' | cut -d: -f1
    else
        getent passwd | cut -d: -f1
    fi
}

function get_file_info() {
    local file_name=$2

    if [ -z "$file_name" ]; then
        echo "Usage: internsctl file getinfo <file-name>"
        return
    fi

    if [ ! -e "$file_name" ]; then
        echo "File not found: $file_name"
        return
    fi

    local size=$(wc -c < "$file_name")
    local permissions=$(stat -c "%A" "$file_name")
    local owner=$(stat -c "%U" "$file_name")
    local last_modified=$(stat -c "%y" "$file_name")

    case "$3" in
        "--size" | "-s") echo $size ;;
        "--permissions" | "-p") echo $permissions ;;
        "--owner" | "-o") echo $owner ;;
        "--last-modified" | "-m") echo $last_modified ;;
        *) 
            echo "File: $file_name"
            echo "Access: $permissions"
            echo "Size(B): $size"
            echo "Owner: $owner"
            echo "Modify: $last_modified"
    esac
}

# Main script logic
case "$1" in
    "cpu" )
        case "$2" in
            "getinfo" ) get_cpu_info ;;
            * ) show_help ;;
        esac
        ;;
    "memory" )
        case "$2" in
            "getinfo" ) get_memory_info ;;
            * ) show_help ;;
        esac
        ;;
    "user" )
        case "$2" in
            "create" ) create_user $@ ;;
            "list" ) list_users $@ ;;
            * ) show_help ;;
        esac
        ;;
    "file" )
        case "$2" in
            "getinfo" ) get_file_info $@ ;;
            * ) show_help ;;
        esac
        ;;
    "--help" ) show_help ;;
    "--version" ) show_version ;;
    * ) show_help ;;
esac
