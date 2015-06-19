      SUBROUTINE XGPIDG (NCODE,IX,JX,K)        
C        
C     THE PURPOSE OF XGPIDG IS TO WRITE DIAGNOSTIC MESSAGES FOR EXGPI   
C        
C     ICODE  = A SIGNED INTEGER WHICH INDICATES DIAGNOSTIC MESSAGE TO   
C              OUTPUT.        
C     NODMAP = DMAP CARD NUMBER.        
C        
      EXTERNAL        LSHIFT,RSHIFT,ANDF        
      INTEGER         IX(1),JX(1),DMPCNT,DMPPNT,BCDCNT,DMAP,OSPRC,OSBOT,
     1                OSPNT,OSCAR(1),OTAPID,OP,RSHIFT,ANDF,CPPGCT       
      DIMENSION       MED(1),IBF(6),MPL(1),OS(5)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM        
      COMMON /STAPID/ TAPID(6),OTAPID(6)        
      COMMON /SYSTEM/ ZSYS(90),LPCH        
C                  ** CONTROL CARD NAMES **        
C                  ** DMAP CARD NAMES **        
      COMMON /XGPIC / ICOLD,ISLSH,IEQUL,NBLANK,NXEQUI,        
     1                NDIAG,NSOL,NDMAP,NESTM1,NESTM2,NEXIT,        
     2                NBEGIN,NEND,NJUMP,NCOND,NREPT,NTIME,NSAVE,        
     3                NOUTPT,NCHKPT,NPURGE,NEQUIV,        
     4                NCPW,NBPC,NWPC,        
     5                MASKHI,MASKLO,ISGNON,NOSGN,IALLON,MASKS(1)        
CZZ   COMMON /ZZXGPI/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /XGPI2 / LMPL,MPLPNT,MPL        
      COMMON /XGPI4 / IRTURN,INSERT,ISEQN,DMPCNT,        
     1                IDMPNT,DMPPNT,BCDCNT,LENGTH,ICRDTP,ICHAR,NEWCRD,  
     2                MODIDX,LDMAP,ISAVDW,DMAP(1)        
      COMMON /MODDMP/ IFLG(6),NAMOPT(26)        
      EQUIVALENCE     (CORE(1),OS(1),LOSCAR),(OSPRC,OS(2)),(OSBOT,OS(3))
     1,               (OSPNT,OS(4)),(OSCAR(1),MED(1),OS(5))        
      EQUIVALENCE     (ZSYS(1),BUFSZ),(ZSYS(2),OP),(ZSYS(3),NOGO),      
     1                (ZSYS(9),NLPP),(ZSYS(12),NLINES),(ZSYS(26),CPPGCT)
     2,               (ZSYS(77),ISYS77)        
      EQUIVALENCE     (MPL(1),IBF(1))        
      DATA    NLABL1/ 4HLABE/, NLABL2/4HL   /        
C        
C     SET NOGO FLAG IF NCODE IS POSITIVE        
C        
      IF (NCODE .GT. 0 .AND. NOGO .LT. 1) NOGO = 1        
      I      = IX(1)        
      J      = JX(1)        
      KDHCOD = 0        
      ICODE  = IABS(NCODE)        
C        
C     BRANCH ON ICODE AND WRITE ERROR MESSAGE.        
C        
      IF (ICODE.EQ.0 .OR. ICODE.GT.73) GO TO 1830        
      NLINES = NLINES + 3        
      IF (NLINES .GE. NLPP) CALL PAGE        
      GO TO ( 220, 250, 280, 310, 340, 370, 400, 430, 460, 490,        
     1        520, 550, 580, 610, 650, 680, 710, 740, 770, 800,        
     2        830, 860, 890, 920, 950, 980,1010,1040,1070,1100,        
     3       1130,1160,1190,1220,1250,1280,1310,1340,1370,1400,        
     4       1430,1460,1490,1520,1550,1580,1610,1640,1670,1710,        
     5       1740,1770,1800,1822,3310,3340,3370,3400,3430,3470,        
     6       3500,3600,3700,1830,1830,1830,1830,1830,3800,3900,        
     7       4000,4100,4200), ICODE        
C        
C     STANDARD ERROR MESSAGES        
C        
   10 NODMAP = ANDF(OSCAR(I+5),NOSGN)        
      ASSIGN 30 TO LX        
   20 IF (NCODE) 130,1830,150        
   30 NME1= OSCAR(I+3)        
      IF (NCODE .LT. 0) GO TO 60        
      WRITE  (OP,50) NME1,OSCAR(I+4),NODMAP        
   50 FORMAT (30X,'ERROR IN DMAP INSTRUCTION ',2A4,3X,        
     1       'INSTRUCTION NO.',I4)        
      GO TO 80        
   60 WRITE  (OP,70) NME1,OSCAR(I+4),NODMAP        
   70 FORMAT (30X,'POSSIBLE ERROR IN DMAP INSTRUCTION ',2A4,3X,        
     1       'INSTRUCTION NO.',I4)        
   80 GO TO L, ( 290, 380, 410, 470, 500, 530, 660, 690, 810, 840,      
     1           960, 990, 720, 750,1320,1470,1500,1530,1560, 230,      
     2           870, 900, 260,1170,1620,1650, 320,1140,1200,1230,      
     3           930,1290,1380,1440,1680,1720,3502,3602,3702)        
C        
   90 ASSIGN 80 TO LX        
      IF (NCODE) 170,1830,190        
C        
  100 ASSIGN 110 TO LX        
      GO TO 190        
  110 WRITE  (OP,120)        
  120 FORMAT (30X,'UNEXPECTED END OF TAPE.')        
      GO TO L, (1050,1080,1110)        
C        
  130 IF (KDHCOD .EQ. 1) GO TO 142        
      WRITE  (OP,140) UWM,ICODE        
  140 FORMAT (A25,I5,1H,)        
      GO TO  210        
  142 WRITE  (OP,144) ICODE        
  144 FORMAT (/,' *** USER POTENTIALLY FATAL MESSAGE',I4,1H,)        
      IF (IFLG(2) .LT. 2) NOGO = 1        
      GO TO  210        
  150 WRITE  (OP,160) UFM,ICODE        
  160 FORMAT (A23,I4,1H,)        
      GO TO  210        
  170 WRITE  (OP,180) SWM,ICODE        
  180 FORMAT (A27,I4,1H,)        
      GO TO  210        
  190 WRITE  (OP,200) SFM,ICODE        
  200 FORMAT (A25,I4,1H,)        
C        
  210 GO TO LX, ( 350, 440, 560, 590, 620, 780,1020,1260,1350,1410,     
     1           1590,1750,1780,1810,1824,  30,  80, 110,3312,3342,     
     2           3372,3402,3432,3472,3802,3902,4002,4102,4202)        
C        
C     ERROR MESSAGE  1   (XIOFL)        
C        
  220 ASSIGN 230 TO L        
      GO TO  10        
  230 WRITE  (OP,240)        
  240 FORMAT (5X,'ASSUMED FIRST INPUT DATA BLOCK IS NULL')        
      GO TO  1850        
C        
C     ERROR MESSAGE  2   (XOSGEN)        
C        
  250 ASSIGN 260 TO L        
      GO TO  10        
  260 WRITE  (OP,270) J,K        
  270 FORMAT (5X,'PARAMETER NAMED ',2A4,' IS DUPLICATED')        
      GO TO  1850        
C        
C     ERROR MESSAGE  3   (XPARAM)        
C        
  280 ASSIGN 290 TO L        
      GO TO  10        
  290 WRITE  (OP,300) J        
  300 FORMAT (5X,'FORMAT ERROR IN PARAMETER NO.',I3)        
      GO TO  1850        
C        
C     ERROR MESSAGE  4   (XPARAM)        
C        
  310 ASSIGN 320 TO L        
      GO TO  90        
  320 WRITE  (OP,330) OSCAR(I+3),OSCAR(I+4),J        
  330 FORMAT (5X,'MPL PARAMETER ERROR,MODULE NAME = ',2A4,3X,        
     1       'PARAMETER NO.',I3)        
      GO TO  1850        
C        
C     ERROR MESSAGE  5   (XPARAM)        
C        
  340 ASSIGN 350 TO LX        
      GO TO  20        
  350 WRITE  (OP,360) J,K        
  360 FORMAT (30X,'PARAMETER INPUT DATA ERROR, ILLEGAL TYPE FOR ',      
     1       'PARAMETER NAMED ',2A4,1H.)        
      GO TO 1850        
C        
C     ERROR MESSAGE  6   (XPARAM)        
C        
  370 ASSIGN 380 TO L        
      GO TO  10        
  380 WRITE  (OP,390) J        
  390 FORMAT (5X,'ILLEGAL TYPE FOR PARAMETER NO.',I3)        
      GO TO  1850        
C        
C     ERROR MESSAGE  7   (XPARAM)        
C        
  400 ASSIGN 410 TO L        
      GO TO  10        
  410 WRITE  (OP,420) J        
  420 FORMAT (5X,'PARAMETER NO.',I3,' NEEDS PARAMETER NAME')        
      GO TO  1850        
C        
C     ERROR MESSAGE  8   (XPARAM)        
C        
  430 ASSIGN 440 TO LX        
      GO TO 20        
  440 WRITE  (OP,450) J,K        
  450 FORMAT (30X,'BULK DATA PARAM CARD ERROR - MUST NOT DEFINE ',      
     1       'PARAMETER NAMED ',2A4,1H.)        
      GO TO 1850        
C        
C     ERROR MESSAGE  9   (XPARAM)        
C        
  460 ASSIGN 470 TO L        
      GO TO  10        
  470 WRITE  (OP,480) J        
  480 FORMAT (5X,'VALUE NEEDED FOR PARAMETER NO.',I3)        
      GO TO  1850        
C        
C     ERROR MESSAGE 10   (XOSGEN)        
C        
  490 ASSIGN 500 TO L        
      KDHCOD = 1        
      GO TO  10        
  500 WRITE  (OP,510)        
  510 FORMAT (5X,'DEFAULT OPTION FOR INPUT DATA BLOCKS - MAKE SURE ',   
     1       'MISSING BLOCKS ARE NOT REQUIRED.')        
      GO TO 1850        
C        
C     ERROR MESSAGE 11   (XOSGEN)        
C        
  520 ASSIGN 530 TO L        
      KDHCOD = 1        
      GO TO  10        
  530 WRITE  (OP,540)        
  540 FORMAT (5X,'DEFAULT OPTION FOR OUTPUT DATA BLOCKS - MAKE SURE ',  
     1       'MISSING BLOCKS ARE NOT REQUIRED.')        
      GO TO 1850        
C        
C     ERROR MESSAGE 12   (XOSGEN)        
C        
  550 ASSIGN 560 TO LX        
      GO TO  20        
  560 WRITE  (OP,570) J        
  570 FORMAT (30X,'ERROR IN DMAP INSTRUCTION NO.',I4,        
     1       ', ILLEGAL CHARACTER IN DMAP INSTRUCTION NAME.')        
      GO TO  1850        
C        
C     ERROR MESSAGE 13   (XOSGEN)        
C        
  580 ASSIGN 590 TO LX        
      GO TO  20        
  590 WRITE  (OP,50) DMAP(J),DMAP(J+1),K        
      WRITE  (OP,600)        
  600 FORMAT (30X,'DMAP INSTRUCTION NOT IN MODULE LIBRARY.')        
      GO TO  1850        
C        
C     ERROR MESSAGE 14   (XOSGEN,XPARAM,XFLORD,XGPI,XSCNDM)        
C        
  610 ASSIGN 620 TO LX        
      GO TO  190        
  620 WRITE  (OP,630) I,J        
  630 FORMAT (5X,'ARRAY NAMED ',2A4,' OVERFLOWED')        
      IF (K .EQ. 0) GO TO 1850        
      WRITE  (OP,640) K        
  640 FORMAT (50X,'AT DMAP INSTRUCTION NO. ',I4,1H.)        
      GO TO  1850        
C        
C     ERROR MESSAGE 15   (XPARAM)        
C        
  650 ASSIGN 660 TO L        
      GO TO  10        
  660 WRITE  (OP,670) J,K        
  670 FORMAT (5X,'INCONSISTENT TYPE USED FOR PARAMETER NAMED ',2A4)     
      GO TO  1850        
C        
C     ERROR MESSAGE 16   (XOSGEN)        
C        
  680 ASSIGN 690 TO L        
      GO TO  10        
  690 WRITE  (OP,700)        
  700 FORMAT (5X,'ILLEGAL FORMAT')        
      GO TO  1850        
C        
C     ERROR MESSAGE 17   (XOSGEN)        
C        
  710 ASSIGN 720 TO L        
      GO TO  10        
  720 WRITE  (OP,730)        
  730 FORMAT (5X,'ILLEGAL TIME SEGMENT NAME - NO TIME ESTIMATES MADE',  
     1       ' FOR THIS TIME SEGMENT (WARNING ONLY)')        
      GO TO  1850        
C        
C     ERROR MESSAGE 18   (XPARAM)        
C        
  740 ASSIGN 750 TO L        
      GO TO  10        
  750 WRITE  (OP,760)        
  760 FORMAT (5X,'TOO MANY PARAMETERS IN DMAP PARAMETER LIST')        
      GO TO  1850        
C        
C     ERROR MESSAGE 19   (XOSGEN)        
C        
  770 ASSIGN 780 TO LX        
      GO TO  20        
  780 WRITE  (OP,50) NLABL1,NLABL2,I        
      WRITE  (OP,790) DMAP(J),DMAP(J+1)        
  790 FORMAT (30X,'LABEL NAMED ',2A4,' IS MULTIPLY DEFINED.')        
      GO TO  1850        
C        
C     ERROR MESSAGE 20   (XOSGEN)        
C        
  800 ASSIGN 810 TO L        
      GO TO  10        
  810 WRITE  (OP,820) J        
  820 FORMAT (5X,'ILLEGAL CHARACTERS IN PARAMETER NO.',I3)        
      GO TO  1850        
C        
C     ERROR MESSAGE 21   (XOSGEN)        
C        
  830 ASSIGN 840 TO L        
      GO TO  10        
  840 WRITE  (OP,850) J,K        
  850 FORMAT (5X,'PARAMETER NAMED ',2A4,' IS NOT IN PRECEDING DMAP ',   
     1        'INSTRUCTION PARAMETER LIST')        
      GO TO  1850        
C        
C     ERROR MESSAGE 22   (XFLORD)        
C        
  860 ASSIGN 870 TO L        
      KDHCOD = 1        
      GO TO  10        
  870 WRITE  (OP,880) J,K        
  880 FORMAT (5X,'DATA BLOCK NAMED ',2A4,' APPEARS AS INPUT BEFORE ',   
     1       'BEING DEFINED')        
      GO TO  1850        
C        
C     ERROR MESSAGE 23   (XFLORD)        
C        
  890 ASSIGN 900 TO L        
      GO TO  10        
  900 WRITE  (OP,910) J,K        
  910 FORMAT (5X,'DATA BLOCK NAMED ',2A4,' IS NOT REFERENCED IN ',      
     1       'SUBSEQUENT FUNCTIONAL MODULE')        
      GO TO  1850        
C        
C     ERROR MESSAGE 24   (XGPI)        
C        
  920 ASSIGN 930 TO L        
      GO TO  90        
  930 WRITE  (OP,940) I,J        
  940 FORMAT (5X,'CANNOT FIND DATA BLOCK NAMED ',2A4,' ON DATA POOL ',  
     1       'TABLE ')        
      GO TO  1850        
C        
C     ERROR MESSAGE 25   (XOSGEN)        
C        
  950 ASSIGN 960 TO L        
      GO TO  10        
  960 WRITE  (OP,970) J,K        
  970 FORMAT (5X,'PARAMETER NAMED ',2A4,' NOT DEFINED')        
      GO TO  1850        
C        
C     ERROR MESSAGE 26   (XOSGEN)        
C        
  980 ASSIGN 990 TO L        
      GO TO  10        
  990 WRITE  (OP,1000) J,K        
 1000 FORMAT (5X,'LABEL NAMED ',2A4,' NOT DEFINED')        
      GO TO  1850        
C        
C     ERROR MESSAGE 27   (XOSGEN)        
C        
 1010 ASSIGN 1020 TO LX        
      GO TO  20        
 1020 WRITE  (OP,1030) J,K        
 1030 FORMAT (5X,'LABEL NAMED ',2A4,' NOT REFERENCED')        
      GO TO  1850        
C        
C     ERROR MESSAGE 28   (XGPI)        
C        
 1040 ASSIGN 1050 TO L        
      GO TO  100        
 1050 WRITE  (OP,1060)        
 1060 FORMAT (61X,'ON NEW PROBLEM TAPE.')        
      GO TO  1850        
C        
C     ERROR MESSAGE 29   (XGPI)        
C        
 1070 ASSIGN 1080 TO L        
      GO TO  100        
 1080 WRITE  (OP,1090)        
 1090 FORMAT (61X,'ON OLD PROBLEM TAPE.')        
      GO TO  1850        
C        
C     ERROR MESSAGE 30   (XGPI)        
C        
 1100 ASSIGN 1110 TO L        
      GO TO  100        
 1110 WRITE  (OP,1120)        
 1120 FORMAT (61X,'ON DATA POOL FILE.')        
      GO TO  1850        
C        
C     ERROR MESSAGE 31   (XGPI)        
C        
 1130 ASSIGN 1140 TO L        
      GO TO  90        
 1140 WRITE  (OP,1150) I,J        
 1150 FORMAT (5X,'CONTROL FILE ',2A4,' INCOMPLETE OR MISSING ON NEW ',  
     1       'PROBLEM TAPE')        
      GO TO  1850        
C        
C     ERROR MESSAGE 32   (XFLORD)        
C        
 1160 ASSIGN 1170 TO L        
      GO TO  10        
 1170 WRITE  (OP,1180) J,K        
 1180 FORMAT (5X,'DATA BLOCK NAMED ',2A4,' MUST BE DEFINED PRIOR TO ',  
     1       'THIS INSTRUCTION')        
      GO TO  1850        
C        
C     ERROR MESSAGE 33   (XGPI)        
C        
 1190 ASSIGN 1200 TO L        
      GO TO  90        
 1200 WRITE  (OP,1210) I,J        
 1210 FORMAT (5X,'SCRATCH FILE CONTAINING DMAP DATA COULD NOT BE ',     
     1       'OPENED IN SUBROUTINE ',2A4)        
      GO TO 1850        
C        
C     ERROR MESSAGE 34   (XSCNDM)        
C        
 1220 ASSIGN 1230 TO L        
      GO TO  90        
 1230 WRITE  (OP,1240) J        
 1240 FORMAT (5X,'CANNOT TRANSLATE DMAP INSTRUCTION NO.',I3)        
      GO TO  1850        
C        
C     ERROR MESSAGE 35   (XGPI)        
C        
 1250 ASSIGN 1260 TO LX        
      GO TO  20        
 1260 M = LSHIFT(IBF(5),7)        
      IYEAR = RSHIFT(ANDF(M,MASKHI),7)        
      M = RSHIFT(M,6)        
      IDAY  = RSHIFT(ANDF(M,MASKHI),9)        
      M = RSHIFT(M,5)        
      IMNTH = RSHIFT(ANDF(M,MASKHI),10)        
      N = LSHIFT(OTAPID(5),7)        
      JYEAR = RSHIFT(ANDF(N,MASKHI),7)        
      N = RSHIFT(N,6)        
      JDAY  = RSHIFT(ANDF(N,MASKHI),9)        
      N = RSHIFT(N,5)        
      JMNTH = RSHIFT(ANDF(N,MASKHI),10)        
      WRITE  (OP,1270) (IBF(I),M=1,4),IMNTH,IDAY,IYEAR,IBF(6),        
     1                 (OTAPID(J),N=1,4),JMNTH,JDAY,JYEAR,OTAPID(6)     
 1270 FORMAT (30X,'INCORRECT OLD PROBLEM TAPE MOUNTED -', /5X,        
     1       'ID OF TAPE MOUNTED= ',2A4,1H,,2A4,1H,,I3,1H/,I2,1H/,I2,   
     1       'REEL=',I2, /5X,        
     2       'ID OF TAPE DESIRED= ',2A4,1H,,2A4,1H,,I3,1H/,I2,1H/,I2,   
     3       'REEL=',I2)        
      GO TO 1850        
C        
C     ERROR MESSAGE 36   (XGPI)        
C        
 1280 ASSIGN 1290 TO L        
      GO TO  90        
 1290 WRITE  (OP,1300) I,J        
 1300 FORMAT (5X,'CANNOT FIND DATA BLOCK NAMED ',2A4,' ON OLD PROBLEM', 
     1       ' TAPE')        
      GO TO 1850        
C        
C     ERROR MESSAGE 37   (XGPI)        
C        
 1310 IF (ISYS77 .LE. -1) GO TO 1850        
      ASSIGN 1320 TO L        
      GO TO  10        
 1320 WRITE  (OP,1330) J,K        
 1330 FORMAT (5X,'WARNING ONLY - MAY NOT BE ENOUGH FILES AVAILABLE FOR',
     1       'MODULE REQUIREMENTS', /5X,        
     1       'FILES NEEDED =',I4,5X,'FILES AVAILABLE =',I4)        
      GO TO 1850        
C        
C     ERROR MESSAGE 38   (XGPI)        
C        
 1340 ASSIGN 1350 TO LX        
      GO TO  190        
 1350 WRITE  (OP,1360)        
 1360 FORMAT (5X,'NOT ENOUGH CORE FOR GPI TABLES.')        
      WRITE  (OP,1361) I        
 1361 FORMAT (5X,'ADDITIONAL CORE NEEDED =',I8,' WORDS.')        
      GO TO  1850        
C        
C     ERROR MESSAGE 39   (XOSGEN)        
C        
 1370 ASSIGN 1380 TO L        
      GO TO  90        
 1380 WRITE  (OP,1390)        
 1390 FORMAT (5X,'RIGID FORMAT DMAP SEQUENCE DOES NOT CORRESPOND TO ',  
     1       'MED TABLE')        
      GO TO 1850        
C        
C     ERROR MESSAGE 40   (XSCNDM)        
C        
 1400 ASSIGN 1410 TO LX        
      GO TO  20        
 1410 WRITE  (OP,1420)        
 1420 FORMAT (5X,'ERROR IN ALTER DECK - CANNOT FIND END OF DMAP ',      
     1       'INSTRUCTION')        
      GO TO 1850        
C        
C     ERROR MESSAGE 41   (XFLDEF)        
C        
 1430 ASSIGN 1440 TO L        
      GO TO  90        
 1440 WRITE  (OP,1450) I,J        
 1450 FORMAT (5X,'TABLES INCORRECT FOR REGENERATING DATA BLOCK ',2A4)   
      GO TO 1850        
C        
C     ERROR MESSAGE 42   (XPARAM)        
C        
 1460 ASSIGN 1470 TO L        
      GO TO  10        
 1470 WRITE  (OP,1480) J,K        
 1480 FORMAT (5X,'PARAMETER NAMED ',2A4,' ALREADY HAD VALUE ASSIGNED ', 
     1        'PREVIOUSLY')        
      GO TO 1850        
C        
C     ERROR MESSAGE 43   (XOSGEN)        
C        
 1490 ASSIGN 1500 TO L        
      GO TO  10        
 1500 WRITE  (OP,1510)        
 1510 FORMAT (5X,'ILLEGAL TYPE FOR CONSTANT VALUE')        
      GO TO  1850        
C        
C     ERROR MESSAGE 44   (XSCNDM)        
C        
 1520 ASSIGN 1530 TO L        
      GO TO  10        
 1530 WRITE  (OP,1540)        
 1540 FORMAT (5X,'UNABLE TO FIND END DMAP INSTRUCTION')        
      GO TO  1850        
C        
C     ERROR MESSAGE 45   (XFLORD)        
C        
 1550 ASSIGN 1560 TO L        
      KDHCOD = 1        
      GO TO  10        
 1560 WRITE  (OP,1570) J,K        
 1570 FORMAT (5X,'DATA BLOCK NAMED ',2A4,' ALREADY APPEARED AS OUTPUT') 
      GO TO 1850        
C        
C     ERROR MESSAGE 46   (XGPI)        
C        
 1580 ASSIGN 1590 TO LX        
      GO TO  20        
 1590 WRITE  (OP,1600)        
 1600 FORMAT (5X,'INCORRECT REENTRY POINT')        
      GO TO  1850        
C        
C     ERROR MESSAGE 47   (XFLORD)        
C        
 1610 ASSIGN 1620 TO L        
      GO TO  10        
 1620 WRITE  (OP,1630)        
 1630 FORMAT (5X,'THIS INSTRUCTION CANNOT BE FIRST INSTRUCTION OF LOOP')
      GO TO 1850        
C        
C     ERROR MESSAGE 48   (XOSGEN)        
C        
 1640 ASSIGN 1650 TO L        
      GO TO  10        
 1650 WRITE  (OP,1660) J,K        
 1660 FORMAT (5X,'DATA SET ',2A4,' IS ALWAYS REGENERATED, THEREFORE IT',
     1       'WILL NOT BE CHECKPOINTED')        
      GO TO  1850        
C        
C     ERROR MESSAGE 49   (XGPIBS,XOSGEN)        
C        
 1670 ASSIGN 1680 TO L        
      GO TO  90        
 1680 WRITE  (OP,1690)        
 1690 FORMAT (5X,'MPL TABLE (MODULE PROPERTIES LIST) IS INCORRECT')     
      IF (I .EQ. 0) GO TO 1850        
      NLINES = NLINES + 1        
      WRITE  (OP,1700) I,J,K        
 1700 FORMAT (5X,'DECIMAL LOCATION RELATIVE TO MPL(1) = ',I10,        
     1        ',MODULE NAME = ',2A4 )        
      GO TO 1850        
C        
C     ERROR MESSAGE 50   (XGPI)        
C        
 1710 ASSIGN 1720 TO L        
      GO TO  90        
 1720 WRITE  (OP,1730)        
 1730 FORMAT (5X,'CANNOT FIND JUMP OSCAR ENTRY NEEDED FOR THIS RESTART')
      GO TO  1850        
C        
C     ERROR MESSAGE 51   (XGPIBS)        
C        
 1740 ASSIGN 1750 TO LX        
      GO TO  190        
 1750 WRITE  (OP,1760)        
 1760 FORMAT (5X,'NOT ENOUGH OPEN CORE FOR XGPIBS ROUTINE')        
      WRITE  (OP,1361) I        
      GO TO  1850        
C        
C     ERROR MESSAGE 52   (XGPIBS)        
C        
 1770 ASSIGN 1780 TO LX        
      GO TO  190        
 1780 WRITE  (OP,1790)        
 1790 FORMAT (5X,'NAMED COMMON /XLINK/ IS TOO SMALL')        
      GO TO  1850        
C        
C     ERROR MESSAGE 53   (XGPIBS)        
C        
 1800 ASSIGN 1810 TO LX        
      GO TO  150        
 1810 WRITE  (OP,1820)        
 1820 FORMAT (5X,'INCORRECT FORMAT IN ABOVE CARD')        
      GO TO  1850        
C        
C     ERROR MESSAGE 54   (XGPI)        
C        
 1822 ASSIGN 1824 TO LX        
      GO TO  130        
 1824 WRITE  (OP,1826) J,K        
 1826 FORMAT (5X,'PARAMETER NAMED ',2A4,' NOT REFERENCED')        
      GO TO  1850        
C        
C     ERROR MESSAGE 55   (XOSGEN)        
C        
 3310 ASSIGN 3312 TO LX        
      GO TO  150        
 3312 WRITE  (OP,3314)        
 3314 FORMAT (5X,'PRECHK NAME LIST EXCEEDS MAXIMUM LIMIT (50)')        
      GO TO  1850        
C        
C     ERROR MESSAGE 56   (XOSGEN)        
C        
 3340 ASSIGN 3342 TO LX        
      GO TO  130        
 3342 WRITE  (OP,3344)        
 3344 FORMAT (5X,'ILLEGAL OPTION ON XDMAP CARD - IGNORED')        
      GO TO  1850        
C        
C     ERROR MESSAGE 57   (XOSGEN)        
C        
 3370 ASSIGN 3372 TO LX        
      GO TO  150        
 3372 WRITE  (OP,3374)        
 3374 FORMAT (5X,'VARIABLE REPT PARAMETER MUST BE AN INTEGER')        
      GO TO  1850        
C        
C     ERROR MESSAGE 58   (XOSGEN)        
C        
 3400 ASSIGN 3402 TO LX        
      GO TO  150        
 3402 WRITE  (OP,3404)        
 3404 FORMAT (5X,'VARIABLE REPT PARAMETER MUST BE DEFINED PRIOR TO ',   
     1       'INSTRUCTION')        
      GO TO 1850        
C        
C     ERROR MESSAGE 59   (OSCXRF)        
C        
 3430 ASSIGN 3432 TO LX        
      KDHCOD = 1        
      GO TO  130        
 3432 WRITE  (OP,3434)        
 3434 FORMAT (5X,'POOL FILE ERROR - DMAP CROSS-REF TERMINATED.')        
      GO TO  1850        
C        
C     ERROR MESSAGE 60   (OSCXRF)        
C        
 3470 ASSIGN 3472 TO LX        
      KDHCOD = 1        
      GO TO  130        
 3472 WRITE  (OP,3474)        
 3474 FORMAT (5X,'INSUFFICIENT OPEN CORE FOR DMAP CROSS-REF - ',        
     1       'TERMINATED.')        
      WRITE  (OP,1361) I        
      GO TO  1850        
C        
C     ERROR MESSAGE 61   (XOSGEN)        
C        
 3500 ASSIGN 3502 TO L        
      GO TO  10        
 3502 WRITE  (OP,3504)        
 3504 FORMAT (5X,'SAVE INSTRUCTION OUT OF SEQUENCE')        
      GO TO  1850        
C        
C     ERROR MESSAGE 62   (XIPFL)        
C        
 3600 ASSIGN 3602 TO L        
      GO TO  10        
 3602 WRITE  (OP,3604)        
 3604 FORMAT (5X,'INCORRECT NUMBER OF INPUT DATA BLOCKS ENCOUNTERED')   
      GO TO  1850        
C        
C     ERROR MESSAGE 63   (XIPFL)        
C        
 3700 ASSIGN 3702 TO L        
      GO TO  10        
 3702 WRITE  (OP,3704)        
 3704 FORMAT (5X,'INCORRECT NUMBER OF OUTPUT DATA BLOCKS ENCOUNTERED')  
      GO TO  1850        
C        
C     ERROR MESSAGE 69   (XGPI)        
C        
 3800 ASSIGN 3802 TO LX        
      GO TO  190        
 3802 WRITE  (OP,3804) I, J        
 3804 FORMAT (5X,'SUBROUTINE ',2A4,' FINDS RIGID FORMAT OR MED TABLE ', 
     1       'RECORD MISSING ON SCRATCH FILE', /5X,        
     2       'MOST LIKELY DUE TO INSUFFECIENT CORE')        
C        
C   * NOTE - DATA ON SCRATCH FILE MAY BE DESTROYED BY XSORT2 *        
      GO TO  1850        
C        
C     ERROR MESSAGE 70   (XGPI)        
C        
 3900 ASSIGN 3902 TO LX        
      GO TO  190        
 3902 WRITE  (OP,3904) I,J,K        
 3904 FORMAT (5X,'SUBROUTINE ',2A4,' FINDS ',A4,' NAME TABLE RECORD ',  
     1       'MISSING ON SCRATCH FILE')        
      GO TO  1850        
C        
C     ERROR MESSAGE 71   (XGPI)        
C        
 4000 ASSIGN 4002 TO LX        
      GO TO  190        
 4002 WRITE  (OP,4004) I        
 4004 FORMAT (5X,'ILLEGAL NUMBER OF WORDS (',I8,') IN MED TABLE RECORD',
     1       ' ON SCRATCH FILE')        
      GO TO  1850        
C        
C     ERROR MESSAGE 72   (XGPI)        
C        
 4100 ASSIGN 4102 TO LX        
      GO TO  190        
 4102 WRITE  (OP,4104) I,J        
 4104 FORMAT (5X,'ILLEGAL NUMBER OF WORDS (',I8,') IN ',A4,        
     1       ' NAME TABLE RECORD ON SCRATCH FILE')        
      GO TO  1850        
C        
C     ERROR MESSAGE 73   (XGPI)        
C        
 4200 ASSIGN 4202 TO LX        
      GO TO  190        
 4202 WRITE  (OP,4204) I        
 4204 FORMAT (5X,'ONE OR MORE ILLEGAL BIT NUMBERS SPECIFIED IN ',A4,    
     1       ' NAME TABLE')        
      GO TO 1850        
C        
 1830 WRITE  (OP,1840) ICODE        
 1840 FORMAT (//5X,'NO MESSAGE AVAILABLE FOR ERROR CODE =',I4)        
C        
 1850 RETURN        
C        
      END        
