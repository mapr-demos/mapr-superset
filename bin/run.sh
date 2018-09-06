#!/bin/bash


fabmanager create-admin --app superset --username admin --password admin --firstname admin --lastname admin --email admin@fab.org

superset db upgrade
superset load_examples
superset init

# TODO: sed nodenames

superset import_datasources -p /opt/app-root/src/mapr-apps/mapr-superset/mapr-datasources

# TODO: find a way to import dashboards
# TODO: configurable port number

superset runserver -d -p 8081
