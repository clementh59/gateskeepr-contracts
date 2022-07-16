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

    ## Chucky data
    const NUMBER_OF_CHUCKY = 2
    const CHUCKY_T1_ROOM = ROOM_ALL
    const CHUCKY_T2_ROOM = ROOM_3
end