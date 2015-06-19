      SUBROUTINE DETM1(*)        
C        
C     RMAX = APPROXIMATE MAGNITUDE OF LARGEST EIGENVALUE OF INTEREST    
C        
C     RMIN = LOWEST  NON-ZERO  EIGENVALUE        
C        
C     MZ = NUMBER OF ZERO EIGENVALUES        
C        
C     NEV = NUMBER OF NON-ZERO EIGENVALUES IN RANGE OF INTEREST        
C        
C     EPSI = CONVERGENCE CRITERION        
C        
C     RMINR = LOWEST EIGENVALUE OF INTEREST        
C        
C     NE   =  NUMBER OF PERMISSIBLE CHANGES OF EPSI        
C        
C     NIT = INTERATIONS TO AN EIGENVALUE        
C        
C     NEVM = MAXIMUM NUMBER OF EIGENVALUES DESIRED        
C        
C     IS  = STARTING SET COUNTER        
C        
C     IC  = COUNTER FOR CHANGE OF CONVERGENCE CRITERIA        
C        
C     NFOUND  = THE NUMBER OF EIGENVALUES FOUND TO DATA        
C     NSTART = NUMBER OF TIMES THROUGH THE STARTING VALUES        
C        
C        
C      IM = MASS MATRIX CONTROL BLOCK        
C        
C      IK = K MATRIX CONTROL BLOCK        
C        
C        A = M +P*K        
C        
C     IEV = EIGENVECTOR CONTROL BLOCK        
C        
      DOUBLE PRECISION P,DETX,PS1,DET1,PSAVE(1),DET(1),PS(1),FACT       
      DOUBLE PRECISION F1, F2, X, Y, RATIO        
C        
      INTEGER PREC,U2,SCR1,SCR2,SCR3,SCR4,SCR5,SCR6,SCR7,NAME(2)        
C        
      DIMENSION IPDET(1)        
C        
      COMMON /DETMX/P(4),DETX(4),PS1(4),DET1(4),N2EV,IPSAV,IPS,IDET,    
     1IPDETA,PREC,NSTART,U2,IC,L1,L2,IS,ND,IADD,SML1,IPDETX(4),IPDET1(4)
     2  ,IFAIL,K,FACT1,IFFND,NFAIL,NPOLE,ISNG        
      COMMON  /REGEAN/ IM(7),IK(7),IEV(7),SCR1,SCR2,SCR3,SCR4,SCR5,LCORE
     1 , RMAX,RMIN,MZ,NEV,EPSI,RMINR,NE,NIT,NEVM,SCR6,SCR7        
     2  ,NFOUND,LAMA        
CZZ   COMMON /ZZDETX/PSAVE        
      COMMON /ZZZZZZ/PSAVE        
C        
      EQUIVALENCE  (PSAVE(1),PS(1),DET(1),IPDET(1))        
C        
      DATA NAME/4HDETM,4H1   /        
C        
C ----------------------------------------------------------------------
C        
      IC = 0        
C        
C     CALCULATE THE NUMBER OF STARTING POINTS TO BE USED        
C        
      N2EV = 2*NEV        
      NN = N2EV        
      SRRMIN = SQRT (RMIN)        
      SRRMAX = SQRT (RMAX)        
      FACT = (SRRMAX - SRRMIN)/N2EV        
      F1 = SRRMIN        
      I = 0        
  120 I = I + 1        
      F2 = F1 + FACT        
      X = DLOG10 (F2/F1)        
      IF (X.LT.1.0D0) GO TO 140        
      IX = X        
      Y = IX        
      IF (X.NE.Y) IX = IX + 1        
      N2EV = N2EV + IX - 1        
      F1 = F2        
  140 IF (I.LT.NN) GO TO 120        
C        
C     CHECK AVAILABILITY OF CORE        
C        
      LC = 2*(KORSZ(PSAVE)/2)        
      IPSAV = LC/2-NEVM        
      IPS = IPSAV -N2EV-1        
      IDET = IPS-N2EV-1        
      IPDETA = 2*IDET -N2EV-2        
      IF(IPDETA .LE. 0) GO TO 80        
      LCORE = LC-IPDETA+1        
C        
C     COMPUTE THE STARTING POINTS        
C        
      NN = IPS + 1        
      PS(NN) = RMIN        
      F1 = SRRMIN        
      I = 0        
  160 F2 = F1 + FACT        
      RATIO = F2/F1        
      X = DLOG10 (RATIO)        
      IF (X.LT.1.0D0) GO TO 200        
      IX = X        
      Y = IX        
      IF (X.NE.Y) IX = IX + 1        
      RATIO = RATIO**(1.0D0/IX)        
      N = 0        
  180 N = N + 1        
      I = I + 1        
      NN = NN + 1        
      PS(NN) = PS(NN-1)*RATIO*RATIO        
      IF (N.LT.IX) GO TO 180        
      GO TO 220        
  200 I = I + 1        
      NN = NN + 1        
      PS(NN) = F2**2        
  220 F1 = F2        
      IF (I.LT.N2EV) GO TO 160        
      IS=1        
      ND=3        
      IADD=0        
      ISNG = 0        
      RMAX = 1.05*RMAX        
      FACT1 = EPSI*SQRT(RMAX)        
C        
C     CALCULATE DETERMINANTE OF FIRST 3 STARTING VALUES        
C        
      ENTRY DETM2        
      IF(NSTART .NE. 0) GO TO 40        
      DO 30 N = 1, ND        
      NN = N+IADD        
      NNP = NN+IPS        
      NND = NN+IDET        
      NNI = NN+IPDETA        
      CALL EADD(-PS(NNP),PREC)        
      CALL DETDET(DET(NND),IPDET(NNI),PS(NNP),SML1,0.0D0,1)        
   30 CONTINUE        
      IF(ND.EQ.3.AND.ISNG.EQ.3)RETURN 1        
      IF(IS .EQ. 1) IADD=2        
      ND = 1        
C        
C     CALCULATE THE INITAL GUESS        
C        
C        
C     PERMUT VALUES TO ORDER BY DETERMINANT        
C        
   40 DO 50 N=1,3        
      NS = N-1+IS        
      NND = NS+IDET        
      NNI = NS+IPDETA        
      NNP = NS+IPS        
      DET1(N) = DET(NND)        
      IPDET1(N) = IPDET(NNI)        
      PS1(N) = PS(NNP)        
   50 CONTINUE        
      RETURN        
   80 CALL MESAGE (-8, 0, NAME)        
      RETURN        
      END        
