FROM node:16 as preparation

ENV DEBIAN_FRONTEND="noninteractive" \
    APP_PATH="/opt/puppeteer/server" \
    APP_PROJECT_ID="puppeteer-server" \
    APP_USER_NAME="docker-user" \
    APP_GROUP_NAME="docker-group" \
    APP_GROUP_ID=1500 \
    APP_USER_ID=1500 \
    NODE_ENV="production"

RUN mkdir -p "${APP_PATH}/node_modules/.bin" \
    && groupadd -g "${APP_GROUP_ID}" "${APP_GROUP_NAME}" \
    && useradd -u "${APP_USER_ID}" -d "${APP_PATH}" -g "${APP_GROUP_NAME}" "${APP_USER_NAME}" \
    && chown -R "${APP_USER_NAME}":"${APP_GROUP_NAME}" "${APP_PATH}"

USER "${APP_USER_NAME}"

WORKDIR "${APP_PATH}"

COPY --chown="${APP_USER_NAME}:${APP_GROUP_NAME}" \
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

COPY --chown="${APP_USER_NAME}:${APP_GROUP_NAME}" ./  "${APP_PATH}/"

RUN ["yarn","run","build"]

FROM preparation as worker

RUN yarn install \
    --non-interactive \
    --production=true \
    --frozen-lockfile \
    --network-timeout 1000000 \
    && yarn cache clean

ENV PATH="${PATH}:${APP_PATH}/node_modules/.bin"

COPY --from=builder --chown="${APP_USER_NAME}:${APP_GROUP_NAME}" "${APP_PATH}/dist/" "${APP_PATH}/dist/"

CMD ["yarn","run","start"]

EXPOSE ${PORT}
