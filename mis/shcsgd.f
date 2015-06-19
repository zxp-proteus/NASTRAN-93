      SUBROUTINE SHCSGD (*,CFLAG,CCSID,CTHETA,PFLAG,PCSID,PTHETA,       
     1                   NECPT,TUBD,CSID,THETAD,TUMSD)        
C        
C     WITH ENTRY SHCSGS (*,CFLAG,CCSID,CTHETA,PFLAG,PCSID,PTHETA,       
C    1                   NECPT,TUBS,CSID,THETAS,TUMSS)        
C        
C        
C     'COORDINATE SYSTEM GENERATOR' ROUTINE FOR SHELL ELEMENTS.        
C        
C     THIS ROUTINE USES THE VALUES IN THE EST TABLE TO CREATE        
C     APPROPRIATE MATERIAL/STRESS COORDINATE SYSTEM TRANSFORMATIONS.    
C        
C     INPUT:        
C            CFLAG    - INDICATOR FLAG FROM CONNECTION        
C            CCSID    - CSID  FROM CONNECTION        
C            CTHETA   - ANGLE FROM CONNECTION        
C            PFLAG    - INDICATOR FLAG FROM PROPERTY        
C            PCSID    - CSID  FROM PROPERTY        
C            PTHETA   - ANGLE FROM PROPERTY        
C            NECPT    - ARRAY OF LENGTH 4, WORDS 2-4 ARE THE LOCATION   
C                       WHERE THE TRANSFORMATION NEEDS TO BE CALCULATED 
C            TUBD/S   - USER TO BASIC TRANSFORMATION        
C     OUTPUT:        
C            TUMSD/S  - USER TO MATERIAL/STRESS TRANSFORMATION        
C            CSID     - CSID  USED FOR CALCULATIONS        
C            THETAD/S - THETA USED FOR CALCULATIONS        
C        
C     NOTES:        
C     1- IF CSID HAS BEEN SPECIFIED, SUBROUTINE TRANSD IS CALLED TO     
C        CALCULATE [TBMS] (MATERIAL/STRESS TO BASIC TRANSFORMATION).    
C        [TBMS] IS THEN PREMULTIPLIED BY [TUB] TO OBTAIN [TUMS].        
C        THEN USING THE PROJECTION OF X-AXIS, AN ANGLE IS CALCULATED    
C        UPON WHICH STEP 2 IS TAKEN.        
C     2- IF THETA HAS BEEN SPECIFIED, INPLANE TRANSFORMATION IS USED TO 
C        CALCULATE [TUMS] (MATERIAL/STRESS TO USER TRANSFORMATION).     
C     3- IF THE CONNECTION VALUE IS LEFT BLANK, THE PROPERTY VALUE IS   
C        USED.        
C     4- NON-STANDARD RETURN IS TAKEN WHEN THE X-AXIS OF THE SPECIFIED  
C        COORDINATE SYSTEM DOES NOT HAVE A PROJECTION ON THE X-Y PLANE  
C        OF THE ELEMENT COORD. SYSTEM        
C        
C        
      INTEGER          CSID,CCSID,PCSID,CFLAG,PFLAG,NECPT(4)        
      REAL             TUBS(9),TUMSS(9),TBMSS(9),XMS,YMS,THETAS,EPS1S,  
     1                 PIS,TWOPIS,RADDGS,DEGRDS,FLIPS        
      DOUBLE PRECISION TUBD(9),TUMSD(9),TBMSD(9),XMD,YMD,THETAD,EPS1D,  
     1                 PID,TWOPID,RADDGD,DEGRDD,FLIPD        
      COMMON /CONDAS/  PIS,TWOPIS,RADDGS,DEGRDS        
      COMMON /CONDAD/  PID,TWOPID,RADDGD,DEGRDD        
      EQUIVALENCE      (TBMSS(1),TBMSD(1))        
      DATA    EPS1D ,  EPS1S /1.0D-7, 1.0E-7 /        
C        
C        
C     DOUBLE PRECISION VERSION        
C        
      FLIPD = 1.0D0        
      IF (CFLAG .EQ. 0) GO TO 130        
C        
C     DETERMINE THETA FROM THE PROJECTION OF THE X-AXIS OF THE MATERIAL/
C     STRESS COORD. SYSTEM, DETERMINED BASED ON CCSID, ONTO THE XY-PLANE
C     OF THE ELEMENT COORD. SYSTEM.        
C        
      CSID = CCSID        
      IF (CCSID .GT. 0) GO TO 110        
C        
C     [TUMS] = [TUB]        
C        
      DO 100 I = 1,9        
      TUMSD(I) = TUBD(I)        
 100  CONTINUE        
      GO TO 120        
C        
C     [TUMS] = [TUB] [TBMS]        
C        
 110  NECPT(1) = CCSID        
      CALL TRANSD (NECPT,TBMSD)        
      CALL GMMATD (TUBD,3,3,0, TBMSD,3,3,0, TUMSD)        
C        
 120  XMD = TUMSD(1)        
      YMD = TUMSD(4)        
      IF (DABS(XMD).LE.EPS1D .AND. DABS(YMD).LE.EPS1D) RETURN 1        
      THETAD = DATAN2(YMD,XMD)        
      IF (TUMSD(9) .LT. 0.0D0) FLIPD = -1.0D0        
      GO TO 190        
C        
 130  IF (CTHETA .EQ. 0.0) GO TO 140        
C        
C     DETERMINE THETA FROM CTHETA        
C        
      THETAD = DBLE(CTHETA)*DEGRDD        
      GO TO 190        
C        
C     DEFAULT IS CHOSEN, LOOK FOR VALUES OF PCSID AND/OR PTHETA ON THE  
C     PSHELL CARD.        
C        
 140  IF (PFLAG .EQ. 0) GO TO 180        
C        
C     DETERMINE THETA FROM THE PROJECTION OF THE X-AXIS OF THE MATERIAL/
C     STRESS COORD. SYSTEM, DETERMINED BASED ON PCSID, ONTO THE XY-PLANE
C     OF THE ELEMENT COORD. SYSTEM.        
C        
      CSID = PCSID        
      IF (PCSID .GT. 0) GO TO 160        
C        
C     [TUMS] = [TUB]        
C        
      DO 150 I = 1,9        
      TUMSD(I) = TUBD(I)        
 150  CONTINUE        
      GO TO 170        
C        
C     [TUMS] = [TUB] [TBMS]        
C        
 160  NECPT(1) = PCSID        
      CALL TRANSD (NECPT,TBMSD)        
      CALL GMMATD (TUBD,3,3,0, TBMSD,3,3,0, TUMSD)        
C        
 170  XMD = TUMSD(1)        
      YMD = TUMSD(4)        
      IF (DABS(XMD).LE.EPS1D .AND. DABS(YMD).LE.EPS1D) RETURN 1        
      THETAD = DATAN2(YMD,XMD)        
      IF (TUMSD(9) .LT. 0.0D0) FLIPD = -1.0D0        
      GO TO 190        
C        
C     DETERMINE THETA FROM PTHETA        
C        
 180  THETAD = DBLE(PTHETA)*DEGRDD        
C        
C     IF THE Z-AXIS OF THE TARGET MATERIAL/STRESS COORD. SYSTEM WAS NOT 
C     POINTING IN THE SAME GENERAL DIRECTION AS THE Z-AXIS OF THE USER  
C     COORD. SYSTEM, FLIP THE Y- AND Z-AXES OF THE FINAL COORDINATE     
C     SYSTEM TO ACCOUNT FOR IT.        
C        
 190  TUMSD(1) = DCOS(THETAD)        
      TUMSD(2) =-FLIPD*DSIN(THETAD)        
      TUMSD(3) = 0.0D0        
      TUMSD(4) = DSIN(THETAD)        
      TUMSD(5) = FLIPD*DCOS(THETAD)        
      TUMSD(6) = 0.0D0        
      TUMSD(7) = 0.0D0        
      TUMSD(8) = 0.0D0        
      TUMSD(9) = FLIPD        
C        
      RETURN        
C        
C        
      ENTRY SHCSGS (*,CFLAG,CCSID,CTHETA,PFLAG,PCSID,PTHETA,        
     1              NECPT,TUBS,CSID,THETAS,TUMSS)        
C     ======================================================        
C        
C     SINGLE PRECISION VERSION        
C        
      FLIPS = 1.0        
      IF (CFLAG .EQ. 0) GO TO 230        
C        
C     DETERMINE THETA FROM THE PROJECTION OF THE X-AXIS OF THE MATERIAL/
C     STRESS COORD. SYSTEM, DETERMINED BASED ON CCSID, ONTO THE XY-PLANE
C     OF THE ELEMENT COORD. SYSTEM.        
C        
      CSID = CCSID        
      IF (CCSID .GT. 0) GO TO 210        
C        
C     [TUMS] = [TUB]        
C        
      DO 200 I = 1,9        
      TUMSS(I) = TUBS(I)        
 200  CONTINUE        
      GO TO 220        
C        
C     [TUMS] = [TUB] [TBMS]        
C        
 210  NECPT(1) = CCSID        
      CALL TRANSS (NECPT,TBMSS)        
      CALL GMMATS (TUBS,3,3,0, TBMSS,3,3,0, TUMSS)        
C        
 220  XMS = TUMSS(1)        
      YMS = TUMSS(4)        
      IF (ABS(XMS).LE.EPS1S .AND. ABS(YMS).LE.EPS1S) RETURN 1        
      THETAS = ATAN2(YMS,XMS)        
      IF (TUMSS(9) .LT. 0.0) FLIPS = -1.0        
      GO TO 290        
C        
 230  IF (CTHETA .EQ. 0.0) GO TO 240        
C        
C     DETERMINE THETA FROM CTHETA        
C        
      THETAS = CTHETA*DEGRDS        
      GO TO 290        
C        
C     DEFAULT IS CHOSEN, LOOK FOR VALUES OF PCSID AND/OR PTHETA ON THE  
C     PSHELL CARD.        
C        
 240  IF (PFLAG .EQ. 0) GO TO 280        
C        
C     DETERMINE THETA FROM THE PROJECTION OF THE X-AXIS OF THE MATERIAL/
C     STRESS COORD. SYSTEM, DETERMINED BASED ON PCSID, ONTO THE XY-PLANE
C     OF THE ELEMENT COORD. SYSTEM.        
C        
      CSID = PCSID        
      IF (PCSID .GT. 0) GO TO 260        
C        
C     [TUMS] = [TUB]        
C        
      DO 250 I = 1,9        
      TUMSS(I) = TUBS(I)        
 250  CONTINUE        
      GO TO 270        
C        
C     [TUMS] = [TUB] [TBMS]        
C        
 260  NECPT(1) = PCSID        
      CALL TRANSS (NECPT,TBMSS)        
      CALL GMMATS (TUBS,3,3,0, TBMSS,3,3,0, TUMSS)        
C        
 270  XMS = TUMSS(1)        
      YMS = TUMSS(4)        
      IF (ABS(XMS).LE.EPS1S .AND. ABS(YMS).LE.EPS1S) RETURN 1        
      THETAS = ATAN2(YMS,XMS)        
      IF (TUMSS(9) .LT. 0.0) FLIPS = -1.0        
      GO TO 290        
C        
C     DETERMINE THETA FROM PTHETA        
C        
 280  THETAS = PTHETA*DEGRDS        
C        
C     IF THE Z-AXIS OF THE TARGET MATERIAL/STRESS COORD. SYSTEM WAS NOT 
C     POINTING IN THE SAME GENERAL DIRECTION AS THE Z-AXIS OF THE USER  
C     COORD. SYSTEM, FLIP THE Y- AND Z-AXES OF THE FINAL COORDINATE     
C     SYSTEM TO ACCOUNT FOR IT.        
C        
 290  TUMSS(1) = COS(THETAS)        
      TUMSS(2) =-FLIPS*SIN(THETAS)        
      TUMSS(3) = 0.0        
      TUMSS(4) = SIN(THETAS)        
      TUMSS(5) = FLIPS*COS(THETAS)        
      TUMSS(6) = 0.0        
      TUMSS(7) = 0.0        
      TUMSS(8) = 0.0        
      TUMSS(9) = FLIPS        
C        
      RETURN        
      END        
