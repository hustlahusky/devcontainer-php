# Reference: https://docs.docker.com/build/bake/reference/

group "default" {
    targets = ["devcontainer"]
}

target "devcontainer" {
    tags = [
        "ghcr.io/hustlahusky/devcontainer-php:latest"
    ]
    dockerfile = "Dockerfile"
    target = "devcontainer"
    args = {
        // ALPINE_REPO = "https://mirror.yandex.ru/mirrors/alpine/"
    }
    labels = {
        "devcontainer.metadata" = jsonencode({
            customizations = {
                vscode = {
                    extensions = [
                        "/opt/phpactor/phpactor.vsix"
                    ]
                    settings = {
                        "phpactor.path": "/opt/phpactor/bin/phpactor"
                    }
                }
            }
        })
    }
}
