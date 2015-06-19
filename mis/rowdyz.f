      SUBROUTINE ROWDYZ (NFB,NLB,ROW,NTZYS,D,DX,DY,DZ,BETA,IDZDY,NTAPE, 
     1                   SGR,CGR,IPRNT,YB,ZB,AR,NSBE,XIS1,XIS2,A0)      
C        
C     CALCULATE A ROW OF DZ OR DY        
C        
C     SLENDER BODY        
C        
C     NFB       FIRST BODY OF THE DESIRED ORIENTATION - Z OR Y -        
C     NLB       LAST  BODY OF THE DESIRED ORIENTATION        
C     ROW       ROW OF DZ OR DY BEING CALCULATED        
C     NTZYS     NO. COLUMNS TO BE CALCULATED        
C     D         CALCULATED ROW        
C     DX        X - COORD. OF RECEIVING POINT        
C     DY        Y - COORD. OF RECEIVING POINT        
C     DZ        Z - COORD. OF RECEIVING POINT        
C     BETA      EQUALS SQRT(1-M**2)        
C     MACH      MACH NO., M        
C     IDZDY     FLAG REQUIRED FOR FLLD        
C        
      INTEGER         B1,T1,B,T,ROW        
      REAL            KR        
      DIMENSION       AR(1),NSBE(1),XIS1(1),XIS2(1),A0(1),YB(1),ZB(1)   
      DIMENSION       D(2,NTZYS)        
      COMMON /AMGMN / MCB(7),NROW,ND,NE,REFC,FMACH,KR        
      COMMON /SYSTEM/ N,NPOT        
C        
      DELTA  = FLOAT(ND)        
      EPSLON = FLOAT(NE)        
      B1     =  0        
      T1     =  0        
      IT1    = 0        
      IF (NFB.EQ.1 .OR. IDZDY.EQ.0) GO TO 10        
      B   = NFB - 1        
      DO 5 T = 1,B        
      IT1 = IT1 + NSBE(T)        
    5 CONTINUE        
   10 CONTINUE        
      DO 200 B = NFB,NLB        
      B1    = B1 + 1        
      DAR   = AR(B)        
      NSBEB = NSBE(B)        
      IF (IPRNT .NE. 0) WRITE (NPOT,15) B,DY,YB(B),DZ,ZB(B)        
   15 FORMAT (12H ROWDYZ  B =,I10,4E20.8)        
C        
C     LOOP FOR EACH ELEMENT IN BODY -B-        
C        
      DO 140 T = 1,NSBEB        
      T1  = T1  + 1        
      IT1 = IT1 + 1        
      D(1,T1) = 0.0        
      D(2,T1) = 0.0        
      XI1  = XIS1(IT1)        
      XI2  = XIS2(IT1)        
      AZRO = A0(IT1)        
      ETA  = YB(B)        
      ZETA = ZB(B)        
C        
C     CHECK TO SEE IF CALCULATIONS ARE TO BE MADE        
C        
      IF (DY.EQ.ETA .AND. DZ.EQ.ZETA) GO TO 30        
      ASSIGN 20 TO JDZDY        
      LHS = 0        
      GO TO 100        
   20 D(1,T1) = DZYR        
      D(2,T1) = DZYI        
C        
C     SKIP IF NO SYMMETRY        
C        
   30 CONTINUE        
      IF (DELTA .EQ. 0.0) GO TO 70        
      ETA = -YB(B)        
C        
C     CHECK TO SEE IF CALCULATIONS ARE TO BE MADE        
C        
      IF (DY.EQ.ETA .AND. DZ.EQ.ZETA) GO TO 50        
      LHS = 1        
      ASSIGN 40 TO JDZDY        
      GO TO 100        
   40 D(1,T1) = D(1,T1) + DELTA*DZYR        
      D(2,T1) = D(2,T1) + DELTA*DZYI        
   50 CONTINUE        
      IF (EPSLON .EQ. 0.0) GO TO 140        
C        
C     CALC. ONLY IF DELTA AND EPSLON  NOT EQUAL ZERO        
C        
      ETA  = -YB(B)        
      ZETA = -ZB(B)        
C        
C     CHECK TO SEE IF CALCULATIONS ARE TO BE MADE        
C        
      IF (DY.EQ.ETA .AND. DZ.EQ.ZETA) GO TO 70        
      ASSIGN 60 TO JDZDY        
      GO TO 100        
   60 D(1,T1) = D(1,T1) + EPSLON*DELTA*DZYR        
      D(2,T1) = D(2,T1) + EPSLON*DELTA*DZYI        
C        
C     SKIP IF NO GROUND EFFECTS        
C        
   70 IF (EPSLON .EQ. 0.0) GO TO 140        
      ETA  =  YB(B)        
      ZETA = -ZB(B)        
C        
C     CHECK TO SEE IF CALCULATIONS ARE TO BE MADE        
C        
      IF (DY.EQ.ETA .AND. DZ.EQ.ZETA) GO TO 140        
      LHS = 1        
      ASSIGN 80 TO JDZDY        
      GO TO 100        
   80 D(1,T1) = D(1,T1) + EPSLON*DZYR        
      D(2,T1) = D(2,T1) + EPSLON*DZYI        
      GO TO 140        
C        
C     CALL SEQUENCE TO DZY        
C        
  100 CALL DZY (DX,DY,DZ,SGR,CGR,XI1,XI2,ETA,ZETA,DAR,AZRO,KR,REFC,     
     1          BETA,FMACH,LHS,IDZDY,DZYR,DZYI)        
      LHS = 0        
      GO TO JDZDY, (20,40,60,80)        
C        
  140 CONTINUE        
C        
C     END OF LOOP FOR ELEMENT        
C        
C     200 IS END OF LOOP ON SLENDER BODY        
C        
  200 CONTINUE        
C        
C     WRITE ROW ON TAPE, ROW NUMBER, NO. ELEMENTS, DATA        
C        
      CALL WRITE (NTAPE,D,2*T1,0)        
      IF (IPRNT .NE. 0) WRITE (NPOT,210) ROW,T1,D        
  210 FORMAT (' ROWDYZ - ROW NO.',I5,1H,,I10,' ELEMENTS',/(1X,6E12.4))  
      RETURN        
      END        
