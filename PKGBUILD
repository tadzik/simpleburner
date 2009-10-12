# Maintainer: Marcin Karpezo <sirmacik at gmail dot com>
pkgname=simpleburner-git
pkgver=20091012
pkgrel=1
pkgdesc="To make Your burning CD/DVD's easier under the CLI environment"
arch=('i686' 'x86_64')
url="http://sirmacik.net/simpleburner/"
license=('BSD')
depends=('python' ' cdrkit')
makedepends=('git')
source=()
md5sums=()

_gitname="simpleburner"
_gitroot="  git://repo.or.cz/${_gitname}.git"

build() {
    cd ${startdir}/src
    
    if [[ -d ${startdir}/src/${_gitname} ]]; then
        cd ${_gitname}
        git pull origin || return 1
    else
        git clone ${_gitroot} || return 1
    fi
    
    mkdir -p ${startdir}/pkg/usr/bin
    install -Dm 755 ${startdir}/src/${_gitname}/${_gitname}.py ${startdir}/pkg/usr/bin/${_gitname}
}
