      SUBROUTINE IDPLOT (IDX)        
C        
      COMMON /OUTPUT/ SKPOUT(32,6),ID(32)        
      COMMON /PLTDAT/ SKPPLT(2),XYMIN(2),XYMAX(2),AXYMAX(2),EDGE(12)    
     1,      SKPA(3),CNTX,CNTY,SKPB(4),PLTYPE        
      INTEGER PLTYPE        
C        
      INTEGER BLANK        
      REAL SAVE(2,4)        
      DATA BLANK,LINSIZ / 1H ,3 /        
C        
C     DOES A PLOT ID EXIST AT ALL        
C        
      IDX = 1        
      DO 101 I = 1,20        
      IF (ID(I).NE.BLANK)  GO TO 102        
  101 CONTINUE        
      IDX = 0        
      GO TO 200        
C        
  102 DO 103 I = 1,2        
      SAVE(I,1) = XYMIN(I)        
      XYMIN(I) = 0.        
      SAVE(I,2) = XYMAX(I)        
      XYMAX(I) = AXYMAX(I)+EDGE(I)        
      SAVE(I,3) = AXYMAX(I)        
      AXYMAX(I) = XYMAX(I)        
      SAVE(I,4) = EDGE(I)        
      EDGE(I) = 0.        
  103 CONTINUE        
      NLINES = (AXYMAX(2)-7.*CNTY) / FLOAT(2*LINSIZ) + .1        
      IF (IABS(PLTYPE).NE.1)  GO TO 122        
C        
C     FILL TOP HALF OF PLOT WITH X-AXIS LINES ALL THE WAY ACROSS.       
C        
      CALL AXIS (0,0,0,0,0,-1)        
      DO 111 I = 1,NLINES        
      Y = XYMAX(2) - FLOAT((I-1)*LINSIZ)        
      CALL AXIS (XYMIN(1),Y,XYMAX(1),Y,1,0)        
  111 CONTINUE        
C        
C     PRINT THE PLOT ID 2 TIMES IN THE MIDDLE OF THE PLOT.        
C        
      CALL PRINT (0,0,0,0,0,-1)        
      X = XYMIN(1) + AMAX1(0.,(AXYMAX(1)-80.*CNTX)/2.)        
      YY = Y-CNTY        
      DO 116 I = 1,2        
      Y = YY - CNTY*FLOAT(I-1)        
      CALL PRINT (X,Y,1,ID,20,0)        
  116 CONTINUE        
C        
C     FILL BOTTOM HALF OF PLOT WITH X-AXIS LINES ALL THE WAY ACROSS.    
C        
      CALL AXIS (0,0,0,0,0,-1)        
      DO 121 I = 1,NLINES        
      Y = XYMIN(2) + FLOAT((I-1)*LINSIZ)        
      CALL AXIS (XYMIN(1),Y,XYMAX(1),Y,1,0)        
  121 CONTINUE        
      CALL AXIS (0,0,0,0,0,1)        
      GO TO 125        
C        
C     NOT A CRT PLOTTER. TYPE THE ID ONCE AT THE BOTTOM OF THE PAPER.   
C        
  122 CALL PRINT (0,0,0,0,0,-1)        
      X = XYMIN(1) + AMAX1(0.,(AXYMAX(1)-80.*CNTX)/2.)        
      Y = 0.        
      IF (PLTYPE.LT.0)  Y=CNTY/2.        
      CALL PRINT (X,Y,1,ID,20,0)        
C        
C     END OF ID PLOT. PUT BLANKS IN THE PLOT ID.        
C        
  125 CALL PRINT (0,0,0,0,0,1)        
      DO 126 I = 1,20        
      ID(I) = BLANK        
  126 CONTINUE        
      DO 127 I = 1,2        
      XYMIN(I) = SAVE(I,1)        
      XYMAX(I) = SAVE(I,2)        
      AXYMAX(I) = SAVE(I,3)        
      EDGE(I) = SAVE(I,4)        
  127 CONTINUE        
C        
  200 RETURN        
      END        
