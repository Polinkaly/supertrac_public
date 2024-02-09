FROM python:3.7-alpine

RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev

RUN pip3 install psycopg2==2.8.6

WORKDIR /trac_deploy

COPY .htpasswd .

COPY Trac-1.7.1.dev0-py3-none-any.whl .

RUN pip3 install Trac-1.7.1.dev0-py3-none-any.whl

WORKDIR /trac_project

RUN trac-admin /trac_project initenv 'Project1' 
postgres://postgres:qwas@10.26.0.32/trac

#RUN chown -R apache:apache /trac_project

CMD ["tracd", "--port", "8000", "/trac_project"]

EXPOSE 8000
