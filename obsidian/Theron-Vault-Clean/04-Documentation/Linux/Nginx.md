### Installing an SSL certificate on Nginx

Our SSL installation service makes SSL security hassle-free. [Learn more](https://www.namecheap.com/support/knowledgebase/article.aspx/10660/69/ssl-installation-service/).

- [Upload certificates](https://www.namecheap.com/support/knowledgebase/article.aspx/9419/33/installing-an-ssl-certificate-on-nginx/#upl)
- [Combine the files](https://www.namecheap.com/support/knowledgebase/article.aspx/9419/33/installing-an-ssl-certificate-on-nginx/#cmbn)
- [Configure the server block](https://www.namecheap.com/support/knowledgebase/article.aspx/9419/33/installing-an-ssl-certificate-on-nginx/#vh)
- [Configure HTTPS redirect](https://www.namecheap.com/support/knowledgebase/article.aspx/9419/33/installing-an-ssl-certificate-on-nginx/#https)

  

This article will guide you through the steps to install your [SSL certificate](https://www.namecheap.com/security/ssl-certificates/) on Nginx and to set up an automated redirect from HTTP:// to HTTPS://.  

1. ## Upload the certificates on the server where your website is hosted
    
    Having completed the [CSR code generation](https://www.namecheap.com/support/knowledgebase/article.aspx/9446/2290/generating-csr-on-apache-opensslmodsslnginx-heroku/) and [SSL activation](https://www.namecheap.com/support/knowledgebase/article.aspx/794/67/how-do-i-activate-an-ssl-certificate) steps, you will receive a zip file with the Sectigo (previously known as Comodo) Certificates via email. Alternatively, you can [download them](https://www.namecheap.com/support/knowledgebase/article.aspx/9464/14/can-i-download-an-issued-certificate-on-your-site) from your Namecheap Account panel.
    
    _**Note**: If you choose NGINX server when activating the certificate, you'll receive a zip file containing a Certificate file, with the '.crt' extension, and a Certificate Authority (CA) bundle file, with the '.ca-bundle' extension._
    
    Upload both files to your server whatever way you prefer. By using an FTP client, for example.
    
    You can also download the Bundle file for each Certificate by following the instructions [here](https://www.namecheap.com/support/knowledgebase/article.aspx/9393/69/where-do-i-find-ssl-ca-bundle).
    
  
  
4. ## Combine all the certificates into a single file
    
    You need to have all the Certificates (_your_domain.crt_ and _your_domain.ca-bundle_) combined in a single '.crt' file.
    
    The Certificate for your domain should come first in the file, followed by the chain of Certificates (CA Bundle).
    
    Enter the directory where you uploaded the certificate files. Run the following command to combine the files:
    
    _`$ cat your_domain.crt your_domain.ca-bundle >> your_domain_chain.crt      `**Please note** that if the certificate files were downloaded from your Namecheap account, the best command to use will be:_  
      
    `$ cat theronstein_com.crt > theronstein_com_chain.crt ; echo >> theronstein_com_chain.crt ; cat theronstein_com.ca-bundle >> theronstein_com_chain.crt`  
      
    Alternatively, you can combine the files using [this online tool](https://decoder.link) and following the steps below:  
    
    - Open _your_domain.crt_ file in a text editor and copy the certificate code, including the '-----BEGIN CERTIFICATE-----' and '-----END CERTIFICATE-----' tags.
    - Go to [decoder.link](https://decoder.link) and open the **SSL&CSR Decoder** tab.
    - Paste _your_domain.crt_ text code to the required field and hit **Decode**.  
          
        ![](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/decoder.link.png)
    - Next, scroll down the results and find **Bundle (Nginx)** section within the **General Information** part.
    - Click on the floppy disk icon over on the right to download the generated file.  
          
        ![](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/decoder.link_2.png)
    - The 'nginx_bundle.zip' file will be downloaded to your PC. Unzip it and use the _nginx_bundle_l3s4k9n1l0s3.crt_ file (the '_l3s4k9n1l0s3'_ part of the name is a random alphanumeric string) for installation.
    
      
    That's it!
  
6. ## Creating a separate Nginx server block or Modifying the existing configuration file
    
    To install the SSL certificate on Nginx, you need to show the server which files to use, either by a) creating a new configuration file, or b) editing the existing one.
    
        a) By adding a new configuration file for the website you can make sure that there are no issues with the separate configuration file. Furthermore, it will be quite easier to troubleshoot the installation in case of any issues with the new configuration.
    
    We suggest creating a new configuration file in this folder:
    
    `**/etc/nginx/conf.d**`
    
    That can be done via this command:
    
    _`**sudo nano /etc/nginx/conf.d/Your_domain*-ssl.conf**`_
    
    _Where **`Your_domain*-ssl.conf`** is the name of the newly created file._
    
    Next, copy and paste one of the below server blocks for the 443 port and edit the directories. Ensure the _server name_ and _path to webroot match in both the server block for port 80 and the one for port 443_. If you have any other important values that need to be saved, move them to the newly created server block too.
    
        b) Edit the default configuration file of the web-server, which is named `**nginx.conf**`. It should be in one of these folders:
    
    `**/usr/local/nginx/conf**`
    
    `**/etc/nginx**`
    
    `**/usr/local/etc/nginx**`
    
    You can also use this command to find it:
    
    `**sudo find / -type f -iname "nginx.conf"**`
    
    Once you find it, open the file with:
    
    `**sudo nano nginx.conf**`
    
    Then copy and paste one of the server blocks for the 443 port given below and edit the directories _according to your server block for the 80 port_ (with _matching server name, path to webroot,_ and any _important values_ you need). Alternatively you can copy the server block for 80 port, then paste it below, update the port and add the necessary SSL-related directives.  
    
    ### Choose the server block:
    
    Below you can find a server block for _your_ Nginx version.
    
    _**Note**: To check your Nginx version, run this command:_
    
    `**sudo nginx -v**`
    
    ![](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/nginx_inst_1.png)
    
    _**Note**: Replace the file names values, like `**your_domain_chain.crt**`, in the server block with your details, and modify the routes to them using_`**/path/to/**.`
    
    - Server block for Nginx version 1.14 and below:
    
    `**server {**`
    
    `**listen 443;**`
    
    `**ssl on;**`
    
    `**ssl_certificate /path/to/certificate/your_domain_chain.crt;**`
    
    `**ssl_certificate_key /path/to/your_private.key;**`
    
    `**root /path/to/webroot;**`
    
    `**server_name your_domain.com;**`
    
    `**}      **`
    
    _**Note**: You can specify multiple hostnames in such configuration, if needed, e.g._:  
      
    `**server {**`
    
    `**listen 443;**`
    
    `**ssl on;**`
    
    `**ssl_certificate /path/to/certificate/your_domain_chain.crt;**`
    
    `**ssl_certificate_key /path/to/your_private.key;**`
    
    `**root /path/to/webroot;**`
    
    `**server_name your_domain.com www.your_domain.com;**`
    
    `**}      **`
    
    - Server block for Nginx version 1.15 and above:  
          
        
    
    `**server {**`
    
    `**listen 443 ssl;**`
    
    `**ssl_certificate /path/to/certificate/your_domain_chain.crt;**`
    
    `**ssl_certificate_key /path/to/your_private.key;**`
    
    `**root /path/to/webroot;**`
    
    `**server_name your_domain.com;**`
    
    `**}      **`
    
    - `**ssl_certificate**` should be pointed to the file with combined certificates you’ve [created earlier](https://www.namecheap.com/support/knowledgebase/article.aspx/9419/33/installing-an-ssl-certificate-on-nginx/#cmbn).
    - `**ssl_certificate_key**` should be pointed to the Private Key that was [generated with the CSR code](https://www.namecheap.com/support/knowledgebase/article.aspx/9446/2290/generating-csr-on-apache-opensslmodsslnginx-heroku/).  
        _Here are [a few tips on how to find the Private key](https://www.namecheap.com/support/knowledgebase/article.aspx/9834/69/how-can-i-find-the-private-key-for-my-ssl-certificate#lnx) on Nginx._
    
    _**  
    Important**: For either a [Multi-Domain](https://www.namecheap.com/security/ssl-certificates/multi-domain.aspx) or a [Wildcard Certificate](https://www.namecheap.com/security/ssl-certificates/wildcard.aspx), you’ll need to have a separate server block added for each of the domain/subdomain included in the Certificate. Ensure you specify the domain/subdomain in question along with the paths to the same Certificate files in the server block, as described above._
    
    Once the corresponding server block is added to the file, ensure you save the edits. Then, you can double-check the changes made with the following steps.
    
    Run this command to verify that the configuration file syntax is ok:
    
    `**sudo nginx -t**`
    
    ![](https://Namecheap.simplekb.com/SiteContents/2-7C22D5236A4543EB827F3BD8936E153E/media/nginx_inst_2.png)
    
    If you receive errors, double check that you followed the guide properly. Feel free to contact our [Support Team](https://www.namecheap.com/support/) if you have any questions.  
      
    _**Here's the tip**: to find the error logs for troubleshooting, just run:_
    
    _`sudo nginx -T | grep 'error_log'`_
    
    _In case none of the files mentioned exist, files are commented out or if no error log files are specified, default system log should be checked:_
    
    _`tail /var/log/nginx/error.log -n 20`_
    
    If the server displays the test successfully, restart Nginx with this command to apply the changes:
    
    `**sudo nginx -s reload**`
    
    Now your SSL Certificate is installed. You can check the installation [here](https://decoder.link/).  
      
    **Important notes**:  
      
    Sometimes, after installing SSL file that was combined using a command line, you may receive '`[Nginx/Apache error: 0906D066:PEM routines:PEM_read_bio:bad end line](https://www.namecheap.com/support/knowledgebase/article.aspx/9855/2238/nginxapache-error-0906d066pem-routinespemreadbiobad-end-line)`' error message, in this case, the workaround can be found in the reference guide.  
      
    Another common issue on this stage is the '`Nginx SSL: error:0B080074:x509 certificate routines: X509_check_private_key:key values mismatch`' error message, you can find more details on it and the possible ways out in [this article](https://www.namecheap.com/support/knowledgebase/article.aspx/9781/2238/nginx-ssl-error0b080074x509-certificate-routines-x509checkprivatekeykey-values-mismatch).  
      
      
    
7. ## Configure HTTPS redirect
    
    We suggest that you install the redirect from HTTP to HTTPS. That way, your website visitors will only be able to access the secure version of your site.
    
    To do this, you’ll need to add one line to the configuration file with the server block for port 80.
    
    _**Tips:**_
    
    - _You can use one of the following commands to look up the configuration files which are enabled now:  
          
        _
    
    **`sudo nginx -T | grep -iw "configuration file"`**
    
    **`sudo nginx -T | grep -iw "include"`**
    
    - _The default paths to the conf file are:  
          
        _
    
    _on RHEL-based Linux OS: `**/etc/nginx/conf.d/default.conf**`_
    
    _on Debian-based Linux OS: `**/etc/nginx/sites-enabled/default**`_
    
    - _You can open the files to check which one contains the needed server block. For this, run:  
          
        _
    
    **`sudo nano name_of_the_file`**
    
    Once you find the file that contains the server block for port 80 (the default HTTP port), add in the following line:
    
    **`return 301 https://$server_name$request_uri;`**
    
    `**Note**: The above redirect rule should be entered as the last line in the server block.`
    
    - `**return**` is the main directive to use.
    - `**301**` is permanent redirect (302 is the temporary one).
    - `**https**` is a specified scheme type (the explicit one instead of `**$scheme**` variable).
    - `**$server_name**` variable will use the domain specified in the server_name directive.
    - `**$request_uri**` variable is used to match the paths to the requested pages/parts of the website (everything after the domain name).  
          
        
    
    Here are examples of server blocks with the HTTPS redirect:
    
    ### Permanent redirect to HTTPS
    
    `server {`
    
    `listen 80;`
    
    `server_name your_domain.com www.your_domain.com;`
    
    `**return 301 https://$server_name$request_uri;**`
    
    `}`
    
    ### Permanent redirect to HTTPS non-www
    
    `server {`
    
    `listen 80;`
    
    `server_name your_domain.com www.your_domain.com;`
    
    `**return 301 https://your_domain.com$request_uri;**`
    
    `}`
    
    ### Permanent redirect to HTTPS www
    
    `server {`
    
    `listen 80;`
    
    `server_name your_domain.com www.your_domain.com;`
    
    `**return 301 https://www.your_domain.com$request_uri;**`
    
    `}`
    
    ### Temporary redirect to HTTPS non-www
    
    `server {`
    
    `listen 80;`
    
    `server_name your_domain.com www.your_domain.com;`
    
    `**return 302 https://your_domain.com$request_uri;**`
    
    `}`
    
    You can find more details about redirect options on Nginx [here](https://www.namecheap.com/support/knowledgebase/article.aspx/9805/38/setting-https-redirect-on-a-nginx-webserver).