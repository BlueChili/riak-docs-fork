FROM peaceiris/hugo:v0.110.0
FROM ruby:2-alpine
ENV HUGO_PORT=1314
ENV CXX=clang++

LABEL description="Alpine + Ruby Docker container."
LABEL maintainer="Peter Clark <peter.clark@tiot.jp>"

# taken from jojomi/docker-hugo at https://github.com/jojomi/docker-hugo/blob/0.25.1/Dockerfile
COPY ./run.sh /run.sh
RUN chmod u+x /run.sh

VOLUME [ "/src", "/output" ]
WORKDIR /src

RUN apk add --no-cache ca-certificates \
    && apk -U add --no-cache gcc musl-dev make g++ git build-base clang \
    && rm -rf /var/cache/apk/* \
    && gem install 'specific_install'

CMD ["/run.sh"]

EXPOSE ${HUGO_PORT}
