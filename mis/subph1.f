      SUBROUTINE SUBPH1        
C        
C     THIS MODULE PERFORMS THE PHASE 1 CONVERSION OF NASTRAN DATA BLOCK 
C     TABLES TO THEIR EQUIVALENT SOF ITEMS        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,ANDF,ORF        
      LOGICAL         LAST        
      INTEGER         BUF(10),TEMP(10),TYPE,SUB1(2),ICODE(32),MCB(7),   
     1                LTYPE1(5),LTYPE2(5),LTYPE3(5)        
      REAL            RZ(12)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /SYSTEM/ BSIZE,OUT        
      COMMON /BLANK / DRY,NAME(2),PSET,PITM        
      COMMON /TWO   / TWO(32)        
CZZ   COMMON /ZZSUBP/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (RZ(1),Z(1))        
      DATA    CASE  , EQEX,USET,BGPD,CSTM,GPSE,ELSE,SCRT/        
     1        101   , 102 ,103 ,104 ,105 ,106 ,107 ,301 /        
      DATA    EQSS  / 4HEQSS/,ICSTM/4HCSTM/,LODS /4HLODS/,PLTS/4HPLTS/, 
     1        BGSS  / 4HBGSS/        
      DATA    IUA   / 25    /, SUB1/4HSUBP,4HH1   /        
      DATA    LTYPE1/ 4HEXTE,4HRNAL,4H STA,4HTIC ,4HLOAD/        
      DATA    LTYPE2/ 4H    ,4H    ,4HTHER,4HMAL ,4HLOAD/        
      DATA    LTYPE3/ 4H ELE,4HMENT,4H DEF,4HORMA,4HTION/        
      DATA    LOAP  , PAPP  /4HLOAP,4HPAPP/,  I0 / 0    /        
C        
      MUA = TWO(IUA)        
C        
C     INITIALLIZE CORE, ETC        
C        
      IF (DRY .EQ. 0) RETURN        
      NC = KORSZ(Z(1))        
      B1 = NC - BSIZE + 1        
C        
C     OPEN SCRATCH FILE TO WRITE CONVERTED DATA        
C        
      B2   =  B1  - BSIZE        
      B3   =  B2  - BSIZE        
      BUF1 =  B3  - BSIZE        
      BUF2 =  BUF1- BSIZE        
      NZ   =  BUF2- 1        
C        
C     TEST FOR CORE        
C        
      IF (NZ .LE. 0) GO TO 4010        
C        
      CALL SOFOPN (Z(B1),Z(B2),Z(B3))        
C        
C     EQSS GENERATION        
C        
      FILE = USET        
      CALL OPEN (*5001,USET,Z(BUF1),0)        
      CALL FWDREC (*5001,USET)        
C        
C     READ USET INTO CORE        
C        
      CALL READ (*5001,*20,USET,Z(1),NZ,0,NU)        
C        
C     RAN OUT OF CORE        
C        
      CALL CLOSE (USET,1)        
      GO TO 4010        
C        
 20   CALL CLOSE (USET,1)        
C        
C     FLAG ELEMENTS IN UA SET  (SET OTHERS TO ZERO)        
C        
      DO 40 I = 1,NU        
      IF (ANDF(MUA,Z(I)) .EQ. 0) GO TO 30        
      Z(I) = 1        
      GO TO 40        
 30   Z(I) = 0        
 40   CONTINUE        
C        
C     READ  SECOND RECORD OF EQEXIN - CONTAINS  G AND SIL PAIRS        
C        
      FILE = EQEX        
      CALL OPEN (*5001,EQEX,Z(BUF1),0)        
      CALL FWDREC (*5001,EQEX)        
      CALL FWDREC (*5001,EQEX)        
C        
C     OPEN SCRATCH FILE TO WRITE CONVERTED DATA        
C        
      CALL OPEN (*5001,SCRT,Z(BUF2),1)        
C        
C     LOOP ON GRID POINTS        
C        
      K = 0        
      I = 0        
C        
 50   CALL READ (*5001,*110,EQEX,BUF,2,0,NWDS)        
      C = 0        
      I = I + 1        
      ISIL = BUF(2)/10        
      TYPE = BUF(2) - 10*ISIL        
      IF (TYPE-2) 60,80,4020        
C        
C     GRID POINT, DETERMINE UA COMPONENTS, PUT IN BINARY FORM        
C        
 60   DO 70 J = 1,6        
      IU = ISIL + J - 1        
      IF (Z(IU) .EQ. 0) GO TO 70        
      C  = ORF(C,LSHIFT(1,J-1))        
 70   CONTINUE        
      GO TO 90        
C        
C     SCALAR POINT        
C        
 80   IF (Z(ISIL) .NE. 0) C = 1        
C        
C     WRITE OUT G AND C        
C        
 90   IF (C .EQ. 0) GO TO 100        
      BUF(2) = C        
      CALL WRITE (SCRT,BUF,2,0)        
      K = K + 1        
 100  CONTINUE        
      GO TO 50        
C        
 110  MCB(1) = EQEX        
      CALL RDTRL (MCB)        
      NPTS = MCB(2)        
      CALL REWIND (EQEX)        
      CALL CLOSE (SCRT,1)        
      IF (NPTS*2 .GT. NZ) GO TO 4010        
C        
C     READ FIRST RECORD OF EQEXIN - GET G AND IOLD        
C     READ SCRATCH - GET G AND C        
C     BUILD TABLE IN CORE        
C        
      FILE = EQEX        
      CALL FWDREC (*5001,EQEX)        
      FILE = SCRT        
      CALL OPEN (*5001,SCRT,Z(BUF2),0)        
C        
C     SET CORE TO ZERO        
C        
      DO 150 I = 1,NPTS        
      IZP = 2*I        
      Z(IZP  ) = 0        
      Z(IZP-1) = 0        
 150  CONTINUE        
      NNEW = K        
C        
C     LOOP ON POINTS IN SCRATCH FILE, STORE C IN ITH WORD OF ENTRY      
C     POSITION OF ENTRY IS THE INTERNAL SEQUENCE        
C        
      IF (K .LE. 0) GO TO 210        
      DO 200 I = 1,K        
      FILE = SCRT        
      CALL READ (*5001,*210,SCRT,BUF,2,0,NWDS)        
      FILE = EQEX        
 180  CALL READ (*5001,*210,EQEX,TEMP,2,0,NWDS)        
      IF (BUF(1)-TEMP(1)) 5001,190,180        
 190  IZP = 2*TEMP(2)        
      Z(IZP) = BUF(2)        
 200  CONTINUE        
C        
C     CORE TABLE IS COMPLETE, FILL IN FIRST ENTRIES        
C        
 210  CALL CLOSE (SCRT,1)        
      CALL REWIND (EQEX)        
      K = 0        
      DO 300 I = 1,NPTS        
      IF (Z(2*I) .EQ. 0) GO TO 300        
      K = K + 1        
      Z(2*I-1) = K        
 300  CONTINUE        
C        
C     CORE NOW CONTAINS NEW IP VALUES AND C IN OLD IP POSITIONS        
C        
      FILE = EQSS        
C        
C     CHECK IF SUBSTRUCTURE EXISTS ALREADY        
C        
      CALL FWDREC (*5001,EQEX)        
      CALL SETLVL (NAME,0,TEMP,ITEST,0)        
      IF (ITEST .NE. 1) WRITE (OUT,6325) UWM,NAME        
      ITEST = 3        
      CALL SFETCH (NAME,EQSS,2,ITEST)        
      IF (ITEST .EQ. 3) GO TO 340        
      WRITE (OUT,6326) UWM,NAME,EQSS        
      GO TO 1000        
 340  BUF(1) = NAME(1)        
      BUF(2) = NAME(2)        
      BUF(3) = 1        
      BUF(4) = NNEW        
      BUF(5) = NAME(1)        
      BUF(6) = NAME(2)        
C        
      CALL SUWRT (BUF,6,2)        
C        
C     PROCESS EQSS OUTPUT-  G, IP, C - SORTED ON G        
C        
      DO 400 I = 1,NPTS        
C        
      CALL READ (*5001,*400,EQEX,TEMP,2,0,NWDS)        
C        
      IPT = TEMP(2)*2 - 1        
      IF (Z(IPT) .EQ. 0) GO TO 400        
      TEMP(2) = Z(IPT  )        
      TEMP(3) = Z(IPT+1)        
      CALL SUWRT (TEMP,3,1)        
 400  CONTINUE        
      CALL SUWRT (TEMP,0,2)        
C        
C     BUILD SIL TABLE BY COUNTING C VALUES        
C        
      NC = 0        
      IS = 1        
      DO 500 I = 1,NPTS        
      IPT = 2*I - 1        
C        
      IF (Z(IPT) .EQ. 0) GO TO 500        
      IS = IS + NC        
      Z(IPT) = IS        
C        
      CALL SUWRT (Z(IPT),2,1)        
C        
C     CALCULATE NUMBER OF COMPONENTS FOR NEXT STEP        
C        
      KCODE = Z(IPT+1)        
      CALL DECODE (KCODE,ICODE,NC)        
 500  CONTINUE        
      CALL SUWRT (0,0,2)        
      CALL SUWRT (TEMP,0,3)        
 1000 CALL CLOSE (EQEX,1)        
C        
C     BGSS GENERATION        
C        
      FILE = BGPD        
      CALL OPEN (*5001,BGPD,Z(BUF1),0)        
      CALL FWDREC (*5001,BGPD)        
      ITEST = 3        
      CALL SFETCH (NAME,BGSS,2,ITEST)        
      IF (ITEST .EQ. 3) GO TO 1100        
      WRITE (OUT,6326) UWM,NAME,BGSS        
      GO TO 2000        
 1100 CONTINUE        
C        
      BUF(1) = NAME(1)        
      BUF(2) = NAME(2)        
      BUF(3) = NNEW        
      CALL SUWRT (BUF,3,2)        
      DO 1200 I = 1,NPTS        
      CALL READ (*5001,*1200,BGPD,BUF,4,0,NWDS)        
C        
      IF (Z(2*I-1) .EQ. 0) GO TO 1200        
C        
      CALL SUWRT (BUF,4,1)        
 1200 CONTINUE        
      CALL SUWRT (0,0,2)        
      CALL SUWRT (BUF,0,3)        
 2000 CALL CLOSE (BGPD,1)        
C        
C        
C     CSTM GENERATION        
C        
C        
      CALL OPEN (*2500,CSTM,Z(BUF1),0)        
C        
C     CSTM EXISTS        
C        
      CALL FWDREC (*5001,CSTM)        
      ITEST = 3        
      CALL SFETCH (NAME,ICSTM,2,ITEST)        
      IF (ITEST .EQ. 3) GO TO 2100        
      WRITE (OUT,6326) UWM,NAME,ICSTM        
      GO TO 2400        
C        
 2100 BUF(1) = NAME(1)        
      BUF(2) = NAME(2)        
      CALL SUWRT (BUF,2,2)        
C        
C     BLAST COPY        
C        
      CALL READ (*5001,*2200,CSTM,Z(1),NZ,1,NWDS)        
      GO TO 4010        
 2200 CALL SUWRT (Z(1),NWDS,2)        
      CALL SUWRT (0,0,3)        
 2400 CALL CLOSE (CSTM,1)        
C        
C     LODS GENERATION        
C        
 2500 NLOD = 0        
C        
      CALL GOPEN (CASE,Z(BUF1),0)        
C        
      ICASE = 0        
C        
 2600 CALL READ (*2800,*2800,CASE,Z(1),9,1,NWDS)        
      ICASE = ICASE + 1        
      IF (Z(I0+4) .EQ. 0) GO TO 2610        
      WRITE (OUT,6327) UIM,NAME,ICASE,LTYPE1,Z(I0+4)        
      Z(NLOD+10) = Z(I0+4)        
      GO TO 2700        
 2610 IF (Z(I0+7) .EQ. 0) GO TO 2620        
      WRITE (OUT,6327) UIM,NAME,ICASE,LTYPE2,Z(I0+7)        
      Z(NLOD+10) = Z(I0+7)        
      GO TO 2700        
 2620 IF (Z(I0+6) .EQ. 0) GO TO 2630        
      WRITE (OUT,6327) UIM,NAME,ICASE,LTYPE3,Z(I0+6)        
      Z(NLOD+10) = Z(I0+6)        
      GO TO 2700        
 2630 Z(NLOD+10) = 0        
 2700 NLOD = NLOD + 1        
      GO TO 2600        
 2800 ITEST = 3        
      LITM  = LODS        
      IF (PITM .EQ. PAPP) LITM = LOAP        
      CALL SFETCH (NAME,LITM,2,ITEST)        
      IF (ITEST .EQ. 3) GO TO 2810        
      WRITE (OUT,6326) UWM,NAME,LITM        
      GO TO 2900        
 2810 Z(   1) = NAME(1)        
      Z(I0+2) = NAME(2)        
      Z(I0+3) = NLOD        
      Z(I0+4) = 1        
      Z(I0+5) = NAME(1)        
      Z(I0+6) = NAME(2)        
      CALL SUWRT (Z(1),6,2)        
      CALL SUWRT (NLOD,1,1)        
      CALL SUWRT (Z(I0+10),NLOD,2)        
      CALL SUWRT (Z(1),0,3)        
 2900 CALL CLOSE (CASE,1)        
C        
C     PLOT SET DATA (PLTS) GENERATION        
C        
      IF (PSET .LE. 0) GO TO 4000        
      FILE = BGPD        
      CALL GOPEN (BGPD,Z(BUF1),0)        
C        
      ITEST = 3        
      CALL SFETCH (NAME,PLTS,2,ITEST)        
      IF (ITEST .EQ. 3) GO TO 3010        
      WRITE (OUT,6326) UWM,NAME,PLTS        
      CALL CLOSE (BGPD,1)        
      GO TO 4000        
C        
 3010 BUF(1) = NAME(1)        
      BUF(2) = NAME(2)        
      BUF(3) = 1        
      BUF(4) = NAME(1)        
      BUF(5) = NAME(2)        
      CALL SUWRT (BUF,5,1)        
      DO 3012 I = 1,11        
 3012 Z(I) = 0        
      RZ( 4) = 1.0        
      RZ( 8) = 1.0        
      RZ(12) = 1.0        
      CALL SUWRT (Z,12,2)        
C        
      CALL READ (*5001,*3020,BGPD,Z(1),NZ,0,NWDS)        
      GO TO 4010        
 3020 CALL SUWRT (Z,NWDS,2)        
      CALL CLOSE (BGPD,1)        
      FILE = EQEX        
      CALL GOPEN (EQEX,Z(BUF1),0)        
      CALL READ (*5001,*3030,EQEX,Z,NZ,1,NWDS)        
      GO TO 4010        
 3030 CALL SUWRT (Z,NWDS,2)        
      CALL CLOSE (EQEX,1)        
      FILE = GPSE        
      LAST = .FALSE.        
      CALL OPEN (*3500,GPSE,Z(BUF1),0)        
C        
      CALL FWDREC (*3500,GPSE)        
C        
      CALL READ (*5001,*3050,GPSE,Z(1),NZ,0,NSETS)        
      GO TO 4010        
C        
C     FIND PLOT SET ID        
C        
 3050 IF (NSETS .EQ. 0) GO TO 3500        
C        
      DO 3060 I = 1,NSETS        
      IF (Z(I) .EQ. PSET) GO TO 3070        
 3060 CONTINUE        
      GO TO 3500        
 3070 IREC = I - 1        
C        
 3075 IF (IREC .EQ. 0) GO TO 3090        
C        
C     POSITION FILE TO SELECTED SET        
C        
      DO 3080 I = 1,IREC        
      CALL FWDREC (*3500,FILE)        
 3080 CONTINUE        
 3090 CALL READ (*3500,*3100,FILE,Z(1),NZ,0,NWDS)        
      GO TO 4010        
 3100 CALL SUWRT (Z(1),NWDS,2)        
      CALL CLOSE (FILE,1)        
      IF (LAST) GO TO 3300        
      LAST = .TRUE.        
      FILE = ELSE        
      CALL OPEN (*3500,ELSE,Z(BUF1),0)        
      CALL FWDREC (*3500,ELSE)        
      GO TO 3075        
C        
C     FINISHED        
C        
 3300 CALL SUWRT (Z(1),0,3)        
      GO TO 4000        
 3500 CALL CLOSE (FILE,1)        
      WRITE  (OUT,3510) UWM,PSET        
 3510 FORMAT (A25,' 6050, REQUESTED PLOT SET NO.',I8,        
     1       ' HAS NOT BEEN DEFINED')        
C        
 4000 CALL SOFCLS        
      WRITE  (OUT,6361) UIM,NAME        
 6361 FORMAT (A29,' 6361, PHASE 1 SUCCESSFULLY EXECUTED FOR ',        
     1       'SUBSTRUCTURE ',2A4)        
      RETURN        
C        
C     INSUFFICIENT CORE        
C        
 4010 WRITE  (OUT,4015) UFM,NZ        
 4015 FORMAT (A23,' 6011, INSUFFICIENT CORE TO LOAD TABLES', /5X,       
     1       'IN MODULE SUBPH1, CORE =',1I8)        
      DRY = -2        
      GO TO 6000        
C        
C     BAD GRID POINT TYPE (IE AXISYMMETRIC OR)        
C        
 4020 WRITE  (OUT,4035) UFM,BUF(1)        
 4035 FORMAT (A23,' 6013 , ILLEGAL TYPE OF POINT DEFINED FOR ',        
     1       'SUBSTRUCTURE ANALYSIS.', /5X,'POINT NUMBER =',I9)        
      GO TO 6000        
C        
C     BAD FILE        
C        
 5001 WRITE  (OUT,5005) SFM,FILE        
 5005 FORMAT (A25,' 6012, FILE =',I4,' IS PURGED OR NULL AND IS ',      
     1       'REQUIRED IN PHASE 1 SUBSTRUCTURE ANALYSIS.')        
C        
 6000 CALL SOFCLS        
      CALL MESAGE (-61,0,SUB1)        
      RETURN        
C        
C        
 6325 FORMAT (A25,' 6325, SUBSTRUCTURE PHASE 1, BASIC SUBSTRUCTURE ',   
     1       2A4,' ALREADY EXISTS ON SOF.', /32X,        
     2       'ITEMS WHICH ALREADY EXIST WILL NOT BE REGENERATED.')      
 6326 FORMAT (A25,' 6326, SUBSTRUCTURE ',2A4,', ITEM ',A4,        
     1       ' ALREADY EXISTS ON SOF.')        
 6327 FORMAT (A29,' 6327, SUBSTRUCTURE ',2A4,' SUBCASE',I9,        
     1       ' IS IDENTIFIED BY', /36X,5A4,' SET',I9,' IN LODS ITEM.',  
     2       /36X,'REFER TO THIS NUMBER ON LOADC CARDS.')        
      END        
