      SUBROUTINE OPTP1B (ELT,ELOP,ELE,PR)        
C        
      INTEGER         ELT(1),ELOP(2,1),ELE(1),PR(1),COUNT,ECT,SYSBUF,   
     1                OUTTAP,YCOR,PRCOR,PRC,NAME(2),CARD(2),ELCR,ELPT,  
     2                PID,PRPT,PRPT1,B1P1        
      COMMON /BLANK / SKP1(2),COUNT,SKP2(2),YCOR,B1P1,NPOW,        
     1                NELW,NWDSE,NPRW,NWDSP,SKP3,        
     2                SKP4(2),ECT,SKP5(4),NUMELM,ITYPE(21)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
CZZ   COMMON /ZZOPT1/ X(1)        
      COMMON /ZZZZZZ/ X(1)        
      COMMON /OPTPW1/ PRCOR,PRC(2)        
      COMMON /GPTA1 / NTYPES,LAST,INCR,NE(1)        
      COMMON /SYSTEM/ SYSBUF,OUTTAP        
      COMMON /NAMES / NRD,NOEOR,NWRT,NWEOR        
      DATA    NAME  / 4H OPT,4HP1B  /        
C        
C        
      IEOP  = 1        
      IDES  = ELOP(1,IEOP  )        
      IDEE  = ELOP(1,IEOP+1)        
      PRPT  = 1        
      PRPT1 = 1        
      ELOP(2,1) = 1        
C        
C     IN CASE OF ERROR SET PRC(1)        
C        
      PRC(1) = -1        
C        
      DO 130 K = 1,NUMELM        
      NELE = (IDEE-IDES)/NWDSE        
      IF (NELE) 30,120,10        
C        
   10 IDX = INCR*(ITYPE(K)-1)        
      IDP = IDX + 4        
      CARD(1) = NE(IDP  )        
      CARD(2) = NE(IDP+1)        
      IF (NE(IDP+2).GT.PRCOR) GO TO 150        
      CALL LOCATE (*160,X(B1P1),CARD(1),I)        
C        
C     SEQUENTIAL ELEMENT SEARCH        
C        
      NPR  = 0        
      ELPT = IDES        
      ELCR = ELE(ELPT)        
C        
   20 CALL READ (*160,*160,ECT,PRC,NE(IDP+2),NOEOR,I)        
      IF (PRC(1)-ELCR) 20,50,30        
C        
C     LOGIC OR FILE FAILURE        
C        
   30 CALL PAGE2 (-2)        
      WRITE  (OUTTAP,40) SFM,ITYPE(K),PRC(1),NAME        
   40 FORMAT (A25,' 2297, INCORRECT LOGIC FOR ELEMENT TYPE',I4,        
     1       ', ELEMENT',I8,2H (,2A4,2H).)        
      GO TO 170        
C        
C     ELEMENT ID IN CORE .EQ. ECT ID - ELEMENT TO BE OPTIMIZED        
C        
   50 PID = PRC(2)        
      CARD(1) = PID        
      CARD(2) = ELE(ELPT+4)        
C        
C     TEST FOR CORE NEEDED AFTER EXPANDING TO NWDSP WORDS        
C        
      IF (PRPT1+NWDSP*(NPR/2+1) .GT. YCOR) GO TO 180        
      CALL BISHEL (*60,CARD,NPR,2,PR(PRPT1))        
   60 ELE(ELPT+4) = PID        
      ELPT = ELPT + NWDSE        
      IF (ELPT .GE. IDEE) GO TO 70        
      ELCR = ELE(ELPT)        
      GO TO 20        
C        
C     NEW ELEMENT TYPE COMING        
C        
   70 CALL FREAD (ECT,0,0,NWEOR)        
C        
C     EXPAND PROPERTIES TO NWDSP WORDS/PROPERTY        
C        
      NX = NPR/2        
      IF (NX-1) 30,100,80        
   80 CONTINUE        
      DO 90 I = 1,NX        
      J = NX - I        
      L = PRPT1 + J*NWDSP        
      M = PRPT1 + J*2        
      PR(L  ) = PR(M  )        
   90 PR(L+1) = PR(M+1)        
C        
  100 PRPT = PRPT1 + NX*NWDSP        
C        
C     PLACE POINTERS IN ELEMENT ARRAY        
C        
      L = IDEE - 1        
      DO 110 I = IDES,L,NWDSE        
      KID = ELE(I+4)        
      CALL BISLOC (*30,KID,PR(PRPT1),NWDSP,NX,J)        
      ELE(I+4) = J        
  110 CONTINUE        
C        
C     SETUP FOR NEXT ELEMENT        
C        
  120 IEOP = IEOP + 1        
      ELOP(2,IEOP) = PRPT        
      PRPT1 = PRPT        
      IDES  = IDEE        
      IF (IEOP .GT. NPOW) GO TO 140        
      IDEE = ELOP(1,IEOP+1)        
  130 CONTINUE        
C        
C        
  140 NPRW = PRPT - 1        
      RETURN        
C        
C     ERRORS        
C        
C     INSUFFICIENT CORE IN /OPTPW1/ OR /XXOPT1/        
C        
  150 COUNT = -1        
      GO TO 140        
C        
C     FILE ERRORS        
C        
  160 CALL MESAGE (-7,ECT,NAME)        
  170 PRPT = 1        
      GO TO 140        
C        
C     INSUFFICIENT CORE        
C        
  180 CALL PAGE2 (-2)        
      WRITE  (OUTTAP,190) UFM,NAME,B1P1,PID        
  190 FORMAT (A23,' 2298, INSUFFICIENT CORE ',2A4,1H(,I10,'), PROPERTY',
     1        I9)        
      GO TO 150        
      END        
