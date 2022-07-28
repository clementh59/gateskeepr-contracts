# Gateskeepr contracts

A description of the game is available [here](docs/GameDocumentation.md).

## Install

```shell
git submodule init
git submodule update
```

## Update openzeppelin dependency

```shell
protostar update cairo_contracts
```

## Use utils.py

```shell
python3 -i utils/utils.py
```

```python
>>> str_to_felt('ERC20-101')
1278752977803006783537
```

## Deploying contract

Then, you just need to run this command:
```shell
make deploy_proposal
make deploy_artifacts
```

## Artifacts

In order to init the artifact contract, you'll need to initialize all the metadata
Here is the data model:

- **artifactsType**: `[typeOfTokenId1, typeOfTokenId2, typeOfTokenId3, ...]`
Types are defined in `contracts/utils/ArtifactTypesUtils.cairo`
- **chuckyInfo**: `[tokenId1, roomAssociatedWithTokenId1, tokenId2, roomAssociatedWithTokenId2, ...]`

## VRF

For now, the vrf used when minting is a pseudo random one.
Here is the original repo: https://github.com/milancermak/xoroshiro-cairo

## Test

```shell
make test
```

If you want to run only one test suite:
```shell
make testFile path=unit/test_full_mint_artifacts
```

By default, `unit/test_full_mint_artifacts` is disabled since it is quite long to run, to run it, you'll need to uncomment this line:
```python
#@external
```

In order to make it work, you'll need to update the openzeppelin erc721 lib:
```cairo
func owner_of{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(token_id: Uint256) -> (owner: felt):
    with_attr error_message("ERC721: token_id is not a valid Uint256"):
        uint256_check(token_id)
    end
    let (owner) = ERC721_owners.read(token_id)
    # with_attr error_message("ERC721: owner query for nonexistent token"):
    #     assert_not_zero(owner)
    # end
    return (owner)
end
```