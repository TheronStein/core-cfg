```console
docker run --name mysql -e MYSQL_ROOT_PASSWORD=password -d mysql:8
```


```console
docker run --name my-espocrm -e ESPOCRM_SITE_URL=http://172.20.0.100:8080 -p 8080:80 --link mysql:mysql -d espocrm/espocrm
```

`THEBEST123!`