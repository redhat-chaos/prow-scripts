# Dockerfile for krkn-hub in prow

FROM quay.io/krkn-chaos/krkn:latest

LABEL maintainer="Red Hat Chaos Engineering Team"

RUN git clone https://github.com/krkn-chaos/krkn-hub.git /home/krkn/krkn-hub

# Copy configurations
ADD . /home/krkn/krkn-hub

# Remove the commented lines once prow runs are working fine
#RUN chmod +x /home/krkn/krkn-hub/*/prow_run.sh
#RUN ls && yum install -y python3 python3-pip python3-devel git diffutils gettext && \
#    python3 -m pip install --upgrade pip

ENV PYTHONPATH=/home/krkn/krkn-hub/packages:$PYTHONPATH PYTHONUNBUFFERED=1

RUN ls

WORKDIR /home/krkn/krkn-hub
