```nginx
server 
{ 
	listen 80;                        
	server_name doomrampage.org www.doomrampage.org;      
	root /var/www/rampage;  
	index index.html index.htm;    

	location / {                                                                       	try_files $uri $uri/ =404;                                                         autoindex off;  #Disable autoindex for the main site                       
	} 
	
	return 301 https://$host$request_uri/temp;
}                                                                             

server 
{      
	listen 443 ssl;                                                                    listen [::]:443 ssl;                                                               server_name doomrampage.org www.doomrampage.org;                                                                                                                      ssl_certificate /etc/nginx/ssl/doomrampage_org_chain.crt;                          ssl_certificate_key /etc/nginx/ssl/doomrampage_org.key;                                                                                                               ssl_protocols TLSv1.2 TLSv1.3;                                                     ssl_ciphers HIGH:!aNULL:!MD5;                                                                                                                                         root /var/www/rampage;                                                             index index.html index.htm;                                                                                                                                      	add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
}
```