
FROM ubuntu:xenial

RUN apt-get update && apt-get install -y --no-install-recommends \
        netbase \
        nfs-kernel-server \
    && rm -rf /var/lib/apt/lists/*

# RUN mkdir -p /exports

# VOLUME /exports

RUN rpcbind && service nfs-kernel-server start

EXPOSE 111/udp 2049/tcp

# ADD run.sh /usr/local/bin/run.sh
# ENTRYPOINT ["run.sh"]
CMD ["sleep", "infinity"]
