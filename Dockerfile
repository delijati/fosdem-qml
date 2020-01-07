FROM clickable/ubuntu-sdk:16.04-amd64

RUN apt-get update && \
    apt-get install -y --no-install-recommends --force-yes \
        libxau6 \
        libxdmcp6 \
        libxcb1 \
        libxext6 \
        libx11-6 \
        mesa-utils \
        xauth \
        mesa-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ENV PYTHONIOENCODING=utf-8
ENV LANG C.UTF-8
