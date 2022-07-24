# SPDX-License-Identifier: MIT
# OpenZeppelin Contracts for Cairo v0.2.0 (token/erc721/ERC721_Mintable_Burnable.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.alloc import alloc
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
from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable
from openzeppelin.introspection.ERC165.library import ERC165
from contracts.utils.ShortString import uint256_to_ss
from contracts.utils.Array import concat_arr

from openzeppelin.access.ownable.library import Ownable

from contracts.utils.constants import (
    STEP_BEFORE,
    STEP_WHITELIST_SALE,
    STEP_PUBLIC_SALE,
    STEP_SOLD_OUT,
    MAX_MINT_PER_ROW,
    STR_UNDERSCORE
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
    GodModeArtifact,
    getStrFromNumber,
    buildUriInfoFromParam,
    buildUriInfoFrom2Params,
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

# token uri
@storage_var
func ERC721_base_token_uri(index : felt) -> (res : felt):
end

@storage_var
func ERC721_base_token_uri_len() -> (res : felt):
end

@storage_var
func ERC721_base_token_uri_suffix() -> (res : felt):
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

@storage_var
func erc20TokenAddress_() -> (address: felt):
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
        erc20TokenAddress: felt,
        baseUri_len: felt, baseUri: felt*, 
        uriSuffix: felt,
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
    ERC721Enumerable.initializer()
    Ownable.initializer(owner)
    vrfAddress_.write(value=vrfAddress)
    erc20TokenAddress_.write(value=erc20TokenAddress)
    _initArtifactsType(artifactsType_len, artifactsType, 1)
    maxSupply_.write(value=maxSupply)
    numAvailableToken_.write(value=maxSupply)
    _setBaseTokenURI(baseUri_len, baseUri, uriSuffix)
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
func totalSupply{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }() -> (totalSupply: Uint256):
    let (totalSupply: Uint256) = ERC721Enumerable.total_supply()
    return (totalSupply)
end

@view
func tokenByIndex{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(index: Uint256) -> (tokenId: Uint256):
    let (tokenId: Uint256) = ERC721Enumerable.token_by_index(index)
    return (tokenId)
end

@view
func tokenOfOwnerByIndex{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(owner: felt, index: Uint256) -> (tokenId: Uint256):
    let (tokenId: Uint256) = ERC721Enumerable.token_of_owner_by_index(owner, index)
    return (tokenId)
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
    }(tokenId: Uint256) -> (token_uri_len: felt, token_uri: felt*):
    alloc_locals

    let (exists) = ERC721._exists(tokenId)
    assert exists = 1

    let (local base_token_uri) = alloc()
    let (local base_token_uri_len) = ERC721_base_token_uri_len.read()

    _baseTokenURI(base_token_uri_len, base_token_uri)

    let (artifactUri) = buildUriInfoFromArtifact(tokenId)

    assert base_token_uri[base_token_uri_len] = artifactUri
    let base_token_uri_len = base_token_uri_len + 1

    let (ERC721_base_token_uri_suffix_local) = ERC721_base_token_uri_suffix.read()
    let (local suffix) = alloc()
    [suffix] = ERC721_base_token_uri_suffix_local
    let (token_uri, token_uri_len) = concat_arr(base_token_uri_len, base_token_uri, 1, suffix)

    return (token_uri_len=token_uri_len, token_uri=token_uri)
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
    assert_type_is(tokenId, TYPES.CHUCKY)
    let (res) = chuckyArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getRoomArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (room: RoomArtifact):
    assert_type_is(tokenId, TYPES.ROOM)
    let (res) = roomArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getOrbArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (orb: OrbArtifact):
    assert_type_is(tokenId, TYPES.ORB_OF_OSUVOX)
    let (res) = orbArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getCataclystArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (cataclyst: CataclystArtifact):
    assert_type_is(tokenId, TYPES.CATACLYST)
    let (res) = cataclystArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getHackEyeArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (hackEye: HackEyeArtifact):
    assert_type_is(tokenId, TYPES.HACK_EYE)
    let (res) = hackEyeArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getCopycatArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (copycat: CopycatArtifact):
    assert_type_is(tokenId, TYPES.COPYCAT)
    let (res) = copycatArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getFreeProposalArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (freeProposals: FreeProposalsArtifact):
    assert_type_is(tokenId, TYPES.FREE_PROPOSALS)
    let (res) = freeProposalsArtifact_.read(tokenId=tokenId)
    return (res)
end

@view 
func getGodModeArtifact{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (godMode: GodModeArtifact):
    assert_type_is(tokenId, TYPES.GOD_MODE)
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
    ERC721Enumerable.transfer_from(from_, to, tokenId)
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
    ERC721Enumerable.safe_transfer_from(from_, to, tokenId, data_len, data)
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
    ERC721Enumerable._burn(tokenId)
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

@external
func consumeFPArtifact{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256):
    alloc_locals
    let (fp_) = getFreeProposalArtifact(tokenId)

    if fp_.number == 1:
        burn(tokenId) 
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    let (newFP) = buildFreeProposalsFromData(fp_.room_number, fp_.number - 1)
    freeProposalsArtifact_.write(tokenId=tokenId, value=newFP)
    
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
    ERC721Enumerable._mint(to, tokenId)

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

###### TOKEN URI INTERNALS

func _baseTokenURI{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(base_token_uri_len : felt, base_token_uri : felt*):
    if base_token_uri_len == 0:
        return ()
    end
    let (base) = ERC721_base_token_uri.read(base_token_uri_len)
    assert [base_token_uri] = base
    _baseTokenURI(
        base_token_uri_len=base_token_uri_len - 1, base_token_uri=base_token_uri + 1
    )
    return ()
end

func _setBaseTokenURI{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(token_uri_len : felt, token_uri : felt*, token_uri_suffix : felt):
    _ERC721_Metadata_setBaseTokenURI(token_uri_len, token_uri)
    ERC721_base_token_uri_len.write(token_uri_len)
    ERC721_base_token_uri_suffix.write(token_uri_suffix)
    return ()
end

func _ERC721_Metadata_setBaseTokenURI{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(token_uri_len : felt, token_uri : felt*):
    if token_uri_len == 0:
        return ()
    end
    ERC721_base_token_uri.write(index=token_uri_len, value=[token_uri])
    _ERC721_Metadata_setBaseTokenURI(token_uri_len=token_uri_len - 1, token_uri=token_uri + 1)
    return ()
end

func buildUriInfoFromArtifact{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(tokenId: Uint256) -> (uri: felt):
    alloc_locals
    let (type) = getArtifactType(tokenId)
    
    if type == TYPES.ORB_OF_OSUVOX:
        let (orb) = getOrbArtifact(tokenId)
        let (res) = buildUriInfoFrom2Params(TYPES.STR_ORB_OF_OSUVOX, orb.room_number, orb.rarity)
        return (res)
    end

    if type == TYPES.ROOM:
        let (room) = getRoomArtifact(tokenId)
        let (res) = buildUriInfoFrom2Params(TYPES.STR_ROOM, room.room_number, room.rarity)
        return (res)
    end

    if type == TYPES.CATACLYST:
        let (cataclyst) = getCataclystArtifact(tokenId)
        let (res) = buildUriInfoFromParam(TYPES.STR_CATACLYST, cataclyst.room_number)
        return (res)
    end

    if type == TYPES.CHUCKY:
        let (chucky) = getChuckyArtifact(tokenId)
        let (res) = buildUriInfoFromParam(TYPES.STR_CHUCKY, chucky.room_number)
        return (res)
    end

    if type == TYPES.HACK_EYE:
        let (he) = getHackEyeArtifact(tokenId)
        let (res) = buildUriInfoFromParam(TYPES.STR_HACK_EYE, he.room_number)
        return (res)
    end

    if type == TYPES.COPYCAT:
        let (copycat) = getCopycatArtifact(tokenId)
        let (res) = buildUriInfoFrom2Params(TYPES.STR_COPYCAT, copycat.rarity, copycat.knowRoom)
        return (res)
    end

    if type == TYPES.FREE_PROPOSALS:
        let (fp_) = getFreeProposalArtifact(tokenId)
        let (res) = buildUriInfoFrom2Params(TYPES.STR_FREE_PROPOSALS, fp_.room_number, fp_.number)
        return (res)
    end

    if type == TYPES.GOD_MODE:
        let (gm) = getGodModeArtifact(tokenId)
        let (res) = buildUriInfoFromParam(TYPES.STR_GOD_MODE, gm.room_number)
        return (res)
    end

    return (0)
end

#
# Custom asserts
#

func assert_type_is{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256, type: felt):
    let (type_) = artifactType_.read(tokenId)
    with_attr error_message("The tokenId doesn't corresponds to this type of artifact"):
        assert type_ = type
    end
    return ()
end