#!/bin/bash

# docker run -e PORT=3001 --name puppeteer-server syndicatedb/puppeteer-server:14.1.1
docker run -e PORT=3001 -p 3001:3001 -d syndicatedb/puppeteer-server:14.1.1