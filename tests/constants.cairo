from contracts.utils.constants import (
    ROOM_1,
    ROOM_2,
    ROOM_3,
    ROOM_4,
    ROOM_5,
    ROOM_6,
    ROOM_7,
    ROOM_8,
    ROOM_9,
    ROOM_10,
    ROOM_11,
    ROOM_12,
    ROOM_ALL,
)

from contracts.utils.ArtifactTypeUtils import TYPES

const CALLER_ADDRESS = 0x123
const ADMIN = 0x27
const ARTIFACTS_SYMBOL = 1095914566
const ARTIFACTS_NAME = 1204970811966366110803

namespace TD:
    # NUM token def
    const NUM_METADATA_DEF = 5

    const T1_TYPE = TYPES.CHUCKY
    const CHUCKY_T1 = 1

    const T2_TYPE = TYPES.HAPPY_HOUR
    const HAPPY_HOUR_T1 = 2
    
    const T3_TYPE = TYPES.ORB_OF_OSUVOX
    const ORB_T1 = 3
    
    const T4_TYPE = TYPES.CHUCKY
    const CHUCKY_T2 = 4

    const T5_TYPE = TYPES.HAPPY_HOUR
    const HAPPY_HOUR_T2 = 5

    const T6_TYPE = TYPES.ROOM
    const ROOM_ARTIFACT_T1 = 6

    const T7_TYPE = TYPES.EXTRA_PASS

    const T8_TYPE = TYPES.ROOM
    const ROOM_ARTIFACT_T2 = 8

    const T9_TYPE = TYPES.ORB_OF_OSUVOX
    const ORB_T2 = 9

    const T10_TYPE = TYPES.CATACLYST
    const CATACLYST_T1 = 10

    const T11_TYPE = TYPES.HACK_EYE
    const HACK_EYE_T1 = 11

    const T12_TYPE = TYPES.COPYCAT
    const COPYCAT_T1 = 12

    const T13_TYPE = TYPES.FREE_PROPOSALS
    const FP_T1 = 13

    const T14_TYPE = TYPES.GOD_MODE
    const GODMODE_T1 = 14
    
    const T15_TYPE = TYPES.COPYCAT
    const COPYCAT_T2 = 15

    const T16_TYPE = TYPES.FREE_PROPOSALS
    const FP_T2 = 16

    const T17_TYPE = TYPES.GOD_MODE
    const GODMODE_T2 = 17

    ## Chucky data
    const NUMBER_OF_CHUCKY = 2
    const CHUCKY_T1_ROOM = ROOM_ALL
    const CHUCKY_T2_ROOM = ROOM_3

    ## Room artifact
    const NUMBER_OF_ROOM_ARTIFACT = 2
    const ROOM_T1_ROOM = ROOM_1
    const ROOM_T1_RARITY = 1
    const ROOM_T2_ROOM = ROOM_8
    const ROOM_T2_RARITY = 2

    # Orb
    const NUMBER_OF_ORB_ARTIFACT = 2
    const ORB_T1_ROOM = ROOM_4
    const ORB_T1_RARITY = 1
    const ORB_T2_ROOM = ROOM_2
    const ORB_T2_RARITY = 1

    # Cataclyst
    const NUMBER_OF_CATACLYST_ARTIFACT = 1
    const CATACLYST_T1_ROOM = ROOM_1

    # Hack eye
    const NUMBER_OF_HACK_EYE_ARTIFACT = 1
    const HACK_EYE_T1_ROOM = ROOM_3

    # Copycat
    const NUMBER_OF_COPYCAT_ARTIFACT = 2
    const COPYCAT_T1_RARITY = ROOM_1
    const COPYCAT_T1_KNOWN_ROOM = 1
    const COPYCAT_T2_RARITY = ROOM_ALL
    const COPYCAT_T2_KNOWN_ROOM = 0

    # Free proposals
    const NUMBER_OF_FP_ARTIFACT = 2
    const FP_T1_ROOM = ROOM_2
    const FP_T1_NUMBER = 10
    const FP_T2_ROOM = ROOM_ALL
    const FP_T2_NUMBER = 42

    # God mode
    const NUMBER_OF_GODMODE_ARTIFACT = 2
    const GODMODE_T1_ROOM = ROOM_2
    const GODMODE_T2_ROOM = ROOM_ALL

end