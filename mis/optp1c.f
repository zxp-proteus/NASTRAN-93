       SUBROUTINE OPTP1C (ELT,ELOP,PR)        
C        
      INTEGER         COUNT,ELT(1),ELOP(2,2),EPT,PR(1),SYSBUF,OUTTAP,   
     1                YCOR,PRCOR,PRC,NAME(2),CARD(2),DTYP(21),B1P1,ENTRY
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /BLANK / SKP1(2),COUNT,SKP2(2),YCOR,B1P1,NPOW,        
     1                SKP3(2),NPRW,NWDSP,SKP4,        
     2                SKP5,EPT,SKP6(6),ENTRY(21)        
      COMMON /OPTPW1/ PRCOR,PRC(1)        
CZZ   COMMON /ZZOPT1/ X(1)        
      COMMON /ZZZZZZ/ X(1)        
      COMMON /GPTA1 / NTYPES,LAST,INCR,NE(1)        
      COMMON /SYSTEM/ SYSBUF,OUTTAP        
      COMMON /NAMES / NRD,NOEOR,NWRT,NWEOR        
      EQUIVALENCE     (M1,RM1)        
      DATA    NAME  / 4H OPT,4HP1C  /,  RM1 / -1.0 /        
C        
C      PROPERTY CORRELATOR TO EST DESIGN VARIABLE (100*EST LOCATION).   
C      THIS VALUE ADDS/SUBTRACTS FROM EST ENTRY TO GET EPT LOCATION.    
C      ENTRY IS MADE BY THE ELT ARRAY (SEQUENTIAL LIST OF NUMBERS WITH  
C      ZEROS FOR ELEMENTS NOT USED).        
C        
      DATA    DTYP  /        
     1        -14, -6, -10, -5, -5, -5, -5, -5, -5, -2,        
C              BR  EB   IS  QM  M1  M2  QP  Q1  Q2  RD        
     2         -4, -4,  -4, -4, -7, -4, -4, -2, -5, -5,        
C              SH  TB   T1  T2  T6  TM  TP  TU  Q4  T3        
     3          0/        
C        
      JETYP = 1        
      IDPS  = ELOP(2,1)        
      IDPE  = ELOP(2,2) - 1        
C        
      DO 80 IETYP = 1,NTYPES        
      IF (ELT(IETYP) .LE. 0) GO TO 80        
      NPR = (IDPE+1-IDPS)/NWDSP        
      IF (NPR) 30,70,10        
C        
   10 IDX = ENTRY(JETYP)        
      IDX = INCR*(IDX-1)        
      IDP = IDX + 7        
      CARD(1) = NE(IDP  )        
      CARD(2) = NE(IDP+1)        
      IF (NE(IDP+2) .GT. PRCOR) GO TO 130        
C        
      CALL LOCATE (*110,X(B1P1),CARD,I)        
      ICPR = PR(IDPS)        
      ICPT = IDPS        
C        
   20 CALL READ (*150,*160,EPT,PRC,NE(IDP+2),NOEOR,I)        
C        
C     SEQUENTIAL PROPERTY SEARCH.  PROPERTIES THAT ARE UNSORTED ON EPT  
C     WILL FAIL.  THIS MAY OCCUR FOR 2 PID/CARD (E.G., QDMEM, QUAD2,    
C     SHEAR, TRIA2, TRMEM).        
C        
      IF (PRC(1)-ICPR) 20,50,30        
C        
C     LOGIC OR UNSORTED FILE ERROR        
C        
   30 CALL PAGE2 (-2)        
      WRITE  (OUTTAP,40) SFM,IETYP,PRC(1),NAME        
   40 FORMAT (A25,' 2299, INCORRECT LOGIC FOR ELEMENT TYPE',I4,        
     1        ', PROPERTY',I9,2H (,2A4,2H).)        
      GO TO 100        
C        
C     PROPERTY IN CORE LOCATED.        
C        
   50 NPR = NPR - 1        
      PR(ICPT+5) = 0        
      PR(ICPT+4) = M1        
C        
C     LOCATE VARIABLE AS SET BY OPTP1A        
C        
      J1 = PR(ICPT+1)/100        
      J2 = J1+DTYP(JETYP)        
      PR(ICPT+3) = PRC(J2)        
      PR(ICPT+2) = PRC(J2)        
C        
C     ICPT+0, +1 SET BY OPTP1A        
C        
      ICPT = ICPT + NWDSP        
      IF (ICPT .GT. IDPE) GO TO 60        
      ICPR = PR(ICPT)        
      GO TO 20        
C        
C     NEW ELEMENT TYPE COMING        
C        
   60 IF (NPR .GT. 0) GO TO 30        
      CALL FREAD (EPT,0,0,NWEOR)        
   70 IDPS  = IDPE  + 1        
      JETYP = JETYP + 1        
      IF (JETYP .GT. NPOW) GO TO 90        
      IDPE = ELOP(2,JETYP+1) - 1        
   80 CONTINUE        
C        
C        
   90 RETURN        
C        
C     ERRORS        
C        
  100 COUNT = -1        
      GO TO 90        
C        
C     UNABLE TO LOCATE SORTED PID        
C        
  110 WRITE  (OUTTAP,120) SFM,NAME,PRC(1)        
  120 FORMAT (A25,' 2300, ',2A4,'UNABLE TO LOCATE PROPERTY',I10,        
     1       ' ON EPT OR IN CORE.')        
      GO TO 100        
C        
C     INSUFFICIENT CORE /OPTPW1/        
C        
  130 CALL PAGE2 (-2)        
      WRITE  (OUTTAP,140) UFM,NAME,PRCOR,IETYP        
  140 FORMAT (A23,' 2296. INSUFFICIENT CORE ',2A4,1H(,I10,' ), ELEMENT',
     1        I9)        
       GO TO 100        
C        
C     ILLEGAL EOF        
C        
  150 CALL MESAGE (-2,EPT,NAME)        
C        
C     ILLEGAL EOR        
C        
  160 CALL MESAGE (-3,EPT,NAME)        
      GO TO 100        
      END        
