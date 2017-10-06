FROM hrektts/ubuntu:16.04.20170915

LABEL maintainer="mps299792458@gmail.com" \
      version="1.37.21"

ENV VERSION=1.37.21

ENV EMSDK=/emsdk-portable
ENV EM_CONFIG=${EMSDK}/.emscripten
ENV BINARYEN_ROOT=${EMSDK}/clang/e${VERSION}_64bit/binaryen
ENV EMSCRIPTEN=${EMSDK}/emscripten/${VERSION}

ENV PATH=${EMSDK}:${EMSDK}/clang/e${VERSION}_64bit:${EMSDK}/emscripten/${VERSION}:${PATH}

RUN wget -qO - https://deb.nodesource.com/setup_8.x | bash - \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    nodejs \
    python \
 && wget -qO - https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz | tar xzf - \
 && cd emsdk-portable \
 && ./emsdk update-tags \
 && ./emsdk install sdk-${VERSION}-64bit --build='MinSizeRel' --enable-wasm \
 && ./emsdk activate latest \
 && ./emsdk construct_env \
 && mv ~/.emscripten ${EM_CONFIG} \
 && sed -e "s:^\(NODE_JS=\).*:\1'$(which node)':g" -i ${EM_CONFIG} \
 && rm -rf ${EMSDK}/node \
 && apt-get --purge remove -y \
    git \
    python \
 && apt-get --purge autoremove -y \
 && rm -rf /var/lib/apt/lists/*
