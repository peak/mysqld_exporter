FROM golang:1.18-bullseye as builder

RUN apt-get update && apt-get install -y \
        build-essential \
        g++ \
        make \
        git \
        mariadb-server

RUN mkdir /build \
  && cd /build \
  && git clone https://github.com/peak/mysqld_exporter.git \
  && cd /build/mysqld_exporter \
  && git checkout v0.14.1

RUN service mariadb start \
    && mysql -u root -e "CREATE OR REPLACE USER 'root'@'localhost' IDENTIFIED BY ''; GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" \
    && cd /build/mysqld_exporter \
    && make

FROM quay.io/prometheus/busybox-linux-amd64:latest
COPY --from=builder /build/mysqld_exporter/mysqld_exporter /usr/local/bin/mysqld_exporter
