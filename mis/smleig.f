      SUBROUTINE SMLEIG(D,O,VAL)
C
C     COMPUTES EIGENVALUES AND VECTORS FOR 1X1 AND 2X2
C
      DOUBLE PRECISION D(2),O(2),VAL(2),P,Q
      INTEGER ENTRY,XENTRY,SYSBUF,PHIA,MCB(7)
      DIMENSION VCOM(30)
C
      COMMON/SYSTEM/SYSBUF
      COMMON /GIVN / TITLE(150)
      COMMON /PACKX/IT1,IT2,II,JJ,INCR
      COMMON /UNPAKX/IT3,III,JJJ,INCR1
C
      EQUIVALENCE
     1 (MO,TITLE(2)),(MD,TITLE(3)),(ENTRY,TITLE(11)),(XENTRY,TITLE(20)),
     2 (VCOM(1),TITLE(101)),(N,VCOM(1)),(LAMA,VCOM(6)),(PHIA,VCOM(12)),
     3 (NFOUND,VCOM(10))
C
      DATA MCB/7*0/                                                     
C                                                                       
C     D        ARRAY OF DIAGONALS
C     O        ARRAY OF OFF DIAGONALS
C     VAL      ARRAY OF EIGENVALUES
C     LAMA     FILE OF EIGENVALUES--HEADER,VALUES,ORDER FOUND
C     PHIA     FILE OF  VECTORS   --......,VECTORS-D.P.
C     MO       RESTART TAPE FOR MORE EIGENVALUES
C     MD       INPUT MATRIX
C     N        ORDER OF  PROBLEM
C     NFOUND   NUMBER OF EIGENVALUES/VECTOR PREVIOUSLY FOUND
C
      IBUF1 =(KORSZ(O) - SYSBUF +1 )/2  -1
C
C     OPEN INPUT MATRIX
C
      CALL GOPEN(MD,O(IBUF1),0)
C
C     SETUP FOR UNPACK
C
      IT3 = 2
      III = 1
      JJJ = N
      INCR1= 1
      ASSIGN 101 TO ITRA
      CALL UNPACK(*1000,MD,D)
  101 IF(N .EQ. 2) GO TO 110
C
C     THE MATRIX IS A 1X1
C
      O(1) = 0.0D0
      VAL(1) = D(1)
      LOC = 1
      GO TO 120
C
C     THE MATRIX IS A 2X2
C
  110 O(1) = D(2)
      O(2) = 0.0D0
      ASSIGN 111 TO ITRA
      III = 2
      CALL UNPACK(*1000,MD,D(2))
  111 P = D(1) + D(2)
      Q = DSQRT( P*P -4.0D0*(D(1)*D(2)- O(1)**2))
      VAL(1) =(P+Q)/2.0D0
      VAL(2) = (P-Q)/2.0D0
      LOC = 0
C
C     WRAP UP ROUTINE
C
  120 CALL CLOSE(MD,1)
C
C     COPY D,O,LOC ONTO MO FOR RESTART
C
      CALL GOPEN(MO,O(IBUF1),1)
C
C     SETUP FOR PACK
C
      IM1=1
      IT1=2
      IT2=2
      II =1
      JJ = N
      INCR =1
      CALL PACK(D,MO,MCB)
      CALL PACK(O,MO,MCB)
      CALL WRITE(MO,LOC,1,1)
      CALL CLOSE(MO,1)
      IF(N .NE. 1) GO TO 125
C
C     1X1 WRITE OUT VECTORS AND VALUES
C
      MCB(1) = PHIA
      MCB(2) = 0
      MCB(3) = 1
      MCB(4) = 2
      MCB(5) = 2
      MCB(6) = 0
      CALL GOPEN(PHIA,O(IBUF1),  1)
      JJ = 1
      CALL PACK(1.0D0,PHIA,MCB)
      CALL CLOSE(PHIA,1)
      CALL WRTTRL(MCB(1))
      CALL GOPEN(LAMA,O(IBUF1),1 )
      IF (NFOUND .EQ. 0) GO TO 128
      DO 126 I= 1,NFOUND
      CALL WRITE(LAMA,0.0,1,0)
  126 CONTINUE
  128 VALX = VAL(1)
      CALL WRITE(LAMA,VALX,1,1)
      IF (NFOUND .EQ. 0) GO TO 129
      DO 127 I= 1,NFOUND
      CALL WRITE(LAMA,I,1,0)
  127 CONTINUE
  129 CALL WRITE(LAMA,NFOUND+1,1,1)
      CALL CLOSE(LAMA,1)
      MCB(1) = LAMA
      CALL WRTTRL(MCB)
  125 XENTRY = -ENTRY
      RETURN
 1000 DO 1001 I =III,JJJ
      D(I) = 0.0D0
 1001 CONTINUE
      GO TO  ITRA,(111,101)
      END
