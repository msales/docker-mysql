FROM mysql:5.7.23

RUN mkdir /msales /var/lib/mysql_ramdisk

ADD tmpfs.cnf /msales/tmpfs.cnf
ADD entry.sh /msales/entry.sh

RUN chmod 755 /msales && \
    chmod 644 /msales/* && \
    chmod +x /msales/entry.sh && \
    rm -rf /var/lib/mysql/*

EXPOSE 3306 33060

ENTRYPOINT ["/msales/entry.sh"]
CMD ["mysqld"]
