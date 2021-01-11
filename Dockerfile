FROM python:3.8-slim-buster

RUN pip install --no-cache-dir --upgrade pip \
    && pip install youtube_dl \
    && pip install awscli

RUN apt-get update \
    && apt-get install -y ffmpeg

WORKDIR /work

COPY youtube-dl-script/main.sh /work

RUN chmod 777 main.sh