#!/bin/bash
# ----- CREATE DIRECTORY ON DBFS FOR LOGS  ----- ##
LOG_DIR=/dbfs/databricks/scripts/logs/$DB_CLUSTER_ID/dask/
HOSTNAME=`hostname`
HOSTIP=`hostname -I | awk '{print $1}'`
mkdir -p $LOG_DIR

# ----- START DASK PROCESSES ON DATABRICKS CLUSTER  ----- ##
if [[ $DB_IS_DRIVER = "TRUE" ]]; then
  # ----- START DASK-SCHEDULER – ON DRIVER NODE  ----- ##
  /databricks/conda/envs/dcs-minimal/bin/python3 /databricks/conda/envs/dcs-minimal/bin/dask-scheduler &> $LOG_DIR/dask-scheduler.$HOSTNAME.log &
  echo $! > $LOG_DIR/dask-scheduler.$HOSTNAME.pid 
else
  # ----- START DASK-WORKER – ON WORKERS NODES  ----- ##
  /databricks/conda/envs/dcs-minimal/bin/python3 /databricks/conda/envs/dcs-minimal/bin/dask-worker tcp://$DB_DRIVER_IP:8786 &> $LOG_DIR/dask-worker.$HOSTNAME.log &
  echo $! > $LOG_DIR/dask-worker.$HOSTNAME.pid 
fi
