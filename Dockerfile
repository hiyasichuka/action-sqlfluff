FROM python:3.13-slim

ENV REVIEWDOG_VERSION="v0.20.3"

ENV WORKING_DIRECTORY="/workdir"
WORKDIR "${WORKING_DIRECTORY}"

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        wget \
        git \
        jq \
        build-essential \
        libsasl2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install reviewdog
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

# Install pip
COPY requirements.setup.txt "${WORKING_DIRECTORY}"
RUN pip install --no-cache-dir -r requirements.setup.txt \
    && uv venv --python 3.13 "${WORKING_DIRECTORY}/.venv"
ENV PATH="${WORKING_DIRECTORY}/.venv/bin:$PATH"

# Set the entrypoint
COPY . "$WORKING_DIRECTORY"
ENTRYPOINT ["/bin/bash", "-c", "/${WORKING_DIRECTORY}/entrypoint.sh"]
