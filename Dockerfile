FROM hrektts/ubuntu:16.04.20170915
ARG version=1.37.21
LABEL maintainer="mps299792458@gmail.com" \
      version="${version}"

ENV EMSDK=/emsdk_portable
ENV EM_CONFIG=${EMSDK}/.emscripten
ENV EMSCRIPTEN=${EMSDK}/emscripten/tag-${version}

ENV PATH=${EMSDK}/emscripten/tag-${version}:${EMSDK}/binaryen/tag-${version}_64bit_binaryen/bin:${PATH}
ENV PATH=${EMSDK}:${EMSDK}/clang/tag-e${version}/build_tag-e${version}_64/bin:${PATH}

RUN wget -qO - https://deb.nodesource.com/setup_8.x | bash - \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    cmake \
    git \
    nodejs \
    python \
    \
 && mkdir -p ${EMSDK} \
 && wget -qO - https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz \
    | tar xzf - -C ${EMSDK} --strip-components 1 \
    \
 && cd ${EMSDK} \
 && ./emsdk update-tags \
 && ./emsdk install sdk-tag-${version}-64bit binaryen-tag-${version}-64bit \
    --build='MinSizeRel' --enable-wasm \
 && ./emsdk activate sdk-tag-${version}-64bit \
 && ./emsdk activate binaryen-tag-${version}-64bit \
 && ./emsdk construct_env \
 && mv ~/.emscripten ${EM_CONFIG} \
 && sed -e "s:^\(NODE_JS=\).*:\1'$(which node)':g" -i ${EM_CONFIG} \
    \
 && rm -rf ${EMSDK}/node \
 && rm -f ${EMSDK}/binaryen-tags.txt \
    ${EMSDK}/emscripten-nightlies.txt ${EMSDK}/emscripten-tags.txt \
    ${EMSDK}/llvm-nightlies-32bit.txt ${EMSDK}/llvm-nightlies-64bit.txt \
    ${EMSDK}/llvm-tags-32bit.txt ${EMSDK}/llvm-tags-64bit.txt \
 && rm -rf ${EMSDK}/zips \
 && find ${EMSDK} -name "CMakeFiles" -type d -prune -exec rm -fr {} \; \
 && find ${EMSDK} -name "CMakeCache.txt" -exec rm {} \; \
 && find ${EMSDK} -name "*.o" -exec rm {} \; \
 && find ${EMSDK} -name "*.a" -exec rm {} \; \
 && find ${EMSDK} -name "*.inc*" -exec rm {} \; \
 && find ${EMSDK} -name "*.gen.tmp" -exec rm {} \; \
 && find ${EMSDK} -name "*.pyc" -exec rm {} \; \
 && apt-get --purge remove -y \
    cmake \
    git \
 && apt-get --purge autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /var/cache/debconf/*-old \
    \
 && emcc -v \
 && em++ -v \
 && clang --version \
 && llvm-ar --version \
 && python --version \
 && which asm2wasm \
 && emcc --clear-cache --clear-ports
