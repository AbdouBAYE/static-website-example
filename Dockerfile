FROM nginx
MAINTAINER THIONGANE Abdoulaye
RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y git
RUN rm -Rf /usr/share/nginx/html/*
RUN git clone https://github.com/AbdouBAYE/static-website-example.git /usr/share/nginx/html
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
