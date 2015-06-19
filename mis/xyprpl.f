      SUBROUTINE XYPRPL        
C        
      LOGICAL         EXCEED,ANY        
      INTEGER         SYSBUF,Z,TITLEC,TITLER,TITLEL,XTITLE,BUFF,IBUF(2),
     1                BLANK,EYE,CURVCH,CLORWD,EOR,SYMBOL(10),        
     2                IGRAPH(3,8),XYPLTT        
      REAL            GRAPH(3,8),BUF(2),FID(300)        
      COMMON /SYSTEM/ SYSBUF, L        
      COMMON /OUTPUT/ IHEAD(96)        
      COMMON /XYPPPP/ IFRAME,TITLEC(32),TITLEL(14),TITLER(14),        
     1                XTITLE(32),ID(300),MAXPLT,XMIN,XINC,EXCEED,I123,  
     2                MAXROW        
CZZ   COMMON /ZZXYTR/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (FID(1),ID(1)),(GRAPH(1,1),IGRAPH(1,1)),        
     1                (BUF(1),IBUF(1))        
      DATA    SYMBOL/ 1H*,1H0,1HA,1HB,1HC,1HD,1HE,1HF,1HG,1HH /        
C        
C     GRAPH ARRAY CONTENTS        
C        
C     COL 1 = LEFT COLUMN USED        
C     COL 2 = CENTER COLUMN USED        
C     COL 3 = RIGHT COLUMN USED        
C     COL 4 = WIDTH OF GRAPH        
C     COL 5 = YRATIO        
C     COL 6 = YMIN        
C     COL 7 = CENTER        
C     COL 8 = YMAX        
C        
      DATA IGRAPH(1,1),IGRAPH(1,2),IGRAPH(1,3),IGRAPH(1,4)/1,60,119,118/
      DATA IGRAPH(2,1),IGRAPH(2,2),IGRAPH(2,3),IGRAPH(2,4)/1,30, 59, 58/
      DATA IGRAPH(3,1),IGRAPH(3,2),IGRAPH(3,3),IGRAPH(3,4)/61,90,119,58/
      DATA BLANK /4H    /, EYE/ 4HI    /        
      DATA XYPLTT, MINXD, NOEOR, EOR, INPRWD, CLORWD /201,10,0,1,0,1/   
C        
C        
      ICORE  = KORSZ(Z)        
      BUFF   = ICORE - SYSBUF        
C        
      ICORE  = BUFF - 1        
      MAXROW = ICORE/30        
      ANY    =.FALSE.        
      EXCEED =.FALSE.        
      CALL OPEN (*180,XYPLTT,Z(BUFF),INPRWD)        
   10 CALL FWDREC (*170,XYPLTT)        
C        
C     READ ID RECORD        
C        
   20 CALL READ (*170,*170,XYPLTT,ID(1),300,EOR,NWORDS)        
C        
C     SKIP RECORD IF PLOT ONLY        
C        
      IF (ID(289).EQ.0 .OR. ID(289).EQ.1) GO TO 10        
C        
C     SKIP INITIALIZATION IF AXIS AND SCALES ARE COMPLETE        
C        
      ICURVE = MOD(ID(3),10)        
      IF (ICURVE .EQ. 0) ICURVE = 10        
      CURVCH = SYMBOL(ICURVE)        
      IF (ID(8) .EQ. 0) GO TO 160        
C        
C     1 = UPPER,  0 = WHOLE,  -1 = LOWER        
C        
      IF (ID(7)) 50,30,30        
C        
C     OUTPUT OUR GRAPH IF THERE IS ONE TO OUTPUT        
C        
   30 IF (ANY) CALL XYGRAF (IGRAPH)        
      ANY = .TRUE.        
C        
C     INITIALIZE MATRIX TO ALL BLANKS        
C        
C        
C     COMPUTE XRATIO = LINES/UNIT VALUE    FID(MINXD) = MIN-X  INCREMENT
C        
C        
C     MAX OF 400 LINES PER PLOT        
C        
      XMIN = FID(15)        
      XMAX = FID(17)        
      TEMP = AMIN1(400.,FLOAT(MAXROW))        
      TEMP = AMIN1(TEMP,3.0*FLOAT(ID(246)))        
      XINC = FID(MINXD)        
      XINC = AMAX1(XINC,(XMAX-XMIN)/TEMP)        
      XRATIO = 1.0/XINC        
      MAXPLT = ABS((XMAX-XMIN)/XINC + 1.5)        
      MAXPLT = MIN0(MAXPLT,MAXROW)        
      N = 30*MAXPLT        
      DO 40 I = 1,N        
   40 Z(I) = BLANK        
   50 CONTINUE        
C        
C     FILL CURVE TITLE AND HEADING        
C     DEMO D10023A INDICATES HEADING WORDS (1-32, AND 36) ARE NUMERIC   
C     0 OR 1. REPLACE THEM BY BLANKS.        
C     (DON'T KNOW WHO PUTS THOSE 0 & 1 HERE)        
C        
      DO 60 I = 1,32        
      XTITLE(I) = ID(I+178)        
   60 TITLEC(I) = ID(I+145)        
      DO 70 I = 1,96        
      IHEAD(I) = ID(I+50)        
      IF (IHEAD(I) .EQ. 0) IHEAD(I) = BLANK        
   70 CONTINUE        
      IF (IHEAD(36) .EQ. 1) IHEAD(36) = BLANK        
      IFRAME = ID(281)        
      IF (ID(7)) 100,80,120        
   80 I123 = 1        
      DO 90 I = 1,14        
   90 TITLEL(I) = ID(I+210)        
      GO TO 140        
  100 I123 = 2        
      DO 110 I = 1,14        
  110 TITLEL(I) = ID(I+210)        
      GO TO 140        
  120 I123 = 3        
      DO 130 I = 1,14        
  130 TITLER(I) = ID(I+210)        
C        
C     PLOT GRID  (WHOLE LOWER OR UPPER)        
C        
  140 DO 150 J = 1,3        
      DO 150 I = 1,MAXPLT        
      CALL XYCHAR (I,IGRAPH(I123,J),EYE)        
  150 CONTINUE        
C        
C     UNITS AND VALUES        
C        
      YMIN = FID(23)        
      YMAX = FID(25)        
      DELTA = YMAX - YMIN        
      IF (DELTA .EQ. 0.0) DELTA = YMIN        
      IF (DELTA .EQ. 0.0) DELTA = 1.0        
      YRATIO = FLOAT(IGRAPH(I123,4))/DELTA        
      CENTER = YMIN + DELTA/2.0        
      GRAPH(I123,5) = YRATIO        
      GRAPH(I123,6) = YMIN        
      GRAPH(I123,7) = CENTER        
      GRAPH(I123,8) = YMAX        
C        
C     READ DATA AND PLOT POINTS        
C        
  160 CALL READ (*170,*20,XYPLTT,BUF(1),2,NOEOR,NWORDS)        
      IF (IBUF(1) .EQ. 1) GO TO 160        
      IROW = (BUF(1) - XMIN)*XRATIO + 1.5        
      ICOL = (BUF(2) - YMIN)*YRATIO + 1.5        
      ICOL = ICOL + IGRAPH(I123,1) - 1        
      CALL XYCHAR (IROW,ICOL,CURVCH)        
      GO TO 160        
C        
C     TERMINIATE  (DUMP GRAPH IF ANY)        
C        
  170 IF (ANY) CALL XYGRAF (IGRAPH)        
      CALL CLOSE (XYPLTT,CLORWD)        
  180 RETURN        
      END        
