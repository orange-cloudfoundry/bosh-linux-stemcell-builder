#!/bin/bash

set -euo pipefail

export VERSION
VERSION=$(sed 's/\.0$//;s/\.0$//' < version/number)

#
# merge all stemcell files into a single metalink for publishing
#

git clone stemcells-index stemcells-index-output

meta4_path=$PWD/stemcells-index-output/published/$OS_NAME-$OS_VERSION/$VERSION/stemcells.meta4

mkdir -p "$( dirname "$meta4_path" )"
meta4 create --metalink="$meta4_path"

find "stemcells-index-output/dev/$OS_NAME-$OS_VERSION/$VERSION" -name "*.meta4" \
  | xargs -n1 -- meta4 import-metalink --metalink="$meta4_path"

cd stemcells-index-output

git add -A
git config --global user.email "ci@localhost"
git config --global user.name "CI Bot"
git commit -m "publish: $OS_NAME-$OS_VERSION/$VERSION"

#
# copy s3 objects into the public bucket
#

for file in $COPY_KEYS ; do
  file="${file/\%s/$VERSION}"

  echo "$file"
  filename=$(basename "$file")

  # occasionally this fails for unexpected reasons; retry a few times
  success="false"
  for i in {1..4}; do
    echo "Attempt ${i}: attempting to upload ${filename}"

    set +e
    if aws s3 cp --content-disposition filename="${filename}" --metadata-directive REPLACE "s3://$CANDIDATE_BUCKET_NAME/$file" "s3://$PUBLISHED_BUCKET_NAME/$file"; then
      success="true"
      break
    fi

    sleep 5
  done

  set -e

  if [[ "${success}" != "true" ]]; then
    echo "Failed uploading ${filename}"
    exit 1
  fi

  echo ""
done

VERSION_PREFIX=${VERSION_PREFIX:-stable-}

echo "${VERSION_PREFIX}${VERSION}" > ../version-tag/tag

echo "Done"
