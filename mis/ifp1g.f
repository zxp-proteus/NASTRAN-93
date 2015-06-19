      SUBROUTINE IFP1G (ITYPE,CASE,ISUB1)        
C        
C     MAKE SURE THIS VERSION ALSO WORKS IN UNIVAC, IBM, CDC AND 64-BIT  
C     MACHINES        
C     ================================================================  
C     IZZZBB = 0 (ALL BITS ZERO)        
C     IBEN   = FIRST BYTE BLANK, REST IS ZERO FILL        
C     EQUAL  = FIRST BYTE EQUAL, REST IS ZERO FILL        
C        
      INTEGER         CHAR,CORE(1),COREY(401),EQUAL,TITLE,CASE(200,2)   
      COMMON /OUTPUT/ TITLE(32)        
CZZ   COMMON /ZZIFP1/ COREX(1)        
      COMMON /ZZZZZZ/ COREX(1)        
      COMMON /IFP1A / SKIP1(3),NWPC,NCPW4,SKIP2(4),IZZZBB,ISTR,SKIP3(2),
     1                IBEN,EQUAL        
      EQUIVALENCE     (COREX(1),COREY(1)), (CORE(1),COREY(401))        
C        
C     FIND EQUAL SIGN AND COPY REMAINING DATA ON CARD        
C        
C     OR FIND THE FIRST BLANK CHARACTER AFTER THE FIRST NON-BLANK WORD  
C     (USED ONLY FOR ITYPE = 8, PTITLE, AXIS TITLE ETC. WHERE EQUAL SIGN
C     IS OPTIONAL AND NOT MANDATORY)        
C        
      K  = -1        
      I2 = NWPC - 2        
      DO 160 I = 1,I2        
      DO 160 J = 1,NCPW4        
      CHAR = KHRFN1(IZZZBB,1,CORE(I),J)        
      IF (CHAR .EQ. EQUAL) GO TO 170        
      IF (CHAR.NE.IBEN .AND. K.EQ.-1) K = 0        
      IF (CHAR.EQ.IBEN .AND. K.EQ. 0) K = I*100 + J        
  160 CONTINUE        
      IF (ITYPE .NE. 8) GO TO 170        
      I  = K/100        
      J  = MOD(K,100)        
  170 K  = (ITYPE-1)*32        
      K1 = K + 38        
      IF (ITYPE .EQ. 8) K1 = 0        
      IF (J  .NE. NCPW4) GO TO 180        
      I = I + 1        
      J = 0        
  180 J = J + 1        
      IPOS  = 1        
      ITS   = K + 1        
      ISAVE = IZZZBB        
      DO 250 II = I,I2        
  190 ISAVE = KHRFN1(ISAVE,IPOS,CORE(II),J)        
      IPOS  = IPOS + 1        
      IF (IPOS .GT. 4) GO TO 210        
  200 J = J + 1        
      IF (J .LE. NCPW4) GO TO 190        
      J = 1        
      GO TO 250        
  210 IPOS = 1        
      IF (ITYPE .EQ. 7) GO TO 220        
      IF (ISTR-1) 220,230,220        
  220 TITLE(ITS) = ISAVE        
      GO TO 240        
  230 CASE(K1+1,ISUB1) = ISAVE        
      K1 = K1 + 1        
  240 ISAVE = IZZZBB        
      ITS = ITS + 1        
      GO TO 200        
  250 CONTINUE        
      DO 260 I = IPOS,4        
  260 ISAVE = KHRFN1(ISAVE,I,IBEN,1)        
      IF (ITYPE .EQ. 7) GO TO 270        
      IF (ISTR-1) 270,280,270        
  270 TITLE(ITS) = ISAVE        
      GO TO 290        
  280 CASE(K1+1,ISUB1) = ISAVE        
  290 RETURN        
      END        
