FROM python:3.13-alpine3.21

WORKDIR /app

COPY scripts/ .

RUN apk add --no-cache \
    aws-cli \
    dialog

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir awsebcli

# Verify
RUN aws --version && eb --version

CMD ["sh", "main.sh"]
