      INTEGER FUNCTION EJECT (LINES)        
      COMMON /SYSTEM/ SKP1(8),MAXLIN,SKP2(2),LINCNT        
C        
C     LINES = NUNBER OF LINES TO BE PRINTED.        
C     RESULT = 1 IF NEW PAGE IS STARTED.        
C        
      EJECT = 0        
      IF (LINCNT+LINES+2 .LE. MAXLIN) GO TO 105        
      CALL PAGE1        
      EJECT = 1        
  105 RETURN        
      END        
