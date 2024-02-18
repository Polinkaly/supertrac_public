FROM python:3.7-alpine

RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev

RUN pip3 install psycopg2==2.8.6

WORKDIR /trac_deploy

COPY .htpasswd .

ADD start.sh /trac_deploy/start.sh 

COPY Trac-1.7.1.dev0-py3-none-any.whl .

RUN pip3 install Trac-1.7.1.dev0-py3-none-any.whl

RUN trac-admin /trac_project initenv 'Project1' postgres://postgres:qwas@192.168.1.194/trac

ENTRYPOINT ["/bin/sh"]

CMD ["/trac_deploy/start.sh"]

EXPOSE 8000
