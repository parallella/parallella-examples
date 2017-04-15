WEBSERVER EXAMPLE
===========================================================================

# !!!!USE AT YOUR OWN RISK!!!!

## Install Apache
```sh
sudo apt install apache2
```
## Copy static page to Apache search path
```sh
sudo cp index.html /var/www/html/index.html
```

## Enable CGI scripts

```sh
sudo emacs /etc/apache2/sites-available/000-default.conf
```

To enable CGI scripts, uncomment the line "#Include conf-available/serve-cgi-bin.conf"

## Copy server script to Apache search path
```sh
sudo cp echo.sh /usr/lib/cgi-bin
```

## Start Apache Server 
```sh
 sudo service apache2 start
```

## Access website on local machine (in your browswer)
http://localhost/

## Access website on remote Parallella (in your browser)

http://parallella


## Stop Apache server 
```sh
 sudo service apache2 stop
```

