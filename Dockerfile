FROM node:lts as builder

RUN apt-get update \
    && apt-get install -y wget --no-install-recommends \
    && apt-get install -y chromium fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r pptruser \
    && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && mkdir -p /home/pptruser/app/dist/ \
    && chown -R pptruser:pptruser /home/pptruser
USER pptruser

WORKDIR /home/pptruser/app/

COPY --chown=pptruser:pptruser \
[ \
    "tsconfig.json", \
    "package.json", \
    "yarn.lock", \
    "/home/pptruser/app/" \
]

RUN yarn install --network-timeout 1000000 \
 && yarn cache clean
ENV PATH=$PATH:/home/pptruser/app/node_modules/.bin

COPY --chown=pptruser:pptruser ./src ./src
RUN yarn run build

FROM builder as worker

WORKDIR /home/pptruser/app/
COPY --chown=pptruser:pptruser \
[ \
    "tsconfig.json", \
    "package.json", \
    "yarn.lock", \
    "/home/pptruser/app/" \
]

RUN yarn install --production=true --network-timeout 1000000 \
    && yarn cache clean

COPY --from=builder --chown=pptruser:pptruser /home/pptruser/app/dist/ /home/pptruser/app/dist/

ENV PATH=$PATH:/home/pptruser/app/node_modules/.bin

CMD ["yarn","run","start"]
