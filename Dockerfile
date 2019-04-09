FROM centos:7 as mfa

RUN \
  yum -y install make gcc autoconf automake \
    libtool openssl-devel openldap-devel curl-devel

RUN \
  yum -y install git pam-devel file


# Install linotp
RUN \
   git clone https://github.com/LinOTP/linotp-auth-pam && \
   cd linotp-auth-pam && sh ./autogen.sh && ./configure && \
   sed  -i 's/erase_string(config.prompt);/\/\/erase_string(config.prompt);/' src/pam_linotp.c && \
   make && cp src/.*/pam_*.so /lib64/security/

# Install pam_mfa
RUN \
   git clone https://github.com/nersc/pam_mfa && \
   cd pam_mfa && sed -i 's/-lldap/-lldap -lpam/' Makefile && \
   sed -i 's|putenv|//putenv|' pam_mfa.c && \
   make && cp *.so /lib64/security/

 

FROM centos:7

MAINTAINER Shane Canon <scanon@lbl.gov>


RUN \
  echo "%_netsharedpath /sys:/proc" >> /etc/rpm/macros.dist && \
  yum -y update && \
  yum install -y wget nss-pam-ldapd openldap nginx

RUN \
   echo "%_netsharedpath /sys:/proc" >> /etc/rpm/macros.dist && \
   yum install -y epel-release && \
   yum update -y && \
   yum install -y R nginx curl-devel libxml2-devel

RUN \
    wget https://download2.rstudio.org/rstudio-server-rhel-1.0.136-x86_64.rpm && \
    yum install -y --nogpgcheck rstudio-server-rhel-1.0.136-x86_64.rpm && \
    rm *.rpm

ADD encrypted-sign-in.htm /usr/lib/rstudio-server/www/templates/

ADD ldap /tmp/ldap/
RUN \
  cp /tmp/ldap/ldap.conf /etc/openldap/ldap.conf && \
  cp /tmp/ldap/nslcd.conf /etc/nslcd.conf && \
  cp /tmp/ldap/nsswitch.conf /etc/nsswitch.conf && \
  cp /tmp/ldap/pam_ldap.conf /etc/pam_ldap.conf && \
  cp /tmp/ldap/password-auth /etc/pam.d/password-auth && \
  cp /tmp/ldap/rstudio /etc/pam.d/


COPY --from=mfa /lib64/security/pam_mfa.so /lib64/security/pam_linotp.so /lib64/security/

#ADD R-packages /tmp/R-packages
#RUN \
#    Rscript /tmp/R-packages

#ADD R-biolite /tmp/R-biolite
#RUN \
#    Rscript/tmp/R-biolite

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./entrypoint.sh /entrypoint.sh

RUN  localedef -i en_US -f UTF-8 en_US.UTF-8

ENV R_HOME /usr/lib64/R
ENV R_DO_DIR /usr/share/doc/R-3.3.2/
ENV LANG en_US.UTF-8 

# Hot fix
RUN yum install -y zsh ksh csh

CMD [ ]
ENTRYPOINT [ "/entrypoint.sh" ]
