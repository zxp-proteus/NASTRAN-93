      SUBROUTINE OPTP1D (ELOP,PR,PL)        
C        
C     PROPERTY OPTIMIZER   SET POINTERS TO PLIMIT        
C        
      INTEGER         ELOP(2,1),PR(1),COUNT,YCOR,B1P1,SCRTH1,        
     1                SYSBUF,OUTTAP,PLP,PID,NAME(2),NKL(2)        
      REAL            PL(1),KL        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /BLANK / SKP1(2),COUNT,SKP2(2),YCOR,B1P1,NPOW,        
     1                SKP3(2),NPRW,NWDSP,NKLW,SKP4(6),SCRTH1        
      COMMON /OPTPW1/ KLWDS,KL(4)        
      COMMON /SYSTEM/ SYSBUF,OUTTAP        
      COMMON /NAMES / NRD,NOEOR,NWRT,NWEOR        
      EQUIVALENCE     (NKL(1),KL(1))        
      DATA    NAME  / 4H OPT,4HPID  /        
C        
      NOGO = 0        
      PLP  = 1        
      GO TO 15        
C        
C     READ A NEW ELEMENT TYPE        
C        
   10 CALL FREAD (SCRTH1,0,0,NWEOR)        
   15 L   = 0        
      NPL = 0        
      CALL READ (*150,*180,SCRTH1,ITP,1,NOEOR,I)        
      IF (ITP .LE. NPOW) GO TO 40        
C        
   20 CALL PAGE2 (-2)        
      WRITE  (OUTTAP,30) SFM,NAME,ITP,L        
   30 FORMAT (A25,' 2301,',2A4,' FILE OPTIMIZATION PARAMETER INCORRECT',
     1       ' AS',2I8)        
      NOGO = NOGO + 1        
      GO TO 140        
C        
   40 IP1 = ELOP(2,ITP)        
      IP2 = ELOP(2,ITP+1) - 1        
      NPR = IP2 - IP1        
      IF (NPR .LE. 0) GO TO 10        
      CALL FREAD (SCRTH1,L,1,NOEOR)        
      IF (L .LE. 0) GO TO 20        
C        
      CALL FREAD (SCRTH1,NKL(1),4,NOEOR)        
      L = L - 1        
C        
C     SEQUENTIAL SEARCH ON PLIMIT AND PROPERTY DATA        
C     LPL -- LAST PLIMIT POINTED TO (BY ILL).        
C     NPL -- NUMBER OF PLIMIT FOR THIS ELEMENT TYPE IN CORE.        
C     PLP -- POINTER FIRST PLIMIT  --    --     -- .        
C        
      LPL = -9877        
C        
      DO 130 IPR = IP1,IP2,NWDSP        
      PID = PR(IPR)        
C        
   50 IF (PID-NKL(1)) 70,80,60        
C        
C     CHECK UPPER RANGE PLIMIT        
C        
   60 CONTINUE        
      IF (PID-NKL(2)) 80,80,70        
C        
C     READ NEXT PLIMIT INTO CORE        
C        
   70 IF (L.LE.0) GO TO 140        
      CALL FREAD (SCRTH1,NKL(1),4,NOEOR)        
      L = L - 1        
      GO TO 50        
C        
C     PLIMIT EXISTS - SEE IF MATCHES LAST        
C        
   80 IF (LPL .EQ. L) GO TO 120        
C        
C     DOESNOT - CHECK IF PREVIOUS ENTRY        
C        
      IF (NPL .EQ. 0) GO TO 100        
      DO 90 LPL = PLP,LOC,2        
      IF (PL(LPL)   .NE. KL(3)) GO TO 90        
      IF (PL(LPL+1) .EQ. KL(4)) GO TO 110        
   90 CONTINUE        
C        
C     NEW PLIMIT        
C        
  100 IF (NPL+PLP+1 .GT.YCOR) GO TO 190        
      NPL = NPL + 2        
      LOC = NPL + PLP - 2        
      PL(LOC  ) = KL(3)        
      PL(LOC+1) = KL(4)        
      LPL = L        
      ILL = LOC        
      GO TO 120        
C        
C     PREVIOUS MATCH        
C        
  110 ILL = LPL        
      LPL = L        
C        
C     LOAD POINTER        
C        
  120 PR(IPR+5) = ILL        
C        
  130 CONTINUE        
C        
  140 PLP = PLP + NPL        
      GO TO 10        
C        
C     END-OF-FILE        
C        
  150 NKLW = PLP + NPL - 1        
  160 IF (NOGO .GT. 0) COUNT = -1        
      RETURN        
C        
C     ILLEGAL EOR        
C        
  180 CALL MESAGE (-3,SCRTH1,NAME)        
C        
C     INSUFFICIENT COREINTERNAL ELEMENT NUMBER PRINTED        
C        
  190 CALL PAGE2 (-2)        
      WRITE  (OUTTAP,200) UFM,NAME,B1P1,ITP        
  200 FORMAT (A23,' 2298, INSUFFICIENT CORE ',2A4,1H(,I10,        
     1       ' ), PROPERTY',I9)        
      NKLW = -PLP        
      GO TO 160        
      END        
