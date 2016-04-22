#!/bin/bash

usage()
{
cat << EOF
usage: $0 options
OPTIONS:

  -h | --config-file	Show this message.
  -b | --bucket-name    S3 bucket name.
  -c | --config-file    s3cmd config file (with keys)

Examples:

$0 --config-file /etc/myconfig --bucket-name myFortune
EOF
}

help=0

# This is where getops short and long options are configured: 
# options may be followed by one colon to indicate they have a required argument
# This example uses: -h or --help (no extra parameter),
# -c /path/to/file or --config-file /path/to/file
# -b <bucketname> or --bucket-name
if ! options=$(getopt -o hc:b: -l help,config-file:,bucket-name: -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

while [ $# -gt 0 ]
do
    case $1 in
    -h|--help) help=1 ;;
    # for options with required arguments, an additional shift is required
    -c|--config-file) config_file="$2" ; shift;;
    -b|--bucket-name) bucket_name="$2" ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*) break;;
    esac
    shift
done

# remove ' character
config_file=`echo $config_file | sed -e "s/'//g"`
bucket_name=`echo $bucket_name | sed -e "s/'//g"`


#BOF just for testing porpouse
echo "help:"$help
echo "config_file:"$config_file
echo "bucket_name:"$bucket_name
#EOF

if [ $help -ne 0 ]; then
	usage
fi

if [ -z $config_file ]; then
	echo "No config file provided buddy!. It's mandatory."
	echo
	usage
	exit 1
fi

if [ ! -f "$config_file" ]; then
	echo "Config file does not exist fella. Get smarter!"
	echo
	usage
	exit 1
fi

if [ -z $bucket_name ]; then
	echo "No bucket name provided buddy!. It's mandatory."
	echo
	usage
	exit 1
fi

# And, finally do your stuff here.
