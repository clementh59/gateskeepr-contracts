build:
	protostar build --cairo-path ./lib/cairo_contracts/src

deploy_proposals:
	protostar deploy ./build/proposals.json --network alpha-goerli

test:
	protostar test ./tests --cairo-path ./lib/cairo_contracts/src

testFile:
	protostar test ./tests/${path} --cairo-path ./lib/cairo_contracts/src

test_artifact:
	make testFile path=integration/test_artifacts.cairo

clean:
	rm -rf ./build

.PHONY: build deploy clean