#!/bin/sh

CERTS=/etc/httpd/conf.d/certificates/blah

docker run -it --privileged \
	-v /dev/log:/dev/log \
	-v $CERTS.crt:/etc/pki/nginx/server.crt \
	-v $CERTS.key:/etc/pki/nginx/private/server.key \
        -v /var/log/:/logs \
        -v /global:/global \
        -e DEBUG=1 \
	--rm -p 128.55.210.132:8889:443  rstudio-centos7:1.0.136   
