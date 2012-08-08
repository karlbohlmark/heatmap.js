.PHONY: bucket
version=$(shell cat version)

all: bucket build

bucket:
	coffee dataToJson.coffee | coffee multiBucket.coffee 50 80 250 80 500 80 | coffee dataAsJs.coffee > multibuckets.js

build:
	coffee -c . && porter test.js -o main.js
