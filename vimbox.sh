#!/bin/bash


mkdir -p $HOME/.vimbox || exit 1
ln -sf $HOME/.vimbox /tmp/.vimbox || exit 1
vimbox_dir=$HOME/.vimbox

gcc_dir=/tmp/opt/gcc6.4.0
glibc_dir=/tmp/opt/glibc

python_dir=${vimbox_dir}/py2.7
base_pkg_dir=${vimbox_dir}/base
vim_dir=${vimbox_dir}/vim

vim_conf_dir=${vimbox_dir}/dconf
gcc_linker="-Wl,--rpath=${glibc_dir}/lib:${gcc_dir}/lib64:${base_pkg_dir}/lib:/lib64:/usr/lib64:/lib -Wl,--dynamic-linker=${glibc_dir}/lib/ld-2.18.so"

default_cc="gcc -O3 -I${glibc_dir}/include -B${glibc_dir}/lib"
default_cxx="c++ -I${glibc_dir}/include -B${glibc_dir}/lib"
current_dir=`pwd`
ln -sf ${current_dir} ${vimbox_dir}/build

RESET="\x1b[0m";
RED_BOLD="\x1b[1;31m";
YELLOW_BOLD="\x1b[1;33m";

ncurses_pkg=ncurses-5.8.tar.gz
openssl_pkg=openssl-1.0.2p.tar.gz
sqlite_pkg=sqlite-autoconf-3250200.tar.gz
zlib_pkg=zlib-1.2.11.tar.gz
termcap_pkg=termcap-1.3.1.tar.gz
readline_pkg=readline-4.3.tar.gz
python_pkg=Python-2.7.10.tgz
vim_pkg=vim-8.1.tar.bz2
md5txt=md5sum.txt

export PATH=${gcc_dir}/bin:$PATH
export CC=${default_cc}
export CXX=${default_cxx}

function notice() { echo -e "${YELLOW_BOLD} notice: ${1} ${RESET}"; }
function error() { echo -e "${RED_BOLD} error: ${1} ${RESET}" && exit 1; }

function curl_pkg() {
    pkg=$1
    curl -O  $pkg || error "download ${pkg}"
}


function download_pkg() {
    if [ ! -f "$gcc_dir/bin/gcc" ]; then
        notice "downloading gcc"
        # wget https://github.com/iohub/vimbox/releases/download/gcc6.4.0-prebuilt/gcc6.4.0-glibc2.18-linux-86_64.tar.xz
        mkdir -p $HOME/.opt
        ln -sf $HOME/.opt /tmp/opt
        notice "extract gcc"
        tar -xvJf gcc6.4.0-glibc2.18-linux-86_64.tar.xz -C /tmp/opt > /dev/null || error "extract gcc"
    fi
    if [ ! -f "$ncurses_pkg" ]; then
        curl_pkg https://ftp.gnu.org/gnu/ncurses/ncurses-5.8.tar.gz
    fi
    if [ ! -f "$openssl_pkg" ]; then
        curl_pkg https://www.openssl.org/source/openssl-1.0.2p.tar.gz
    fi
    if [ ! -f "$sqlite_pkg" ]; then
        curl_pkg https://sqlite.org/2018/sqlite-autoconf-3250200.tar.gz
    fi
    if [ ! -f "$zlib_pkg" ]; then
        curl_pkg https://zlib.net/zlib-1.2.11.tar.gz
    fi
    if [ ! -f "$termcap_pkg" ]; then
        curl_pkg https://ftp.gnu.org/gnu/termcap/termcap-1.3.1.tar.gz
    fi
    if [ ! -f "$readline_pkg" ]; then
        curl_pkg http://ftp.gnu.org/gnu/readline/readline-4.3.tar.gz
    fi
    if [ ! -f "$python_pkg" ]; then
        curl_pkg https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz
    fi
    if [ ! -f "$vim_pkg" ]; then
        curl_pkg https://ftp.osuosl.org/pub/blfs/conglomeration/vim/vim-8.1.tar.bz2
    fi
    if [ ! -f "$md5txt" ]; then
        curl_pkg https://raw.githubusercontent.com/iohub/vimbox/master/md5sum.txt
    fi
    md5sum -c $md5txt || error 'checksum'
}

function build_ncurses() {
    export CPPFLAGS="-P"
    rm -rf ncurses-5.8
    notice "extract ${ncurses_pkg}"
    tar xvzf ncurses-5.8.tar.gz > /dev/null
    cd ncurses-5.8
    notice "configure ncurses"
    ./configure --prefix=${base_pkg_dir} --with-shared  > config.log 2>&1 || error "build ncurses"
    notice "build ncurses"
    make > make.log 2>&1  || error "build ncurses"
    notice "install ncurses"
    make install || error "install ncurses"
    cd ..
    unset CPPFLAGS
}

function build_openssl() {
    rm -rf openssl-1.0.2p
    notice "extract ${openssl_pkg}"
    tar xvzf openssl-1.0.2p.tar.gz > /dev/null
    cd openssl-1.0.2p
    export CC="${default_cc}"
    export LDFLAGS=$gcc_linker
    notice "configure openssl"
    ./config shared  --prefix=${base_pkg_dir}  > config.log 2>&1 || error "configure openssl"
    notice "build openssl"
    make > make.log  2>&1 || error "build openssl"
    make install > install.log 2>&1 || error "install openssl"
    cd ..
}

function build_sqlite3() {
    rm -rf sqlite-autoconf-3250200
    notice "extract ${sqlite_pkg}"
    tar xvzf sqlite-autoconf-3250200.tar.gz
    cd sqlite-autoconf-3250200/
    notice "configure sqlite"
    ./configure --prefix=${base_pkg_dir} --enable-shared --disable-static  LDFLAGS="-lpthread" > config.log  2>&1 \
        || error "configure sqlite"
    notice "build sqlite"
    make > make.log  2>&1 || error "build sqlite"
    notice "install sqlite"
    make install > install.log 2>&1 || error "install sqlite"
    cd ..
}

# zlib-1.2.11
function build_zlib() {
    rm -rf zlib-1.2.11
    notice "extract zlib"
    tar xvzf zlib-1.2.11.tar.gz > /dev/null
    cd zlib-1.2.11
    ./configure --prefix=${base_pkg_dir}  > config.log 2>&1  || error "configure zlib"
    notice "build zlib"
    make > make.log 2>&1 || error "build zlib"
    notice "install zlib"
    make install > install.log 2>&1 || error "installl zlib"
    cd ..
}

function build_termcap() {
    rm -rf termcap-1.3.1
    notice "extract termcap"
    tar xvzf termcap-1.3.1.tar.gz > /dev/null
    cd termcap-1.3.1/
    notice "configure termcap"
    ./configure --prefix=${base_pkg_dir} > config.log  2>&1 || error "configure termcap"
    cat <<EOT >> Makefile

libtermcap.so:
	\$(CC) \$(HDRS) \$(SRCS) -fPIC -shared -o \$@
EOT

    notice "build termcap"
    make && make libtermcap.so > make.log 2>&1 || error "build termcap"
    make install > install.log 2>&1 || error "install termcap"
    rm ${base_pkg_dir}/lib/libtermcap.a
    cp libtermcap.so ${base_pkg_dir}/lib/ || exit 1
    cd ..
}

function build_readline() {
    rm -rf readline-4.3
    notice "extract readline"
    tar xvzf readline-4.3.tar.gz > /dev/null
    cd readline-4.3/
    export CC=${default_cc}
    export CXX=${default_cxx}
    notice "configure readline"
    ./configure --prefix=${base_pkg_dir} LDFLAGS=-L${base_pkg_dir}/lib > config.log 2>&1|| error "configure readline"
    notice "build readline"
    make > make.log 2>&1 || error "build readline"
    make install > install.log 2>&1|| error "install readline"
    cd ..
}

function build_deps() {
    build_ncurses
    build_openssl
    # build_sqlite3
    build_zlib
    build_termcap
    build_readline
}

function build_python2() {
    rm -rf Python-2.7.10
    notice "extract python"
    tar xvzf Python-2.7.10.tgz > /dev/null || error "extract python"
    cd Python-2.7.10
    SSL=${base_pkg_dir}

cat <<EOT >>  Modules/Setup.dist
readline readline.c -lreadline -ltermcap
_ssl _ssl.c \
        -DUSE_SSL -I${SSL}/include -I${SSL}/include/openssl \
        -L${SSL}/lib -lssl -lcrypto
_curses_panel _curses_panel.c -lpanel -lncurses
zlib zlibmodule.c -I${base_pkg_dir}/include -L${base_pkg_dir}/lib -lz
EOT

    export LD_LIBRARY_PATH=${gcc_dir}/lib64:${base_pkg_dir}/lib:$python_dir/lib:/lib64
    export CFLAGS="-I${base_pkg_dir}/include  -I${base_pkg_dir}/include/ncurses"
    PLINKER="-Wl,--rpath=/tmp/opt/build/Python-2.7.10:${python_dir}/lib:${glibc_dir}/lib:${gcc_dir}/lib64:${base_pkg_dir}/lib:/lib64:/usr/lib64:/lib -Wl,--dynamic-linker=${glibc_dir}/lib/ld-2.18.so"
    export LDFLAGS="-L${base_pkg_dir}/lib -L${gcc_dir}/lib64 -L/tmp/opt/glibc/lib ${PLINKER}"
    ./configure --prefix=$python_dir --enable-shared  --enable-unicode=ucs4 > config.log 2>&1 || error "configure python"
    notice "build python"
    make > make.log || error "build python"
    notice "install python"
    make install || error "install python"
    cd ..
}

function build_vim() {
    rm -rf vim81
    notice "extract vim"
    tar xvjf vim-8.1.tar.bz2 > /dev/null|| error "extract vim"
    cd vim81
    PYCONFIG=$python_dir/lib/python2.7/config
    PYHEADER=$python_dir/include/python2.7
    export PATH=${python_dir}/bin:$PATH
    export LDFLAGS="-L${base_pkg_dir}/lib -L${glibc_dir}/lib -L${gcc_dir}/lib64 -L${python_dir}/lib"
    export CC="${default_cc} -I${PYHEADER}"
    notice "configure vim"
    ./configure --enable-gui=no --without-x -with-features=huge \
        --prefix=$vim_dir --with-tlib=ncurses \
        --enable-pythoninterp=yes \
        --with-python-config-dir=$PYCONFIG > config.log 2>&1 || error "configure vim"
    notice "build vim"
    make > make.log 2>&1 || error "build vim"
    notice "install vim"
    make install > install.log 2>&1 || error "install vim"
    cp $vim_dir/bin/vim $vim_dir/bin/lvim
    cd ..
}

function init_vim() {
    echo 'downloading vimrc'
    VIMRC=https://gist.githubusercontent.com/iohub/b14d93b0fcdd47bb4aa85b53d05a84b9/raw
    HCONF=$vimbox_dir/vimconf
    curl $VIMRC -o vimrc
    echo 'installing vim-plug'
    curl -fLo $HCONF/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || error "install vim-plug"

    echo "set nocompatible" > vimrc.new
    echo "set rtp+=$HCONF" >> vimrc.new
    mkdir -p $HCONF/plugged
    echo "call plug#begin(\"$HCONF/plugged\")" >> vimrc.new
    cat vimrc >> vimrc.new
    mv vimrc.new vimrc
    cp -f vimrc $HCONF

    echo "export vim_dir=$vim_dir" > ${vimbox_dir}/env
    echo "export VIMRUNTIME=\$vim_dir/share/vim/vim81" >> ${vimbox_dir}/env
    echo "export LD_LIBRARY_PATH=$python_dir/lib:${base_pkg_dir}/lib:$gcc_dir/lib64" >> ${vimbox_dir}/env
    echo "export EDITOR=dvim" >> ${vimbox_dir}/env
    echo "export PATH=\$vim_dir/bin:\$GOHOME/bin:\$PATH" >> ${vimbox_dir}/env
    echo "alias vim='lvim -u $HCONF/vimrc'" >> ${vimbox_dir}/env
}


download_pkg
build_deps
build_python2
# build_vim
# init_vim
