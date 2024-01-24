FROM alpine:3.19.0

LABEL "com.github.actions.name"="Label para aprovações de PR"
LABEL "com.github.actions.description"="Label automático para PR com determinado numero de aprovações"
LABEL "com.github.actions.icon"="tag"
LABEL "com.github.actions.color"="0E8A16"

LABEL version="1.0.0"
LABEL repository="http://github.com/bhut-it/gitaction-label-approved"
LABEL maintainer="BHUT <contato@bhut.com.br>"

RUN apk add --no-cache bash curl jq grep

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
