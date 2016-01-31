#!/bin/bash

# only proceed script when started not by pull request (PR)
#if [ $TRAVIS_PULL_REQUEST == "true" ]; then
#  echo "this is PR, exiting"
#  exit 0
#fi

# enable error reporting to the console
set -e

# build site with jekyll, by default to `_site' folder
bundle exec jekyll build
echo "site built"

# cleanup
rm -rf ../paolobrasolin.github.io.master
echo "cleaned up"

#clone `master' branch of the repository using encrypted GH_TOKEN for authentification
git clone https://${GH_TOKEN}@github.com/paolobrasolin/paolobrasolin.github.io.git ../paolobrasolin.github.io.master
echo "repo cloned"

# copy generated HTML site to `master' branch
cp -R _site/* ../paolobrasolin.github.io.master
echo "copied"

# commit and push generated content to `master' branch
# since repository was cloned in write mode with token auth - we can push there
cd ../paolobrasolin.github.io.master
ls
git checkout master
git config user.email "paolo.brasolin@gmail.com"
git config user.name "Paolo Brasolin"
git add -A .
git commit -a -m "Travis #$TRAVIS_BUILD_NUMBER"
echo "confed"
git status
#git push --quiet origin master > /dev/null 2>&1
git push origin master
echo "nope"
