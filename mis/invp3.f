      SUBROUTINE INVP3 (NORM1,SUB,MTIMSU,XTRNSY)        
C        
C     SUBROUTINE INVP3, THE MAIN LINK OF INVPWR, SOLVES FOR THE        
C     EIGENVALUES AND EIGENVECTORS OF (K-LAMBDA*M)        
C     THIS ROUTINE HANDLES BOTH SINGLE AND DOUBLE PRECISION VERSIONS    
C        
      EXTERNAL          NORM1     ,SUB      ,MTIMSU   ,XTRNSY        
      INTEGER           FILEK     ,END      ,SYSBUF   ,SR2FIL   ,       
     1                  SR3FIL    ,FILEL    ,FILELT   ,NAME(2)  ,       
     2                  SR7FIL    ,COMFLG   ,TIMEIT   ,TIMED    ,       
     3                  SR8FIL    ,SWITCH   ,T1       ,T2       ,       
     4                  OPTION    ,OPT2     ,FILEM    ,FILEVC   ,       
     5                  FILELM    ,MCBVC(7) ,DMPFIL        
      REAL              LAMMIN    ,LAMMAX        
      DOUBLE PRECISION  DZ(1)     ,ALN      ,ALNM1    ,CN       ,       
     1                  DTEMP     ,LAM1     ,LM1NM1   ,ETA      ,       
     2                  ETANM1    ,LAM2     ,LM2NM1   ,H2N      ,       
     3                  H2NM1     ,DELTA    ,LAMBDA   ,LMBDA    ,       
     4                  LAM1D     ,FREQ        
CZZ   COMMON   /ZZINV3/ Z(1)        
      COMMON   /ZZZZZZ/ Z(1)        
      COMMON   /UNPAKX/ ITU       ,IIU      ,JJU      ,INCRU        
      COMMON   /PACKX / ITP1      ,ITP2     ,IIP      ,JJP      ,       
     1                  INCRP        
      COMMON   /INVPWX/ FILEK(7)  ,FILEM(7) ,SR1FIL(7),SR2FIL(7),       
     1                  FILELM    ,FILEVC   ,SR3FIL   ,SR4FIL   ,       
     2                  SR5FIL    ,SR6FIL   ,SR7FIL   ,SR8FIL   ,       
     3                  DMPFIL    ,LAMMIN   ,LAMMAX   ,NOEST    ,       
     4                  NDPLUS    ,NDMNUS   ,EPS      ,NORTHO        
      COMMON   /SYSTEM/ KSYSTM(65)        
      COMMON   /INFBSX/ FILEL(7)  ,FILELT(7)        
      COMMON   /FBSX  / LFILE(7)        
      COMMON   /NAMES / RD        ,RDREW    ,WRT      ,WRTREW   ,       
     1                  REW       ,NOREW    ,EOFNRW        
      COMMON   /INVPXX/ LAMBDA    ,COMFLG   ,ITERTO   ,TIMED    ,       
     1                  NOPOS     ,RZERO    ,NEG      ,NOCHNG   ,       
     2                  IND       ,LMBDA    ,SWITCH   ,NZERO    ,       
     3                  NONEG     ,IVECT    ,IREG     ,ISTART        
      COMMON   /REIGKR/ OPTION        
      COMMON   /DCOMPX/ DUMX(20)  ,IOFFF        
      COMMON   /TRDXX / IDUMMY(27),IOPEN        
      EQUIVALENCE       (DZ(1)     ,Z(1)  ) ,(KSYSTM( 1),SYSBUF ),      
     1                  (KSYSTM( 2),IOUTPT) ,(KSYSTM( 9),NLPP   ),      
     2                  (KSYSTM(12),NLNS  ) ,(KSYSTM(55),IPREC  )       
      DATA      NAME  / 4HINVP, 4H3       / ,OPT2   / 4HUINV    /       
C        
C     DEFINITION OF LOCAL PARAMETERS        
C        
C     ITER     =  NUMBER OF ITERATIONS FROM THE CURRENT SHIFT POINT     
C     IRAPID   =  1 = RAPID CONVERGENCE DO ONE MORE ITERATION        
C     IEP2     =  1 = EPSILON 2 TEST FAILED        
C     A        =  CONVERGENCE SAFETY FACTOR        
C     EP1      =  EPSILON FOR DETERMINING IF IT IS POSSIBLE TO SHIFT    
C     EP2      =  EPSILON TO DETERMINE IF LAMBDA 2 IS VALID        
C     EP3      =  EPSILON TO DETERMINE IF EIGENVALUE IS TOO CLOSE TO SHI
C     GAMMA    =  CLOSE ROOT CRITERION        
C     II1      =  POINTER TO U(N)        
C     II2      =  POINTER TO U(N-1) OR DELTA U(N)        
C     JJ1      =  POINTER TO F(N)        
C     JJ2      =  POINTER TO DELTA F(N-1)        
C     JJ3      =  POINTER TO F(N-1) OR DELTA F(N)        
C     ALN      =  ALPHA(N)        
C     ALNM1    =  ALPHA(N-1)        
C     CN       =  NORMALIZATION FACTOR FOR LAST EIGENVECTOR        
C        
      IOPEN = -10        
      CALL SSWTCH (16,L16)        
      KHR   = 0        
      NZ    = KORSZ(Z)        
      NCOL  = FILEK(2)        
      NCOL2 = NCOL*IPREC        
      CALL MAKMCB (MCBVC,FILEVC,NCOL,2,IPREC)        
      ITU   = IPREC        
      IIU   = 1        
      JJU   = NCOL        
      INCRU = 1        
      ITP1  = IPREC        
      ITP2  = IPREC        
      IIP   = 1        
      JJP   = NCOL        
      INCRP = 1        
C        
C     INITIALIZE        
C        
      ITER  = 0        
      IRAPID= 0        
      IEP2  = 0        
      KEP2  = 0        
      KOLD  =-1        
      KOUNT = 0        
      GO TO 30        
C        
   10 IF (NORTHO .EQ. 0) GO TO 30        
      CALL KLOCK  (ICURNT)        
      CALL TMTOGO (IIJJKK)        
      NAVG = (ICURNT-ISTART)/NORTHO        
      IF (IIJJKK .GE. 2*NAVG) GO TO 30        
   20 COMFLG = 8        
      GO TO 1140        
C        
   30 IEPCNT = 0        
      IF (SWITCH .EQ. 1) GO TO 40        
      FILEL(1)  = SR2FIL(1)        
      FILELT(1) = SR3FIL        
      GO TO 50        
   40 FILEL(1)  = SR7FIL        
      FILELT(1) = SR8FIL        
C        
   50 DO 60 I = 2,7        
      LFILE(I) = FILEK(I)        
   60 FILEL(I) = FILEK(I)        
      LFILE(1) = FILEL(1)        
      FILELT(7)= IOFFF        
C        
C     SET CONVERGENCE CRITERIA        
C        
      A   = .1        
      EP1 = .003        
      EP2 = .00001        
      EP2 = .02        
      EP3 = .05        
      GAMMA = .01        
      IF (L16.EQ.0 .OR. KHR.NE.0) GO TO 100        
      CALL PAGE1        
      NLNS = NLNS + 10        
      WRITE  (IOUTPT,70)        
   70 FORMAT (85H0D I A G   1 6   O U T P U T   F R O M    R O U T I N E
     1   I N V P 3   F O L L O W S . ,//)        
      WRITE  (IOUTPT,80) RZERO,EPS,GAMMA,A,EP1,EP2,EP3        
   80 FORMAT (8H0RZERO =,1P,E13.5,4X,5HEPS =,1P,E13.5,4X,7HGAMMA =,     
     1        1P,E13.5,4X,3HA =,1P,E13.5, /,8H EP1   =,1P,E13.5,4X,     
     2        5HEP2 =,1P,E13.5,4X,7HEP3   =,1P,E13.5)        
      WRITE  (IOUTPT,90)        
   90 FORMAT (5H0ITER,5H CFLG,11X,3HSTP,11X,3HSHP,10X,4HLAM1,10X,4HLAM2,
     1    11X,3HETA,9X,5HDELTA,4X,1HK,11X,3HH2N,9X,5HLAM1D,/1X,126(1H=))
C        
C     INITIALIZE POINTERS TO VECTORS        
C        
  100 II1   = 1        
      II2   = II1 + NCOL2        
      JJ1   = II2 + NCOL2        
      JJ2   = JJ1 + NCOL2        
      JJ3   = JJ2 + NCOL2        
      JJ4   = JJ3 + NCOL2        
      JJ5   = JJ4 + NCOL2        
      END   = JJ5 + NCOL2        
      IEND  = END        
      END   = IEND + NCOL        
      IBUF1 = NZ   - SYSBUF        
      IBUF2 = IBUF1- SYSBUF        
      IBUF3 = IBUF2- SYSBUF        
      IOBUF = IBUF3- SYSBUF        
      IF (END .GE. IOBUF) GO TO 1300        
C        
C     GET ORTHOGONALITY FLAGS FOR PREVIOUS EIGENVECTORS        
C        
      IF (ITERTO .NE. 0) GO TO 160        
      IF (NORTHO .EQ. 0) GO TO 170        
      CALL GOPEN (FILEVC,Z(IOBUF),RDREW)        
      CALL GOPEN (FILEM ,Z(IBUF1),RDREW)        
      DO 150 I = 1,NORTHO        
      IX = IEND + I - 1        
      Z(IX) = 1.0        
      CALL UNPACK (*110,FILEVC,Z(II1))        
      GO TO 140        
  110 J = NCOL2        
      IF (IPREC .EQ. 2) GO TO 130        
  120 Z(J) = 0.0        
      J = J - 1        
      IF (J .GT. 0) GO TO 120        
      GO TO 140        
  130 DZ(J) = 0.0D0        
      J = J - 1        
      IF (J .GT. 0) GO TO 130        
  140 CALL M TIMS U (Z(II1),Z(JJ1),Z(IBUF1))        
      CALL X TRNS Y (Z(II1),Z(JJ1),DTEMP)        
      IF (DTEMP .LT. 0.0D0) Z(IX) = -1.0        
  150 CONTINUE        
      CALL CLOSE (FILEM ,REW)        
      CALL CLOSE (FILEVC,REW)        
      GO TO 170        
  160 IF (NORTHO .EQ. 0) GO TO 170        
      IFILE = DMPFIL        
      CALL GOPEN (DMPFIL,Z(IOBUF),RDREW)        
      CALL READ  (*1310,*1320,DMPFIL,Z(IEND),NORTHO,1,IDUM)        
      CALL CLOSE (DMPFIL,1)        
  170 IFILE = FILEM(1)        
      CALL GOPEN (IFILE,Z(IBUF3),RDREW)        
      IFILE = FILEL(1)        
      CALL GOPEN (IFILE,Z(IBUF1),RDREW)        
      IFILE = FILELT(1)        
      CALL GOPEN (IFILE,Z(IBUF2),RDREW)        
C        
C     GENERATE A STARTING VECTOR        
C        
      IF (IVECT . EQ. 1) GO TO 240        
      KSAVE = K        
      K = IABS(IND)        
      IF (IPREC .EQ. 2) GO TO 210        
      DO 200 I = 1,NCOL        
      Z(I) = 1.0/FLOAT((MOD(K,13)+1)*(1+5*I/NCOL))        
  200 K = K + 1        
      GO TO 230        
  210 DO 220 I = 1,NCOL        
      DZ(I) = 1.0D0/FLOAT((MOD(K,13)+1)*(1+5*I/NCOL))        
  220 K = K + 1        
  230 K = KSAVE        
      GO TO 310        
C        
C      USE PREVIOUSLY STORED VECTOR AS A STARTING VECTOR        
C        
  240 IFILE = FILEVC        
      CALL GOPEN (FILEVC,Z(IOBUF),RD)        
      CALL BCKREC (FILEVC)        
      IN1 = 1        
      IF (COMFLG-1) 260,250,260        
  250 IN1 = JJ5        
      CALL BCKREC (FILEVC)        
  260 CALL UNPACK (*270,FILEVC,Z(IN1))        
      GO TO 300        
  270 J = IN1 + NCOL2        
      IF (IPREC .EQ. 2) GO TO 290        
  280 J = J - 1        
      Z(J) = 0.0        
      IF (J .GT. IN1) GO TO 280        
      GO TO 300        
  290 J = J - 1        
      DZ(J) = 0.0D0        
      IF (J   .GT.  IN1) GO TO 290        
  300 IF (COMFLG .EQ. 1) GO TO 320        
      CALL BCKREC (FILEVC)        
      CALL CLOSE  (FILEVC,NOREW)        
      IVECT = 0        
  310 CONTINUE        
      INTSUB = 1        
      GO TO 490        
C        
C     PICK UP THE LAST ITERATED VECTOR FOR A STARTING VECTOR        
C        
  320 CONTINUE        
      CALL UNPACK (*330,FILEVC,Z)        
      GO TO 360        
  330 J = NCOL2        
      IF (IPREC .EQ. 2) GO TO 350        
  340 Z(J) = 0.0        
      J = J - 1        
      IF (J .GT. 0) GO TO 340        
      GO TO 360        
  350 DZ(J) = 0.0D0        
      J = J - 1        
      IF (J.GT.0) GO TO 350        
  360 CALL BCKREC (FILEVC)        
      CALL BCKREC (FILEVC)        
      CALL CLOSE  (FILEVC,NOREW)        
      GO TO 310        
C        
C     SHIFT POINTERS TO VECTORS        
C        
  400 II  = II1        
      II1 = II2        
      II2 = II        
      II  = JJ1        
      JJ1 = JJ2        
      JJ2 = JJ3        
      JJ3 = II        
      IF (L16.EQ.0 .OR. KHR.EQ.0) GO TO 420        
      IF (NLNS .GE. NLPP) CALL PAGE1        
      NLNS = NLNS + 1        
      WRITE (IOUTPT,410) ITERTO,COMFLG,        
     1                   LMBDA,LAMBDA,LAM1,LAM2,ETA,DELTA,K,H2N,LAM1D   
  410 FORMAT (2I5,6(1P,D14.5),I5,2(1P,D14.5))        
  420 KHR = 1        
C        
C     SAVE N-1 VECTOR        
C        
      IF (SWITCH .NE. 0) GO TO 460        
      IXX = JJ5 + NCOL2 - 1        
      IXZ = II2        
      IF (IPREC .NE. 2) GO TO 440        
      DO 430 I = JJ5,IXX,2        
      Z(I  ) = Z(IXZ  )        
      Z(I+1) = Z(IXZ+1)        
  430 IXZ = IXZ + 2        
      GO TO 460        
  440 DO 450 I = JJ5,IXX        
      Z(I) = Z(IXZ)        
  450 IXZ  = IXZ + 1        
  460 CONTINUE        
C        
C     SHIFT PARAMETERS        
C        
      ALNM1  = ALN        
      ETANM1 = ETA        
      H2NM1  = H2N        
      LM1NM1 = LAM1        
      LM2NM1 = LAM2        
C        
C     CALL INVFBS TO MAKE ONE ITERATION        
C        
      CALL KLOCK (T1)        
      IF (OPTION .NE. OPT2) GO TO 470        
      IF (FILEL(5) .EQ. 2) CALL INVFBS (Z(JJ3),Z(II1),Z(IOBUF))        
      IF (FILEL(5) .EQ. 1) CALL INTFBS (Z(JJ3),Z(II1),Z(IOBUF))        
      GO TO 480        
  470 CALL FBSINV (Z(JJ3),Z(II1),Z(IOBUF))        
  480 ITERTO = ITERTO + 1        
      ITER   = ITER   + 1        
      IEPCNT = IEPCNT + 1        
      CALL TMTOGO (IJKK)        
      IF (IJKK .LE. 0) GO TO 20        
      INTSUB = 2        
  490 CONTINUE        
      IF (NORTHO .EQ. 0) GO TO 550        
C        
C     NORMALIZE CURRENT ITERANT WITH RESPECT TO VECTORS FOUND IN THE    
C     CURRENT AND PREVIOUS SEARCH REGIONS        
C        
      CALL M TIMS U (Z(II1),Z(JJ1),Z(IOBUF))        
      IFILE = FILEVC        
      CALL GOPEN (FILEVC,Z(IOBUF),RDREW)        
      DO 540 I = 1,NORTHO        
      CALL UNPACK (*500,FILEVC,Z(JJ4))        
      GO TO 530        
  500 J = JJ4 + NCOL2        
      IF (IPREC .EQ. 2) GO TO 520        
  510 J = J - 1        
      Z(J) = 0.0        
      IF (J .GT. JJ4) GO TO 510        
      GO TO 530        
  520 J = J - 1        
      DZ(J) = 0.0D0        
      IF (J .GT. JJ4) GO TO 520        
  530 CALL X TRNS Y (Z(JJ4),Z(JJ1),DTEMP)        
      IX = IEND + I - 1        
      DTEMP = -DTEMP*Z(IX)        
  540 CALL SUB (Z(JJ4),Z(II1),DTEMP,-1.0D0)        
      CALL CLOSE (FILEVC,NOREW)        
  550 CALL NORM1 (Z(II1),CN)        
C        
C     BEGIN TESTING CONVERGENCE CRITERIA        
C        
C     COMPUTE F(N)        
C        
      CALL M TIMS U (Z(II1),Z(JJ1),Z(IOBUF))        
C        
C     COMPUTE ALPHA(N)        
C        
      CALL X TRNS Y (Z(II1),Z(JJ1),ALN)        
      ALN = DSQRT(DABS(ALN))        
C        
C     COMPUTE DELTA U(N)        
C        
      GO TO (400,600), INTSUB        
  600 CALL SUB (Z(II1),Z(II2),1.0D0/ALN,1.0D0/ALNM1)        
C        
C     COMPUTE DELTA F(N)        
C        
      CALL SUB (Z(JJ1),Z(JJ3),1.0D0/ALN,1.0D0/ALNM1)        
      LAM1 = ALNM1/(CN*ALN)        
      IF (IRAPID .EQ. 1) GO TO 900        
      CALL X TRNS Y (Z(II2),Z(JJ3),ETA)        
      ETA = DSQRT(DABS(ETA))        
C        
C     RAPID CONVERGENCE TEST        
C        
      IF (ETA .GE. A*EPS*GAMMA*DABS(1.0D0+LAMBDA/LAM1)) GO TO 620       
  610 IRAPID = 1        
      GO TO 400        
  620 IF (ITER   .EQ.     1) GO TO 400        
      IF (ETANM1 .GE. 1.E-6) GO TO 700        
      IF (ETA - 1.01*ETANM1) 700,700,610        
C        
C     EPSILON 2 TEST        
C        
  700 IF (IEP2  .EQ.  1) GO TO 720        
      IF (ETA .EQ. 0.D0) GO TO 910        
      CALL X TRNS Y (Z(II2),Z(JJ2),DTEMP)        
      LAM2 = LAM1*DTEMP/ETA**2        
      H2N  = (LAM2-LM2NM1)/LAMBDA        
      IF (ITER .LT. 4) GO TO 720        
      IF (EP2.GT.DABS(H2N) .AND. DABS(H2N).GT.DABS(H2NM1)) GO TO 710    
      GO TO 720        
  710 CONTINUE        
      IEP2 = 1        
      LAM2 = LM2NM1        
  720 DELTM1 = DELTA        
      DELTA  = ETA**2/DMIN1((1.0D0-LAM2/LAM1)**2,10.0D0)        
C        
C     VECTOR CONVERGENCE TEST        
C        
      IF (DSQRT(DELTA) .LE. A*EPS) GO TO 910        
      IF (ITER .LE. 3) GO TO 400        
C        
C     EPSILON 1 TEST        
C        
      IF (IEPCNT .GE. 100) GO TO 1270        
      IF (IEPCNT .GE.  10) GO TO 800        
      LAM1D = DABS(LAM1-LM1NM1)/RZERO        
      IF (LAM1D .GE. DBLE(EP1)) GO TO 400        
  800 CONTINUE        
C        
C     SHIFT DECISION        
C        
      IF (IEPCNT.GT.5 .AND. DELTA.GT.DELTM1) GO TO 850        
      IF (DABS(LAM2/LAM1) .GT. 1.) GO TO 820        
      IF (KEP2) 850,810,810        
  810 KEP2 = -1        
      GO TO 400        
  820 KEP2 = 0        
      CALL KLOCK (T2)        
      TIMEIT = T2 - T1        
      K= DLOG(DSQRT(DABS(DELTA))/(A*EPS))/DABS(DLOG(DABS(LAM2/LAM1)))+1.
      K= MIN0(K,9999)        
      IF (K .NE. KOLD) GO TO 830        
      KOUNT = KOUNT + 1        
      IF (KOUNT .GE. 6) GO TO 850        
      GO TO 840        
  830 KOLD  = K        
      KOUNT = 0        
  840 IF (TIMED .GE. (K-3)*TIMEIT) GO TO 400        
  850 LAMBDA= LAMBDA + LAM1        
      K     = 0        
      KOLD  =-1        
      KOUNT = 0        
      IEPCNT= 0        
      IF (L16  .EQ.    0) GO TO 870        
      IF (NLNS .GE. NLPP) CALL PAGE1        
      NLNS = NLNS + 3        
      WRITE  (IOUTPT,860) LAMBDA        
  860 FORMAT (18H0NEW SHIFT POINT =,1P,D14.5,/)        
C        
C     STORE THE LAST VECTOR BEFORE A SHIFT FOR USE AS A STARTING VECTOR 
C        
  870 IF (SWITCH .EQ. 1) GO TO 880        
      IN1 = II1        
      GO TO 890        
  880 IN1 = JJ5        
  890 IFILE = FILEVC        
      CALL GOPEN (FILEVC,Z(IOBUF),WRT)        
      CALL PACK  (Z(IN1),FILEVC,MCBVC)        
      IVECT  = 1        
      COMFLG = 1        
C        
C     STORE THE CURRENT VECTOR ON THE EIGENVECTOR FILE SO IT CAN BE     
C     USED AS A STARTING VECTOR        
C        
      CALL PACK  (Z(II1),FILEVC,MCBVC)        
      CALL CLOSE (FILEVC,EOFNRW)        
      GO TO 1140        
C        
C     MAKE EPSILON 1 TEST        
C        
  900 IF (DABS (LAM1-LM1NM1)/RZERO .GE. DBLE(EP1)) GO TO 400        
C        
C     CONVERGENCE ACHIEVED, NORMALIZE THE EIGENVECTOR        
C        
  910 CALL M TIMS U (Z(II1),Z(JJ1),Z(IOBUF))        
      CALL X TRNS Y (Z(II1),Z(JJ1),DTEMP)        
      IX = IEND + NORTHO        
      Z(IX) = 1.0        
      IF (DTEMP .LT. 0.0D0) Z(IX) = -1.0        
      DTEMP = 1.0D0/DSQRT(DABS(DTEMP))        
      J = II1        
      KLOCAL = II1 + NCOL2 - 1        
      IF (IPREC .NE. 2) GO TO 930        
      J = (J+1)/2        
      KLOCAL = KLOCAL/2        
      DO 920 I = J,KLOCAL        
  920 DZ(I) = DZ(I)*DTEMP        
      GO TO 950        
  930 DO  940 I = J,KLOCAL        
  940 Z(I) = Z(I)*DTEMP        
  950 CONTINUE        
C        
C     STORE THE EIGENVECTOR AND EIGENVALUE ON THE OUTPUT FILES        
C        
      LAM1 = LAM1 + LAMBDA        
      IF (L16  .EQ. 0) GO TO 1010        
      IF (NLNS .GE. NLPP) CALL PAGE1        
      NLNS = NLNS + 3        
      FREQ = (1.0D0/(8.0D0*DATAN(1.0D0)))*DSQRT(DABS(LAM1))        
      WRITE  (IOUTPT,1000) LAM1,FREQ        
 1000 FORMAT (32H0CONVERGENCE ACHIEVED AND LAM1 =,1P,D14.5,        
     1        7X,'FREQ =',1P,D14.5,'HZ',/)        
 1010 IFILE = FILEVC        
      CALL GOPEN (FILEVC,Z(IOBUF),WRT)        
      CALL PACK  (Z(II1),FILEVC,MCBVC)        
      CALL CLOSE (FILEVC,EOFNRW)        
      CALL GOPEN (FILELM,Z(IOBUF),WRT)        
      CALL WRITE (FILELM,LAM1,2,1)        
      CALL CLOSE (FILELM,EOFNRW)        
      CALL CLOSE (SR7FIL,EOFNRW)        
      CALL CLOSE (FILEL,REW)        
      CALL CLOSE (FILELT,REW)        
      CALL CLOSE (FILEM,REW)        
      NORTHO = NORTHO + 1        
      IEP2   = 0        
      IRAPID = 0        
      NOCHNG = 0        
      IF (LAM1) 1020,1030,1030        
 1020 IF (LAM1 .GE. LAMMIN) NONEG = NONEG + 1        
      GO TO 1040        
 1030 IF (LAM1 .LE. LAMMAX) NOPOS = NOPOS + 1        
 1040 IF (NOPOS.GE.NDPLUS .AND. NONEG.GE.NDMNUS) GO TO 1230        
      IF (NORTHO .GE. NCOL-NZERO) GO TO 1220        
      IF (NORTHO .GE.    3*NOEST) GO TO 1210        
      COMFLG = 0        
      IF (SWITCH .EQ. 0) GO TO 1050        
      SWITCH = 0        
      LAMBDA = LMBDA        
      GO TO 1060        
 1050 CONTINUE        
      IVECT = 0        
      IF (ITER .LE. 5) GO TO 1070        
 1060 IN1 = JJ5        
      CALL GOPEN (FILEVC,Z(IOBUF),WRT)        
      CALL PACK  (Z(IN1),FILEVC,MCBVC)        
      CALL CLOSE (FILEVC,EOFNRW)        
      IVECT = 1        
 1070 ITER  = 0        
C        
C     TEST IF REGION IS EXHAUSTED        
C        
      IF (NEG) 1120,1100,1110        
C        
C     NO NEGATIVE REGION        
C        
 1100 IF (LAM1 .GT. LAMMAX) GO TO 1240        
      GO TO 1130        
C        
C     ON POSITIVE SIDE        
C        
 1110 IF (NOPOS.LT.NDPLUS .AND. LAM1.LE.LAMMAX) GO TO 1130        
C        
C     SWITCH TO NEGATIVE SIDE        
C        
      COMFLG = 3        
      GO TO 1140        
C        
C     ON NEGATIVE SIDE        
C        
 1120 IF (NONEG.GE.NDMNUS .OR. LAM1.LT.LAMMIN) GO TO 1240        
C        
C     CONTINUE ON SAME SIDE        
C        
 1130 IF (LAM1.LE.LAMBDA+RZERO .AND. LAM1.GE.LAMBDA-RZERO) GO TO 1250   
      IF (IREG.NE.0 .AND. IND.GT.0) GO TO 1200        
      COMFLG = 0        
      IND = -IND        
 1140 CALL CLOSE (FILEL,REW)        
      CALL CLOSE (FILELT,REW)        
      CALL CLOSE (FILEM,REW)        
      CALL WRTTRL (MCBVC)        
      IF (L16  .EQ.    0) GO TO 1150        
      IF (NLNS .GE. NLPP) CALL PAGE1        
      NLNS = NLNS + 1        
      WRITE (IOUTPT,410) ITERTO,COMFLG,LMBDA,LAMBDA,        
     1                   LAM1,LAM2,ETA,DELTA,K,H2N,LAM1D        
 1150 IF (NORTHO .EQ. 0) RETURN        
C        
      CALL GOPEN (DMPFIL,Z(IOBUF),WRTREW)        
      CALL WRITE (DMPFIL,Z(IEND),NORTHO,1)        
      CALL CLOSE (DMPFIL,1)        
      RETURN        
C        
 1200 IND = -(IND+1)        
      IVECT = 0        
      IF (IND .EQ .-13) IND = -1        
      GO TO 1260        
 1210 COMFLG = 4        
      GO TO 1140        
 1220 COMFLG = 5        
      GO TO 1140        
 1230 COMFLG = 6        
      GO TO 1140        
 1240 COMFLG = 7        
      GO TO 1140        
 1250 IND = IABS(IND)        
      IREG = 1        
      XXX = LAM1 - LAMBDA        
      IF (EPS*ABS(RZERO) .GE. EP3*ABS(XXX)) GO TO 1270        
 1260 IF (NORTHO .EQ. 0) GO TO 10        
      CALL GOPEN (DMPFIL,Z(IOBUF),WRTREW)        
      CALL WRITE (DMPFIL,Z(IEND),NORTHO,1)        
      CALL CLOSE (DMPFIL,1)        
      GO TO 10        
C        
C     CURRENT SHIFT POINT TOO CLOSE TO THE EIGENVALUE        
C        
 1270 IF (COMFLG .NE. 2) GO TO 1280        
      COMFLG = 9        
      GO TO 1140        
 1280 CONTINUE        
      XXX = LAM1 - LAMBDA        
      LAMBDA = LAMBDA + SIGN(.02,XXX)*RZERO        
      COMFLG = 2        
      GO TO 1140        
C        
C     ERROR EXITS        
C        
 1300 NO = -8        
      IFILE = END - IOBUF        
      GO TO 1330        
 1310 NO = -2        
      GO TO 1330        
 1320 NO = -3        
 1330 CALL MESAGE (NO,IFILE,NAME(1))        
      RETURN        
      END        
