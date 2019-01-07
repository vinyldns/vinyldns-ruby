start-api:
	./scripts/start_api

stop-api:
	./scripts/stop_api

test: start-api
	./scripts/run_tests
