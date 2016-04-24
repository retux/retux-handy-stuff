#!/usr/bin/env bash
# jsonobjs.sh: Json as complex data structures for Bash
#
#  Use hash or dictionaries in bash is quite hard and complex,
#    My friend @kaminoo gave me a simple but powerfull idea for
#    this: why not to use json objects to represents complex objets
#    or data structures in bash. This is handy when you need to stick
#    to bash and not to move to more powerfull scripting languages like
#    python, perl or ruby among others.
#    Better use bash version 4 at least, for using assoatives arrays.
# Just for testing porpouse whe get a set of filesystem objects:
#
#

jsonObject='{'
 
if [ -z "$1" ]; then
	WKD='.'
else
	WKD="$1"
fi

function usage {
	echo "$0 <directory>"
	echo
	echo "If directory not provided will list current working dir."
	exit 1
}

function filljson {
	# -A is an associative array (hash)
	declare -A myFile
	IFS="$(printf '\n\t')"
	for i in `ls -lrti $1 | grep -v total`
	do
		#echo $i
		#echo 

		myFile[inode]=`echo $i | awk '{print $1}'`
		myFile[perms]=`echo $i | awk '{print $2}'`
		myFile[links]=`echo $i | awk '{print $3}'`
		myFile[user]=`echo $i | awk '{print $4}'`
		myFile[group]=`echo $i | awk '{print $5}'`
		myFile[fsize]=`echo $i | awk '{print $6}'`
		myFile[date]=`echo $i | awk '{print $7}'`
		myFile[date]+=" "`echo $i | awk '{print $8}'`
		myFile[date]+=" "`echo $i | awk '{print $9}'`
		myFile[fname]=`echo $i | awk '{print $10}'`
		
		jsonObject+=" \"${myFile[fname]}\": { \"inode\": ${myFile[inode]}, \"perms\": \"${myFile[perms]}\", \"links\": ${myFile[links]}, \
\"user\": \"${myFile[user]}\", \"group\": \"${myFile[group]}\", \"fsize\": ${myFile[fsize]}, \"date\": \"${myFile[date]}\" },"
		unset $myFile
	done
	jsonObject=`echo $jsonObject | sed -e 's/,$//'`	
	jsonObject+='}'
	echo $jsonObject
} 

if [ "$1" == "--help" ]; then
	 usage
fi
filljson $WKD
