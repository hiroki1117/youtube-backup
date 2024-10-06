FROM python:3.12-slim-bookworm

RUN pip install --no-cache-dir --upgrade pip \
    && pip install yt-dlp==2024.09.27 \
    && pip install awscli==1.32.0

RUN apt-get update \
    && apt-get install -y ffmpeg

WORKDIR /work

COPY ./main.sh /work

RUN chmod 111 main.sh
