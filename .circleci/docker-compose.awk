#!/usr/bin/env awk -f

# A short script for removing volume sections from compose files for circleci

BEGIN {
    volumes=false
}

/volumes/ {
    volumes=1
}

!/volumes/ && !/^ *-/ {
    volumes=0
}

{
    if (!volumes) {
        print
    }
}
