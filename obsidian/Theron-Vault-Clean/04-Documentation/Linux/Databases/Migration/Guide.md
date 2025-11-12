### Migrate the Installation

```bash
sudo rsync -avv --progress /var/lib/postgresql/16/main/ /hdd/srv/src/db/
```

### Change user references

```bash
sudo usermod -l coredb postgres
sudo groupmod -n coredb postgres
sudo usermod -d /hdd/srv/src/db coredb
```
