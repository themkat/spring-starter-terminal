[![Lint script](https://github.com/themkat/spring-starter-terminal/actions/workflows/lint.yml/badge.svg)](https://github.com/themkat/spring-starter-terminal/actions/workflows/lint.yml)
# Spring Starter Terminal
Simple script that uses dialog as a terminal UI for creating new Spring application using the Spring Starter / Spring Initializer service. A little quick and dirty, and the UI has major room for improvement relating to sizes. You can create a project, and it will unpack in the folder you are running the script from (useful to have in PATH if you dare ;) ).


![screen recording](screenrecording.gif)


## Dependencies
- bash (or equivalent, also tested with zsh)
- Standard Unix tools (sed, curl)
- dialog
- jq


## Container image
If you prefer to use the script from a container, [it is available on Docker hub and is called themkat/spring-starter](https://hub.docker.com/r/themkat/spring-starter). You can also build it yourself from this repo using the included Dockerfile using `docker build -t themkat/spring-starter .`.
