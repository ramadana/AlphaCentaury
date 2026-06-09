# Stratios
# This is a db and app tools container based on Debian.
# Intended to perform various database and application management tasks.

FROM debian:13

RUN apt update && apt upgrade -y
RUN apt install -y --no-install-recommends \
    ca-certificates \
    nano \
    curl \
    iputils-ping \
    postgresql-client && \
    curl -o mongodb-mongosh_2.5.9_amd64.deb https://downloads.mongodb.com/compass/mongodb-mongosh_2.5.9_amd64.deb && \
    dpkg -i mongodb-mongosh_2.5.9_amd64.deb && \
    rm mongodb-mongosh_2.5.9_amd64.deb

CMD [ "sleep", "infinity" ]