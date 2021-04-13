#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PHROOT=$(dirname $(dirname $DIR))
REGISTRY=primehub.airgap:5000

function print_usage() {
  echo "Push to airgap registry"
  echo ""
  echo "Usage: "
  echo "  `basename $0` <images.txt> [<images.tgz>]"
  echo ""
  echo "Options: "
  echo "  -h  print this help"
  echo "  -r  set the registry server to push (default \"${REGISTRY}\")"
  echo ""
  echo "Examples: "
  echo "  # load and push image "
  echo "  `basename $0` path/to/images.txt"
  echo ""
  echo "  # load and push image (the same behavior as above)"
  echo "  `basename $0` path/to/images.txt path/to/images.tgz"
  echo ""
  echo "  # load and push image with specific registry name"
  echo "  `basename $0` -r registry.primehub.local:5000 path/to/images.txt"
  echo ""
}

while getopts "r:h" OPT; do
  case $OPT in
    r)
      REGISTRY=$2
      ;;
    h)
      print_usage
      exit
      ;;
  esac
done
shift $(expr $OPTIND - 1 )

# Remaining argument
if [[ $# -eq 1 ]]; then
  IMAGES_LIST=$1
  IMAGES_FILE="$(dirname $IMAGES_LIST)/$(basename -s .txt $IMAGES_LIST).tgz"
elif [[ $# -eq 2 ]]; then
  IMAGES_LIST=$1
  IMAGES_FILE=$2
else
  print_usage
  exit
fi

echo "images.txt: $IMAGES_LIST"
echo "images.tgz: $IMAGES_FILE"
echo "registry:   $REGISTRY"
echo

if [[ ! -f $IMAGES_LIST ]]; then
  echo "$IMAGES_LIST not found"
  exit
fi

if [[ ! -f $IMAGES_FILE ]]; then
  echo "$IMAGES_FILE not found"
  exit
fi

# load to docker file
echo "load images..."
docker load -i $IMAGES_FILE
echo

echo "push images..."
# push to registry
for image in `cat $IMAGES_LIST`; do
  echo "push $image"
  docker tag $image ${REGISTRY}/${image}
  docker push ${REGISTRY}/${image}
done
