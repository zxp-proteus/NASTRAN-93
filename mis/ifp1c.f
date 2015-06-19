      SUBROUTINE IFP1C (I81,NZ)        
C        
      LOGICAL         BIT64        
      INTEGER         CORE(1),COREY(401),SCR1,THRU,OTPE,EXCE,BLANK,     
     1                NIFP1C(2)        
      COMMON /SYSTEM/ SYSBUF,OTPE,NOGO,INTP,MPCN,SPCN,METHOD,LOADNN,    
     1                NLPP,STFTEM,IPAGE,LINE,TLINE,MAXLIN,DATE(3),TIM,  
     2                IECHO,SPLOTS,SKIP(65),INTRA        
      COMMON /IFP1A / SCR1,CASECC,IS,NWPC,NCPW4,NMODES,ICC,NSET,NSYM,   
     1                ZZZZBB,ISTR,ISUB,LENCC,IBEN,EQUAL,IEOR        
      COMMON /XIFP1 / BLANK,BIT64        
CZZ   COMMON /ZZIFP1/ COREX(1)        
      COMMON /ZZZZZZ/ COREX(1)        
      EQUIVALENCE     (COREX(1),COREY(1)), (CORE(1),COREY(401))        
      DATA   THRU   / 4HTHRU/,EXCE / 4HEXCE/        
      DATA   NIFP1C / 4H IFP,4H1C  /        
C        
      I81O = I81        
      CORE(I81+2) = ISUB        
      IF (CORE(I81+3) .NE. -1) GO TO 260        
      CORE(I81) = CORE(I81+4)        
      ILSET = I81 + 1        
      CORE(ILSET) = 0        
C        
C     FIND BEGINNING OF SET LIST        
C        
      I81 = I81 + 5        
      IF (CORE(I81) .EQ. IEOR) GO TO 270        
      IREAL = 0        
      IF (CORE(I81) .GT.    1) GO TO 200        
      I81 = I81 + 3        
      IF (CORE(I81) .EQ. IEOR) GO TO 270        
      IPUT  = ILSET + 2        
   20 ITHRU = 0        
      IEXCPT= 0        
   30 ASSIGN 20 TO IRET        
      IF (CORE(I81)) 40,60,80        
   40 ITHRU  = 0        
      IEXCPT = 0        
   50 IF (IABS(CORE(I81)) .NE. 1) IREAL = 1        
      CORE(IPUT) = CORE(I81+1)        
      IBK1 = IABS(CORE(I81+1))        
      I81  = I81  + 2        
      IPUT = IPUT + 1        
      CORE(ILSET) = CORE(ILSET) + 1        
      GO TO 30        
C        
C     CONTINUATION CARD        
C        
C ... ALLOW ON-LINE READ IF INTRA IS .GT. ZERO, SET BY ONLINS        
C        
   60 IF (INTRA .LE. 0) GO TO 65        
      CALL XREAD (*240,CORE(1))        
      ICC = ICC + 1        
      GO TO 67        
   65 CALL READ (*240,*240,SCR1,CORE(1),NWPC,0,FLAG)        
      WRITE (OTPE,250) ICC,(CORE(I),I=1,NWPC)        
      ICC  = ICC  + 1        
      LINE = LINE + 1        
      IF (LINE .GE. NLPP) CALL PAGE        
   67 I81 = IPUT        
      NZ  = NZ - CORE(ILSET)        
      CALL XRCARD (CORE(I81),NZ,CORE(1))        
      GO TO IRET, (20,120)        
C        
C     END OF RECORD        
C        
   70 I81 = IPUT        
      IF (CORE(ILSET)-1) 200,230,71        
   71 CONTINUE        
      IF (IREAL .EQ. 1) GO TO 230        
C        
C     SORT LIST        
C        
      ISET = CORE(ILSET)        
      CALL IFP1S (CORE(ILSET+2),CORE(I81),CORE(ILSET))        
C        
C     CORRECT FOR DELETIONS        
C        
      I81 = I81 + CORE(ILSET) - ISET        
      GO TO 230        
C        
C     THRU AND EXCEPT        
C        
   80 IF (CORE(I81) .EQ. IEOR) GO TO 70        
      IF (IREAL .EQ. 1) CALL IFP1D(-622)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,CORE(I81+1),0)        
      IF (CORE(I81+1)  .NE. THRU) GO TO 90        
      IF (CORE(ILSET)  .EQ. 0) GO TO 200        
      IF (CORE(IPUT-1) .LT. 0) GO TO 280        
      I81 = I81 +3        
      IF (CORE(I81) .EQ. IEOR) GO TO 270        
      IBK  = IBK1        
      IFWD = CORE(I81+1)        
      IFWD1= IFWD        
      IF (IBK .GE. IFWD) GO TO 200        
      ITHRU = 1        
C     TEST FOR DEGENERATE THRU INTERVAL        
      IF (IFWD-IBK.EQ.1) GO TO 50        
      CORE(I81+1) = -CORE(I81+1)        
      GO TO 50        
C        
C     EXCEPT        
C        
   90 IF (CORE(I81+1) .NE. EXCE) GO TO 200        
      IF (ITHRU .EQ. 1) GO TO 110        
C        
C     EXCEPT WITHOUT THRU        
C        
      CALL IFP1D (-613)        
      GO TO 220        
C        
C     PROCESS EXCEPT CANDIDATES        
C        
  110 I81 = I81 + 3        
      IF (CORE(I81) .EQ. IEOR) GO TO 270        
      IF (IEXCPT .EQ. 1) GO TO 280        
      IEXCPT = 1        
      JEXCPT = 0        
  120 ASSIGN 120 TO IRET        
      IF (CORE(I81)) 130,60,80        
  130 IF (CORE(I81+1) .GT. IFWD1) GO TO 20        
      IF (CORE(I81+1) .LT.   IBK) GO TO 200        
      IF (CORE(I81+1).LE.CORE(I81-1) .AND. JEXCPT.EQ.1 .AND.        
     1   (CORE(I81+2).LE.0 .OR. CORE(I81+2).EQ.IEOR)) GO TO 160        
      JEXCPT = 1        
      IF (CORE(I81+1) .EQ.   IBK) GO TO 290        
      IF (CORE(I81+1) .EQ.  IFWD) GO TO 300        
      IF (CORE(I81+1) .EQ. IFWD1) GO TO 310        
      IF (CORE(I81+1)-1 .EQ. IBK) GO TO 140        
      IF (CORE(I81+1)+1 .EQ.IFWD) GO TO 180        
C     EXCEPT IN MIDDLE OF INTERVAL        
      CORE(IPUT-1) = -CORE(I81+1) + 1        
      IACIP = IABS(CORE(IPUT-1))        
      IF (IACIP-IBK.EQ.1) CORE(IPUT-1) = IACIP        
      CORE(IPUT  ) = CORE(I81+1)+1        
      CORE(IPUT+1) = -IFWD        
      IF (IFWD-CORE(IPUT).EQ.1) CORE(IPUT+1) = IFWD        
      IBK = CORE(IPUT)        
      I81 = I81  + 2        
      IPUT= IPUT + 2        
      CORE(ILSET) = CORE(ILSET) + 2        
      GO TO 120        
C     EXCEPT ADJACENT TO BOTTOM OF INTERVAL        
  140 IL1 = CORE(IPUT-1)        
      IBK = IBK + 2        
      CORE(IPUT-1) = IBK        
      IAL1 = IABS(IL1)        
      IF (IAL1-IBK.EQ.1) IL1 = IAL1        
      CORE(IPUT) = IL1        
      IF (IBK .NE. IAL1) GO TO 150        
      IBK  = 0        
      IFWD = 0        
      I81  = I81 + 2        
      GO TO 120        
  150 IPUT = IPUT + 1        
      I81  = I81  + 2        
      CORE(ILSET) = CORE(ILSET) + 1        
      GO TO 120        
  160 CALL IFP1D (-626)        
      I81 = I81 + 2        
      GO TO 120        
C     EXCEPT ADJACENT TO TOP OF INTERVAL        
  180 CORE(IPUT) = IABS(CORE(IPUT-1))        
      IFWD = IFWD - 2        
      CORE(IPUT-1) = -IFWD        
      IF (IFWD-IBK .EQ. 1) CORE(IPUT-1) = IFWD        
      GO TO 150        
C        
C     FOULED UP SET        
C        
  200 CALL IFP1D (-614)        
  220 I81  = I81O        
      NSET = NSET - 1        
  230 RETURN        
  240 CALL MESAGE (-1,SCR1,NIFP1C)        
      GO TO 240        
  250 FORMAT (11X,I8,6X,20A4)        
C        
C     NO NAME FOR SET        
C        
  260 CALL IFP1D (-615)        
      GO TO 220        
C        
C     UNEXPECTED END OF RECORD        
C        
  270 CALL IFP1D (-623)        
      GO TO 220        
C        
C     EXCEPT FOLLOWED BY THRU        
C        
  280 CALL IFP1D (-616)        
      GO TO 220        
C        
C     EXCEPTING BEGINNING OF INTERVAL        
C        
  290 IBK = IBK + 1        
      CORE(IPUT-2) = IBK        
      I81 = I81 + 2        
      IF (IFWD-IBK .EQ. 1) CORE(IPUT-1) = IFWD        
      IF (IBK .NE. IFWD) GO TO 120        
      IPUT = IPUT - 1        
      CORE(ILSET) = CORE(ILSET) - 1        
      IBK  = 0        
      IFWD = 0        
      GO TO 120        
C        
C     EXCEPT END OF INTERVAL        
C        
  300 IFWD = IFWD - 1        
      CORE(IPUT-1) = -IFWD        
      I81 = I81 + 2        
      IF (IFWD-IBK .EQ. 1) CORE(IPUT-1) = IFWD        
      IF (IBK .NE. IFWD) GO TO 20        
      IPUT = IPUT - 1        
      CORE(ILSET) = CORE(ILSET) - 1        
      GO TO 20        
C        
C     EXCEPT PAST OLD END OF INTERVAL        
C        
  310 I81  = I81 + 2        
      IPUT = IPUT- 1        
      CORE(ILSET) = CORE(ILSET) - 1        
      GO TO 20        
      END        
