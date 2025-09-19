FROM debian:bullseye-slim

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		build-essential git ssh ca-certificates \
		libevent-dev zlib1g-dev libssl-dev cmake

RUN update-ca-certificates \
	&& mkdir -p -m 0600 ~/.ssh \
	&& ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

COPY . /usr/local/src/libwsc
WORKDIR /usr/local/src/libwsc
RUN mkdir build \
	&& cd build \
	&& cmake .. \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=/usr/local \
		-DUSE_TLS=ON \
		-DLIBWSC_USE_DEBUG=OFF \
		-DBUILD_SHARED_LIBS=ON \
	&& make -j $(nproc) \
	&& make -j $(nproc) install