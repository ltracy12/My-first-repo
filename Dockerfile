FROM nginx:1.19.0 
MAINTAINER zhoulj@harbor.peppa-pig.info

## change timezone to china
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt install -y tzdata && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

## copy file to ningx workdir
ADD html/index.html /usr/share/nginx/html

