#!/bin/bash

#### USER SETTINGS
WORKING_DIR=/home/matias/nginx_build
NGINX_VERSION=1.13.2

### REMEMBER This scripts requires your user to gave sudo rights


function check_dependencies {
    echo "[info]Remember buddy you will need sudo permissions for your user: "
	echo 
	echo "$ su"
    echo "# visudo"
    echo "Add at the bottom of the file: your_username_here ALL=(ALL)       ALL"
	
	echo
	if [ ! $(type -P gzip) ]; then
	    echo "[error] Gzip bin was not found. Stopped!"
		exit 1
	fi
	
	if [ ! $(type -P unzip) ]; then
	    echo "[error] Gzip bin was not found. Stopped!"
		exit 1
	fi
	
	if [ ! $(type -P wget) ]; then
	    echo "[error] Gzip bin was not found. Stopped!"
		exit 1
	fi
}


function install_predependencies {
    cd ${WORKING_DIR}
    echo "Install Development Tools"
    sudo apt-get install -y build-essential
    sudo apt-get install -y unzip wget
    echo "Install Extra Packages"
    echo "----------------------"
	echo
    echo "Install optional NGINX dependencies (using pkg manager):"
    sudo apt-get install -y perl perl-devel perl-ExtUtils-Embed libxslt libxslt-devel libxml2 libxml2-devel gd gd-devel GeoIP GeoIP-devel
}


function uninstall_predependencies {
    echo "Uninstall Development Tools"
    sudo apt-get remove -y build-essential
    sudo apt-get remove -y unzip wget
    echo "Uninstall Extra Packages"
    echo "----------------------"
	echo
    echo "Uninstall optional NGINX dependencies (using pkg manager):"
    sudo apt-get install -y perl perl-devel perl-ExtUtils-Embed libxslt libxslt-devel libxml2 libxml2-devel gd gd-devel GeoIP GeoIP-devel
}


function download_nginx {
    echo "Download the latest mainline version of NGINX source code."
    cd ${WORKING_DIR}
    if [[ $? -ne 0 ]]; then
        echo "[Error] Could not cd into ${WORKING_DIR}."
    fi
    wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar zxvf nginx-${NGINX_VERSION}.tar.gz
    echo "[info] Download the NGINX dependencies' source code and extract them."
    echo "[info] NGINX depends on 3 libraries: PCRE, zlib and OpenSSL"
    # PCRE version 8.40
    wget https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.gz && tar xzvf pcre-8.40.tar.gz
    # zlib version 1.2.11
    wget https://www.zlib.net/zlib-1.2.11.tar.gz && tar xzvf zlib-1.2.11.tar.gz

    # OpenSSL version 1.1.0f
    wget https://www.openssl.org/source/openssl-1.1.0f.tar.gz && tar xzvf openssl-1.1.0f.tar.gz
    echo "[info] Download nginx-module-vts module"
    wget https://github.com/vozlt/nginx-module-vts/archive/master.zip
    if [[ $? -ne 0 ]]; then
        echo "[Error] while downloading nginx-module-vts module. Stopped!"
	    exit 1
    fi
    unzip nginx-module-vts-master.zip 
    wget https://github.com/vozlt/nginx-module-vts/archive/master.zip
    if [[ $? -ne 0 ]]; then
        echo "[Error] while uncompressing nginx-module-vts module. Stopped!"
	    exit 1
    fi
    #Remove all .tar.gz files. We don't need them anymore:
    rm -f *.tar.gz
    rm -f *.zip
}


function build_nginx {
    # // If extra modules are needed add them to this function.
    echo "[info] cd into NGINX source directory, and start build:"
    cd ./nginx-${NGINX_VERSION}
    echo "[info] files in nginx-${NGINX_VERSION} directory."
    ls

    echo "[info] Copying NGINX manual page to /usr/share/man/man8"
    sudo cp ./nginx-${NGINX_VERSION}/man/nginx.8 /usr/share/man/man8
    sudo gzip /usr/share/man/man8/nginx.8
    
    echo "[info] Configure nxing-${NGINX_VERSION}:" 
    echo "[info] To see want core modules can be build as dynamic run."
    
    ./configure --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --modules-path=/usr/lib64/nginx/modules \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --user=nginx \
            --group=nginx \
            --build=CentOS \
            --builddir=nginx-1.13.2 \
            --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_xslt_module=dynamic \
            --with-http_image_filter_module=dynamic \
            --with-http_geoip_module=dynamic \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_auth_request_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_degradation_module \
            --with-http_slice_module \
            --with-http_stub_status_module \
            --http-log-path=/var/log/nginx/access.log \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --with-mail=dynamic \
            --with-mail_ssl_module \
            --with-stream=dynamic \
            --with-stream_ssl_module \
            --with-stream_realip_module \
            --with-stream_geoip_module=dynamic \
            --with-stream_ssl_preread_module \
            --with-compat \
            --with-pcre=../pcre-8.40 \
            --with-pcre-jit \
            --with-zlib=../zlib-1.2.11 \
            --with-openssl=../openssl-1.1.0f \
            --with-openssl-opt=no-nextprotoneg \
            --with-debug \
			--add-module=./nginx-module-vts-master
    make 
    sudo make install

    echo "[info ]Symlink /usr/lib/nginx/modules to /etc/nginx/modules directory, so that you can load dynamic modules in nginx configuration like this load_module modules/ngx_foo_module.so;:"
    sudo ln -s /usr/lib64/nginx/modules /etc/nginx/modules
}


function usage {
    echo "Install nginx web server from source."
	echo "${0} <option>}"
	echo
	echo "Optional options are:"
	echo "    --check_dependencies: will check script dependencies."
	echo "    --install_predependencies: install dev packages binaries nginx depends on."
	echo "    --uninstall_predependencies: install dev packages binaries nginx depends on."
	echo "    --download_nginx: download nginx source code."
	echo "    --build_nginx: build nginx."
}

function full_install {
    check_dependencies    
	install_predependencies
	download_nginx
	build_nginx
}

function main {
    if [[ ${1} == "--help" ]]; then
	    usage
	fi

	case "$1" in
        --check_dependencies)  echo "[info] Check nginx dependencies ... "
        check_dependencies
        ;;
        --install_predependencies)  echo  "[info] Install nginx pre-depdencies ... "
        install_predependencies
        ;;
        --download_nginx)  echo  "[info] Download nginx source ... "
        download_nginx
        ;;
        --build_nginx) echo  "[info] Build nginx"
        build_nginx
        ;;
		--full_install) echo  "[info] Full install started ..."
        full_install
        ;;
        *) echo "[info] Full install started ..."
		full_install
        ;;
    esac
}

main $*