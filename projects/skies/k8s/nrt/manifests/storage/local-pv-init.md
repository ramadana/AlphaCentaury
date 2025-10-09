# Local PV Setup Instructions

Since local PVs require actual host directories, you need to manually create these on each node:

## alikara node (10.25.96.4)

SSH into the alikara node and run:

```bash
mkdir -p /mnt/data/{postgresql,prometheus,loki,grafana}
chmod 777 /mnt/data/{postgresql,prometheus,loki,grafana}
```

## sobaseki node (10.25.96.5)

SSH into the sobaseki node and run:

```bash
mkdir -p /mnt/data/metabase
chmod 777 /mnt/data/metabase
```

Or use Vultr API / SSH to execute this remotely.

After directories are created, restart the StatefulSets.
