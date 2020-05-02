FROM alpine:3.9.6
RUN apk add --update mysql-client openssh-client ncftp bash && rm -rf /var/cache/apk/* && mkdir /dump && chmod 777 /dump
COPY dump.sh /
VOLUME [ "/dump" ]
ENTRYPOINT ["/dump.sh"]
