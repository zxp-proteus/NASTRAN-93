      SUBROUTINE CYCT2B (INPUT,OUTPT,NCOL,IZ,MCB)        
C        
C     THE PURPOSE OF THIS SUBROUTINE IS TO COPY NCOL COLUMNS FROM       
C     INPUT TO OUTPUT USING CORE AT IZ -- MCB IS THE TRAILER        
C        
      INTEGER         OUTPT,IZ(4),MCB(7)        
      COMMON /UNPAKX/ ITC,IIK,JJK,INCR1        
      COMMON /PACKX / ITA,ITB,II,JJ,INCR        
      EQUIVALENCE     (ZERO,IZERO)        
      DATA    ZERO  / 0.0 /        
C        
C        
      ITA = IABS(ITC)        
      ITB = ITA        
      INCR= INCR1        
      DO 30 I = 1,NCOL        
      IIK = 0        
      CALL UNPACK (*20,INPUT,IZ)        
      II  = IIK        
      JJ  = JJK        
   10 CALL PACK (IZ,OUTPT,MCB)        
      GO TO 30        
C        
C     NULL COLUMN        
C        
   20 II = 1        
      JJ = 1        
      IZ(1) = IZERO        
      IZ(2) = IZERO        
      IZ(3) = IZERO        
      IZ(4) = IZERO        
      GO TO 10        
   30 CONTINUE        
C        
      RETURN        
      END        
