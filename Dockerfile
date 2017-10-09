FROM hrektts/ubuntu:16.04.20170915
LABEL maintainer="mps299792458@gmail.com" \
      version="1.37.21"

ENV VERSION=1.37.21

ENV EMSDK=/emsdk_portable
ENV EM_CONFIG=${EMSDK}/.emscripten
ENV EMSCRIPTEN=${EMSDK}/emscripten/tag-${VERSION}

ENV PATH=${EMSDK}/emscripten/tag-${VERSION}:${EMSDK}/binaryen/tag-${VERSION}_64bit_binaryen/bin:${PATH}
ENV PATH=${EMSDK}:${EMSDK}/clang/tag-e${VERSION}/build_tag-e${VERSION}_64/bin:${PATH}

RUN wget -qO - https://deb.nodesource.com/setup_8.x | bash - \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    cmake \
    git \
    nodejs \
    python \
 && mkdir -p ${EMSDK} \
 && wget -qO - https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz \
    | tar xzf - -C ${EMSDK} --strip-components 1 \
 && cd ${EMSDK} \
 && ./emsdk update-tags \
 && ./emsdk install sdk-tag-${VERSION}-64bit binaryen-tag-${VERSION}-64bit \
    --build='MinSizeRel' --enable-wasm \
 && ./emsdk activate sdk-tag-${VERSION}-64bit \
 && ./emsdk activate binaryen-tag-${VERSION}-64bit \
 && ./emsdk construct_env \
 && mv ~/.emscripten ${EM_CONFIG} \
 && sed -e "s:^\(NODE_JS=\).*:\1'$(which node)':g" -i ${EM_CONFIG} \
 && rm -rf ${EMSDK}/node \
 && rm -rf /var/lib/apt/lists/*
