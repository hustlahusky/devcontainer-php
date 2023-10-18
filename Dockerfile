FROM php:8.2-cli-alpine AS php_cli_upstream
FROM composer/composer:2-bin AS composer_upstream
FROM mlocati/php-extension-installer:2 as extension_installer_upstream
FROM docker/compose-bin:latest AS docker_compose_upstream
FROM docker/buildx-bin:latest AS docker_buildx_upstream

FROM php_cli_upstream AS phpactor

ARG PHPACTOR_VER=2023.09.24.0
RUN --mount=type=bind,from=composer_upstream,source=/composer,target=/usr/local/bin/composer \
    curl -sSL https://github.com/phpactor/phpactor/archive/refs/tags/${PHPACTOR_VER}.tar.gz -o /opt/phpactor.tar.gz \
        && tar -xzf /opt/phpactor.tar.gz -C /opt \
        && mv /opt/phpactor-${PHPACTOR_VER} /opt/phpactor \
        && composer install --ignore-platform-reqs --no-dev --working-dir=/opt/phpactor \
        && curl -sSL https://github.com/phpactor/vscode-phpactor/releases/latest/download/phpactor.vsix -o /opt/phpactor/phpactor.vsix \
        && true

FROM php_cli_upstream AS devcontainer

ARG ALPINE_REPO=http://dl-cdn.alpinelinux.org/alpine/
RUN --mount=type=cache,target=/var/cache/apk,target=/var/cache/apk,sharing=locked,id=apk \
    sed -i -r 's#^http.+/(.+/main)#'${ALPINE_REPO%/}'/\1#' /etc/apk/repositories \
    && sed -i -r 's#^http.+/(.+/community)#'${ALPINE_REPO%/}'/\1#' /etc/apk/repositories \
    && sed -i -r 's#^http.+/(.+/testing)#'${ALPINE_REPO%/}'/\1#' /etc/apk/repositories \
    && apk update -qq \
    && apk upgrade -qq \
    && apk add --no-cache --update \
        bash \
        binutils \
        ca-certificates \
        coreutils \
        curl \
        docker-bash-completion \
        docker-cli \
        git \
        gnu-libiconv \
        gnupg \
        htop \
        less \
        lsof \
        man-pages \
        mandoc \
        nano \
        net-tools \
        openssh-client \
        procps \
        psmisc \
        rsync \
        shadow \
        socat \
        starship \
        sudo \
        tzdata \
        unzip \
        vim \
        wget \
        zip \
        zlib \
    && mkdir -p /usr/local/lib/docker/cli-plugins \
    && usermod --shell /bin/bash root \
    && true

# https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions
RUN --mount=type=bind,from=extension_installer_upstream,source=/usr/bin/install-php-extensions,target=/usr/local/bin/install-php-extensions \
    --mount=type=cache,target=/var/cache/apk,target=/var/cache/apk,sharing=locked,id=apk \
    install-php-extensions \
        apcu \
        bcmath \
        intl \
        opcache \
        pcntl \
        zip \
    && true

COPY --link --from=phpactor /opt/phpactor /opt/phpactor
COPY --link --from=composer_upstream /composer /usr/local/bin/
COPY --link --from=docker_compose_upstream /docker-compose /usr/local/lib/docker/cli-plugins/docker-compose
COPY --link --from=docker_buildx_upstream /buildx /usr/local/lib/docker/cli-plugins/docker-buildx
COPY --link rootfs/ /

RUN chmod +x \
        /usr/local/bin/docker-entrypoint \
    && true

ENV \
    PATH="${PATH}:/opt/phpactor/bin" \
    COMPOSER_HOME=/data/.composer

ENTRYPOINT ["docker-entrypoint"]
CMD ["--sleep"]
VOLUME [ "/data" ]
