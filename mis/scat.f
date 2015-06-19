      SUBROUTINE SCAT (KG,NCON,INV,II3,NORIG)        
C        
C     THIS ROUTINE IS USED ONLY IN BANDIT MODULE        
C        
C     THIS ROUTINE USES SCATTER SORT TECHNIQUES FOR EACH GRID POINT     
C     ENCOUNTERED TO DETERMINE WHETHER OR NOT THE POINT HAS BEEN SEEN   
C     BEFORE.   IF NOT, INV, NORIG, AND NN ARE UPDATED.        
C        
C     INV(I,1) CONTAINS AN ORIGINAL GRID POINT NUMBER        
C     INV(I,2) CONTAINS THE INTERNAL NUMBER ASSIGNED TO IT (BEFORE SORT)
C        
      DIMENSION       KG(1),    NORIG(1),    INV(II3,2)        
      COMMON /BANDB / DUM3B(3), NGRID        
      COMMON /BANDS / NN,       DUM3(3),  MAXGRD,   MAXDEG,   KMOD      
      COMMON /SYSTEM/ ISYS,     NOUT        
C        
      IF (NCON .LT. 1) RETURN        
      DO 50 I = 1,NCON        
      NOLD = KG(I)        
      IF (NOLD .EQ. 0) GO TO 50        
      LOC = NOLD - 1        
   20 LOC = MOD(LOC,KMOD) + 1        
      IF (INV(LOC,1) .NE. 0) GO TO 30        
      INV(LOC,1) = NOLD        
      NN = NN + 1        
      IF (NN .GT. MAXGRD) GO TO 60        
      NORIG(NN) = NOLD        
      INV(LOC,2) = NN        
      GO TO 40        
   30 IF (INV(LOC,1) .NE. NOLD) GO TO 20        
   40 KG(I) = INV(LOC,2)        
   50 CONTINUE        
      RETURN        
C        
   60 NGRID = -1        
      RETURN        
      END        
