#!/bin/bash

# List of IDEs
IDE=("PCP" "IIU" "WS" "CL")
MINICONDA_VER=24.7.1-0

# Iterate over each IDE
for it in "${IDE[@]}"; do
    # Build Docker image with the specific ARG and tag
    docker build --build-arg IDE_CODE="$it" \
        --build-arg MINICONDA_VER="$MINICONDA_VER" \
        -t "ghcr.io/miniconda:${MINICONDA_VER}-${it}" \
        -f miniconda.Dockerfile \
        . --push
done
