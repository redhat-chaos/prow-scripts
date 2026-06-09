# Dockerfile for krkn-hub in prow

FROM quay.io/krkn-chaos/krkn:latest

LABEL maintainer="Red Hat Chaos Engineering Team"

RUN git clone https://github.com/krkn-chaos/krkn-hub.git /home/krkn/krkn-hub

# Copy configurations
ADD . /home/krkn/krkn-hub

USER root

RUN dnf install -y unzip &&  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install
RUN aws --version

RUN dnf install -y openssl && curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
RUN helm version

RUN chown -R krkn:krkn /home/krkn && chmod -R 777 /home/krkn

USER krkn
ENV PYTHONPATH=/home/krkn/krkn-hub/packages PYTHONUNBUFFERED=1

RUN ls

WORKDIR /home/krkn/krkn-hub
