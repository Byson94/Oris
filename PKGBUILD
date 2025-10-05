pkgname="atlasis"
pkgver="0.1.0"
pkgrel="1"
pkgdesc="Atlasis desktop environment"
arch=("x86_64")
depends=(
    # core libs
    "niri"

    # User Interface
    "ewwii"
    "swww"
    "hyprlock"
)

package() {
    mkdir -p "${pkgdir}/usr/"
    
    cp -r "$srcdir/bin" "$pkgdir/usr/"
    cp -r "$srcdir/share/." "$pkgdir/usr/share/"
    cp -r "$srcdir/share/wayland-sessions/"* "$pkgdir/usr/share/wayland-sessions/"
}