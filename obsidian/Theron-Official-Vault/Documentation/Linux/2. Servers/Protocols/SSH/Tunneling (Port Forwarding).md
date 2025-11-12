### Local Tunneling

Local port forwarding is mostly used to connect to a remote service on an internal network such as a database or VNC server.

In Linux, macOS, and other Unix systems, to create a local port forwarding, pass the `-L` option to the `ssh` client:

* Command*
```
ssh -L [LOCAL_IP:]LOCAL_PORT:DESTINATION:DESTINATION_PORT [USER@]SSH_SERVER
```](<ssh -L [LOCAL_IP:]LOCAL_PORT:DESTINATION:DESTINATION_PORT [USER@]SSH_SERVER

The options used are as follows:

    [LOCAL_IP:]LOCAL_PORT - The local machine IP address and port number. When LOCAL_IP is omitted, the ssh client binds on the localhost.
    DESTINATION:DESTINATION_PORT - The IP or hostname and the port of the destination machine.
    [USER@]SERVER_IP - The remote SSH user and server IP address.

You can use any port number greater than 1024 as a LOCAL_PORT. Ports numbers less than 1024 are privileged ports and can be used only by root. If your SSH server is listening on a port other than 22 (the default), use the -p [PORT_NUMBER] option.

The destination hostname must be resolvable from the SSH server.

Let’s say you have a MySQL database server running on machine db001.host on an internal (private) network, on port 3306, which is accessible from the machine pub001.host, and you want to connect using your local machine MySQL client to the database server. To do so, you can forward the connection using the following command:

ssh -L 3336:db001.host:3306 user@pub001.host

Once you run the command, you’ll be prompted to enter the remote SSH user password. Once entered, you will be logged into the remote server, and the SSH tunnel will be established. It is also a good idea to set up an SSH key-based authentication and connect to the server without entering a password.

Now, if you point your local machine database client to 127.0.0.1:3336, the connection will be forwarded to the db001.host:3306 MySQL server through the pub001.host machine that acts as an intermediate server.

You can forward multiple ports to multiple destinations in a single ssh command. For example, you have another MySQL database server running on machine db002.host, and you want to connect to both servers from your local client, you would run:

ssh -L 3336:db001.host:3306 3337:db002.host:3306 user@pub001.host

To connect to the second server, you would use 127.0.0.1:3337.

When the destination host is the same as the SSH server, instead of specifying the destination host IP or hostname, you can use localhost.

Say you need to connect to a remote machine through VNC, which runs on the same server, and it is not accessible from the outside. The command you would use is:

ssh -L 5901:127.0.0.1:5901 -N -f user@remote.host

The -f option tells the ssh command to run in the background and -N not to execute a remote command. We are using localhost because the VNC and the SSH server are running on the same host.

If you are having trouble setting up tunneling, check your remote SSH server configuration and make sure AllowTcpForwarding is not set to no. By default, forwarding is allowed.>)