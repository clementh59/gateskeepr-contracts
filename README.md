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

First, you'll need to generate the hash of your metadata file. This is in order to prove that you didn't change the metadata file after the mint, since there is a reveal of the NFTs once every items have been minted.

Here is an example of metadata file:
```json
{"chucky":[17,27,40,55],"cataclyst":[1,30,41,100,832,1234]}
```

And here is its corresponding hash: `f0f6e222375d6102530b05fb03d1974d3f4fbcebfa55191965b48405e85708d3`

Then, you just need to run this command:
```shell
make deploy_proposal
make deploy_artifacts
```

Once the contracts are deployed, and the mint is finished, you'll need to register, in the contract, the token metadata.