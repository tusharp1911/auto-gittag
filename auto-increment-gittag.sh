#!/bin/bash
#Purpose: To automate git tag incremetation
#Version: 1.0
#Created Date: 
#Modified Date: 
#Author: Tushar Patole

# retrieve branch name
BRANCH_NAME=$(git branch | sed -n '/\* /s///p')

# remove prefix release
REGEXP_RELEASE="release\/"
VERSION_BRANCH=$(echo "$BRANCH_NAME" | sed "s/$REGEXP_RELEASE//")

echo "Current version branch is $VERSION_BRANCH"

#get highest tag number
VERSION=`git describe --abbrev=0 --tags` 

#replace . with space so can split into an array
VERSION_SPLIT=(${VERSION//./ })

#get number parts and increase last one by 1
VNUM1=${VERSION_SPLIT[0]}
VNUM2=${VERSION_SPLIT[1]}
VNUM2=${VERSION_SPLIT[2]}
VNUM1=`echo $VNUM1 | sed 's/v//'`

# Check for major or minor in commit message and increment the relevant version number
MAJOR=`git log --format=%B -n 1 HEAD | grep 'major'` 
MINOR=`git log --format=%B -n 1 HEAD | grep 'minor'`
HOTFIX=`git log --format=%B -n 1 HEAD | grep 'hotfix'`


if [ "$MAJOR" ]; then
    echo "Update major version"
    VNUM1=$((VNUM1+1))
    VNUM2=0
    VNUM3=0
elif [ "$MINOR" ]; then
    echo "Update minor version"
    VNUM2=$((VNUM2+1))
    VNUM3=0
elif [ "$HOTFIX" ]; then
    echo "Update hotfix version"
    VNUM3=$((VNUM3+1))
else
    clear	
    echo "ERROR: Mention the version of commit - [major/minor/hotfix]"
    exit
fi

#get latest commit and see if it already has a tag
GIT_COMMIT=`git rev-parse HEAD`
NEEDS_TAG=`git describe --contains $GIT_COMMIT`

#tag only if there is no tag already 
if [ -z "$NEEDS_TAG" ]; then
    echo "Tagged with $NEW_TAG (Ignoring fatal:cannot describe)"

#create new tag
NEW_TAG="v$VNUM1.$VNUM2.$VNUM3"

echo "Updating $VERSION to $NEW_TAG"
    
git tag $NEW_TAG
git push --tags origin master

else
  echo "Tag is alreday given to the this latest commit."

fi

