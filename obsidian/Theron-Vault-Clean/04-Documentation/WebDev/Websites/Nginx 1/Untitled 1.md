server {
    listen 80;
    server_name doomrampage.org www.doomrampage.org;
    root /var/www/rampage;

    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
        autoindex off;  # Disable autoindex for the main site
    }

    return 301 https://$host$request_uri/temp;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name doomrampage.org www.doomrampage.org;
    root /var/www/rampage;
    ssl_certificate /etc/nginx/ssl/ssl/doomrampage_org.crt;
    ssl_certificate_key /etc/nginx/ssl/doomrampage_org.key;

    index index.html index.htm;

    add_header Strict-Transport-Security "max-age=31536000;";

    location /temp {
        try_files $uri $uri/ =404;
        autoindex off;
        #try_files $uri $uri/ =404;
        #autoindex off;  # Disable autoindex for the main site
        #proxy_set_header X-Real-IP $remote_addr;
        #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #proxy_set_header Host $host;
        #proxy_set_header X-NginX-Proxy true;
        #proxy_pass http://localhost:3001;
        #proxy_redirect off;
    }


    location /remote {
        root /var/www/webdav;
        client_max_body_size 10G;
        dav_methods PUT DELETE MKCOL COPY MOVE;
        create_full_put_path on;
        dav_access user:rw group:rw all:r;

        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
	
	 #   location /src {
#       index index.html index.htm index.js
    #   autoindex off;  # Enable directory listing
    #}

    location /wads {
        autoindex on;  # Enable directory listing
    }

    location /configs {
        autoindex on;  # Enable directory listing
    }

    #location ~ \.php$ {
    #    include snippets/fastcgi-php.conf;
    #    fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    #}

    #location ~ /\.ht {
    #    deny all;
    #}i
}