FROM python:3.10-alpine
LABEL maintainer="amanda.macdonald@telepsycrx.com"

ENV PYTHONUNBUFFED 1
ENV PATH="/scripts:${PATH}"

RUN apk add py3-pip
RUN pip install --upgrade pip

COPY ./requirements.txt /requirements.txt
RUN apk add --update --no-cache postgresql-client jpeg-dev
RUN apk add --update --no-cache --virtual .tmp-build-deps \
    gcc libc-dev linux-headers postgresql-dev musl-dev zlib zlib-dev libffi-dev
RUN pip install -r /requirements.txt
RUN apk del .tmp-build-deps


RUN mkdir /config
WORKDIR /config
COPY ./config /config/
COPY ./scripts /scripts
RUN chmod +x /scripts/*

RUN mkdir -p /vol/web/media
RUN mkdir -p /vol/web/static
RUN adduser -D user
RUN chown -R user:user /vol/
RUN chown -R 755 /vol/web
USER user
VOLUME /vol/web

CMD ["entrypoint.sh"]