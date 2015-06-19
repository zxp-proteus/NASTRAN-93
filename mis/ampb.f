      SUBROUTINE AMPB(PHIDH,GTKA,D1JK,D2JK,D1JE,D2JE,USETA,        
     1 DJH1,DJH2,GKI,SCR1,SCR2,SCR3)        
C        
C     THE PURPOSE OF THIS SUBROUTINE IS TO SOLVE FOR THE DJH MATRICES.  
C      IT ALSO COMPUTES GKI FOR LATER USE.        
C      THE STEPS ARE,        
C        
C     1. PHIDH GOES TO   1       1      1        
C                        1 PHIA  1      1        
C                        1 ----- 1 ---- 1        
C                        1       1      1        
C                        1       1      1        
C        
C     2. GKI =GTKA$PHIA        
C        
C     3. DJI1=D1JK*GKI        
C     4. DJI2=D2JK*GKI        
C     5.        
C     6. DJH1= 1 DJI1 1 D1JE 1        
C              1      1      1        
C     7. DJH2= 1 DJI2 1 D2JE 1        
C        
C        
C        
      INTEGER PHIDH,GTKA,D1JK,D2JK,D1JE,D2JE,USETA,DJH1,DJH2,GKI,       
     1 SCR1,SCR2,SCR3,PHIA,DJI1,DJI2,MCB(7),UD,UA,UE        
C        
      COMMON /BLANK/NOUE        
      COMMON /PATX/LC,NS0,NS1,NS2,IUSET        
      COMMON /BITPOS/UM,UO,UR,USG,USB,UL,UA,UF,US,UN,UG,UE,UP,UNE,UFE,UD
     1 ,UPS,USA,UK,UPA        
CZZ   COMMON/ZZAMB2/Z(1)        
      COMMON/ZZZZZZ/Z(1)        
      COMMON/SYSTEM/SYSBUF,NOUT,SKIP(52),IPREC        
      COMMON /AMPCOM/ NCOLJ        
C        
C-----------------------------------------------------------------------
C        
      MCB(1)=PHIDH        
      CALL RDTRL(MCB)        
      NOH=MCB(2)        
C        
C     DETERMINE IF PHIDH MUST BE MODIFIED        
C        
      IF(NOUE.EQ.-1)GO TO 20        
C        
C     BUILD PARTITIONING VECTORS        
C        
      IUSET = USETA        
      LC=KORSZ(Z)        
      CALL CALCV(SCR1,UD,UA,UE,Z)        
      CALL AMPB1(SCR2,NOH-NOUE,NOUE)        
C        
C     PERFORM PARTITION        
C                       RP   CP        
      CALL AMPB2(PHIDH,SCR3,0,0,0,SCR2,SCR1,0,0)        
      PHIA=SCR3        
      GO TO 30        
C        
C     NO MOD REQUIRED        
C        
   20 PHIA=PHIDH        
   30 CONTINUE        
C        
C     COMPUTE GKI        
C        
      CALL SSG2B(GTKA,PHIA,0,GKI,1,IPREC,1,SCR1)        
C        
C     START COMPUTATION OF DJH MATRICES        
C        
      DJI1=SCR3        
      DJI2=SCR3        
      IF(NOUE.GT.0)GO TO 40        
      DJI1=DJH1        
      DJI2=DJH2        
   40 CONTINUE        
      CALL SSG2B(D1JK,GKI,0,DJI1,1,IPREC,1,SCR1)        
      IF(NOUE.EQ.-1)GO TO 50        
      CALL MERGED(DJI1,D1JE,0,0,DJH1,SCR2,0,0,NCOLJ)        
   50 CONTINUE        
      CALL SSG2B(D2JK,GKI,0,DJI2,1,IPREC,1,SCR1)        
      IF(NOUE.EQ.-1)GO TO 60        
      CALL MERGED(DJI2,D2JE,0,0,DJH2,SCR2,0,0,NCOLJ)        
   60 CONTINUE        
      RETURN        
      END        
