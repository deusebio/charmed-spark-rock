# Copyright 2024 Canonical Ltd.
# See LICENSE file for licensing details.


# ---------------------------------------------------------------------------
# This is an OCI image for Kyuubi K8s charm.
#
# It is an open source, end-to-end, production ready data platform on top of
# cloud native technologies.
# ---------------------------------------------------------------------------

    ARG KYUUBI_ARTIFACT="https://dlcdn.apache.org/kyuubi/kyuubi-1.9.0/apache-kyuubi-1.9.0-bin.tgz"
    ARG CHECKSUM="54721812f35743aec60104466c3527e6d68f2a75afb3bdbd68d06c9bd7e09a5f35f71d9edb9f24cc2189d403ef5aa65ee54fe594ca1c78e9ab621177bab32054"
    ARG TARFILE="kyuubi.tar.tz"
    ARG BASE_IMAGE

# --------------------------------------------------------------------------
# Temporary stage to download and extract Kyuubi
# --------------------------------------------------------------------------

    FROM alpine:latest AS downloader

    ARG KYUUBI_ARTIFACT
    ARG CHECKSUM
    ARG TARFILE

    # Install wget and tar in the temporary image
    RUN apk add --no-cache wget tar
    RUN echo hello
    RUN echo $TARFILE
    RUN echo bye

    # Download and verify Kyuubi
    RUN wget -O $TARFILE $KYUUBI_ARTIFACT && \
        echo "$CHECKSUM  $TARFILE" | sha512sum -c -

    # Debugging steps to check the downloaded file and checksums
    RUN ls -lh $TARFILE
    RUN sha512sum $TARFILE
    RUN echo "$CHECKSUM  $TARFILE" | sha512sum -c -

    # Create the target directory and extract the tarball
    RUN mkdir -p /opt/kyuubi && \
        tar -xzvf $TARFILE -C /opt/kyuubi --strip-components=1

# --------------------------------------------------------------------------
# Final stage 
# --------------------------------------------------------------------------

    FROM $BASE_IMAGE

    ARG BASE_IMAGE

    USER root

    # Copy the extracted Kyuubi files from the temporary stage
    COPY --from=downloader /opt/kyuubi /opt/kyuubi

    # Copy local files to the container
    COPY ./bin/kyuubi.sh /opt/pebble/kyuubi.sh
    RUN chown _daemon_:_daemon_ /opt/pebble/kyuubi.sh

    # Copy pebble layers
    COPY ./pebble/layers.yaml /var/lib/pebble/default/layers/002-charmed-kyuubi.yaml

    # Copy PostgreSQL dependencies
    RUN cp /opt/kyuubi/jars/postgresql* /opt/spark/jars

    # Set appropriate permissions
    RUN chown -R _daemon_:_daemon_ /opt/kyuubi/ && \
        chmod -R 750 /opt/kyuubi

    USER _daemon_

    # Provide Default Entrypoint for Pebble
    ENTRYPOINT [ "/bin/pebble", "enter", "--verbose", "--args", "sparkd" ]