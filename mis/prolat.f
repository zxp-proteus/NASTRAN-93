      SUBROUTINE PROLAT        
C        
C     PROLATE COMPUTES COEFFICIENTS FOR A PROLATE SPHEROIDAL HARMONIC   
C     EXPANSION FOR MAGNETOSTATICS PROBLEMS. A PROLATE SPHEROID IA      
C     ASSUMED TO ENCLOSE THE FERROMAGNETIC BODY AND ALL MAGNETIC        
C     SOURCES. A PROLATE BULK DATA CARD DEFINES THE GRIDS ON HTE SURFACE
C     OF TEH PROLATE SPHEROID, THE NUMBER OF TERMS IN THE SERIES        
C     EXPANSION,ETC. CASE CONTROL CARD AXISYM CONTROLS SYMMETRY OR ANTI-
C     SYMMETRY(OR LACK OF) OF THE POTENTIAL W.R.T. THE X-Y PLANE FOR    
C     EACH SUBCASE.        
C        
C     PROLATE  GEOM1,EQEXIN,BGPDT,CASECC,NSLT,HUGV,REMFLD,HEST,MPT,DIT/ 
C              PROCF        
C        
      LOGICAL         REMFL,ONLYAR,ANOM,WRIT        
      INTEGER         BUF1,BUF2,FILE,GEOM1,EQEXIN,BGPDT,CASECC,HUGV,    
     1                PROCOF,SYSBUF,OTPE,TYPOUT,SCR1,PROLTE(2),INFO(7), 
     2                SUBCAS,HEST,PROCOS,TRAIL(7)        
C     INTEGER         DIT,REMFLD,MPT        
      REAL            INTER(4,4),J11,J12,J21,J22        
      DIMENSION       IZ(6),NAM(2),MCB(7),V13(3),V24(3),VX(3),POTI(4),  
     1                POTV(4),XII(4),ETAI(4),XDETJ(4),IPT(4),XX(4),     
     2                YY(4),ZZ(4),PNMV(4),XETA(4),XPHI(4),TRIGC(4),     
     3                TRIGS(4),ETAINT(4),PHIINT(4),XN(4),FO(7),TITLE(96)
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27,SIM*31        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM,SIM        
      COMMON /BIOT  / NG1,NG2,IST,SUBCAS,X1,Y1,Z1,X2,Y2,Z2,BUF2,REMFL,  
     1                MCORE,LOAD,NSLT,SCR1,HEST,NTOT        
      COMMON /SYSTEM/ SYSBUF,OTPE        
      COMMON /UNPAKX/ TYPOUT,II,NN,INCR        
      COMMON /PACKX / ITYPIN,ITYPOU,III,NNN,JNCR        
CZZ   COMMON /ZZPROL/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (Z(1),IZ(1)) , (INFO(1),FO(1))        
      DATA    NAM   / 4HPROL,4HATE /        
      DATA    PROCOS/ 302    /        
      DATA    PROLTE/ 4101,41/        
      DATA    GEOM1,  EQEXIN,BGPDT,CASECC/101,102,103,104/        
      DATA    HUGV,   PROCOF /106,201    /        
C     DATA    REMFLD, MPT,DIT/107,109,110/        
      DATA    PT1,    PT2    /.211324865,.788675135/        
      DATA    INTER(1,1),INTER(2,2),INTER(3,3),INTER(4,4)/4*.622008469/ 
      DATA    INTER(1,2),INTER(1,4),INTER(2,1),INTER(2,3)/4*.16666667 / 
      DATA    INTER(3,2),INTER(3,4),INTER(4,1),INTER(4,3)/4*.16666667 / 
      DATA    INTER(1,3),INTER(2,4),INTER(3,1),INTER(4,2)/4*.044658199/ 
      DATA    PI    / 3.1415927/        
C        
      TPI    = 2.*PI        
      WRIT   = .FALSE.        
      NSLT   = 105        
      HEST   = 108        
      SCR1   = 301        
      LCORE  = KORSZ(Z)        
      LLCORE = LCORE        
      BUF1   = LCORE - SYSBUF        
      LCORE  = BUF1 - 1        
      IF (LCORE .LE. 0) GO TO 1008        
C        
      XII(1) = PT1        
      XII(2) = PT1        
      XII(3) = PT2        
      XII(4) = PT2        
      ETAI(1)= PT2        
      ETAI(2)= PT1        
      ETAI(3)= PT1        
      ETAI(4)= PT2        
C        
C     CHECK TO SEE IF PROLATE CARD EXISTS.IF NOT, WARNING AND OUT       
C        
      FILE = GEOM1        
      CALL PRELOC (*1001,Z(BUF1),GEOM1)        
      CALL LOCATE (*10,Z(BUF1),PROLTE,IDX)        
      GO TO 20        
   10 WRITE  (OTPE,15) SIM        
   15 FORMAT (A31,', NO PROLAT CARD FOUND')        
      CALL CLOSE (GEOM1,1)        
      RETURN        
C        
C     THERE IS ONLY ONE PROLAT CARD IN THE DECK-READ IT IN        
C        
   20 CALL READ (*1002,*30,GEOM1,Z,LCORE,0,NGRIDS)        
      GO TO 1008        
   30 CALL CLOSE (GEOM1,1)        
      SEMAJ  = Z(1)        
      J      = 2        
      SEMIN  = Z(J)        
      NSEGS  = IZ(3)        
      MSEGS  = IZ(4)        
      NNHARM = IZ(5)        
      NMHARM = IZ(6)        
      IGRID  = 6        
C        
C     CREATE A LIST OF COORDINATES FOR THE GRID POINTS. WE WILL NEED    
C     BOTH INTERNAL AND SIL VALUES FOR THE GRIDS.BUT THESE ARE THE SAME 
C     IN HEAT TRANSFER. SO READ IN ONLY THE 1ST RECORD OF EQEXIN        
C        
      MCORE = LCORE-NGRIDS        
      IEQEX = NGRIDS        
      CALL GOPEN (EQEXIN,Z(BUF1),0)        
      FILE = EQEXIN        
      CALL READ (*1002,*40,EQEXIN,Z(IEQEX+1),MCORE,0,NEQEX)        
      GO TO 1008        
   40 CALL CLOSE (EQEXIN,1)        
C        
C     CREATE A LIST OF INTERNAL VALUES OF THE GRIDS ON PROLAT-CHECK CORE
C        
      INEXT = IEQEX + NEQEX        
      IF (INEXT+NGRIDS-6 .GT. LCORE) GO TO 1008        
C        
      IGRID1 = IGRID + 1        
      K = 0        
      DO 50 I = IGRID1,NGRIDS        
      K = K + 1        
      CALL BISLOC (*60,IZ(I),IZ(IEQEX+1),2,NEQEX/2,JLOC)        
C        
C     STORE  THE INTERNAL VALUE        
C        
      IZ(INEXT+K) = IZ(IEQEX+JLOC+1)        
   50 CONTINUE        
      GO TO 70        
   60 WRITE  (OTPE,65) UFM,IZ(I)        
   65 FORMAT (A23,', GRID',I8,' ON PROLAT CARD DOES NOT EXIST')        
      CALL MESAGE (-61,0,0)        
C        
C     MOVE THIS LIST UP IN CORE  / ALL ELSE IN OPEN CORE IS EXPENDABLE  
C        
   70 DO 80 I = 1,K        
   80 IZ(I)  = IZ(INEXT+I)        
      NGRIDS = NGRIDS - 6        
C        
C     CREATE SCRATCH FILE OF HC VALUES FOR EACH REMFLUX CARD(FOR LATER  
C     USE IN HC LINE INTEGRALS)        
C        
      BUF2 = BUF1        
      MCORE= LCORE        
      CALL REMFLX (NGRIDS)        
C        
C     NOW PICK UP COORDINATES OF THESE POINTS-OPEN CORE 1-NGRIDS GIVES  
C     THE POINTERS        
C        
      IBG  = NGRIDS        
      CALL GOPEN (BGPDT,Z(BUF1),0)        
      FILE = BGPDT        
      CALL READ (*1002,*90,BGPDT,Z(IBG+1),LCORE-NGRIDS,0,NBG)        
      GO TO 1008        
   90 CALL CLOSE (BGPDT,1)        
C        
      K = IBG + NBG        
      IF (K+3*NGRIDS .GT. LCORE) GO TO 1008        
      DO 100 I = 1,NGRIDS        
      IPZ  = IZ(I)        
      ISUB = 4*(IPZ-1) + IBG        
      ISUB1= ISUB + 1        
      DO 95 J = 1,3        
   95 Z(K+J) = Z(ISUB1+J)        
      K = K + 3        
  100 CONTINUE        
C        
C     MOVE THESE UP IN CORE SO THAT TOTAL WORDS OF OPEN CORE IS NOW     
C     4*NGRIDS        
C        
      K = IBG + NBG        
      DO 110 I = 1,NGRIDS        
      IJ = NGRIDS + 3*(I-1)        
      DO 105 J = 1,3        
  105 Z(IJ+J) = Z(K+J)        
      K = K + 3        
  110 CONTINUE        
      IBG = NGRIDS        
      IOP = 0        
      IOP1= 1        
C        
C     NOW PICK UP POTENTIAL VALUES AY THESE GRIDS        
C        
      MCB(1) = HUGV        
      CALL RDTRL (MCB)        
      NCOL  = MCB(2)        
      NROW  = MCB(3)        
      TYPOUT= 1        
      II    = 1        
      NN    = NROW        
      INCR  = 1        
      SUBCAS= 0        
  115 INEXT = 4*NGRIDS        
      IPOT  = INEXT        
      IF (INEXT+NROW+NGRIDS .GT. LCORE) GO TO 1008        
      SUBCAS = SUBCAS + 1        
      CALL GOPEN  (HUGV,Z(BUF1),IOP)        
      CALL UNPACK (*131,HUGV,Z(INEXT+1))        
      CALL CLOSE  (HUGV,2)        
C        
C     PICK UP POTENTIALS OF ASSOCIATED POINTS        
C        
      ISUB = INEXT + NROW        
      DO 120 I = 1,NGRIDS        
      IPZ = IZ(I)        
      Z(ISUB+I) = Z(INEXT+IPZ)        
  120 CONTINUE        
C        
C     MOVE THESE  UP        
C        
      DO 130 I = 1,NGRIDS        
  130 Z(IPOT+I) = Z(ISUB+I)        
      GO TO 150        
C        
C     ZERO POTENTIALS        
C        
  131 DO 132 I = 1,NGRIDS        
  132 Z(IPOT+I) = 0.        
      CALL CLOSE (HUGV,2)        
C        
C     OPEN CORE ARRANGEMENT        
C        
C     1 - NGRIDS                            SIL VALUES        
C     NGRIDS + 1 - 4*NGRIDS                 BGPDT VALUES OF THESE POINTS
C     4*NGRIDS + 1 - 5*NGRIDS               ANOMALY POTENTIALS        
C     5*NGRIDS + 1 - 5*NGRIDS + NTOT        LOAD INFO IF NEEDED        
C     5*NGRIDS + NTOT + 1 - 6*NGRIDS + NTOT HC POTENTIALS        
C        
C     PICK UP SYMMETRY INDICATOR FOR THIS CASE. 0 MEANS NO SYMMETRY,    
C     1(SINE) MEANS ANTI-SYMMETRY, 2(COSINE) MEANS SYMMETRY. 0 IMPLIES  
C     360 DEGREE MODELING, 1 AND 2 IMPLY 180 DEGREE MODELING(SKIP SUBCOM
C     REPCASE. IF LOAD=0, THEN BIOT SAVART LOADS ARE ZERO)        
C        
C     INDICATOR=10,20, OR 30 MEANS ANOMALY ONLY, IE DO NOT INCLUDE      
C     EFFECTS OF   APPLIED FIELD(USED MAINLY IN INDUCING FIELDS)        
C     IF THIS IS THE CASE, SET ANOM TO TRUE AND GO  BACK TO 0,1,2       
C        
  150 INEXT = 5*NGRIDS        
      IF (INEXT+136 .GT. LCORE) GO TO 1008        
      CALL GOPEN (CASECC,Z(BUF1),IOP)        
  135 CALL FREAD (CASECC,Z(INEXT+1),136,1)        
      NSYM = IZ(INEXT+16)        
      LOAD = IZ(INEXT+4)        
      ISYM = IZ(INEXT+136)        
      DO 136 I = 1,96        
  136 TITLE(I) = Z(INEXT+38+I)        
      ANOM = .FALSE.        
      IF (ISYM.LE.2) GO TO 140        
      ANOM = .TRUE.        
      IF (ISYM.EQ.30) ISYM = 0        
      ISYM = ISYM/10        
  140 CONTINUE        
      IF (NSYM .NE. 0) GO TO 135        
      CALL CLOSE (CASECC,2)        
C        
C     PROLATE SPHEROID COORDINATE XI IS CONSTANT OVER THE REFERNCE      
C     SPHEROID. DFOC=DISTANCE BETWEEN FOCI        
C        
      INEXT = 5*NGRIDS        
      DFOC = 2.*SQRT(SEMAJ**2-SEMIN**2)        
      XI   = 2.*SEMAJ/DFOC        
      DXI  = 2./DFOC/XI        
C        
C     IF BIOT-SAVART LOAD ARE ZERO OR ANOMALY ONLY, SKIP HC POTENTIALS  
C        
      IF (LOAD .EQ. 0) GO TO 192        
      IF (ANOM) GO TO 192        
C        
C     SET UP LOADS FOR LINE INTEGRAL COMPUTATIONS        
C        
      BUF2  = BUF1        
      MCORE = LCORE        
      IST   = INEXT        
C        
      CALL LOADSU        
C        
      INEXT = INEXT + NTOT        
      IF (INEXT+NGRIDS .GT. LCORE) GO TO 1008        
C        
C     CHECK CORE FOR BIOTSV        
C        
      IF (REMFL .AND. INEXT+4*NGRIDS.GT.LCORE) GO TO 1008        
C        
C     FIRST INTEGRATE THE BIOT-SAVART FIELD ON THE PROLATE SPHEROID TO  
C     COME UP WITH AN EQUIVALENT POTENTIAL AT EACH POINT TO BE ADDED TO 
C     THE ANOMALY POTENTIAL. STORE THESE POTENTIALS IN 5*NGRIDS+NTOT+1  
C     THRU 6*NGRIDS+NTOT        
C        
C        
      DO 160 I = 1,NGRIDS        
  160 Z(INEXT+I) = 0.        
      IHCPOT = INEXT        
      MLONG  = MSEGS + 1        
      IF (ISYM .EQ. 0) MLONG = MSEGS        
      MCIRC = MSEGS        
      IF (ISYM .EQ. 0) MCIRC = MSEGS - 1        
C        
      DO 190 N = 1,NSEGS        
C        
      DO 170 M = 1,MLONG        
C        
C     INTEGRATE HC LONGITUDINALLY. PERFORM LINE INTEGRAL OF HC.DL       
C     RETRIEVE COORDINATES OF POINTS        
C        
      IPT1 = (M-1)*(NSEGS-1) + 2 + (N-1)        
      IPT2 = IPT1 + 1        
      IF (N .EQ.     1) IPT1 = 1        
      IF (N .EQ. NSEGS) IPT2 = 2        
C        
      ISUB = 3*(IPT1-1) + IBG        
      X1   = Z(ISUB+1)        
      Y1   = Z(ISUB+2)        
      Z1   = Z(ISUB+3)        
      ISUB = 3*(IPT2-1) + IBG        
      X2   = Z(ISUB+1)        
      Y2   = Z(ISUB+2)        
      Z2   = Z(ISUB+3)        
      NG1  = IZ(IPT1)        
      NG2  = IZ(IPT2)        
C        
      CALL LINEIN (X1,Y1,Z1,X2,Y2,Z2,HCDL)        
C        
C     NOW ADD POTENTIAL FROM 1ST POINT TO INTEGRAL AT 2ND TO GIVE       
C     INITIAL POTENTIAL AT 2ND POINT. IF 2ND POINT IS RIGHT END POINT   
C     (POINT 2 ON PROLAT), ACCUMULATE FOR AVERAGING        
C        
      ADD = 0.        
      IF (IPT2 .EQ. 2) ADD = Z(IHCPOT+2)        
      Z(IHCPOT+IPT2) = Z(IHCPOT+IPT1) + HCDL + ADD        
C        
C     GET ANOTHER CIRCUMFERENTIAL SEGMENT        
C        
  170 CONTINUE        
C        
C     AVERAGE THE INTEGRALS AT RIGHT END POINT        
C        
      Z(IHCPOT+2) = Z(IHCPOT+2)/FLOAT(MLONG)        
C        
C     LONGITUDINAL INTEGRATIONS FOR THIS LONGITUDINAL SEGMENT ARE       
C     COMPLETE.        
C     NOW INTEGRATE CIRCUMFERENTIALLY DOWN THE RIGHT HAND SIDE OF THE   
C     LONGITUDINAL SEGMENT AND AVERGAE WITH THE LONGITUDINAL RESULTS.   
C     IF WE ARE AT THE LAST SET OF LONGITUDINAL SEGMENTS, DO NOT DO ANY 
C     CIRCUMFERENTIAL INTEGRATIONS SINCE WE HAVE ONLY THE RIGHT END     
C     POINT.        
C        
      IF (N .EQ. NSEGS) GO TO 190        
      DO 180 M = 1,MCIRC        
      IPT1 = (M-1)*(NSEGS-1) + 2 + N        
      IPT2 = IPT1 + (NSEGS-1)        
      ISUB = 3*(IPT1-1) + IBG        
      X1   = Z(ISUB+1)        
      Y1   = Z(ISUB+2)        
      Z1   = Z(ISUB+3)        
      ISUB = 3*(IPT2-1) + IBG        
      X2   = Z(ISUB+1)        
      Y2   = Z(ISUB+2)        
      Z2   = Z(ISUB+3)        
      NG1  = IZ(IPT1)        
      NG2  = IZ(IPT2)        
C        
      CALL LINEIN (X1,Y1,Z1,X2,Y2,Z2,HCDL)        
C        
C     TO GET FINAL HC POTENTIAL AT 2ND POINT, ADD PRESENT POTENTIAL AT  
C     POINT 2(WHICH RESULTED FROM LONGITUDINAL INTEGRATION) TO THE SUM  
C     OF THE POTENTIAL AT POINT 1 AND PRESENT INTEGRAL. THEN AVERAGE    
C        
      Z(IHCPOT+IPT2) = (Z(IHCPOT+IPT2) + Z(IHCPOT+IPT1) + HCDL)/2.      
C        
  180 CONTINUE        
C        
C     GET ANOTHER SET OF LONGITUDINAL SEGMENTS        
C        
  190 CONTINUE        
C        
      CALL CLOSE (NSLT,1)        
C        
C     USING THE POTENTIALS JUST COMPUTED, COMPUTE AN AVERAGE REFERNCE   
C     POTENTIAL TO BE SUBTRACTED FROM THESE POTENTIALS SO THAT THE      
C     AVERAGE POTENTIAL IS ZERO GIVING A ZERO MONOPOLE.        
C     (AVERAGE POTENTIAL=(U/AREA)*(INTEGRAL OF PHI*D(AREA))-INTEGRATE   
C     OVER EACH SURFACE PATCH. ALSO COMPARE COMPUTED AREA TO ANALYTICAL 
C     AREA. IF THIS SUBCASE IS A SINE CASE, THEN AVERGAE IS        
C     AUTOMATICALLY ZERO AND WE CAN SKIP THIS.(THE AREA IN THE        
C     INTEGRATION IS 4*PI-MORSE+FESCHBACH-PAGES 1265 AND 1285--OR THE   
C     A00 TE-M OF THE EXPANSION)        
C     THE REASON FOR THE REFERENCE POTENTIAL IS THAT WE MUST ARBITRARILY
C     SET PHI=0 AT SOME POINT AND THEN THEN INTEGRATE TO GET PHIC.      
C     REFF COMPENSATES FOR THAT        
C        
      REFF = 0.        
  192 ONLYAR = .FALSE.        
      IF (LOAD.EQ.0 .OR. ISYM.EQ.1) ONLYAR = .TRUE.        
      IF (ANOM) ONLYAR = .TRUE.        
C        
      SUMP = 0.        
      SUMA = 0.        
      SUMEP= 0.        
      DO 240 N = 1,NSEGS        
      DO 240 M = 1,MSEGS        
C        
C     GET THE COORDINATES OF THE 4 CORNERS OF THE PATCH(3 CORNERS IF    
C     1ST OR LAST SET OF SEGMENTS)        
C        
      IPT(1) = (M-1)*(NSEGS-1) + 2 + (N-1)        
      IPT(2) = IPT(1) + (NSEGS-1)        
      IPT(3) = IPT(2) + 1        
      IPT(4) = IPT(1) + 1        
      IF (M .NE. MSEGS) GO TO 195        
      IF (ISYM  .NE. 0) GO TO 195        
      IPT(2) = N + 1        
      IPT(3) = IPT(2) + 1        
  195 IF (N .NE. 1) GO TO 200        
      IPT(1) = 1        
      IPT(2) = 1        
      GO TO 210        
  200 IF (N .NE. NSEGS) GO TO 210        
      IPT(3) = 2        
      IPT(4) = 2        
C        
C     COMPITE VECTOR COMPONENTS FOR THE DIAGONALS AND TAKE 1/2 THE CROSS
C     PRODUCT TO GET THE PATCH AREA        
C        
  210 DO 215 I = 1,4        
      ISUB  = 3*(IPT(I)-1) + IBG        
      XX(I) = Z(ISUB+1)        
      YY(I) = Z(ISUB+2)        
      ZZ(I) = Z(ISUB+3)        
      XETA(I) = DXI*XX(I)        
      IF (ZZ(I).EQ.0. .AND. YY(I).EQ.0.) GO TO 215        
      XPHI(I) = ATAN2(ZZ(I),YY(I))        
      IF (XPHI(I) .LT. 0.) XPHI(I) = XPHI(I) + TPI        
  215 CONTINUE        
      IF (ISYM.NE.0 .OR. M.NE.MSEGS) GO TO 216        
      XPHI(2) = TPI        
      XPHI(3) = TPI        
  216 IF (N .NE. 1) GO TO 217        
      XPHI(1) = XPHI(4)        
      XPHI(2) = XPHI(3)        
      GO TO 218        
  217 IF (N .NE. NSEGS) GO TO 218        
      XPHI(4) = XPHI(1)        
      XPHI(3) = XPHI(2)        
  218 CONTINUE        
C        
      V13(1) = XX(3) - XX(1)        
      V13(2) = YY(3) - YY(1)        
      V13(3) = ZZ(3) - ZZ(1)        
      V24(1) = XX(4) - XX(2)        
      V24(2) = YY(4) - YY(2)        
      V24(3) = ZZ(4) - ZZ(2)        
C        
      VX(1) = V13(2)*V24(3) - V13(3)*V24(2)        
      VX(2) = V13(3)*V24(1) - V13(1)*V24(3)        
      VX(3) = V13(1)*V24(2) - V13(2)*V24(1)        
C        
      AREA   = .5*SQRT(VX(1)**2+VX(2)**2+VX(3)**2)        
      AREAEP = .5*((XETA(4)-XETA(2))*(XPHI(1)-XPHI(3))        
     1           -(XETA(1)-XETA(3))*(XPHI(4)-XPHI(2)))        
C        
C     FOLLOWING IS BECAUSE OF BACKWARDS DEFINITION OF XPHI        
C        
      AREAEP = -AREAEP        
      IF (ONLYAR) GO TO 235        
C        
C     PERFORM LINEAR INTERPOLATION OF TEH POTENTIALS FROM THE VERTICES  
C     TO THE INTEGRATION POINTS USING ISOPARAMETRIC SHAPE FUNCTIONS AND 
C     THEN INTEGRATE. 1ST PICK UP VERTEX POTENTIALS        
C        
C        
      IPT1 = IPT(1)        
      IPT2 = IPT(2)        
      IPT3 = IPT(3)        
      IPT4 = IPT(4)        
      POTV(1) = Z(IHCPOT+IPT1)        
      POTV(2) = Z(IHCPOT+IPT2)        
      POTV(3) = Z(IHCPOT+IPT3)        
      POTV(4) = Z(IHCPOT+IPT4)        
C        
      DO 220 I = 1,4        
      POTI(I) = 0.        
      DO 220 J = 1,4        
      POTI(I) = POTI(I)+INTER(I,J)*POTV(J)        
  220 CONTINUE        
C        
      SUM = 0.        
      DO 230 I = 1,4        
C        
C     COMPUTE DETREMINANT OF JACOBIAN        
C        
      J11 = ETAI(I)*(XETA(4)-XETA(1)) + (1.-ETAI(I))*(XETA(3)-XETA(2))  
      J12 = ETAI(I)*(XPHI(4)-XPHI(1)) + (1.-ETAI(I))*(XPHI(3)-XPHI(2))  
      J21 = XII(I)*(XETA(4)-XETA(3)) + (1.- XII(I))*(XETA(1)-XETA(2))   
      J22 = XII(I)*(XPHI(4)-XPHI(3)) + (1.- XII(I))*(XPHI(1)-XPHI(2))   
      J12 =-J12        
      J22 =-J22        
      DETJ= J11*J22 - J12*J21        
  230 SUM = SUM + POTI(I)*DETJ*.25        
C        
C     NOTE---  .25 * SUM OF THE 4 DETJ-S EQUALS AREAEP        
C        
      SUMP = SUMP + SUM        
  235 SUMA = SUMA + AREA        
      SUMEP= SUMEP + AREAEP        
C        
C     GET ANOTHER PATCH        
C        
  240 CONTINUE        
C        
      IF (SUMA .GT. 0.) GO TO 260        
      WRITE  (OTPE,250) UFM        
  250 FORMAT (A23,', AREA OF PROLATE SPHEROID IS ZERO')        
      CALL MESAGE (-61,0,0)        
C        
C     COMPUTE ANALYTICAL AREA        
C        
  260 EPS  = .5*DFOC/SEMAJ        
      AREA = 2.*PI*(SEMIN**2+SEMAJ*SEMIN*ASIN(EPS)/EPS)        
      IF (ISYM .NE. 0) SUMA = 2.*SUMA        
C        
      IF (.NOT.WRIT) WRITE (OTPE,270) UIM,AREA,SUMA        
  270 FORMAT (A29,', THE EXACT SURFACE AREA OF THE PROLATE SPHEROID IS',
     1       1X,1P,E15.3,',  THE COMPUTED AREA IS ',1P,E15.3)        
      WRIT = .TRUE.        
      IF (LOAD .EQ. 0) GO TO 295        
      IF (ANOM) GO TO 295        
      IF (ISYM .EQ. 1) GO TO 280        
C        
C     GET REFERNCE POTENTIAL AND SUBTRACT FROM SUM OF ANOMALY AND HC    
C     POTENTI        
C        
      REFF = SUMP/SUMEP        
  280 DO 290 I = 1,NGRIDS        
  290 Z(IPOT+I) = Z(IPOT+I) + Z(IHCPOT+I) - REFF        
C        
C     FINALLY NOW WE CAN COMPUTE THE COEFFICIENTS A(M,N) AND B(M,N).    
C     MORSE ABD FESCHBACH P. 1285--CHAECK FOR ENOUGH OPEN VORE SPACE TO 
C     STORE THE A-S AND B-S. FOR EACH TYPE, THE NUMBER OF COEFFICIENTS  
C     IS THE SUM OF TH+ INTEGERS FROM 1 TO (\+1), UNLESS M HAS A MAXIMUM
C     LESS THAN N, IN WHICH CASE, THE COUNT IS (M+1)*(N+1-M)+SUM OF     
C     INTEGERS FROM 1 TO M. THE COEFFICIENTS WE NEED ARE        
C        
C              M=0       M=1       M=2       M=4       ETC        
C        N=0   A00        
C        N=1   A01       A11        
C        N=2   A02       A12       A22        
C        N=3   A03       A13       A23       A33        
C         .        
C        ETC        
C        
C     WE NO LONGER NEED THE HC POTENTIALS OR LOAD INFO. SO STORE        
C     COEFFICIENTS STARTING AT 5*NGRIDS+1        
C        
  295 IACOEF = IPOT + NGRIDS        
      NCOEFS = ((NNHARM+1)*(NNHARM+2))/2        
      IF (NMHARM .LT. NNHARM) NCOEFS = (NMHARM+1)*(NNHARM+1-NMHARM)+    
     1                                 (NMHARM*(NMHARM+1))/2        
      IBCOEF = IACOEF + NCOEFS        
      IF (IBCOEF+NCOEFS .GT. LCORE) GO TO 1008        
      N2 = 2*NCOEFS        
      DO 300 I = 1,N2        
  300 Z(IACOEF+I) = 0.        
C        
C     START THE INTEGRATIONS - FOR EACH PATCH IN TURN, DO ALL THE M-S   
C     AND N-        
C        
      DO 460 NS = 1,NSEGS        
      DO 460 MS = 1,MSEGS        
C        
C     INITIAL PART IS SAME AS FOR REFERNEC POTENTIAL        
C        
      IPT(1) = (MS-1)*(NSEGS-1) + 2 + (NS-1)        
      IPT(2) = IPT(1) + (NSEGS-1)        
      IPT(3) = IPT(2) + 1        
      IPT(4) = IPT(1) + 1        
      IF (MS .NE. MSEGS) GO TO 310        
      IF (ISYM  .NE.  0) GO TO 310        
      IPT(2) = NS + 1        
      IPT(3) = IPT(2) + 1        
  310 IF (NS .NE. 1) GO TO 320        
      IPT(1) = 1        
      IPT(2) = 1        
      GO TO 330        
  320 IF (NS .NE. NSEGS) GO TO 330        
      IPT(3) = 2        
      IPT(4) = 2        
  330 DO 335 I = 1,4        
      ISUB  = 3*(IPT(I)-1) + IBG        
      XX(I) = Z(ISUB+1)        
      YY(I) = Z(ISUB+2)        
      ZZ(I) = Z(ISUB+3)        
      XETA(I) = DXI*XX(I)        
      IF (ZZ(I).EQ.0. .AND. YY(I).EQ.0.) GO TO 335        
      XPHI(I) = ATAN2(ZZ(I),YY(I))        
      IF (XPHI(I) .LT. 0.) XPHI(I) = XPHI(I) + TPI        
  335 CONTINUE        
      IF (ISYM.NE.0 .OR. MS.NE.MSEGS) GO TO 337        
      XPHI(2) = TPI        
      XPHI(3) = TPI        
  337 IF (NS .NE. 1) GO TO 338        
      XPHI(1) = XPHI(4)        
      XPHI(2) = XPHI(3)        
      GO TO 339        
  338 IF (NS .NE. NSEGS) GO TO 339        
      XPHI(4) = XPHI(1)        
      XPHI(3) = XPHI(2)        
  339 CONTINUE        
C        
C     GET POTENTAILS AT VERTICES        
C        
      DO 336 I = 1,4        
      ISUB = IPT(I)        
      POTV(I) = Z(IPOT+ISUB)        
  336 CONTINUE        
C        
C     INTERPOLATE TO GET POTENTIALS AT EACH INTEGRATION POINT        
C        
      DO 340 I = 1,4        
      POTI(I) = 0.        
      DO 340 J = 1,4        
      POTI(I) = POTI(I) + INTER(I,J)*POTV(J)        
  340 CONTINUE        
C        
C     SAVE JACOBIAN DETERMINA5TS AT THE INTEGRATION POINTS        
C        
      DO 350 I = 1,4        
      J11 = ETAI(I)*(XETA(4)-XETA(1)) + (1.-ETAI(I))*(XETA(3)-XETA(2))  
      J12 = ETAI(I)*(XPHI(4)-XPHI(1)) + (1.-ETAI(I))*(XPHI(3)-XPHI(2))  
      J21 = XII(I)*(XETA(4)-XETA(3))  + (1.- XII(I))*(XETA(1)-XETA(2))  
      J22 = XII(I)*(XPHI(4)-XPHI(3))  + (1.- XII(I))*(XPHI(1)-XPHI(2))  
C        
C     BECAUSE OF MY INCONSISTENCY IN DIRECTIONS BETWEEN PROLATE SPHEROID
C     COORDINATES IN ANGLE DIRECTION AND ISOPARAMETRIC COORDINATES IN   
C     THAT DIRECTION, WE MUST SWITCH SIGNS FOR XPHI DIFFERENCES- OR ELSE
C     WE WE WILL GET NEGATIVE AREAS        
C        
      J12 = -J12        
      J22 = -J22        
C        
      XDETJ(I) = J11*J22 - J12*J21        
  350 CONTINUE        
C        
C     COMPUTE 4 (ETA,PHI) COORDINATES AT THE INTEGRATION POINTS. USE    
C     SHAPE FUNCTIONS FOR UNIT SQUARE. (ETAINT AND PHIINT ARE PROLATE   
C     SPHEROIDAL COORDINATES AT INTEGRATION POINTS. XETA,XHPI ARE       
C     PROLATE SPHEROIDAL COORDS. AT VERTICES. XII,ETAI ARE ISOPARAMETRIC
C     COORDS AT INTEGRATION POINTS FOR UNIT ISOPARAMEQRIC SPUARE.       
C        
      DO 358 I = 1,4        
      XN(1) = (1.-XII(I))*ETAI(I)        
      XN(2) = (1.-XII(I))*(1.-ETAI(I))        
      XN(3) = XII(I)*(1.-ETAI(I))        
      XN(4) = XII(I)*ETAI(I)        
      ETAINT(I) = 0.        
      PHIINT(I) = 0.        
      DO 357 J  = 1,4        
      ETAINT(I) = ETAINT(I) + XN(J)*XETA(J)        
      PHIINT(I) = PHIINT(I) + XN(J)*XPHI(J)        
  357 CONTINUE        
  358 CONTINUE        
C        
C     START ACTUAL INTEGRATION FOR A GIVEN N,M        
C        
      KOUNT = 0        
      NNP1  = NNHARM + 1        
      DO 450 N = 1,NNP1        
      IAN = N - 1        
      CN  = IAN        
C        
C     SINCE M SUMMATION GOES ONLY TO N, COMPUTE MIN(N,NNHARM)        
C        
      NMP1 = NMHARM + 1        
      IF (NMP1 .GT. N) NMP1 = N        
C        
      DO 450 M = 1,NMP1        
      IAM = M - 1        
      CM  = IAM        
      KOUNT = KOUNT + 1        
C        
C     COMPUTE ASSOCIATED LEGENDRE FUNCTION OF 1ST KIND AT EAC        
C     INTEGRATION POINT        
C        
      DO 360 I = 1,4        
      CALL PNM (IAM,IAN,ETAINT(I),0,PNMV(I))        
  360 CONTINUE        
C        
C     COMPUTE TRIG FUNCTION AT EAC INTEGRATION POINT        
C        
      DO 370 I = 1,4        
      ANG = CM*PHIINT(I)        
      TRIGS(I) = SIN(ANG)        
      TRIGC(I) = COS(ANG)        
  370 CONTINUE        
C        
      SUMA = 0.        
      SUMB = 0.        
      DO 380 I = 1,4        
      IF (ISYM.EQ.0 .OR. ISYM.EQ.1)        
     1    SUMB = SUMB + TRIGS(I)*PNMV(I)*POTI(I)*XDETJ(I)*.25        
      IF (ISYM.EQ.0 .OR. ISYM.EQ.2)        
     1    SUMA = SUMA + TRIGC(I)*PNMV(I)*POTI(I)*XDETJ(I)*.25        
  380 CONTINUE        
C        
C     NOW FORM MULTIPLICATICE CONSTANT BASED ON N,M        
C        
      EM = 1.        
      IF (IAM .GT. 0) EM = 2.        
C        
C     ADJUST EM FOR 1/2 MODEL IF NECESSARY        
C        
      IF (ISYM .GT. 0) EM = 2.*EM        
C        
C     COMPUTE FACTORIALS        
C        
      NMM = IAN - IAM        
      IF (NMM .NE. 0) GO TO 390        
      FNUM = 1.        
      GO TO 410        
  390 FNUM = 1.        
      C = 1.        
      DO 400 I = 1,NMM        
      FNUM = FNUM*C        
      C = C + 1.        
  400 CONTINUE        
  410 NPM = IAN+IAM        
      IF (NPM .NE. 0) GO TO 420        
      FDEN = 1.        
      GO TO 440        
  420 FDEN = 1.        
      C = 1.        
      DO 430 I = 1,NPM        
      FDEN = FDEN*C        
      C = C + 1.        
  430 CONTINUE        
  440 CON = EM*(2.*CN+1.)*FNUM/FDEN/4./PI        
C        
      SUMA = SUMA*CON        
      SUMB = SUMB*CON        
C        
C     STORE THE COEFFICIENTS        
C        
      Z(IACOEF+KOUNT) = SUMA+Z(IACOEF+KOUNT)        
      Z(IBCOEF+KOUNT) = SUMB+Z(IBCOEF+KOUNT)        
C        
C     GET ANOTHER N OR M        
C        
  450 CONTINUE        
C        
C     GET ANOTHER AREA PATCH        
C        
  460 CONTINUE        
C        
C     DONE - THE SCARATCH DATA BLOCK PROCOS WILL HAVE 5 RECORDS FOR EACH
C     SUBCASE. 1ST IS 7 WORD INFO ARRAY, 2ND IS A(M,N) 3RD IS B(M,N)    
C     4TH IS POTENTIALS ON SURFACE FROM ANOMALY+HC POTENTIALS-REFF,     
C     5TH IS POTENTAILS ON SURFACE USING EXPANSION(WHICH WE WILL DO NOW)
C        
      ISUMP = IBCOEF + NCOEFS        
      IF (ISUMP+NGRIDS .GT. LCORE) GO TO 1008        
C        
      DO 480 I = 1,NGRIDS        
C        
C     PICK UP COORDINATES OF POINT        
C        
      ISUB = 3*(I-1) + IBG        
      X1 = Z(ISUB+1)        
      Y1 = Z(ISUB+2)        
      Z1 = Z(ISUB+3)        
C        
C     COMPUTE PROLATE SPHEROIDAL COORDINATES        
C        
      ETA = DXI*X1        
      PHI = 0.        
      IF (Z1.EQ.0. .AND. Y1.EQ.0.) GO TO 465        
      PHI = ATAN2(Z1,Y1)        
C        
C     START SUMMATION        
C        
  465 KOUNT = 0        
      SUM   = 0.        
      DO 470 N = 1,NNP1        
      IAN = N - 1        
      CN  = IAN        
      NMP1= NMHARM + 1        
      IF (NMP1 .GT. N) NMP1 = N        
      DO 470 M = 1,NMP1        
      IAM = M - 1        
      CM  = IAM        
      KOUNT = KOUNT + 1        
C        
C     GET LEGENDRE AND TRIG FUNCTIONS        
C        
      CALL PNM (IAM,IAN,ETA,0,V)        
      ANG   = CM*PHI        
      TRIG1 = COS(ANG)        
      TRIG2 = SIN(ANG)        
      AB    = 0.        
      IF (ISYM.EQ.0 .OR. ISYM.EQ.1) AB = AB+Z(IBCOEF+KOUNT)*TRIG2       
      IF (ISYM.EQ.0 .OR. ISYM.EQ.2) AB = AB+Z(IACOEF+KOUNT)*TRIG1       
C        
      SUM = SUM + AB*V        
  470 CONTINUE        
C        
C     STORE VALUE        
C        
      Z(ISUMP+I) = SUM        
C        
C     GET ANOTHER POINT        
C        
  480 CONTINUE        
C        
C     WRITE RESULTS TO PROCOS        
C        
      FO(1)   = SEMAJ        
      FO(2)   = SEMIN        
      INFO(3) = NNHARM        
      INFO(4) = NMHARM        
      INFO(5) = NCOEFS        
      INFO(6) = ISYM        
      INFO(7) = NGRIDS        
      CALL GOPEN (PROCOS,Z(BUF1),IOP1)        
      CALL WRITE (PROCOS,INFO,7,0)        
      CALL WRITE (PROCOS,TITLE,96,1)        
      CALL WRITE (PROCOS,Z(IACOEF+1),NCOEFS,1)        
      CALL WRITE (PROCOS,Z(IBCOEF+1),NCOEFS,1)        
      CALL WRITE (PROCOS,Z(IPOT  +1),NGRIDS,1)        
      CALL WRITE (PROCOS,Z(ISUMP +1),NGRIDS,1)        
      CALL CLOSE (PROCOS,2)        
C        
C     NOW THAT WE ARE FINISHED ALL THIS WORK, WE SHOULD SEE IF THERE    
C     ARE OTHER SUBCASES WE MUST DO IT FOR        
C        
      IF (SUBCAS .GE. NCOL) GO TO 490        
      IOP  = 2        
      IOP1 = 3        
      GO TO 115        
C        
C     DONE        
C        
  490 TRAIL(1) = PROCOS        
      TRAIL(2) = SUBCAS        
      DO 500 I = 3,7        
  500 TRAIL(I) = 0        
      CALL WRTTRL (TRAIL)        
C        
C     CHECK FOR SUBCOMS AND REPCASES AND WRITE ( TO OUTPUT FILE        
C        
      CALL PROCOM (PROCOS,PROCOF,CASECC,NCOEFS,NGRIDS)        
C        
      RETURN        
C        
 1001 N =-1        
      GO TO 1010        
 1002 N =-2        
      GO TO 1010        
 1008 N =-8        
      FILE = 0        
 1010 CALL MESAGE (N,FILE,NAM)        
      RETURN        
      END        
