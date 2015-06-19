      SUBROUTINE TRLG        
C        
C     THIS IS THE MODULE DRIVER FOR  TRLG(TRANSIENT LOAD GENERATOR)     
C        
C     INPUTS(14)        
C       CASEXX      CASECONTROL        
C       USETD        
C       DLT         DYNAMIC LOAD TABLE        
C       SLT         STATIC  LOAD TABLE        
C       BGPDT       BASIC GRID POINT DEFINITION TABLE        
C       SIL         SCALAR INDEX LIST        
C       CSTM        COORDINATE SYSTEMS        
C       TRL         TRANSIENT RESPONSE LIST        
C       DIT         DIRECT INPUT TABELS        
C       GMD        
C       GOD        
C       PHIDH        
C       EST        
C       MGG         MASS MATRIX FOR GRAVITY LOADS        
C       MPT        
C     OUTPUTS(6)        
C       PPO        
C       PSO        
C       PDO        
C       PD        
C       PH        
C       TOL        
C     PARAMETERS        
C      IP1 = -1     IF (AP = AD)        
C      NCOL.LE.0    NO CONTINUE MODE (TO = 0.0)        
C      NCOL.GT.0    CONTINUE MODE (TO = LAST TIME)        
C        
C     SCRATCHES (9)        
C        
      INTEGER  CASEXX,USETD,DLT,SLT,BGPDT,SIL,CSTM,TRL,DIT,GMD,GOD,     
     1         PHIDH,PPO,PSO,PDO,PD,PH,TOL,SCR1,SCR2,SCR3,SCR4,SCR5,    
     2         SCR6,SCR7,AP,AS,AD,AH,TMLDTB,FCT,FCO,SCR8,EST,SCR9,MCB(7)
C        
      COMMON /BLANK/ IP1,NCOL        
C        
      DATA  CASEXX,USETD,DLT,SLT,BGPDT,SIL,CSTM,TRL,DIT,GMD,GOD,PHIDH/  
     1      101   , 102 ,103,104,105  ,106,107 ,108,109,110,111,112  /  
      DATA  EST,MGG,MPT /        
     1      113,114,115 /        
      DATA  PPO,PSO,PDO,PD ,PH ,TOL /        
     1      201,202,203,204,205,206 /        
      DATA  SCR1,SCR2,SCR3,SCR4,SCR5,SCR6,SCR7,SCR8,SCR9 /        
     1      301 ,302 ,303 ,304 ,305, 306 ,307 ,308 ,309  /        
C        
C     FORM AP MATRIX AND EXTRACT LOAD TABLES        
C        
      AP = SCR1        
      TMLDTB = SCR2        
      CALL TRLGA (CASEXX,USETD,DLT,SLT,BGPDT,SIL,CSTM,AP,TMLDTB,ITRL,   
     1            SCR3,SCR4,SCR5,EST,SCR6,MGG,SCR7,MPT)        
C        
C     REDUCE TRANSFORMATION MATRIX        
C        
      AS = SCR3        
      AD = SCR4        
      AH = SCR5        
      MCB(1) = AP        
      CALL RDTRL (MCB)        
      IF (MCB(2) .LE. 0) GO TO 10        
      CALL TRLGB (USETD,AP,GMD,GOD,PHIDH,AS,AD,AH,IP1,SCR6,SCR7,SCR8,   
     1            SCR9)        
C        
C     PRODUCE TIME FUNCTION MATRIX        
C        
   10 CONTINUE        
      FCT = SCR6        
      FCO = SCR7        
      CALL  TRLGC (TMLDTB,TRL,DIT,ITRL,FCT,FCO,TOL,IP2)        
      IF (MCB(2) .LE. 0) GO TO 20        
      IF (IP2  .EQ.  -1) FCO = FCT        
C        
C     COMPUTE LOAD FACTORS        
C        
      CALL TRLGD (FCT,FCO,AP,AS,AD,AH,PPO,PSO,PDO,PD,PH,IP1,SCR2,IP2)   
   20 CONTINUE        
      RETURN        
      END        
