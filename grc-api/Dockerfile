FROM golang:1.22-alpine AS builder

# Enable Go modules globally
ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOOS=linux

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application - explicit module build
RUN cd /app && go build -v -o /grc-api -trimpath .

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from builder
COPY --from=builder /grc-api .

# Expose port
EXPOSE 8080

CMD ["./grc-api"]
