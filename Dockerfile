# image with az, docker, helm & kubernetes
FROM docker:19-dind

ENV AZURE_VERSION=2.5.1

ENV KUBE_VERSION=v1.13.0

ENV HELM_VERSION=3.1.2
ENV HELM_EXPERIMENTAL_OCI=1

ENV HELM_BASE_URL="https://get.helm.sh"
ENV HELM_TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"


RUN echo "**** installing kubectl ****" \
    && apk add --update ca-certificates \
    && apk add --update -t deps curl \
    && apk add --update gettext \
    && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && apk del --purge deps \
    && rm /var/cache/apk/* \
    \
    && echo "**** installing python ****" \
    && apk add --no-cache python3  \
    && if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi \
    \
    && echo "**** installing pip ****" \
    && python3 -m ensurepip  \
    && rm -r /usr/lib/python*/ensurepip  \
    && pip3 install --no-cache --upgrade pip setuptools wheel  \
    && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
    \
    && echo "**** installing azure-cli ****" \
    && apk update \
    && apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python3-dev make \
    && pip --no-cache-dir install -U pip \
    && pip --no-cache-dir install azure-cli==${AZURE_VERSION} \
    && apk del --purge build \
    \
    && echo "**** installing helm ****" \
    && apk add --update --no-cache curl ca-certificates \
    && curl -L ${HELM_BASE_URL}/${HELM_TAR_FILE} |tar xvz \
    && mv linux-amd64/helm /usr/bin/helm \
    && chmod +x /usr/bin/helm \
    && rm -rf linux-amd64 \
    && apk del curl \
    && rm -f /var/cache/apk/*

WORKDIR /apps
