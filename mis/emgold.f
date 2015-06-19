      SUBROUTINE EMGOLD        
C        
C     THIS IS A DRIVING ROUTINE OF THE -EMG- MODULE WHICH ALLOWS PIVOT- 
C     POINT-LOGIC ELEMENT SUBROUTINES TO BE USED IN CONJUNCTION WITH THE
C     NON-PIVOT-POINT PROCESS.        
C        
      LOGICAL          ERROR,LAST,HEAT,KHEAT,LHEAT,HYDRO        
      INTEGER          OUTPT,SIL,POSVEC,ELTYPE,ELID,ELEM,DICT,ESTWDS,   
     1                 ESTID,ESTBUF,FILTYP,PRECIS,MDICT(15),KDICT(15),  
     2                 BDICT(15),FLAGS,QP        
      DOUBLE PRECISION DUMMY        
      CHARACTER        UFM*23,UWM*25,UIM*29,SFM*25,SWM*27,SIM*31        
      COMMON /XMSSG /  UFM,UWM,UIM,SFM,SWM,SIM        
      COMMON /MACHIN/  MACH,DUM2(2),LQRO        
      COMMON /SYSTEM/  KSYSTM(65)        
      COMMON /GPTA1 /  NELEMS,NLAST,INCR,ELEM(1)        
      COMMON /EMGDIC/  ELTYPE,LDICT,NLOCS,ELID,ESTID        
      COMMON /EMGEST/  ESTBUF(100)        
      COMMON /SMA1ET/  KECPT(100)        
      COMMON /SMA2ET/  MECPT(100)        
      COMMON /SMA1IO/  SMAIO(36)        
      COMMON /SMA1BK/  S1DUM(10)        
      COMMON /SMA2BK/  S2DUM(10)        
      COMMON /SMA1DP/  KWORK(700)        
      COMMON /SMA2DP/  MWORK(700)        
      COMMON /SMA1CL/  IOPT4,K4GGSW,KNPVT,SKIP19(19),KNOGO,KSAFE(200)   
      COMMON /SMA2CL/  IOPTB,BGGIND,MNPVT,SKIP17(17),MNOGO,SKIP2(2),    
     1                 MSAFE(200)        
      COMMON /EMG1BX/  NSILS,POSVEC(10),IBLOC,NBLOC,IROWS,DICT(15),     
     1                 FILTYP,SIL(10),LAST        
      COMMON /EMGPRM/  SKIPXX(15),FLAGS(3),PRECIS,ERROR,HEAT,ICMBAR,    
     1                 LCSTM,LMAT,LHMAT,KFLAGS(3),L38        
      COMMON /HYDROE/  HYDRO        
      COMMON /SMA1HT/  KHEAT        
      COMMON /SMA2HT/  LHEAT        
      COMMON /IEMGOD/  DUMMY,LTYPES        
      EQUIVALENCE      (KSYSTM(2),OUTPT), (KSYSTM(40),NBPW),
     1                 (SMAIO(11),IFKGG), (SMAIO(13),IF4GG)        
C        
      KTEMP = KNOGO        
      MTEMP = MNOGO        
      QP    = MOD(LQRO/100,10)        
      JLTYPE= 2*(ELTYPE-1) + PRECIS        
      KHEAT = HEAT        
      LHEAT = HEAT        
      IZERO = INCR*(ELTYPE - 1)        
      IF (ELTYPE .EQ. LTYPES) GO TO 20        
      CALL PAGE2 (3)        
      INDEX = IZERO        
      IF (.NOT.HEAT) GO TO 3        
      IF (ELTYPE.EQ.62 .OR. ELTYPE.EQ.63) INDEX = 15*INCR        
    3 IF (L38 .EQ. 1) WRITE (OUTPT,4) SIM,ELEM(INDEX+1),ELEM(INDEX+2)   
    4 FORMAT (A31,' 3107',/5X,'EMGOLD CALLED BY EMGPRO TO PROCESS ',2A4,
     1       ' ELEMENTS.')        
      LTYPES = ELTYPE        
      GO TO 20        
    5 WRITE  (OUTPT,10) SWM,ELID,ELEM(IZERO+1),ELEM(IZERO+2)        
   10 FORMAT (A27,' 3121, EMGOLD HAS RECEIVED A CALL FOR ELEMENT ID',I9,
     1       ' (ELEMENT TYPE ',2A4,2H)., /5X,'ELEMENT IGNORED AS THIS ',
     2       'ELEMENT TYPE IS NOT HANDLED BY EMGOLD.')        
      GO TO 1220        
C  12 WRITE  (OUTPT,14) UFM,ELEM(IZERO+1),ELEM(IZERO+2)        
C  14 FORMAT (A23,', HEAT OPTION NOT SET FOR ELEMENT TYPE ',2A4)        
C     KNOGO = 1        
C     GO TO 1220        
C        
   20 NSILS = ELEM(IZERO+10)        
      ISIL  = ELEM(IZERO+13)        
      IF (ELEM(IZERO+9) .NE. 0) ISIL = ISIL - 1        
      ESTWDS = ELEM(IZERO+12)        
      I1 = ISIL        
      I2 = ISIL + NSILS - 1        
      L  = NSILS        
C        
C     MOVE SILS TO SEPARATE ARRAY        
C        
C     SORT ARRAY OF SILS        
C        
C     POSITION VECTOR        
C        
      DO 80 I = I1,I2        
      IF (ESTBUF(I) .EQ. 0) GO TO 72        
      K = 1        
      DO 70 J = I1,I2        
      IF (ESTBUF(J) - ESTBUF(I)) 60,50,70        
   50 IF (J .GE. I) GO TO 70        
   60 IF (ESTBUF(J) .NE. 0) K = K + 1        
   70 CONTINUE        
      GO TO 74        
   72 K = L        
      L = L - 1        
   74 POSVEC(K) = I - I1 + 1        
   80 SIL(K) = ESTBUF(I)        
C        
C     ELIMINATE DUP SILS THAT MAY OCCUR,E.G. CHBDY WITH AMB.PTS.        
C        
      K = 1        
      ICOUNT = 1        
      DO 85 I = 2,NSILS        
   82 K = K + 1        
      IF (K .LE. NSILS) GO TO 84        
      SIL(I) = 0        
      POSVEC(I) = 0        
      GO TO 85        
   84 IF (SIL(K) .EQ. SIL(K-1)) GO TO 82        
      SIL(I) = SIL(K)        
      IF (SIL(K) .NE. 0) ICOUNT = ICOUNT + 1        
      POSVEC(I) = POSVEC(K)        
   85 CONTINUE        
      NSILS = ICOUNT        
C        
C     SETUP VALUES AND DICTIONARY IN /EMG1BX/ FOR EMG1B USE        
C        
      DICT(1) = ESTID        
      DICT(2) = 1        
C        
C     PSUEDO SMA1-SMA2 FILE NUMBERS        
C        
      IFKGG = 201        
      IF4GG = 202        
C        
C     DICT(4) WILL BE RESET TO EITHER 1 OR 63 BY EMG1B        
C     BASED ON INCOMING DATA TO EMG1B        
C        
      DO 90 I = 5,15        
      DICT(I) = 0        
   90 CONTINUE        
C        
C     CALL ELEMENT FOR EACH PIVOT ROW        
C        
      LAST  = .FALSE.        
      KNOGO = 0        
      MNOGO = 0        
      DO 1210 I = 1,NSILS        
      IF (I .EQ. NSILS) LAST = .TRUE.        
C        
C     STIFFNESS MATRIX        
C        
      IF (FLAGS(1) .EQ. 0) GO TO 550        
C        
C     RESTORE K-DICTIONARY IF NECESSARY        
C        
      IF (I .EQ. 1) GO TO 110        
      DO 100 L = 1,15        
      DICT(L) = KDICT(L)        
  100 CONTINUE        
  110 CONTINUE        
      FILTYP = 1        
C        
C     IOPT4 IS TURNED ON SO THAT DAMPING CONSTANTS ARE SENT TO EMG1B    
C     IN ALL AVAILABLE CASES BY ELEMENT ROUTINES.  MATRIX DATA WILL BE  
C     IGNORED BY EMG1B ON EMG1B CALLS SENDING DAMPING CONSTANTS.        
C     DAMPING CONSTANTS WILL BE PLACED IN 5TH WORD OF ELEMENT DICTIONARY
C     ENTRY.        
C        
      IOPT4  = 1        
      K4GGSW = 0        
      KNPVT  = SIL(I)        
C        
C     FULL 6X6 MATRIX FORCED FOR STIFFNESS WITH OLD ELEMENT ROUTINES    
C        
      DICT(2) = 1        
      IF (SIL(I) .NE. 0) GO TO 115        
      CALL EMG1B (DUMMY,0,1,1,0)        
      GO TO 520        
  115 CONTINUE        
      DO 120 L = 1,ESTWDS        
      KECPT(L) = ESTBUF(L)        
  120 CONTINUE        
      HYDRO = .FALSE.        
      IF (ELTYPE.GE.76 .AND. ELTYPE.LE.79) HYDRO = .TRUE.        
C        
C     CALL THE PROPER ELEMENT STIFFNESS ROUTINE        
C        
      LOCAL = JLTYPE - 100        
      IF (LOCAL) 130,130,140        
C        
C     PAIRED -GO TO- ENTRIES PER ELEMENT SINGLE/DOUBLE PRECISION        
C        
C             1 CROD      2 C.....    3 CTUBE     4 CSHEAR    5 CTWIST  
  130 GO TO (  5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C             6 CTRIA1    7 CTRBSC    8 CTRPLT    9 CTRMEM   10 CONROD  
     1,      190,  190,    5,    5,  210,  210,    5,    5,    5,    5  
C        
C            11 ELAS1    12 ELAS2    13 ELAS3    14 ELAS4    15 CQDPLT  
     2,        5,    5,    5,    5,    5,    5,    5,    5,  280,  280  
C        
C            16 CQDMEM   17 CTRIA2   18 CQUAD2   19 CQUAD1   20 CDAMP1  
     3,      290,  290,  300,  300,  310,  310,  320,  320,    5,    5  
C        
C            21 CDAMP2   22 CDAMP3   23 CDAMP4   24 CVISC    25 CMASS1  
     4,        5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            26 CMASS2   27 CMASS3   28 CMASS4   29 CONM1    30 CONM2   
     5,        5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            31 PLOTEL   32 C.....   33 C.....   34 CBAR     35 CCONEAX 
     6,      520,  520,    5,    5,    5,    5,    5,    5,  340,  345  
C        
C            36 CTRIARG  37 CTRAPRG  38 CTORDRG  39 CTETRA   40 CWEDGE  
     7,      350,  350,  370,  370,    5,    5,  400,  400,  410,  410  
C        
C            41 CHEXA1   42 CHEXA2   43 CFLUID2  44 CFLUID3  45 CFLUID4 
     8,      420,  420,  430,  430,  440,  440,  450,  450,  460,  460  
C        
C            46 CFLMASS  47 CAXIF2   48 CAXIF3   49 CAXIF4   50 CSLOT3  
     9,      520,  520,  440,  440,  450,  450,  460,  460,  470,  470  
C        
     *      ), JLTYPE        
C        
C            51 CSLOT4   52 CHBDY    53 CDUM1    54 CDUM2    55 CDUM3   
  140 GO TO (480,  480,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            56 CDUM4    57 CDUM5    58 CDUM6    59 CDUM7    60 CDUM8   
     B,        5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            61 CDUM9    62 CQDMEM1  63 CQDMEM2  64 CQDMEM3  65 CIHEX1  
     C,        5,    5,  292,  292,  295,  294,    5,    5,    5,    5  
C        
C            66 CIHEX2   67 CIHEX3   68 CQUADTS  69 CTRIATS  70 CTRIAAX 
     D,        5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            71 CTRAPAX  72 CAERO1   73 CTRIM6   74 CTRPLT1  75 CTRSHL  
     E,        5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            76 CFHEX1   77 CFHEX2   78 CFTETRA  79 CFWEDGE  80 CIS2D8  
     F,      420,  420,  430,  430,  400,  400,  410,  410,    5,    5  
C        
C            81 CELBOW   82 FTUBE    83 CTRIA3   84 CPSE2    85 CPSE3   
     G,      390,  390,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            86 CPSE4        
     H,        5,    5        
C        
     *      ), LOCAL        
C        
C        
C     IN -HEAT- FORMULATIONS SOME ELEMENTS ARE IGNORED (OPTION(1)=HEAT) 
C     IN STRUCTURE PROBLEMS SOME ELEMENTS ARE IGNORED (OPTION(1)=STRUCT)
C        
  190 CALL KTRIQD (1)        
      GO TO 520        
  210 CALL KTRPLT        
      GO TO 520        
  280 CALL KQDPLT        
      GO TO 520        
  290 CALL KQDMEM        
      GO TO 520        
C        
C     REPLACE ELEMENT TYPE CQDMEM1 BY ELEMENT TYPE CQDMEM        
C     IN -HEAT- FORMULATION        
C        
  292 IF (HEAT) GO TO 290        
      GO TO 5        
C        
C     REPLACE ELEMENT TYPE CQDMEM2 BY ELEMENT TYPE CQDMEM        
C     IN -HEAT- FORMULATION        
C        
  294 IF (HEAT) GO TO 290        
      GO TO 5        
C        
C     REPLACE ELEMENT TYPE CQDMEM2 BY ELEMENT TYPE CQDMEM        
C     IN -HEAT- FORMULATION        
C        
  295 IF (HEAT) GO TO 290        
      GO TO 5        
  300 CALL KTRIQD (2)        
      GO TO 520        
  310 CALL KTRIQD (4)        
      GO TO 520        
  320 CALL KTRIQD (3)        
      GO TO 520        
  340 CALL KCONES        
      GO TO 520        
  343 CALL KCONE2        
      GO TO 520        
  345 IF (MACH .EQ.  3) GO TO 340
      IF (NBPW .GE. 60) GO TO 343
      IF (QP .EQ. 0) CALL KCONED        
      IF (QP .NE. 0) CALL KCONEQ        
      GO TO 520        
  350 IF (HEAT) GO TO 360        
      IF (KNOGO .EQ. 2) GO TO 1210        
      CALL KTRIRG        
      IF (KNOGO .EQ. 2) GO TO 1210        
      GO TO 520        
  360 CALL HRING (3)        
      GO TO 520        
  370 IF (HEAT) GO TO 380        
      CALL KTRAPR        
      GO TO 520        
  390 CALL KELBOW        
      GO TO 520        
  380 CALL HRING (4)        
      GO TO 520        
  400 CALL KTETRA (0,0)        
      GO TO 520        
  410 CALL KSOLID (1)        
      GO TO 520        
  420 CALL KSOLID (2)        
      GO TO 520        
  430 CALL KSOLID (3)        
      GO TO 520        
  440 CALL KFLUD2        
      GO TO 520        
  450 CALL KFLUD3        
      GO TO 520        
  460 CALL KFLUD4        
      GO TO 520        
  470 CALL KSLOT (0)        
      GO TO 520        
  480 CALL KSLOT (1)        
      GO TO 520        
C        
C     OUTPUT THE PIVOT ROW PARTITION NOW COMPLETED BY -EMG1B-        
C        
  520 CALL EMG1B (0.0D0,-1111111,0,0,0.0D0)        
C        
C     SAVE K-DICTIONARY        
C        
      DO 530 L = 1,15        
      KDICT(L) = DICT(L)        
  530 CONTINUE        
C        
C     MASS MATRIX M        
C        
  550 IF (FLAGS(2) .EQ. 0) GO TO 1090        
      IF (HEAT) GO TO 1090        
C        
C     RESTORE M-DICTIONARY IF NECESSARY        
C        
      IF (I .EQ. 1) GO TO 570        
      DO 560 L = 1,15        
      DICT(L) = MDICT(L)        
  560 CONTINUE        
  570 CONTINUE        
      FILTYP = 2        
      IOPTB  = 0        
      BGGIND =-1        
      MNPVT  = SIL(I)        
      DICT(2)= 1        
      IF (SIL(I) .NE. 0)  GO TO 575        
      CALL EMG1B (DUMMY,0,1,2,0)        
      GO TO 1060        
  575 CONTINUE        
      DO 580 L = 1,ESTWDS        
      MECPT(L) = ESTBUF(L)        
  580 CONTINUE        
C        
C     CALL THE PROPER ELEMENT MASS ROUTINE.        
C        
  590 LOCAL = JLTYPE - 100        
      IF (LOCAL) 600,600,610        
C        
C     PAIRED -GO TO- ENTRIES PER ELEMENT SINGLE/DOUBLE PRECISION        
C        
C             1 CROD      2 C.....    3 CTUBE     4 CSHEAR    5 CTWIST  
  600 GO TO (  5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C             6 CTRIA1    7 CTRBSC    8 CTRPLT    9 CTRMEM   10 CONROD  
     1,      670,  670,    5,    5,  710,  710,    5,    5,    5,    5  
C        
C            11 ELAS1    12 ELAS2    13 ELAS3    14 ELAS4    15 CQDPLT  
     2,        5,    5,    5,    5,    5,    5,    5,    5,  740,  740  
C        
C            16 CQDMEM   17 CTRIA2   18 CQUAD2   19 CQUAD1   20 CDAMP1  
     3,      760,  760,  770,  770,  790,  790,  810,  810,    5,    5  
C        
C            21 CDAMP2   22 CDAMP3   23 CDAMP4   24 CVISC    25 CMASS1  
     4,        5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            26 CMASS2   27 CMASS3   28 CMASS4   29 CONM1    30 CONM2   
     5,        5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            31 PLOTEL   32 C.....   33 C.....   34 CBAR     35 CCONEAX 
     6,     1060, 1060,    5,    5,    5,    5,    5,    5,  910,  910  
C        
C            36 CTRIARG  37 CTRAPRG  38 CTORDRG  39 CTETRA   40 CWEDGE  
     7,      930,  930,  940,  940,    5,    5,  960,  960,  970,  970  
C        
C            41 CHEXA1   42 CHEXA2   43 CFLUID2  44 CFLUID3  45 CFLUID4 
     8,      980,  980,  990,  990, 1000, 1000, 1010, 1010, 1020, 1020  
C        
C            46 CFLMASS  47 CAXIF2   48 CAXIF3   49 CAXIF4   50 CSLOT3  
     9,     1030, 1030, 1000, 1000, 1010, 1010, 1020, 1020, 1040, 1040  
C        
     *     ), JLTYPE        
C        
C        
C            51 CSLOT4   52 CHBDY    53 CDUM1    54 CDUM2    55 CDUM3   
  610 GO TO (1050,1050,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            56 CDUM4    57 CDUM5    58 CDUM6    59 CDUM7    60 CDUM8   
     B,        5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            61 CDUM9    62 CQDMEM1  63 CQDMEM2  64 CQDMEM3  65 CIHEX1  
     C,        5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            66 CIHEX2   67 CIHEX3   68 CQUADTS  69 CTRIATS  70 CTRIAAX 
     D,        5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            71 CTRAPAX  72 CAERO1   73 CTRIM6   74 CTRPLT1  75 CTRSHL  
     E,        5,    5,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            76 CFHEX1   77 CFHEX2   78 CFTETRA  79 CFWEDGE  80 CIS2D8  
     F,     1060, 1060, 1060, 1060, 1060, 1060, 1060, 1060,    5,    5  
C        
C            81 CELBOW   82 FTUBE    83 CTRIA3   84 CPSE2    85 CPSE3   
     G,      950,  950,    5,    5,    5,    5,    5,    5,    5,    5  
C        
C            86 CPSE4        
     H,        5,    5        
C        
     *      ), LOCAL        
C        
C        
C     CONVENTIONAL MASS MATRIX GENERATION ROUTINE CALLED WHEN        
C     ICMBAR .LT. 0        
C     OTHERWISE CONSISTENT MASS MATRIX GENERATION ROUTINE CALLED        
C        
  670 IF (ICMBAR .LT. 0) GO TO 680        
      CALL MTRIQD (1)        
      GO TO 1060        
  680 CALL MASSTQ (5)        
      GO TO 1060        
C        
  710 IF (ICMBAR .LT. 0) GO TO 720        
      CALL MTRPLT        
      GO TO 1060        
  720 CALL MASSTQ (3)        
      GO TO 1060        
C        
  740 IF (ICMBAR .LT. 0) GO TO 750        
      CALL MQDPLT        
      GO TO 1060        
  750 CALL MASSTQ (7)        
      GO TO 1060        
  760 CALL MASSTQ (1)        
      GO TO 1060        
C        
  770 IF (ICMBAR .LT. 0) GO TO 780        
      CALL MTRIQD (2)        
      GO TO 1060        
  780 CALL MASSTQ (4)        
      GO TO 1060        
C        
  790 IF (ICMBAR .LT. 0) GO TO 800        
      CALL MTRIQD (4)        
      GO TO 1060        
  800 CALL MASSTQ (1)        
      GO TO 1060        
C        
  810 IF (ICMBAR .LT. 0) GO TO 820        
      CALL MTRIQD (3)        
      GO TO 1060        
  820 CALL MASSTQ (2)        
      GO TO 1060        
  910 CALL MCONE        
      GO TO 1060        
  930 IF (MNOGO .EQ. 2) GO TO 1210        
      IF (HEAT) GO TO 935        
      CALL MTRIRG        
      IF (MNOGO .EQ. 2) GO TO 1210        
      GO TO 1060        
  935 CALL MRING (3)        
      GO TO 1060        
  940 IF (HEAT) GO TO 945        
      CALL MTRAPR        
      GO TO 1060        
  945 CALL MRING (4)        
      GO TO 1060        
  950 CALL MELBOW        
      GO TO 1060        
  960 CALL MSOLID (1)        
      GO TO 1060        
  970 CALL MSOLID (2)        
      GO TO 1060        
  980 CALL MSOLID (3)        
      GO TO 1060        
  990 CALL MSOLID (4)        
      GO TO 1060        
 1000 CALL MFLUD2        
      GO TO 1060        
 1010 CALL MFLUD3        
      GO TO 1060        
 1020 CALL MFLUD4        
      GO TO 1060        
 1030 CALL MFREE        
      GO TO 1060        
 1040 CALL MSLOT (0)        
      GO TO 1060        
 1050 CALL MSLOT (1)        
      GO TO 1060        
C        
C     OUTPUT THE PIVOT ROW PARTITION NOW COMPLETED BY -EMG1B-        
C        
 1060 CALL EMG1B (0.0D0,-1111111,0,0,0.0D0)        
      IF (HEAT) GO TO 1185        
C        
C     SAVE M-DICTIONARY        
C        
      DO 1070 L = 1,15        
      MDICT(L) = DICT(L)        
 1070 CONTINUE        
C        
C     DAMPING MATRIX B        
C        
 1090 IF (FLAGS(3) .EQ. 0) GO TO 1210        
      IF (.NOT.HEAT) GO TO 1210        
C        
C     RESTORE B-DICTIONARY IF NECESSARY        
C        
      IF (I .EQ. 1) GO TO 1110        
      DO 1100 L = 1,15        
      DICT(L) = BDICT(L)        
 1100 CONTINUE        
 1110 FILTYP = 3        
      IOPTB  =-1        
      BGGIND =-1        
      MNPVT  = SIL(I)        
      DICT(2)= 1        
      IF (SIL(I) .NE. 0) GO TO 1115        
      CALL EMG1B (DUMMY,0,1,3,0)        
      GO TO 1180        
 1115 DO 1120 L = 1,ESTWDS        
      MECPT(L) = ESTBUF(L)        
 1120 CONTINUE        
      GO TO 590        
C        
C     OUTPUT THE PIVOT ROW PARTITION NOW COMPLETED BY -EMG1B-        
C        
 1180 CALL EMG1B (0.0D0,-1111111,0,0,0.0D0)        
C        
C     SAVE DICTIONARY        
C        
 1185 DO 1190 L = 1,15        
      BDICT(L) = DICT(L)        
 1190 CONTINUE        
C        
 1210 CONTINUE        
      IF (KNOGO .EQ. 0) KNOGO = KTEMP        
      IF (MNOGO .EQ. 0) MNOGO = MTEMP        
C        
 1220 RETURN        
      END        
