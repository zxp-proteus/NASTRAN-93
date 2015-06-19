      SUBROUTINE BDAT02        
C        
C     THIS SUBROUTINE PROCESSES CONCT BULK DATA AND WRITES CONNECTION   
C     ENTRIES IN TERMS OF CODED GRID POINT ID NUMBERS ON SCR1        
C        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         TDAT,PRINT        
      INTEGER         SCR1,OUTT,BUF1,BUF2,CONCT(2),FLAG,GEOM4,ID(2),    
     1                COMP,NAMS(4),IO(9),AAA(2),CONSET,ANDF,RSHIFT,COMBO
      DIMENSION       IBITS(32),JBITS(32),NAME(14),IHD(16)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,SCTOC,      
     1                GEOM4,CASECC        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /CMB002/ BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,LCORE,INPT,OUTT    
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB,CONECT,TRAN,  
     1                MCON,RESTCT(7,7),ISORT,ORIGIN(7,3),IPRINT        
      COMMON /CMB004/ TDAT(6)        
      COMMON /OUTPUT/ ITITL(96),IHEAD(96)        
      COMMON /CMBFND/ INAM(2),IERR        
      COMMON /BLANK / STEP,IDRY        
      DATA    AAA   / 4HBDAT,4H02       / , CONCT  / 210,2  /        
      DATA    IHD   / 4H  SU , 4HMMAR , 4HY OF , 4H CON , 4HNECT ,      
     1                4HION  , 4HENTR , 4HIES  , 4HSPEC , 4HIFIE ,      
     2                4HD BY , 4H CON , 4HCT   , 4HBULK , 4H DAT ,      
     3                4HA    /        
      DATA    IBLNK / 4H     /        
C        
      DO 10 I = 1,96        
      IHEAD(I) = IBLNK        
   10 CONTINUE        
      J = 1        
      DO 20 I = 73,88        
      IHEAD(I) = IHD(J)        
   20 J = J + 1        
      PRINT = .FALSE.        
      IF (ANDF(RSHIFT(IPRINT,3),1) .EQ. 1) PRINT = .TRUE.        
      NP2 = 2*NPSUB        
      DO 30 I = 1,NP2,2        
      J = I/2 + 1        
      NAME(I  ) = COMBO(J,1)        
      NAME(I+1) = COMBO(J,2)        
   30 CONTINUE        
      IFILE = SCR1        
      CALL OPEN (*220,SCR1,Z(BUF2),3)        
      CALL LOCATE (*180,Z(BUF1),CONCT,FLAG)        
      IFILE = GEOM4        
   40 CALL READ (*200,*170,GEOM4,ID,1,0,N)        
      IF (ID(1) .EQ. CONSET) GO TO 60        
      CALL READ (*200,*210,GEOM4,ID,-5,0,N)        
   50 CALL READ (*200,*210,GEOM4,ID,2,0,N)        
      IF (ID(1)+ID(2) .NE. -2) GO TO 50        
      GO TO 40        
   60 CALL READ (*200,*210,GEOM4,COMP,1,0,N)        
      IF (.NOT.PRINT) GO TO 80        
      CALL PAGE        
      CALL PAGE2 (6)        
      WRITE  (OUTT,70) (NAME(KDH),KDH=1,NP2)        
   70 FORMAT (/24X,74HNOTE  GRID POINT ID NUMBERS HAVE BEEN CODED TO THE
     1 COMPONENT SUBSTRUCTURE ,/30X,75HWITHIN A GIVEN PSEUDOSTRUCTURE BY
     2 - 1000000*COMPONENT NO. + ACTUAL GRID ID., //15X,22HCONNECTED   C
     3ONNECTION,23X,33HGRID POINT ID FOR PSEUDOSTRUCTURE/18X,3HDOF,9X,  
     44HCODE,3X,7(3X,2A4)/)        
   80 CONTINUE        
      TDAT(2) = .TRUE.        
      CALL ENCODE (COMP)        
      CALL READ (*200,*210,GEOM4,NAMS,4,0,N)        
      CALL FINDER (NAMS(1),IS1,IC1)        
      IF (IERR .NE. 1) GO TO 90        
      WRITE (OUTT,100) UFM,NAMS(1),NAMS(2)        
      IDRY = -2        
   90 CONTINUE        
      CALL FINDER (NAMS(3),IS2,IC2)        
      IF (IERR .NE. 1) GO TO 110        
      WRITE (OUTT,100) UFM,NAMS(3),NAMS(4)        
      IDRY = -2        
  100 FORMAT (A23,' 6523, THE BASIC SUBSTRUCTURE ',2A4, /30X,        
     1       'REFERED TO BY A CONCT  BULK DATA CARD CAN NOT BE FOUND ', 
     2       'IN THE PROBLEM TABLE OF CONTENTS.')        
  110 CALL READ (*200,*210,GEOM4,ID,2,0,N)        
C     RETURN        
C        
      IF (ID(1)+ID(2) .EQ. -2) GO TO 40        
      IF (IS1 .NE. IS2) GO TO 130        
      KK = 2*IS1 - 1        
      WRITE  (OUTT,120) UFM,ID(1),ID(2),NAME(KK),NAME(KK+1)        
  120 FORMAT (A23,' 6536, MANUAL CONNECTION DATA IS ATTEMPTING TO ',    
     1       'CONNECT', /31X,'GRID POINTS',I9,5X,4HAND ,I8, /31X,       
     2       'WHICH ARE BOTH CONTAINED IN PSEUDOSTRUCTURE ',2A4)        
      IDRY = -2        
  130 CONTINUE        
      DO 140 I = 1,9        
  140 IO(I) = 0        
      IO(1) = COMP        
      IO(2) = 2**(IS1-1) + 2**(IS2-1)        
      IO(2+IS1) = IC1*1000000 + ID(1)        
      IO(2+IS2) = IC2*1000000 + ID(2)        
      NWD = 2 + NPSUB        
      CALL WRITE (SCR1,IO,NWD,1)        
      IF (.NOT.PRINT .OR. IDRY.EQ.-2) GO TO 160        
      CALL BITPAT (IO(1),IBITS)        
      CALL BITPAT (IO(2),JBITS)        
      CALL PAGE2 (1)        
      WRITE (OUTT,150) (IBITS(KDH),KDH=1,2),(JBITS(KDH),KDH=1,2),       
     1                 (IO(KDH+2),KDH=1,NPSUB)        
  150 FORMAT (16X,A4,A2,6X,A4,A3,2X,7(3X,I8))        
  160 CONTINUE        
      GO TO 110        
  170 CONTINUE        
  180 CALL CLOSE (SCR1,1)        
      RETURN        
C        
  200 IMSG = -2        
      GO TO 230        
  210 IMSG = -3        
      GO TO 230        
  220 IMSG = -1        
  230 CALL MESAGE (IMSG,IFILE,AAA)        
      RETURN        
      END        
