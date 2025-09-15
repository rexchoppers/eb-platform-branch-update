FROM python:3.13-alpine3.21

WORKDIR /app

RUN apk add --no-cache \
    aws-cli \
    dialog

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir awsebcli

COPY scripts/ .

CMD ["sh", "main.sh"]
