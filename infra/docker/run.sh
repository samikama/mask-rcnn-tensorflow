# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
#!/usr/bin/env bash

BRANCH_NAME=${1:-"master"}

echo "Running docker image mask-rcnn-tensorflow:dev-${BRANCH_NAME}"
echo ""



nvidia-docker run -it  -v ~/data:/data -v ~/logs:/logs mask-rcnn-tensorflow:dev-${BRANCH_NAME}