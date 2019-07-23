#!/bin/bash

DIR=$(dirname $0)
source "$DIR/backup.env.sh"

cd "$JOPLIN_DATA"

if [ ! -d "$JOPLIN_DATA/.tree" ]; then
  mkdir "$JOPLIN_DATA/.tree"
fi

# Create tree snapshot for the record
tree -a -I .git -o "$JOPLIN_DATA/.tree/tree.txt"

# First secure all data
git add -A

if [ -z "$JOPLIN_GPG_KEY" ]; then
    git commit --gpg-sign=$JOPLIN_GPG_KEY -am "feat(automatic): Scripted catch-all backup"
else
    git commit -am "feat(automatic-unsigned): Scripted catch-all backup"
fi

# Get new knowledge
git fetch origin master:master

# Save current branch name
CURRENT_BRANCH=$(git branch | grep \* | cut -d ' ' -f2)

# Add new knowledge to master
git checkout master
git merge $CURRENT_BRANCH

# Importing pre-existing knowledge
git checkout $CURRENT_BRANCH
git merge master

# Push to server
git push --all
