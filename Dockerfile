FROM maprtech/pacc:6.0.1_5.0.0_centos7

RUN yum upgrade python-setuptools
RUN yum install -y git gcc gcc-c++ libffi-devel python-devel python-pip python-wheel openssl-devel libsasl2-devel openldap-devel cyrus-sasl-devel cyrus-sasl-gssapi cyrus-sasl-md5 cyrus-sasl-plain

RUN pip install --upgrade setuptools pip
RUN pip install superset pyhive

# Create a directory for your MapR Application and copy the Application
RUN mkdir -p /home/mapr/mapr-apps/mapr-superset/

WORKDIR /home/mapr/mapr-apps/
RUN git clone https://github.com/mapr-demos/sqlalchemy-drill/
WORKDIR /home/mapr/mapr-apps/sqlalchemy-drill/
RUN git checkout mapr-superset
RUN python setup.py install

COPY ./bin /home/mapr/mapr-apps/mapr-superset/bin
COPY ./datasources /home/mapr/mapr-apps/mapr-superset/datasources
COPY ./dashboard /home/mapr/mapr-apps/mapr-superset/dashboard
RUN chmod +x /home/mapr/mapr-apps/mapr-superset/bin/*

CMD ["/home/mapr/mapr-apps/mapr-superset/bin/run.sh"]
