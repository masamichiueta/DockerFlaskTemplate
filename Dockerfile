FROM python:3.6

RUN pip install uwsgi
RUN which uwsgi

RUN apt-get update \
	&& apt-get install -y nginx supervisor \
	&& rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/conf.d/
COPY uwsgi.ini /etc/uwsgi/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY ./ /app
WORKDIR /app
RUN pip install -r requirements.txt

CMD ["/usr/bin/supervisord"]
