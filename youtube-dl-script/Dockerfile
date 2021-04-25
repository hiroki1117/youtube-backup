FROM python:3.8-slim-buster

RUN pip install --no-cache-dir --upgrade pip \
    && pip install youtube_dl==2021.4.17 \
    && pip install awscli==1.19.57

RUN apt-get update \
    && apt-get install -y ffmpeg

WORKDIR /work

COPY ./main.sh /work

RUN chmod 777 main.sh