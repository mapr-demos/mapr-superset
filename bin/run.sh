#!/bin/bash

DEFAULT_WEB_UI_PORT=8080

# Check if 'WEB_UI_PORT' environment varaible set
if [ ! -z ${WEB_UI_PORT+x} ]; then # WEB_UI_PORT exists
    echo "Web UI port number: $WEB_UI_PORT"
else
    echo "WEB_UI_PORT environment variable is not set. Please set it and rerun. Defaulting to: $DEFAULT_WEB_UI_PORT"
    WEB_UI_PORT=${DEFAULT_WEB_UI_PORT}
fi

# Check if 'DRILL_NODE' environment variable set
if [ ! -z ${DRILL_NODE+x} ]; then # DRILL_NODE exists
    echo "Drill node: $DRILL_NODE"
else
    echo 'DRILL_NODE environment variable is not set. Please set it and rerun.'
    exit 1
fi

# Check if 'HIVE_NODE' environment variable set
if [ ! -z ${HIVE_NODE+x} ]; then # HIVE_NODE exists
    echo "Hive node: $HIVE_NODE"
else
    echo 'HIVE_NODE environment variable is not set. Please set it and rerun.'
    exit 1
fi

# Change permissions
sudo chown -R ${MAPR_CONTAINER_USER}:${MAPR_CONTAINER_GROUP} /home/mapr/mapr-apps

fabmanager create-admin --app superset --username admin --password admin --firstname admin --lastname admin --email admin@fab.org

superset db upgrade
superset load_examples
superset init

sed -i -e "s=hive://node1=hive://$HIVE_NODE=g" /home/mapr/mapr-apps/mapr-superset/datasources/mapr-datasources
sed -i -e "s=sadrill://node1=sadrill://$DRILL_NODE=g" /home/mapr/mapr-apps/mapr-superset/datasources/mapr-datasources

superset import_datasources -p /home/mapr/mapr-apps/mapr-superset/datasources/mapr-datasources

python /home/mapr/mapr-apps/mapr-superset/bin/dashboard-import.py /home/mapr/mapr-apps/mapr-superset/dashboard/mapr-dashboard-drill.json
python /home/mapr/mapr-apps/mapr-superset/bin/dashboard-import.py /home/mapr/mapr-apps/mapr-superset/dashboard/mapr-dashboard-hive.json

superset runserver -d -p ${WEB_UI_PORT}
