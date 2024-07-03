#! /bin/bash
set -e

docker build . --tag mobile-wallet-tech-docs

docker run -p 4567:4567 -p 35729:35729 -v $(pwd):/usr/src/docs -it mobile-wallet-tech-docs