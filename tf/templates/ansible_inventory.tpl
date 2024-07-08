masters:
    hosts:
        master:
            ansible_host: ${ips[0]}
workers:
    hosts:
        worker_1:
            ansible_host: ${ips[1]}
        worker_2:
            ansible_host: ${ips[2]}
nodes:
    children:
        masters:
        workers:
