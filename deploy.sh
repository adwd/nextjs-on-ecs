#!/bin/bash

set -ex

: ${REVISION:="$(git rev-parse --short HEAD)"}
export REVISION;

./build-image-and-push.sh

# Next.jsで作った静的ファイルをS3に上げる
rm -rf ./dist/
mkdir ./dist/
CONTAINER_ID="$(docker create "nextjs-on-ecs-server:$REVISION")"
docker cp ${CONTAINER_ID}:/app/.next ./dist/
docker rm -v ${CONTAINER_ID}
aws s3 sync ./dist/.next/static s3://nextjs-on-ecs-static-bucket/_next/static

ecspresso --config config.yaml deploy
