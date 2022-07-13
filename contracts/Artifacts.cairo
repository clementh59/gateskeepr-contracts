# SPDX-License-Identifier: MIT
# OpenZeppelin Contracts for Cairo v0.2.0 (token/erc721/ERC721_Mintable_Burnable.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add
)
from starkware.cairo.common.math import (
    assert_nn_le,
    assert_not_zero
)

from openzeppelin.token.erc721.library import ERC721
from openzeppelin.introspection.ERC165 import ERC165

from openzeppelin.access.ownable import Ownable

from contracts.utils.constants import (
    STEP_BEFORE,
    STEP_WHITELIST_SALE,
    STEP_PUBLIC_SALE,
    STEP_SOLD_OUT,
    MAX_MINT_PER_ROW
)

#
# Storage
#

# Minting step
@storage_var
func step_() -> (res : felt):
end

# keep in mind the last token id to auto increment when minting
@storage_var
func lastTokenId_() -> (tokenId : Uint256):
end

@storage_var
func metadataHashState_() -> (hash : felt):
end

@storage_var
func tokenMetadata_(tokenId: Uint256) -> (metadata : felt):
end

#
# Constructor
#

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        name: felt,
        symbol: felt, 
        owner: felt,
        hashState: felt
    ):
    ERC721.initializer(name, symbol)
    Ownable.initializer(owner)
    lastTokenId_.write(value=Uint256(1,0))
    metadataHashState_.write(value=hashState)
    return ()
end

#
# Getters
#

@view
func metadataHashState{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (hash: felt):
    let (hash) = metadataHashState_.read()
    return (hash)
end

@view
func mintingStep{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (step: felt):
    let (step) = step_.read()
    return (step)
end

@view
func supportsInterface{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(interfaceId: felt) -> (success: felt):
    let (success) = ERC165.supports_interface(interfaceId)
    return (success)
end

@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (name: felt):
    let (name) = ERC721.name()
    return (name)
end

@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    let (symbol) = ERC721.symbol()
    return (symbol)
end

@view
func balanceOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt) -> (balance: Uint256):
    let (balance: Uint256) = ERC721.balance_of(owner)
    return (balance)
end

@view
func ownerOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (owner: felt):
    let (owner: felt) = ERC721.owner_of(tokenId)
    return (owner)
end

@view
func getApproved{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (approved: felt):
    let (approved: felt) = ERC721.get_approved(tokenId)
    return (approved)
end

@view
func isApprovedForAll{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, operator: felt) -> (isApproved: felt):
    let (isApproved: felt) = ERC721.is_approved_for_all(owner, operator)
    return (isApproved)
end

@view
func tokenURI{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (tokenURI: felt):
    let (tokenURI: felt) = ERC721.token_uri(tokenId)
    return (tokenURI)
end

@view
func owner{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (owner: felt):
    let (owner: felt) = Ownable.owner()
    return (owner)
end

@view
func nextTokenId{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (tokenId: Uint256):
    let (lastTokenId : Uint256) = lastTokenId_.read()
    let one_as_uint = Uint256(1, 0)
    let (tokenId : Uint256, _) = uint256_add(lastTokenId, one_as_uint)
    return (tokenId)
end

@view
func getItemType{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (res: felt):
    let (metadata) = tokenMetadata_.read(tokenId)
    return (metadata)
end

#
# Externals
#

@external
func setTokensMetadata{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(values_len : felt, values : felt*):
    Ownable.assert_only_owner()
    _setTokensMetadata(values_len, values, 1)
    return ()
end

@external
func setMintingStep{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(step: felt):
    Ownable.assert_only_owner()
    step_.write(value=step)
    return ()
end

@external
func approve{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(to: felt, tokenId: Uint256):
    ERC721.approve(to, tokenId)
    return ()
end

@external
func setApprovalForAll{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(operator: felt, approved: felt):
    ERC721.set_approval_for_all(operator, approved)
    return ()
end

@external
func transferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(
        from_: felt,
        to: felt,
        tokenId: Uint256
    ):
    ERC721.transfer_from(from_, to, tokenId)
    return ()
end

@external
func safeTransferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(
        from_: felt,
        to: felt,
        tokenId: Uint256,
        data_len: felt,
        data: felt*
    ):
    ERC721.safe_transfer_from(from_, to, tokenId, data_len, data)
    return ()
end

@external
func mint{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(to: felt, amount: felt):

    alloc_locals
    
    let (step) = step_.read()

    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    _fill_conditions_in_case_of_STEP_BEFORE(step)
    _fill_conditions_in_case_of_STEP_WHITELIST(step)
    _fill_conditions_in_case_of_STEP_PUBLIC(step)
    _fill_conditions_in_case_of_STEP_SOLD_OUT(step)

    with_attr error_message("amount should be between 1 and MAX_MINT_PER_ROW"):
        assert_nn_le(amount, MAX_MINT_PER_ROW)
        assert_not_zero(amount)
    end
    
    _mint(to, amount)
    return ()
end

@external
func burn{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(tokenId: Uint256):
    ERC721.assert_only_token_owner(tokenId)
    ERC721._burn(tokenId)
    return ()
end

@external
func setTokenURI{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(tokenId: Uint256, tokenURI: felt):
    Ownable.assert_only_owner()
    ERC721._set_token_uri(tokenId, tokenURI)
    return ()
end

@external
func setBaseTokenURI{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    base_token_uri_len : felt, base_token_uri : felt*, token_uri_suffix : felt
):
    Ownable.assert_only_owner()
    #ERC721_Metadata_setBaseTokenURI(base_token_uri_len, base_token_uri, token_uri_suffix)
    return ()
end

@external
func transferOwnership{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(newOwner: felt):
    Ownable.transfer_ownership(newOwner)
    return ()
end

@external
func renounceOwnership{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }():
    Ownable.renounce_ownership()
    return ()
end

#
# Internal functions
#
func _mint{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(to: felt, amount: felt):

    if amount == 0:
        return ()
    end

    let (tokenId : Uint256) = nextTokenId()

    ERC721._mint(to, tokenId)
    lastTokenId_.write(value=tokenId)

    _mint(to, amount - 1)
    return ()
end

func _fill_conditions_in_case_of_STEP_SOLD_OUT(step: felt):
    if step == STEP_SOLD_OUT:
        # todo
    end
    return ()
end

func _fill_conditions_in_case_of_STEP_PUBLIC(step: felt):
    if step == STEP_PUBLIC_SALE:
        # todo
    end
    return ()
end

func _fill_conditions_in_case_of_STEP_WHITELIST{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(step: felt):
    alloc_locals
    if step == STEP_WHITELIST_SALE:
        Ownable.assert_only_owner()
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
        # todo
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end
    return ()
end

func _fill_conditions_in_case_of_STEP_BEFORE{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(step: felt):
    alloc_locals
    if step == STEP_BEFORE:
        Ownable.assert_only_owner()
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end
    return ()
end

func _setTokensMetadata{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(values_len : felt, values : felt*, index: felt):
    
    if values_len == 0:
        return ()
    end

    let tokenId: Uint256 = Uint256(index, 0)
    tokenMetadata_.write(tokenId = tokenId, value=[values])
    _setTokensMetadata(values_len=values_len - 1, values=values + 1, index = index + 1)
    return ()
end