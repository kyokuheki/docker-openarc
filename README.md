# docker-openarc

Dockernized OpenARC

## Usage
```shell
docker build -t openarc .
docker run -itd --restart=always -p127.0.0.1:8891:8891/tcp \
  -v/srv/openarc:/etc/openarc:ro \
  -v/srv/opendkim/dkimkeys:/etc/dkimkeys \
  --init --name openarc openarc
```

## References
- http://www.trusteddomain.org/
- https://github.com/trusteddomainproject/OpenARC/releases
