FROM alpine:3.9
MAINTAINER abogatikov@devalexb.com

RUN apk --no-cache add curl ca-certificates bash
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl
COPY plugin.sh /bin/
RUN chmod +x /bin/plugin.sh
ENTRYPOINT ["/bin/plugin.sh"]
