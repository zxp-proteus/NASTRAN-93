      SUBROUTINE XRGNUM        
C        
C     XRGNUM PROCESSES THE NUMBER ON A CARD OR FILE NAME TABLE ENTRY    
C     THIS ROUTINE IS CALLED ONLY BY XRGDTB        
C        
C     WRITTEN BY  RPK CORPORATION; DECEMBER, 1983        
C        
C     INPUT        
C       /SYSTEM/        
C         OPTAPE       UNIT NUMBER FOR THE OUTPUT PRINT FILE        
C       /XRGDXX/        
C         ICHAR        CONTAINS THE CARD IMAGE IN 80A1 FORMAT        
C         ICOL         CURRENT COLUMN BEING PROCESSED        
C         RECORD       CONTAINS THE CARD IMAGE IN 20A4 FORMAT        
C        
C     OUTPUT        
C       /XRGDXX/        
C         ICOL         CURRENT COLUMN BEING PROCESSED        
C         NUMBER       VALUE OF THE NUMBER IN INTEGER FORMAT        
C        
C     LOCAL VARIABLES        
C         BLANK          CONTAINS THE VALUE 1H        
C         IFRCOL         FIRST COLUMN TO BE EXAMINED BY XRGNUM        
C         NEWNUM         INTEGER VALUE OF THE CHARACTER IN THE CURRENT  
C                        COLUMN        
C         NUMS           CONTAINS THE ALPHA VALUES 1,2,...0        
C        
C     THE CARD IS SCANED TO FIND THE VALUE OF THE NUMBER IN THE FIRST   
C     FIELD OF THE CARD        
C        
C     MESSAGE 8030 MAY BE ISSUED        
C        
      INTEGER         RECORD, OPTAPE, BLANK , NUMS(10)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /XRGDXX/ IRESTR, NSUBST, IPHASE, ICOL  , NUMBER, ITYPE ,   
     1                ISTATE, IERROR, NUM(2), IND   , NUMENT,        
     2                RECORD(20)    , ICHAR(80)     , LIMIT(2),        
     3                ICOUNT, IDMAP , ISCR  ,NAME(2), MEMBER(2),        
     4                IGNORE        
      COMMON /SYSTEM/ ISYSBF, OPTAPE, DUM(98)        
      DATA    NUMS  / 1H1, 1H2, 1H3, 1H4, 1H5, 1H6, 1H7, 1H8, 1H9, 1H0/ 
      DATA    BLANK / 1H  /        
C        
      IFRCOL = ICOL        
      NUMBER = 0        
 50   IF (ICOL .GE. 80) GO TO 350        
      IF (ICHAR(ICOL) .EQ. BLANK) GO TO 200        
      DO 100 K = 1,10        
      IF (ICHAR(ICOL) .NE. NUMS(K)) GO TO 100        
      NEWNUM = MOD(K,10)        
      NUMBER = NUMBER*10 + NEWNUM        
      GO TO 150        
 100  CONTINUE        
      GO TO 250        
 150  ICOL = ICOL + 1        
      GO TO 50        
 200  ICOL = ICOL + 1        
      IF (NUMBER .EQ. 0) GO TO 50        
      GO TO 350        
 250  NUMBER = 0        
      J = 0        
      K = 1        
      WRITE  (OPTAPE,300) UFM,IFRCOL,RECORD,J,(I,I=1,8),K,(J,I=1,8)     
 300  FORMAT (A23,' 8030, EXPECTED AN INTEGER NEAR COLUMN',I3,        
     1        ' IN THE FOLLOWING CARD', //20X,20A4, /,(20X,I1,I9,7I10)) 
 350  RETURN        
      END        
