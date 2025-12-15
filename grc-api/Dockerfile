FROM golang:1.22-alpine AS builder

WORKDIR /app

# Enable Go modules
ENV GO111MODULE=on

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o /grc-api .

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from builder
COPY --from=builder /grc-api .

# Expose port
EXPOSE 8080

CMD ["./grc-api"]
