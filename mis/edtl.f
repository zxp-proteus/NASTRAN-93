      SUBROUTINE EDTL (NEDT,ILIST,PG)        
C        
C     THIS SUBROUTINE COMPUTES THE ELEMENT TEMPERATURE AND ENFORCED     
C     DEFORMATION LOADS        
C        
      IMPLICIT INTEGER (A-Z)        
      LOGICAL         EORFLG,ENDID,BUFFLG,RECORD        
      INTEGER         PG(7),PCOMP(2),PCOMP1(2),PCOMP2(2),ILIST(1),      
     1                IPARM(2),TLIST(1080)        
      REAL            CORE,TI        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM        
      COMMON /BLANK / NROWSP,IPARAM,COMPS        
      COMMON /SYSTEM/ KSYSTM(64)        
      COMMON /PACKX / ITYA,ITYB,II,JJ,INCUR        
CZZ   COMMON /ZZSSB1/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /XCSTM / TGB(3,3)        
      COMMON /TRANX / IDUM1(14)        
      COMMON /FPT   / TO,NSIL,NGPTT,NSTART,LCORE        
      COMMON /LOADX / LCARE,N(3),CSTM,SIL,NNN,ECPT,MPT,GPTT,EDT,IMPT,   
     1                IGPTT,IEC,NN(3),DIT,ICM        
      COMMON /TRIMEX/ MECPT(200)        
      COMMON /SGTMPD/ TI(33)        
      COMMON /MATIN / MATID,INFLAG,TEMP,STRESS,SINTH,COSTH        
      COMMON /MATOUT/ E1,G,NU,RHO,ALPHA,TO1,GE,SIGMAT,SIGMAC,SIGMAS,    
     1                SPACE(10)        
      COMMON /GPTA1 / NELEMS,LAST,INCR,NE(1)        
      COMMON /SSGETT/ ELTYPE,OLDEL,EORFLG,ENDID,BUFFLG,ITEMP,IDEFT,     
     1                IDEFM,RECORD        
      COMMON /SSGWRK/ DUM(300)        
      COMMON /COMPST/ IPCMP,NPCMP,IPCMP1,NPCMP1,IPCMP2,NPCMP2        
      EQUIVALENCE     (KSYSTM( 1),SYSBUF),(KSYSTM( 2),OUTPT ),        
     1                (KSYSTM(55),IPREC ),(KSYSTM(56),ITHRML),        
     2                (TI(7)     ,ICHECK),(TI(6)     ,IFLAG )        
      DATA    IPARM , IPGTT/ 4HEDTL,4H    ,4HGPTT   /        
      DATA    CROD  , CTUBE, CONROD, CBAR, PCOMPS   /        
     1        1     , 3    , 10    , 34  , 112      /        
      DATA    PCOMP ,        PCOMP1,       PCOMP2   /        
     1        5502  , 55,    5602, 56,     5702, 57 /        
C        
      IGPTT = IPGTT        
C        
C     CHECK IF HEAT FORMULATION        
C        
      IF (ITHRML .NE. 0) RETURN        
C        
      ITEMP = 0        
      IDEFT = NEDT        
      GO TO 10        
C        
C        
      ENTRY TEMPL (NTEMP,ILIST,PG)        
C     ============================        
C        
      IF (ITHRML .NE. 0) RETURN        
      IDEFT = 0        
      ITEMP = NTEMP        
C        
C     START SEARCH POINTERS AT ZERO        
C        
   10 ITYA  = 1        
      CALL DELSET        
      ITYB  = 1        
      IPR   = IPREC        
      IF (IPR .NE. 1) IPR = 0        
      II    = 1        
      JJ    = NROWSP        
      INCUR = 1        
      NNN   = 0        
      NOGPTT= 0        
      IDUM1(1) = 0        
      ICM   = 1        
      NOEDT = 0        
      CALL DELSET        
      LPCOMP = 0        
C        
C     SET CORE SIZE AND BUFFERS        
C        
      LCORE= KORSZ(CORE) - NROWSP        
      BUF1 = LCORE - SYSBUF - 2        
      BUF2 = BUF1  - SYSBUF - 2        
      BUF3 = BUF2  - SYSBUF - 2        
      BUF4 = BUF3  - SYSBUF - 2        
      BUF5 = BUF4  - SYSBUF - 2        
C        
C     OPEN FILES--        
C        
C     READ FILE PCOMPS INTO CORE ONLY IF PARAM COMPS = -1,        
C     INDICATING THE PRESENCE OF LAMINATED COMPOSITE ELEMENTS        
C        
      IF (COMPS .NE. -1) GO TO 25        
C        
      IPM = PCOMPS        
      CALL PRELOC (*750,CORE(BUF2),PCOMPS)        
C        
      IPCMP  = NROWSP + 1        
      IPCMP1 = IPCMP        
      NPCMP  = 0        
      NPCMP1 = 0        
      NPCMP2 = 0        
C        
      LCORE = BUF5 - NROWSP - 1        
C        
C     LOCATE PCOMP DATA AND READ INTO CORE        
C        
      CALL LOCATE (*14,CORE(BUF2),PCOMP,FLAG)        
C        
      CALL READ (*860,*12,PCOMPS,CORE(IPCMP),LCORE,0,NPCMP)        
      GO TO 820        
   12 IPCMP1 = IPCMP + NPCMP        
      LCORE  = LCORE - NPCMP        
      IF (IPCMP1 .GE. LCORE) GO TO 820        
C        
C     LOCATE PCOMP1 DATA AND READ INTO CORE        
C        
   14 CALL LOCATE (*18,CORE(BUF2),PCOMP1,FLAG)        
C        
      IPCMP1 = IPCMP + NPCMP        
      CALL READ (*20,*16,PCOMPS,CORE(IPCMP1),LCORE,0,NPCMP1)        
      GO TO 820        
   16 IPCMP2 = IPCMP1 + NPCMP1        
      LCORE  = LCORE  - NPCMP1        
      IF (IPCMP2 .GE. LCORE) GO TO 820        
C        
C     LOCATE PCOMP2 DATA AND READ INTO CORE        
C        
   18 CALL LOCATE (*20,CORE(BUF2),PCOMP2,FLAG)        
C        
      IPCMP2 = IPCMP1 + NPCMP1        
      CALL READ (*20,*20,PCOMPS,CORE(IPCMP2),LCORE,0,NPCMP2)        
      GO TO 820        
C        
   20 LPCOMP = NPCMP + NPCMP1 + NPCMP2        
C        
      LCORE = LCORE - NPCMP2        
      IF (LCORE .LE. 0) GO TO 820        
C        
      CALL CLOSE (PCOMPS,1)        
C        
C        
   25 CALL GOPEN (ECPT,CORE(BUF2),0)        
      IF (ITEMP) 30,40,30        
   30 IPM = GPTT        
      CALL OPEN (*750,GPTT,CORE(BUF3),0)        
C        
C     BRING IN MAT ETC        
C        
      CALL READ (*860,*810,GPTT,TLIST(1),  -2,0,NTLIST)        
      CALL READ (*860,*40 ,GPTT,TLIST(1),1080,1,NTLIST)        
      WRITE  (OUTPT,35) UFM        
   35 FORMAT (A23,' 4013, PROBLEM LIMITATION OF 360 TEMPERATURE SETS ', 
     1       ' HAS BEEN EXCEEDED.')        
      N1 = -37        
      GO TO 760        
   40 IF (IDEFT .NE. 0) CALL GOPEN (EDT,CORE(BUF4),0)        
      NLOOP = IDEFT + ITEMP        
      IF (IDEFT .NE. 0) LDEFM = 0        
C        
C     INITIALIZE MATERIAL ROUTINE        
C        
      IMAT  = NROWSP + LPCOMP        
      LCORE = BUF5   - IMAT        
      CALL PREMAT (CORE(IMAT+1),CORE(IMAT+1),CORE(BUF5),LCORE,NMAT,     
     1             MPT,DIT)        
      NSTART = IMAT  + NMAT        
      LCORE  = LCORE - NSTART        
      IF (LCORE .LE. 0) GO TO 820        
      IF (IDEFT .NE. 0) LDEFM = 0        
C        
      DO 720 ILLOP = 1,NLOOP        
C        
      IDEFM = ILIST(ILLOP)        
      IF (ITEMP) 75,75,70        
   70 CALL REWIND (GPTT)        
C        
   75 IF (NNN .EQ. 1) GO TO 95        
C        
C     BRING SIL INTO CORE        
C        
      IF (LCORE .LT. 0) GO TO 820        
      CALL GOPEN (SIL,CORE(BUF5),0)        
      IPM = SIL        
      CALL READ (*860,*80,SIL,CORE(NSTART+1),LCORE,1,NSIL)        
      GO TO 820        
   80 CALL CLOSE (SIL,1)        
      LCORE  = LCORE  - NSIL        
      NSTART = NSTART + NSIL        
C        
C     READ CSTM INTO OPEN CORE AND MAKE INITIAL CALLS TO PRETRD/PRETRS  
C        
      IF (LCORE .LT. 0) GO TO 820        
      CALL OPEN (*90,CSTM,CORE(BUF5),0)        
      ICM = 0        
      CALL SKPREC (CSTM,1)        
      IPM = CSTM        
      CALL READ (*860,*85,CSTM,CORE(NSTART+1),LCORE,1,NCSTM)        
      GO TO 820        
   85 CONTINUE        
C        
C     FOR THOSE SUBROUTINES WHICH USE BASGLB INSTEAD OF TRANSS/TRANSD,  
C     WE NEED TO REPOSITION THE CSTM FILE AND LEAVE THE GINO BUFFER     
C     AVAILABLE FOR LATER CALLS TO READ BY SUBROUTINE BASGLB.        
C        
      CALL REWIND (CSTM)        
      CALL SKPREC (CSTM,1)        
C        
      CALL PRETRD (CORE(NSTART+1),NCSTM)        
      CALL PRETRS (CORE(NSTART+1),NCSTM)        
C        
      LCORE  = LCORE  - NCSTM        
      NSTART = NSTART + NCSTM        
      IF (LCORE .LE. 0) GO TO 820        
C        
   90 NNN = 1        
   95 IF (ITEMP) 150, 150, 99        
C        
   99 DO 100 I = 1,NTLIST,3        
      IF (IDEFM .EQ. TLIST(I)) GO TO 110        
  100 CONTINUE        
C        
C     THERMAL LOAD NOT FOUND IN GPTT        
C        
      IPARM(2) = IPARM(1)        
      IPARM(1) = IGPTT        
      CALL MESAGE (-32,IDEFM,IPARM(1))        
  110 TO = TLIST(I+1)        
      IF (TLIST(I+2) .EQ. 0) GO TO 140        
      I = TLIST(I+2)        
      DO 120 J = 1,I        
      CALL FWDREC (*800,GPTT)        
  120 CONTINUE        
C        
C     READ SETID AND VERIFY CORRECT RECORD.  FAILSAFE        
C        
      CALL READ (*121,*121,GPTT,IDDD,1,0,DUMMY)        
      IF (IDDD .EQ. IDEFM) GO TO 125        
  121 WRITE  (OUTPT,122) IDEFM        
  122 FORMAT (98H0*** SYSTEM FATAL ERROR 4014, ROUTINE EDTL DETECTS BAD 
     1DATA ON TEMPERATURE DATA BLOCK FOR SET ID =,I9)        
      N1 = -61        
      GO TO 760        
  125 RECORD = .TRUE.        
      GO TO 150        
C        
C     THE GPTT (ELEMENT TEMPERATURE TABLE) IS NOW POSITIONED TO THE     
C     TEMPERATURE DATA FOR THE SET REQUESTED.  SUBROUTINE SSGETD WILL   
C     READ THE DATA.        
C        
  140 CONTINUE        
      RECORD = .FALSE.        
C        
  150 CONTINUE        
      CALL CLOSE (CSTM,1)        
      CALL OPEN (*151,CSTM,CORE(BUF5),0)        
      CALL SKPREC (CSTM,1)        
      ICM = 0        
  151 DO 160 I = 1,NROWSP        
  160 CORE(I) =  0.0        
C        
C     INITIALIZE /SSGETT/ VARIABLES        
C        
      OLDEL  = 0        
      EORFLG = .FALSE.        
      ENDID  = .TRUE.        
      BUFFLG = .FALSE.        
C        
C     ELEMENT CALL PROCESSING        
C        
C        
C     READ THE ELEMENT TYPE        
C        
  170 CALL READ (*710,*830,ECPT,ELTYPE,1,0,FLAG)        
      IF (ELTYPE.GE.1 .AND. ELTYPE.LE.NELEMS) GO TO 174        
      CALL MESAGE (-7,0,NAME)        
  172 WRITE  (OUTPT,173) SWM,ELTYPE        
  173 FORMAT (A27,' 4015, ELEMENT THERMAL AND DEFORMATION LOADING NOT ',
     1       'COMPUTED FOR ILLEGAL ELEMENT TYPE',I9, /34X,        
     2       'IN MODULE SSG1.')        
      GO TO 610        
  174 IDX    = (ELTYPE-1)*INCR        
      JLTYPE = 2*ELTYPE - IPR        
      NWORDS = NE(IDX+12)        
C        
C     READ AN ENTRY FOR ONE ELEMENT FROM ECPT        
C        
  175 CALL READ (*840,*170,ECPT,MECPT(1),NWORDS,0,FLAG)        
      IF (ITEMP .NE. 0) GO TO 176        
C        
C     ELEMENT DEFORMATION LOAD        
C        
      IF (IDEFM .NE. LDEFM) CALL FEDTST (IDEFM)        
      LDEFM = IDEFM        
      IF (ELTYPE .EQ. CROD  ) GO TO 180        
      IF (ELTYPE .EQ. CTUBE ) GO TO 200        
      IF (ELTYPE .EQ. CONROD) GO TO 190        
      IF (ELTYPE .EQ. CBAR  ) GO TO 210        
      GO TO 610        
C        
C     THERMAL LOAD        
C        
  176 CONTINUE        
C        
C     BRANCH TO THE DESIRED ELEMENT TYPE        
C        
      LOCAL = JLTYPE - 100        
      IF (LOCAL) 177,177,178        
C        
C        
C     PAIRED -GO TO- ENTRIES PER ELEMENT SINGLE/DOUBLE PRECISION        
C        
C             1 CROD      2 CBEAM     3 CTUBE     4 CSHEAR    5 CTWIST  
  177 GO TO( 180,  180,  172,  172,  200,  200,  360,  360,  610,  610  
C        
C             6 CTRIA1    7 CTRBSC    8 CTRPLT    9 CTRMEM   10 CONROD  
     1,      270,  270,  240,  240,  250,  250,  220,  220,  190,  190  
C        
C            11 ELAS1    12 ELAS2    13 ELAS3    14 ELAS4    15 CQDPLT  
     2,      610,  610,  610,  610,  610,  610,  610,  610,  260,  260  
C        
C            16 CQDMEM   17 CTRIA2   18 CQUAD2   19 CQUAD1   20 CDAMP1  
     3,      230,  230,  280,  280,  300,  300,  290,  290,  610,  610  
C        
C            21 CDAMP2   22 CDAMP3   23 CDAMP4   24 CVISC    25 CMASS1  
     4,      610,  610,  610,  610,  610,  610,  610,  610,  610,  610  
C        
C            26 CMASS2   27 CMASS3   28 CMASS4   29 CONM1    30 CONM2   
     5,      610,  610,  610,  610,  610,  610,  610,  610,  610,  610  
C        
C            31 PLOTEL   32 CREACT   33 CQUAD3   34 CBAR     35 CCONE   
     6,      610,  610,  172,  172,  172,  172,  210,  210,  350,  350  
C        
C            36 CTRIARG  37 CTRAPRG  38 CTORDRG  39 CTETRA   40 CWEDGE  
     7,      320,  320,  330,  330,  340,  340,  390,  390,  400,  400  
C        
C            41 CHEXA1   42 CHEXA2   43 CFLUID2  44 CFLUID3  45 CFLUID4 
     8,      410,  410,  420,  420,  610,  610,  610,  610,  610,  610  
C        
C            46 CFLMASS  47 CAXIF2   48 CAXIF3   49 CAXIF4   50 CSLOT3  
     9,      610,  610,  610,  610,  610,  610,  610,  610,  610,  610  
C        
     *), JLTYPE        
C        
C            51 CSLOT4   52 CHBDY    53 CDUM1    54 CDUM2    55 CDUM3   
  178 GO TO( 610,  610,  610,  610,  553,  553,  554,  554,  555,  555  
C        
C            56 CDUM4    57 CDUM5    58 CDUM6    59 CDUM7    60 CDUM8   
     B,      556,  556,  557,  557,  558,  558,  559,  559,  560,  560  
C        
C            61 CDUM9    62 CQDMEM1  63 CQDMEM2  64 CQUAD4   65 CIHEX1  
     C,      561,  561,  562,  562,  563,  563,  564,  564,  425,  425  
C        
C            66 CIHEX2   67 CIHEX3   68 CQUADTS  69 CTRIATS  70 CTRIAAX 
     D,      425,  425,  425,  425,  172,  172,  172,  172,  428,  428  
C        
C             71 CTRAPAX  72 CAERO1   73 CTRIM6   74 CTRPLT1  75 CTRSHL 
     E,       429,  429,  172,  172,  430,  430,  431,  431,  432,  432 
C        
C             76 CFHEX1   77 CFHEX2   78 CFTETRA  79 CFWEDGE  80 CIS2D8 
     F,       172,  172,  172,  172,  172,  172,  172,  172,  433,  433 
C        
C             81 CELBOW   82 FTUBE    83 TRIA3        
     G,       172,  172,  610,  610,  566,  566        
C        
     *), LOCAL        
C        
C     ROD        
C        
  180 CALL ROD        
      GO TO 175        
C        
C     CONROD        
C        
  190 GO TO 180        
C        
C     TUBE        
C        
  200 GO TO 180        
C        
C     BAR        
C        
  210 CALL BAR (CORE(1),IDEFM,ITEMP,IDEFT)        
      GO TO 175        
C        
C     TRMEM        
C        
  220 CALL SSGETD (MECPT(1),TI(1),0)        
      CALL TRIMEM (0,TI,CORE(1))        
      GO TO 175        
C        
C     QDMEM        
C        
  230 CALL SSGETD (MECPT(1),TI(1),0)        
      CALL QDMEM  (TI,CORE(1))        
      GO TO 175        
C        
C     TRBSC        
C        
  240 CALL SSGETD (MECPT(1),TI(1),0)        
      CALL TRBSC  (0,TI)        
      GO TO 175        
C        
C     TRPLT        
C        
  250 CALL SSGETD (MECPT(1),TI(1),0)        
      CALL TRPLT  (TI)        
      GO TO 175        
C        
C     QDPLT        
C        
  260 CALL SSGETD (MECPT(1),TI(1),0)        
      CALL QDPLT  (TI)        
      GO TO 175        
C        
C     TRIA1        
C        
  270 KK = 1        
      GO TO 301        
C        
C     TRIA2        
C        
  280 KK = 2        
      GO TO 301        
C        
C     QUAD1        
C        
  290 KK = 3        
      GO TO 301        
C        
C     QUAD2        
C        
  300 KK = 4        
  301 CALL SSGETD (MECPT(1),TI(1),0)        
      CALL TRIQD  (KK,TI(1))        
      GO TO 175        
C        
C     TRIARG        
C        
  320 CALL SSGETD (MECPT(1),TI(1),3)        
      CALL TTRIRG (TI(2),CORE(1))        
      GO TO 175        
C        
C     TRAPRG        
C        
  330 CALL SSGETD (MECPT(1),TI(1),4)        
      CALL TTRAPR (TI(2),CORE(1))        
      GO TO 175        
C        
C     TORDRG        
C        
  340 CALL SSGETD (MECPT(1),TI(1),2)        
      CALL TTORDR (TI(2),CORE(1) )        
      GO TO 175        
C        
C     CONE        
C        
  350 CALL SSGETD (MECPT(1),TI(1),2)        
      CALL CONE   (TI(2),CORE(1))        
      GO TO 175        
C        
C     SHEAR PANEL        
C        
  360 CALL TSHEAR        
      GO TO 175        
C        
C     TETRA        
C        
  390 CALL SSGETD (MECPT(1),TI(1),4)        
      CALL TETRA  (TI(2),CORE(1),0)        
      GO TO 175        
C        
C     WEDGE        
C        
  400 IIJJ = 1        
      NPTS = 6        
      GO TO 421        
C        
C     HEXA1        
C        
  410 IIJJ = 2        
      NPTS = 8        
      GO TO 421        
C        
C     HEXA2        
C        
  420 IIJJ = 3        
      NPTS = 8        
  421 CALL SSGETD (MECPT(1),TI(1),NPTS)        
      CALL SOLID  (TI(2),CORE(1),IIJJ)        
      GO TO 175        
C        
C     IHEX1, IHEX2, IHEX3        
C        
  425 NPTS=12*(ELTYPE-64)-4        
      CALL SSGETD (MECPT(1),TI(1),NPTS)        
      CALL IHEX   (TI(1),CORE(1),ELTYPE-64)        
      GO TO 175        
C        
C     TRIAAX        
C        
  428 CALL SSGETD (MECPT,TI,3)        
      CALL TRTTEM (TI(2),CORE)        
      GO TO 175        
C        
C     TRAPAX        
C        
  429 CALL SSGETD (MECPT,TI,4)        
      CALL TPZTEM (TI(2),CORE)        
      GO TO 175        
C        
C     TRIM6        
C        
  430 CALL SSGETD (MECPT(1),TI,6)        
      CALL TLODM6 (TI(1))        
      GO TO 175        
C        
C     TRPLT1        
C        
  431 CALL SSGETD (MECPT(1),TI,0)        
      CALL TLODT1 (TI(1),TI(1))        
      GO TO 175        
C        
C     TRSHL        
C        
  432 CALL SSGETD (MECPT(1),TI(1),0)        
      CALL TLODSL (TI(1),TI(1))        
      GO TO 175        
C        
C     IS2D8        
C        
  433 CALL SSGETD (MECPT(1),TI(1),8)        
      CALL TIS2D8 (TI(2),CORE)        
      GO TO 175        
C        
C     DUMMY ELEMENTS        
C        
  553 CALL DUM1 (CORE(1))        
      GO TO 175        
  554 CALL DUM2 (CORE(1))        
      GO TO 175        
  555 CALL DUM3 (CORE(1))        
      GO TO 175        
  556 CALL DUM4 (CORE(1))        
      GO TO 175        
  557 CALL DUM5 (CORE(1))        
      GO TO 175        
  558 CALL DUM6 (CORE(1))        
      GO TO 175        
  559 CALL DUM7 (CORE(1))        
      GO TO 175        
  560 CALL DUM8 (CORE(1))        
      GO TO 175        
  561 CALL DUM9 (CORE(1))        
      GO TO 175        
C        
C     QDMEM1        
C        
  562 CALL SSGETD (MECPT(1),TI(1),0)        
      CALL QDMM1  (TI,CORE(1))        
      GO TO 175        
C        
C     QDMEM2        
C        
  563 CALL SSGETD (MECPT(1),TI(1),0)        
      CALL QDMM2  (TI,CORE(1))        
      GO TO 175        
C        
C     QUAD4        
C        
  564 DO 565 ITI = 1,7        
  565 TI(ITI) = 0.0        
      CALL SSGETD (MECPT(1),TI,4)        
      IF (IPR .NE. 0) CALL TLQD4S        
      IF (IPR .EQ. 0) CALL TLQD4D        
      GO TO 175        
C        
C     TRIA3        
C        
  566 DO 567 ITI = 1,7        
  567 TI(ITI) = 0.0        
      CALL SSGETD (MECPT(1),TI,3)        
      IF (IPR .NE. 0) CALL TLTR3S        
      IF (IPR .EQ. 0) CALL TLTR3D        
      GO TO 175        
C        
C     NO LOAD, SKIP THE ECPT ENTRY ONLY        
C        
  610 CALL FWDREC (*840,ECPT)        
      GO TO 170        
C        
C     PACK THE LOAD VECTOR FROM CORE TO OUTPUT DATA BLOCK -PG-        
C        
  710 CALL PACK (CORE,PG(1),PG)        
      CALL REWIND (ECPT)        
      CALL FWDREC (*840,ECPT)        
      IF (IDEFT .NE. 0 .AND. IDEFM .NE. 0) CALL FEDTED (IDEFM)        
C        
  720 CONTINUE        
C        
      IF (NOEDT  .EQ. 0) CALL CLOSE (EDT ,1)        
      IF (NOGPTT .EQ. 0) CALL CLOSE (GPTT,1)        
      IF (ICM    .EQ. 0) CALL CLOSE (CSTM,1)        
      CALL CLOSE (ECPT,1)        
      RETURN        
C        
  750 N1 = -1        
  760 CALL MESAGE (N1,IPM,IPARM)        
  800 IPM = GPTT        
      GO TO 860        
  810 N1 = -3        
      GO TO 760        
  820 N1 = -8        
      GO TO 760        
  830 IPM = ECPT        
      GO TO 810        
  840 IPM = ECPT        
  860 N1 = -2        
      GO TO 760        
      END        
