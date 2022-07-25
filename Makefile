build:
	protostar build --cairo-path ./lib/cairo_contracts/src

deploy_vrf:
	protostar deploy ./build/vrf.json --network alpha-goerli -i 0x233f9e9aff81a8edf20a0a8d97600f3b2c4

# ARTIFACT_NAME - ARTIFACT_SYMBOL - ADMIN - VRF_ADDR - MAX_SUPPLY - erc20ADDR
# BASE URI LEN - BASE URI - SUFFIX
# NUM METADATA
# TYPES
deploy_artifacts:
	protostar deploy ./build/artifacts.json --network alpha-goerli --i 1204970811966366110803 1095914566 0x47E9F6CA38cf10E85E04c5129D11aFBdE5AcC7437285E5212Fbf288bE3FEcf 0x2aac94d1726880bfa8bf3cde38844772a8b2a7d4b3fa5543abc94f512d4267f 17 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7 3 184555836509371486644298270517380613565396767415278678887948391494588524912 181013377130034395323720486686928921175651501487220877225392962331537655362 2595708412864275896982673928188083756432250159 199354445678 17 8 9 0 8 9 99 2 99 0 1 3 4 6 7 4 6 7 4 1 13 4 3 6 6 1 1 8 8 2 6 3 4 1 9 2 1 2 10 1 2 11 3 6 12 1 1 15 13 0 6 13 2 4 16 13 42 4 14 2 17 13

# artifactAddr - erc20Addr
deploy_proposals:
	protostar deploy ./build/proposals.json --network alpha-goerli -i 0x010c1b41edfc3d78ec4dc469580bc9c03bf07b900e50b25bbddb279ac58924e8 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7

test:
	protostar test ./tests --cairo-path ./lib/cairo_contracts/src

testFile:
	protostar test ./tests/${path} --cairo-path ./lib/cairo_contracts/src --stdout-on-success

test_artifact:
	make testFile path=integration/test_artifacts.cairo

test_proposals:
	make testFile path=integration/test_proposals.cairo

clean:
	rm -rf ./build

.PHONY: build deploy clean