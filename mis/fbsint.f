      SUBROUTINE FBSINT (X,Y)        
C        
C     GIVEN THE DECOMPOSITION OF A REAL SYMMETRIC MATRIX, FBSINT WILL   
C     SOLVE A SYSTEM OF SIMULTANEOUS LINEAR EQUATIONS BY FORWARD-       
C     BACKWARD SUBSTITUTION        
C        
C     THIS ROUTINE IS SUITABLE FOR BOTH SINGLE AND DOUBLE PRECISION     
C     OPERATION        
C        
      INTEGER         FILEL     ,IBLK(15)        
      REAL            X(1)      ,Y(1)        
      COMMON /INFBSX/ FILEL(7)        
      COMMON /FBSX  / LFILE(7)        
      EQUIVALENCE     (FILEL(3) ,NROW)        
C        
      NROW2 = NROW        
      IF (FILEL(5) .EQ. 2) NROW2 = 2*NROW        
      DO 100 I = 1,NROW2        
      Y(I) = X(I)        
  100 CONTINUE        
      DO 120 I = 1,7        
      LFILE(I) = FILEL(I)        
  120 CONTINUE        
      CALL REWIND (FILEL)        
      CALL SKPREC (FILEL,1)        
      IBLK(1) = FILEL(1)        
      IF (FILEL(5) .EQ. 1) CALL FBS1 (IBLK,Y,Y,NROW2)        
      IF (FILEL(5) .EQ. 2) CALL FBS2 (IBLK,Y,Y,NROW2)        
      RETURN        
      END        
