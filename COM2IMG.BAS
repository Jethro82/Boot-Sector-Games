OPEN COMMAND$ + ".COM" FOR RANDOM AS #1 LEN = 256
OPEN COMMAND$ + ".IMG" FOR RANDOM AS #2 LEN = 256
DIM Data1 AS STRING * 256
TYPE Data2
        Contents AS STRING * 254
        Signature AS INTEGER
END TYPE
DIM Data2 AS Data2
GET #1, &H7C, Data1
GET #1, &H7D, Data2
IF LOF(1) > 31998 THEN BEEP: PRINT "Boot code larger than 510 bytes"
Data2.Signature = &HAA55
PUT #2, 1, Data1
PUT #2, 2, Data2
Data1 = ""
PUT #2, 5760, Data1
CLOSE #2

