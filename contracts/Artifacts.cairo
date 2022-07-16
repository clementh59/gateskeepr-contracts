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
    assert_not_zero,
    unsigned_div_rem
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

from contracts.utils.ArtifactTypeUtils import (
    buildChuckyFromData,
    buildRoomFromData,
    buildOrbOfOsuvoxFromData,
    buildCataclystFromData,
    buildHackEyeFromData,
    buildCopycatFromData,
    buildFreeProposalsFromData,
    buildGodModeFromData,
    TYPES,
    ChuckyArtifact,
    RoomArtifact,
    OrbArtifact,
    CataclystArtifact,
    HackEyeArtifact,
    CopycatArtifact,
    FreeProposalsArtifact,
    GodModeArtifact
)

from contracts.interfaces.IVRF import IVRF

#
# Storage
#

# Minting step
@storage_var
func step_() -> (res : felt):
end

@storage_var
func vrfAddress_() -> (address : felt):
end

@storage_var
func maxSupply_() -> (address : felt):
end

@storage_var
func availableTokens_(index: felt) -> (tokenId: felt):
end

@storage_var
func numAvailableToken_() -> (num: felt):
end



#### METADATA AND ARTIFACT TYPES

@storage_var
func artifactType_(tokenId: Uint256) -> (type: felt):
end

@storage_var
func chuckyArtifact_(tokenId: Uint256) -> (type: ChuckyArtifact):
end

@storage_var
func roomArtifact_(tokenId: Uint256) -> (type: RoomArtifact):
end

@storage_var
func orbArtifact_(tokenId: Uint256) -> (type: OrbArtifact):
end

@storage_var
func cataclystArtifact_(tokenId: Uint256) -> (type: CataclystArtifact):
end

@storage_var
func hackEyeArtifact_(tokenId: Uint256) -> (type: HackEyeArtifact):
end

@storage_var
func copycatArtifact_(tokenId: Uint256) -> (type: CopycatArtifact):
end

@storage_var
func freeProposalsArtifact_(tokenId: Uint256) -> (type: FreeProposalsArtifact):
end

@storage_var
func godModeArtifact_(tokenId: Uint256) -> (type: GodModeArtifact):
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
        vrfAddress: felt,
        maxSupply: felt,
        artifactsType_len: felt,
        artifactsType: felt*,
        chuckyData_len: felt, chuckyData: felt*,
        roomArtifactData_len: felt, roomArtifactData: felt*,
        orbData_len: felt, orbData: felt*,
        cataclystData_len: felt, cataclystData: felt*,
        hackEyeData_len: felt, hackEyeData: felt*,
        copycatData_len: felt, copycatData: felt*,
        freeProposalsData_len: felt, freeProposalsData: felt*,
        godModeData_len: felt, godModeData: felt*,
    ):
    ERC721.initializer(name, symbol)
    Ownable.initializer(owner)
    vrfAddress_.write(value=vrfAddress)
    _initArtifactsType(artifactsType_len, artifactsType, 1)
    maxSupply_.write(value=maxSupply)
    numAvailableToken_.write(value=maxSupply)
    _initChuckyData(chuckyData_len, chuckyData)
    _initRoomArtifactData(roomArtifactData_len, roomArtifactData)
    _initOrbData(orbData_len, orbData)
    _initCataclystData(cataclystData_len, cataclystData)
    _initHackEyeData(hackEyeData_len, hackEyeData)
    _initCopycatData(copycatData_len, copycatData)
    _initFreeProposalsData(freeProposalsData_len, freeProposalsData)
    _initGodModeData(godModeData_len, godModeData)
    return ()
end

#
# Getters
#

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
func getArtifactType{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (res: felt):
    let (res) = artifactType_.read(tokenId)
    return (res)
end

@view 
func numAvailableTokens{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (num: felt):
    let (res) = numAvailableToken_.read()
    return (res)
end

@view 
func getChuckyArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (chucky: ChuckyArtifact):
    let (res) = chuckyArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getRoomArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (room: RoomArtifact):
    let (res) = roomArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getOrbArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (orb: OrbArtifact):
    let (res) = orbArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getCataclystArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (cataclyst: CataclystArtifact):
    let (res) = cataclystArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getHackEyeArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (hackEye: HackEyeArtifact):
    let (res) = hackEyeArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getCopycatArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (copycat: CopycatArtifact):
    let (res) = copycatArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getFreeProposalArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (freeProposals: FreeProposalsArtifact):
    let (res) = freeProposalsArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getGodModeArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (godMode: GodModeArtifact):
    let (res) = godModeArtifact_.read(tokenId=tokenId)
    return (res)
end

#
# Externals
#

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
    alloc_locals

    if amount == 0:
        return ()
    end

    let (vrfAddress) = vrfAddress_.read()
    let (random) = IVRF.generateVRF(contract_address=vrfAddress)
    let (numAvailableToken) = numAvailableToken_.read()
    let (_, remainder) = unsigned_div_rem(random, numAvailableToken)

    let (tokenIdFelt) = _getAvailableTokenAtIndex(remainder, numAvailableToken)
    # we do remainder + 1 because the first tokenId is 1 and not 0
    let tokenId: Uint256 = Uint256(tokenIdFelt + 1, 0)
    ERC721._mint(to, tokenId)

    numAvailableToken_.write(value=numAvailableToken-1)

    _mint(to, amount - 1)
    return ()
end

# Implements https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle.
func _getAvailableTokenAtIndex{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(indexToUse: felt, numAvailable: felt) -> (tokenId: felt):
    alloc_locals

    let (valAtIndex) = availableTokens_.read(index=indexToUse)
    let lastIndex = numAvailable - 1

    if indexToUse != lastIndex:
        let (lastValInArray) = availableTokens_.read(index=lastIndex)
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
        if lastValInArray == 0:
            # This means the index itself is still an available token
            availableTokens_.write(index=indexToUse, value=lastIndex)
        else:
            # This means the index itself is not an available token, but the val at that index is.
            availableTokens_.write(index=indexToUse, value=lastValInArray)
        end
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    if valAtIndex == 0:
        # This means the index itself is still an available token
        return (indexToUse)
    end

    return (valAtIndex)
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

func _initArtifactsType{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(artifactsType_len: felt, artifactsType: felt*, index: felt):
    
    if artifactsType_len == 0:
        return ()
    end

    let tokenId: Uint256 = Uint256(index, 0)
    artifactType_.write(tokenId = tokenId, value=[artifactsType])
    _initArtifactsType(artifactsType_len=artifactsType_len - 1, artifactsType=artifactsType + 1, index = index + 1)
    return ()
end

func _initChuckyData{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(chuckyData_len: felt, chuckyData: felt*):
    if chuckyData_len == 0:
        return ()
    end

    let tokenId: Uint256 = Uint256([chuckyData], 0)
    let (value) = buildChuckyFromData([chuckyData + 1])
    chuckyArtifact_.write(tokenId=tokenId, value=value)

    _initChuckyData(chuckyData_len=chuckyData_len - 2, chuckyData=chuckyData + 2)
    return ()
end

func _initRoomArtifactData{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(array_len: felt, array: felt*):
    if array_len == 0:
        return ()
    end

    let tokenId: Uint256 = Uint256([array], 0)
    let (value) = buildRoomFromData([array + 1], [array + 2])
    roomArtifact_.write(tokenId=tokenId, value=value)

    _initRoomArtifactData(array_len=array_len - 3, array=array + 3)
    return ()
end

func _initOrbData{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(array_len: felt, array: felt*):
    if array_len == 0:
        return ()
    end

    let tokenId: Uint256 = Uint256([array], 0)
    let (value) = buildOrbOfOsuvoxFromData([array + 1], [array + 2])
    orbArtifact_.write(tokenId=tokenId, value=value)

    _initOrbData(array_len=array_len - 3, array=array + 3)
    return ()
end

func _initCataclystData{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(array_len: felt, array: felt*):
    if array_len == 0:
        return ()
    end

    let tokenId: Uint256 = Uint256([array], 0)
    let (value) = buildCataclystFromData([array + 1])
    cataclystArtifact_.write(tokenId=tokenId, value=value)

    _initCataclystData(array_len=array_len - 2, array=array + 2)
    return ()
end

func _initHackEyeData{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(array_len: felt, array: felt*):
    if array_len == 0:
        return ()
    end

    let tokenId: Uint256 = Uint256([array], 0)
    let (value) = buildHackEyeFromData([array + 1])
    hackEyeArtifact_.write(tokenId=tokenId, value=value)

    _initHackEyeData(array_len=array_len - 2, array=array + 2)
    return ()
end

func _initCopycatData{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(array_len: felt, array: felt*):
    if array_len == 0:
        return ()
    end

    let tokenId: Uint256 = Uint256([array], 0)
    let (value) = buildCopycatFromData([array + 1], [array + 2])
    copycatArtifact_.write(tokenId=tokenId, value=value)

    _initCopycatData(array_len=array_len - 3, array=array + 3)
    return ()
end

func _initFreeProposalsData{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(array_len: felt, array: felt*):
    if array_len == 0:
        return ()
    end

    let tokenId: Uint256 = Uint256([array], 0)
    let (value) = buildFreeProposalsFromData([array + 1], [array + 2])
    freeProposalsArtifact_.write(tokenId=tokenId, value=value)

    _initFreeProposalsData(array_len=array_len - 3, array=array + 3)
    return ()
end

func _initGodModeData{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(array_len: felt, array: felt*):
    if array_len == 0:
        return ()
    end

    let tokenId: Uint256 = Uint256([array], 0)
    let (value) = buildGodModeFromData([array + 1])
    godModeArtifact_.write(tokenId=tokenId, value=value)

    _initGodModeData(array_len=array_len - 2, array=array + 2)
    return ()
end