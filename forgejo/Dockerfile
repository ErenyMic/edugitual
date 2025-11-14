FROM codeberg.org/forgejo/forgejo:13

RUN apk add --no-cache jq

COPY custom-entrypoint.sh /usr/local/bin/
COPY create-users.sh /usr/local/bin/
COPY create-token.sh /usr/local/bin/
COPY app.ini /tmp/app.ini

RUN chmod +x /usr/local/bin/*.sh

ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]