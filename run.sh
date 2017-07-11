#!/bin/bash

set -e

make
.build/debug/swift-format $@
