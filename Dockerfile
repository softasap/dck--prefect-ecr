FROM prefecthq/prefect:2.18-python3.9-conda AS builder

ARG ECR_HELPER_VERSION=0.7.1

ADD https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/0.7.1/linux-amd64/docker-credential-ecr-login /tmp/docker-credential-ecr-login
#ADD https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/0.7.1/linux-amd64/docker-credential-ecr-login.sha256 /tmp

COPY docker-config.json /root/.docker/config.json

RUN  mv /tmp/docker-credential-ecr-login /usr/local/bin/docker-credential-ecr-login \
  && chmod a+x /usr/local/bin/docker-credential-ecr-login

ENV PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  # Poetry's configuration:
  POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_CREATE=false \
  POETRY_CACHE_DIR='/var/cache/pypoetry' \
  POETRY_HOME='/usr/local' \
  POETRY_VERSION=1.8.3

# Update package lists and install curl
RUN apt-get update && apt-get install -y curl && apt-get clean && rm -rf /var/lib/apt/lists/*


# System deps:
RUN curl -sSL https://install.python-poetry.org | python3 -

# Copy only requirements to cache them in docker layer
WORKDIR /opt/prefect/datascience-pipelines/
COPY poetry.lock pyproject.toml /opt/prefect/datascience-pipelines/

# Project initialization:
RUN poetry install --only=main --no-interaction --no-ansi
