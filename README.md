# MapR Superset

## Contents

* [Overview](#overview)
* [Installation](#installation)
* [MapR Music Dashboard](#mapr-music-dashboard)


## Overview

Apache Superset (incubating) is a modern, enterprise-ready business intelligence web application for data visualization.
This document explains how to install and use [Apache Superset](https://superset.incubator.apache.org) on MapR Cluster. 

## Installation

### OS dependencies
    
Superset stores database connection information in its metadata database. For that purpose, we use the `cryptography` 
Python library to encrypt connection passwords. Unfortunately this library has OS level dependencies.

```
sudo yum upgrade python-setuptools
sudo yum install gcc gcc-c++ libffi-devel python-devel python-pip python-wheel openssl-devel libsasl2-devel openldap-devel
sudo yum install cyrus-sasl-devel cyrus-sasl-gssapi cyrus-sasl-md5 cyrus-sasl-plain
```

### Python’s setup tools and pip

Put all the chances on your side by getting the very latest `pip` and `setuptools` libraries:

```
sudo pip install --upgrade setuptools pip

```
### Superset installation and initialization
    
```
# Install superset
sudo pip install superset

# Create an admin user (you will be prompted to set username, first and last name before setting a password)
fabmanager create-admin --app superset

# Initialize the database
superset db upgrade

# Load some data to play with
superset load_examples

# Create default roles and permissions
superset init

# To start a development web server on port, use -p to bind to 8080 port
superset runserver -d -p 8080
```

### Build from sources

Superset for Python3 can be installed using `pip install superset` command, but in case when Python 2.7 is used you 
can face the following problem:

```
[mapr@yournode ~]$ sudo pip install superset
Collecting superset
  Using cached https://files.pythonhosted.org/packages/89/36/3dcf6e8e9ab80e94af0bc4e6ddf296d8ece737f52b39f721e0296267a9e8/superset-0.26.0.tar.gz
    Complete output from command python setup.py egg_info:
    Traceback (most recent call last):
      File "<string>", line 1, in <module>
      File "/tmp/pip-install-WNtySi/superset/setup.py", line 19, in <module>
        with open('README.md', encoding='utf-8') as f:
    TypeError: 'encoding' is an invalid keyword argument for this function
``` 

In this case you can build and install the latest version of Apache Superset from source code. 

* Clone Superset repository

```
git clone https://github.com/apache/incubator-superset.git
```

* Install yarn package manager

```
curl -o- -L https://yarnpkg.com/install.sh | sudo bash
```
`yarn` package manager depends on Node.js, install it if needed.

* Build

```
$ cd incubator-superset/superset/assets

$ /root/.yarn/bin/yarn

$ /root/.yarn/bin/yarn run build

$ cd ../..

$ sudo python setup.py install
```

In case of `TypeError: 'encoding' is an invalid keyword argument for this function` error, modify `setup.py` file and 
remove `encoding` argument from `with open('README.md', encoding='utf-8') as f:` line.

* Initialize Superset
```

# Create an admin user (you will be prompted to set username, first and last name before setting a password)
fabmanager create-admin --app superset

# Initialize the database
superset db upgrade

# Load some data to play with
superset load_examples

# Create default roles and permissions
superset init

# To start a development web server on port, use -p to bind to 8080 port
superset runserver -d -p 8080
```


## MapR Music Dashboard

![](images/mapr-music-dashboard.png?raw=true "MapR Music Dashboard")

MapR Music Dashboard visualizes data from [MapR Music](https://github.com/mapr-demos/mapr-music) dataset. Follow the 
steps below in order to import this dashboard to your Superset installation.

* Import MapR Music dataset

MapR Dashboard visualizes data from [MapR Music](https://github.com/mapr-demos/mapr-music) dataset. Use the following 
commands in order to import it:
```
$ git clone https://github.com/mapr-demos/mapr-music.git

$ cd mapr-music

$ ./bin/import-dataset.sh --path dataset/
```

* Create Hive tables

Create Hive `albums` and `artists` tables using `MapRDBJsonStorageHandler`.


Create `albums` table:
```
CREATE EXTERNAL TABLE albums ( 
 id string, 
 MBID string, 
 barcode string, 
 cover_image_url string, 
 language string,
 name string,
 rating double,
 status string) 
STORED BY 'org.apache.hadoop.hive.maprdb.json.MapRDBJsonStorageHandler' 
TBLPROPERTIES("maprdb.table.name" = "/apps/albums","maprdb.column.id" = "id"); 
```

Create `artists` table:
```
CREATE EXTERNAL TABLE artists ( 
 id string, 
 MBID string, 
 area string, 
 begin_date date,
 end_date date,
 gender string,
 profile_image_url string, 
 name string,
 rating double) 
STORED BY 'org.apache.hadoop.hive.maprdb.json.MapRDBJsonStorageHandler' 
TBLPROPERTIES("maprdb.table.name" = "/apps/artists","maprdb.column.id" = "id"); 
```

* Register Hive datasource

Under the Sources menu, select the Databases option, on the resulting page, click on the green plus sign, near the top 
right. You can configure a number of advanced options on this page, but for this walkthrough, you’ll only need to do two 
things: Name your database connection as `Hive`, provide the SQLAlchemy Connection URI `hive://<hostname>:10000/default` 
and test the connection.

* Register tables

Now that you’ve configured a database, you’ll need to add specific tables to Superset that you’d like to query.
Under the `Sources` menu, select the `Tables` option. On the resulting page, click on the green plus sign, near the top 
left. You only need a few pieces of information to add a new table to Superset: the target database from the Database 
drop-down menu(chose `Hive` newly-created DB) and table name(register `albums` and `artists` tables). 
Click on the `Save` button to save the configuration

* Explore table

To start exploring your data, simply click on the table name you just created in the list of available tables. By 
default, you’ll be presented with a `Table View` where you can construct queries to fetch and visualize your data.

Please, refer [Tutorial - Creating your first dashboard](https://superset.incubator.apache.org/tutorial.html) page to 
get more information of how to create new charts and dashboards.

* Configure impersonation

While exploring data you can face `User: mapr is not allowed to impersonate mapr` error. To fix it for YARN deployments 
edit `/opt/mapr/hadoop/hadoop-2.7.0/etc/hadoop/core-site.xml` on all ResourceManager nodes and add the two properties 
below:

```
<configuration> 
     <property> 
          <name>hadoop.proxyuser.mapr.groups</name> 
          <value>*</value> 
     </property> 
     <property> 
          <name>hadoop.proxyuser.mapr.hosts</name> 
          <value>*</value> 
     </property> 
</configuration>
```

Restart the active ResourceManager using either the MCS or the `maprcli node services` command:
```
$ maprcli node services -name resourcemanager -action restart -nodes firstnodehostname,secondnodehostname
```

* Import dashboard 

This repository contains sample [MapR Dashboard](/dashboard/mapr-dashboard-hive.json) for Hive datasource. After 
completing the steps above you can easily import this dashboard using `Import Dashboards` option under `Manage` menu.
