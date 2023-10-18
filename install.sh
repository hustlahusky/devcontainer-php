#!/usr/bin/env bash
set -e

DEV_USER_ID=$(id -u)
DEV_USER_NAME=$(getent passwd ${DEV_USER_ID} | awk -F: '{print $1}')
DEV_USER_HOME=$(getent passwd ${DEV_USER_ID} | awk -F: '{print $6}')
DEV_GROUP_ID=$(id -g)
DEV_GROUP_NAME=$(getent group ${DEV_GROUP_ID} | awk -F: '{print $1}')

DOCKER_SOCKET=$(docker context inspect -f '{{ .Endpoints.docker.Host }}' || echo "")
case "${DOCKER_SOCKET}" in
    unix:/*) DOCKER_SOCKET="${DOCKER_SOCKET:7}" ;;
    *)  DOCKER_SOCKET="" ;;
esac

echo "// Reference: https://aka.ms/devcontainer.json"
echo "{"
echo "  \"name\": \"devcontainer-php\","
echo "  \"image\": \"ghcr.io/hustlahusky/devcontainer-php:latest\","
echo "  \"overrideCommand\": false,"
echo "  \"runArgs\": ["
echo "    \"--rm\","
echo "    \"--init\""
echo "  ],"
echo "  \"containerEnv\": {"
echo "    \"DEV_USER_ID\": \"${DEV_USER_ID}\","
echo "    \"DEV_USER_NAME\": \"${DEV_USER_NAME}\","
echo "    \"DEV_USER_HOME\": \"${DEV_USER_HOME}\","
echo "    \"DEV_GROUP_ID\": \"${DEV_GROUP_ID}\","
echo "    \"DEV_GROUP_NAME\": \"${DEV_GROUP_NAME}\""
echo "  },"
echo "  \"remoteUser\": \"${DEV_USER_NAME}\","
echo "  \"updateRemoteUserUID\": false,"
echo "  \"workspaceMount\": \"source=\${localWorkspaceFolder},target=\${localWorkspaceFolder},type=bind\","
echo "  \"workspaceFolder\": \"\${localWorkspaceFolder}\","
echo "  \"mounts\": ["
if [[ "${DOCKER_SOCKET}" != "" ]]; then
    echo "    \"source=${DOCKER_SOCKET},target=/var/run/docker-host.sock,type=bind\","
fi
echo "    \"source=$(basename ${PWD})-devcontainer-php,target=/data,type=volume\""
echo "  ],"
echo "  \"customizations\": {"
echo "    \"vscode\": {"
echo "      \"extensions\": []"
echo "    }"
echo "  }"
echo "}"
