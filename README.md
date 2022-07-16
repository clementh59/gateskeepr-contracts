# Gateskeepr contracts

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