# ---------- Builder ----------
FROM --platform=$BUILDPLATFORM golang:1.26 AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /app

ARG REPOSITORY
ARG VERSION=dev
ARG REVISION=none
ARG BUILDTIME

COPY go.mod go.sum ./
RUN go mod download

COPY ./apps/seed ./apps/seed
COPY ./pkg ./pkg

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
	go build -trimpath \
	-ldflags="-s -w \
	-X github.com/pitabwire/frame/version.Repository=${REPOSITORY} \
	-X github.com/pitabwire/frame/version.Version=${VERSION} \
	-X github.com/pitabwire/frame/version.Commit=${REVISION} \
	-X github.com/pitabwire/frame/version.Date=${BUILDTIME}" \
	-o /app/binary ./apps/seed/cmd/

# ---------- Final ----------
FROM cgr.dev/chainguard/static:latest
USER 65532:65532
WORKDIR /
COPY --from=builder /app/binary /service
ENTRYPOINT ["/service"]
