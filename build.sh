#!/bin/bash
set -eu -o pipefail

: ${OWNER:=appearhere}

tags() {
  name=${1/#.\//}
  repo=${name%\/*}
  tag=${name#*\/}

  branch=$(git rev-parse --abbrev-ref HEAD || git rev-parse HEAD | git branch -a --contains | sed -n 2p | cut -d'/' -f 3-)
  tags="${branch} ${tag}"

  [ "$branch" = "master" ] && tags="${tags} latest"

  t=""
  for tag in $tags; do t="${t} $OWNER/$repo:$tag"; done
  echo "${t}"
}

build() {
  dir=$1
  (
    cd $dir || exit 1
    docker build --iidfile .iid . 1>&2 || exit 1
  )

  iid=$(cat $dir/.iid)
  build_id=${iid#sha256:}

  rm $dir/.iid

  echo $build_id
}

tag() {
  image_id=$1
  dir=$2

  for tag in $(tags $dir);
  do
    docker tag $image_id $tag
  done
}

push() {
  dir=$1

  for tag in $(tags $dir);
  do
    docker push $tag
  done
}

repos=$(find . -name "Dockerfile" -exec dirname {} \;)

for repo in $repos;
do
  image_id=$(build $repo || exit 1)
  tag $image_id $repo   || exit 1
  push $repo  || exit 1
done
