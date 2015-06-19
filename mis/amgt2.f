      SUBROUTINE AMGT2 (INPUT,D1JK,D2JK)        
C        
C     DRIVER FOR SWEPT TURBOPROP BLADES (AEROELASTIC THEORY 7).        
C        
C     COMPUTATIONS ARE FOR D1JK AND D2JK MATRICES.        
C     FOR SWEPT TURBOPROPS K-SET = J-SET = 2*NSTNS*NLINES.        
C        
C     D1JK = F(INVERSE)TRANSPOSE        
C        
C     D2JK = NULL        
C        
      LOGICAL         TSONIC,DEBUG        
      INTEGER         D1JK,D2JK,TD1JK,TD2JK,ECORE,SYSBUF,NAME(2),SLN    
      REAL            MINMAC,MAXMAC,MACH        
      DIMENSION       IZ(1)        
      COMMON /AMGP2 / TD1JK(7),TD2JK(7)        
      COMMON /AMGMN / MCB(7),NROW,DUM(2),REFC,SIGMA,RFREQ        
      COMMON /CONDAS/ PI,TWOPI,RADEG,DEGRA,S4PISQ        
      COMMON /PACKX / ITI,ITO,II,NN,INCR        
      COMMON /SYSTEM/ SYSBUF,IOUT        
CZZ   COMMON /ZZMGT2/ WORK(1)        
      COMMON /ZZZZZZ/ WORK(1)        
      COMMON /BLANK / NK,NJ        
      COMMON /TAMG2L/ IREF,MINMAC,MAXMAC,NLINES,NSTNS,REFSTG,REFCRD,    
     1                REFMAC,REFDEN,REFVEL,REFSWP,SLN,NSTNSX,STAGER,    
     2                CHORD,DCBDZB,BSPACE,MACH,DEN,VEL,SWEEP,AMACH,     
     3                REDF,BLSPC,AMACHR,TSONIC,XSIGN        
      COMMON /AMGBUG/ DEBUG        
      EQUIVALENCE     (WORK(1),IZ(1))        
      DATA    NAME  / 4HAMGT,4H2   /        
C        
C     READ PARAMETERS IREF,MINMAC,MAXMAC,NLINES AND NSTNS        
C        
      CALL FREAD (INPUT,IREF,5,0)        
      IF (DEBUG) CALL BUG1 ('ACPT-REF  ',5,IREF,5)        
C        
C     READ REST OF ACPT RECORD INTO OPEN CORE AND LOCATE REFERENCE      
C     PARAMETERS REFSTG,REFCRD,REFMAC,REFDEN,REFVEL AND REFSWP        
C        
      ECORE = KORSZ(IZ) - 3*SYSBUF        
      CALL READ (*10,*10,INPUT,IZ,ECORE,1,NWAR)        
      GO TO 120        
   10 NDATA = 3*NSTNS + 10        
      IF (DEBUG) CALL BUG1 ('ACPT-REST ',10,IZ,NWAR)        
      IRSLN = 0        
      NLINE = 0        
      DO 20 I = 1,NWAR,NDATA        
      IF (IREF .EQ. IZ(I)) IRSLN = I        
      NLINE = NLINE + 1        
   20 CONTINUE        
C        
C     DETERMINE DIRECTION OF BLADE ROTATION VIA Y-COORDINATES AT TIP    
C     STREAMLINE. USE COORDINATES OF FIRST 2 NODES ON STREAMLINE.       
C        
      IPTR  = NDATA*(NLINES-1)        
      XSIGN = 1.0        
      IF (WORK(IPTR+15) .LT. WORK(IPTR+12)) XSIGN = -1.0        
C        
C     DID IREF MATCH AN SLN OR IS THE DEFAULT TO BE TAKEN (BLADE TIP)   
C        
      IF (IRSLN .EQ. 0) IRSLN = (NLINES-1)*NDATA + 1        
      REFSTG = WORK(IRSLN+2)        
      REFCRD = WORK(IRSLN+3)        
      REFMAC = WORK(IRSLN+6)        
      REFDEN = WORK(IRSLN+7)        
      REFVEL = WORK(IRSLN+8)        
      REFSWP = WORK(IRSLN+9)        
C        
C     REPOSITION ACPT TO BEGINNING OF BLADE DATA.        
C        
      CALL BCKREC (INPUT)        
      CALL FREAD  (INPUT,0,-6,0)        
C        
      IF (DEBUG) CALL BUG1 ('TAMG2L    ',22,IREF,27)        
C        
C     COMPUTE POINTERS AND SEE IF THERE IS ENOUGH CORE        
C        
      NSTNS2 = 2*NSTNS        
      NSNS   = NSTNS*NSTNS        
      IP1    = 1        
      IP2    = IP1 + NSNS        
      NEXT   = IP2 + 3*NSTNS        
      IF (NEXT .GT. ECORE) GO TO 120        
C        
C     COMPUTE F(INVERSE) FOR EACH STREAMLINE        
C        
      NN = II + NSTNS - 1        
      DO 100 NLINE = 1,NLINES        
      CALL AMGT2A (INPUT,WORK(IP1),WORK(IP2),WORK(IP2))        
C        
C     OUTPUT D1JK (=F(INVERSE)TRANSPOSE) FOR THIS STREAMLINE.        
C        
      IP3 = IP2 + NSTNS - 1        
      DO 50 I = 1,NSTNS        
      K   = I        
      DO 30 J = IP2,IP3        
      WORK(J) = WORK(K)        
   30 K   = K + NSTNS        
      CALL PACK (WORK(IP2),D1JK,TD1JK)        
      IF (DEBUG) CALL BUG1 ('D1JK      ',40,WORK(IP2),NSTNS)        
   50 CONTINUE        
      II = II + NSTNS        
      NN = NN + NSTNS        
      DO 80 I = 1,NSTNS        
      K = I        
      DO 70 J = IP2,IP3        
      WORK(J) = WORK(K)        
   70 K = K + NSTNS        
      CALL PACK (WORK(IP2),D1JK,TD1JK)        
      IF (DEBUG) CALL BUG1 ('D1JK      ',70,WORK(IP2),NSTNS)        
   80 CONTINUE        
      II = II + NSTNS        
      IF (NLINE .EQ. NLINES) GO TO 100        
      NN = NN + NSTNS        
  100 CONTINUE        
C        
C     OUTPUT D2JK = NULL        
C        
      DO 110 ICOL = 1,NK        
      CALL BLDPK  (ITI,ITO,D2JK,0,0)        
  110 CALL BLDPKN (D2JK,0,TD2JK)        
      RETURN        
C        
C     ERROR MESSAGES        
C        
C     NOT ENOUGH CORE        
C        
  120 CALL MESAGE (-8,0,NAME)        
      RETURN        
      END        
