#!/bin/sh
echo "[server-startup] Executing bootstrap script"

set -e
echo "Validating required params..."

if [ -z $ENVIRONMENT ]; then
  echo "ENVIRONMENT is missing"
  exit 1
fi

if [ -z $CONSUL_HTTP_ADDR ]; then
  echo "CONSUL_HTTP_ADDR is missing"
  exit 2
fi

if [ -z $CONSUL_HTTP_TOKEN ]; then
  echo "CONSUL_HTTP_TOKEN is missing"
  exit 3
fi

# dynamicaly parse a Consul template

sed -e "s/{ENVIRONMENT}/$ENVIRONMENT/g" ./infraestructure/env.tmpl > ./env_app.tmpl
./consul-template -template="./env_app.tmpl:./.env" \
                 -config ./infraestructure/config.hcl -once -log-level info

$(jq -r 'keys[] as $k | "export \($k)=\(.[$k])"' ./.env)

python3 manage.py run  -h 0.0.0.0