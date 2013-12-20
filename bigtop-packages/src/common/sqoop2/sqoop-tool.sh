#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Autodetect JAVA_HOME if not defined

tomcat_deployment() {
  DEPLOYMENT_SOURCE=`readlink -e /etc/sqoop2/tomcat-conf`
  DEPLOYMENT_TARGET=/var/lib/sqoop2/tool-tomcat-deployment

  rm -rf ${DEPLOYMENT_TARGET}
  mkdir ${DEPLOYMENT_TARGET}
  cp -r ${DEPLOYMENT_SOURCE}/conf ${DEPLOYMENT_TARGET}
  cp -r /usr/lib/sqoop2/webapps ${DEPLOYMENT_TARGET}/webapps
  cp -r ${DEPLOYMENT_SOURCE}/WEB-INF/* ${DEPLOYMENT_TARGET}/webapps/sqoop/WEB-INF/
  cp -r ${SQOOP_HOME}/bin ${DEPLOYMENT_TARGET}/

  if [ -n "${BIGTOP_CLASSPATH}" ] ; then
    sed -i -e "s#^\(common.loader=.*\)\$#\1,${BIGTOP_CLASSPATH/:/,}#" ${DEPLOYMENT_TARGET}/conf/catalina.properties
  fi

  chown -R sqoop2:sqoop ${DEPLOYMENT_TARGET}
}

. /usr/lib/bigtop-utils/bigtop-detect-javahome

tomcat_deployment

LIB_DIR=/usr/lib/sqoop2
BIN_DIR=${LIB_DIR}/bin

export CLASSPATH=$CLASSPATH:$(echo "$LIB_DIR"/client-lib/*.jar | tr ' ' ':')
export CATALINA_HOME=/usr/lib/bigtop-tomcat
export CATALINA_BIN=${CATALINA_HOME}/bin
export CATALINA_BASE=/var/lib/sqoop2/tool-tomcat-deployment
export JAVA_OPTS="$JAVA_OPTS -Dsqoop.config.dir=/etc/sqoop2/conf"

COMMAND="cd ~/ && ${BIN_DIR}/sqoop.sh tool $@"
su -s /bin/bash -c "${COMMAND}" sqoop2

