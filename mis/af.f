      SUBROUTINE AF (F,N,A,B,C,C1,C2,C3,T1,T3,T5,JUMP)
C
C     THIS AREA INTEGRATION ROUTINE IS USED IN TRIM6, TRPLT1 AND TRSHL
C     IT COMPUTES THE F FUNCTION, AND CONSTANTS C1, C2, C3
C
C     FAC ARE THE FACTORIALS 1 THRU 36
C     B   IS  DISTANCE OF GRID POINT 1
C     A   IS  DISTANCE OF GRID POINT 3
C     C   IS  DISTANCE OF GRID POINT 5
C     T1  IS  ASSOCIATIVE VARIABLE AT GRID POINT 1
C     T3  IS  ASSOCIATIVE VARIABLE AT GRID POINT 3
C     T5  IS  ASSOCIATIVE VARIABLE AT GRID POINT 5
C     N   IS  DIMENSION OF AREA FUNCTION F
C
C
C
      REAL             F(N,N)
      DOUBLE PRECISION FAC(20), TEMP
      DATA FAC / 1.D0,1.D0, 2.D0,6.D0, 2.4D1,  1.2D2, 7.2D2, 5.04D3,    
     1           4.032D4,       3.6288D5,     3.6288D6,     3.99168D7,  
     2           4.790016D8,    6.227021D9,   8.7178291D10, 1.307674D12,
     3           2.092279D13,   3.556874D14,  6.402374D15,  1.216451D17/
C                                                                       
      IF (JUMP .GT. 0) GO TO 30
      IF (N .GT. 18) STOP 'IN AF'
      DO 10 I=1,N
      DO 10 J=1,N
 10   F(I,J)=0.0
      DO 20 I=1,N
      I1=I
      DO 15 J=1,I
      TEMP = DBLE(C**J) * FAC(I1) / FAC(I+2)
      TEMP = DBLE(A**I1-(-B)**I1) * TEMP * FAC(J)
      F(I1,J) = SNGL(TEMP)
      I1=I1-1
 15   CONTINUE
 20   CONTINUE
      IF (JUMP .LT. 0) RETURN
C
 30   AB=A-B
      IF (A .EQ. B .AND. A .NE. 0.0) AB=A+B
      IF (AB .EQ. 0.0) CALL MESAGE (-37,0,0)
      C1=(T1*A-T3*B)/AB
      C2=(T3-T1)/AB
      C3=(T5-C1)/C
      RETURN
      END
