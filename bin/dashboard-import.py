import sys
import time

import simplejson as json

from superset import (
  app, appbuilder, cache, db, results_backend, security_manager, sql_lab, utils,
  viz,
)

import superset.models.core as models

file_path=sys.argv[1:][0]

with open(file_path) as data_file:
  data = json.loads(data_file.read(), object_hook=utils.decode_dashboards)
  current_tt = int(time.time())
  for dashboard in data['dashboards']:
    models.Dashboard.import_obj(dashboard, import_time=current_tt)
    print("'%s' dashboard imported successfully!" % dashboard)

  db.session.commit()
