FROM golang:alpine as builder

ENV JSONNET_VERSION 0.17.0
ENV PROMTOOL_VERSION 2.21.0

WORKDIR /go

# Jsonnet Go tools
RUN GO111MODULE=on go get github.com/google/go-jsonnet/cmd/jsonnet@v${JSONNET_VERSION}
RUN GO111MODULE=on go get github.com/google/go-jsonnet/cmd/jsonnetfmt@v${JSONNET_VERSION}
RUN GO111MODULE=on go get github.com/google/go-jsonnet/cmd/jsonnet-deps@v${JSONNET_VERSION}
RUN GO111MODULE=on go get github.com/google/go-jsonnet/cmd/jsonnet-lint@v${JSONNET_VERSION}
RUN GO111MODULE=on go get github.com/brancz/gojsontoyaml
RUN GO111MODULE=on go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb

# Prometheus rule validation
RUN wget https://github.com/prometheus/prometheus/releases/download/v${PROMTOOL_VERSION}/prometheus-${PROMTOOL_VERSION}.linux-amd64.tar.gz && \
    tar -xzf prometheus-*.tar.gz -C /opt && \
	mv /opt/prometheus-*/promtool /opt

FROM alpine

RUN apk -U --no-cache add make git bash

WORKDIR /opt
RUN chmod 777 /opt

COPY --from=builder /go/bin/gojsontoyaml /usr/local/bin
COPY --from=builder /go/bin/jb /usr/local/bin
COPY --from=builder /go/bin/jsonnet /usr/local/bin
COPY --from=builder /go/bin/jsonnetfmt /usr/local/bin
COPY --from=builder /go/bin/jsonnet-deps /usr/local/bin
COPY --from=builder /go/bin/jsonnet-lint /usr/local/bin
COPY --from=builder /opt/promtool /usr/local/bin

USER 1000

ENTRYPOINT ["jsonnet"]
