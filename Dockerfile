FROM python:3.13-alpine3.21

RUN apk add --no-cache \
    aws-cli

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir awsebcli

# Verify
RUN aws --version && eb --version

ENTRYPOINT ["sh"]
