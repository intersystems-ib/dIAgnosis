#!/bin/sh

RSA_KEY_NUMBITS="2048"
DAYS="365"

GenRootCertificate() {
    local ROOT_SUBJ=$1
    local CERT_FNAME=$2
    
    echo "Generating root certificate"

    if [ ! -f "$CERT_FNAME.key" ]
    then
    # generate root certificate
    
    openssl genrsa \
        -out "$CERT_FNAME.key" \
        "$RSA_KEY_NUMBITS"

    openssl req \
        -new \
        -key "$CERT_FNAME.key" \
        -out "$CERT_FNAME.csr" \
        -subj "$ROOT_SUBJ"

    openssl req \
        -x509 \
        -key "$CERT_FNAME.key" \
        -in "$CERT_FNAME.csr" \
        -out "$CERT_FNAME.cer" \
        -days "$DAYS"

    else
    echo "ENTRYPOINT: ./webgateway-shared/CA_Server.key already exists"
    fi

}

GenCertificate() {
    local PUBLIC_SUBJ=$1
    local CERT_FNAME=$2
    local CERT_ROOT=${3:-./webgateway-shared/CA_server.cer}

    
    if [ ! -f "$CERT_FNAME.cer" ]
    then
    # generate public rsa key
    openssl genrsa \
        -out "$CERT_FNAME.key" \
        "$RSA_KEY_NUMBITS"
    else
    echo "ENTRYPOINT: $CERT_FNAME.cer already exists"
    return
    fi

    if [ ! -f "$CERT_FNAME.cer" ]
    then
    # generate public certificate
    
    openssl req \
        -new \
        -key "$CERT_FNAME.key" \
        -out "$CERT_FNAME.csr" \
        -subj "$PUBLIC_SUBJ"

    openssl x509 \
        -req \
        -in "$CERT_FNAME.csr" \
        -CA "$CERT_ROOT.cer" \
        -CAkey "$CERT_ROOT.key" \
        -out "$CERT_FNAME.cer" \
        -CAcreateserial \
        -days "$DAYS"
    
    cat $CERT_ROOT.cer >> "$CERT_FNAME.cer"
    else
    echo "ENTRYPOINT: $CERT_FNAME.cer already exists"
    fi
}

GenNginxCertificate() {
    local PUBLIC_SUBJ=$1
    local CERT_FNAME=$2

    openssl req \
        -x509 \
        -nodes \
        -subj "$PUBLIC_SUBJ" \
        -days $DAYS \
        -newkey rsa:2048 \
        -keyout $CERT_FNAME.key \
        -out $CERT_FNAME.crt
}

rm -vfr certificates

mkdir -p ./webgateway-shared
GenRootCertificate "/C=ES/ST=Madrid/L=Madrid/O=Community/OU=ES/CN=localhost" "./webgateway-shared/CA_Server"

# GenCertificate Arguments : 
#  1. subject without CN
#  2. CN
#  3. Certificate filename
#  4. Root Certificate filename

# Generate webgateway client certificate.
GenCertificate "/C=ES/ST=Madrid/L=Madrid/O=Community/OU=ES/CN=webgateway" "./webgateway-shared/webgateway_client" "./webgateway-shared/CA_Server"

# Generate IRIS server certificate
GenCertificate "/C=ES/ST=Madrid/L=Madrid/O=Community/OU=ES/CN=iris" "./webgateway-shared/iris_server" "./webgateway-shared/CA_Server"

# Generate Apache Web Server Certificate

GenCertificate "/C=ES/ST=Madrid/L=Madrid/O=Community/OU=ES/CN=webgateway" "./webgateway-shared/apache_webgateway" "./webgateway-shared/CA_Server"

# Generate nginx certificate

GenNginxCertificate "/C=ES/ST=Madrid/L=Madrid/O=Community/OU=ES/CN=localhost" "./webgateway-shared/encoder_ui"
