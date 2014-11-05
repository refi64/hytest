#!/bin/bash

set -e

pypy_url=http://buildbot.pypy.org/nightly/trunk/pypy-c-jit-latest-linux64.tar.bz2
pip_url=https://bootstrap.pypa.io/get-pip.py
python=python
pip=pip

if $python --version 2>&1 | grep PyPy; then
    echo "Fetching PyPy..."
    curl $pypy_url -o pypy.tbz2
    echo "Extracting PyPy..."
    tar xf pypy.tbz2
    python=pypy-*/bin/pypy
    echo "Downloading pip..."
    curl $pip_url | $python
    pip=pypy-*/bin/pip
fi

echo "Installing dependencies..."
$pip install -r requirements.txt

echo "Running tests..."
$python ./hytest
