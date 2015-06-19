      SUBROUTINE DETM3 (*,*,*)        
C        
C     RMAX   = APPROXIMATE MAGNITUDE OF LARGEST EIGENVALUE OF INTEREST  
C     RMIN   = LOWEST  NON-ZERO  EIGENVALUE        
C     MZ     = NUMBER OF ZERO EIGENVALUES        
C     NEV    = NUMBER OF NON-ZERO EIGENVALUES IN RANGE OF INTEREST      
C     EPSI   = CONVERGENCE CRITERION        
C        
C     NEVM   = MAXIMUM NUMBER OF EIGENVALUES DESIRED        
C     IS     = STARTING SET COUNTER        
C     IC     = COUNTER FOR CHANGE OF CONVERGENCE CRITERIA        
C     NFOUND = THE NUMBER OF EIGENVALUES FOUND TO DATA        
C     IM     = MASS MATRIX CONTROL BLOCK        
C     IK     = K MATRIX CONTROL BLOCK        
C     IEV    = EIGENVECTOR CONTROL BLOCK        
C        
C     A      = M + P*K        
C        
      INTEGER          PREC,U2,SCR1,SCR2,SCR3,SCR4,SCR5,SCR6,SCR7       
      DOUBLE PRECISION P,DETX,PS1,DET1,PSAVE(1),DET(1),PS(1),AA,HK1,HK, 
     1                 LAMDAK,DELTAK,GK,ROOT,ROOT1,LAMDK1,A,XLAMSV,PTRY,
     2                 DETRY,SRP,H1,H2,H3,GK1,HKP1,T1,T2,DIST,DSAVE,    
     3                 TEMP2        
      DIMENSION        IPDET(1)        
      COMMON /DETMX /  P(4),DETX(4),PS1(4),DET1(4),N2EV,IPSAV,IPS,IDET, 
     1                 IPDETA,PREC,NSTART,U2,IC,L1,L2,IS,ND,IADD,SML1,  
     2                 IPDETX(4),IPDET1(4),IFAIL,K,FACT1,IFFND,NFAIL,   
     3                 NPOLE        
      COMMON /REGEAN/  IM(7),IK(7),IEV(7),SCR1,SCR2,SCR3,SCR4,SCR5,     
     1                 LCORE,RMAX,RMIN,MZ,NEV,EPSI,RMINR,NE,NIT,NEVM,   
     2                 SCR6,SCR7,NFOUND,LAMA        
CZZ   COMMON /ZZDETX/  PSAVE        
      COMMON /ZZZZZZ/  PSAVE        
      EQUIVALENCE      (PSAVE(1),PS(1),DET(1),IPDET(1))        
C        
      CALL ARRM (PS1,DET1,IPDET1)        
      AA = PS1(3) - PS1(2)        
      DSAVE = 1.0E38        
C        
C     COPY INTO INTERATION BLOCK        
C        
      DO 30 N = 1,3        
      DETX(N) = DET1(N)        
      P(N) = PS1(N)        
   30 IPDETX(N) = IPDET1(N)        
C        
C     START INTERATION LOOP        
C        
      K     = 1        
      IGOTO = 1        
   40 HK1   = P(2) - P(1)        
      HK    = P(3) - P(2)        
      LAMDAK= HK/HK1        
      IF (DABS(HK) .LE. DABS(EPSI*100.0*P(3))) GO TO 240        
C        
C     CHECK FOR EARLY CONVERGENCE        
C        
      DELTAK = 1.0D0 + LAMDAK        
C        
C     COMPUTE  GK        
C        
C     T1 = DETX*LAMDAK**2 - DETX(2)*DELTAK**2        
      CALL SUMM (T1,IT1,DETX(1)*LAMDAK*LAMDAK,IPDETX,DETX(2)*DELTAK*    
     1           DELTAK,IPDETX(2),-1)        
C     GK = T1 + DETX(3)*(LAMDAK+DELTAK)        
      CALL SUMM (GK,IGK,T1,IT1,DETX(3)*(LAMDAK+DELTAK),IPDETX(3),1)     
C        
C     COMPUTE ROOT1        
C        
C     TI = DETX(1)*LAMDAK - DETX(2)*DELTAK        
      CALL SUMM (T1,IT1,DETX(1)*LAMDAK,IPDETX(1),DETX(2)*DELTAK,        
     1           IPDETX(2),-1)        
C     T2 = T1 + DETX(3)        
      CALL SUMM (T2,IT2,T1,IT1,DETX(3),IPDETX(3),1)        
C     ROOT1 = GK*GK - 4.0DELTAK*LAMDAK*DETX(3)*T2        
      CALL SUMM (ROOT1,IROOT1,GK*GK,2*IGK,-4.0*DELTAK*LAMDAK*DETX(3)*T2,
     1           IPDETX(3)+IT2,1)        
C        
C     COMPUTE ROOT = DSQRT (ROOT1)        
C        
      CALL SQRTM (ROOT,IROOT,ROOT1,IROOT1)        
      A   = -2.0*DETX(3)*DELTAK        
      GK1 = GK        
      DO 90 N = 1,2        
      IF (ROOT1 .LT. 0.0) GO TO 50        
      TEMP2 = ROOT        
      IF (GK1 .NE. 0.0D0) TEMP2 = DSIGN(ROOT,GK1)        
C        
      CALL SUMM (T1,IT1,GK,IGK,TEMP2,IROOT,1)        
C        
C     LAMDK1 = A/(T1)        
      LAMDK1 = A/T1        
      ILMK   = IPDETX(3) - IT1        
      LAMDK1 = LAMDK1*10.0**ILMK        
      GO TO 60        
C        
C     T1= GK*GK + DABS(ROOT1)        
C        
   50 CALL SUMM (T1,IT1,GK*GK,IGK+IGK,DABS(ROOT1),IROOT1,1)        
      LAMDK1 = A*GK/T1        
      ILMK   = IPDETX(3) + IGK - IT1        
      LAMDK1 = LAMDK1*10.0**ILMK        
      GO TO 100        
   60 IF (K .NE. 1) GO TO 100        
C        
C     IF (K .EQ. 1) RECALC LK1 TO MINIMIZE DIST        
C        
      DIST = 0.0D0        
      DO 70 I = 1,3        
      DIST = DABS(PS1(I)-PS1(3)-LAMDK1*AA) + DIST        
   70 CONTINUE        
      IF (DIST .GE. DSAVE) GO TO 80        
      DSAVE  = DIST        
      XLAMSV = LAMDK1        
   80 GK1 = -GK1        
   90 CONTINUE        
      LAMDK1 = XLAMSV        
  100 HKP1 = LAMDK1*HK        
      PTRY = P(3) + HKP1        
C        
C     RANGE CHECKS        
C        
      IF (PTRY .GT. RMAX) GO TO 120        
      IF (IS .EQ. N2EV-1) GO TO 110        
      NNP = IS + IPS        
      IF (PTRY .GT. 0.45*PS(NNP+2)+0.55*PS(NNP+3)) GO TO 120        
  110 IF (PTRY .LT. RMINR) GO TO 111        
      GO TO 140        
C        
C     INCREASE POLE  AT LOWEST  E. V. GEOMETRICALLY        
C        
  111 NPOLE1 = NPOLE + 1        
      NPOLE  = 2*NPOLE + 1        
C        
C     SWEEP PREVIOUSLY EVALUATED STARTING POINTS BY POLES        
C        
      N2EV2 = ND + IADD        
      DO 113 N = 1,N2EV2        
      NND   = N + IDET        
      NNP   = N + IPS        
      NNI   = N + IPDETA        
      PTRY  = 1.0D0        
      IPTRY = 0        
      DO 112 I = 1,NPOLE1        
      PTRY = PTRY*(PS(NNP)-RMINR)        
      CALL DETM6 (PTRY,IPTRY)        
  112 CONTINUE        
      DET(NND)   = DET(NND)/PTRY        
      IPDET(NNI) = IPDET(NNI) - IPTRY        
      CALL DETM6 (DET(NND),IPDET(NNI))        
  113 CONTINUE        
      GO TO 120        
C        
C     NEW STARTING SET        
C        
  120 IFAIL = 0        
  119 IS    = IS + 1        
      IF (IS  .GE. N2EV) GO TO 130        
      IF (NSTART .EQ. 0) IADD = IADD + 1        
      RETURN 1        
C        
C      LOOK AT OLD STARTING SETS AGAIN        
C        
  130 IF (IFFND .NE. 1) RETURN 2        
      IFFND  = 0        
      IS     = 1        
      NSTART = NSTART + 1        
      RETURN 1        
C        
C     TRY FOR CONVERGENCE        
C        
  140 CALL TMTOGO (IPTRY)        
      IF (IPTRY .LE. 0) RETURN 3        
      CALL EADD (-PTRY,PREC)        
      CALL DETDET (DETRY,IPTRY,PTRY,SML1,DETX(3),IPDETX(3))        
      IF (DETRY .NE. 0.0D0) GO TO 145        
      IGOTO = 2        
      GO TO 180        
C        
C     BEGIN CONVERGENCE TESTS        
C        
  145 IF (K .LE. 2) GO TO 170        
      SRP = DSQRT(DABS(P(3)))        
      H1  = DABS(HK1)/SRP        
      H2  = DABS(HK)/SRP        
      H3  = DABS(HKP1)/SRP        
  150 FACT1 = EPSI*SQRT(RMAX)        
      IF (H1 .GT. 2.E7*FACT1) GO TO 200        
      IF (H2 .GT. 2.E4*FACT1) GO TO 200        
      IF (H3 .GT. H2) GO TO 160        
      IF (H3 .GT. 2.*FACT1) GO TO 200        
      IGOTO = 2        
      GO TO 180        
  160 IF (H2 .GT. 20.*FACT1) GO TO 200        
      IGOTO = 2        
      GO TO 180        
C        
C     INTERATE AGAIN        
C        
  170 K = K + 1        
  180 DO 190 I = 1,2        
      P(I) = P(I+1)        
      IPDETX(I) = IPDETX(I+1)        
  190 DETX(I)   = DETX(I+1)        
      IPDETX(3) = IPTRY        
      DETX(3)   = DETRY        
      P(3) = PTRY        
      GO TO (40,240), IGOTO        
C        
C     FAIL TEST        
C        
  200 K = K + 1        
      IF (K-NIT) 180,210,220        
  210 IF (IFAIL.EQ.1 .AND. IC.LT.NE) GO TO 230        
  220 IFAIL = 1        
      NFAIL = NFAIL + 1        
      GO TO 119        
  230 EPSI = 10.0*EPSI        
      IC = IC + 1        
      GO TO 150        
C        
C     ACCEPT PK        
C        
  240 IFFND = 1        
      RETURN        
      END        
