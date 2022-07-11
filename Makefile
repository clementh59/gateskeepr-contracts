build:
	protostar build --cairo-path ./lib/cairo_contracts/src

deploy_proposals:
	protostar deploy ./build/proposals.json --network alpha-goerli

test:
	protostar test ./tests --cairo-path ./lib/cairo_contracts/src

clean:
	rm -rf ./build

.PHONY: build deploy clean