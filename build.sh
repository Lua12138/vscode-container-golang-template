#!/bin/bash

PROJECT_NAME=golang-template

WORK_DIR=$(dirname $(readlink -f "$0"))
SOURCE_DIR="${WORK_DIR}/src"
PUBLISH_DIR="${WORK_DIR}/publish"

BUILD_VERSION=1
BUILD_TIME=$(date +'%Y.%m.%d.%H.%M.%S')
BUILD_GO_VERSION=$(go version)
BUILD_GIT_COMMIT_LOG=$(git log --pretty=oneline -n 1)
BUILD_GIT_COMMIT_LOG=${BUILD_GIT_COMMIT_LOG//\'/\"}
BUILD_OS="$(uname -o) $(uname -m) $(uname -v)"

VERSION_LD_FLAGS="\
  -X 'info.BUILD_GO_VERSION=${BUILD_GO_VERSION}' \
  -X 'info.BUILD_TIME=${BUILD_TIME}' \
  -X 'info.BUILD_COMMIT_LOG=${BUILD_COMMIT_LOG}' \
  -X 'info.BUILD_OS=${BUILD_OS}' \
  -X 'info.BUILD_VERSION=${BUILD_VERSION}' \
  -X 'info.BUILD_USERNAME=${USER}'"

LD_FLAGS="-w -s -extldflags \"-static -fpic\" -buildid="

rm -rf "$PUBLISH_DIR/"
mkdir -p "$PUBLISH_DIR"

build_android(){
  TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64
  TOOLCHAIN_NAME=(armv7a-linux-androideabi aarch64-linux-android)
  ABIS=(arm arm64)
  ABI_VERSION=(7 8)
  ANDROID_API_VERSION=$1

  for ((i=0;i<${#ABIS[@]};i++)); do
      abi=${ABIS[$i]}
      echo "======> Build android for $abi <======"
      CGO_ENABLED=1 \
      GOOS=android \
      GOARCH=$abi \
      GOAPI=${ABI_VERSION[$i]} \
      API=$ANDROID_API_VERSION \
      CC=$TOOLCHAIN/bin/${TOOLCHAIN_NAME[$i]}$ANDROID_API_VERSION-clang \
      CXX=$TOOLCHAIN/bin/${TOOLCHAIN_NAME[$i]}$ANDROID_API_VERSION-clang++ \
      go build -a -ldflags "$VERSION_LD_FLAGS -w -s -buildid=" -o "$PUBLISH_DIR/$PROJECT_NAME-android-$abi" "src/main.go"
    done
}

build_desktop(){
  BUILD_TARGET=(
      "linux amd64 /usr/bin/x86_64-linux-gnu-gcc /usr/bin/x86_64-linux-gnu-g++"
      "windows amd64 /usr/bin/x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-g++"
  )

  for item in "${BUILD_TARGET[@]}"; do
    target=($item)
    OSNAME=${target[0]}
    OSARCH=${target[1]}
    OSCC=${target[2]}
    OSCXX=${target[3]}
    echo "======> Build $OSNAME $OSARCH <======"

    CGO_ENABLED=1 \
      GOOS=$OSNAME \
      GOARCH=$OSARCH \
      CC=$OSCC \
      CXX=$OSCXX \
      go build -a -ldflags "$VERSION_LD_FLAGS $LD_FLAGS" -o "$PUBLISH_DIR/$PROJECT_NAME-desktop-$OSNAME-$OSARCH" "src/main.go"
  done
}

build_android 24
build_desktop

cd $PUBLISH_DIR

find . -type f -name "$PROJECT_NAME-*" | xargs sha1sum > checksum.sha1
find . -type f -name "$PROJECT_NAME-*" | xargs sha256sum > checksum.sha256
find . -type f -name "$PROJECT_NAME-*" | xargs file > file