
# DNS Records

* A Record: @ - (ip address)
	`A  @  162.248.95.73`
* CNAME Record: www - domain
	`URL Redirect  www.theronstein.com http://theronstein.com`
# Nginx Configuration

server {
    listen 80;
    #listen [::] 80;
    server_name www.theronstein.com;

    return 301 http://theronstein.com$request_uri;
}

server {
    listen 80;
    #listen [::] 80;
    server_name theronstein.com;

    root /var/www/theron;
    index index.html index.htm;

    location /.well-known {
        autoindex on;
    }

    location /.well-known/pki-validation {
        autoindex on;
    }
}