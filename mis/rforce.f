      SUBROUTINE RFORCE (LCORE)        
C        
C     COMPUTES STATIC LOADS DUE TO ROTATING COORDINATE SYSTEMS        
C        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         NONSHL,CUPMAS        
      INTEGER         FILE,SLT,BGPDT,OLD,ICARD(6),SYSBUF,NAME(2),       
     1                STRTMN,ANDF,RSHIFT        
      REAL            MT(3,3),MTR(3,3),MR(3,3)        
      DIMENSION       CARD(6),RA(4),WB(3),WG(3),RI(4),XM(6,6),IY(7)     
      COMMON /MACHIN/ MACH,IHALF,JHALF        
      COMMON /CONDAS/ PI,TWOPHI,RADEG,DEGRA,S4PISQ        
      COMMON /UNPAKX/ IT1,II,JJ,INCR        
      COMMON /XCSTM / TI(3,3)        
      COMMON /TRANX / IX(5),TO(3,3)        
CZZ   COMMON /ZZSSA1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYSBUF,DUMY(25),MN        
      COMMON /ZNTPKX/ A(4),IROW,IEOL,IEOR        
      COMMON /LOADX / LC,SLT,BGPDT,OLD,NN(11),MGG        
      EQUIVALENCE     (ICARD(1),CARD(1)), (IR,RI(1)), (IRA,RA(1))       
      DATA    NAME  / 4HRFOR,4HCE  /        
C        
C     DEFINITION OF VARIABLES        
C        
C     SLT      STATIC LOAD TABLE        
C     BGPDT    BASIC GRID POINT DEFINITION TABLE        
C     MGG      MASS  MATRIX        
C     FILE     FILE NAME FOR ERROR MESAGES        
C     CARD     CARD IMAGE OF RFORCE CARD        
C     RA       BGPDT ENTRY FOR AXIAL GRID POINT        
C     WB       OMEGA-S IN BASIC COORDINATES        
C     II       SIL OF CURRENT  POINT        
C     IT1      UNPACK TYPE(REAL)        
C     INCR     INCREMENT( TO ROW STORE COLUMNS)        
C     RI       BGPDT ENTRY FOR CURRENT GRID POINT        
C     WG       OMEGA-S IN GLOBAL COORDINANTS AT CURRENT GRID POINT      
C     XM       6X6 DIAGONAL PARTION OF MGG        
C     MT       3X3 PARTITION OF  MGG        
C     MR       3X3 PARTITION OF  MGG        
C     MTR      3X3 PARTITION OF  MGG        
C     OLD      CURRENT POSITION OF BGPDT  0 IMPLIES BEGINNING        
C        
C        
C     BRING IN CARD IMAGE        
C        
      CALL FREAD (SLT,CARD,6,0)        
C        
C     FIND LOCATION OF AXIAL GRID POINT        
C        
      DO 10 I = 1,3        
      RA(I+1) = 0.0        
   10 CONTINUE        
      IF (ICARD(1) .EQ. 0) GO TO 30        
      CALL FNDPNT (RA(1),ICARD(1))        
C        
C     CHECK FOR GRID POINT        
C        
      IF (IRA .NE. -1) GO TO 30        
      DO 20 I = 1,3        
      RA(I+1) = 0.0        
   20 CONTINUE        
   30 CALL REWIND (BGPDT)        
      CALL SKPREC (BGPDT,1)        
C        
C     CONVERT WI'S TO BASIC COORDINANTS        
C        
      DO 40 I = 4,6        
      WB(I-3) = CARD(I)*TWOPHI*CARD(3)        
   40 CONTINUE        
      IF (ICARD(2) .EQ. 0) GO TO 60        
      CALL FDCSTM (ICARD(2))        
      CALL MPYL (TO,WB,3,3,1,WG)        
      DO 50 I = 1,3        
      WB(I) = WG(I)        
   50 CONTINUE        
C        
C     OPEN MASS MATRIX        
C        
   60 CONTINUE        
      J   = LCORE - SYSBUF        
      CALL GOPEN (MGG,Z(J),0)        
      IT1 = 1        
C        
C     TEST FOR COUPLED MASS        
C        
      IY(1) = MGG        
      CALL RDTRL (IY)        
      CUPMAS = .FALSE.        
      IF (IY(6) .EQ. 1) GO TO 90        
      IF (IY(6) .GT. 6) CUPMAS = .TRUE.        
      IF (CUPMAS) GO TO 90        
      INCR = 0        
      NCOL = IY(2)        
      DO 70 I = 1,NCOL        
      II = 0        
      CALL UNPACK (*70,MGG,A)        
      IF (JJ-II .GT. 6) CUPMAS = .TRUE.        
      IF (CUPMAS) GO TO 80        
   70 CONTINUE        
   80 CALL REWIND (MGG)        
      CALL SKPREC (MGG,1)        
   90 II = 1        
      INCR = 6        
C        
C     TEST FOR CONICAL SHELL PROBLEM        
C        
      NONSHL = .TRUE.        
      IF (MN .EQ. 0) GO TO 100        
      NONSHL = .FALSE.        
      NHARMS = ANDF(MN,JHALF)        
      NRINGS = RSHIFT(MN,IHALF)        
      IY(1)  = BGPDT        
      CALL RDTRL (IY)        
      STRTMN = IY(2) - NHARMS*NRINGS        
      IPTAX  = 0        
      KOUNTM = 0        
C        
C     BRING IN BGPDT        
C        
  100 FILE = BGPDT        
      CALL READ (*410,*330,BGPDT,RI(1),4,0,IFLAG)        
C        
C     TEST FOR CONICAL SHELL PROCESSING        
C        
      IF (NONSHL) GO TO 120        
      IPTAX = IPTAX + 1        
      IF (IPTAX .LT. STRTMN) GO TO 110        
      KOUNTM = KOUNTM + 1        
      IF (KOUNTM .LE. NRINGS) GO TO 240        
      GO TO 330        
C        
  110 IF (IR .NE. -1) CALL SKPREC (MGG,6)        
C        
C     CHECK FOR SCALAR POINT        
C        
  120 CONTINUE        
      IF (IR .NE. -1) GO TO 130        
      CALL SKPREC (MGG,1)        
      II = II + 1        
      GO TO 100        
C        
C     TEST FOR COUPLED MASS PROCESSING        
C        
  130 IF (CUPMAS) GO TO 250        
C        
C     CONVERT WB'S TO GLOBAL COORDINATES AT RI        
C        
      DO 140 I = 1, 3        
  140 WG(I) = WB(I)        
      IF (IR .EQ. 0) GO TO 150        
      CALL BASGLB (WB(1),WG(1),RI(2),IR)        
C        
C     BRING IN  6X6  ON DIAGONAL OF MASS MATRIX        
C        
  150 JJ = II + 5        
      DO 160 J = 1,6        
      DO 160 I = 1,6        
      XM(I,J) = 0.0        
  160 CONTINUE        
      DO 170 I = 1,6        
      CALL UNPACK (*170,MGG,XM(I,1))        
  170 CONTINUE        
C        
C     MOVE  6X6 TO PARTITIONS        
C        
      DO 180 I = 1,3        
      DO 180 J = 1,3        
      MT(J,I) = XM(J,I)        
      MR(J,I) = XM(J+3,I+3)        
      MTR(J,I)= XM(J+3,I)        
  180 CONTINUE        
C        
C     COMPUTE WBX(RI-RA)        
C        
      DO 190 I = 1,3        
      XM(I,1) = RI(I+1) - RA(I+1)        
  190 CONTINUE        
      CALL CROSS (WB(1),XM(1,1),XM(1,3))        
      DO 200 I = 1,3        
      XM(I,1) = XM(I,3)        
  200 CONTINUE        
      IF (IR .EQ. 0) GO TO 210        
      CALL MPYL (TI(1,1),XM(1,1),3,3,1,XM(1,3))        
  210 CONTINUE        
C        
C     COMPUTE MOMENTS        
C        
      CALL MPYL  (MR(1,1),WG(1),3,3,1,XM(1,1))        
      CALL CROSS (XM(1,1),WG(1),XM(1,2))        
      CALL MPYLT (MTR(1,1),XM(1,3),3,3,1,XM(1,1))        
      CALL CROSS (XM(1,1),WG,XM(1,4))        
      J = II + 2        
      DO 220 I = 1,3        
      J = J + 1        
      Z(J) = Z(J) + XM(I,2) + XM(I,4)        
  220 CONTINUE        
C        
C     COMPUTE FORCES        
C        
      CALL MPYL  (MTR(1,1),WG(1),3,3,1,XM(1,1))        
      CALL CROSS (XM(1,1),WG(1),XM(1,2))        
      CALL MPYL  (MT(1,1),XM(1,3),3,3,1,XM(1,1))        
      CALL CROSS (XM(1,1),WG,XM(1,4))        
      J = II - 1        
      DO 230 I = 1,3        
      J = J + 1        
      Z(J) = Z(J) + XM(I,4) + XM(I,2)        
  230 CONTINUE        
C        
C     BUMP  II        
C        
      II  = II + 6        
      GO TO 100        
C        
C     CONICAL SHELL PROCESSING        
C     COMPUTE A = R*WB**2        
C        
  240 XM(2,3) = 0.0        
      XM(3,3) = 0.0        
      XM(1,3) = RI(2)*WB(2)*WB(2)        
      GO TO 290        
C        
C     COUPLED MASS PROCESSING        
C     COMPUTE -WB*(WB*(RI - RA))        
C        
  250 DO 260 I = 1, 3        
  260 XM(I,1) = RI(I+1) - RA(I+1)        
      CALL CROSS (WB(1),XM(1,1),XM(1,3))        
      CALL CROSS (XM(1,3),WB(1),XM(1,1))        
      IF (IR .EQ. 0) GO TO 270        
      CALL BASGLB (XM(1,1),XM(1,3),RI(2),IR)        
      GO TO 290        
  270 DO 280 I = 1, 3        
  280 XM(I,3) = XM(I,1)        
C        
C     COMPUTE F = M*A        
C        
  290 I1 = 1        
      DO 320 I = 1, 3        
      CALL INTPK (*320,MGG,0,I1,0)        
      IF (XM(I,3) .EQ. 0.0) GO TO 310        
  300 CALL ZNTPKI        
      Z(IROW) = Z(IROW) + A(1)*XM(I,3)        
      IF (IEOL .NE. 1) GO TO 300        
      GO TO 320        
  310 CALL SKPREC (MGG,1)        
  320 CONTINUE        
      CALL SKPREC (MGG,3)        
      GO TO 100        
C        
C     EOR IN BGPDT        
C        
  330 CALL CLOSE  (MGG,1)        
      CALL REWIND (BGPDT)        
      OLD = 0        
      CALL SKPREC (BGPDT,1)        
      RETURN        
C        
C     FILE ERRORS        
C        
  400 CALL MESAGE (IP1,FILE,NAME(1))        
  410 IP1 = -2        
      GO TO 400        
      END        
