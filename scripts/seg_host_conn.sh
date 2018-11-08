#!/bin/sh

#variable definition
seg_no=$1

sql_check_conf="
\o /tmp/seg_conf.out;
select content, hostname, port from gp_segment_configuration where role = 'p';
"

#check arguments
[ $# -gt 1 ] && echo "Too many arguments." && exit 1;
[ x"${seg_no}" == x ] && echo "Usage: $0 <content_number>" && exit 1;

#generate tmp file that contains seg info
nohup psql postgres <<EOF
    ${sql_check_conf}
EOF

#concat CONNECT string
host_name=`cat /tmp/seg_conf.out | sed 's/[ ]*//g' | grep ^${seg_no}'|' | awk -F'|' '{print $2}'`

#execute
ssh ${host_name}
