      SUBROUTINE CF2FBS (TPOSE,XOUT,IOBUF)
C*******
C     CF2FBS PERFORMS THE DOUBLE-PRECISION FORWARD AND BACKWARD SWEEPS
C     FOR THE COMPLEX FEER METHOD. THESE SWEEPS CONSTITUTE THE
C     OPERATIONAL INVERSE (MATRIX INVERSION).
C*******
C     DEFINITION OF INPUT AND OUTPUT PARAMETERS
C*******
C     TPOSE    = .FALSE. --- PERFORM OPERATION L * U
C              = .TRUE.  --- PERFORM OPERATION U-TRANSPOSE * L-TRANSPOSE
C     XOUT     = INPUT VECTOR GETS TRANSFORMED TO OUTPUT VECTOR
C     IOBUF    = INPUT  GINO BUFFER
C*******
      DOUBLE PRECISION  DTEMP    ,XOUT(1)  ,DA       ,UNIDUM
      INTEGER           NAME(2)  ,IOBUF(1) ,EOL      ,CDP
      LOGICAL           TPOSE(1) ,SYMMET   ,QPR
      COMMON  /FEERAA/  AADUM(117),MCBLT(7),MCBUT(7)
      COMMON  /FEERXC/  XCD01(4) ,SYMMET   ,XCD02(9) ,NSWP
     2                 ,XCD03(6) ,QPR
      COMMON  /ZNTPKX/  DA(2)    ,II       ,EOL
      COMMON  /NAMES /  RD       ,RDREW    ,WRT      ,WRTREW
     2                 ,REW      ,NOREW    ,EOFNRW   ,RSP
     3                 ,RDP      ,CSP      ,CDP
      COMMON  /SYSTEM/  KSYSTM   ,NOUT
      EQUIVALENCE       (AADUM(42),ISCR6)
      DATA   NAME       /4HCF2F,4HBS  /                                 
C                                                                       
      IF (QPR) WRITE (NOUT,8887) TPOSE(1),SYMMET,NSWP,ISCR6
 8887 FORMAT(1H0,12HENTER CF2FBS,8X,11HTRANSPOSE =,L2,L9,2I10)          
               JUNK = 0
      IF (TPOSE(1) .AND. .NOT.SYMMET) GO TO 399
C*******
C     BELOW FOR OPERATION L * U
C     (LOGIC COPIED FROM SUBROUTINE CINFBS)
C*******
C     BEGIN FORWARD PASS USING THE LOWER TRIANGLE
C*******
      CALL GOPEN (MCBLT(1),IOBUF(1),RDREW)
      J = 1
  100 CALL INTPK(*200,MCBLT(1),0,CDP,0)
  110 IF (EOL) 3010,120,3010
  120 CALL ZNTPKI
               IF (QPR) WRITE (NOUT,8882) DA,II,EOL,J
 8882          FORMAT(1H ,4HDA =,2D16.8,4X,4HII =,I6,                   
     2                4X,5HEOL =,I2,4X,3HJ =,I4)                        
      IF (J-II) 184,130,110
C*******
C     PERFORM THE REQUIRED ROW INTERCHANGE
C*******
  130 IN1 = ( J + IFIX(SNGL(DA(1))) )*2 - 1
               IF (QPR) WRITE (NOUT,8883) IN1,EOL
 8883          FORMAT(1H ,3X,5HIN1 =,I6,4X,5HEOL =,I2)                  
      IN2 = IN1+1
      J2 = 2*J
      UNIDUM = XOUT(J2)
      XOUT(J2) = XOUT(IN2)
      XOUT(IN2) = UNIDUM
      J2 = J2-1
      UNIDUM = XOUT(J2)
      XOUT(J2) = XOUT(IN1)
      XOUT(IN1) = UNIDUM
  160 IF (EOL) 200,170,200
  170 CALL ZNTPKI
               IF (QPR) WRITE (NOUT,8882) DA,II,EOL,J
  184 II2 = 2*II
      II1 = II2-1
      J2 = 2*J
      J1 = J2-1
      XOUT(II1) = XOUT(II1) - DA(1)*XOUT(J1) + DA(2)*XOUT(J2)
      XOUT(II2) = XOUT(II2) - DA(2)*XOUT(J1) - DA(1)*XOUT(J2)
      GO TO 160
  200 J = J+1
      IF (J.LT.NSWP) GO TO 100
      CALL CLOSE (MCBLT(1),REW)
C*******
C     BEGIN BACKWARD PASS USING THE UPPER TRIANGLE
C*******
      IOFF = MCBUT(7)-1
               IF (QPR) WRITE (NOUT,8866) IOFF,MCBLT,MCBUT
 8866          FORMAT(1H ,15(1X,I7))                                    
      CALL GOPEN (MCBUT(1),IOBUF(1),RDREW)
      J = NSWP
 210  CALL INTPK(*3020,MCBUT(1),0,CDP,0)
      IF (EOL) 3020,230,3020
  230 CALL ZNTPKI
               IF (QPR) WRITE (NOUT,8882) DA,II,EOL,J
      I = NSWP - II + 1
      IF (I.NE.J) GO TO 275
C*******
C     DIVIDE BY THE DIAGONAL
C*******
      I2 = 2*I
      I1 = I2-1
      UNIDUM = 1.D0/(DA(1)**2+DA(2)**2)
      DTEMP = (DA(1)*XOUT(I1)+DA(2)*XOUT(I2))*UNIDUM
      XOUT(I2) = (DA(1)*XOUT(I2)-DA(2)*XOUT(I1))*UNIDUM
      XOUT(I1) = DTEMP
               IF (QPR) WRITE (NOUT,8884)
 8884          FORMAT(1H ,6X,8HDIAGONAL)                                
C*******                                                                
C     SUBTRACT OFF REMAINING TERMS
C*******
  255 IF (I.GT.J) GO TO 230
      IF (EOL) 300,270,300
  270 CALL ZNTPKI
               IF (QPR) WRITE (NOUT,8882) DA,II,EOL,J
      I = NSWP - II + 1
  275 IN1 = I
      IN2 = J
      IF (I.LT.J) GO TO 279
      K = IN1
      IN1 = IN2-IOFF
               JUNK = 1
      IF (IN1.LE.0) GO TO 3020
      IN2 = K
  279 IN1 = 2*IN1
      IN2 = 2*IN2
      II1 = IN1-1
      II2 = IN2-1
            IF (QPR) WRITE (NOUT,8820) I,J,II1,II2
 8820       FORMAT(1H ,3HI =,I6,6X,3HJ =,I6,6X,5HII1 =,I6,6X,5HII2 =,I6)
      XOUT(II1) = XOUT(II1) - DA(1)*XOUT(II2) + DA(2)*XOUT(IN2)
      XOUT(IN1) = XOUT(IN1) - DA(2)*XOUT(II2) - DA(1)*XOUT(IN2)
      GO TO 255
  300 J = J-1
      IF (J.GT.0) GO TO 210
      CALL CLOSE (MCBUT(1),REW)
      GO TO 4000
C*******
C     BELOW FOR OPERATION U-TRANSPOSE * L-TRANSPOSE
C     (LOGIC COPIED FROM SUBROUTINE CDIFBS)
C*******
C     BEGIN THE FORWARD PASS USING THE UPPER TRIANGLE
C*******
  399 IOFF = MCBUT(7)-1
               IF (QPR) WRITE (NOUT,2216) IOFF
 2216          FORMAT(1H ,30X,6HIOFF =,I10)                             
      MCSAVE = MCBUT(1)
      MCBUT(1) = ISCR6
      CALL GOPEN (MCBUT(1),IOBUF(1),RDREW)
      DO 500  I = 1,NSWP
               IF (QPR) WRITE (NOUT,2218) I
 2218          FORMAT(1H ,12HLOOP INDEX =,I6)                           
      J = I+I
      CALL INTPK(*500,MCBUT(1),0,CDP,0)
  410 CALL ZNTPKI
               IF (QPR) WRITE (NOUT,2224) II,EOL,DA
 2224          FORMAT(1H ,4HII =,I14,6X,5HEOL =,I2,                     
     2                8X,4HDA =,2D16.8)                                 
      IF (II-I) 430,420,440
C*******
C     DIVIDE BY THE DIAGONAL
C*******
  420 I1 = J-1
      UNIDUM = 1.D0/(DA(1)**2+DA(2)**2)
      DTEMP = (XOUT(I1)*DA(1) + XOUT(J)*DA(2))*UNIDUM
      XOUT(J) = (XOUT(J)*DA(1) - XOUT(I1)*DA(2))*UNIDUM
      XOUT(I1) = DTEMP
               IF (QPR) WRITE (NOUT,8884)
      GO TO 490
C*******
C     SUBTRACT OFF NORMAL TERM
C*******
  430 I2 = II+II
      I1 = I2-1
      J1 = J-1
      XOUT(J1) = XOUT(J1) - XOUT(I1)*DA(1) + XOUT(I2)*DA(2)
      XOUT(J) = XOUT(J) - XOUT(I1)*DA(2) - XOUT(I2)*DA(1)
      GO TO 490
C*******
C     SUBTRACT OFF ACTIVE COLUMN TERMS
C*******
  440 K = (I-IOFF)*2
               JUNK = 1
      IN1 = K
      IF (IN1.LE.0) GO TO 3020
      I2 = II+II
      I1 = I2-1
      J1 = K-1
      XOUT(I1) = XOUT(I1) - XOUT(J1)*DA(1) + XOUT(K)*DA(2)
      XOUT(I2) = XOUT(I2) - XOUT(K)*DA(1) - XOUT(J1)*DA(2)
  490 IF (EOL) 500,410,500
  500 CONTINUE
      CALL CLOSE (MCBUT(1),REW)
      MCBUT(1) = MCSAVE
C*******
C     BEGIN BACKWARD PASS USING THE LOWER TRIANGLE
C*******
      CALL GOPEN (MCBLT(1),IOBUF(1),RDREW)
      CALL SKPREC (MCBLT(1),NSWP)
      DO 600  I = 1,NSWP
               IF (QPR) WRITE (NOUT,2218) I
      CALL BCKREC (MCBLT(1))
      INTCHN = 0
      CALL INTPK(*600,MCBLT(1),0,CDP,0)
      J = (NSWP-I+1)*2
  520 CALL ZNTPKI
               IF (QPR) WRITE (NOUT,2224) II,EOL,DA
      IF (II.NE.NSWP-I+1) GO TO 550
      IF (II.LT.J/2) GO TO 3010
C*******
C     PERFORM THE INTERCHANGE
C*******
      INTCHN = IFIX(SNGL(DA(1)))*2
               IF (QPR) WRITE (NOUT,2226) INTCHN
 2226          FORMAT(1H ,4X,11HINTERCHANGE,I6)                         
      GO TO 590
  530 IN1 = J+INTCHN
               IF (QPR) WRITE (NOUT,2232) J,INTCHN,IN1
 2232          FORMAT(1H ,15X,3I6)                                      
      DTEMP = XOUT(J)
      XOUT(J) = XOUT(IN1)
      XOUT(IN1) = DTEMP
      J1 = J-1
      I1 = IN1-1
      DTEMP = XOUT(J1)
      XOUT(J1) = XOUT(I1)
      XOUT(I1) = DTEMP
      GO TO 600
  550 J1 = J-1
      I2 = II+II
      I1 = I2-1
      XOUT(J1) = XOUT(J1) - XOUT(I1)*DA(1) + XOUT(I2)*DA(2)
      XOUT(J) = XOUT(J) - XOUT(I1)*DA(2) - XOUT(I2)*DA(1)
  590 IF (EOL) 595,520,595
  595 IF (INTCHN) 600,600,530
  600 CALL BCKREC (MCBLT(1))
      CALL CLOSE (MCBLT(1),REW)
      GO TO 4000
 3010 J = MCBLT(1)
      GO TO 3040
 3020 J = MCBUT(1)
 3040 CALL MESAGE (-5,J,NAME)
 4000 CONTINUE
               IF (QPR.AND.JUNK.EQ.0) WRITE (NOUT,5516)
 5516          FORMAT(1H0,30X,13HIOFF NOT USED,/1H )                    
               IF (QPR.AND.JUNK.NE.0) WRITE (NOUT,5518)
 5518          FORMAT(1H0,30X,13HIOFF WAS USED,/1H )                    
      RETURN
      END
