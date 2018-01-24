#!/bin/bash
current_branch() {
    git rev-parse --abbrev-ref HEAD
}

branch=$(current_branch)

if [$branch = 'master']
then
    git pull
else
    echo 'Polymath-core is not on the master branch. \n The contracts may be unstable, please switch to the master branch.'
fi
