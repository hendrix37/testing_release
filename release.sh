#!/bin/bash

# Script to simplify the release flow.
# 1) Fetch the current release version
# 2) Increase the version (major, minor, patch)
# 3) Add a new git tag
# 4) Push the tag
git add .
git commit -m "$2"
git push
# Parse command line options.
while getopts ":Mmpd" Option
do
  case $Option in
    M ) major=true;;
    m ) minor=true;;
    p ) patch=true;;
    d ) dry=true;;
  esac
done

shift $(($OPTIND - 1))

# Display usage
if [ -z $major ] && [ -z $minor ] && [ -z $patch ];
then
  echo "usage: $(basename $0) [Mmp] [message]"
  echo ""
  echo "  -d Dry run"
  echo "  -M for a major release"
  echo "  -m for a minor release"
  echo "  -p for a patch release"
  echo ""
  echo " Example: release -p \"Some fix\""
  echo " means create a patch release with the message \"Some fix\""
  exit 1
fi

# Force to the root of the project
pushd "$(dirname $0)/../"

# 1) Fetch the current release version

echo "Fetch tags"
git fetch --prune --tags

version=$(git describe --abbrev=0 --tags)
version=${version:1} # Remove the v in the tag v0.37.10 for example

echo "Current version: $version"

# 2) Increase version number

# Build array from version string.

a=( ${version//./ } )

# Increment version numbers as requested.

if [ ! -z $major ]
then
  ((a[0]++))
  a[1]=0
  a[2]=0
fi

if [ ! -z $minor ]
then
  ((a[1]++))
  a[2]=0
fi

if [ ! -z $patch ]
then
  ((a[2]++))
fi

next_version="${a[0]}.${a[1]}.${a[2]}"

username=$(git config user.name)
msg="$1 by $username"

echo "Tag message: $msg"
echo "Next version: v$next_version"

git tag -a "v$next_version" -m "$msg"
git push --tags origin main

echo -e "\e[32mRelease done: $next_version\e[0m"
