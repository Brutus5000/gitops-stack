This stack assumes to run the host(s) on NixOS with ZFS configured and has NixOS specific configuration.

The storage class `zfs-localpv` works together with the storage driver from [OpenEBS](https://openebs.github.io/zfs-localpv). The storage class takes care of mapping the volumes into ZFS datasets.

**Important:** The datasets are not mounted by default on the host. You need to do this manually if you want to inspect the files of a volume. Also, should you forget to unmount, the PVC can't be deleted.

For ZFS in order to match a PVC to a dataset, you can lookup the volume name via `kubectl get pvc`. The `VOLUME`column is then part of the dataset name, prefixed by the poolname of the storage class (e.g. `storage/faf-k8s`)