[all:vars]
ansible_user=${ssh_user_name}
ssh_proxy=${fip}
ansible_ssh_common_args='-C -o ControlMaster=auto -o ControlPersist=60s -o ProxyCommand="ssh ${ssh_user_name}@${fip} -W %h:%p"'

[cassandra]
${computes}

[cassandra_seed]
${seeds}