#!/bin/bash
# CREATE DIRECTORY ON DBFS FOR LOGS
LOG_DIR=/dbfs/databricks/scripts/logs/$DB_CLUSTER_ID/dask/
HOSTNAME=`hostname`
mkdir -p $LOG_DIR
 
# ----- START DASK – ON DRIVER NODE START ----- ##
# ----- THE SCHEDULER PROCESS             ----- ##
# ON WORKER NODES START WORKER PROCESSES
if [[ $DB_IS_DRIVER = "TRUE" ]]; then
  dask-scheduler &> $LOG_DIR/dask-scheduler.$HOSTNAME.log &
  echo $! > $LOG_DIR/dask-scheduler.$HOSTNAME.pid
else
  dask-worker tcp://$DB_DRIVER_IP:8786 &> $LOG_DIR/dask-worker.$HOSTNAME.log &
  echo $! > $LOG_DIR/dask-worker.$HOSTNAME.pid &
fi
## ------------------- ENDING ----------------- ##

## /databricks/init_scripts_xkp/init-dask-conda-env.sh
