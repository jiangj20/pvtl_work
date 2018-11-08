#!/bin/sh

#variable definition
seg_no=$1
db_name=$2
file_name=$3
sql_check_conf="
\o /tmp/seg_conn.out;
select content, hostname, port from gp_segment_configuration where role = 'p';
"

#check arguments
[ $# -gt 3 ] && echo "Too many arguments." && exit 1;
([ x"${seg_no}" == x ] || [ x"${db_name}" == x ]) && echo "Usage: $0 <content_number> <dbname> [file_to_run]" && exit 1;

#generate tmp file that contains seg info
nohup psql postgres <<EOF
    ${sql_check_conf}
EOF

#concat CONNECT string
host_name=`cat /tmp/seg_conn.out | sed 's/[ ]*//g' | grep ^${seg_no}'|' | awk -F'|' '{print $2}'`
seg_port=`cat /tmp/seg_conn.out | sed 's/[ ]*//g' | grep ^${seg_no}'|' | awk -F'|' '{print $3}'`

#execute
if [ x"${file_name}" == x ]; then
PGOPTIONS='-c gp_session_role=utility' psql ${db_name} -h ${host_name} -p ${seg_port}
else
PGOPTIONS='-c gp_session_role=utility' psql ${db_name} -h ${host_name} -p ${seg_port} -f ${file_name}
fi
