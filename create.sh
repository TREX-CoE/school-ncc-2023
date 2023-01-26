#!/bin/bash
readonly HTMLIZE=./docs/htmlize.el

if [[ -z $1 ]] ; then
   ORG_FILES="*.org"
else
   ORG_FILES=$1
fi

echo $ORG_FILES


# Download the htmlize Emacs plugin if not present
url="https://github.com/hniksic/emacs-htmlize"
repo="emacs-htmlize"

if [[ ! -f "${HTMLIZE}" ]]
then
    git clone ${url} \
        && cp ${repo}/htmlize.el ${HTMLIZE} \
        && rm -rf ${repo}
fi

# Assert htmlize is installed
[[ -f ${HTMLIZE} ]] \
    || exit 1


# Convert org to HTML
if [[ -f ./docs/htmlize.el ]]
then
    for org in ${ORG_FILES}
    do
	echo "HTMLIZE: $org"
    	emacs --batch --load ./docs/htmlize.el --load ./docs/config.el $org -f org-html-export-to-html
    done
else
    for org in ${ORG_FILES}
    do
	echo "CONVERT: $org"
    	emacs --batch --load ./docs/config.el $org -f org-html-export-to-html
    done
fi

mv *.html docs/
cd docs
for i in *.html ; do
   sed -i "s/ HOME / NEXT /" $i
   sed -i "s/ UP / PREV /" $i
   sed -i '/^<h2>Table of Contents<\/h2>/i<a href="index.html"><h2>HOME<\/h2></a>' $i
done

