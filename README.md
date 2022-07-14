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