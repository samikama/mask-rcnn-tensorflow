# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
#!/usr/bin/env bash

# This script shows how to build the Docker image and push it to ECR to be ready for use
# by SageMaker.

# The argument to this script is the image name. This will be used as the image on the local
# machine and combined with the account and region to form the repository name for ECR.
image=$1
if [ "$image" == "" ]
then
    echo "Usage: $0 <image-name>"
    exit 1
fi

export AWS_ACCESS_KEY_ID=$(aws --profile default configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws --profile default configure get aws_secret_access_key)


# Get the account number associated with the current IAM credentials
account=$(aws sts get-caller-identity --query Account --output text)

if [ $? -ne 0 ]
then
    exit 255
fi


# Get the region defined in the current configuration (default to us-west-2 if none defined)
region=$(aws configure get region)
#region=${region:-us-east-1}


fullname="${account}.dkr.ecr.${region}.amazonaws.com/${image}:latest"
# If the repository doesn't exist in ECR, create it.

aws ecr describe-repositories --repository-names "${image}" > /dev/null 2>&1

if [ $? -ne 0 ]
then
    aws ecr create-repository --repository-name "${image}" > /dev/null
fi

# Get the login command from ECR and execute it directly
$(aws ecr get-login --region ${region} --no-include-email)

# Build the docker image locally with the image name and then push it to ECR
# with the full name.
echo "Building docker image mask-rcnn-tensorflow"
echo ""

docker build  -t ${image} -f Dockerfile_sm . --build-arg CACHEBUST=$(date +%s) \
				--build-arg AWS_ACCESS_KEY_ID \
				--build-arg AWS_SECRET_ACCESS_KEY \

if [ $? -ne 0 ]
then
  echo "Local build failed. Not pushing."
  exit 1
fi

docker tag ${image} ${fullname}

docker push ${fullname}
