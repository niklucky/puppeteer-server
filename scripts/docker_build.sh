#!/bin/bash

VERSION=$1

docker image build  --platform linux/amd64 --tag syndicatedb/puppeteer-server:${VERSION} . 
docker tag syndicatedb/puppeteer-server:${VERSION} syndicatedb/puppeteer-server:latest