FROM peaceiris/hugo:v0.110.0-full

COPY ./hugo.sh /run.sh
RUN chmod u+x /run.sh

VOLUME [ "/src", "/output" ]
WORKDIR /src
ENTRYPOINT /run.sh
EXPOSE ${HUGO_PORT}
