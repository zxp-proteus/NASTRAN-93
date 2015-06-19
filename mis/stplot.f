      SUBROUTINE STPLOT (PLTNUM)        
C        
      INTEGER         PLTNUM,DATE(3),IDTE(8),CHAR,PLOTER,PLTYPE,PLTAPE, 
     1                EOF,CAMERA,BFRAMS        
      REAL            SAVE(2,2)        
      COMMON /XXPARM/ PBUFSZ,CAMERA,BFRAMS        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /CHAR94/ CHAR(60)        
      COMMON /PLTDAT/ MODEL,PLOTER,REG(2,2),XYMAX(13),CHRSCL,SKPA1(3),  
     1                CNTX,SKPA2(5),PLTYPE,PLTAPE,SKPA3,EOF        
      EQUIVALENCE     (KSYSTM(15),DATE(1))        
      DATA    IDTE  / 2*1H ,1H/, 2*1H , 1H/, 2*1H  /, LSTPLT, M / 0,0 / 
C        
      IF (PLTNUM .LT. 0) GO TO 150        
C        
C     SELECT THE PROPER CAMERA        
C        
      CALL SELCAM (CAMERA,PLTNUM,0)        
C        
C     GENERATE THE ID PLOT        
C        
      IF (PLOTER .NE. LSTPLT) CALL SKPFRM (1)        
      LSTPLT = PLOTER        
      CALL IDPLOT (ID)        
      IF (ID .EQ. 0) GO TO 120        
      CALL SELCAM (CAMERA,PLTNUM,0)        
      CALL SKPFRM (1)        
C        
C     INSERT THE BLANK FRAMES ON FILM ONLY        
C        
  120 IF (CAMERA.EQ.2 .OR. IABS(PLTYPE).NE.1) GO TO 130        
      IF (BFRAMS .EQ. 0) GO TO 130        
      CALL SELCAM (1,0,1)        
      CALL SKPFRM (MAX0(BFRAMS,1))        
  130 CALL SELCAM (CAMERA,0,1)        
C        
C     TYPE THE PLOT NUMBER IN UPPER LEFT AND RIGHT CORNERS OF THE PLOT  
C        
      IF (PLTNUM .EQ. 0) GO TO 135        
      DO 131 I  = 1,2        
      SAVE(I,1) = REG(I,1)        
      REG (I,1) = 0.        
      SAVE(I,2) = REG(I,2)        
      REG (I,2) = XYMAX(I)        
  131 CONTINUE        
      CALL TYPINT (0,0,0,0,0,-1)        
      CALL TYPINT (REG(1,1)+CHRSCL,REG(2,2)-CHRSCL,+1,PLTNUM,0,0)       
C        
C     PRINT THE DATE        
C        
      IF (M .NE. 0) GO TO 1312        
      DO 1311 N = 1,7,3        
      M = M + 1        
      I = DATE(M)/10 + 1        
      J = DATE(M) - (I-1)*10 + 1        
      IF (I .EQ. 1) I = 48        
      IDTE(N  ) = CHAR(I)        
 1311 IDTE(N+1) = CHAR(J)        
C        
 1312 CALL TIPE (8.*CNTX,REG(2,2)-CHRSCL,1,IDTE(1),8,0)        
C        
      CALL TYPINT (REG(1,2)-CHRSCL,REG(2,2)-CHRSCL,-1,PLTNUM,0,0)       
      DO 132 I = 1,2        
      REG(I,1) = SAVE(I,1)        
      REG(I,2) = SAVE(I,2)        
  132 CONTINUE        
  135 CALL TYPINT (0,0,0,0,0,1)        
      GO TO 200        
C        
C     TERMINATE A PLOT        
C        
  150 CALL SKPFRM (1)        
      CALL TYPINT (0,0,0,0,0,1)        
      IF (EOF .EQ. 0) CALL SEOF (PLTAPE)        
      CALL SCLOSE (PLTAPE)        
C        
  200 RETURN        
      END        
