#!/bin/bash

VERSION=$1

docker image build --tag syndicatedb/puppeteer-server:${VERSION} . 
docker tag syndicatedb/puppeteer-server:${VERSION} syndicatedb/puppeteer-server:latest