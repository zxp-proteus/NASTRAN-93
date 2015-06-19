      SUBROUTINE TA1C        
C        
C     TA1C READS GENERAL ELEMENTS FROM THE ECT AND BUILDS THE GEI.      
C     FOR EACH GENERAL ELEMENT, THE UI AND UD LISTS ARE CONVERTED TO    
C     SIL NOS. AND SORTED ON SIL NO. THE ELEMENTS OF THE Z AND S        
C     MATRICES ARE WRITTEN IN INTERNAL SORT (I.E., ROW AND COL NOS      
C     CORRESPOND TO POSITION IN THE SORTED UI AND UD LISTS.        
C        
C        
      INTEGER         GENL  ,ECT   ,EPT   ,BGPDT ,SIL   ,GPTT  ,CSTM  , 
     1                EST   ,GPECT ,GEI   ,ECPT  ,GPCT  ,SCR1  ,SCR2  , 
     2                SCR3  ,SCR4  ,Z     ,SYSBUF,BUF1  ,BUF2  ,BUF3  , 
     3                FILE  ,FLAG  ,GENEL ,RD    ,RDREW ,WRT   ,WRTREW, 
     4                CLSREW,SILNO ,BUF   ,HALF        
      DIMENSION       NAM(2),BUF(10)      ,GENEL(2)        
      COMMON /BLANK / LUSET ,NOSIMP,NOSUP ,NOGENL,GENL  ,COMPS        
      COMMON /TA1COM/ NSIL  ,ECT   ,EPT   ,BGPDT ,SIL   ,GPTT  ,CSTM  , 
     1                MPT   ,EST   ,GEI   ,GPECT ,ECPT  ,GPCT  ,MPTX  , 
     2                PCOMPS,EPTX  ,SCR1  ,SCR2  ,SCR3  ,SCR4        
      COMMON /TAC1AX/ BUF1  ,BUF2  ,BUF3  ,IUI   ,NUI   ,IUD   ,NUD   , 
     1                IZ    ,NOGO  ,IDGENL        
CZZ   COMMON /ZZTAC1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYSBUF,DUM38(38)    ,NBPW        
      COMMON /SETUP / NFILE(6)        
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW        
      DATA    GENEL / 4301  ,43  / ,NAM /  4HTA1C,4H    /        
      DATA    HALF  / 65536      /        
C        
C     ADD MORE BITS TO HALF IF MACHINE WORD IS LARGER THAN 32        
C        
      IF (NBPW .GE. 36) HALF = 4*HALF        
      IF (NBPW .GT. 36) HALF = 4*HALF        
C        
C     SET BUFFER POINTERS, ETC.        
C        
      BUF1 = KORSZ(Z) - SYSBUF - 2        
      BUF2 = BUF1 - SYSBUF        
      BUF3 = BUF2 - SYSBUF        
      NOGO = 0        
      NOGENL = 0        
C        
C     READ THE SIL INTO CORE        
C        
      FILE = SIL        
      CALL OPEN (*2001,SIL,Z(BUF1),RDREW)        
      CALL FWDREC (*2002,SIL)        
      CALL READ (*2002,*1011,SIL,Z,BUF2,1,NSIL)        
      CALL MESAGE (-8,0,NAM)        
 1011 CALL CLOSE (SIL,CLSREW)        
C        
C     OPEN THE GEI. WRITE HEADER RECORD.        
C        
      FILE = GEI        
      CALL OPEN (*2001,GEI,Z(BUF2),WRTREW)        
      CALL FNAME (GEI,BUF)        
      CALL WRITE (GEI,BUF,2,1)        
C        
C     OPEN THE ECT. READ ELEMENT ID.        
C        
      FILE = ECT        
      CALL PRELOC (*2001,Z(BUF1),ECT)        
      CALL LOCATE (*2006,Z(BUF1),GENEL,FLAG)        
 1031 CALL READ (*2002,*1150,ECT,BUF,1,0,FLAG)        
      IDGENL = BUF(1)        
      NOGENL = NOGENL + 1        
C        
C     READ THE UI LIST. STORE POSITION IN UI LIST, SIL NO.,        
C     INTERNAL GRID NO., AND COMPONENT CODE.        
C        
      IUI = NSIL + 1        
      I = IUI        
      J = 1        
 1041 CALL READ (*2002,*2003,ECT,Z(I+2),2,0,FLAG)        
      IF (Z(I+2) .EQ. -1) GO TO 1042        
      Z(I) = J        
      K = Z(I+2)        
      Z(I+1) = Z(K)        
      IF (Z(I+3) .NE. 0) Z(I+1) = Z(I+1) + Z(I+3) - 1        
      I = I + 4        
      J = J + 1        
      GO TO 1041        
 1042 NUI   = I - 4        
      NBRUI = J - 1        
      NWDUI = 4*NBRUI        
C        
C     READ THE UD LIST (IF PRESENT). STORE POSITION IN UD LIST, SIL NO.,
C     INTERNAL GRID NO., AND COMPONENT CODE.        
C        
      IUD = I        
      J = 1        
 1051 CALL READ (*2002,*2003,ECT,Z(I+2),2,0,FLAG)        
      IF (Z(I+2) .EQ. -1) GO TO 1052        
      Z(I) = J        
      K = Z(I+2)        
      Z(I+1) = Z(K)        
      IF (Z(I+3) .NE. 0) Z(I+1) = Z(I+1) + Z(I+3) - 1        
      I = I + 4        
      J = J + 1        
      GO TO 1051        
 1052 NUD   = I - 4        
      NBRUD = J - 1        
      NWDUD = 4*NBRUD        
      IZ = I        
C        
C     SORT UI AND UD LISTS ON SIL NO.        
C     STORE INTERNAL POSITION IN UI AND UD LISTS.        
C     WRITE ELEMENT ID, NO. OF UI-S, NO. OF UD-S.        
C     WRITE SIL NOS. FOR UI LIST AND SIL NOS. FOR UD LIST.        
C        
      CALL SORTI (0,0,4,2,Z(IUI),NWDUI)        
      BUF(2) = NBRUI        
      BUF(3) = NBRUD        
      CALL WRITE (GEI,BUF,3,0)        
      K = 1        
      DO 1061 I = IUI,NUI,4        
      SILNO  = Z(I+1)        
      Z(I+1) = K        
      CALL WRITE (GEI,SILNO,1,0)        
 1061 K = K + 1        
      IF (NBRUD .EQ. 0) GO TO 1070        
      CALL SORTI (0,0,4,2,Z(IUD),NWDUD)        
      K = 1        
      DO 1062 I = IUD,NUD,4        
      SILNO  = Z(I+1)        
      Z(I+1) = K        
      CALL WRITE (GEI,SILNO,1,0)        
 1062 K = K + 1        
C        
C     SORT UI LIST ON EXTERNAL POSITION.        
C        
 1070 CALL SORTI (0,0,4,1,Z(IUI),NWDUI)        
C        
C     DETERMINE IF CORE WILL HOLD THE FULL Z OR K MATRIX        
C        
      NCORE  = BUF2 - IZ        
      NWDZ   = NBRUI**2        
      NOCORE = 0        
      IF (NWDZ .GT. NCORE) NOCORE = 1        
C        
C     READ INDICATOR OF INPUT OF Z OR K MATRIX        
C        
      CALL READ (*2002,*2003,ECT,IJK,1,0,FLAG)        
      CALL WRITE (GEI,IJK,1,0)        
      KOZ = 0        
      IF (IJK .EQ. 2) KOZ = 1        
C        
C     READ THE ELEMENTS OF THE Z OR K MATRIX.        
C     CONVERT FROM EXTERNAL ROW AND COL NOS. TO INTERNAL ROW AND COL    
C     NOS.  IF CORE WILL HOLD Z OR K, STORE THE ELEMENTS IN CORE        
C     OTHERWISE, WRITE CODED ROW/COL NOS AND ELEMENTS ON SCRATCH FILE.  
C        
      IF (NOCORE .NE. 0) CALL OPEN (*2001,SCR4,Z(BUF3),WRTREW)        
      DO 1094 I = IUI,NUI,4        
      INTROW = Z(I+1)        
      KROW = IZ + (INTROW-1)*NBRUI - 1        
      DO 1094 J = I,NUI,4        
      INTCOL = Z(J+1)        
      KCOL = IZ + (INTCOL-1)*NBRUI - 1        
      CALL READ (*2002,*2003,ECT,BUF(2),1,0,FLAG)        
      IF (NOCORE .NE. 0) GO TO 1092        
      K    = KROW + INTCOL        
      Z(K) = BUF(2)        
      K    = KCOL + INTROW        
      Z(K) = BUF(2)        
      GO TO 1093        
 1092 M = 2        
      BUF(1) = HALF*INTCOL + INTROW        
      IF (INTROW .EQ. INTCOL) GO TO 1095        
      BUF(3) = HALF*INTROW + INTCOL        
      BUF(4) = BUF(2)        
      M = 4        
 1095 CALL WRITE (SCR4,BUF,M,0)        
 1093 CONTINUE        
 1094 CONTINUE        
      IF (NOCORE .NE. 0) CALL CLOSE (SCR4,CLSREW)        
C        
C     IF Z OR K MATRIX IS IN CORE,WRITE IT OUT        
C     OTHERWISE,SORT THE MATRIX AND THEN WRITE IT.        
C        
      IF (NOCORE .EQ. 0) GO TO  1103        
      CALL OPEN (*2001,SCR4,Z(BUF3),RDREW)        
      NFILE(1) = SCR1        
      NFILE(2) = SCR2        
      NFILE(3) = SCR3        
      CALL SORTI (SCR4,0,2,1,Z(IZ),NCORE-SYSBUF)        
      CALL CLOSE (SCR4,CLSREW)        
      CALL OPEN  (*2001,NFILE(6),Z(BUF3),RDREW)        
 1101 CALL READ  (*2002,*1102,NFILE(6),BUF,2,0,FLAG)        
      CALL WRITE (GEI,BUF(2),1,0)        
      GO TO 1101        
 1102 CALL CLOSE (NFILE(6),CLSREW)        
      GO TO 1110        
 1103 CALL WRITE (GEI,Z(IZ),NWDZ,0)        
C        
C     READ FLAG WORD FOR S MATRIX.        
C     IF S MATRIX NOT PRESENT, BUT UD IS PRESENT,        
C     EXECUTE TA1CA TO COMPUTE AND WRITE S MATRIX.        
C     IF S MATRIX AND UD BOTH NOT PRESENT, CLOSE GEI RECORD AND LOOP    
C     BACK        
C        
 1110 CALL READ (*2002,*2003,ECT,BUF,1,0,FLAG)        
      IF (BUF(1) .NE. 0) GO TO 1120        
      IF (NBRUD  .EQ. 0) GO TO 1111        
      CALL SORTI (0,0,4,2,Z(IUI),NWDUI)        
      CALL TA1CA (KOZ)        
 1111 CALL WRITE (GEI,0,0,1)        
      GO TO 1031        
C        
C     S MATRIX IS PRESENT.        
C     DETERMINE IF CORE WILL HOLD THE FULL S MATRIX        
C        
 1120 NWDS = NBRUD*NBRUI        
      CALL SORTI (0,0,4,1,Z(IUD),NWDUD)        
      NOCORE = 0        
      IF (NWDS .GT. NCORE) NOCORE = 1        
C        
C     READ THE ELEMENTS OF THE S MATRIX.        
C     CONVERT FROM EXTERNAL ROW AND COL NOS TO INTERNAL ROW AND COL NOS.
C     IF CORE WILL HOLD S, STORE THE ELEMENTS IN CORE.        
C     OTHERWISE, WRITE CODED ROW/COL NOS AND ELEMENTS ON SCRATCH FILE.  
C        
      IF (NOCORE .NE. 0) CALL OPEN (*2001,SCR4,Z(BUF3),WRTREW)        
      DO 1133 I = IUI,NUI,4        
      INTROW = Z(I+1)        
      KROW   = IZ + (INTROW-1)*NBRUD - 1        
      DO 1132 J = IUD,NUD,4        
      INTCOL = Z(J+1)        
      K = KROW + INTCOL        
      CALL READ (*2002,*2003,ECT,BUF(2),1,0,FLAG)        
      IF (NOCORE .NE. 0) GO TO 1131        
      Z(K) = BUF(2)        
      GO TO 1132        
 1131 BUF(1) = INTCOL + HALF*INTROW        
      CALL WRITE (SCR4,BUF,2,1)        
 1132 CONTINUE        
 1133 CONTINUE        
      IF (NOCORE .NE. 0) CALL CLOSE (SCR4,CLSREW)        
C        
C     IF S MATRIX IS IN CORE, WRITE IT OUT.        
C     OTHERWISE, SORT THE MATRIX AND THEN WRITE IT.        
C        
      IF (NOCORE .EQ. 0) GO TO 1142        
      CALL OPEN (*2001,SCR4,Z(BUF3),RDREW)        
      NFILE(1) = SCR1        
      NFILE(2) = SCR2        
      NFILE(3) = SCR3        
      CALL SORTI (SCR4,0,2,1,Z(IZ),NCORE-SYSBUF)        
      CALL CLOSE (SCR4,CLSREW)        
      CALL OPEN  (*2001,NFILE(6),Z(BUF3),RDREW)        
 1141 CALL READ  (*2002,*1143,NFILE(6),BUF,2,0,FILE)        
      CALL WRITE (GEI,BUF(2),1,0)        
      GO TO 1141        
 1142 CALL WRITE (GEI,Z(IZ),NWDS,0)        
 1143 CALL WRITE (GEI,0,0,1)        
      GO TO 1031        
C        
C     HERE WHEN NO MORE GENERAL ELEMENTS        
C        
 1150 CALL CLOSE (ECT,CLSREW)        
      CALL CLOSE (GEI,CLSREW)        
      BUF(1) = GEI        
      BUF(2) = NOGENL        
      CALL WRTTRL (BUF)        
      IF (NOGO .NE. 0) CALL MESAGE (-61,0,NAM)        
      RETURN        
C        
C     FATAL ERRORS        
C        
 2001 N = -1        
      GO TO 2005        
 2002 N = -2        
      GO TO 2005        
 2003 N = -3        
 2005 CALL MESAGE (N,FILE,NAM)        
 2006 CALL MESAGE (-30,63,BUF)        
      RETURN        
      END        
