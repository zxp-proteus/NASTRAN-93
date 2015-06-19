      SUBROUTINE PRTPRM        
C        
C     PRINTS NASTRAN PARAMETERS        
C        
C  $MIXED_FORMATS        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL         LSHIFT,RSHIFT        
      LOGICAL          KICKK        
      REAL             WAL(32)        
      DOUBLE PRECISION DAL(2)        
      DIMENSION        BT(26),KT(26),K1(32),K2(32),K3(32),K4(32),       
     1                 K5(32),K6(32),NAME(2),VAL(2)        
      COMMON /MACHIN/  MACHX        
      COMMON /BLANK /  IC,B1,B2        
      COMMON /XVPS  /  V(2)        
      COMMON /SYSTEM/  NB,NOUT,JUNK1(6),LNMAX,JUNK2(2),LN        
      COMMON /OUTPUT/  DUMHED(96),H1(32),H2(32),H3(32)        
      EQUIVALENCE      (V(2),L), (DAL(1),VAL(1),WAL(1))        
      DATA    XXXX  /  4HXXXX   /,   OO/27/        
      DATA    KT    /  5,6,4,5,6,5,3,4,3,5,7,6,6,6,6,5,0,0,0,4,3,2,     
     1                 7,5,4,1  /        
      DATA    K1    /  32*4H    /        
      DATA    K2    /  7*4H    ,4HC O ,4HN T ,4HE N ,4HT S ,4H  O ,     
     1                 4HF     ,4HP A ,4HR A ,4HM E ,4HT E ,4HR   ,     
     2                 4HT A   ,4HB L ,4HE   ,11*4H        /        
      DATA    K3    /  32*4H    /        
      DATA    K4    /  32*4H    /        
      DATA    K5    /  32*4H    /        
      DATA    K6    /  32*4H    /        
      DATA    BT    /  4HSTAT,4HINER,4HMODE,4HDIFF,4HBUCK,4HPLA ,4HDIRC,
     1                 4HDIRF,4HDIRT,4HMDLC,4HMDLF,4HMDLT,4HNMDS,4HCYCS,
     2                 4HCYCM,4HASTA,4HDDRM,4HFVDA,4HMVDA,4HHSTA,4HHNLI,
     3                 4HHTRD,4HBLAD,4HFLUT,4HAERO,4HDMAP/        
C        
C        
      IF (IC .NE. 0) GO TO 550        
      DO 10 M = 1,32        
      H1(M) = K1(M)        
      H2(M) = K2(M)        
   10 H3(M) = K3(M)        
      CALL PAGE        
      I = 3        
      IF (I .GT. L) GO TO 510        
      KICKK = .FALSE.        
      IF (B1.NE.XXXX .OR. B2.NE.XXXX) KICKK = .TRUE.        
      IF (KICKK) GO TO 180        
C        
   20 IF (I .GT. L) GO TO 7820        
      ASSIGN 30 TO R        
      GO TO 300        
   30 I = I + NW + 3        
      IF (LN .GE. LNMAX) CALL PAGE        
      GO TO (40,60,80,100,120,150), TYPE        
   40 WRITE  (NOUT,50) NAME(1),NAME(2),VAL(1)        
   50 FORMAT (20X,2A4,10X,I10)        
      GO TO  170        
   60 WRITE  (NOUT,70) NAME(1),NAME(2),WAL(1)        
   70 FORMAT (20X,2A4,10X,1P,E14.6)        
      GO TO  170        
   80 WRITE  (NOUT,90) NAME(1),NAME(2),VAL(1),VAL(2)        
   90 FORMAT (20X,2A4,10X,2A4)        
      GO TO  170        
  100 WRITE  (NOUT,110) NAME(1),NAME(2),DAL(1)        
  110 FORMAT (20X,2A4,10X,1P,D24.16)        
      GO TO  170        
  120 WRITE  (NOUT,130) NAME(1),NAME(2),WAL(1),WAL(2)        
  130 FORMAT (20X,2A4,10X,1H(,1P,2E14.6,1H))        
      IF (MACHX .GE. 5) WRITE (NOUT,140,ERR=170) DAL(1)        
  140 FORMAT (1H+,69X,'OR',D24.16)        
      GO TO  170        
  150 WRITE  (NOUT,160) NAME(1),NAME(2),DAL(1),DAL(2)        
  160 FORMAT (20X,2A4,10X,1H(,1P,2D24.16,1H))        
  170 IF (KICKK) GO TO 200        
      LN = LN + 2        
      GO TO 20        
C        
  180 IF (I .GT. L) GO TO 530        
      IF (V(I).NE.B1 .OR. V(I+1).NE.B2) GO TO 210        
      ASSIGN 190 TO R        
      GO TO 300        
  190 GO TO (40,60,80,100,120,150), TYPE        
  200 GO TO 7820        
  210 I = I + V(I+2) + 3        
      GO TO 180        
C        
  300 NAME(1) = V(I  )        
      NAME(2) = V(I+1)        
      NW = V(I+2)        
      DO 310 M = 1,NW        
      MI = M + I        
  310 VAL(M) = V(MI+2)        
      M = NUMTYP(VAL(1)) + 1        
      GO TO ( 320, 490, 320, 480), M        
C            ZERO,INTG,REAL, BCD        
C        
  320 IF (NW .GT. 1) GO TO 330        
      TYPE = 2        
      GO TO 500        
  330 IF (NW .LT. 4) GO TO 340        
      TYPE = 6        
      GO TO 500        
C        
C     THE 7094 AND 6600 SHOULD BE CORRECT        
C     THE 360 AND 1108 CAN STILL HAVE SOME MISTAKES        
C     VAX IS OK, OTHER UNIX MACHINES FOLLOW VAX              ** MACHX **
C     MACHINES ABOVE 12 NEED TO BE SET CORRECTLY IN NEXT GO TO STATEMENT
C        
C            DUMMY  360  1108  6600   VAX  ULTRIX   SUN   AIX     HP    
C             S/G   MAC  CRAY  CNVX   NEC  FUJISU    DG  AMDL  PRIME    
C             486  DUMMY        
C            ----  ----- ----  ----  ----  ------  ----  ----  -----    
  340 GO TO ( 420,  430,  440,  450,  350,    350,  350,  350,   350,   
     1        350,  350,  410,  350,  350,    350,  350,  350,   350,   
     2        350,  350), MACHX        
C        
C     ****** NEED TEST FOR RDP VS CSP.  I ASSUME CSP FOR NOW.        
C        
  350 GO TO 430        
C        
C     ****** OH MY GOSH, HOW CAN I SOLVE THIS PROBLEM FOR THE VAX       
C        
  410 IF (RSHIFT(VAL(2),48) .EQ. 0) GO TO 470        
      GO TO 460        
  420 IF (MACHX.EQ.1 .AND. IABS(RSHIFT(VAL(1),27)).EQ.        
     1    OO+IABS(RSHIFT(VAL(2),27))) GO TO 470        
      GO TO 460        
  430 IF (RSHIFT(LSHIFT(VAL(2),8),28).EQ.0 .AND. VAL(2).NE.0) GO TO 470 
      GO TO 460        
  440 IF (RSHIFT(LSHIFT(VAL(1),9),35).EQ.1 .AND. RSHIFT(LSHIFT(VAL(2),9)
     1   ,35).EQ.1) GO TO 460        
      IF (VAL(2) .EQ. 0) GO TO 460        
      GO TO 470        
  450 IF (IABS(RSHIFT(VAL(1),48)) .EQ. 48+IABS(RSHIFT(VAL(2),48)))      
     1    GO TO 470        
  460 TYPE = 5        
      GO TO 500        
  470 TYPE = 4        
      GO TO 500        
  480 TYPE = 3        
      GO TO 500        
  490 TYPE = 1        
  500 GO TO R, (30,190)        
C        
  510 WRITE  (NOUT,520)        
  520 FORMAT (1H0,19X,'NO PARAMETERS EXIST')        
      LN = LN + 2        
      GO TO 7820        
  530 WRITE  (NOUT,540) B1,B2        
  540 FORMAT (1H0,19X,'PARAMETER NAMED ',2A4,' IS NOT IN VPS.')        
      LN = LN + 2        
      GO TO 7820        
C        
  550 DO 560 M = 1,32        
      H1(M) = K4(M)        
      H2(M) = K5(M)        
  560 H3(M) = K6(M)        
      CALL PAGE        
      KICK = IABS(IC)        
      DO 570 M = 1,26        
      IF (B1 .NE. BT(M)) GO TO 570        
      MM = M        
      GO TO 590        
  570 CONTINUE        
      LN = LN + 2        
      WRITE  (NOUT,580) B1,B2        
  580 FORMAT ('0SECOND PRTPARM PARAMETER VALUE -',2A4,'- IMPROPER.')    
      GO TO 7810        
  590 IF (KICK.GT.KT(MM) .AND. MM.LE.26) GO TO 600        
      LN = LN + 5        
      GO TO ( 700, 800, 900,1000,1100,1200,1300,1400,1500,1600,        
     1       1700,1800,1900,2000,2100,2200,2300,2400,2500,3000,        
     2       3100,3200,3600,3700,3800,4100), MM        
  600 WRITE  (NOUT,610) KICK        
  610 FORMAT ('0PRTPARM DIAGNOSTIC',I20,' NOT IN TABLE.')        
      LN = LN + 2        
      GO TO 7810        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 1        
C        
  700 GO TO (710,720,730,740,750), KICK        
  710 WRITE (NOUT,4200)        
      GO TO 7800        
  720 WRITE (NOUT,4210)        
      GO TO 7800        
  730 WRITE (NOUT,4220)        
      GO TO 7800        
  740 WRITE (NOUT,4230)        
      GO TO 7800        
  750 WRITE (NOUT,4240)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 2        
C        
  800 GO TO (810,820,830,840,850,860), KICK        
  810 WRITE (NOUT,4300)        
      GO TO 7800        
  820 WRITE (NOUT,4310)        
      GO TO 7800        
  830 WRITE (NOUT,4320)        
      GO TO 7800        
  840 WRITE (NOUT,4330)        
      GO TO 7800        
  850 WRITE (NOUT,4340)        
      GO TO 7800        
  860 WRITE (NOUT,4350)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 3        
C        
  900 GO TO (910,920,930,940), KICK        
  910 WRITE (NOUT,4400)        
      GO TO 7800        
  920 WRITE (NOUT,4410)        
      GO TO 7800        
  930 WRITE (NOUT,4420)        
      GO TO 7800        
  940 WRITE (NOUT,4430)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 4        
C        
 1000 GO TO (1010,1020,1030,1040,1050), KICK        
 1010 WRITE (NOUT,4500)        
      GO TO 7800        
 1020 WRITE (NOUT,4510)        
      GO TO 7800        
 1030 WRITE (NOUT,4520)        
      GO TO 7800        
 1040 WRITE (NOUT,4530)        
      GO TO 7800        
 1050 WRITE (NOUT,4540)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 5        
C        
 1100 GO TO (1110,1120,1130,1140,1150,1160), KICK        
 1110 WRITE (NOUT,4600)        
      GO TO 7800        
 1120 WRITE (NOUT,4610)        
      GO TO 7800        
 1130 WRITE (NOUT,4620)        
      GO TO 7800        
 1140 WRITE (NOUT,4630)        
      GO TO 7800        
 1150 WRITE (NOUT,4640)        
      GO TO 7800        
 1160 WRITE (NOUT,4650)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 6        
C        
 1200 GO TO (1210,1220,1230,1240,1250), KICK        
 1210 WRITE (NOUT,4700)        
      GO TO 7800        
 1220 WRITE (NOUT,4710)        
      GO TO 7800        
 1230 WRITE (NOUT,4720)        
      GO TO 7800        
 1240 WRITE (NOUT,4730)        
      GO TO 7800        
 1250 WRITE (NOUT,4740)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 7        
C        
 1300 GO TO (1310,1320,1330), KICK        
 1310 WRITE (NOUT,4800)        
      GO TO 7800        
 1320 WRITE (NOUT,4810)        
      GO TO 7800        
 1330 WRITE (NOUT,4820)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 8        
C        
 1400 GO TO (1410,1420,1430,1440), KICK        
 1410 WRITE (NOUT,4900)        
      GO TO 7800        
 1420 WRITE (NOUT,4910)        
      GO TO 7800        
 1430 WRITE (NOUT,4920)        
      GO TO 7800        
 1440 WRITE (NOUT,4930)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 9        
C        
 1500 GO TO (1510,1520,1530), KICK        
 1510 WRITE (NOUT,5000)        
      GO TO 7800        
 1520 WRITE (NOUT,5010)        
      GO TO 7800        
 1530 WRITE (NOUT,5020)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 10        
C        
 1600 GO TO (1610,1620,1630,1640,1650), KICK        
 1610 WRITE (NOUT,5100)        
      GO TO 7800        
 1620 WRITE (NOUT,5110)        
      GO TO 7800        
 1630 WRITE (NOUT,5120)        
      GO TO 7800        
 1640 WRITE (NOUT,5130)        
      GO TO 7800        
 1650 WRITE (NOUT,5140)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 11        
C        
 1700 GO TO (1710,1720,1730,1740,1750,1760,1770), KICK        
 1710 WRITE (NOUT,5200)        
      GO TO 7800        
 1720 WRITE (NOUT,5210)        
      GO TO 7800        
 1730 WRITE (NOUT,5220)        
      GO TO 7800        
 1740 WRITE (NOUT,5230)        
      GO TO 7800        
 1750 WRITE (NOUT,5240)        
      GO TO 7800        
 1760 WRITE (NOUT,5250)        
      GO TO 7800        
 1770 WRITE (NOUT,5260)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 12        
C        
 1800 GO TO (1810,1820,1830,1840,1850,1860), KICK        
 1810 WRITE (NOUT,5300)        
      GO TO 7800        
 1820 WRITE (NOUT,5310)        
      GO TO 7800        
 1830 WRITE (NOUT,5320)        
      GO TO 7800        
 1840 WRITE (NOUT,5330)        
      GO TO 7800        
 1850 WRITE (NOUT,5340)        
      GO TO 7800        
 1860 WRITE (NOUT,5350)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 13        
C        
 1900 GO TO (1910,1920,1930,1940,1950,1960), KICK        
 1910 WRITE (NOUT,5400)        
      GO TO 7800        
 1920 WRITE (NOUT,5410)        
      GO TO 7800        
 1930 WRITE (NOUT,5420)        
      GO TO 7800        
 1940 WRITE (NOUT,5430)        
      GO TO 7800        
 1950 WRITE (NOUT,5440)        
      GO TO 7800        
 1960 WRITE (NOUT,5450)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 14        
C        
 2000 GO TO (2010,2020,2030,2040,2050,2060), KICK        
 2010 WRITE (NOUT,5500)        
      GO TO 7800        
 2020 WRITE (NOUT,5510)        
      GO TO 7800        
 2030 WRITE (NOUT,5520)        
      GO TO 7800        
 2040 WRITE (NOUT,5530)        
      GO TO 7800        
 2050 WRITE (NOUT,5540)        
      GO TO 7800        
 2060 WRITE (NOUT,5550)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 15        
C        
 2100 GO TO (2110,2120,2130,2140,2150,2160), KICK        
 2110 WRITE (NOUT,5600)        
      GO TO 7800        
 2120 WRITE (NOUT,5610)        
      GO TO 7800        
 2130 WRITE (NOUT,5620)        
      GO TO 7800        
 2140 WRITE (NOUT,5630)        
      GO TO 7800        
 2150 WRITE (NOUT,5640)        
      GO TO 7800        
 2160 WRITE (NOUT,5650)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 16        
C        
 2200 GO TO (2210,2220,2230,2240,2250), KICK        
 2210 WRITE (NOUT,5700)        
      GO TO 7800        
 2220 WRITE (NOUT,5710)        
      GO TO 7800        
 2230 WRITE (NOUT,5720)        
      GO TO 7800        
 2240 WRITE (NOUT,5730)        
      GO TO 7800        
 2250 WRITE (NOUT,5740)        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 17        
C        
 2300 CONTINUE        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 18        
C        
 2400 CONTINUE        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 19        
C        
 2500 CONTINUE        
      GO TO 7800        
C        
C     HEAT APPROACH - RIGID FORMAT 1        
C        
 3000 GO TO (3010,3020,3030,3040), KICK        
 3010 WRITE (NOUT,6600)        
      GO TO 7800        
 3020 WRITE (NOUT,6610)        
      GO TO 7800        
 3030 WRITE (NOUT,6620)        
      GO TO 7800        
 3040 WRITE (NOUT,6630)        
      GO TO 7800        
C        
C     HEAT APPROACH - RIGID FORMAT 3        
C        
 3100 GO TO (3110,3120,3130), KICK        
 3110 WRITE (NOUT,6700)        
      GO TO 7800        
 3120 WRITE (NOUT,6710)        
      GO TO 7800        
 3130 WRITE (NOUT,6720)        
      GO TO 7800        
C        
C     HEAT APPROACH - RIGID FORMAT 9        
C        
 3200 GO TO (3210,3220), KICK        
 3210 WRITE (NOUT,6800)        
      GO TO 7800        
 3220 WRITE (NOUT,6810)        
      GO TO 7800        
C        
C     AERO APPROACH - RIGID FORMAT 9        
C        
 3600 GO TO (3610,3620,3630,3640,3650,3660,3670), KICK        
 3610 WRITE (NOUT,7200)        
      GO TO 7800        
 3620 WRITE (NOUT,7210)        
      GO TO 7800        
 3630 WRITE (NOUT,7220)        
      GO TO 7800        
 3640 WRITE (NOUT,7230)        
      GO TO 7800        
 3650 WRITE (NOUT,7240)        
      GO TO 7800        
 3660 WRITE (NOUT,7250)        
      GO TO 7800        
 3670 WRITE (NOUT,7260)        
      GO TO 7800        
C        
C     AERO APPROACH - RIGID FORMAT 10        
C        
 3700 GO TO (3710,3720,3730,3740,3750), KICK        
 3710 WRITE (NOUT,7300)        
      GO TO 7800        
 3720 WRITE (NOUT,7310)        
      GO TO 7800        
 3730 WRITE (NOUT,7320)        
      GO TO 7800        
 3740 WRITE (NOUT,7330)        
      GO TO 7800        
 3750 WRITE (NOUT,7340)        
      GO TO 7800        
C        
C     AERO APPROACH - RIGID FORMAT 11        
C        
 3800 GO TO (3810,3820,3830,3840), KICK        
 3810 WRITE (NOUT,7400)        
      GO TO 7800        
 3820 WRITE (NOUT,7410)        
      GO TO 7800        
 3830 WRITE (NOUT,7420)        
      GO TO 7800        
 3840 WRITE (NOUT,7430)        
      GO TO 7800        
C        
C     DMAP APPROACH        
C        
 4100 WRITE (NOUT,7700) KICK        
      GO TO 7800        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 1        
C        
 4200 FORMAT (//////,' STATIC ANALYSIS ERROR NO.1  ATTEMPT TO EXECUTE ',
     1       'MORE THAN 360 LOOPS.')        
 4210 FORMAT (//////,' STATIC ANALYSIS ERROR NO.2  MASS MATRIX REQUIRED'
     1,      ' FOR WEIGHT AND BALANCE CALCULATIONS.')        
 4220 FORMAT (//////,' STATIC ANALYSIS ERROR NO.3  NO INDEPENDENT ',    
     1       'DEGREES OF FREEDOM HAVE BEEN DEFINED.')        
 4230 FORMAT (//////,' STATIC ANALYSIS ERROR NO.4  NO ELEMENTS HAVE ',  
     1       'BEEN DEFINED.')        
 4240 FORMAT (//////,' STATIC ANALYSIS ERROR NO.5  A LOOPING PROBLEM ', 
     1       'RUN ON A NON-LOOPING SUBSET.')        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 2        
C        
 4300 FORMAT (//////,' INERTIA RELIEF ERROR NO.1  MASS MATRIX REQUIRED',
     1       ' FOR CALCULATION OF INERTIA LOADS.')        
 4310 FORMAT (//////,' INERTIA RELIEF ERROR NO.2  ATTEMPT TO EXECUTE ', 
     1       'MORE THAN 360 LOOPS.')        
 4320 FORMAT (//////,' INERTIA RELIEF ERROR NO.3  NO INDEPENDENT ',     
     1       'DEGREES OF FREEDOM HAVE BEEN DEFINED.')        
 4330 FORMAT (//////,' INERTIA RELIEF ERROR NO.4  FREE BODY SUPPORTS ', 
     1       'ARE REQUIRED.')        
 4340 FORMAT (//////,' INERTIA RELIEF ERROR NO.5  A LOOPING PROBLEM ',  
     1       'RUN ON A NON-LOOPING SUBSET.')        
 4350 FORMAT (//////,' INERTIA RELIEF ERROR NO.6  NO STRUCTURAL ',      
     1       'ELEMENTS HAVE BEEN DEFINED.')        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 3        
C        
 4400 FORMAT (//////,' NORMAL MODES ERROR NO.1  MASS MATRIX REQUIRED ', 
     1       'FOR REAL EIGENVALUE ANALYSIS.')        
 4410 FORMAT (//////,' NORMAL MODES ERROR NO.2  EIGENVALUE EXTRACTION ',
     1       'DATA REQUIRED FOR REAL EIGENVALUE ANALYSIS.')        
 4420 FORMAT (//////,' NORMAL MODES ERROR NO.3  NO INDEPENDENT DEGREES',
     1       ' OF FREEDOM HAVE BEEN DEFINED.')        
 4430 FORMAT (//////,' NORMAL MODES ERROR NO.4  NO STRUCTURAL ELEMENTS',
     1       ' HAVE BEEN DEFINED.')        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 4        
C        
 4500 FORMAT (//////,' DIFFERENTIAL STIFFNESS ERROR NO.1  NO STRUCTURAL'
     1,      ' ELEMENTS HAVE BEEN DEFINED.')        
 4510 FORMAT (//////,' DIFFERENTIAL STIFFNESS ERROR NO.2  FREE BODY ',  
     1       'SUPPORTS NOT ALLOWED.')        
 4520 FORMAT (//////,' DIFFERENTIAL STIFFNESS ERROR NO.3  NO GRID POINT'
     1,      ' DATA IS SPECIFIED.')        
 4530 FORMAT (//////,' DIFFERENTIAL STIFFNESS ERROR NO.4  MASS MATRIX ',
     1       'REQUIRED FOR WEIGHT AND BALANCE CALCULATIONS.')        
 4540 FORMAT (//////,' DIFFERENTIAL STIFFNESS ERROR NO.5  NO ',        
     1       'INDEPENDENT DEGREES OF FREEDOM HAVE BEEN DEFINED.')       
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 5        
C        
 4600 FORMAT (//////,' BUCKLING ANALYSIS ERROR NO.1  NO STRUCTURAL ',   
     1       'ELEMENTS HAVE BEEN DEFINED.')        
 4610 FORMAT (//////,' BUCKLING ANALYSIS ERROR NO.2  FREE BODY SUPPORTS'
     1,      ' NOT ALLOWED.')        
 4620 FORMAT (//////,' BUCKLING ANALYSIS ERROR NO.3  EIGENVALUE ',      
     1       'EXTRACTION DATA REQUIRED FOR REAL EIGENVALUE ANALYSIS.')  
 4630 FORMAT (//////,' BUCKLING ANALYSIS ERROR NO.4  NO EIGENVALUES ',  
     1       'FOUND.')        
 4640 FORMAT (//////,' BUCKLING ANALYSIS ERROR NO.5  MASS MATRIX ',     
     1       'REQUIRED FOR WEIGHT AND BALANCE CALCULATIONS.')        
 4650 FORMAT (//////,' BUCKLING ANALYSIS ERROR NO.6  NO INDEPENDENT ',  
     1       'DEGREES OF FREEDOM HAVE BEEN DEFINED.')        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 6        
C        
 4700 FORMAT (//////,' PIECEWISE LINEAR ERROR NO.1  NO NONLINEAR ',     
     1       'ELEMENTS HAVE BEEN DEFINED.')        
 4710 FORMAT (//////,' PIECEWISE LINEAR ERROR NO.2  ATTEMPT TO EXECUTE',
     1       ' MORE THAN 360 LOOPS.')        
 4720 FORMAT (//////,' PIECEWISE LINEAR ERROR NO.3  MASS MATRIX ',      
     1       'REQUIRED FOR WEIGHT AND BALANCE CALCULATIONS.')        
 4730 FORMAT (//////,' PIECEWISE LINEAR ERROR NO.4  NO ELEMENTS HAVE ', 
     1       'BEEN DEFINED.')        
 4740 FORMAT (//////,' PIECEWISE LINEAR ERROR NO.5  STIFFNESS MATRIX ', 
     1       'SINGULAR DUE TO MATERIAL PLASTICITY.')        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 7        
C        
 4800 FORMAT (//////,' DIRECT COMPLEX EIGENVALUE ERROR NO.1  ',        
     1       'EIGENVALUE EXTRACTION DATA REQUIRED FOR COMPLEX ',        
     2       'EIGENVALUE ANALYSIS.')        
 4810 FORMAT (//////,' DIRECT COMPLEX EIGENVALUE ERROR NO.2  ATTEMPT ', 
     1       'TO EXECUTE MORE THAN 100 LOOPS.')        
 4820 FORMAT (//////,' DIRECT COMPLEX EIGENVALUE ERROR NO.3  MASS ',    
     1       'MATRIX REQUIRED FOR WEIGHT AND BALANCE CALCULATIONS.')    
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 8        
C        
 4900 FORMAT (//////,' DIRECT FREQUENCY RESPONSE ERROR NO.1  FREQUENCY',
     1       ' RESPONSE LIST REQUIRED FOR FREQUENCY RESPONSE ',        
     2       'CALCULATIONS.')        
 4910 FORMAT (//////,' DIRECT FREQUENCY RESPONSE ERROR NO.2  DYNAMIC ', 
     1       'LOADS TABLE REQUIRED FOR FREQUENCY RESPONSE CALCULATIONS')
 4920 FORMAT (//////,' DIRECT FREQUENCY RESPONSE ERROR NO.3  ATTEMPT ', 
     1       'TO EXECUTE MORE THAN 100 LOOPS.')        
 4930 FORMAT (//////,' DIRECT FREQUENCY RESPONSE ERROR NO.4  MASS ',    
     1       'MATRIX REQUIRED FOR WEIGHT AND BALANCE CALCULATIONS.')    
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 9        
C        
 5000 FORMAT (//////,' DIRECT TRANSIENT RESPONSE ERROR NO.1  TRANSIENT',
     1       ' RESPONSE LIST REQUIRED FOR TRANSIENT RESPONSE ',        
     2       'CALCULATIONS.')        
 5010 FORMAT (//////,' DIRECT TRANSIENT RESPONSE ERROR NO.2  ATTEMPT ', 
     1       'TO EXECUTE MORE THAN 100 LOOPS.')        
 5020 FORMAT (//////,' DIRECT TRANSIENT RESPONSE ERROR NO.3  MASS ',    
     1       'MATRIX REQUIRED FOR WEIGHT AND BALANCE CALCULATIONS.')    
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 10        
C        
 5100 FORMAT (//////,' MODAL COMPLEX EIGENVALUE ERROR NO.1  MASS MATRIX'
     1,      ' REQUIRED FOR MODAL FORMULATION.')        
 5110 FORMAT (//////,' MODAL COMPLEX EIGENVALUE ERROR NO.2  EIGENVALUE',
     1       ' EXTRACTION DATA REQUIRED FOR REAL EIGENVALUE ANALYSIS.') 
 5120 FORMAT (//////,' MODAL COMPLEX EIGENVALUE ERROR NO.3  ATTEMPT TO',
     1       ' EXECUTE MORE THAN 100 LOOPS.')        
 5130 FORMAT (//////,' MODAL COMPLEX EIGENVALUE ERROR NO.4  REAL ',     
     1       'EIGENVALUES REQUIRED FOR MODAL FORMULATION.')        
 5140 FORMAT (//////,' MODAL COMPLEX EIGENVALUE ERROR NO.5  NO ',       
     1       'STRUCTURAL ELEMENTS HAVE BEEN DEFINED.')        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 11        
C        
 5200 FORMAT (//////,' MODAL FREQUENCY RESPONSE ERROR NO.1  MASS MATRIX'
     1,      ' REQUIRED FOR MODAL FORMULATION.')        
 5210 FORMAT (//////,' MODAL FREQUENCY RESPONSE ERROR NO.2  EIGENVALUE',
     1       ' EXTRACTION DATA REQUIRED FOR REAL EIGENVALUE ANALYSIS.') 
 5220 FORMAT (//////,' MODAL FREQUENCY RESPONSE ERROR NO.3  ATTEMPT TO',
     1       ' EXECUTE MORE THAN 100 LOOPS.')        
 5230 FORMAT (//////,' MODAL FREQUENCY RESPONSE ERROR NO.4  REAL ',     
     1       'EIGENVALUES REQUIRED FOR MODAL FORMULATION.')        
 5240 FORMAT (//////,' MODAL FREQUENCY RESPONSE ERROR NO.5  FREQUENCY ',
     1       'RESPONSE LIST REQUIRED FOR FREQUENCY RESPONSE ',        
     2       'CALCULATIONS.')        
 5250 FORMAT (//////,' MODAL FREQUENCY RESPONSE ERROR NO.6  DYNAMIC ',  
     1       'LOADS TABLE REQUIRED FOR FREQUENCY RESPONSE CALCULATIONS')
 5260 FORMAT (//////,' MODAL FREQUENCY RESPONSE ERROR NO.7  NO ',       
     1       'STRUCTURAL ELEMENTS HAVE BEEN DEFINED.')        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 12        
C        
 5300 FORMAT (//////,' MODAL TRANSIENT RESPONSE ERROR NO.1  MASS MATRIX'
     1,      ' REQUIRED FOR MODAL FORMULATION.')        
 5310 FORMAT (//////,' MODAL TRANSIENT RESPONSE ERROR NO.2 EIGENVALUE ',
     1       'EXTRACTION DATA REQUIRED FOR REAL EIGENVALUE ANALYSIS.')  
 5320 FORMAT (//////,' MODAL TRANSIENT RESPONSE ERROR NO.3 ATTEMPT TO ',
     1       'EXECUTE MORE THAN 100 LOOPS.')        
 5330 FORMAT (//////,' MODAL TRANSIENT RESPONSE ERROR NO.4 REAL ',      
     1       'EIGENVALUES REQUIRED FOR MODAL FORMULATION.')        
 5340 FORMAT (//////,' MODAL TRANSIENT RESPONSE ERROR NO.5 TRANSIENT ', 
     1       'RESPONSE LIST REQUIRED FOR TRANSIENT RESPONSE ',        
     2       'CALCULATIONS.')        
 5350 FORMAT (//////,' MODAL TRANSIENT RESPONSE ERROR NO.6 NO ',        
     1       'STRUCTURAL ELEMENTS HAVE BEEN DEFINED.')        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 13        
C        
 5400 FORMAT (//////,' NORMAL MODES WITH DIFFERENTIAL STIFFNESS ERROR ',
     1       'NO.1  NO STRUCTURAL ELEMENTS HAVE BEEN DEFINED.')        
 5410 FORMAT (//////,' NORMAL MODES WITH DIFFERENTIAL STIFFNESS ERROR ',
     1       'NO.2  FREE BODY SUPPORTS NOT ALLOWED.')        
 5420 FORMAT (//////,' NORMAL MODES WITH DIFFERENTIAL STIFFNESS ERROR ',
     1       'NO.3  EIGENVALUE EXTRACTION DATA REQUIRED FOR REAL ',     
     2       'EIGENVALUE ANALYSIS.')        
 5430 FORMAT (//////,' NORMAL MODES WITH DIFFERENTIAL STIFFNESS ERROR ',
     1       'NO.4  NO EIGENVALUE FOUND.')        
 5440 FORMAT (//////,' NORMAL MODES WITH DIFFERENTIAL STIFFNESS ERROR ',
     1       'NO. 5  MASS MATRIX REQUIRED FOR REAL EIGENVALUE ANALYSIS')
 5450 FORMAT (//////,' NORMAL MODES WITH DIFFERENTIAL STIFFNESS ERROR ',
     1       'NO. 6  NO INDEPENDENT DEGREES OF FREEDOM HAVE BEEN ',     
     2       'DEFINED.')        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 14        
C        
 5500 FORMAT (//////,' STATICS WITH CYCLIC TRANSFORMATION ERROR NO. 1 ',
     1       ' ATTEMPT TO EXECUTE MORE THAN 360 LOOPS.')        
 5510 FORMAT (//////,' STATICS WITH CYCLIC TRANSFORMATION ERROR NO. 2  '
     1,      'MASS MATRIX REQUIRED FOR WEIGHT AND BALANCE CALCULATIONS')
 5520 FORMAT (//////,' STATICS WITH CYCLIC TRANSFORMATION ERROR NO. 3 ',
     1       ' NO INDEPENDENT DEGREES OF FREEDOM HAVE BEEN DEFINED.')   
 5530 FORMAT (//////,' STATICS WITH CYCLIC TRANSFORMATION ERROR NO. 4 ',
     1       ' NO ELEMENTS HAVE BEEN DEFINED.')        
 5540 FORMAT (//////,' STATICS WITH CYCLIC TRANSFORMATION ERROR NO. 5 ',
     1       ' CYCLIC TRANSFORMATION DATA ERROR.')        
 5550 FORMAT (//////,' STATICS WITH CYCLIC TRANSFORMATION ERROR NO. 6 ',
     1       ' FREE BODY SUPPORTS NOT ALLOWED.')        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 15        
C        
 5600 FORMAT (//////,' NORMAL MODES WITH CYCLIC TRANSFORMATION ERROR ', 
     1       'NO. 1  MASS MATRIX REQUIRED FOR REAL EIGENVALUE ANALYSIS')
 5610 FORMAT (//////,' NORMAL MODES WITH CYCLIC TRANSFORMATION ERROR ', 
     1       'NO. 2  EIGENVALUE EXTRACTION DATA REQUIRED FOR REAL ',    
     2       'EIGENVALUE ANALYSIS.')        
 5620 FORMAT (//////,' NORMAL MODES WITH CYCLIC TRANSFORMATION ERROR ', 
     1       'NO. 3  NO INDEPENDENT DEGREES OF FREEDOM HAVE BEEN ',     
     2       'DEFINED.')        
 5630 FORMAT (//////,' NORMAL MODES WITH CYCLIC TRANSFORMATION ERROR ', 
     1       'NO. 4  FREE BODY SUPPORTS NOT ALLOWED.')        
 5640 FORMAT (//////,' NORMAL MODES WITH CYCLIC TRANSFORMATION ERROR ', 
     1       'NO. 5  CYCLIC TRANSFORMATION DATA ERROR.')        
 5650 FORMAT (//////,' NORMAL MODES WITH CYCLIC TRANSFORMATION ERROR ', 
     1       'NO. 6  NO STRUCTURAL ELEMENTS HAVE BEEN DEFINED.')        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 16        
C        
 5700 FORMAT (//////,' AEROTHERMOELASTIC ERROR NO. 1  NO STRUCTURAL ',  
     1       'ELEMENTS HAVE BEEN DEFINED.')        
 5710 FORMAT (//////,' AEROTHERMOELASTIC ERROR NO. 2  FREE BODY ',      
     1       'SUPPORTS NOT ALLOWED.')        
 5720 FORMAT (//////,' AEROTHERMOELASTIC ERROR NO. 3  NO GRID POINT ',  
     1       'DATA IS SPECIFIED.')        
 5730 FORMAT (//////,' AEROTHERMOELASTIC ERROR NO. 4  MASS MATRIX ',    
     1       'REQUIRED FOR WEIGHT AND BALANCE CALCULATIONS.')        
 5740 FORMAT (//////,' AEROTHERMOELASTIC ERROR NO. 5  NO INDEPENDENT ', 
     1       'DEGREES OF FREEDOM HAVE BEEN DEFINED.')        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 17        
C        
C5800 FORMAT (//)        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 18        
C        
C5900 FORMAT (//)        
C        
C     DISPLACEMENT APPROACH - RIGID FORMAT 19        
C        
C6000 FORMAT (//)        
C        
C        
C     HEAT APPROACH - RIGID FORMAT 1        
C        
 6600 FORMAT (//////,' STATIC HEAT TRANSFER ERROR NO. 1  ATTEMPT TO ',  
     1       'EXECUTE MORE THAN 100 LOOPS.')        
 6610 FORMAT (//////,' STATIC HEAT TRANSFER ERROR NO. 2  LOOPING ',     
     1       'PROBLEM RUN ON A NON-LOOPING SUBSET.')        
 6620 FORMAT (//////,' STATIC HEAT TRANSFER ERROR NO. 3  NO INDEPENDENT'
     1,      ' DEGREES OF FREEDOM HAVE BEEN DEFINED.')        
 6630 FORMAT (//////,' STATIC HEAT TRANSFER ERROR NO. 4  NO ELEMENTS ', 
     1       'HAVE BEEN DEFINED.')        
C        
C     HEAT APPROACH - RIGID FORMAT 3        
C        
 6700 FORMAT (//////,' NONLINEAR STATIC HEAT TRANSFER ERROR NO. 1  NO ',
     1       'INDEPENDENT DEGREES OF FREEDOM HAVE BEEN DEFINED.')       
 6710 FORMAT (//////,' NONLINEAR STATIC HEAT TRANSFER ERROR NO. 2  NO ',
     1       'SIMPLE STRUCTURAL ELEMENTS.')        
 6720 FORMAT (//////,' NONLINEAR STATIC HEAT TRANSFER ERROR NO. 3  ',   
     1       'STIFFNESS MATRIX SINGULAR.')        
C        
C     HEAT APPROACH - RIGID FORMAT 9        
C        
 6800 FORMAT (//////,' TRANSIENT HEAT TRANSFER ERROR NO. 1  TRANSIENT ',
     1       'RESPONSE LIST REQUIRED FOR TRANSIENT RESPONSE ',        
     2       'CALCULATIONS.')        
 6810 FORMAT (//////,' TRANSIENT HEAT TRANSFER ERROR NO. 2  ATTEMPT ',  
     1       'TO EXECUTE MORE THAN 100 LOOPS.')        
C        
C     AERO APPROACH - RIGID FORMAT 9        
C        
 7200 FORMAT (//////,' BLADE FLUTTER ANALYSIS ERROR NO. 1  MASS MATRIX',
     1       ' REQUIRED FOR MODAL FORMULATION.')        
 7210 FORMAT (//////,' BLADE FLUTTER ANALYSIS ERROR NO. 2  EIGENVALUE ',
     1       'EXTRACTION DATA REQUIRED FOR REAL EIGENVALUE ANALYSIS.')  
 7220 FORMAT (//////,' BLADE FLUTTER ANALYSIS ERROR NO. 3  ATTEMPT TO ',
     1       'EXECUTE MORE THAN 100 LOOPS.')        
 7230 FORMAT (//////,' BLADE FLUTTER ANALYSIS ERROR NO. 4  REAL ',      
     1       'EIGENVALUES REQUIRED FOR MODAL FORMULATION.')        
 7240 FORMAT (//////,' BLADE FLUTTER ANALYSIS ERROR NO. 5  NO GRID ',   
     1       'POINT DATA IS SPECIFIED OR NO STRUCTURAL ELEMENTS HAVE ', 
     2       'BEEN DEFINED.')        
 7250 FORMAT (//////,' BLADE FLUTTER ANALYSIS ERROR NO. 6  FREE BODY ', 
     1       'SUPPORTS NOT ALLOWED.')        
 7260 FORMAT (//////,' BLADE FLUTTER ANALYSIS ERROR NO. 7  CYCLIC ',    
     1       'TRANSFORMATION DATA ERROR.')        
C        
C     AERO APPROACH - RIGID FORMAT 10        
C        
 7300 FORMAT (//////,' MODAL FLUTTER ANALYSIS ERROR NO. 1  MASS MATRIX',
     1       ' REQUIRED FOR MODAL FORMULATION.')        
 7310 FORMAT (//////,' MODAL FLUTTER ANALYSIS ERROR NO. 2  EIGENVALUE ',
     1       'EXTRACTION DATA REQUIRED FOR REAL EIGENVALUE ANALYSIS.')  
 7320 FORMAT (//////,' MODAL FLUTTER ANALYSIS ERROR NO. 3  ATTEMPT TO ',
     1       'EXECUTE MORE THAN 100 LOOPS.')        
 7330 FORMAT (//////,' MODAL FLUTTER ANALYSIS ERROR NO. 4  REAL ',      
     1       'EIGENVALUES REQUIRED FOR MODAL FORMULATION.')        
 7340 FORMAT (//////,' MODAL FLUTTER ANALYSIS ERROR NO. 5  NO GRID ',   
     1       'POINT DATA IS SPECIFIED OR NO STRUCTURAL ELEMENTS HAVE ', 
     2       'BEEN DEFINED.')        
C        
C    AERO APPROACH - RIGID FORMAT 11        
C        
 7400 FORMAT (//////,' MODAL AEROELASTIC RESPONSE ERROR NO. 1  MASS ',  
     1       'MATRIX REQUIRED FOR MODAL FORMULATION.')        
 7410 FORMAT (//////,' MODAL AEROELASTIC RESPONSE ERROR NO. 2  ',       
     1       'EIGENVALUE EXTRACTION DATA REQUIRED FOR REAL EIGENVALUE ',
     2       'ANALYSIS.')        
 7420 FORMAT (//////,' MODAL AEROELASTIC RESPONSE ERROR NO. 3  NO GRID',
     1       ' POINT DATA IS SPECIFIED OR NO STRUCTURAL ELEMENTS HAVE ',
     2       'BEEN DEFINED.')        
 7430 FORMAT (//////,' MODAL AEROELASTIC RESPONSE ERROR NO. 4  REAL ',  
     1       'EIGENVALUES REQUIRED FOR MODAL FORMULATION.')        
C        
C     DMAP APPROACH        
C        
 7700 FORMAT (//////,10X,'DMAP ERROR',3X,I20)        
 7800 IF (IC .GE. 0) RETURN        
C        
 7810 CONTINUE        
      CALL MESAGE (-61,0,0)        
C        
 7820 RETURN        
C        
      END        
