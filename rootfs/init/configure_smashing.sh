
ICINGAWEB_URL=${ICINGAWEB_URL:-"http://localhost/icingaweb2"}
PROXY_PATH=${PROXY_PATH:-""}

DASHBOARD=${DASHBOARD:-icinga2}

DASHING_PATH="/opt/${DASHBOARD}"
CONFIG_FILE="${DASHING_PATH}/config.ru"

# -------------------------------------------------------------------------------------------------

if [ -f ${CONFIG_FILE} ]
then
  sed -i 's|%AUTH_TOKEN%|'${AUTH_TOKEN}'|g' ${CONFIG_FILE}
fi

icinga_dashboard="${DASHING_PATH}/dashboards/icinga2.erb"

if [ -f "${icinga_dashboard}" ]
then
  sed -i \
    -e 's|%ICINGAWEB_URL%|'${ICINGAWEB_URL}'|g' \
    -e 's|%PROXY_PATH%|'${PROXY_PATH}'|g' \
    ${icinga_dashboard}
fi

if [ ! -z ${PROXY_PATH} ]
then

  sed -i \
    -e "s/^run Sinatra::Application$/run Rack::URLMap.new\('%PROXY_PATH%' => Sinatra::Application\)/g" \
    ${CONFIG_FILE}
fi

app_coffee="${DASHING_PATH}/assets/javascripts/application.coffee"

if [ $(grep -c "Batman.config.viewPrefix" ${app_coffee})  -eq 0 ]
then

  ed ${app_coffee} > /dev/null << END
9i
Batman.config.viewPrefix = '%PROXY_PATH%/views'
.
w
q
END
fi
echo ""

sed -i \
  -e 's|%PROXY_PATH%|'${PROXY_PATH}'|g' \
  ${app_coffee}


layout="${DASHING_PATH}/dashboards/layout.erb"

if [ -f ${layout} ]
then
  sed -i \
    -e 's|%PROXY_PATH%|'${PROXY_PATH}'|g' \
    ${layout}
fi

sed -i \
  -e 's|%DASHBOARD%|'${DASHBOARD}'|g' \
  -e 's|%PROXY_PATH%|'${PROXY_PATH}'|g' \
  ${CONFIG_FILE}


if [ -f /etc/supervisor.d/dashing.ini ]
then
  sed -i \
    -e 's|%DASHBOARD%|'${DASHBOARD}'|g' \
    /etc/supervisor.d/dashing.ini
fi

cp /usr/lib/ruby/gems/current/gems/smashing/templates/project/assets/stylesheets/font-awesome.css ${DASHING_PATH}/assets/stylesheets/


for f in font-awesome.css font-awesome.min.css
do
  if [ -f ${DASHING_PATH}/assets/stylesheets/${f} ]
  then
    sed \
      -i \
      -e "s|'../fonts/|'|g" \
      ${DASHING_PATH}/assets/stylesheets/${f}
  fi
done

# EOF
