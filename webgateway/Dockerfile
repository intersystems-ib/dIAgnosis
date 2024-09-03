ARG IMAGE=containers.intersystems.com/intersystems/webgateway:latest-cd
FROM $IMAGE

RUN apt-get update
RUN apt-get install -y build-essential cmake zlib1g-dev libcppunit-dev git subversion wget && rm -rf /var/lib/apt/lists/*

RUN wget https://www.openssl.org/source/openssl-1.0.2g.tar.gz -O - | tar -xz
WORKDIR /openssl-1.0.2g
RUN ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl && make && make install

WORKDIR /

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /webgateway/gen-certificates.sh /gen-certificates.sh
RUN chmod +x /gen-certificates.sh