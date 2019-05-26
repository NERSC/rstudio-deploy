FROM centos:7

MAINTAINER Shane Canon <scanon@lbl.gov>


RUN \
  echo "%_netsharedpath /sys:/proc" >> /etc/rpm/macros.dist && \
  yum -y update && \
  yum install -y wget nss-pam-ldapd openldap nginx

ADD ldap /tmp/ldap/
RUN \
  cp /tmp/ldap/ldap.conf /etc/openldap/ldap.conf && \
  cp /tmp/ldap/nslcd.conf /etc/nslcd.conf && \
  cp /tmp/ldap/nsswitch.conf /etc/nsswitch.conf && \
  cp /tmp/ldap/pam_ldap.conf /etc/pam_ldap.conf && \
  cp /tmp/ldap/password-auth /etc/pam.d/password-auth && \
  cp /tmp/ldap/rstudio /etc/pam.d/

RUN \
   echo "%_netsharedpath /sys:/proc" >> /etc/rpm/macros.dist && \
   yum install -y epel-release && \
   yum update -y

RUN \
   yum install -y nginx curl zsh ksh csh bzip2

RUN \
   wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
   sh ./Miniconda3-latest-Linux-x86_64.sh -b -p /anaconda3


ENV PATH /anaconda3/bin:$PATH

RUN conda install -c r rstudio

RUN \
    wget https://download2.rstudio.org/server/centos6/x86_64/rstudio-server-rhel-1.2.1335-x86_64.rpm && \
    yum install -y --nogpgcheck rstudio-server-rhel-1.2.1335-x86_64.rpm && \
    rm *.rpm

ADD . /src/
RUN \
    cp /src/rserver.conf /etc/rstudio/rserver.conf && \
    cp /src/encrypted-sign-in.htm /usr/lib/rstudio-server/www/templates/

#ADD R-packages /tmp/R-packages
#RUN \
#    Rscript /tmp/R-packages

#ADD R-biolite /tmp/R-biolite
#RUN \
#    Rscript/tmp/R-biolite

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./entrypoint.sh /entrypoint.sh

RUN  localedef -i en_US -f UTF-8 en_US.UTF-8

#ENV R_HOME /usr/lib64/R
#ENV R_DO_DIR /usr/share/doc/R-3.3.2/
#ENV LANG en_US.UTF-8 

CMD [ ]
ENTRYPOINT [ "/entrypoint.sh" ]
