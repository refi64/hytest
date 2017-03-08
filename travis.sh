#!/bin/bash

set -e

echo "Installing dependencies..."
pip install -r requirements.txt

echo "Running tests..."
python ./hytest
