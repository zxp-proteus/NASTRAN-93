      FUNCTION KRSHFT (IWORD,N)        
C        
C     CHARACTER FUNCTION KRSHFT AND KLSHFT PERFORM LEFT AND RIGHT       
C     SHIFTS, BY N CHARACTERS (BYTES).        
C     EMPTY BYTES ARE ZERO FILLED.        
C        
C     NORMALLY, KRSHFT AND KLSHFT WORK ALMOST LIKE RSHIFT AND LSHFIT    
C     RESPECTIVELY, EXCEPT THEY MOVE DATA BY BYTE COUNT, NOT BY BITS.   
C     HOWEVER, IF THE MACHINE STORES THE BCD WORD DATA IN REVERSE ORDER 
C     (SUCH AS VAX AND SILICON GRAPHICS), KRSHFT IS EQUIVALENCED TO     
C     LSHFIT, AND KLSFHT TO RSHIFT.        
C        
      EXTERNAL        LSHIFT,   RSHIFT        
      INTEGER         IWORD(1), RSHIFT        
      COMMON /MACHIN/ MAC(3),   LQRO        
      COMMON /SYSTEM/ DUMMY(38),NBPC        
C        
      IF (MOD(LQRO,10) .EQ. 1) GO TO 10        
      KRSHFT = RSHIFT(IWORD(1),N*NBPC)        
      RETURN        
   10 KRSHFT = LSHIFT(IWORD(1),N*NBPC)        
      RETURN        
C        
      ENTRY KLSHFT (IWORD,N)        
C     ======================        
C        
      IF (MOD(LQRO,10) .EQ. 1) GO TO 20        
      KLSHFT = LSHIFT(IWORD(1),N*NBPC)        
      RETURN        
   20 KLSHFT = RSHIFT(IWORD(1),N*NBPC)        
      RETURN        
      END        
