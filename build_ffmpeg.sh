#!/bin/bash

# DEPENDENCIES-BASE: git, mercurial, curl, tar, gcc, g++, make, libtool, automake, autoconf, pkg-config, cmake, bison, flex
# DEPENDENCIES?: libexpat, libpng
# DEPENDENCIES: libfontconfig-devel, libfreetype2-devel, libbz2-devel, librubberband-devel, libfftw3-devel

set -u
set -e


git_clone_ie() # git clone ignore error
{
    git clone $1 $2 || true
}

git_get_fresh()
{
    echo "FETCH/CLEAN $1"
    git_clone_ie $2 $1
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)
    cd $1
    git fetch -p
    git clean -fdx
    git checkout -- .
    cd $CURRENT_DIR
}

git_get_frver() # fresh with version
{
    git_get_fresh $1 $3
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)
    cd $1
    git checkout $2
    cd $CURRENT_DIR
}

dl_tar_gz_fre()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    echo "CLEAN/DOWNLOAD/UNTAR $1"

    rm -rf "$1"

    mkdir "$1"
    cd "$1"

    curl -o tmp.tar.gz -L $2
    tar -xzvf tmp.tar.gz --strip-components=1
    rm tmp.tar.gz

    cd $CURRENT_DIR
}

autogen_src()
{
    echo "AUTOGEN $1"

    ./autogen.sh
}

configure_src()
{
    echo "CONFIGURE $1"

    echo ./configure \
        --prefix=$OUT_PREFIX \
        "${@:2}"
    ./configure \
        --prefix=$OUT_PREFIX \
        "${@:2}"
}

config_src()
{
    echo "CONFIGURE $1"

    echo ./config \
         --prefix=$OUT_PREFIX \
         "${@:2}"
    ./config \
        --prefix=$OUT_PREFIX \
        "${@:2}"
}

cmake_src()
{
    echo "CMAKE $1"

    echo cmake . \
         -G "Unix Makefiles" \
         -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=$OUT_PREFIX \
         "${@:2}"
    cmake . \
          -G "Unix Makefiles" \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=$OUT_PREFIX \
          "${@:2}"
}

cmake_sp_src()
{
    echo "CMAKE $1"

    echo cmake "$2" \
         -G "Unix Makefiles" \
         -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=$OUT_PREFIX \
         "${@:3}"
    cmake "$2" \
          -G "Unix Makefiles" \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=$OUT_PREFIX \
          "${@:3}"
}

make_src()
{
    echo "MAKE $1"

    make
    make install
}

make_iie_src() # ignore install error
{
    echo "MAKE $1"

    make
    make install || true
}

compile_with_configure()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    configure_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
}

compile_with_config_sp() # subpath, not necessarily needed
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1
    cd $2

    configure_src "$1" "${@:3}"
    make_src "$1"

    cd $CURRENT_DIR
}

compile_with_config()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    config_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
}

compile_with_autogen()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    autogen_src "$1"
    configure_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
}

compile_with_autog_iie()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    autogen_src "$1"
    configure_src "$@"
    make_iie_src "$1"

    cd $CURRENT_DIR
}

compile_with_cmake()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    cmake_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
}
compile_with_cmake_sp()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1
    cd $2

    cmake_sp_src "$1" "$3" "${@:4}"
    make_src "$1"

    cd $CURRENT_DIR
}

compile_ffnvcodec()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    echo "MAKE $1"

    make install PREFIX=$OUT_PREFIX

    cd $CURRENT_DIR
}

compile_c2man()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    echo "C2MAN CONFIGURE $1"

    ./Configure -dE

    echo "binexp=$OUT_BIN" >> config.sh
    echo "installprivlib=$OUT_PREFIX" >> config.sh
    echo "mansrc=$OUT_PREFIX" >> config.sh
    sh config_h.SH
    sh flatten.SH
    sh Makefile.SH

    echo "MAKE $1"

    make depend
    make
    make install

    cd $CURRENT_DIR
}



# set path vars
WD=$(pwd)
SRC=$WD/src

OUT_PREFIX=$WD/ffmpeg_build
OUT_BIN=$WD/ffmpeg_bin
OUT_PKG_CONFIG=$OUT_PREFIX/lib/pkgconfig

export PATH="$OUT_BIN:$PATH"
export PKG_CONFIG_PATH=$OUT_PKG_CONFIG

rm -rf $OUT_PREFIX
rm -rf $OUT_BIN

mkdir -p $OUT_PREFIX
mkdir -p $OUT_BIN
mkdir -p $SRC


# get source
cd $SRC
git_get_fresh  ffmpeg                     https://git.ffmpeg.org/ffmpeg.git
git_get_frver  nasm         nasm-2.13.03  http://repo.or.cz/nasm.git
git_get_fresh  yasm                       git://github.com/yasm/yasm.git
git_get_fresh  libx264                    http://git.videolan.org/git/x264.git
git_get_fresh  libx265                    https://github.com/videolan/x265
git_get_fresh  libopus                    https://github.com/xiph/opus.git
git_get_fresh  libogg                     https://github.com/xiph/ogg.git
git_get_fresh  libvorbis                  https://github.com/xiph/vorbis.git
git_get_fresh  libvpx                     https://chromium.googlesource.com/webm/libvpx
# git_get_fresh  freetype2                  git://git.sv.nongnu.org/freetype/freetype2.git
git_get_fresh  fontconfig                 git://anongit.freedesktop.org/fontconfig
git_get_frver  frei0r       v1.6.1        https://github.com/dyne/frei0r.git
git_get_fresh  fribidi                    https://github.com/fribidi/fribidi.git
git_get_frver  libass       9a2b38e8f595  https://github.com/libass/libass.git
git_get_fresh  libopenjpeg                https://github.com/uclouvain/openjpeg.git
git_get_fresh  libsoxr                    https://git.code.sf.net/p/soxr/code
git_get_fresh  libspeex                   https://github.com/xiph/speex.git
git_get_fresh  openssl                    git://git.openssl.org/openssl.git
git_get_fresh  libtheora                  https://github.com/xiph/theora.git
git_get_fresh  libvidstab                 https://github.com/georgmartius/vid.stab.git
git_get_fresh  libwebp                    https://chromium.googlesource.com/webm/libwebp
git_get_fresh  ffnvcodec                  https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
git_get_fresh  c2man                      https://github.com/fribidi/c2man.git

dl_tar_gz_fre  lame      http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
dl_tar_gz_fre  xvidcore  https://downloads.xvid.com/downloads/xvidcore-1.3.5.tar.gz
cd $WD



compile_with_autog_iie nasm \
                       --bindir=$OUT_BIN

compile_with_autogen   yasm \
                       --bindir=$OUT_BIN

compile_c2man          c2man

# update table
hash -r

compile_with_configure libx264 \
                       --bindir=$OUT_BIN \
                       --enable-static \
                       --enable-pic

compile_with_cmake_sp  libx265 build/linux ../../source \
                       -DENABLE_SHARED:bool=off

compile_with_autogen   libopus \
                       --disable-shared

# compile libogg (dependency of libvorbis)
compile_with_autogen   libogg \
                       --disable-shared

compile_with_autogen   libvorbis \
                       --with-ogg=$OUT_PREFIX \
                       --disable-shared

compile_with_configure libvpx \
                       --disable-examples \
                       --disable-unit-tests \
                       --enable-vp9-highbitdepth \
                       --as=yasm

compile_with_configure lame \
                       --bindir=$OUT_BIN \
                       --disable-shared \
                       --enable-nasm

# compile fribidi (dependency of libass)
compile_with_autogen   fribidi \
                       --bindir=$OUT_BIN \
                       --disable-shared

compile_with_autogen   libass \
                       --bindir=$OUT_BIN \
                       --disable-shared

compile_with_cmake     libopenjpeg \
                       -DBUILD_SHARED_LIBS=OFF

compile_with_cmake     libsoxr \
                       -Wno-dev \
                       -DBUILD_SHARED_LIBS:BOOL=OFF \
                       -DBUILD_TESTS:BOOL=OFF \
                       -DWITH_OPENMP=OFF

compile_with_autogen   libspeex \
                       --disable-shared

compile_with_config    openssl

compile_with_autogen   libtheora \
                       --disable-shared

compile_with_config_sp xvidcore build/generic

compile_with_cmake     libvidstab \
                       -DBUILD_SHARED_LIBS=OFF

compile_with_autogen   libwebp

compile_with_autogen   frei0r

compile_ffnvcodec      ffnvcodec

compile_with_configure ffmpeg \
                       --bindir=$OUT_BIN \
                       --pkg-config-flags="--static" \
                       --extra-cflags="-I$OUT_PREFIX/include" \
                       --extra-ldflags="-L$OUT_PREFIX/lib" \
                       --extra-libs=-lpthread \
                       --extra-libs=-lm \
                       --extra-libs=-lmvec \
                       --extra-ldexeflags="-static" \
                       --enable-pthreads \
                       --enable-gpl \
                       --enable-libx264 \
                       --enable-libx265 \
                       --enable-libopus \
                       --enable-libvorbis \
                       --enable-libvpx \
                       --enable-libmp3lame \
                       --enable-fontconfig \
                       --enable-libopenjpeg \
                       --enable-libspeex \
                       --enable-network \
                       --enable-libtheora \
                       --enable-libsoxr \
                       --enable-libxvid \
                       --enable-libvidstab \
                       --enable-libwebp \
                       --enable-libass \
                       --enable-libfreetype \
                       --enable-libfribidi \
                       --enable-frei0r \
                       --enable-avfilter \
                       --enable-avresample \
                       --enable-bzlib \
                       --enable-zlib \
                       --enable-hardcoded-tables \
                       --enable-iconv \
                       --enable-postproc \
                       --disable-debug \
                       --enable-runtime-cpudetect \
                       --enable-manpages \
                       --enable-nvenc \
                       --enable-nonfree \
                       --enable-openssl

