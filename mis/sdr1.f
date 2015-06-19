      SUBROUTINE SDR1        
C        
      EXTERNAL        ANDF        
      INTEGER         ANDF,UE,REIG,USET,PG,ULV,UOOV,YS,GO,GM,PS,QR,     
     1                UGVX,PGX,QSX,UM,UO,UR,US,IA(7),        
     2                UA1,UF1,UN1,UG1,UP,UNE,UFE,UD,UA,UF,UN,UG,DYNA    
      COMMON /TWO   / TWO1(32)        
      COMMON /BLANK / APPEND,ITYPE(2)        
      COMMON /BITPOS/ UM,UO,UR,USG,USB,UL,UA1,UF1,US,UN1,UG1,UE,UP,UNE, 
     1                UFE,UD        
      COMMON /SYSTEM/ ISYS(54),IPREC,IHEAT        
      EQUIVALENCE     (ISYS(25),IRFNO)        
CIBMR 6/93     DATA    DYNA  , REIG , IUM, ISCR5,ISCR6    /        
CIBMR 6/93    1        4HDYNA, 4HREIG,304, 0    ,306      /        
      DATA    DYNA  , REIG / 4HDYNA, 4HREIG /
CIBMD 6/93 DATA    IUR   , IUO  , IUA, IUF, IUN, IUG, IPVECT, IUS /        
CIBMD 6/93 1        0     , 304  , 302, 303, 302, 306, 301   , 304 /        
CIBMD 6/93 DATA    USET  , PG   , ULV, UOOV,YS , GO , GM    , PS  /        
CIBMD 6/93 1        101   , 102  , 103, 104, 105, 106, 107   , 108 /        
CIBMD 6/93 DATA    KFS   , KSS  , QR , UGVX,PGX, QSX  /        
CIBMD 6/931        109   , 110  , 111, 201, 202, 203  /        
C        
CIBMNB 6/93
      IUM   = 304
      ISCR6 = 306
      IUR   = 0
      IUO   = 304
      IPVECT= 301
      IUS   = 304
      USET  = 101
      PG    = 102
      ULV   = 103
      UOOV  = 104
      YS    = 105
      GO    = 106
      GM    = 107
      PS    = 108
      KSS   = 110
      QR    = 111
      UGVX  = 201
      PGX   = 202
      QSX   = 203
CIBMNE
      KFS = 109        
      IUA = 302        
      IUF = 303        
      IUN = 302        
      IUG = 306        
      ISCR5 = 0        
C        
C     COPY PG ONTO PGX        
C        
      CALL SDR1A (PG,PGX)        
C        
C     SET FLAGS TO CONTROL LOGIC        
C        
      IA(1) = USET        
      CALL RDTRL (IA(1))        
      IF (IA(1) .LE. 0) RETURN        
      IOMT   = ANDF(IA(5),TWO1(UO))        
      NOUE   = ANDF(IA(5),TWO1(UE))        
      ISNG   = ANDF(IA(5),TWO1(US))        
      IREACT = ANDF(IA(5),TWO1(UR))        
      IMULTI = ANDF(IA(5),TWO1(UM))        
      ITRAN  = 1        
C        
C     TEST FOR DYNAMICS OR STATICS        
C        
      IF (NOUE.NE.0 .OR. ITYPE(1).EQ.DYNA) GO TO 10        
C        
C     STATICS        
C        
      UA = UA1        
      UF = UF1        
      UN = UN1        
      UG = UG1        
      GO TO 20        
C        
C     DYNAMICS        
C        
   10 UG = UP        
      UN = UNE        
      UF = UFE        
      UA = UD        
      IF (IHEAT .NE. 0) ITRAN = 0        
      IF (IRFNO .EQ. 9) ITRAN = 0        
   20 CONTINUE        
C        
C     IF REAL EIGENVALUE,BUCKLING,OR DYNAMICS PROBLEM UR = 0        
C        
      IF (ITYPE(1).EQ.DYNA .OR. ITYPE(1).EQ.REIG) GO TO 70        
      IF (IREACT) 40,70,40        
C        
C     REACTIONS        
C        
   40 CALL SDR1B (IPVECT,ULV,IUR,IUA,UA,UL,UR,USET,0,0)        
      ISCR5 = 305        
      IF (ISNG) 50,60,50        
   50 CONTINUE        
      CALL SDR1B (IPVECT,QR,0,ISCR5,UF,UR,UL,USET,0,0)        
      IUG = IUA        
      GO TO 80        
C        
C     REACTS BUT NO SINGLES - MAKE QG        
C        
   60 CALL SDR1B (IPVECT,QR,0,ISCR5,UG,UR,UL,USET,0,0)        
      CALL SDR1A (ISCR5,QSX)        
      GO TO 80        
C        
C     NO REACT        
C        
C        
C     NON STATICS APPROACH        
C        
   70 IUA = ULV        
   80 IF (IOMT) 90,100,90        
C        
C     OMITTED POINTS        
C        
   90 CALL SSG2B (GO,IUA,UOOV,IUO,0,IPREC,1,ISCR6)        
      CALL SDR1B (IPVECT,IUA,IUO,IUF,UF,UA,UO,USET,0,0)        
      IUG = IUF        
      GO TO 110        
C        
C     NO OMITTED POINTS        
C        
  100 ISAV = IUF        
      IUF  = IUA        
      IUN  = ISAV        
  110 IF (ISNG) 120,180,120        
C        
C     SINGLE POINT CONSTRAINTS        
C        
C        
C     TEST FOR PRESENCE OF YS VECTOR        
C        
  120 IA(1) = YS        
      CALL RDTRL (IA(1))        
      IF (IA(1).LT.0 .OR. IA(6).EQ.0) GO TO 130        
      CALL SDR1B (IPVECT,IUF,YS,IUN,UN,UF,US,USET,1,IUS)        
C        
C     IUS CONTAINS EXPANDED YS FROM SPC        
C        
C        
C     IS QS REWUESTED        
C        
      IA(1) = QSX        
      CALL RDTRL (IA(1))        
      IF (IA(1) .LE. 0) GO TO 190        
C        
C     COMPUTE QS        
C        
      CALL SSG2B (KSS,IUS,PS,IPVECT,0,IPREC,2,ISCR6)        
      CALL SSG2B (KFS,IUF,IPVECT,IUS,1,IPREC,1,ISCR6)        
      IF (IMULTI.NE.0 .AND. IREACT.NE.0) GO TO 160        
      CALL SDR1B (IPVECT,IUS,ISCR5,ISCR6,UG,US,UF,USET,0,0)        
      CALL SDR1A (ISCR6,QSX)        
      GO TO 190        
C        
C     NO YS VECTOR        
C        
  130 CALL SDR1B (IPVECT,IUF,0,IUN,UN,UF,US,USET,0,0)        
      IA(1) = QSX        
      CALL RDTRL (IA(1))        
      IF (IA(1) .LE. 0) GO TO 190        
C        
C     COMPUTE QS = KFS T*UF        
C        
      IUF1 = IUF        
      IF (ITYPE(1) .NE. DYNA) GO TO 140        
C        
C     EXPAND  KFS TO  D SET        
C        
      IF (NOUE .EQ. 0) GO TO 140        
      CALL SDR1B (IPVECT,KFS,0,IUS,UF,UF1,UE,USET,0,0)        
      KFS = IUS        
C        
C     IF TRANSIENT STRIP VELOCITY AND ACCERERATION FROM IUF        
C        
  140 CALL SDR1D (PS,IUF,QSX,ITRAN)        
      IF (ITRAN .EQ. 1) GO TO 150        
      IUF1 = QSX        
  150 CALL SSG2B (KFS,IUF1,PS,IPVECT,1,IPREC,2,ISCR6)        
      IF (IMULTI.NE.0 .AND. IREACT.NE.0 .AND. ITYPE(1).NE.DYNA .AND.    
     1    ITYPE(1).NE.REIG) GO TO 170        
      CALL SDR1B (IUS,IPVECT,ISCR5,ISCR6,UG,US,UF,USET,0,0)        
      CALL SDR1A (ISCR6,QSX)        
      GO TO 190        
  160 CALL SDR1B (IPVECT,IUS,ISCR5,ISCR6,UN,US,UF,USET,0,0)        
      CALL SDR1B (IPVECT,ISCR6,0,IUS,UG,UN,UM,USET,0,0)        
      CALL SDR1A (IUS,QSX)        
      GO TO 190        
  170 CALL SDR1B (IUS,IPVECT,ISCR5,IUF,UN,US,UF,USET,0,0)        
      CALL SDR1B (IUS,IUF,0,IPVECT,UG,UN,UM,USET,0,0)        
      CALL SDR1A (IPVECT,QSX)        
      GO TO 190        
C        
C     NO SINGLE POINT CONSTRAINTS        
C        
  180 IUG = IUN        
      IUN = IUF        
C        
  190 IF (IMULTI) 210,200,210        
C        
C     NO MULTI POINT CONSTRAINTS        
C        
  200 IUG = IUN        
      GO TO 220        
C        
C     MULTI POINT CONSTRAINTS        
C        
  210 IUG = ISCR6        
      CALL SSG2B (GM,IUN,0,IUM,0,IPREC,1,ISCR6)        
      CALL SDR1B (IPVECT,IUN,IUM,IUG,UG,UN,UM,USET,0,0)        
  220 CALL SDR1A (IUG,UGVX)        
      RETURN        
      END        
