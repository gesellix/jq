FROM debian:9 as build

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

COPY . /app

# get dependencies and build jq.
# valgrind seems to have trouble with pthreads TLS so it's off.

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        autoconf \
        libtool \
        git \
        bison \
        flex \
        python3 \
        python3-pip \
        wget && \
    pip3 install pipenv && \
    (cd /app/docs && pipenv sync) && \
    (cd /app && \
        git submodule init && \
        git submodule update && \
        autoreconf -i && \
        ./configure --disable-valgrind --enable-all-static --prefix=/usr/local && \
        make -j8 && \
        make check && \
        make install )


# get the standalone jq binary and put it into an empty base image

FROM scratch
COPY --from=build /usr/local/bin/jq /bin/jq

ENTRYPOINT ["/bin/jq"]
CMD []
