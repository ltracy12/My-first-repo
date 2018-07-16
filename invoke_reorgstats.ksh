#!/bin/ksh

#1010101001010101010100101010101001010101010010101010010101010010101010100101010101010101010101010010101010101
#
# Script name: invoke_reorgstats.ksh
#
# Syntax: ./invoke_reorgstats.ksh <dbname>
#
# Description: This script is used to invoke / control the genReorgstats.sh script to run on multiple schemas
#
# Developed by: Cuong.V.Ly@us.ibm.com
#
# Date : 09/25/2012
#
#10101010010101010100101010101001010101001010101010101010010101010100101010101010101001010101010101010100101001

typeset -u dbname=$1
instance=`echo ${DB2INSTANCE}`
clock_in=`date +%Y_%m_%d-%H:%M`
dir=/db2backup/db2_scripts/logs
trigger_dir=${dir}/${instance}_${dbname}
input_dir=${dir}/${instance}_${dbname}
output_dir=${dir}/${instance}_${dbname}
LOGFILE=${dir}/invoke_reorgstats_${instance}_${dbname}.log

## GET RID OF THE PREVIOUS LOG FILE ##



# Redirect STDOUT and STDERR to the logfile and the screen
# if they are connected to a tty -- we're probably running the script from the command line
#if [[ -t 1 && -t 2 ]]; then
#        tee -a $LOGFILE > /dev/tty |&    # send to the tty and to the co-process
#else                        # If they are not -- we were probably called from cron
#        tee -a $LOGFILE |&               # send just to the co-process
#fi
#exec 1>&p                                #send stdout to the co-process
#exec 2>&1                                #send stderr to the co-process


elapsed_time()
{
  SEC=$1

  print "${clock_in}" | tee -a ${LOGFILE}

  (( SEC < 60 )) && print "[Elapsed time: $SEC seconds]\c"
  (( SEC >= 60 && SEC < 3600 )) && print "Completed [Elapsed time: $(( SEC / 60 )) \
  min $(( SEC % 60 )) sec]\n\n" | tee -a ${LOGFILE}

  (( SEC > 3600 )) && print "Completed [Elapsed time: $(( SEC / 3600 )) hr \
  $(( SEC % 3600 / 60 )) min $(( SEC % 3600 % 60 )) sec]\n\n" | tee -a ${LOGFILE}
  print "\n" | tee -a ${LOGFILE}
}

print "DB2 INSTANCE: ${instance}\n" | tee -a ${LOGFILE}

db2 connect to ${dbname}
if [[ $? != 0 ]];
then
   print "DB ${dbname} connection failed!!" | tee -a ${LOGFILE}
   exit 1
fi


if [[ ! -d ${output_dir} ]];
then
    mkdir ${output_dir}
fi


if test ! -e "${dir}/${instance}_${dbname}/cluster_index.list"
then
   touch ${dir}/${instance}_${dbname}/cluster_index.list
fi


db2_cmd="select distinct tabschema from syscat.tables where tabschema not like 'SYS%'"
##db2_cmd="select distinct tabschema from syscat.tables where tabschema = 'MAPDM' and \
##         tabname in ('MAP_ACCOUNT_GEO_IBM_CLIENT_CRITERIA', 'CLIENT_REF', 'MAP_CUSTOMER_IBM_CLIENT', \
##                     'MAP_CUSTOMER_GEO_IBM_CLIENT_CRITERIA')"

db2 -x ${db2_cmd} | while read schema
do
  ## Script is running in interactive mode to bypass the trigger file##
  ## W = weekly ##
  ## Y = runTheDDL ##
  ## Y = interactiveMode to avoid trigger file ##
  ## N = runstatsOnlyMode ##
  print $schema
  ${dir}/genReorgstats.sh ${dbname} ${schema} ${input_dir}/ ${output_dir}/ ${trigger_dir}/ cluster_index.list W Y Y N | tee -a ${LOGFILE}
done


time_elapsed=${SECONDS}
elapsed_time ${time_elapsed}

##exec 1>&-                                #close stdout
##exec 2>&-                                #close stderr

exit 0


