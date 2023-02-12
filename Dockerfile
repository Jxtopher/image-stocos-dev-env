FROM debian:11.6-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends gnupg2 \
    && echo "deb http://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6A26B1AE64C3C388 \
    && apt-get update -y \ 
    && apt-get install -y --no-install-recommends \
    build-essential \
    ccache \
    clang-tidy-11 \
    cmake \
    cppcheck \
    doxygen \
    gcovr \
    libboost-iostreams1.74-dev \
    libboost-log1.74-dev \
    libboost-program-options1.74-dev \
    libcppunit-dev \
    libjsoncpp-dev \
    libssl-dev \
    libwebsocketpp-dev \
    mongodb-org-server \
    pkg-config \
    python3-numpy \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install black websocket-client ipython

# https://github.com/mongodb/mongo-c-driver/releases/
COPY ./external/mongo-c-driver-1.23.2.tar.gz /tmp/mongo-c-driver-1.23.2.tar.gz
RUN MONGO_C_DRIVER="mongo-c-driver-1.23.2"                                            \
    && tar xzf /tmp/${MONGO_C_DRIVER}.tar.gz -C /tmp/                                 \
    && mkdir /tmp/${MONGO_C_DRIVER}/cmake-build                                       \
    && cd /tmp/${MONGO_C_DRIVER}/cmake-build                                          \
    && cmake -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF -DCMAKE_INSTALL_PREFIX=/usr/ ..  \
    && cmake --build . --target install -j $(nproc)

# https://github.com/mongodb/mongo-cxx-driver/releases
COPY ./external/mongo-cxx-driver-r3.7.0.tar.gz /tmp/mongo-cxx-driver-r3.7.0.tar.gz
RUN tar xzf /tmp/mongo-cxx-driver-r3.7.0.tar.gz -C /tmp/                       \
    && cd /tmp/mongo-cxx-driver-r3.7.0/build                                   \
    && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/        \
    && cmake --build . --target install -j $(nproc)

RUN export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

RUN rm -rf /tmp/*