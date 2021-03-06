      SUBROUTINE FNDIAM (SND1,SND2,NDSTK,NDEG,LVL,LVLS1,LVLS2,IWK,        
     1                   IDFLT,NDLST,JWK,IDIM)        
C        
C     THIS ROUTINE IS USED ONLY IN BANDIT MODULE        
C        
C     FNDIAM IS THE CONTROL PROCEDURE FOR FINDING THE PSEUDO-DIAMETER        
C     OF NDSTK AS WELL AS THE LEVEL STRUCTURE FROM EACH END        
C        
C     SND1-     ON INPUT THIS IS THE NODE NUMBER OF THE FIRST        
C               ATTEMPT AT FINDING A DIAMETER.  ON OUTPUT IT        
C               CONTAINS THE ACTUAL NUMBER USED.        
C     SND2-     ON OUTPUT CONTAINS OTHER END OF DIAMETER        
C     LVLS1-    ARRAY CONTAINING LEVEL STRUCTURE WITH SND1 AS ROOT        
C     LVLS2-    ARRAY CONTAINING LEVEL STRUCTURE WITH SND2 AS ROOT        
C     IDFLT-    FLAG USED IN PICKING FINAL LEVEL STRUCTURE, SET =1        
C               IF WIDTH OF LVLS1 .GE. WIDTH OF LVLS2, OTHERWISE =2        
C     LVL,IWK-  WORKING STORAGE        
C     JWK-      WORKING STORAGE, CURRENTLY SHARING SAME SPACE WITH RENUM        
C     DIMENSION OF NDLST IS THE MAX NUMBER OF NODES IN LAST LEVEL.        
C        
      INTEGER          FLAG,     SND,      SND1,     SND2        
      DIMENSION        NDEG(1),  LVL(1),   LVLS1(1), LVLS2(1), IWK(1),        
     1                 JWK(1),   NDSTK(1), NDLST(IDIM)        
      COMMON /BANDB /  DUM3B(3), NGRID        
      COMMON /BANDG /  N,        IDPTH        
C        
      FLAG=0        
      MTW2=N        
      SND=SND1        
C        
C     ZERO LVL TO INDICATE ALL NODES ARE AVAILABLE TO TREE        
C        
   20 DO 25 I=1,N        
   25 LVL(I)=0        
      LVLN=1        
C        
C     DROP A TREE FROM SND        
C        
      CALL TREE (SND,NDSTK,LVL,IWK,NDEG,LVLWTH,LVLBOT,LVLN,MAXLW,MTW2,        
     1           JWK)        
      IF (FLAG.GE.1) GO TO 110        
      FLAG=1        
   70 IDPTH=LVLN-1        
      MTW1=MAXLW        
C        
C     COPY LEVEL STRUCTURE INTO LVLS1        
C        
      DO 75 I=1,N        
   75 LVLS1(I)=LVL(I)        
      NDXN=1        
      NDXL=0        
      MTW2=N        
C        
C     SORT LAST LEVEL BY DEGREE  AND STORE IN NDLST        
C        
      CALL SORTDG (NDLST,IWK(LVLBOT),NDXL,LVLWTH,NDEG)        
      IF (NDXL.LE.IDIM) GO TO 100        
C        
C     DIMENSION EXCEEDED  . . .  STOP JOB.        
C        
   80 NGRID=-3        
      RETURN        
C        
  100 CONTINUE        
      SND=NDLST(1)        
      GO TO 20        
  110 IF (IDPTH.GE.LVLN-1) GO TO 120        
C        
C     START AGAIN WITH NEW STARTING NODE        
C        
      SND1=SND        
      GO TO 70        
  120 IF (MAXLW.GE.MTW2) GO TO 130        
      MTW2=MAXLW        
      SND2=SND        
C        
C     STORE NARROWEST REVERSE LEVEL STRUCTURE IN LVLS2        
C        
      DO 125 I=1,N        
  125 LVLS2(I)=LVL(I)        
  130 IF (NDXN.EQ.NDXL) GO TO 140        
C        
C     TRY NEXT NODE IN NDLST        
C        
      NDXN=NDXN+1        
      SND=NDLST(NDXN)        
      GO TO 20        
  140 IDFLT=1        
      IF (MTW2.LE.MTW1) IDFLT=2        
      IF (IDPTH .GT. IDIM) GO TO 80        
      RETURN        
      END        
