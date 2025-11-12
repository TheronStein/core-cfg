http://www.yourdomainname.com/.well-known/pki-validation/AN2D4C5H7F01823KRIDHJ.txt.

server {
    listen 80;
    server_name theron.stein.com www.theronstein.com;
    root /var/www/theronstein;

    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
        autoindex off;  # Disable autoindex for the main site
    }
    return 301 https://$host$request_uri;
}