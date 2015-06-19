      SUBROUTINE SHCTSS (IERR,ELID,PID,MID,TLAM,TMEAN,TGRAD,THETAE,     
     1                   FTHERM,EPSLNT,ICORE,CORE)        
C        
C     SINGLE PRECISION ROUTINE TO EVALUATE THERMAL STRAINS FOR COMPOSITE
C     SHELL ELEMENTS.        
C        
C     INPUT :        
C           ELID   - ELEMENT ID        
C           PID    - PROPERTY ID        
C           MID    - ARRAY OF LAMINATE MATERIAL ID'S        
C           TLAM   - LAMINATE THICKNESS        
C           TMEAN  - ELEMENT MEAN TEMPERATURE        
C           TGRAD  - THERMAL GRADIENT        
C           THETAE - ANGLE FROM ELEMENT X-AXIS TO MATERIAL X-AXIS       
C           FTHERM - ARRAY OF THERMAL FORCES CONTAINING THE USER-       
C                    DEFINED THERMAL MOMENTS, IF SUPPLIED        
C           IPCMPI AND NPCMPI ARE THE STARTING POINT AND THE NUMBER     
C           OF WORDS OF PCOMPI DATA IN CORE, AS INPUT BY /SDR2C1/.      
C     OUTPUT:        
C           EPSLNT - ARRAY OF THERMAL STRAINS FOR THE LAMINATE        
C        
C        
      LOGICAL          NONMEM,PCMP,PCMP1,PCMP2        
      INTEGER          ELID,PID,MID(4),ICORE(1),PCOMP,PCOMP1,PCOMP2,    
     1                 PIDLOC,SYM,SYMMEM,INDX(6,3)        
      REAL             CORE(1)        
      REAL             TLAM,TMEAN,TGRAD,THETAE,FTHERM(6),EPSLNT(6),     
     1                 MINRT,ABBD(6,6),STIFF(36),GLAY(9),GLAYT(9),      
     2                 GBAR(9),GPROP(25),ALPHAL(3),ALPHAE(3),GALPHA(3), 
     3                 THETA,TRANSL(9),TSUBO,DELTA,DELTAT,ZK,ZK1,ZREF,  
     4                 ZSUBI,C,C2,S,S2,PI,TWOPI,RADDEG,DEGRAD,DETERM,   
     5                 DUM(6)        
      COMMON /CONDAS/  PI,TWOPI,RADDEG,DEGRAD        
      COMMON /MATIN /  MATID,INFLAG,ELTEMP        
      COMMON /SDR2C1/  IPCMP,NPCMP,IPCMP1,NPCMP1,IPCMP2,NPCMP2        
C        
C        
      DATA    PCOMP ,  PCOMP1,PCOMP2 / 0,1,2 /        
      DATA    SYM   ,  MEM   ,SYMMEM / 1,2,3 /        
C        
C     INITIALIZE        
C        
      IERR = 0        
      DO 20 LL = 1,6        
      DO 10 MM = 1,6        
      ABBD(LL,MM) = 0.0        
   10 CONTINUE        
   20 CONTINUE        
C        
      MINRT = TLAM*TLAM*TLAM/12.0        
      ZREF  =-TLAM/2.0        
C        
      INFLAG = 12        
      ELTEMP = TMEAN        
C        
      ITYPE = -1        
      LPCOMP= IPCMP + NPCMP + NPCMP1 + NPCMP2        
      PCMP  = NPCMP  .GT. 0        
      PCMP1 = NPCMP1 .GT. 0        
      PCMP2 = NPCMP2 .GT. 0        
C        
C     ISSUE ERROR IF PCOMPI DATA HAS NOT BEEN READ INTO CORE        
C        
      IF (LPCOMP .EQ. IPCMP) GO TO 600        
C        
C     LOCATE PID BY PERFORMING A SEQUENTIAL SEARCH OF THE PCOMPI DATA   
C     BLOCK WHICH IS IN CORE.        
C        
C     SEARCH FOR PID IN PCOMP DATA        
C        
      IF (.NOT.PCMP) GO TO 110        
      IP = IPCMP        
      IF (ICORE(IP) .EQ. PID) GO TO 210        
      IPC11 = IPCMP1 - 1        
      DO 100 IP = IPCMP,IPC11        
      IF (ICORE(IP).NE.-1 .OR. IP.GE.IPC11) GO TO 100        
      IF (ICORE(IP+1) .EQ. PID) GO TO 200        
  100 CONTINUE        
C        
C     SEARCH FOR PID IN PCOMP1 DATA        
C        
  110 IF (.NOT.PCMP1) GO TO 130        
      IP = IPCMP1        
      IF (ICORE(IP) .EQ. PID) GO TO 230        
      IPC21 = IPCMP2 - 1        
      DO 120 IP = IPCMP1,IPC21        
      IF (ICORE(IP).NE.-1 .OR. IP.GE.IPC21) GO TO 120        
      IF (ICORE(IP+1) .EQ. PID) GO TO 220        
  120 CONTINUE        
C        
C     SEARCH FOR PID IN PCOMP2 DATA        
C        
  130 IF (.NOT.PCMP2) GO TO 150        
      IP = IPCMP2        
      IF (ICORE(IP) .EQ. PID) GO TO 250        
      LPC11 = LPCOMP - 1        
      DO 140 IP = IPCMP2,LPC11        
      IF (ICORE(IP).NE.-1 .OR. IP.GE.LPC11) GO TO 140        
      IF (ICORE(IP+1) .EQ. PID) GO TO 240        
  140 CONTINUE        
C        
C     PID WAS NOT LOCATED; ISSUE ERROR        
C        
  150 GO TO 600        
C        
C     PID WAS LOCATED; DETERMINE TYPE        
C        
  200 IP     = IP + 1        
  210 ITYPE  = PCOMP        
      PIDLOC = IP        
      NLAY   = ICORE(PIDLOC+1)        
      IPOINT = PIDLOC + 8 + 4*NLAY        
      GO TO 300        
C        
  220 IP     = IP + 1        
  230 ITYPE  = PCOMP1        
      PIDLOC = IP        
      NLAY   = ICORE(PIDLOC+1)        
      IPOINT = PIDLOC + 8 + NLAY        
      GO TO 300        
C        
  240 IP     = IP + 1        
  250 ITYPE  = PCOMP2        
      PIDLOC = IP        
      NLAY   = ICORE(PIDLOC+1)        
      IPOINT = PIDLOC + 8 + 2*NLAY        
C        
  300 TSUBO  = CORE(IPOINT+24)        
      DELTA  = TMEAN - TSUBO        
      LAMOPT = ICORE(PIDLOC+8)        
      NONMEM = LAMOPT.NE.MEM .AND. LAMOPT.NE.SYMMEM        
C        
C     LAMOPT - LAMINATION GENERATION OPTION        
C            = ALL     (ALL PLYS, DEFAULT)        
C            = SYM     (SYMMETRIC)        
C            = MEM     (MEMBRANE ONLY)        
C            = SYMMEM  (SYMMETRIC-MEMBRANE)        
C        
C     CONSTRUCT THE LAMINATE FORCE-STRAIN MATRIX        
C        
C     EXTENSIONAL        
C        
      MATID = MID(1)        
      CALL MAT (ELID)        
      CALL LPROPS (GPROP)        
C        
      DO 320 LL = 1,3        
      II = 3*(LL-1)        
      DO 310 MM = 1,3        
      ABBD(LL,MM) = GPROP(MM+II)*TLAM        
  310 CONTINUE        
  320 CONTINUE        
C        
C     BENDING        
C        
      IF (.NOT.NONMEM) GO TO 400        
C        
      MATID = MID(2)        
      CALL MAT (ELID)        
      CALL LPROPS (GPROP)        
C        
      DO 340 LL = 1,3        
      II = 3*(LL-1)        
      DO 330 MM = 1,3        
      ABBD(LL+3,MM+3) = GPROP(MM+II)*MINRT        
  330 CONTINUE        
  340 CONTINUE        
C        
C     MEMBRANE-BENDING        
C        
      IF (LAMOPT .EQ. SYM) GO TO 400        
C        
      MATID = MID(4)        
      CALL MAT (ELID)        
      CALL LPROPS (GPROP)        
C        
      DO 360 LL = 1,3        
      II = 3*(LL-1)        
      DO 350 MM = 1,3        
      ABBD(LL,MM+3) = GPROP(MM+II)*TLAM*TLAM        
      ABBD(LL+3,MM) = GPROP(MM+II)*TLAM*TLAM        
  350 CONTINUE        
  360 CONTINUE        
C        
C        
C     BEGIN THE LOOP OVER LAYERS        
C        
  400 ZK = ZREF        
      DO 500 K = 1,NLAY        
C        
C     SET THE LAYER-DEPENDENT VARIABLES        
C        
      ZK1 = ZK        
      IF (ITYPE .NE. PCOMP) GO TO 410        
      ZK = ZK1 + CORE(PIDLOC+6+4*K)        
      THETA = CORE(PIDLOC   +7+4*K)        
      GO TO 430        
C        
  410 IF (ITYPE .NE. PCOMP1) GO TO 420        
      ZK = ZK1 + CORE(PIDLOC+8  )        
      THETA = CORE(PIDLOC   +8+K)        
      GO TO 430        
C        
  420 IF (ITYPE .NE. PCOMP2) GO TO 430        
      ZK = ZK1 + CORE(PIDLOC+7+2*K)        
      THETA = CORE(PIDLOC   +8+2*K)        
C        
C     LAYER MATERIAL PROPERTIES        
C        
  430 DO 440 IR = 1,9        
      GLAY(IR) = CORE(IPOINT+IR)        
  440 CONTINUE        
C        
      DO 450 IR = 1,3        
      ALPHAL(IR) = CORE(IPOINT+13+IR)        
  450 CONTINUE        
C        
      TI = ZK - ZK1        
      ZSUBI = (ZK+ZK1)/2.0        
      DELTAT = DELTA + ZSUBI*TGRAD        
C        
C     TRANSFORM THE LAYER MATERIAL PROPERTIES FROM THE FIBER SYSTEM TO  
C     THE ELEMENT SYSTEM        
C        
      THETA = THETA*DEGRAD + THETAE        
      C   = COS(THETA)        
      C2  = C*C        
      S   = SIN(THETA)        
      S2  = S*S        
C        
      TRANSL(1)  = C2        
      TRANSL(2)  = S2        
      TRANSL(3)  = C*S        
      TRANSL(4)  = S2        
      TRANSL(5)  = C2        
      TRANSL(6)  =-C*S        
      TRANSL(7)  =-2.0*C*S        
      TRANSL(8)  = 2.0*C*S        
      TRANSL(9)  = C2 - S2        
C        
C                _            T        
C     CALCULATE [G] = [TRANSL] [GLAY][TRANSL]        
C        
      CALL GMMATS (GLAY(1),3,3,0,  TRANSL(1),3,3,0, GLAYT(1))        
      CALL GMMATS (TRANSL(1),3,3,1, GLAYT(1),3,3,0, GBAR(1))        
C        
C     CALCULATE [ALPHAE] = [TRANSL]X[ALPHA]        
C     MODIFY [TRANSL] FOR TRANSFORMATIONS OF ALPHAS        
C        
      TRANSL(3) = -TRANSL(3)        
      TRANSL(6) = -TRANSL(6)        
      TRANSL(7) = -TRANSL(7)        
      TRANSL(8) = -TRANSL(8)        
C        
      CALL GMMATS (TRANSL(1),3,3,0, ALPHAL(1),3,1,0, ALPHAE(1))        
C        
C        
C     CALCULATE THERMAL FORCES AND MOMENTS        
C        
      CALL GMMATS (GBAR(1),3,3,0, ALPHAE(1),3,1,0, GALPHA(1))        
C        
      DO 460 IR = 1,3        
      FTHERM(IR) = FTHERM(IR  ) + GALPHA(IR)*DELTAT*(ZK-ZK1)        
      IF (NONMEM)  FTHERM(IR+3) = FTHERM(IR+3) - GALPHA(IR)*        
     1                            DELTAT*(ZK*ZK-ZK1*ZK1)/2.0        
  460 CONTINUE        
C        
C     CALCULATE CONTRIBUTION FROM SYMMETRIC LAYERS        
C        
      IF (LAMOPT.NE.SYM .AND. LAMOPT.NE.SYMMEM) GO TO 480        
      DELTAT = DELTA - ZSUBI*TGRAD        
C        
      DO 470 IR = 1,3        
      FTHERM(IR) = FTHERM(IR  ) + GALPHA(IR)*DELTAT*(ZK-ZK1)        
      IF (NONMEM)  FTHERM(IR+3) = FTHERM(IR+3) - GALPHA(IR)*        
     1                            DELTAT*(ZK1*ZK1-ZK*ZK)/2.0        
  470 CONTINUE        
  480 IF (ITYPE .EQ. PCOMP) IPOINT = IPOINT + 27        
C        
  500 CONTINUE        
C        
C        
C     END OF LOOP OVER THE LAYERS        
C        
C     COMPUTE THERMAL STRAIN VECTOR        
C        
C                      -1        
C     {EPSLNT} = [ABBD]  {FTHERM}        
C        
      ISING = -1        
      CALL INVERS (6,ABBD,6,DUM,0,DETERM,ISING,INDX)        
C        
      DO 520 LL = 1,6        
      NN = 6*(LL-1)        
      DO 510 MM = 1,6        
      STIFF(NN+MM) = ABBD(LL,MM)        
  510 CONTINUE        
  520 CONTINUE        
C        
      CALL GMMATS (STIFF(1),6,6,0, FTHERM(1),6,1,0, EPSLNT(1))        
      GO TO 700        
C        
  600 IERR = 1        
  700 RETURN        
      END        
