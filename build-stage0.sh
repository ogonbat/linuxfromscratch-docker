#!/usr/bin/env bash
set -e

cd "$(dirname $0)"
cd "$(pwd -P)/stage0"

echo "Building stage0..."
time docker build -t ccondit/linuxfromscratch-stage0-build .

echo "Starting temporary container for export..."
docker run --name=linuxfromscratch-stage0-tmp ccondit/linuxfromscratch-stage0-build

echo "Exporting filesystem..."
docker export linuxfromscratch-stage0-tmp | gzip -c > ../linuxfromscratch-stage0.tar.gz

echo "Removing temporary resources..."
docker stop linuxfromscratch-stage0-tmp
docker rm linuxfromscratch-stage0-tmp
docker rmi ccondit/linuxfromscratch-stage0-build

echo "Loading squashed stage0..."
docker import \
	--change 'ENV PATH /bin:/sbin:/usr/bin:/usr/sbin:/tools/bin:/tools/sbin' \
	--change 'CMD ["/bin/sh"]' \
	../linuxfromscratch-stage0.tar.gz ccondit/linuxfromscratch-stage0

echo "Stage0 generated."
