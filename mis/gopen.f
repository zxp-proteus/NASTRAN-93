      SUBROUTINE GOPEN (FILE,BUFFER,OPTION)        
C        
      INTEGER FILE,OPTION,ERR,OUTREW,OUTNOR        
      REAL    BUFFER(1),SUBNAM(2),HEADER(2)        
      DATA    SUBNAM / 4H GOP,4HEN  /        
      DATA    OUTREW,INPNOR,OUTNOR  / 1,2,3 /        
C        
      CALL OPEN (*200,FILE,BUFFER,OPTION)        
      IF (OPTION.EQ.INPNOR .OR. OPTION.EQ.OUTNOR) GO TO 150        
      IF (OPTION.EQ.OUTREW)  GO TO 110        
      CALL READ (*201,*202,FILE,HEADER,2,1,ERR)        
      GO TO 150        
  110 CALL FNAME (FILE,HEADER)        
      CALL WRITE (FILE,HEADER,2,1)        
  150 RETURN        
C        
  200 ERR = -1        
      GO TO 210        
  201 ERR = -2        
      GO TO 210        
  202 ERR = -3        
  210 CALL MESAGE (ERR,FILE,SUBNAM)        
C        
      RETURN        
      END        
