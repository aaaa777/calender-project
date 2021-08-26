FROM python:3

USER root

COPY ./resolv.conf /etc/resolv.conf

RUN apt update \
 && apt install -y libpq-dev \
 && mkdir /server \
 && pip install flask psycopg2

COPY ./src/ /server/ 

CMD ["python", "/server/server.py"]