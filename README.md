# 🐳 PHP Dev Container

Prebuilt development environment for PHP.

Battaries included:

- PHP 8.2
- Git
- Composer
- Phpactor language server
- Docker CLI (with compose and buildx plugins)
- Bash and Starship
- Automatic user creation on container startup
- History persistance

## Add `.devcontainer.json` to your project

```bash
curl -sSL https://raw.githubusercontent.com/hustlahusky/devcontainer-php/master/install.sh | bash > .devcontainer.json
```

## Pull docker image

```bash
docker pull ghcr.io/hustlahusky/devcontainer-php:latest
```
