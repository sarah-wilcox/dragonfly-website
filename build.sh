#!/bin/bash

set -ex

export RUN=
export RUN_WEB=
export CI=true

make clean
make build
make compress

cp static-site.tgz /output

# If AWS, sync to s3 & optionally invalidate cloudflare cache.
# Otherwise, publish to gorbachev.
if [[ -v AWS_ACCESS_KEY_ID && -v AWS_BUCKET && -v AWS_SECRET_ACCESS_KEY ]]; then
  aws s3 sync _site s3://${AWS_BUCKET}

  if [[ -v AWS_CLOUDFRONT_ID ]]; then
    aws cloudfront create-invalidation \
        --distribution-id ${AWS_CLOUDFRONT_ID} \
        --paths "/*"
  fi
else
  cp -rf _site/* /publish
fi
