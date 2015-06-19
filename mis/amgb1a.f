      SUBROUTINE AMGB1A (INPUT,MATOUT,AJJ,AJJT,TSONX,TAMACH,TREDF)      
C        
C     COMPUTE AJJ MATRIX FOR COMPRESSOR BLADES        
C        
      LOGICAL         TSONIC,DEBUG        
      INTEGER         SLN,NAME(2),TSONX(1)        
      REAL            MINMAC,MAXMAC,MACH        
      COMPLEX         AJJ(NSTNS,1),AJJT(NSTNS)        
      DIMENSION       TAMACH(1),TREDF(1)        
      COMMON /AMGMN / MCB(7),NROW,DUM(2),REFC,SIGMA,RFREQ        
      COMMON /CONDAS/ PI,TWOPI,RADEG,DEGRA,S4PISQ        
      COMMON /PACKX / ITI,ITO,II,NN,INCR        
      COMMON /BAMG1L/ IREF,MINMAC,MAXMAC,NLINES,NSTNS,REFSTG,REFCRD,    
     1                REFMAC,REFDEN,REFVEL,REFFLO,SLN,NSTNSX,STAGER,    
     2                CHORD,RADIUS,BSPACE,MACH,DEN,VEL,FLOWA,AMACH,     
     3                REDF,BLSPC,AMACHR,TSONIC        
      COMMON /AMGBUG/ DEBUG        
      DATA    NAME  / 4HAMGB,4H1A  /        
C        
C     LOOP ON STREAMLINES, COMPUTE AJJ FOR EACH STREAMLINE AND THEN     
C     PACK AJJ INTO AJJL MATRIX AT CORRECT POSITION        
C        
      II = 0        
      NN = 0        
      NSTNS3 = 3*NSTNS        
      DO 100 LINE = 1,NLINES        
C        
C     READ STREAMLINE DATA (SKIP COORDINATE DATA)        
C        
      CALL READ (*999,*999,INPUT,SLN,10,0,NWAR)        
      CALL READ (*999,*999,INPUT,0,-NSTNS3,0,NWAR)        
C        
C     COMPUTE PARAMETERS        
C        
      AMACH = MACH*COS(DEGRA*(FLOWA-STAGER))        
      REDF  = RFREQ*(CHORD/REFCRD)*(REFVEL/VEL)*(MACH/AMACH)        
      BLSPC = BSPACE/CHORD        
      IF (DEBUG) CALL BUG1 ('BAMG1L    ',5,IREF,26)        
C        
C     COMPUTE POINTER FOR LOCATION INTO AJJ MATRIX        
C        
      IAJJC = 1        
      IF (TSONIC) IAJJC = NSTNS*(LINE-1) + 1        
C        
C     BRANCH TO SUBSONIC, SUPERSONIC OR TRANSONIC CODE        
C        
      TAMACH(LINE) = AMACH        
      TREDF(LINE)  = REDF        
      IF (AMACH .LE. MAXMAC) GO TO 10        
      IF (AMACH .GE. MINMAC) GO TO 20        
C        
C     TRANSONIC STREAMLINE. STORE DATA FOR TRANSONIC INTERPOLATION      
C        
      TSONX(LINE) = IAJJC        
      GO TO 100        
C        
C     SUBSONIC STREAMLINE        
C        
   10 CALL AMGB1B (AJJ(1,IAJJC))        
      GO TO 30        
C        
C     SUPERSONIC STREAMLINE        
C        
   20 CALL AMGB1C (AJJ(1,IAJJC))        
   30 CONTINUE        
C        
C     IF THERE ARE NO TRANSONIC STREAMLINES OUTPUT THIS AJJ SUBMATRIX   
C        
      IF (TSONIC) GO TO 60        
      II = NN + 1        
      NN = NN + NSTNS        
C        
C     OUTPUT AJJ MATRIX        
C        
      DO 50 I = 1,NSTNS        
      IF (DEBUG) CALL BUG1 ('SS-AJJL   ',40,AJJ(1,I),NSTNS*2)        
      CALL PACK (AJJ(1,I),MATOUT,MCB)        
   50 CONTINUE        
      GO TO 100        
   60 TSONX(LINE) = 0        
  100 CONTINUE        
C        
C     PERFORM TRANSONIC INTERPOLATION, IF NECESSARY        
C        
      IF (.NOT.TSONIC) GO TO 300        
      IF (DEBUG) CALL BUG1 ('TSONX     ',102,TSONX,NLINES)        
      IF (DEBUG) CALL BUG1 ('TAMACH    ',103,TAMACH,NLINES)        
      IF (DEBUG) CALL BUG1 ('TREDF     ',104,TREDF,NLINES)        
      CALL AMGB1D (AJJ,TSONX,TAMACH,TREDF)        
C        
C     OUTPUT AJJ FOR EACH STREAMLINE        
C        
      DO 200 NLINE = 1,NLINES        
      II = NN + 1        
      NN = NN + NSTNS        
      DO 120 I = II,NN        
      IF (DEBUG) CALL BUG1 ('STS-AJJL  ',110,AJJ(1,I),NSTNS*2)        
      CALL PACK (AJJ(1,I),MATOUT,MCB)        
  120 CONTINUE        
  200 CONTINUE        
  300 RETURN        
C        
C     ERROR MESSAGES        
C        
C     INPUT NOT POSITIONED PROPERLY OR INCORRECTLY WRITTEN        
C        
  999 CALL MESAGE (-7,0,NAME)        
      RETURN        
      END        
