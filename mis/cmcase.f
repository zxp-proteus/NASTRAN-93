      SUBROUTINE CMCASE        
C        
C     THIS SUBROUTINE PROCESSES THE CASE CONTROL DATA BLOCK        
C        
      EXTERNAL        ORF        
      LOGICAL         IAUTO,TRAN,CONECT,LF(3),LONLY,SRCH        
      INTEGER         CASECC,BUF2,STEP,Z,CNAM,RESTCT,COMBO,OUTT,AUTO,   
     1                ORF,NCNAM(2),IHD(96),IBITS(32),CONSET,MNEM(11),   
     2                SNAM(7,2),IDIR(3),COMP(7,2),SYMT(7),TRANS(7),     
     3                ISYM(15,2),AAA(2),PORA,PAPP        
      DIMENSION       AZ(1)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /CMB001/ JUNK(8),CASECC        
      COMMON /CMB002/ BUF1,BUF2,JUNK1(6),OUTT        
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB,CONECT,TRAN,  
     1                MCON,RESTCT(7,7),ISORT,ORIGIN(7,3),IPRINT        
      COMMON /CMB004/ TDAT(6),NIPNEW,CNAM(2),LONLY        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /OUTPUT/ ITITL(96),IHEAD(96)        
      COMMON /SYSTEM/ XXX,IOT,MUNK(6),NLPP,JUNK3(2),LINE,JUNK2(2),      
     1                IDAT(3)        
      COMMON /BLANK / STEP,IDRY,PORA        
      EQUIVALENCE     (Z(1),AZ(1))        
      DATA    NMNEM / 11 /, IDIR/ 1HX, 1HY, 1HZ /,  AUTO/ 4HAUTO / ,    
     1        AAA   / 4HCMCA, 4HSE   /        
      DATA    MNEM  / 4HOPTS, 4HSORT, 4HNAMC, 4HNAMS, 4HTOLE, 4HCONN,   
     1                4HCOMP, 4HTRAN, 4HSYMT, 4HSEAR, 4HOUTP/        
      DATA    ISYM  / 4,2,1,6,6,5,5,3,3,6*7,1HX,1HY,1HZ,2HXY,2HYX,2HXZ, 
     1                2HZX,2HYZ,2HZY,3HXYZ,3HXZY,3HYXZ,3HYZX,3HZXY,     
     2                3HZYX /        
      DATA    IHD   / 74*4H    , 4H SUM , 4HMARY , 4H OF  , 4HCASE ,    
     1                4H CON ,   4HTROL , 4H FOR , 4H COM , 4HBINE ,    
     2                4H OPE ,   4HRATI , 4HON   , 10*4H           /    
      DATA    NHEQSS/ 4HEQSS /        
      DATA    PAPP  , LOAP,LODS/ 4HPAPP , 4HLOAP , 4HLODS /        
C        
C     OPEN CASECC DATA BLOCK AND READ INTO OPEN CORE        
C        
      SRCH = .FALSE.        
      IERR = 0        
      DO 10 I = 1,96        
      IHEAD(I) = IHD(I)        
   10 CONTINUE        
      IFILE = CASECC        
      CALL OPEN (*580,CASECC,Z(BUF2),0)        
      NREC = STEP        
      IF (NREC .EQ. 0) GO TO 30        
      DO 20 I = 1,NREC        
      CALL FWDREC (*580,CASECC)        
   20 CONTINUE        
   30 CALL READ (*570,*590,CASECC,Z(1),5,0,NNN)        
      I = 2        
      NWDSCC = Z(I  )        
      NPSUB  = Z(I+1)        
      CALL READ (*570,*40,CASECC,Z(1),NWDSCC,1,NNN)        
   40 JJ = 0        
      KK = 0        
      IPRINT = 0        
C        
C     INITIALIZE COMBO AND RESTCT ARRAYS        
C        
      DO 70 I = 1,7        
      DO 50 J = 1,5        
      COMBO(I,J) = 0        
   50 CONTINUE        
      DO 60 J = 1,7        
      RESTCT(I,J) = 0        
   60 CONTINUE        
   70 CONTINUE        
C        
C     INITIALIZE COMP,TRANS,AND SYMT ARRAYS        
C        
      CONECT = .FALSE.        
      TRAN   = .FALSE.        
      DO 90 I = 1,7        
      SYMT(I) = 0        
      TRANS(I)= 0        
      DO 80 J = 1,2        
      COMP(I,J) = 0        
   80 CONTINUE        
   90 CONTINUE        
      DO 100 I = 1,3        
      LF(I) = .FALSE.        
  100 CONTINUE        
      CNAM(1) = 0        
      CNAM(2) = 0        
C        
C     PROCESS CASE CONTROL MNEMONICS        
C        
      DO 350 I = 1,NWDSCC,3        
      DO 110 J = 1,NMNEM        
      IF (Z(I) .NE. MNEM(J)) GO TO 110        
      GO TO (120,130,160,170,180,190,200,220,230,260,290), J        
  110 CONTINUE        
      GO TO 350        
  120 IAUTO = .FALSE.        
      IF (Z(I+1) .EQ. AUTO) IAUTO = .TRUE.        
      GO TO 350        
C        
  130 DO 140 L = 1,3        
      IF (Z(I+1) .EQ. IDIR(L)) GO TO 150        
  140 CONTINUE        
      ISORT = 1        
      GO TO 350        
  150 ISORT = L        
      GO TO 350        
C        
  160 IF (LF(1)) GO TO 300        
      LF(1)   = .TRUE.        
      CNAM(1) = Z(I+1)        
      CNAM(2) = Z(I+2)        
      GO TO 350        
C        
  170 JJ = JJ + 1        
      SNAM(JJ,1) = Z(I+1)        
      SNAM(JJ,2) = Z(I+2)        
      GO TO 350        
C        
  180 IF (LF(2)) GO TO 300        
      LF(2) = .TRUE.        
      TOLER = AZ(I+2)        
      GO TO 350        
C        
  190 IF (LF(3)) GO TO 300        
      LF(3)  = .TRUE.        
      CONSET = Z(I+2)        
      CONECT = .TRUE.        
      GO TO 350        
C        
  200 KK = KK + 1        
      COMP(KK,1) = Z(I+1)        
      COMP(KK,2) = Z(I+2)        
      DO 210 LINDX = 1,NPSUB        
      IF (Z(I+1).EQ.SNAM(LINDX,1) .AND. Z(I+2).EQ.SNAM(LINDX,2))        
     1   GO TO 350        
  210 CONTINUE        
      WRITE (OUTT,630) UFM,Z(I+1),Z(I+2)        
      IERR = 1        
      GO TO 350        
C        
  220 TRANS(KK) = Z(I+2)        
      TRAN = .TRUE.        
      GO TO 350        
C        
  230 DO 240 L = 1,15        
      IF (Z(I+1) .EQ. ISYM(L,2)) GO TO 250        
  240 CONTINUE        
      IERR = 1        
      WRITE (OUTT,620) UFM,Z(I+1),COMP(KK,1),COMP(KK,2)        
      GO TO 350        
  250 SYMT(KK) = ISYM(L,1)        
      GO TO 350        
C        
  260 DO 270 L = 1,NPSUB        
      IF (Z(I+1).EQ.SNAM(L,1) .AND. Z(I+2).EQ.SNAM(L,2)) GO TO 280      
  270 CONTINUE        
      WRITE (OUTT,630) UFM,Z(I+1),Z(I+2)        
      IERR = 1        
      GO TO 350        
  280 SRCH = .TRUE.        
      RESTCT(LINDX,L) = 1        
      RESTCT(L,LINDX) = 1        
      GO TO 350        
C        
  290 IPRINT = ORF(IPRINT,Z(I+2))        
      GO TO 350        
C        
  300 GO TO (350,350,310,350,320,330) , J        
  310 WRITE (OUTT,740) UFM        
      GO TO 340        
  320 WRITE (OUTT,750) UFM        
      GO TO 340        
  330 WRITE (OUTT,760) UFM        
  340 IERR = 1        
  350 CONTINUE        
C        
C     IF NO SEARCH OPTIONS SPECIFIED - SEARCH ALL POSSIBLE CONNECTIONS  
C        
      IF (SRCH) GO TO 370        
      DO 360 I = 1,7        
      DO 360 J = 1,7        
  360 RESTCT(I,J) = 1        
  370 CONTINUE        
      DO 400 I = 1,NPSUB        
      DO 380 J = 1,NPSUB        
      IF (SNAM(I,1).EQ.COMP(J,1) .AND. SNAM(I,2).EQ.COMP(J,2)) GO TO 390
  380 CONTINUE        
      COMBO(I,1) = SNAM(I,1)        
      COMBO(I,2) = SNAM(I,2)        
      COMBO(I,3) = 0        
      COMBO(I,4) = 0        
      GO TO 400        
  390 COMBO(I,1) = SNAM(I,1)        
      COMBO(I,2) = SNAM(I,2)        
      COMBO(I,3) = TRANS(J)        
      COMBO(I,4) = SYMT(J)        
  400 CONTINUE        
      CALL CLOSE (CASECC,1)        
      CALL PAGE        
      WRITE (OUTT,690) NPSUB        
      IF (IAUTO) WRITE (OUTT,700)        
      IF (.NOT. IAUTO) WRITE (OUTT,710)        
      IF (.NOT.(IAUTO .OR. CONECT)) GO TO 550        
  410 IF (CONECT) WRITE (OUTT,720) CONSET        
      IF (CNAM(1).EQ.0 .AND. CNAM(2).EQ.0) GO TO 560        
      WRITE (OUTT,640) CNAM        
      CALL FDSUB (CNAM,ITEST)        
      IF (ITEST .NE. -1) GO TO 500        
      IF (PORA .EQ. PAPP) GO TO 540        
  420 IF (.NOT.LF(2)) GO TO 530        
      WRITE (OUTT,670) TOLER        
      CALL DECODE (IPRINT,IBITS,NFLG)        
      IF (NFLG .EQ. 0) IBITS(1) = 0        
      IF (NFLG .EQ. 0) GO TO 440        
      DO 430 I = 1,NFLG        
      IBITS(I) = IBITS(I) + 1        
  430 CONTINUE        
  440 CONTINUE        
      WRITE (OUTT,810) (IBITS(KDH),KDH=1,NFLG )        
  450 DO 480 I = 1,NPSUB        
      WRITE (OUTT,770) I,COMBO(I,1),COMBO(I,2)        
      NCNAM(1) = COMBO(I,1)        
      NCNAM(2) = COMBO(I,2)        
      CALL SFETCH (NCNAM,NHEQSS,3,ITEST)        
      IF (ITEST .EQ. 4) WRITE (OUTT,780) UFM,NCNAM        
      IF (ITEST .EQ. 4) IDRY = -2        
      IF (COMBO(I,3) .NE. 0) WRITE (OUTT,790) COMBO(I,3)        
      IF (COMBO(I,4) .EQ. 0) GO TO 480        
      DO 460 MJ = 1,15        
      IF (COMBO(I,4) .EQ. ISYM(MJ,1)) GO TO 470        
  460 CONTINUE        
  470 WRITE (OUTT,800) ISYM(MJ,2)        
  480 CONTINUE        
  490 IF (IERR .EQ. 1) IDRY = -2        
      GO TO 610        
  500 LITM = LODS        
      IF (PORA .EQ. PAPP) LITM = LOAP        
      CALL SFETCH (CNAM,LITM,3,ITEST)        
      LONLY = .FALSE.        
      IF (ITEST .EQ. 3) GO TO 520        
      IF (PORA .EQ. PAPP) GO TO 510        
      WRITE (OUTT,650) UFM        
      IERR = 1        
      GO TO 420        
C        
C     OPTIONS PA YET LOAP ITEM ALREADY EXISTS        
C        
  510 WRITE (OUTT,820) UFM,CNAM        
      IERR = 1        
      GO TO 490        
C        
C     NEW LODS ONLY DEFINED        
C        
  520 LONLY = .TRUE.        
      RETURN        
C        
  530 WRITE (OUTT,660) UFM        
      IERR = 1        
      GO TO 450        
C        
C     OPTIONS PA YET SUBSTRUCTURE DOES NOT EXIST        
C        
  540 WRITE (OUTT,830) UFM,CNAM        
      IERR = 1        
      GO TO 490        
  550 WRITE (OUTT,680) UFM        
      IERR = 1        
      GO TO 410        
  560 WRITE (OUTT,730) UFM        
      IERR = 1        
      GO TO 490        
  570 IMSG = -2        
      GO TO 600        
  580 IMSG = -1        
      GO TO 600        
  590 IMSG = -3        
  600 CALL MESAGE (IMSG,IFILE,AAA)        
  610 CONTINUE        
      RETURN        
C        
  620 FORMAT (A23,' 6505, THE SYMMETRY OPTION ',A4,        
     1       ' CONTAINS AN INVALID SYMBOL.')        
  630 FORMAT (A23,' 6506, THE COMPONENT SUBSTRUCTURE ',2A4,        
     1       ' IS NOT ONE OF THOSE ON THE COMBINE CARD.')        
  640 FORMAT (/10X,38HTHE RESULTANT PSEUDOSTRUCTURE NAME IS ,2A4)       
  650 FORMAT (A23,' 6508, THE NAME SPECIFIED FOR THE RESULTANT ',       
     1       'PSEUDOSTRUCTURE', /32X,'ALREADY EXISTS ON THE SOF.')      
  660 FORMAT (A23,' 6504, A TOLERANCE MUST BE SPECIFIED FOR A COMBINE ',
     1       'OPERATION.')        
  670 FORMAT (/10X,32HTHE TOLERANCE ON CONNECTIONS IS ,E15.6)        
  680 FORMAT (A23,' 6501, THE MANUAL COMBINE OPTION HAS BEEN SPECIFIED',
     1       ', BUT NO CONNECTION SET WAS GIVEN.')        
  690 FORMAT (/10X,'THIS JOB STEP WILL COMBINE ',I1,' PSEUDOSTRUCTURES')
  700 FORMAT (/10X,40HCONNECTIONS ARE GENERATED AUTOMATICALLY. )        
  710 FORMAT (/10X,35HCONNECTIONS ARE SPECIFIED MANUALLY. )        
  720 FORMAT (/10X,25HTHE CONNECTION SET ID IS ,I8)        
  730 FORMAT (A23,' 6502, NO NAME HAS BEEN SPECIFIED FOR THE RESULTANT',
     1       ' COMBINED PSEUDOSTRUCTURE.')        
  740 FORMAT (A23,' 6519, REDUNDANT NAMES FOR RESULTANT PSEUDOSTRUCTURE'
     1,      ' HAVE BEEN SPECIFIED.')        
  750 FORMAT (A23,' 6520, REDUNDANT VALUES FOR TOLER HAVE BEEN ',       
     1       'SPECIFIED.')        
  760 FORMAT (A23,' 6512, REDUNDANT CONNECTION SET ID S HAVE BEEN ',    
     1       'SPECIFIED.')        
  770 FORMAT (/10X, 27HCOMPONENT SUBSTRUCTURE NO. ,I1,8H NAME = ,2A4)   
  780 FORMAT (A23,' 6507, THE SUBSTRUCTURE ',2A4,' DOES NOT EXIST ON ', 
     1       'THE SOF FILE')        
  790 FORMAT (/15X, 15HTRANS SET ID = ,I8)        
  800 FORMAT (15X,22HSYMMETRY DIRECTIONS = ,A4)        
  810 FORMAT (/10X,30HTHE PRINT CONTROL OPTIONS ARE ,25I3)        
  820 FORMAT (A23,' 6533, OPTIONS PA HAS BEEN SPECIFIED BUT THE LOAP ', 
     1       'ITEM ALREADY EXISTS FOR SUBSTRUCTURE ',2A4)        
  830 FORMAT (A23,' 6534, OPTIONS PA HAS BEEN SPECIFIED BUT THE ',      
     1       'SUBSTRUCTURE ',2A4,' DOES NOT EXIST.', /30X,        
     2       'YOU CANNOT APPEND SOMETHING TO NOTHING.')        
      END        
