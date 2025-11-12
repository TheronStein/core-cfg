<hr>

## Node. Js
```
Openssl req -nodes -newkey rsa: 2048 -keyout chaoscore_org. Key -out chaoscore_org. Csr
```

## Combining SSLs
<hr>

##### Normal
```
cat doomrampage_org.crt doomrampage_org.ca-bundle > doomrampage_org_chain.crt
```


##### NameCheap

```
cat doomrampage_org.crt > doomrampage_org_chain.crt ; echo >> doomrampage_org_chain.crt ; cat doomrampage_org.ca-bundle >> doomrampage_org_chain.crt
```