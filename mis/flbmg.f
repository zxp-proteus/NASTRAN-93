      SUBROUTINE FLBMG        
C        
C     DRIVER FOR MODULE FLBMG        
C        
C     COMPUTES THE HYDROELASTIC AREA FACTOR MATRIX AND THE        
C     GRAVITATIONAL STIFFNESS MATRIX.        
C        
C     THE HYDROELASTIC USET VECTOR IA ALSO BUILT.        
C        
C     DMAP CALL        
C        
C        FLBMG    GEOM2,ECT,BGPDT,SIL,MPT,GEOM3,CSTM,USET,EQEXIN/       
C                 USETF,USETS,AF,DKGG/S,N,NOGRAV/S,N,NOFREE/S,N,TILT $  
C        
C     INPUT DATA BLOCKS        
C        
C        GEOM2  - FLUID ELEMENT BOUNDARY DATA        
C        ECT    - ELEMENT CONNECTION TABLE        
C        BGPDT  - BASIC GRID POINT DEFINITION TABLE        
C        SIL    - SCALAR INDEX LIST        
C        MPT    - MATERIAL PROPERTIES TABLE        
C        GEOM3  - GRAVITY LOAD DATA        
C        CSTM   - COORDINATE SYSTEM TRANSFORMATION MATRICES        
C        USET   - DISPLACEMENT SET DEFINITION TABLE        
C        EQEXIN - EQUIVALENCE BETWEEN EXTERNAL AND INTERNAL GRID POINTS 
C        
C     OUTPUT DATA BLOCK        
C        
C        USETF  - FLUID AND STRUCTURAL POINT SET DEFINITION TABLE       
C        USETS  - STRUCTURAL POINT SET DEFINITION TABLE        
C        AF     - FLUID AREA FACTOR MATRIX        
C        DKGG   - STRUCTURAL GRAVITY STIFFNESS AMTRIX        
C        
C     PARAMETERS        
C        
C        NOGRAV - INPUT  - FLAG WHICH SPECIFIES WHETHER GRAVITY        
C                          EFFECTS ARE TO BE COMPUTED.        
C        NOFREE - OUTPUT - FLAG WHICH SPECIFIES WHETHER A FLUID FREE    
C                          SURFACE EXISTS.        
C        TILT   - OUTPUT - FREE SURFACE TILT VECTOR USED IN PLOTTING    
C        
C     USER PRINT OPTIONS        
C        
C        DIAG 32 - PRINTS HYDROELASTIC SET DEFINITION.        
C        DIAG 33 - PRINTS HYDROELASTIC DEGREE OF FREEDOM DEFINITION.    
C        
C        
      LOGICAL         ERROR        
      INTEGER         GEOM2    ,ECT      ,BGPDT    ,SIL      ,MPT      ,
     1                GEOM3    ,CSTM     ,USET     ,EQEXIN   ,USETF    ,
     2                USETS    ,AF       ,DKGG     ,FBELM    ,FRELM    ,
     3                CONECT   ,AFMAT    ,AFDICT   ,KGMAT    ,KGDICT   ,
     4                Z1       ,Z2(1)    ,SYSBUF        
      CHARACTER       UFM*23   ,UWM*25   ,UIM*29        
      COMMON /XMSSG / UFM      ,UWM      ,UIM        
      COMMON /FLBFIL/ GEOM2    ,ECT      ,BGPDT    ,SIL      ,MPT      ,
     1                GEOM3    ,CSTM     ,USET     ,EQEXIN   ,USETF    ,
     2                USETS    ,AF       ,DKGG     ,FBELM    ,FRELM    ,
     3                CONECT   ,AFMAT    ,AFDICT   ,KGMAT    ,KGDICT    
      COMMON /FLBPTR/ ERROR    ,ICORE    ,LCORE    ,IBGPDT   ,NBGPDT   ,
     1                ISIL     ,NSIL     ,IGRAV    ,NGRAV    ,IGRID    ,
     2                NGRID    ,IBUF1    ,IBUF2    ,IBUF3    ,IBUF4    ,
     3                IBUF5        
      COMMON /SYSTEM/ SYSBUF   ,NOUT        
      COMMON /BLANK / NOGRAV   ,NOFREE   ,TILT(2)        
CZZ   COMMON /ZZFLB1/ Z1(1)        
      COMMON /ZZZZZZ/ Z1(1)        
CZZ   COMMON /ZZFLB2/ Z2        
      EQUIVALENCE     (Z2(1),Z1(1))        
C        
C        
C     INITILIZE OPEN CORE FOR ELEMENT MATRIX GENERATION PHASE        
C        
      ERROR =.FALSE.        
      LCORE = KORSZ(Z1(1))        
      ICORE = 1        
      IBUF1 = LCORE - SYSBUF - 1        
      IBUF2 = IBUF1 - SYSBUF        
      IBUF3 = IBUF2 - SYSBUF        
      IBUF4 = IBUF3 - SYSBUF        
      IBUF5 = IBUF4 - SYSBUF        
C        
C     PROCESS FLUID ELEMENTS ON THE FLUID / STRUCTURE BOUNDARY        
C     AND THE FREE SURFACE .        
C        
      CALL FLBELM        
      IF (ERROR) GO TO 20        
C        
C     BUILD THE HYDROELASTIC USET VECTOR        
C        
      CALL FLBSET        
      IF (ERROR) GO TO 20        
C        
C     GENERATE THE ELEMENT MATRICES        
C        
      CALL FLBEMG        
      IF (ERROR) GO TO 20        
C        
C     INITIALIZE CORE FOR THE MATRIX ASSEMBLY PHASE        
C        
      LCORE = KORSZ(Z2(1))        
      ICORE = 1        
      IBUF1 = LCORE - SYSBUF - 1        
      IBUF2 = IBUF1 - SYSBUF        
C        
C     ASSEMBLE THE AREA FACTOR MATRIX        
C        
      CALL FLBEMA (1)        
C        
C     IF GRAVITY LOADS - ASSEMBLE THE GRAVITY STIFFNESS MATRIX        
C        
      IF (NOGRAV .LT. 0) GO TO 10        
      CALL FLBEMA (2)        
C        
C     MODULE COMPLETION        
C        
   10 CONTINUE        
      RETURN        
C        
C     FATAL ERROR OCCURED DURING PROCESSING - TERMINATE RUN        
C        
   20 WRITE  (NOUT,30) UIM        
   30 FORMAT (A29,' 8000, MODULE FLBMG TERMINATED DUE TO ABOVE ERRORS.')
      CALL MESAGE (-61,0,0)        
      RETURN        
      END        
