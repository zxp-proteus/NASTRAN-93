      SUBROUTINE DADD5        
C        
C     DMAP DRIVER FOR SADD (MATRIX ADD) ROUTINE        
C     THE DMAP CALL FOR THIS MODULE IS        
C     ADD5 A,B,C,D,E / X / V,N,P1 / V,N,P2 / V,N,P3 / V,N,P4 / V,N,P5 $ 
C     THE PARAMETERS ARE ALL COMPLEX SINGLE-PRECISION.        
C        
      DIMENSION       INX(5),AMCBS(1),MC(5)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ IBUF,NOUT        
      COMMON /SADDX / NOMAT,LCORE,MCBS(67)        
CZZ   COMMON /ZZDADD/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /BLANK / ALPHA(10)        
      EQUIVALENCE     (MCBS(1),AMCBS(1)),(MCBS(61),MC(1))        
      DATA    INX   / 101,102,103,104,105 /, IOUT /201/        
C        
      LCORE = KORSZ(CORE)        
C        
      DO 10 I = 1,67        
   10 MCBS(I) = 0        
C        
C     SETUP MATRIX CONTROL BLOCKS OF THE INPUT MATRICES        
C        
      I = 1        
      K = 0        
C        
      MC(5) = 1        
      DO 20 J = 1,5        
      MCBS(I) = INX(J)        
      CALL RDTRL (MCBS(I))        
C        
C     EXCLUDE NULL MATRICES FROM MCBS ARRAY        
C        
      IF (MCBS(I) .LE. 0) GO TO 20        
C        
C     MOVE MULTIPLIERS TO MCBS ARRAY        
C        
      MCBS (I+7) = 1        
      AMCBS(I+8) = ALPHA(2*J-1)        
      AMCBS(I+9) = ALPHA(2*J)        
      IF (AMCBS(I+9) .NE. 0.0) MCBS(I+7) = 3        
C        
C     DETERMINE THE PRECISION AND TYPE OF THE OUTPUT MATRIX        
C        
      MC(5) = MAX0(MC(5),MCBS(I+4),MCBS(I+7))        
      IF (MCBS(I+4) .EQ. 2) K = 1        
      I = I + 12        
   20 CONTINUE        
C        
      MC(1) = IOUT        
      NOMAT = I/12        
      IF (NOMAT .EQ. 0) RETURN        
      IF (NOMAT .EQ. 1) GO TO 60        
C        
C     CHECK TO ENSURE THAT THE MATRICES BEING ADDED ARE OF THE SAME     
C     ORDER        
C        
      I = 14        
      DO 50 J = 2, NOMAT        
      IF (MCBS(2).EQ.MCBS(I) .AND. MCBS(3).EQ.MCBS(I+1)) GO TO 40       
      WRITE  (NOUT,30) UFM        
   30 FORMAT (A23,' 4149, ATTEMPT TO ADD MATRICES OF UNEQUAL ORDER IN ',
     1       'MODULE ADD5.')        
      CALL MESAGE (-61,0,0)        
   40 I = I + 12        
   50 CONTINUE        
   60 MC(2) = MCBS(2)        
      MC(3) = MCBS(3)        
      MC(4) = MCBS(4)        
      IF (MC(5).EQ.3 .AND. K.NE.0) MC(5) = 4        
      MC(5) = MIN0(4,MC(5))        
C        
C     ADD MATRICES        
C        
      CALL SADD   (CORE,CORE)        
      CALL WRTTRL (MC(1))        
      RETURN        
C        
      END        
