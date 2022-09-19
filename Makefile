UNIT_TAGS := "$(subst :, or ,$(shell awk '{print $2}' tests/cucumber/unit.tags | paste -s -d: -))"
INTEGRATION_TAGS := "$(subst :, or ,$(shell awk '{print $2}' tests/cucumber/integration.tags | paste -s -d: -))"

unit:
	node_modules/.bin/cucumber-js --tags $(UNIT_TAGS) tests/cucumber/features --require-module ts-node/register --require tests/cucumber/steps/index.js
	
integration:
	node_modules/.bin/cucumber-js --tags $(INTEGRATION_TAGS) tests/cucumber/features --require-module ts-node/register --require tests/cucumber/steps/index.js

# The following assumes that all cucumber steps are defined in `./tests/cucumber/steps/steps.js` and begin past line 135 of that file.
# Please note any deviations of the above before presuming correctness.
display-all-js-steps:
	tail -n +135 tests/cucumber/steps/steps.js | grep -v '^ *//' | awk "/(Given|Then|When)/,/',/" | grep -E "\'.+\'"  | sed "s/^[^']*'\([^']*\)'.*/\1/g"

harness:
	./test-harness.sh

SB_CMD = pause
sb:
	cd test-harness/.sandbox && docker-compose $(SB_CMD)

sb-pause:
	make sb SB_CMD=pause

sb-unpause:
	make sb SB_CMD=unpause

sb-ps:
	make sb SB_CMD=ps

docker-build:
	docker build -t js-sdk-testing -f tests/cucumber/docker/Dockerfile $(CURDIR) --build-arg TEST_BROWSER --build-arg CI=true

docker-run:
	docker ps -a
	docker run -it --network host js-sdk-testing:latest

docker-test: harness docker-build docker-run

format:
	npm run format
