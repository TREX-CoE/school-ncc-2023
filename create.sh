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

