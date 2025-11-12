### Installing an SSL certificate on Node.js

No time to install SSL? Try [our installation service](https://www.namecheap.com/support/knowledgebase/article.aspx/10660/69/ssl-installation-service/).

**Preface**

After the SSL certificate is issued, it should be implemented on the web server to enable HTTPS connections. Upon issuance, the Certificate Authority (Comodo/Sectigo) will email the certificate files; these files will also be available for download from your Namecheap account as described [here](https://www.namecheap.com/support/knowledgebase/article.aspx/9464/14/can-i-download-an-issued-certificate-on-your-site).

This article will cover certificate implementation for [Node.js](https://nodejs.org/en/about/) and [Express](https://expressjs.com/). You can jump to the appropriate sections from the Table of Contents below.

**Table of Contents  
  
**

- [Prerequisites](https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/#prereq)
- [Importing certificate files into your application](https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/#import)
- [HTTPS on Node.js](https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/#https_node_js)
    - [Creating an HTTPS server](https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/#create_https_s)
    - [Redirecting to HTTPS](https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/#redir_https_n)
- [HTTPS on Express](https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/#https_express)
    - [Creating an HTTPS application with Express](https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/#create_https_express)
    - [Redirecting to HTTPS with Express](https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/#redir_https_e)

Currently, the LTS version of Node.js is 10.15.0 and the latest version of Express is 4.16.4. These versions will be used and referred to throughout this guide.

**Note**: This guide also assumes basic understanding of JavaScript since Node.js is a JavaScript runtime environment, as well as basic Node.js and/or Express concepts.  

  

### Prerequisites

SSL certificate installation requires the certificate files provided by the Certificate Authority, as well as the matching private key for the SSL certificate.

These files should be uploaded to your server (or wherever the Node.js application is located) before proceeding to the next steps:

- Certificate (usually a .crt file).
- CA bundle/chain (usually a .ca-bundle file).
- Private key (usually a .key file).

The private key is generated prior to certificate activation, typically at the same time as the Certificate Signing Request (CSR). Even if you have the private key, it is worth checking that it is the correct one by matching it with your SSL certificate in [this tool](https://decoder.link/matcher).

**Please note**: While the files can be placed into any directory, make sure the directory that holds the private key is not public. The private key is meant to be stored securely on the server without any public access.

If you are unsure where to find the private key, we suggest checking out [this](https://www.namecheap.com/support/knowledgebase/article.aspx/9834/69/how-can-i-find-the-private-key-for-my-ssl-certificate) article. In case the private key is lost or there is no way to retrieve it, you can always [reissue](https://www.namecheap.com/support/knowledgebase/article.aspx/811/14/how-do-i-reissue-my-ssl-certificate) your certificate with a new [CSR and key](https://www.namecheap.com/support/knowledgebase/article.aspx/9704/2290/generating-a-csr-on-nodejs/) pair.

**Important**: When downloading certificate files from your Namecheap account, you will also receive a .p7b (PKCS#7 certificate) file. This file is not the private key and will not be needed for installation.

  

### Importing certificate files into your application

Node.js SSL/TLS capabilities are based on the OpenSSL library, so it’s flexible in the way it accepts SSL certificate files. The files can be read as buffers or as text (specifying the UTF-8 encoding) using the [FS (File System)](https://nodejs.org/dist/latest-v10.x/docs/api/fs.html) module, or can be simply provided as strings with the certificate code in the PEM format.

In most cases, the most straightforward way is preferred, which is reading the SSL certificate files from the file system as shown below:

|   |
|---|
|const fs = require('fs');<br><br>const cert = fs.readFileSync('./path/to/the/cert.crt');  <br>const ca = fs.readFileSync('./path/to/the/ca.crt');  <br>const key = fs.readFileSync('./path/to/the/private.key');|

The paths to these files can be relative or absolute. Feel free to use the [Path](https://nodejs.org/dist/latest-v10.x/docs/api/path.html) module to create the paths instead of using simple strings.

Below is an example setup when the files are being loaded:

![node_1](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/node_1.png)

In this example, the **ssl** directory was created specifically for SSL-related files, and the files are read from it. The cert, ca and key constants hold the respective representations of the SSL certificate, CA bundle, and private key files.

**Important**: Several certificates in a single file (which is typically needed for the CA bundle file) are supported from Node.js version 5.2.0. If you are using an earlier version of Node.js, you will need to provide an array of CA certificates as shown below.

The version of Node.js you have installed can be checked by running **_node -v_**.

If you are using Node.js 5.2.0 or higher, you can skip this section and jump straight to the [HTTPS on Node.js](https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/#https_node_js) or [HTTPS on Express](https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/#https_express).

In case you are using a version of Node.js prior to 5.2.0, you can follow the instructions below to split the CA bundle into separate SSL certificates.

You can manually separate the .ca-bundle file into separate certificate files using any text editor and load them into an array. Or, you can separate the .ca-bundle file within your app. Examples of both are provided below:

Using multiple CA certificate files:

|   |
|---|
|const ca = [  <br>   fs.readFileSync('./ssl/CAcert1.crt'),  <br>   fs.readFileSync('./ssl/CAcert2.crt')  <br>];|

If you separate the files manually, make sure to provide them in the same order they are in the .ca-bundle file.

Separating the file within the app:

|   |
|---|
|const caBundle = fs.readFileSync('./ssl/example.ca-bundle', {encoding:'utf8'});  <br>const ca = caBundle.split('-----END CERTIFICATE-----\r\n') .map(cert => cert +'-----END CERTIFICATE-----\r\n');  <br>_// We had to remove one extra item that is present due to  <br>// an extra line at the end of the file.  <br>// This may or may not be needed depending on the formatting  <br>// of your .ca-bundle file._  <br>ca.pop();  <br>console.log(ca);|

The result of running the above code should be an array of certificates as shown below:

![node_2](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/node_2.png)

  

### HTTPS on Node.js

  
**Creating an HTTPS server  
**  

The HTTPS server is created using the [https.createServer()](https://nodejs.org/dist/latest-v10.x/docs/api/https.html#https_https_createserver_options_requestlistener) method, which takes in an options object as its first argument, and the request listener callback as the second one. The options object should contain the following properties:

- cert - the certificate
- ca - the CA bundle (chain) provided in one file or as an array
- key - the private key

Additional options can be added to the object if needed.

**Please note**: If you have the certificate in .pfx (PKCS#12) format, you can use it by providing an options object with the pfx property containing the pfx file, and a passphrase property if needed.

As always, you can create the object before calling the method, or you can pass an anonymous object with the required properties, shown below:

|   |
|---|
|let options = {  <br>   cert: cert, // fs.readFileSync('./ssl/example.crt');  <br>   ca: ca, // fs.readFileSync('./ssl/example.ca-bundle');  <br>   key: key // fs.readFileSync('./ssl/example.key');  <br>};  <br>  <br>// also okay: https.createServer({cert, ca, key}, (req, res) => { ...  <br>const httpsServer = https.createServer(options, (req, res) => {  <br>   res.statusCode = 200;  <br>   res.setHeader('Content-Type', 'text/html');  <br>   res.end("<h1>HTTPS server running</h1>");  <br>});|

In the end, the boilerplate server code should look something like this:

![node_3](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/node_3.png)

Here we import the certificate files into an object on lines 7-11, then pass this object to the createServer method on line 13 which creates the HTTPS server, and finally call the [listen()](https://nodejs.org/dist/latest-v10.x/docs/api/https.html#https_server_listen) method on line 19 to start the server.

Make sure to restart your Node.js application if it was already running to apply the changes. To start the application, you can simply run **node .js** in the directory with your app, where **.js** is your application startup file.

This completes the setup! You can use the following tool to check the SSL certificate installation by entering the corresponding hostname and port you are using: https://decoder.link

  

**Redirecting to HTTPS**

To redirect HTTP requests to HTTPS, you will also need to set up an HTTP server with the [HTTP](https://nodejs.org/dist/latest-v10.x/docs/api/http.html) module.

In essence, redirecting an HTTP request to another URL requires two things: the corresponding response code (301 or 302) and the “Location” HTTP header with the URL that should be used instead.

Below you can find an example of how such an HTTP server can be set up:

|   |
|---|
|const http = require('http');  <br>const hostname = 'exampledomain.com';  <br>const httpServer = http.createServer((req, res) => {  <br>   res.statusCode = 301;  <br>   res.setHeader('Location', `https://${hostname}${req.url}`);  <br>   res.end(); // make sure to call send() or end() to send the response  <br>});  <br>httpServer.listen(80);|

In the above example, we also pass the requested URL from req.url.

If you were serving all content via HTTP before and would like to switch to HTTPS and set up the redirect, the easiest way should be just [changing your HTTP server to an HTTPS server](https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/#create_https_s), and [creating an additional HTTP server](https://nodejs.org/dist/latest-v10.x/docs/api/http.html#http_http_createserver_options_requestlistener) that will redirect the requests.

Below you can see a request made to such an HTTP server with a custom URL:

![node_4](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/node_4.png)

And then correctly passed to the HTTPS server:

![node_5](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/node_5.png)

  

### HTTPS on Express

  
**Setting up an HTTPS application with Express  
**  

Using HTTPS with Express requires creating an HTTPS server with the [HTTPS](https://nodejs.org/dist/latest-v10.x/docs/api/https.html) module from Node.js. Your Express app should be passed as a parameter to the [https.createServer()](https://nodejs.org/dist/latest-v10.x/docs/api/https.html#https_https_createserver_options_requestlistener) method:

|   |
|---|
|const https = require('https');  <br>const express = require('express');  <br>  <br>// const httpsOptions = {cert, ca, key};  <br>  <br>const app = express();  <br>const httpsServer = https.createServer(httpsOptions, app);  <br>  <br>// Your app code here  <br>  <br>httpsServer.listen(443, 'exampledomain.com');|

The httpsOptions parameter is an object identical to the one used in this section of the guide: [Creating an HTTPS server](https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/#create_https_s).

An example of the full code to create an HTTPS Express app is shown below:

![node_6](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/node_6.png)

At this point, you will have an Express app that is accessible via HTTPS. Note that the aforementioned example application will listen only to HTTPS requests on the specified port. If you also need your app to listen to HTTP requests, you will need to set up an HTTP server in a similar manner using [http.createServer()](https://nodejs.org/dist/latest-v10.x/docs/api/http.html#http_http_createserver_options_requestlistener) from the [HTTP](https://nodejs.org/dist/latest-v10.x/docs/api/http.html) module.

Make sure to restart your application if it was already running to apply the changes. To restart the application, you can simply run **node .js** in the directory with your app.

This tool can be used to check SSL certificate installation: [https://decoder.link](https://decoder.link)

  

**Redirecting to HTTPS with Express**

To redirect any HTTP requests to HTTPS, you will also need to have an HTTP server running that can listen to HTTP requests. The server should be created using the [HTTP](https://nodejs.org/dist/latest-v10.x/docs/api/http.html) module, and passed your Express app as a parameter in the same way the app was passed for the HTTPS server.

To create a redirect to HTTPS, you can set up a middleware function that will check if a request is made via HTTP and redirect it to HTTPS if it is. Below is an example of such middleware using the built-in [redirect()](https://expressjs.com/en/4x/api.html#res.redirect) method from Express:

|   |
|---|
|app.use((req, res, next) => {  <br>   if(req.protocol === 'http') {  <br>     res.redirect(301, `https://${req.headers.host}${req.url}`);  <br>   }  <br>   next();  <br>});|

Below is an example of a full Express app code that uses HTTPS and redirects all HTTP requests to HTTPS:

![node_7](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/node_7.png)

In the code above, we set up our Express app on line 16, then created HTTP and HTTPS servers on lines 17 and 18. Lines 20-25 create the middleware that redirects the HTTP requests to HTTPS. Lastly, as an example, we set up some server code on lines 30-35, and start the HTTP and HTTPS servers by calling their listen() methods on lines 37 and 38.

Below you can see the screenshots that illustrate the HTTP requests for both static files and custom URLs, which are redirected correctly.

Static files:

![node_8](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/node_8.png)

Custom URLs:

![node_9](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/node_9.png)

**Please note**: If Node.js was installed as a virtual environment on Namecheap shared hosting - it's not possible to install an SSL certificate on it, instead the certificate can be [easily installed via cPanel](https://www.namecheap.com/support/knowledgebase/article.aspx/9418/33/installing-a-ssl-certificate-on-your-server-using-cpanel).

### Associated articles

[How to enable SSL after purchase](https://www.namecheap.com/support/knowledgebase/article.aspx/10095/67/how-to-enable-ssl-after-purchase/)

Comments

We welcome your comments, questions, corrections and additional information relating to this article. Your comments may take some time to appear. Please be aware that off-topic comments will be deleted.

If you need specific help with your account, feel free to contact our [Support Team](https://www.namecheap.com/help-center/). Thank you.

Updated

**1/31/2024**

Viewed

**89503** times

[](http://www.facebook.com/sharer.php?u=https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/&t=Installing an SSL certificate on Node.js - SSL Installation - Namecheap.com&display=popup "Share on Facebook")[](http://twitter.com/share?url=https://www.namecheap.com/support/knowledgebase/article.aspx/9705/33/installing-an-ssl-certificate-on-nodejs/&text=Installing an SSL certificate on Node.js - SSL Installation - Namecheap.com&via=namecheap "Tweet This")