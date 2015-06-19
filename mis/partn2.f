      SUBROUTINE PARTN2 (CP,RP,CORE,BUF)        
C        
C     THIS IS AN INITIALIZATION ROUTINE FOR PARTN1 AND MERGE1.        
C     IT CALLS PARTN3 TO BUILD THE BIT STRINGS FROM THE PARTITIONING    
C     VECTORS -CP- AND -RP- AND SETS DEFAULT OPTIONS FOR -CP- AND  -RP- 
C     BASED ON -SYM-.        
C        
C        
      LOGICAL         CPNULL  ,RPNULL  ,CPHERE  ,RPHERE        
      INTEGER         CP      ,RP      ,CORE    ,BUF(4)  ,SUBR(2) ,     
     1                CPSIZE  ,RPSIZE  ,CPONES  ,RPONES  ,Z       ,     
     2                SYM     ,TYPE    ,FORM    ,SYSBUF  ,OUTPT   ,     
     3                CPCOL   ,RPCOL        
      CHARACTER       UFM*23  ,UWM*25  ,UIM*29  ,SFM*25  ,SWM*27        
      COMMON /XMSSG / UFM     ,UWM     ,UIM     ,SFM     ,SWM        
      COMMON /SYSTEM/ SYSBUF  ,OUTPT        
      COMMON /PRTMRG/ CPSIZE  ,RPSIZE  ,CPONES  ,RPONES  ,CPNULL  ,     
     1                RPNULL  ,CPHERE  ,RPHERE  ,ICP     ,NCP     ,     
     2                IRP     ,NRP        
CZZ   COMMON /ZZPTMG/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /BLANK / SYM     ,TYPE    ,FORM(4) ,CPCOL   ,RPCOL   ,     
     1                IREQCL        
      DATA    SUBR  / 4HPART  ,4HN2    /        
C        
C        
C              I             I             I                I        
C       SYM    I  RP-PURGED  I  CP-PURGED  I NEITHER-PURGED I        
C     ---------+-------------+-------------+----------------+--------   
C              I             I             I                I        
C       .LT.0  I  RP IS SET  I  CP IS SET  I  RP MUST HAVE  I        
C              I  = TO CP    I  = TO RP    I  SAME ONES-S   I        
C              I             I             I  COUNT AS CP   I        
C     ---------+-------------+-------------+----------------+--------   
C              I             I             I                I        
C       .GE.0  I  RP IS SET  I  CP IS SET  I  USE CP AND RP I        
C              I  TO ALL 0   I  TO ALL 0   I                I        
C              I             I             I                I        
C        
C     IN ALL CASES, RESULTANT -CP- AND -RP- DIMENSIONS MUST BE        
C     COMPATIBLE TO THOSE OF  -A-        
C        
C        
C     CONVERT COLUMN PARTITIONING VECTOR TO BIT STRING.        
C        
      ICP = 1        
      IREQCL = CPCOL        
      CALL PARTN3 (CP,CPSIZE,CPONES,ICP,NCP,CPHERE,BUF,CORE)        
      CPCOL = IREQCL        
      IF (CPHERE) GO TO 10        
      IRP = 1        
      GO TO 20        
   10 IRP = NCP + 1        
C        
C     CONVERT ROW PARTITIONING VECTOR TO BIT STRING.        
C        
   20 IREQCL = RPCOL        
      CALL PARTN3 (RP,RPSIZE,RPONES,IRP,NRP,RPHERE,BUF,CORE)        
      RPCOL = IREQCL        
C        
C     BRANCH ON SYMMETRIC OR  NON-SYMMETRIC DMAP VARIABLE SYM        
C        
      CPNULL = .FALSE.        
      RPNULL = .FALSE.        
      IF (SYM) 30,140,140        
C        
C     DMAP USER CLAIMS SYMMETRIC INPUT AND OUTPUT        
C        
   30 IF (CPHERE) GO TO 70        
C        
C     -CP- IS PURGED.  CHECK FOR -RP- PURGED (ERROR), AND IF NOT SET    
C     -CP- BITS EQUAL TO -RP- BITS        
C        
      IF (RPHERE) GO TO 60        
C        
C     BOTH -RP- AND -CP- PURGED AND -A- IS NOT PURGED (ERROR).        
C        
   40 WRITE  (OUTPT,50) SFM        
   50 FORMAT (A25,' 2170, BOTH THE ROW AND COLUMN PARTITIONING VECTORS',
     1       ' ARE PURGED AND ONLY ONE MAY BE.')        
      CALL MESAGE (-61,0,SUBR)        
C        
C     SET CP-ONES = RP-ONES BY SIMPLE EQUIVALENCE OF CORE SPACE        
C        
   60 ICP = IRP        
      NCP = NRP        
      CPONES = RPONES        
      CPSIZE = RPSIZE        
      GO TO 170        
C        
C     -CP- IS NOT PURGED.  IF -RP- IS PURGED IT IS SET EQUAL TO -CP-.   
C        
   70 IF (RPHERE) GO TO 80        
      IRP = ICP        
      NRP = NCP        
      RPONES = CPONES        
      RPSIZE = CPSIZE        
      GO TO 170        
C        
C     BOTH -RP- AND -CP- ARE PRESENT AND SINCE USER HAS SPECIFIED A     
C     SYMMETRIC OUTPUT PARTITION IS DESIRED THE NUMBER OF        
C     NON-ZEROS IN-CP- MUST EQUAL THE NUMBER OF NON-ZEROS IN -RP- FOR NO
C     ERROR HERE.        
C        
   80 IF (CPONES.EQ.RPONES .AND. CPSIZE.EQ.RPSIZE) GO TO 100        
      WRITE  (OUTPT,90) SWM,CP,RP        
   90 FORMAT (A27,' 2171, SYM FLAG INDICATES TO THE PARTITION OR MERGE',
     1       ' MODULE THAT A SYMMETRIC MATRIX IS TO BE', /5X,        
     2       ' OUTPUT.  THE PARTITIONING VECTORS',2I4,' HOWEVER DO NOT',
     3       ' CONTAIN AN IDENTICAL NUMBER OF ZEROS AND NON-ZEROS.')    
C        
C     CHECK FOR ORDER OF ONES IN ROW AND COLUMN PARTITIONING VECTOR.    
C        
  100 IF (CPSIZE .NE. RPSIZE) GO TO 170        
      J = IRP        
      DO 110 I = ICP,NCP        
      IF (Z(I) .NE. Z(J)) GO TO 120        
      J = J + 1        
  110 CONTINUE        
      GO TO 170        
C        
C     ROW AND COLUMN PARTITIONING VECTORS DO NOT HAVE SAME ORDER.       
C        
  120 WRITE  (OUTPT,130) SWM        
  130 FORMAT (A27,' 2172, ROW AND COLUMN PARTITIONING VECTORS DO NOT ', 
     1       'HAVE IDENTICAL ORDERING OF ZERO', /5X,' AND NON-ZERO ',   
     2       'ELEMENTS, AND SYM FLAG INDICATES THAT A SYMMETRIC ',      
     3       'PARTITION OR MERGE IS TO BE PERFORMED.')        
      GO TO 170        
C        
C     DMAP USER DOES NOT REQUIRE SYMMETRY        
C        
  140 IF (CPHERE) GO TO 160        
C        
C     -CP- IS PURGED.  THUS -RP- MUST BE PRESENT FOR NO ERROR.        
C        
      IF (RPHERE) GO TO 150        
      GO TO 40        
C        
C     SET CP-ONES EQUAL TO 0 AND CPSIZE = 0        
C        
  150 CPNULL = .TRUE.        
      CPSIZE = 0        
      CPONES = 0        
      GO TO 170        
C        
C     -CP- NOT PURGED.  IF -RP- IS PURGED SET IT NULL.        
C        
  160 IF (RPHERE) GO TO 170        
      RPNULL = .TRUE.        
      NRP    = IRP - 1        
      RPSIZE = 0        
      RPONES = 0        
  170 RETURN        
      END        
