# ---------- Builder ----------
FROM --platform=$BUILDPLATFORM golang:1.26@sha256:3c3e25a4da13fd0478eed2df1eb35a0e667094a7124d3993a6a1d30f71c17e79 AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /app

ARG REPOSITORY
ARG VERSION=dev
ARG REVISION=none
ARG BUILDTIME

COPY go.mod go.sum ./
RUN go mod download

COPY ./apps/limits-admin ./apps/limits-admin
COPY ./pkg ./pkg

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
	go build -trimpath \
	-ldflags="-s -w \
	-X github.com/pitabwire/frame/version.Repository=${REPOSITORY} \
	-X github.com/pitabwire/frame/version.Version=${VERSION} \
	-X github.com/pitabwire/frame/version.Commit=${REVISION} \
	-X github.com/pitabwire/frame/version.Date=${BUILDTIME}" \
	-o /app/binary ./apps/limits-admin/cmd/

# ---------- Final ----------
FROM cgr.dev/chainguard/static:latest@sha256:207a5673ab31ed83332e54ae33d0f1de4adb5984bd93b8309789889e7bf30ba6
USER 65532:65532
WORKDIR /
COPY --from=builder /app/binary /service
ENTRYPOINT ["/service"]
