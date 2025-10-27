# !/bin/bash
set -euo pipefail

dirs=("oris-ewwii-plugins" "oris-uscfg" "oris-misc-pkgs" ".")

for dir in "${dirs[@]}"; do
    echo "=============================="
    echo "Building $dir"
    echo "=============================="
    
    if [ -d "$dir" ]; then
        pushd "$dir" > /dev/null
        makepkg -f
        popd > /dev/null
    else
        echo "Directory $dir does not exist, skipping."
    fi
done

echo "All builds finished."
