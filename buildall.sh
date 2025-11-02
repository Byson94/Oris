#!/bin/bash
set -euo pipefail

dirs=("oris-ewwii-plugins" "oris-uscfg" "oris-misc-pkgs" ".")
install_flag=false
pkg_files=()

if [[ "${1:-}" == "--install" || "${1:-}" == "-i" ]]; then
    install_flag=true
fi

for dir in "${dirs[@]}"; do
    echo "=============================="
    echo "Building $dir"
    echo "=============================="
    
    if [ -d "$dir" ]; then
        pushd "$dir" > /dev/null
        makepkg -f
        latest_pkg=$(ls -t *.pkg.tar.* 2>/dev/null | head -n1 || true)
        if [[ -n "$latest_pkg" ]]; then
            pkg_files+=("$(realpath "$latest_pkg")")
        fi
        popd > /dev/null
    else
        echo "Directory $dir does not exist, skipping."
    fi
done

if $install_flag && [[ ${#pkg_files[@]} -gt 0 ]]; then
    echo "=============================="
    echo "Installing all built packages..."
    echo "=============================="
    sudo pacman -U "${pkg_files[@]}"
fi

echo "All builds finished."
