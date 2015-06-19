      SUBROUTINE RMG        
C        
C     RADIATION MATRIX GENERATOR MODULE.        
C        
C     DMAP CALLING SEQUENCE        
C        
C     RMG    EST,MATPOOL,GPTT,KGGX/RGG,QGE,KGG/C,Y,TABS/C,Y,SIGMA/      
C            V,N,NLR/V,N,LUSET $        
C        
C     THIS MODULE COMPUTES AND OUTPUTS DATA IN SINGLE OR DOUBLE        
C     PRECISION BASED ON -PRECIS-.        
C        
      LOGICAL          NOGO     ,DOUBLE   ,LRAD        
      INTEGER          BUF(10)  ,SUBR(2)  ,RADLST(2),RADMTX(2),HBDYTP  ,
     1                 EST      ,GPTT     ,RGG      ,QGE      ,SCRT1   ,
     2                 SCRT2    ,SCRT3    ,SCRT4    ,SCRT5    ,SCRT6   ,
     3                 SYSBUF   ,OUTPT    ,TSET     ,PRECIS   ,UNOUT   ,
     4                 UNIROW   ,UNNROW   ,UNINCR   ,PKIN     ,PKOUT   ,
     5                 PKIROW   ,PKNROW   ,PKINCR   ,RD       ,RDREW   ,
     6                 WRT      ,WRTREW   ,CLSREW   ,CLS      ,ELEM    ,
     7                 Z        ,CORE     ,BUF1     ,BUF2     ,BUF3    ,
     8                 FLAG     ,WORDS    ,EOR      ,MCB1(7)  ,MCB2(7) ,
     9                 MCB3(7)  ,ELTYPE   ,ESTWDS   ,ECPT(100),RCOL    ,
     O                 DCOL     ,RX       ,DX       ,SQR      ,FILE    ,
     1                 DIRGG    ,DNRGG    ,IDATA(16),BLOCK(20),RADCHK  ,
     2                 MCB(7)   ,NAME(2)  ,RADTYP(2),BLOCK2(20)        
      REAL             RZ(2)    ,RBUF(10) ,RDATA(16),AI(4)        
      DOUBLE PRECISION DETT     ,MINDIA   ,DSUMFA   ,DO(2)    ,DI(2)   ,
     1                 DZ(1)    ,DTEMP2   ,DVALUE        
      CHARACTER        UFM*23   ,UWM*25   ,UIM*29   ,SFM*25   ,SWM*27   
      COMMON /XMSSG /  UFM      ,UWM      ,UIM      ,SFM      ,SWM      
      COMMON /SYSTEM/  KSYSTM(65)        
      COMMON /NAMES /  RD       ,RDREW    ,WRT      ,WRTREW   ,CLSREW  ,
     1                 CLS      ,SKIP5(5) ,SQR        
      COMMON /ZBLPKX/  AO(4)    ,IROW        
      COMMON /PACKX /  PKIN     ,PKOUT    ,PKIROW   ,PKNROW   ,PKINCR   
      COMMON /UNPAKX/  UNOUT    ,UNIROW   ,UNNROW   ,UNINCR        
      COMMON /GFBSX /  JL(7)    ,JU(7)    ,JB(7)    ,JX(7)    ,NZZZ    ,
     1                 IPR      ,ISGN        
      COMMON /DCOMPX/  IA(7)    ,IL(7)    ,IU(7)    ,ISR1     ,ISR2    ,
     1                 ISR3     ,DETT     ,IPOW     ,NZZ      ,MINDIA  ,
     2                 IB       ,IBBAR        
      COMMON /GPTA1 /  NELEMS   ,LAST     ,INCR     ,ELEM(1)        
CZZ   COMMON /ZZRMGX/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      COMMON /BLANK /  TABS     ,SIGMA    ,NLR      ,LUSET        
      EQUIVALENCE      (Z(1),RZ(1),DZ(1) ),(BUF(1),RBUF(1)   ),        
     1                 (DO(1)   ,AO(1)   ),(DI(1) ,AI(1)     ),        
     2                 (IDATA(1),RDATA(1)),(DEFALT,IDEFLT    ),        
     3                 (KSYSTM( 1),SYSBUF),(KSYSTM( 2),OUTPT ),        
     4                 (KSYSTM(10),TSET  ),(KSYSTM(55),IPREC ),        
     5                 (KSYSTM(57),MYRADM),(KSYSTM(58),RADCHK)        
C        
C     MYRADM  = 1  IMPLIES SYMMETRIC SCRIPT-AF INPUT        
C     RADCHK NE 0  REQUESTS DIAGNOSTIC PRINTOUT OF AREAS AND VIEW FACTOR
C     MYRADM  = 2  IMPLIES UNSYMMETRIC SCRIPT-AF INPUT        
C        
      DATA     SUBR  / 4HRMG ,4H     /        
      DATA     RADTYP/ 4H    ,4H  UN /        
      DATA     RADLST/ 2014,  20     /        
      DATA     RADMTX/ 3014,  30     /        
      DATA     HBDYTP/ 52            /        
      DATA     NOEOR / 0  /, EOR / 1 /        
      DATA     EST   , MATPOL, GPTT, KGGX, RGG, QGE, KGG   /        
     1         101   , 102   , 103 , 104 , 201, 202, 203   /        
      DATA     SCRT1 , SCRT2, SCRT3, SCRT4, SCRT5, SCRT6   /        
     1         301   , 302  , 303  , 304  , 305  , 306     /        
C        
C     DEFINITION OF CORE AND BUFFER POINTERS        
C        
      CALL DELSET        
      SCRT1  = 301        
      PRECIS = 2        
      IF (IPREC .NE. 2) PRECIS = 1        
      CORE = KORSZ(Z)        
      BUF1 = CORE - SYSBUF - 2        
      BUF2 = BUF1 - SYSBUF - 2        
      BUF3 = BUF2 - SYSBUF - 2        
      CORE = BUF3 - 1        
      IF (CORE .LT. 100) CALL MESAGE (-8,0,SUBR)        
      NOGO   = .FALSE.        
      DOUBLE = .FALSE.        
      IF (PRECIS .EQ. 2) DOUBLE = .TRUE.        
      IF (MYRADM.EQ.1 .OR. MYRADM.EQ.2) WRITE (OUTPT,5) UWM,        
     1                                                  RADTYP(MYRADM)  
    5 FORMAT (A25,' 2358, ',A4,'SYMMETRIC SCRIPT-AF MATRIX (HREE) ',    
     1        'ASSUMED IN RADMTX')        
C        
C     OPEN MATPOOL DATA BLOCK.        
C        
      FILE = MATPOL        
      CALL PRELOC (*1100,Z(BUF1),MATPOL)        
C        
C     LOCATE RADLST DATA        
C        
      CALL LOCATE (*1090,Z(BUF1),RADLST,FLAG)        
C        
C     BUILD ELEMENT DATA TABLE.  -LENTRY- WORDS PER ELEMENT ID PRESENT  
C     IN RADLST.        
C        
C     EACH ENTRY CONTAINS THE FOLLOWING OR MORE        
C        
C     WORD  1 = ELEMENT ID OF HBDY ELEMENT        
C     WORD  2 = DIAGONAL MATRIX ELEMENT A-SUB-I        
C     WORD  3 = DIAGONAL MATRIX ELEMENT E-SUB-I        
C     WORD  4 = ELEMENT FA SUM (USED FOR RADMTX CHECK)        
C     WORD  5 = SIL-1        
C     WORD  6 = SIL-2        
C     WORD  7 = SIL-3        
C     WORD  8 = SIL-4        
C     WORD  9 = GIJ-1  (GIJ TERMS MAY BE 2 WORDS EACH IF DOUBLE PREC)   
C     WORD 10 = GIJ-2        
C     WORD 11 = GIJ-3        
C     WORD 12 = GIJ-4        
C        
C        
      LENTRY = 8 + 4*PRECIS        
      IELTAB = 1        
      IDXM8  = IELTAB - LENTRY - 1        
      NELTAB = IELTAB - 1        
   10 IF (NELTAB+LENTRY .GT. CORE) CALL MESAGE (-8,0,SUBR)        
      CALL READ (*1110,*1120,MATPOL,Z(NELTAB+1),1,NOEOR,WORDS)        
      IF (Z(NELTAB+1)) 30,30,20        
   20 Z(NELTAB+2) = 0        
      Z(NELTAB+3) = 0        
      NELTAB = NELTAB + LENTRY        
      GO TO 10        
C        
C     ALL RADLST DATA NOW IN CORE.        
C     (POSITION TO END OF RECORD ON  MATPOOL)        
C        
   30 CALL READ (*1110,*50,MATPOL,BUF,1,EOR,WORDS)        
      WRITE  (OUTPT,40) SWM        
   40 FORMAT (A27,' 3071, EXTRA DATA IN RADLST RECORD OF MATPOOL DATA ',
     1       'BLOCK IGNORED.')        
C        
C     LOCATE RADMTX DATA        
C        
   50 NE = (NELTAB-IELTAB+1)/LENTRY        
      CALL LOCATE (*135,Z(BUF1),RADMTX,FLAG)        
      LRAD = .TRUE.        
C        
C     READ IN RADMTX DATA.  FOR LOWER TRIANGLE COLUMNS PRESENT        
C     ENTRY WORDS 2 AND 3 IN -ELTAB- WILL BE USED TO STORE FIRST        
C     AND LAST LOCATIONS OF LOWER TRIANGLE COLUMN.  ZEROS IMPLY COLUMN  
C     IS NULL.        
C        
      IRAD = NELTAB + 1        
C        
C     READ COLUMN INDEX        
C        
   60 CALL READ (*1110,*140,MATPOL,INDEX,1,NOEOR,WORDS)        
C        
C     MAXIMUM NUMBER OF INPUT TERMS FOR THIS COLUMN. (LOWER TRIANGLE)   
C        
      MAX = NE - INDEX + 1        
      IF (MYRADM .EQ. 2) MAX = NE        
C        
C     SET -IDX- TO ELTAB ENTRY        
C        
      IDX = IDXM8 + INDEX*LENTRY        
C        
C     READ IN COLUMN ELEMENTS IF ANY        
C        
      N = 0        
   70 CALL READ (*1110,*1120,MATPOL,Z(IRAD),1,NOEOR,WORDS)        
      IF (Z(IRAD) .EQ. -1) GO TO 100        
      N = N + 1        
      IRAD = IRAD + 1        
      IF (IRAD .GT. CORE) CALL MESAGE (-8,0,SUBR)        
      IF (N .LE. MAX) GO TO 70        
C        
C     TOO MANY COLUMN ELEMENTS INPUT        
C        
      IRAD = IRAD - 1        
C        
C     SKIP TO END OF COLUMN        
C        
   80 CALL READ (*1110,*1120,MATPOL,IDUM,1,NOEOR,WORDS)        
      IF (IDUM .NE. -1) GO TO 80        
      WRITE  (OUTPT,90) UWM,INDEX,NE        
   90 FORMAT (A25,' 3072, TOO MANY MATRIX VALUES INPUT VIA RADMTX BULK',
     1       ' DATA FOR COLUMN',I9,1H., /5X,'EXTRA VALUES IGNORED AS ', 
     2       'MATRIX SIZE IS DETERMINED TO BE OF SIZE',I9,        
     3       ' FROM RADLST COUNT OF ELEMENT ID-S.')        
C        
C     ALL DATA FOR LOWER TRIANGLE PORTION OF COLUMN IS IN CORE.        
C     (BACK UP OVER ANY ZEROS)        
C        
  100 IF (N) 60,60,110        
  110 IF (Z(IRAD-1)) 130,120,130        
  120 N = N - 1        
      IRAD = IRAD - 1        
      GO TO 100        
C        
C     SET FIRST AND LAST POINTERS        
C        
  130 Z(IDX+2) = IRAD - N        
      Z(IDX+3) = IRAD - 1        
C        
C     GO READ NEXT COLUMN        
C        
      GO TO 60        
C        
C     NULL RADMTX ASSUMED        
C        
  135 LRAD = .FALSE.        
C        
C     RADMTX IS COMPLETELY IN CORE IN TEMPORARY SPECIAL PACKED FORM.    
C        
C     NOW PACK OUT EACH COLUMN OF MATRIX F TO SCRATCH 1        
C        
  140 CALL CLOSE (MATPOL,CLSREW)        
      IF (MYRADM.EQ.1 .OR. MYRADM.EQ.2) SCRT1 = 303        
      CALL GOPEN (SCRT1,Z(BUF1),WRTREW)        
      CALL MAKMCB (MCB1,SCRT1,NE,SQR,PRECIS)        
      DO 210 JCOL = 1,NE        
C        
C     INITIALIZE PACKING OF COLUMN -JCOL-        
C        
      CALL BLDPK (1,PRECIS,SCRT1,0,0)        
C        
C     PACK OUT ELEMENTS OF COLUMN -JCOL-        
C        
      INXCOL = IDXM8 + JCOL*LENTRY        
C        
C     SET FA SUM TO ZERO FOR CURRENT COLUMN.        
C        
      SUMFA = 0.0        
      IF (.NOT.LRAD) GO TO 205        
      DO 200 IROW = 1,NE        
C        
C     LOCATE ELEMENT ROW-IROWK, COL-JCOL.        
C        
      IF (IROW.GE.JCOL .OR. MYRADM.EQ.2) GO TO 180        
C        
C     HERE IF ABOVE THE DIAGONAL        
C     ELEMENT DESIRED IS IN COLUMN -IROW- IN CORE AND POSITION        
C     (JCOL-IROW+1) OF THE LOWER TRIANGLE PORTION.        
C        
      IDX = IDXM8 + IROW*LENTRY        
      I1  = Z(IDX+2)        
      IF (I1) 200,200,150        
  150 I2  = Z(IDX+3)        
      IPOS= JCOL - IROW + I1        
  160 IF (IPOS .GT. I2) GO TO 200        
      IF (RZ(IPOS)) 162,200,170        
  162 WRITE  (OUTPT,164) UWM,JCOL,IROW,RZ(IPOS)        
  164 FORMAT (A25,' 2359, COL',I6,', ROW',I6,        
     1        ' OF RADMTX IS NEGATIVE (',E14.6,').')        
  170 AO(1) = RZ(IPOS)        
      IF (MYRADM.EQ.1 .OR. MYRADM.EQ.2) AO(1) = -SIGMA*RZ(IPOS)        
      IF (JCOL.EQ.IROW .AND. (MYRADM.EQ.1 .OR. MYRADM.EQ.2)) GO TO 175  
      SUMFA = SUMFA + RZ(IPOS)        
  175 CALL ZBLPKI        
      GO TO 200        
C        
C     HERE IF BELOW OR ON DIAGONAL.        
C     ELEMENT DESIRED IS IN COLUMN -JCOL- IN POSITION (IROW-JCOL+I1)    
C        
  180 IDX= INXCOL        
      I1 = Z(IDX+2)        
      IF (I1) 200,200,190        
  190 I2 = Z(IDX+3)        
      IPOS = IROW - JCOL + I1        
      IF (MYRADM .EQ. 2) IPOS = IROW + I1 - 1        
      GO TO 160        
C        
  200 CONTINUE        
C        
C     COMPLETE COLUMN        
C        
  205 CALL BLDPKN (SCRT1,0,MCB1)        
C        
C     SAVE COLUMN FA SUM IN ELTAB FOR AWHILE.        
C        
      RZ(INXCOL+4) = SUMFA        
C        
  210 CONTINUE        
C        
C     PACKED MATRIX IS COMPLETE        
C        
      CALL WRTTRL (MCB1)        
      CALL CLOSE (SCRT1,CLSREW)        
C/////        
C     CALL DMPFIL (-SCRT1,Z(NELTAB+1),CORE-NELTAB-2)        
C     CALL BUG (10HF-MATRIX    ,210,0,1)        
C/////        
C        
C     OUTPUT OF ELEMENT-ID LIST TO QGE HEADER RECORD IS PERFORMED AT    
C     THIS TIME.        
C        
      FILE = QGE        
      CALL OPEN  (*1130,QGE,Z(BUF1),WRTREW)        
      CALL FNAME (QGE,NAME)        
      CALL WRITE (QGE,NAME,2,NOEOR)        
      DO 215 I = IELTAB,NELTAB,LENTRY        
      CALL WRITE (QGE,Z(I),1,NOEOR)        
  215 CONTINUE        
      CALL WRITE (QGE,0,0,EOR)        
      CALL CLOSE (QGE,CLS)        
C        
C     OPEN EST AND PROCESS EST ELEMENT DATA OF ONLY THE HBDY ELEMENTS   
C     WHOSE ELEMENT ID-S ARE IN THE RADLST.  I.E. NOW IN THE RDLST TABLE
C        
      FILE = EST        
      CALL GOPEN (EST,Z(BUF1),RDREW)        
      GO TO 230        
C        
C     LOCATE HBDY ELEMENT TYPE RECORD        
C        
  220 CALL FWDREC (*1110,EST)        
C        
C     READ ELEMENT TYPE        
C        
  230 CALL READ (*300,*1120,EST,ELTYPE,1,NOEOR,WORDS)        
      IF (ELTYPE .NE. HBDYTP) GO TO 220        
C        
C     NOW POSITIONED TO READ EST DATA FOR HBDY ELEMENT.        
C        
      J = (ELTYPE-1)*INCR        
      ESTWDS = ELEM(J+12)        
      LOST = 0        
C        
C     READ EST FOR ONE ELEMENT        
C        
  240 CALL READ (*1110,*300,EST,ECPT,ESTWDS,NOEOR,WORDS)        
C        
C     FIND ID IN LIST        
C        
      DO 250 I = IELTAB,NELTAB,LENTRY        
      IF (ECPT(1) .EQ. Z(I)) GO TO 260        
  250 CONTINUE        
      GO TO 240        
C        
C     ELEMENT ID IS IN LIST        
C        
  260 CALL HBDY (ECPT,ECPT,1,RDATA,IDATA)        
C        
C     ON RETURN TAKE ELEMENT OUTPUTS AND PLANT THEM IN ALL ENTRIES      
C     HAVING THIS SAME ID.        
C        
      IADD = 4*PRECIS + 7        
      DO 290 J = IELTAB,NELTAB,LENTRY        
      IF (ECPT(1) .NE. Z(J)) GO TO 290        
C        
C     CHECK TO SEE IF SUM FA/A EQUALS 1.0 FOR THIS ELEMENT.        
C        
      IF (RDATA(2) .GT. 1.0E-10) GO TO 261        
      CHECK = 9999999.        
      GO TO 263        
  261 CHECK = RZ(J+3)/RDATA(2)        
      IF (MYRADM.EQ.1 .OR. MYRADM.EQ.2) CHECK = CHECK/RDATA(3)        
      IF (CHECK .GT. 0.99) GO TO 262        
      LOST = LOST + 1        
  262 IF (CHECK .LT. 1.01) GO TO 266        
  263 WRITE  (OUTPT,264) UFM,Z(J),CHECK,RDATA(2)        
  264 FORMAT (A23,' 2360, TOTAL VIEW FACTOR (FA/A), FOR ELEMENT',I9,    
     1       ' IS',1P,E14.6,', (ELEMENT AREA IS ',1P,E14.5,').')        
      NOGO = .TRUE.        
  266 IF (CHECK.LT.1.01 .AND. RADCHK.NE.0) WRITE (OUTPT,267) UIM,Z(J),  
     1                                     CHECK,RDATA(2)        
  267 FORMAT (A29,' 2360, TOTAL VIEW FACTOR (FA/A), FOR ELEMENT',I9,    
     1       ' IS ',1P,E14.6,', (ELEMENT AREA IS ',1P,E14.5,')')        
      Z(J  ) = IDATA(1)        
      Z(J+1) = IDATA(2)        
      Z(J+2) = IDATA(3)        
      Z(J+3) = IDATA(4)        
      Z(J+4) = IDATA(5)        
      Z(J+5) = IDATA(6)        
      Z(J+6) = IDATA(7)        
      Z(J+7) = IDATA(8)        
      IF (DOUBLE) GO TO 270        
      RZ(J+ 8) = RDATA( 9)        
      RZ(J+ 9) = RDATA(10)        
      RZ(J+10) = RDATA(11)        
      RZ(J+11) = RDATA(12)        
      GO TO 280        
  270 DX = J/2 + 1        
      DZ(DX+4) = RDATA( 9)        
      DZ(DX+5) = RDATA(10)        
      DZ(DX+6) = RDATA(11)        
      DZ(DX+7) = RDATA(12)        
  280 Z(J) = -Z(J)        
  290 CONTINUE        
      GO TO 240        
C        
C     ALL ELEMENTS PROCESSED.        
C        
  300 CALL CLOSE (EST,CLSREW)        
      IF (LOST .GT. 0) WRITE (OUTPT,302) UIM,LOST        
  302 FORMAT (A29,' 2361, ',I4,' ELEMENTS HAVE A TOTAL VIEW FACTOR (FA',
     1       '/A) LESS THAN 0.99 , ENERGY MAY BE LOST TO SPACE.')       
C        
C     CHECK TO SEE IF ALL ELEMENTS WERE PROCESSED.        
C        
C/////        
C     CALL BUG (4HELTB ,270,Z(IELTAB),NELTAB-IELTAB+1)        
C/////        
      DO 340 I = IELTAB,NELTAB,LENTRY        
      IF (Z(I)) 310,310,320        
  310 Z(I) = -Z(I)        
      GO TO 340        
  320 NOGO = .TRUE.        
      WRITE  (OUTPT,330) UFM,Z(I)        
  330 FORMAT (A23,' 3073, NO -HBDY- ELEMENT SUMMARY DATA IS PRESENT ',  
     1       'FOR ELEMENT ID =',I9, /5X,        
     2       'WHICH APPEARS ON A -RADLST- BULK DATA CARD.')        
  340 CONTINUE        
      IF (NOGO) CALL MESAGE (-61,0,0)        
      IF (MYRADM.EQ.1 .OR. MYRADM.EQ.2) GO TO 345        
C        
C     FORMATION OF THE Y MATRIX.  MATRIX F IS STORED ON SCRATCH 1       
C        
C         Y    = -F  (1.0 - E )  +  A        
C          IJ      IJ        J       I        
C        
C         A  IS ADDED IN ONLY TO THE DIAGONAL TERMS I.E. I = J        
C          I        
C        
C     MATRIX Y WILL BE STORED ON SCRATCH 2.        
C        
C        
C     OPEN SCRATCH 1 FOR MATRIX F COLUMN UNPACKING.        
C        
      CALL GOPEN (SCRT1,Z(BUF1),RDREW)        
C        
C     OPEN SCRATCH 2 FOR MATRIX Y COLUMN PACKING        
C        
      CALL GOPEN  (SCRT2,Z(BUF2),WRTREW)        
      CALL MAKMCB (MCB2,SCRT2,NE,SQR,PRECIS)        
C        
C     SET UP VECTOR CORE (INSURE EVEN BOUNDARY)        
C        
  345 ICOL = MOD(NELTAB,2) + NELTAB + 1        
      RCOL = ICOL        
      DCOL = ICOL/2 + 1        
      NCOL = ICOL + PRECIS*NE - 1        
      IF (NCOL .GT. CORE) CALL MESAGE (-8,0,SUBR)        
      IF (MYRADM.EQ.1 .OR. MYRADM.EQ.2) GO TO 465        
      MELTAB = IELTAB - LENTRY - 1        
C        
C     SETUP /PACKX/ FOR PACKING COLUMNS OF Y (SCRATCH 2)        
C        
      PKIN   = PRECIS        
      PKOUT  = PRECIS        
      PKIROW = 1        
      PKNROW = NE        
      PKINCR = 1        
C        
C     SETUP /UNPAKX/ FOR UNPACKING COLUMNS OF F (SCRATCH 1)        
C        
      UNOUT  = PRECIS        
      UNIROW = 1        
      UNNROW = NE        
      UNINCR = 1        
      DO 430 I = 1,NE        
      MELTAB = MELTAB + LENTRY        
      RX = RCOL        
      DX = DCOL        
C        
C     UNPACK A COLUMN OF F INTO CORE.        
C        
      CALL UNPACK (*350,SCRT1,Z(ICOL))        
      GO TO 370        
  350 DO 360 J = ICOL,NCOL        
      Z(J) = 0        
  360 CONTINUE        
C        
C     COMPUTE THE Y-COLUMN        
C        
  370 DO 390 IROW = 1,NE        
      IF (DOUBLE) GO TO 380        
C        
C     REAL COMPUTATION        
C        
      RZ(RX) = -RZ(RX)*(1.0E0 - RZ(MELTAB+3))        
      IF (IROW .EQ. I) RZ(RX) = RZ(RX) + RZ(MELTAB+2)        
      RX = RX + 1        
      GO TO 390        
C        
C     DOUBLE PRECISION COMPUTATION        
C        
  380 DZ(DX) = -DZ(DX)*(1.0D0 - DBLE(RZ(MELTAB+3)))        
      IF (IROW .EQ. I) DZ(DX) = DZ(DX) + DBLE(RZ(MELTAB+2))        
      DX = DX + 1        
  390 CONTINUE        
C        
C     PACK COLUMN OUT        
C        
      MCBSAV  = MCB2(6)        
      MCB2(6) = 0        
      CALL PACK (Z(ICOL),SCRT2,MCB2)        
      IF (MCB2(6)) 400,400,420        
  400 NOGO = .TRUE.        
      WRITE  (OUTPT,410) UFM,I        
  410 FORMAT (A23,' 3074, COLUMN',I9,' OF THE Y MATRIX IS NULL.')       
  420 MCB2(6) = MAX0(MCB2(6),MCBSAV)        
C        
  430 CONTINUE        
      IF (NOGO) CALL MESAGE (-61,0,SUBR)        
      CALL CLOSE (SCRT1,CLSREW)        
      CALL WRTTRL (MCB2)        
      CALL CLOSE (SCRT2,CLSREW)        
C/////        
C     CALL DMPFIL (-SCRT2,Z(ICOL),CORE-ICOL-1)        
C     CALL BUG (10HY-MATRIX    ,400,0,1)        
C/////        
C        
C     NOW SOLVING FOR MATRIX X ON SCRATCH-3        
C        
C     (Y) (X) = (F)        
C        
C     F IS ON SCRATCH 1        
C     Y IS ON SCRATCH 2        
C        
C        
C     SETUP /DCOMPX/        
C        
      IA(1) = SCRT2        
      IL(1) = 201        
      IU(1) = 203        
      IL(5) = PRECIS        
      ISR1  = SCRT4        
      ISR2  = SCRT5        
      ISR3  = SCRT6        
      CALL RDTRL (IA)        
      NZZ   = KORSZ(Z(ICOL))        
      IB    = 0        
      IBBAR = 0        
      CALL DECOMP (*440,Z(ICOL),Z(ICOL),Z(ICOL))        
      GO TO 460        
  440 WRITE  (OUTPT,450) UFM        
  450 FORMAT (A23,' 3075, INTERMEDIATE MATRIX Y IS SINGULAR.')        
      CALL MESAGE (-61,0,SUBR)        
C        
C     SETUP /GFBSX/        
C        
  460 JL(5) = IL(5)        
      JU(7) = IU(7)        
      JL(1) = 201        
      JU(1) = 203        
      JB(1) = SCRT1        
      JX(1) = SCRT3        
      IPR   = PRECIS        
C//// WHAT ABOUT IDET        
      ISGN  = 1        
      NZZZ  = NZZ        
      JL(3) = NE        
      JX(5) = PRECIS        
      CALL RDTRL (JB(1))        
      CALL GFBS (Z(ICOL),Z(ICOL))        
      JX(3) = NE        
      JX(4) = SQR        
      CALL WRTTRL (JX)        
C/////        
C     CALL DMPFIL (-SCRT3,Z(ICOL),CORE-ICOL-1)        
C     CALL BUG (10HX-MATRIX     ,438,0,1)        
C/////        
C        
C     FORMATION OF THE R MATRIX (TO BE STORED ON SCRATCH 1)        
C        
C          R    =(-SIGMA*E *A *E *X  ) + (SIGMA*E *A )        
C           IJ            J  I  I  IJ            J  I        
C        
C     (TERM2 IS ADDED IN ONLY WHEN I = J)        
C        
C     IF MYRADM = 1 OR 2    , RADMTX MULTIPLIED BY -SIGMA IS ON SCRT3   
C     MATRIX X IS ON SCRATCH 3        
C        
C        
C     OPEN SCRATCH 3 FOR MATRIX X COLUMN UNPACKING.        
C        
  465 CALL GOPEN (SCRT3,Z(BUF3),RDREW)        
C        
C     THE FOLLOWING CARD IS NEEDED IF DIRECT SCRIPT-F INPUT IS USED     
C        
      SCRT1 = 301        
C        
C     OPEN SCRATCH 1 FOR MATRIX R COLUMN PACKING.        
C        
      FILE = SCRT1        
      CALL GOPEN  (SCRT1,Z(BUF1),WRTREW)        
      CALL MAKMCB (MCB1,SCRT1,NE,SQR,PRECIS)        
      MELTAB = IELTAB - LENTRY - 1        
C        
C     SETUP /PACKX/ FOR PACKING COLUMNS OF R (SCRATCH 1)        
C        
      PKIN   = PRECIS        
      PKOUT  = PRECIS        
      PKIROW = 1        
      PKNROW = NE        
      PKINCR = 1        
C        
C     SETUP /UNPAKX/ FOR UNPACKING COLUMNS OF X (SCRATCH 3)        
C        
      UNOUT  = PRECIS        
      UNIROW = 1        
      UNNROW = NE        
      UNINCR = 1        
C        
      IDX1 = IELTAB - LENTRY        
      DO 520 ICOLUM = 1,NE        
      DSUMFA = 0.        
      SUMFA  = 0.        
      MELTAB = MELTAB + LENTRY        
C        
C     COMPUTE CONSTANT FOR COLUMN        
C        
C     TEMP1 = SIGMA*E        
C                    J        
C        
      TEMP1 = SIGMA*RZ(MELTAB+3)        
      RX = RCOL        
      DX = DCOL        
C        
C     UNPACK A COLUMN OF X INTO CORE.        
C        
      CALL UNPACK (*470,SCRT3,Z(ICOL))        
      GO TO 490        
  470 DO 480 J = ICOL,NCOL        
      Z(J) = 0        
  480 CONTINUE        
C        
C     COMPUTE THE R-COLUMN        
C        
  490 IDX2 = IDX1        
      DO 510 IROW = 1,NE        
      IDX2 = IDX2 + LENTRY        
      IF (DOUBLE) GO TO 500        
C        
C     REAL COMPUTATION.        
C        
      IF (MYRADM.EQ.1 .OR. MYRADM.EQ.2) GO TO 495        
      TEMP2  = TEMP1*RZ(IDX2+1)        
      RZ(RX) =-TEMP2*RZ(IDX2+2)*RZ(RX)        
      IF (IROW .EQ. ICOLUM) RZ(RX) = RZ(RX) + TEMP2        
  495 IF (IROW .NE. ICOLUM) SUMFA  = SUMFA  + RZ(RX)        
      RX = RX + 1        
      GO TO 510        
C        
C     DOUBLE PRECISON COMPUTATION        
C        
  500 IF (MYRADM.EQ.1 .OR. MYRADM.EQ.2) GO TO 505        
      DTEMP2 = DBLE(TEMP1)*DBLE(RZ(IDX2+1))        
      DZ(DX) =-DTEMP2*DBLE(RZ(IDX2+2))*DZ(DX)        
      IF (IROW .EQ. ICOLUM) DZ(DX) = DZ(DX) + DTEMP2        
  505 IF (IROW .NE. ICOLUM) DSUMFA = DSUMFA + DZ(DX)        
      DX = DX + 1        
C        
  510 CONTINUE        
C        
C     PACK COLUMN OF R OUT        
C        
      IF (MYRADM.NE.1 .AND. MYRADM.NE.2) GO TO 515        
      IF (DOUBLE) DZ(DX-1-NE+ICOLUM) = -DSUMFA        
      IF (.NOT.DOUBLE) RZ(ICOLUM+RX-1-NE) = -SUMFA        
  515 CALL PACK (Z(ICOL),SCRT1,MCB1)        
  520 CONTINUE        
      CALL WRTTRL (MCB1)        
      CALL CLOSE (SCRT1,CLSREW)        
      CALL CLOSE (SCRT3,CLSREW)        
C/////        
C     CALL DMPFIL (-SCRT1,Z(ICOL),CORE-ICOL-1)        
C     CALL BUG (10HR-MATRIX    ,490,0,1)        
C/////        
C        
C     ALL OF THE HBDY ELEMENTS OF THE RADLST HAVE        
C     HAD THEIR G TERMS COMPUTED, THESE G TERMS MAY BE INSERTED INTO    
C     THE FULL MATRIX G.        
C        
C     GOING THROUGH THE RADLST TABLE WE HAVE EACH ELEMENT ENTRY FORMING 
C     A COLUMN OF G WITH THE G TERMS OF THE RESPECTIVE ENTRY BEING      
C     ENTERED INTO THE COLUMN AT THE SIL LOCATIONS.  (THE SILS WERE     
C     PLACED IN THE RADLST ENTRY EARLIER)        
C        
C        
C     AS THE X MATRIX STORED ON SCRATCH 3 IS NO LONGER NEEDED        
C     WE WILL USE SCRATCH 3 FOR THE G MATRIX NOW.        
C        
      CALL GOPEN  (SCRT3,Z(BUF3),WRTREW)        
      CALL MAKMCB (MCB3,SCRT3,LUSET,2,PRECIS)        
C        
C     LOOP ON THE RADLST TABLE        
C        
      DO 600 I = IELTAB,NELTAB,LENTRY        
C        
C     BEGIN PACKING A COLUMN OUT        
C        
      CALL BLDPK (PRECIS,PRECIS,SCRT3,0,0)        
C        
C     PACK 1 TO 4 TERMS OUT.        
C        
      I1 = I + 4        
      I2 = I + 7        
      DO 580 J = 1,4        
C        
C     PICKING THE SMALLEST SIL NOT ZERO FOR THE NEXT TERM OUT        
C        
      ISIL = 0        
      DO 560 L = I1,I2        
      IF (Z(L)) 560,560,530        
  530 IF (ISIL) 550,550,540        
  540 IF (Z(L)-ISIL) 550,550,560        
  550 ISIL = Z(L)        
      K = L        
  560 CONTINUE        
C        
C     ZERO SIL IMPLYS OUT OF VALUES        
C        
      IF (ISIL) 590,590,570        
C        
C     PACK OUT TERM  (MAY BE SINGLE OR DOUBLE PRECISON)        
C        
  570 IROW = Z(K)        
      Z(K) = 0        
C        
C     RESET K TO GIJ TERM PTR.        
C        
      KK = K + 4        
      IF (DOUBLE) KK = KK + K - I1        
      AO(1) = RZ(KK  )        
      AO(2) = RZ(KK+1)        
      CALL ZBLPKI        
  580 CONTINUE        
C        
C     COMPLETE THE COLUMN        
C        
  590 CALL BLDPKN (SCRT3,0,MCB3)        
  600 CONTINUE        
C        
C     G MATRIX IS COMPLETE ON SCRATCH 3.        
C        
      CALL WRTTRL (MCB3)        
      CALL CLOSE  (SCRT3,CLSREW)        
C/////        
C     CALL DMPFIL (-SCRT3,Z(ICOL),CORE-ICOL-1)        
C     CALL BUG (10HG-MATRIX     ,570,0,1)        
C/////        
C        
C     FORM OUTPUT MATRIX  (Q  ) = (G)(R )        
C                           GE         E        
C        
C        
C     ALL CORE AT THIS POINT IS AVAILABLE THUS OPEN CORE FOR SSG2B      
C     WHICH IS IN /SSGB2/ MAY BE AT THE SAME LEVEL AS        
C     /RMGZZZ/.  SSG2B IS THE DRIVER FOR MPYAD.        
C        
      CALL SSG2B (SCRT3,SCRT1,0,SCRT5,0,PRECIS,1,SCRT2)        
C        
C                                        T        
C     FORM OUTPUT MATRIX  (R  ) = (Q  )(G )        
C                           GG      GE        
C        
C        
C     THE MATRIX G IS FIRST TRANSPOSED.        
C        
C     MATRIX G IS ON SCRATCH-3.  MATRIX G TRANSPOSE WILL BE ON SCRATCH-2
C        
C     OPEN CORE /DTRANX/ FOR TRANP1 MAY BE AT SAME LEVEL AS /RMGZZZ/.   
C        
      CALL TRANP1 (SCRT3,SCRT2,4,SCRT4,SCRT6,SCRT1,RGG,0,0,0,0)        
C/////        
C     CALL DMPFIL (-SCRT2,Z(ICOL),CORE-ICOL-1)        
C     CALL BUG (10HG-TRANSP    ,570,0,1)        
C/////        
C        
C     SSG2B MAY BE CALLED NOW TO COMPUTE (R  )        
C                                          GG        
C        
      CALL SSG2B (SCRT5,SCRT2,0,RGG,0,PRECIS,1,SCRT1)        
C        
C     QGE WAS PLACED ON SCRT5.  NOW COPY IT TO QGE (WHERE THE HEADER    
C     RECORD HAS BEEN SPECIALLY PREPARED EARLIER) .        
C        
      FILE = QGE        
      CALL OPEN (*1130,QGE,Z(BUF1),WRT)        
      FILE = SCRT5        
      CALL GOPEN  (SCRT5,Z(BUF2),RDREW)        
      CALL CPYFIL (SCRT5,QGE,Z,CORE,ICOUNT)        
      MCB(1) = SCRT5        
      CALL RDTRL (MCB)        
      MCB(1) = QGE        
      CALL WRTTRL (MCB)        
      CALL CLOSE (SCRT5,CLSREW)        
      CALL CLOSE (QGE,CLSREW)        
C        
C                    1      3        
C     FORM  S   = 4(U  + T )  THIS IS ACTUALLY A DIAGONAL MATRIX.       
C            GG      G    A        
C        
C     NOW ALLOCATE S   DIAGONAL MATRIX SPACE AND STORE -TABS- EVERYWHERE
C                   GG        
C        
C        
      ISGG = 1        
      NSGG = PRECIS*LUSET        
      IF (NSGG .GT. CORE) CALL MESAGE (-8,0,SUBR)        
      IF (DOUBLE) GO TO 620        
C        
C     REAL VECTOR        
C        
      DO 610 I = ISGG,NSGG        
      RZ(I) = TABS        
  610 CONTINUE        
      GO TO 640        
C        
C     DOUBLE PRECISION VECTOR        
C        
  620 DX = ISGG/2 + 1        
      NDX = DX + LUSET - 1        
      DO 630 I = DX,NDX        
      DZ(I) = TABS        
  630 CONTINUE        
C        
C     IF -TSET- IS SPECIFIED THEN THAT SET OF TEMPERATURES IS ADDED TO  
C     THE UG VECTOR IN CORE.        
C        
  640 IF (TSET) 900,900,650        
C        
C     TSET IS REQUESTED        
C        
  650 FILE = GPTT        
      CALL OPEN (*1130,GPTT,Z(BUF1),RDREW)        
C        
C     DETERMINE NUMBER OF RECORDS IN ELEMENT TEMPERATURE SECTION TO     
C     SKIP OVER. (FIRST SKIP THE NAME IN HEADER)        
C        
      CALL READ (*1110,*1120,GPTT,BUF,2,NOEOR,FLAG)        
C        
C     LOOK FOR REQUESTED TSET POINTERS AND REPOSITION GPTT.        
C        
      NUMBER =  0        
      NUMTST = -1        
  660 CALL READ (*1110,*670,GPTT,BUF,3,NOEOR,FLAG)        
      IF (BUF(3) .GT. NUMBER) NUMBER = BUF(3)        
      IF (TSET .NE. BUF(1)) GO TO 660        
C        
C     BUF(1)=SET-ID, BUF(2)=-1 OR DEFAULT TEMP, BUF(3)=GPTT DATA RECORD.
C        
      DEFALT = RBUF(2)        
      NUMTST = BUF(3)        
      GO TO 660        
C        
C     CHECK FOR TSET NOT FOUND.        
C        
  670 IF (NUMTST .EQ. -1) GO TO 1170        
C        
C     ADD SKIP COUNTS (EL. RECORDS + DUPE HEADER + TEMP SET -1)        
C        
      NUMBER = NUMBER + NUMTST        
C        
C     NO NEED TO DO FURTHER I/O IF TSET IS ALL DEFAULT TEMPS.        
C        
      IF (NUMTST .EQ. 0) NUMBER = 0        
      IF (NUMBER) 740,740,720        
  720 DO 730 I = 1,NUMBER        
      CALL FWDREC (*1110,GPTT)        
  730 CONTINUE        
C        
C     TEMPERATURE DATA IS IN PAIRS OF INTERNAL ID AND TEMPERATURE.      
C        
C        
C     AT THIS POINT THE GRID POINT TEMPERATUE DATA IS ADDED INTO THE SGG
C     DIAGONAL HELD IN CORE.        
C        
  740 NSIL = 1        
      RX = ISGG - 1        
      DX = ISGG/2        
      ASSIGN 750 TO IRETRN        
      IF (NUMBER) 790,790,750        
  750 CALL READ (*1110,*870,GPTT,BUF,2,NOEOR,FLAG)        
  760 IF (BUF(1)-NSIL) 770,820,800        
  770 WRITE  (OUTPT,780) SFM        
  780 FORMAT (A25,' 3076, GPTT DATA IS NOT IN SORT BY INTERNAL ID.')    
      CALL MESAGE (-61,0,SUBR)        
C        
C     ADD DEFAULT TEMPERATURE (IF ONE EXISTS) TO THOSE POINTS NOT HAVING
C     AN EXPLICIT TEMPERATURE DEFINED.        
C        
  790 BUF(1) = LUSET + 1        
  800 IF (IDEFLT .NE. -1) GO TO 830        
      WRITE  (OUTPT,810) UFM,NSIL        
  810 FORMAT (A23,' 3077, THERE IS NO GRID POINT TEMPERATURE DATA OR ', 
     1       'DEFAULT TEMPERATURE DATA FOR SIL POINT',I9, /5X,        
     2       'AND POSSIBLY OTHER POINTS.')        
      CALL MESAGE (-61,0,SUBR)        
  820 VALUE = RBUF(2)        
      GO TO 840        
  830 VALUE = DEFALT        
      ASSIGN 880 TO IRETRN        
      ISIL = NSIL        
      KSIL = BUF(1) - 1        
      NSIL = BUF(1)        
      GO TO 845        
  840 ISIL = NSIL        
      KSIL = BUF(1)        
      NSIL = BUF(1) + 1        
  845 DO 860 I = ISIL,KSIL        
      IF (I .GT. LUSET) GO TO 890        
      IF (DOUBLE) GO TO 850        
      RX = RX + 1        
      RZ(RX) = RZ(RX) + VALUE        
      GO TO 860        
  850 DX = DX + 1        
      DZ(DX) = DZ(DX) + DBLE(VALUE)        
  860 CONTINUE        
      GO TO IRETRN, (750,890,880)        
  870 ASSIGN 890 TO IRETRN        
      BUF(1) = LUSET        
      VALUE  = DEFALT        
      GO TO 840        
  880 ASSIGN 750 TO IRETRN        
      GO TO 760        
C        
C     ALL TEMPERATURE DATA HAS BEEN ADDED IN.        
C        
  890 CALL CLOSE (GPTT,CLSREW)        
C/////        
C     CALL BUG (4HTMPS,890,Z(ISGG),NSGG-ISGG+1)        
C/////        
C        
C     NOW CUBE EACH TERM AND THEN MULTIPLY EACH TERM BY 4.0        
C        
  900 IF (DOUBLE) GO TO 920        
C        
C     REAL COMPUTATION        
C        
      DO 910 I = ISGG,NSGG        
      RZ(I) = 4.0*(RZ(I)**3)        
  910 CONTINUE        
      GO TO 940        
C        
C     DOUBLE PRECISION COMPUTATION        
C        
  920 DX  = ISGG/2 + 1        
      NDX = DX + LUSET - 1        
      DO 930 I = DX,NDX        
      DZ(I) = 4.0D0*(DZ(I)**3)        
  930 CONTINUE        
C        
C     ALLOCATION OF CORE FOR A COLUMN OF MATRIX RGG.        
C        
  940 IRGG  = NSGG + 1        
      NRGG  = IRGG + PRECIS*LUSET - 1        
      DIRGG = IRGG/2 + 1        
      DNRGG = DIRGG + LUSET - 1        
      IF (NRGG .GT. CORE) CALL MESAGE (-8,0,SUBR)        
C        
C                                   X        
C     FORM OUTPUT MATRIX  (K  ) = (K  ) + (R  )(S  )        
C                           GG      GG      GG   GG        
C        
C        
C     THE DIAGONAL MATRIX (S  ) RESIDES IN CORE FROM Z(ISGG) TO Z(NSGG) 
C                           GG        
C        
C     Z(IRGG) TO Z(NRGG) WILL BE USED TO HOLD A COLUMN OF R.        
C        
C       X        
C     (K  ) WILL BE UNPACKED INCREMENTALLY AND ADDED INTO THE COLUMN    
C       GG        
C        
C     OF R, AFTER THAT COLUMN OF R HAS BEEN MULTIPLIED BY THE RESPECTIVE
C        
C     DIAGONAL ELEMENT OF (S  ).        
C                           GG        
C        
C/////        
C     CALL BUG (4HSGG  ,829,Z(ISGG),NSGG-ISGG+1)        
C/////        
      CALL GOPEN (RGG,Z(BUF1),RDREW)        
      CALL GOPEN (KGGX,Z(BUF2),RDREW)        
      CALL GOPEN (KGG,Z(BUF3),WRTREW)        
      CALL MAKMCB (MCB1,KGG,LUSET,SQR,PRECIS)        
C        
C     SET UP /PACKX/ FOR PACKING COLUMN OF KGG OUT.        
C        
      PKIN   = PRECIS        
      PKOUT  = PRECIS        
      PKIROW = 1        
      PKNROW = LUSET        
      PKINCR = 1        
      RX = ISGG - 1        
      DX = ISGG/2        
C        
C     LOOP THROUGH -LUSET- COLUMNS TO BE OUTPUT.        
C        
      DO 1080 I = 1,LUSET        
      IF (DOUBLE) GO TO 950        
      RX = RX + 1        
      VALUE = RZ(RX)        
      GO TO 960        
  950 DX = DX + 1        
      DVALUE = DZ(DX)        
C        
C     UNPACK A COLUMN OF R        
C        
  960 DO 980 J = IRGG,NRGG        
      Z(J) = 0        
  980 CONTINUE        
C        
C     -UNPACK- CAN NOT BE USED HERE DUE TO UNPACKING OF KGGX BELOW.     
C        
      CALL INTPK  (*990,RGG,BLOCK2,PRECIS,1)        
  984 CALL INTPKI (AI,IIROW,RGG,BLOCK2,IEOL)        
      IF (DOUBLE) GO TO 985        
      K = IRGG - 1 + IIROW        
      RZ(K) = RZ(K) + AI(1)        
      IF (IEOL) 984,984,990        
  985 K = DIRGG - 1 + IIROW        
      DZ(K) = DZ(K) + DI(1)        
      IF (IEOL) 984,984,990        
C        
C     MULTIPLY RGG COLUMN BY DIAGONAL ELEMENT OF SGG.        
C        
  990 IF (DOUBLE) GO TO 1010        
C        
C     REAL COMPUTATION        
C        
      DO 1000 J = IRGG,NRGG        
      RZ(J) = RZ(J)*VALUE        
 1000 CONTINUE        
      GO TO 1030        
C        
C     DOUBLE PRECISION COMPUTATION        
C        
 1010 DO 1020 J = DIRGG,DNRGG        
      DZ(J) = DZ(J)*DVALUE        
 1020 CONTINUE        
C        
C     INCREMENTAL UNPACK OF A COLUMN OF KGGX.        
C     ADD TO MODIFIED COLUMN OF RGG IN CORE, AND THEN        
C     BLAST PACK OUT FURTHER MODIFIED COLUMN AS A COLUMN OF KGG.        
C        
C     START UNPACKING COLUMN OF KGGX        
C        
 1030 CALL INTPK  (*1070,KGGX,BLOCK,PRECIS,1)        
 1040 CALL INTPKI (AI,IIROW,KGGX,BLOCK,IEOL)        
C        
C     ADD VALUE IN        
C        
      IF (IIROW .GT. LUSET) GO TO 1050        
      IF (DOUBLE) GO TO 1060        
C        
C     REAL ADD IN        
C        
      K = IRGG - 1 + IIROW        
      RZ(K) = RZ(K) + AI(1)        
 1050 IF (IEOL) 1040,1040,1070        
C        
C     DOUBLE PRECISION ADD IN        
C        
 1060 K = DIRGG - 1 + IIROW        
      DZ(K) = DZ(K) + DI(1)        
      IF (IEOL) 1040,1040,1070        
C        
C     PACK OUT COMPLETED COLUMN.        
C        
 1070 CALL PACK (Z(IRGG),KGG,MCB1)        
 1080 CONTINUE        
      CALL WRTTRL (MCB1)        
      CALL CLOSE (KGG,CLSREW )        
      CALL CLOSE (KGGX,CLSREW)        
      CALL CLOSE (RGG,CLSREW )        
C        
C     ALL PROCESSING COMPLETED.        
C        
      NLR = +1        
      RETURN        
 1090 CALL CLOSE (MATPOL,CLSREW)        
 1100 NLR = -1        
      RETURN        
C        
C     ERROR CONDITIONS        
C        
C        
C     END OF FILE        
C        
 1110 J = -2        
      GO TO 1140        
C        
C     END OF RECORD        
C        
 1120 J = -3        
      GO TO 1140        
C        
C     UNDEFINED FILE        
C        
 1130 J = -1        
 1140 CALL MESAGE (J,FILE,SUBR)        
C        
C     GPTT DATA MISSING FOR SET -TSET-.        
C        
 1170 WRITE  (OUTPT,1180) UFM,TSET        
 1180 FORMAT (A23,' 3078, NO GPTT DATA IS PRESENT FOR TEMPERATURE SET ',
     1        I8,1H.)        
      CALL MESAGE (-61,0,SUBR)        
C        
C     NO HBDY ELEMENTS        
C        
C1190 WRITE  (OUTPT,1200) UFM        
C1200 FORMAT (A23,' 3079, THERE ARE NO -HBDY- ELEMENTS PRESENT.')       
C     CALL MESAGE (-61,0,SUBR)        
C        
      RETURN        
      END        
