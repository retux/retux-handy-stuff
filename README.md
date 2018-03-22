Ain't it handy?
--------------

This is just a set of simple scripts, but there are always handy.

getopts_base.sh: basic example for using getopts in bash. With both short and long options.

   IMPORTANT: getopts call should be outside of any function, because it reads parameters
passed to script.


create_bs4_project.sh:
=====================

This script will create a basic bootstrap 4 template to start working from.
Bootstrap template (index.html) and bootstrap files will be installed on you current
working directory.

create_bs4_project.sh --local-files 

Will download both bootstrap and jquery and copy them to you current directory.

and:

create_bs4_project.sh --use-cdn

Will create index.html and use bootstrap and jquery from its CDNs.


