# Dockerfile for krkn-hub in prow

FROM quay.io/krkn-chaos/krkn:latest

LABEL maintainer="Red Hat Chaos Engineering Team"

# Install dependencies
RUN yum install -y which

RUN git clone https://github.com/krkn-chaos/krkn-hub.git /krkn-hub

# Copy configurations
ADD . /krkn-hub

RUN ls && yum install -y python3 python3-pip python3-devel git diffutils gettext && \
    python3 -m pip install --upgrade pip

ENV PYTHONPATH=/krkn-hub/packages:$PYTHONPATH PYTHONUNBUFFERED=1

RUN ls

WORKDIR /krkn-hub