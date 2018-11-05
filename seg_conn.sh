#!/bin/sh
seg_no=$1
db_name=$2
sql_to_execute="
\o /tmp/seg_conn.out
select content, hostname, port from gp_segment_configuration where role = 'p';
"

([ x"${seg_no}"==x ] || [ x"${db_name}"==x ]) && echo "Usage: $0 [content_number] [dbname]" && exit 1;

#generate tmp file that contains 
nohup psql postgres <<EOF
    ${sqls_to_execute}
EOF

#concat CONNECT string
host_name=`cat /tmp/seg_conn.out | sed 's/[ ]*//g' | grep ^${seg_no}'|' | awk -F'|' '{print $2}'`
seg_port=`cat /tmp/seg_conn.out | sed 's/[ ]*//g' | grep ^${seg_no}'|' | awk -F'|' '{print $3}'`

#execute
PGOPTIONS='-c gp_session_role=utility' psql $db_name -h $host_name -p $seg_port
