# Puppeteer HTTP-server

## Versions

Docker image version is Puppeteer version.

## Environement variables

| Variable      | Description | Default value |
| ----------- | ----------- | --------- |
| `TMP_PATH`      | Temporary folder where the generated files will be added (for example, when generating PDF). You can pass volume in docker-compose and save there | `/tmp` |
| `SERVER_URL`   | For returned files URLs. For example, when generating a PDF, a link like `http://localhost:3000/123.pdf` will be returned. You can define this host for convenience. Also server serves static from `TMP_PATH` | empty |
| `PORT` | HTTP-server port | `3000` |
| `REQUEST_SIZE` | Request payload size in express format (`10mb` etc) | `20mb` |

## Using with docker-compose

In `docker-compose-yml` simple config.