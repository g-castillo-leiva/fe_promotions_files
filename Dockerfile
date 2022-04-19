FROM python:3.8-alpine

WORKDIR /app


RUN apk add --no-cache ca-certificates && update-ca-certificates
ARG CONSUL_TEMPLATE_VERSION=0.25.1
RUN wget "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tgz"
RUN tar zxfv consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tgz

RUN apk add --no-cache jq
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . . 
RUN chmod +x ./infraestructure/entrypoint.sh
ENTRYPOINT ["./infraestructure/entrypoint.sh"]
ENV FLASK_ENV production
CMD ["python3", "manage.py" "run"]