FROM golang:1.23-bullseye AS build-env

ENV PACKAGES="curl make git libc-dev bash gcc jq bc"
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y ${PACKAGES}

WORKDIR /go/src/github.com/evmos/

RUN git clone "https://github.com/Akira0x01/evmos.git"

WORKDIR /go/src/github.com/evmos/evmos
RUN git checkout v19.2.0

RUN make build

FROM golang:1.23-bullseye AS final

ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG USERNAME

# Create a non-root user
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}

WORKDIR /home/${USERNAME}

RUN apt update -y && apt install jq bc -y

# Copy over binaries from the build-env
COPY --from=build-env /go/src/github.com/evmos/evmos/build/evmosd ./bin/

COPY ./setup_genesis.sh ./setup_genesis.sh
COPY ./start.sh ./start.sh

USER ${USERNAME}

ENTRYPOINT ["/bin/bash", "-c"]

EXPOSE 26556
EXPOSE 26657
EXPOSE 9090
EXPOSE 1317
EXPOSE 8545