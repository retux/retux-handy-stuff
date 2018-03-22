#!/usr/bin/env bash


function usage {
    echo "This script will create a bootstrap 4 project in your current directory."
    echo "You can select whether to use bootstrap files locally or to use cdn."
    echo "Usage:"
    echo
    echo "${0} --local-files | --cdn"

}


function use_dist_files {
    echo "[info] Downloading bootstrap"
    if [[ ! -f /tmp/bootstrap.zip ]]
    then
        wget -O /tmp/bootstrap.zip http://getbootstrap.com/2.3.2/assets/bootstrap.zip
    else
        echo "[info] File already exists, I won't download it."
    fi
    if [[ ! -f /tmp/jquery-migrate-3.0.0.min.js ]]
    then
        wget -O /tmp/jquery-migrate-3.0.0.min.js https://code.jquery.com/jquery-migrate-3.0.0.min.js
    else
        echo "[info] Jquery file already exists, I won't download it."
    fi
    wget -O /tmp/index.html https://raw.githubusercontent.com/BlackrockDigital/startbootstrap-bare/master/index.html 
    pushd /tmp
    unzip -o bootstrap.zip
    popd
    mkdir -p vendor/bootstrap
    mkdir -p vendor/jquery
    for each in `ls /tmp/bootstrap`
    do
        cp -a /tmp/bootstrap/${each} vendor/bootstrap
    done
    cp /tmp/jquery-migrate-3.0.0.min.js vendor/jquery/jquery.min.js
    cp /tmp/index.html .   
    sed -i 's/bootstrap\.bundle\.min\.js/bootstrap\.min\.js/g' index.html
    pwd
    create_index_local
}


function release_resources {
    rm -f /tmp/index.html
    rm -f /tmp/bootstrap.zip
    rm -f /tmp/jquery-migrate-3.0.0.min.js
}


function use_cdn {
    tee index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Bootstrap 101 Template</title>

    <!-- Bootstrap -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
    <!-- Optional theme -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body>
    <h1>Hello, world!</h1>

    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <!-- If you wanna use jquery over CDN -->
    <!-- Latest compiled and minified JavaScript -->
    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
</body>
</html>
EOF
}


function create_index_local {
    tee index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Bootstrap 101 Template</title>

    <!-- Bootstrap -->
    <link href="vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body>
    <h1>Hello, world!</h1>

    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <!-- If you wanna use jquery over CDN -->
    <!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script> -->
    <script src="vendor/jquery/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="vendor/bootstrap/js/bootstrap.min.js"></script>
</body>
</html>
EOF
}


function main {
    if [[ -z ${1} ]]
    then
        usage
        exit 1
    fi
    TYPE="${1}"
    case "${TYPE}" in
        --local-files)
            use_dist_files
            ;;
        --cdn)
            use_cdn
            ;;
        *)
            usage
            exit 1
    esac
}


main $*
trap release_resources EXIT

