      INTEGER FUNCTION ISFT (BF,SFT,J)        
C        
      EXTERNAL LSHIFT,RSHIFT        
      INTEGER  BF,SFT,RSHIFT        
C        
      IF (J .EQ. 4) GO TO 10        
      ISFT = RSHIFT(BF,SFT)        
      RETURN        
   10 ISFT = LSHIFT(BF,SFT)        
      RETURN        
      END        
