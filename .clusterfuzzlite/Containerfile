FROM gcr.io/oss-fuzz-base/base-builder-rust
RUN apt-get update && apt-get install -y make autoconf automake libtool
COPY . $SRC/dicti0nary-attack
WORKDIR $SRC/dicti0nary-attack
COPY .clusterfuzzlite/build.sh $SRC/
