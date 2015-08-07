This presentation was created from 129 lines of simple markdown formatted text using the publishing tool from Jurgen Leschner called [pub-server](https://github.com/jldec).  

#Install node installation  
```sh  
$ curl -sL https://deb.nodesource.com/setup_0.10 | sudo -E bash -
$ sudo apt-get install -y nodejs
```

#Install pub-server  
```sh  
$ sudo npm install -g pub-server  
```

#Update other packages 
```sh  
$ sudo npm update -g pub-server
```

#Run server  
```sh  
$ pub
```

#View Presentation  
```sh  
chromium-browser http://localhost:3001/openness
```


