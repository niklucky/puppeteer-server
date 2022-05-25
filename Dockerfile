FROM node:16-alpine as preparation

ENV DEBIAN_FRONTEND="noninteractive" \
    APP_PATH="/opt/puppeteer/server" \
    APP_PROJECT_ID="puppeteer-server" \
    APP_USER="docker-user" \
    APP_GROUP_ID=1500 \
    APP_USER_ID=1500 \
    NODE_ENV="production"

RUN apk add chromium

# RUN apt-get install -y ca-certificates fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 \
#     libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 \
#     libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
#     libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 \
#     libxtst6 lsb-release wget xdg-utils

# RUN apt-get install -y libnss3 libnssutil3 libsmime3 libnspr4 libatk-1.0 libatk-bridge-2.0 \
#     libcups libdrm libdbus-1 libxkbcommon libXcomposite libXdamage libXfixes \
#     libXrandr libgbm libasound libatspi

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN addgroup -g "${APP_GROUP_ID}" "${APP_USER}"
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --ingroup "$APP_USER" \
    --no-create-home \
    --uid "$APP_USER_ID" \
    "$APP_USER"

RUN mkdir -p "${APP_PATH}/node_modules/.bin"
RUN chown -R "${APP_USER}":"${APP_USER}" "${APP_PATH}"

USER "${APP_USER}"

WORKDIR "${APP_PATH}"

COPY --chown="${APP_USER}:${APP_USER}" \
[    \
    "package.json", \
    "yarn.lock", \
    "tsconfig.json", \
    "${APP_PATH}/" \
]

FROM preparation as builder

RUN yarn install \
    --non-interactive \
    --production=false \
    --frozen-lockfile \
    --network-timeout 1000000 \
    && yarn cache clean

ENV PATH="${PATH}:${APP_PATH}/node_modules/.bin"

COPY --chown="${APP_USER}:${APP_USER}" ./  "${APP_PATH}/"

RUN ["yarn","run","build"]

FROM preparation as worker

RUN yarn install \
    --non-interactive \
    --production=true \
    --frozen-lockfile \
    --network-timeout 1000000 \
    && yarn cache clean

ENV PATH="${PATH}:${APP_PATH}/node_modules/.bin"

COPY --from=builder --chown="${APP_USER}:${APP_USER}" "${APP_PATH}/dist/" "${APP_PATH}/dist/"

CMD ["yarn","run","start"]

