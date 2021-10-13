# please

A collection of scripts they can be used for deploying viva-con-agua services.
 
## Install
Download repository from github.com and install the base version:
```
git clone git@github.com:Viva-con-Agua/please.github
cd please
please base install

```

## Frontend

You can use the frontend service for deploying a service behind an 
nginx reverse proxy that listen on port 80 or 80/443 in case of live mode.

### adding service
```
[service]
    docker_ip=
    route=
    repo=
    repo_name=
```
For adding a new frontend service it's important to edit `config/frontend.ini` 
and add an entry for an new service. `docker_ip` need to define with an unused ip address. 
For setting the subdomain use `route`. In case you want to install the service directly from github.com
you need to define the `repo` and the `repo_name` variable.



### install service
```
please frontend install <service>
```  
Installs a frontend app by using the `frontend.ini` config file.
The script download the repository from github build it
and link it to frontend-nginx

### link service
```    
please frontend link <service>
```
Link the service to the `frontend-nginx` by using the ip defined in the frontend.ini. 
In case you want to deploy a third party service. 

## Link 

## Config
