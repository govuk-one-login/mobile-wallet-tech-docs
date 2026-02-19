#! /bin/bash
set -e
LOCAl_TD_GEM=${1:-false}
TAG_NAME=${2:-mobile-wallet-tech-docs}

if [ $LOCAl_TD_GEM = "true" ]; then
  echo "Attempting build with local tech docs gem.  Expect gem repository to be at ../tech-docs-gem."
  rm -rf ./tech-docs-gem
  if [ -d "../tech-docs-gem" ]; then
    echo "Found local gem, copying into current project root."
    cp -r ../tech-docs-gem ./tech-docs-gem
    echo "Running docker build using command:  Dockerfile.gemtest --tag $TAG_NAME"
    docker build -f Dockerfile.gemtest --tag "$TAG_NAME" .
  else
    echo "Error: I couldn't find tech docs gem at ../tech-docs-gem. Did you clone it?"
    echo "Building site with tech_docs_gem stable release"
    docker build -f --tag mobile-wallet-tech-docs .
  fi
fi
docker run -p 4567:4567 -p 35729:35729 -v $(pwd):/usr/src/docs -it "$TAG_NAME"