
FROM bodsch/docker-dashing:1711.1

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

ENV \
  BUILD_DATE="2017-11-09" \
  DASHBOARD="icinga2" \
  ICINGA2_GEM_VERSION="0.9"

EXPOSE 3030

LABEL \
  version="1711" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.name="Dashing Icinga2 Docker Image" \
  org.label-schema.description="Inofficial Dashing Icinga2 Docker Image" \
  org.label-schema.url="https://github.com/Smashing/smashing" \
  org.label-schema.vcs-url="https://github.com/bodsch/docker-dashing-icinga2" \
  org.label-schema.vendor="Bodo Schulz" \
  org.label-schema.version=${ICINGA_VERSION} \
  org.label-schema.schema-version="1.0" \
  com.microscaling.docker.dockerfile="/Dockerfile" \
  com.microscaling.license="GNU General Public License v3.0"

# ---------------------------------------------------------------------------------------

COPY build /build

RUN \
  apk --no-cache update && \
  apk --no-cache upgrade && \
  apk --no-cache add \
    build-base \
    git \
    jq \
    openssl-dev \
    ruby-dev \
    openssl-dev \
    supervisor && \
  cd /opt && \
  smashing new ${DASHBOARD} && \
  rm -f /opt/${DASHBOARD}/jobs/twitter* && \
  rm -f /opt/${DASHBOARD}/dashboards/* && \
  cd ${DASHBOARD} && \
  bundle config local.icinga2 /build && \
  sed -i "/gem 'twitter'/d" Gemfile && \
  #
  cd /opt/${DASHBOARD} && \
  count=$(ls -1 /build/*.gem 2> /dev/null | tail -n1) && \
  if [ ! -z ${count} ] ; then \
    gem install --no-rdoc --no-ri ${count} ; \
  else \
    echo "gem 'icinga2', '~> ${ICINGA2_GEM_VERSION}'" >> Gemfile ; \
  fi && \
  #
  bundle update && \
  apk del --purge \
    build-base \
    git \
    ruby-dev \
    openssl-dev && \
  rm -rf \
    /tmp/* \
    /build \
    /var/cache/apk/* \
    /usr/lib/ruby/gems/current/cache/* \
    /root/.gem \
    /root/.bundle

COPY rootfs/ /

WORKDIR /opt/${DASHBOARD}

CMD [ "/init/run.sh" ]

# ---------------------------------------------------------------------------------------
