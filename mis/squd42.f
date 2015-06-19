      SUBROUTINE SQUD42        
C        
C     PHASE 2 STRESS RECOVERY FOR 4-NODE ISOPARAMETRIC QUADRILATERAL    
C     SHELL ELEMENT (QUAD4)        
C        
C     NOTE - FOR LAMINATED COMPOSITE ELEMENTS THE FOLLOWING ARE        
C            NOT SUPPORTED        
C        
C         1. VARIABLE GRID POINT THICKNESS        
C         3. TEMPERATURE AT 'FIBRE' DISTANCE        
C        
C         ALSO STRESSES ARE ONLY EVALUATED AT THE ELEMENT CENTRE        
C         AND SIMILARILY FOR STRESS RESULTANTS        
C        
C        
C     ALGORITHM -        
C        
C     1- STRAIN RECOVERY DATA IS SENT BY PHASE 1 THRU 'PHIOUT',        
C        WHICH INCLUDES ALL THE NECESSARY TRANSFORMATIONS AND        
C        STRAIN RECOVERY MATRICES. THE DATA IS REPEATED FOR EACH        
C        STRESS EVALUATION POINT.        
C     2- GLOBAL DISPLACEMENT VECTOR ENTERS THE ROUTINE IN CORE.        
C     3- BASED ON THE DATA IN /SDR2X4/, LOCATION OF THE GLOBAL        
C        DISPLACEMENT VECTOR FOR THE CURRENT SUBCASE IS DETERMINED.     
C     4- WORD 132 OF /SDR2DE/ CONTAINS THE STRESS OUTPUT REQUEST        
C        OPTION FOR THE CURRENT SUBCASE.        
C     5- ELEMENT/GRID POINT TEMPERATURE DATA ENTERS THE ROUTINE        
C        THRU /SDR2DE/ (POSITIONS 97-103, 104-129 NOT USED.)        
C     6- ELEMENT STRAINS ARE CALCULATED, CORRECTED FOR THERMAL        
C        STRAINS, AND PREMULTIPLIED BY G-MATRIX.        
C        
      EXTERNAL        ANDF        
      LOGICAL         EXTRM,LAYER,COMPOS,GRIDS,INTGS,MAXSH,VONMS,BENDNG,
     1                TRNFLX,TEMPP1,TEMPP2,SNRVRX,SNRVRY,FOUR,PCMP,     
     2                PCMP1,PCMP2,DEBUG        
      INTEGER         INTZ(1),IGRID(5),NPHI(2395),NSTRES(86),ELID,      
     1                KSIL(8),IORDER(8),CENTER,NFORS(46),EXTRNL,        
     2                INDXG2(3,3),INDX(6,3),OPRQST,FLAG,IPN(5),COMPS,   
     3                OES1L,OEF1L,PCOMP,PCOMP1,PCOMP2,PIDLOC,SYM,SYMMEM,
     4                SOUTI,FTHR,STRAIN,ELEMID,PLYID,ANDF,SDEST,FDEST   
C    5,               GPSTRS,INDEXU(3,3),INDEXV(2,3)        
      REAL            MOMINR,KHIT,MINTR,TDELTA(6),DELTA(48),TSTB(5,5),  
     1                TSTT(5,5),TSTN(50),DELTAT(8),U(36),G(36),G2(9),   
     2                ALFAM(3),ALFAB(3),Z1(5),Z2(5),GPTH(4),STRES(86),  
     3                G3(4),TMI(9),TRANS(9),STRNT(3),STRNB(3),STRNTC(3),
     4                STRNBC(3),EPST(3),EPSB(3),EPSE(3),EPSTOT(3),FB(2),
     5                EPSLNE(3),STRESL(3),STRESE(3),EZEROT(6),ALPHA(3), 
     6                V(2),EI(2),ZBAR(2),TRNAR(2),TRNSHR(2),ULTSTN(6),  
     7                ABBD(6,6),STIFF(36),MTHER(6),DUMC(6),STEMP(8)     
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
CZZ   COMMON /ZZSDR2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ KSYSTM(60)        
      COMMON /SDR2C1/ IPCMP,NPCMP,IPCMP1,NPCMP1,IPCMP2,NPCMP2,        
     1                NSTROP        
      COMMON /SDR2X2/ DUMM(30),OES1L,OEF1L        
      COMMON /SDR2X4/ DUMMY(35),IVEC,IVECN,LDTEMP        
      COMMON /SDR2X7/ PHIOUT(2395)        
      COMMON /SDR2X8/ SIGMA(3),ICOUNT,NSTOT,THIKNS(5),ISTRES,KPOINT,    
     1                EXTRNL(8),TSTR(50),XPOINT(2),SHPFNC(4),EPSLN(8),  
     2                KHIT(3),G2ALFB(30),TST(20),TES(9),TESU(9),TESV(4),
     3                REALI(5),GT(36),EPSLNT(6),TSIGMA(8),SIGNX(4),     
     4                SIGNY(4),VXCNTR,VYCNTR,FXCNTR,FYCNTR,FXYCNT,      
     5                STRX(2),STRY(2),STRS(2),FORSUL(46)        
      COMMON /SDR2DE/ KSDRDE(141)        
      COMMON /BLANK / APP(2),SORT2,IDUM(2),COMPS        
      COMMON /CONDAS/ PI,TWOPI,RADDEG,DEGRAD        
      EQUIVALENCE     (Z(1)   ,INTZ(1)   ), (NFORS(1) ,FORSUL(1) ),     
     1                (NPHI(1),PHIOUT(1) ), (NSTRES(1),STRES(1)  ),     
     2                (ELID   ,NPHI(1)   ), (KSIL(1)  ,NPHI(2)   ),     
     3                (TSUB0  ,PHIOUT(18)), (IORDER(1),NPHI(10)  ),     
     4                (AVGTHK ,PHIOUT(21)), (MOMINR   ,PHIOUT(22)),     
     5                (G(1)   ,PHIOUT(23)), (ALFAM(1) ,PHIOUT(59)),     
     6                (GPTH(1),PHIOUT(65)), (ALFAB(1) ,PHIOUT(62)),     
     7                (IPID   ,NPHI(79)  ), (KSTRS    ,KSDRDE(42)),     
     8                (KFORCE ,KSDRDE(41)), (STEMP(1) ,KSDRDE(97)),     
     9                (SDEST  ,KSDRDE(26)), (FDEST    ,KSDRDE(33)),     
     O                (NOUT   ,KSYSTM(2) ), (STEMP(7) ,FLAG      )      
C    1,               (INDEXU(1,1),INDEXV(1,1))        
      DATA    DEBUG / .FALSE.  /        
      DATA    CENTER/ 4HCNTR   /        
      DATA    CONST / 0.57735026918962/        
      DATA    EPSS  / 1.0E-11  /        
      DATA    EPSA  / 1.0E-7   /        
      DATA    IPN   / 1,4,2,3,5/        
      DATA    PCOMP / 0 /        
      DATA    PCOMP1/ 1 /        
      DATA    PCOMP2/ 2 /        
      DATA    SYM   / 1 /        
      DATA    MEM   / 2 /        
      DATA    SYMMEM/ 3 /        
      DATA    STRAIN/ 5 /        
C        
C     DEFINE PHIOUT(2395), THE TRANSMITTED DATA BLOCK        
C        
C     ADDRESS     DESCRIPTIONS        
C        
C        1        ELID        
C      2 - 9      SIL NUMBERS        
C     10 - 17     IORDER        
C       18        TREF        
C     19 - 20     FIBRE DISTANCES Z1, Z2 AS SPECIFIED ON PSHELL CARD    
C       21        AVGTHK- AVERAGE THICKNESS OF THE ELEMENT        
C       22        MOMINR- MOMENT OF INERTIA FACTOR        
C     23 - 58     GBAR-MATRIX, 6X6 MATRIX OF MATERIAL PROPERTY (W/O G3) 
C     59 - 61     THERMAL EXPANSION COEFFICIENTS FOR MEMBRANE        
C     62 - 64     THERMAL EXPANSION COEFFICIENTS FOR BENDING        
C     65 - 68     CORNER NODE THICKNESSES        
C     69 - 77     TUM-MATRIX, 3X3 TRANSFORMATION FROM MATERIAL TO USER  
C                 DEFINED COORDINATE SYSTEM        
C       78        OFFSET OF ELEMENT FROM GP PLANE        
C       79        ORIGINAL PROPERTY ID FOR COMPOSITES        
C     80 - 79+9*NNODE        
C                 TEG-MATRIX, A 3X3 MATRIX FOR THE TRANSFORMATION       
C                 MATRIX FROM GLOBAL COORD TO ELMT COORD FOR        
C                 EACH NODE.        
C                 TEG-MATRIX, 3X3 DATA ARE REPEATED FOR NNODES        
C     --------        
C     START FROM PHIOUT(79+9*NNODE+1) AS A REFERENCE ADDRESS        
C                       79+9*4    +1= 116        
C        
C     ADDRESS     DESCRIPTIONS        
C        
C        1        T, MEMBRANE THICKNESS AT THIS EVALUATION POINT        
C      2 - 10     TES-MATRIX, A 3X3 TRANSFORMATION MATRIX FROM ELEM.    
C                        C.S. TO USER DEFINED STRESS C.S. AT THIS       
C                        EVALUATION POINT        
C     11 - 19     CORRECTION TO GBAR-MATRIX FOR MEMBRANE-BENDING        
C                        COUPLING AT THIS EVALUATION POINT        
C     20 - 28     TMI-MATRIX, 3X3 TRANSFORMATION FROM TANGENT TO MATERIA
C     29 - 32     G3-MATRIX        
C     33 - 32+NNODE        
C                 ELEMENT SHAPE FUNCTION VALUES AT THIS EVAL. POINT     
C     32+NNODE+1 -        
C     32+NNODE+8*NDOF        
C                 B-MATRIX, 8 X NDOF        
C        
C     --------    ABOVE DATA BATCH REPEATED 10 TIMES        
C        
C     TOTAL PHIOUT WORDS = (116-1) + (32+4+8*(6*4))*10        
C                        =    115  + (32+4+192)*10 = 115 + 2280 = 2395  
C        
C        
C     DEFINE STRES (TOTAL OF 86 WORDS), THE STRESS OUTPUT DATA BLOCK    
C        
C     ADDRESS     DESCRIPTIONS        
C        
C        1        ELID        
C     -------------------------------------------------------        
C        2        INTEGRATION POINT NUMBER        
C     3  - 10     STRESSES FOR LOWER POINTS        
C     11 - 18     STRESSES FOR UPPER POINTS        
C     ---------   ABOVE DATA REPEATED 4 TIMES        
C     70 - 86     STRESSES FOR CENTER POINT        
C        
C     DEFINE FORSUL (TOTAL OF 46 WORDS), THE FORCE RESULTANT OUTPUT     
C     DATA BLOCK.        
C        
C     ADDRESS    DESCRIPTIONS        
C        
C        1       ELID        
C     ------------------------------------------------        
C        2       GRID POINT NUMBER        
C      3 - 10    FORCES        
C     --------   ABOVE DATA REPEATED 4 TIMES        
C     38 - 46    FORCES FOR CENTER POINT        
C        
C     NSTOT  = NUMBER OF DATA OUTPUT THRU 'STRES'        
C     NFORCE = NUMBER OF DATA OUTPUT THRU 'FORSUL'        
C     NNODE  = TOTAL NUMBER OF NODES        
C     NDOF   = TOTAL NUMBER OF DEGREES OF FREEDOM        
C     LDTEMP = SWITCH TO DETERMINE IF THERMAL EFFECTS ARE PRESENT       
C     ICOUNT = POINTER FOR PHIOUT DATA        
C        
C     STAGE 1 -  INITIALIZATION        
C     =========================        
C        
      NSTOT = 1 + 5 + 5*2*8        
      NFORCE= 1 + 5*9        
      NNODE = 0        
      DO 10 ICHK = 1,8        
      IF (KSIL(ICHK) .GT. 0) NNODE = NNODE + 1        
   10 EXTRNL(ICHK) = 0        
      NDOF = 6*NNODE        
      FOUR = NNODE .EQ. 4        
C        
C     COMMENTS FROM G.C. 2/1990        
C     EXTRNL ARE SET TO ZEROS ABOVE AND NEVER SET TO ANY VALUE LATER.   
C     IT IS THEN USED TO SET IGRID. WHAT'S EXTRNL FOR?        
C     THE ANSWER IS THAT EXTRNL AND IGRID ARE USED ONLY WHEN GRIDS FLAG 
C     IS TRUE. GRIDS IS FALSE IN COSMIC VERSION.        
C        
C     ALSO, A MISSING ROUTINE, FNDGID, SUPPOSELY RETURNS EXTERNAL GRID  
C     NUMBER FROM SIL INDEX. FNDGID IS LOCATED A FEW LINES BELOW 80     
C        
C     CHECK THE OUTPUT AND STRESS REQUEST        
C        
      GRIDS = .FALSE.        
      INTGS = .TRUE.        
      MAXSH = ANDF(NSTROP,1) .EQ. 0        
      VONMS = ANDF(NSTROP,1) .NE. 0        
      EXTRM = ANDF(NSTROP,2) .EQ. 0        
      LAYER = ANDF(NSTROP,2) .NE. 0        
      BENDNG= MOMINR .GT. 0.0        
C        
C     NOTE - MAXSH AND EXTRM ARE NO LONGER USED        
C        
C     IF LAYERED STRESS/STARIN OUTPUT IS REQUESTED, AND THERE ARE NO    
C     LAYERED COMPOSITE DATA, SET LAYER FLAG TO FALSE        
C        
      IF (LAYER .AND. NPCMP+NPCMP1+NPCMP2.LE.0) LAYER = .FALSE.        
C        
C     IF LAYERED OUTPUT IS REQUESTED BUT THE CURRENT ELEMENT IS NOT A   
C     LAYERED COMPOSITE, SET LAYER FLAG TO FALSE        
C        
      IF (LAYER .AND. IPID.LT.0) LAYER = .FALSE.        
C        
      OPRQST = -2        
      IF (KSTRS  .EQ. 1) OPRQST = OPRQST + 1        
      IF (KFORCE .EQ. 1) OPRQST = OPRQST + 2        
      IF (OPRQST .EQ.-2) RETURN        
C        
C     CHECK FOR FIBRE DISTANCES Z1 AND Z2 BEING BLANK        
C        
      LOGZ12 = -4        
      IF (NPHI(19) .EQ. 0) LOGZ12 = LOGZ12 + 2        
      IF (NPHI(20) .EQ. 0) LOGZ12 = LOGZ12 + 4        
C        
C     CHECK FOR THE TYPE OF TEMPERATURE DATA        
C     NOTES  1- TYPE TEMPP1 ALSO INCLUDES TYPE TEMPP3        
C            2- IF NIETHER TYPE IS TRUE, GRID POINT TEMPERATURES        
C               ARE PRESENT.        
C        
      TEMPP1 = FLAG .EQ. 13        
      TEMPP2 = FLAG .EQ.  2        
C        
C     CHECK FOR OFFSET AND COMPOSITES        
C        
      OFFSET = PHIOUT(78)        
      COMPOS = COMPS.EQ.-1 .AND. IPID.GT.0        
C        
C     ZERO OUT STRESS AND FORCE RESULTANT ARRAYS        
C        
      DO 20 K = 1,NSTOT        
   20 STRES(K) = 0.0        
      DO 30 I = 1,NFORCE        
   30 FORSUL(I)= 0.0        
      NSTRES(1)= ELID        
      NFORS(1) = ELID        
C        
C     ZERO OUT THE COPY OF GBAR-MATRIX TO BE USED BY THIS ROUTINE       
C        
      DO 40 K = 1,36        
   40 GT(K) = 0.0        
C        
C     STAGE 2 - ARRANGEMENT OF INCOMING DATA        
C     ======================================        
C        
C     SORT THE GRID TEMPERATURE CHANGES INTO SIL ORDER (IF PRESENT)     
C        
      IF (LDTEMP .EQ.     -1) GO TO 60        
      IF (TEMPP1 .OR. TEMPP2) GO TO 60        
C        
C     DO 50 K = 1,NNODE        
C     KPOINT = IORDER(K)        
C  50 DELTAT(K) = STEMP(KPOINT)        
C        
C     COMMENTS FORM G.CHAN/UNISYS  2/93        
C     THE ABOVE DO 50 LOOP DOES NOT WORK SINCE STEMP(2 THRU NNODE) = 0.0
C        
      DO 50 K = 1,NNODE        
   50 DELTAT(K) = STEMP(1)        
C        
C     PICK UP THE GLOBAL DISPLACEMENT VECTOR AND TRANSFORM IT        
C     INTO THE ELEMENT C.S.        
C        
   60 DO 80 IDELT = 1,NNODE        
      JDELT = IVEC + KSIL(IDELT) - 2        
      KDELT = 6*(IDELT-1)        
      DO 70 LDELT = 1,6        
      TDELTA(LDELT) = Z(JDELT+LDELT)        
   70 CONTINUE        
C        
C     FETCH TEG-MATRIX 3X3 FOR EACH NODE AND LOAD IT IN A 6X6 MATRIX    
C     INCLUDE THE EFFECTS OF OFFSET        
C        
      CALL TLDRS  (OFFSET,IDELT,PHIOUT(80),U)        
      CALL GMMATS (U,6,6,0, TDELTA,6,1,0, DELTA(KDELT+1))        
   80 CONTINUE        
C        
C     GET THE EXTERNAL GRID POINT ID NUMBERS FOR CORRESPONDING SIL      
C     NUMBERS.        
C        
C     CALL FNDGID (ELID,8,KSIL,EXTRNL)        
C        
C     STAGE 3 - CALCULATION OF STRAINS        
C     ================================        
C        
C     INTEGRATION DATA IN PHIOUT IS ARRANGED IN ETA, XI INCREASING      
C     SEQUENCE.        
C        
      ISIG  = 1        
      ICOUNT= -(8*NDOF+NNODE+32) + 79 + 9*NNODE        
C        
      DO 350 INPLAN = 1,5        
      INPLN1 = IPN(INPLAN)        
C        
C     MATCH GRID ID NUMBER WHICH IS IN SIL ORDER        
C        
      IF (INPLAN .EQ. 5) GO TO 100        
      DO 90 I = 1,NNODE        
      IF (IORDER(I) .NE. INPLN1) GO TO 90        
      IGRID(INPLAN) = EXTRNL(I)        
      GO TO 110        
   90 CONTINUE        
      GO TO 110        
C        
  100 IGRID(INPLAN) = CENTER        
  110 CONTINUE        
C        
      DO 340 IZTA = 1,2        
      ZETA = (IZTA*2-3)*CONST        
C        
      ICOUNT = ICOUNT + 8*NDOF + NNODE + 32        
      IF (IZTA .EQ. 2) GO TO 160        
C        
C     THICKNESS AND MOMENT OF INERTIA AT THIS POINT        
C        
      THIKNS(INPLAN) = PHIOUT(ICOUNT+1)        
      IF (GRIDS .AND. INPLAN.NE.5) THIKNS(INPLAN) = GPTH(INPLN1)        
      REALI(INPLAN) = MOMINR*THIKNS(INPLAN)**3/12.0        
C        
C     DETERMINE FIBER DISTANCE VALUES        
C        
      IF (LOGZ12 .EQ. -4) GO TO 150        
      IF (LOGZ12) 120,130,140        
C        
  120 Z1(INPLAN) = -0.5*THIKNS(INPLAN)        
      Z2(INPLAN) = PHIOUT(20)        
      GO TO 160        
C        
  130 Z1(INPLAN) = PHIOUT(19)        
      Z2(INPLAN) = 0.5*THIKNS(INPLAN)        
      GO TO 160        
C        
  140 Z1(INPLAN) = -0.5*THIKNS(INPLAN)        
      Z2(INPLAN) = -Z1(INPLAN)        
      GO TO 160        
C        
  150 Z1(INPLAN) = PHIOUT(19)        
      Z2(INPLAN) = PHIOUT(20)        
  160 CONTINUE        
C        
C     FIRST COMPUTE LOCAL STRAINS UNCORRECTED FOR THERMAL STRAINS       
C     AT THIS EVALUATION POINT.        
C        
C        EPSLN  = PHIOUT(KSIG) * DELTA        
C          EPS  =       B      *   U        
C          8X1        8XNDOF    NDOFX1        
C        
      KSIG = ICOUNT+NNODE+33        
      CALL GMMATS (PHIOUT(KSIG),8,NDOF,0, DELTA(1),NDOF,1,0, EPSLN)     
C        
C     CALCULATE THERMAL STRAINS IF TEMPERATURES ARE PRESENT        
C        
      IF (LDTEMP .EQ. -1) GO TO 260        
      DO 170 IET = 1,6        
  170 EPSLNT(IET) = 0.0        
C        
C     A) MEMBRANE STRAINS        
C        
      IF (TEMPP1 .OR. TEMPP2) GO TO 190        
C        
C     GRID TEMPERATURES        
C        
      KSHP = ICOUNT + 32        
      TBAR = 0.0        
      DO 180 ISH = 1,NNODE        
      KSH  = KSHP + ISH        
  180 TBAR = TBAR + PHIOUT(KSH)*DELTAT(ISH)        
      TMEAN= TBAR        
      GO TO 200        
C        
C     ELEMENT TEMPERATURES        
C        
  190 TBAR = STEMP(1)        
  200 TBAR = TBAR - TSUB0        
      DO 210 IEPS = 1,3        
  210 EPSLNT(IEPS) = -TBAR*ALFAM(IEPS)        
C        
C     B) BENDING STRAINS (ELEMENT TEMPERATURES ONLY)        
C        
      IF (.NOT.BENDNG) GO TO 260        
      IF (.NOT.(TEMPP1 .OR. TEMPP2)) GO TO 260        
C        
C     EXTRACT G2-MATRIX FROM GBAR-MATRIX AND CORRECT IT FOR COUPLING    
C        
      IG21 = 0        
      DO 220 IG2 = 1,3        
      IG22 = (IG2-1)*6 + 21        
      DO 220 JG2 = 1,3        
      IG21 = IG21 + 1        
      JG22 = JG2  + IG22        
  220 G2(IG21) = G(JG22) + PHIOUT(ICOUNT+10+IG21)        
C        
      IG2AB = (ISIG*3)/5 + 1        
      CALL GMMATS (G2,3,3,0, ALFAB,3,1,0, G2ALFB(IG2AB))        
C        
      IF (TEMPP1) GO TO 240        
      CALL INVERS (3,G2,3,GDUM,0,DETG2,ISNGG2,INDXG2)        
      CALL GMMATS (G2,3,3,0, STEMP(2),3,1,0, KHIT)        
      DO 230 IEPS = 4,6        
  230 EPSLNT(IEPS) = KHIT(IEPS-3)*ZETA*THIKNS(INPLAN)/(2.*REALI(INPLAN))
      GO TO 260        
C        
  240 TPRIME = STEMP(2)        
      DO 250 IEPS = 4,6        
  250 EPSLNT(IEPS) = -TPRIME*ALFAB(IEPS-3)*ZETA*THIKNS(INPLAN)/2.       
C        
C     MODIFY GBAR-MATRIX        
C        
  260 I1 = -6        
      I2 = 12        
      I3 = 11 + ICOUNT        
      DO 270 I = 1,3        
      I1 = I1 + 6        
      I2 = I2 + 6        
      DO 270 J = 1,3        
      J1 = J  + I1        
      J3 = J1 + 3        
      J4 = J  + I2        
      J2 = J4 + 3        
      GT(J1) = G(J1)        
      GT(J2) = G(J2)        
      GT(J3) = G(J3) + PHIOUT(I3)        
      GT(J4) = G(J4) + PHIOUT(I3)        
  270 I3 = I3 + 1        
C        
C     DETERMINE G MATRIX FOR THIS EVALUATION POINT        
C        
      DO 280 I = 1,4        
  280 G3(I) = PHIOUT(ICOUNT+28+I)        
C        
      IF (LDTEMP .EQ. -1) GO TO 300        
C        
C     CORRECT STRAINS FOR THERMAL EFFECTS        
C        
      DO 290 I = 1,6        
  290 EPSLN(I) = EPSLN(I) + EPSLNT(I)        
C        
C     CALCULATE STRESS VECTOR        
C        
  300 CALL GMMATS (GT(1),6,6,0, EPSLN(1),6,1,0, TSIGMA(1))        
      CALL GMMATS (G3(1),2,2,0, EPSLN(7),2,1,0, TSIGMA(7))        
      IF (.NOT.BENDNG) GO TO 320        
C        
C     COMBINE STRESSES ONLY IF 'BENDING'        
C        
      DO 310 I = 1,3        
  310 TSIGMA(I) = TSIGMA(I+3)        
C        
  320 CONTINUE        
C        
C     TRANSFORM STRESSES FROM ELEMENT TO STRESS C.S.        
C        
      DO 330 I = 1,9        
  330 TES(I) = PHIOUT(ICOUNT+1+I)        
C        
      TESU(1) = TES(1)*TES(1)        
      TESU(2) = TES(4)*TES(4)        
      TESU(3) = TES(1)*TES(4)        
      TESU(4) = TES(2)*TES(2)        
      TESU(5) = TES(5)*TES(5)        
      TESU(6) = TES(2)*TES(5)        
      TESU(7) = TES(1)*TES(2)*2.0        
      TESU(8) = TES(4)*TES(5)*2.0        
      TESU(9) = TES(1)*TES(5) + TES(2)*TES(4)        
C        
      CALL GMMATS (TESU(1),3,3,1, TSIGMA(1),3,1,0, TSTR(ISIG))        
C        
      TESV(1) = TES(5)*TES(9) + TES(6)*TES(8)        
      TESV(2) = TES(2)*TES(9) + TES(8)*TES(3)        
      TESV(3) = TES(4)*TES(9) + TES(7)*TES(6)        
      TESV(4) = TES(1)*TES(9) + TES(3)*TES(7)        
C        
      ISIG = ISIG + 3        
      CALL GMMATS (TESV(1),2,2,1, TSIGMA(7),2,1,0, TSTR(ISIG))        
C        
  340 ISIG = ISIG + 2        
  350 CONTINUE        
C        
C     IF REQUIRED, EXTRAPOLATE STRESSES FROM INTEGRATION POINTS        
C     TO CORNER POINTS.        
C        
C     FIRST EXTRAPOLATE ACROSS ZETA, REGARDLESS OF INPLANE REQUEST      
C        
      DO 370 IKK = 1,5        
      ITB = (IKK-1)*10        
      DO 360 IJJ = 1,5        
      TSTB(IKK,IJJ) = TSTR(ITB+  IJJ)        
      TSTT(IKK,IJJ) = TSTR(ITB+5+IJJ)        
  360 CONTINUE        
  370 CONTINUE        
C        
      X1 = -CONST        
      X2 = -X1        
C        
      DO 380 K = 1,2        
      IK = 0        
      XX = -1.0        
      IF (K .EQ. 2) XX =-XX        
      IF (K .EQ. 2) IK = 5        
C        
      XN22 = (XX-X1)/(X2-X1)        
      XN11 = 1.0 - XN22        
C        
      DO 380 I = 1,5        
      IKKN = (I-1)*10 + IK        
      DO 380 J = 1,5        
  380 TSTN(IKKN+J) = TSTB(I,J)*XN11 + TSTT(I,J)*XN22        
C        
      DO 390 II = 1,50        
  390 TSTR(II) = TSTN(II)        
C        
      IF (INTGS .OR. COMPOS) GO TO 540        
C        
      IXTR = 5        
      JXTR = IXTR*4        
C        
      IZ1 = 0        
      DO 530 IZ = 1,2        
C        
      DO 400 I = 1,JXTR        
  400 TST(I) = 0.0        
C        
C     FOR THE SAKE OF COMPATIBILITY BETWEEN THE CONVENTION FOR        
C     SHEAR FORCES, AND THE CONVENTION FOR EXTRAPOLATION, WE MAY        
C     HAVE TO CHANGE THE SIGNS AROUND FOR SPECIFIC POINTS. THEY        
C     WILL BE RETURNED TO THE ORIGINAL SIGNS AFTER EXTRAPOLATION IS     
C     COMPLETE.        
C        
      IF (OPRQST .LT. 0) GO TO 460        
      DO 440 I = 1,4        
      J = (I-1)*2*IXTR + IZ1 + 4        
      IF (TSTR(J) .EQ. 0.0) GO TO 410        
      SIGNY(I) = TSTR(J)/ABS(TSTR(J))        
      GO TO 420        
  410 SIGNY(I) = 0.0        
  420 IF (TSTR(J+1) .EQ. 0.0) GO TO 430        
      SIGNX(I) = TSTR(J+1)/ABS(TSTR(J+1))        
      GO TO 440        
  430 SIGNX(I) = 0.0        
  440 CONTINUE        
C        
      SNRVRY = .FALSE.        
      IF (SIGNY(1)*SIGNY(2).LE.0.0 .OR. SIGNY(3)*SIGNY(4).LE.0.0 .OR.   
     1    SIGNY(3)*SIGNY(1).LE.0.0) SNRVRY = .TRUE.        
      SNRVRX = .FALSE.        
      IF (SIGNX(1)*SIGNX(2).LE.0.0 .OR. SIGNX(3)*SIGNX(4).LE.0.0 .OR.   
     1    SIGNX(3)*SIGNX(1).LE.0.0) SNRVRX = .TRUE.        
C        
      IF (.NOT.SNRVRY) GO TO 450        
      TSTR(IZ1+4) = -TSTR(IZ1+4)        
      TSTR(IZ1+4+4*IXTR) = -TSTR(IZ1+4+4*IXTR)        
  450 IF (.NOT.SNRVRX) GO TO 460        
      TSTR(IZ1+5) = -TSTR(IZ1+5)        
      TSTR(IZ1+5+2*IXTR) = -TSTR(IZ1+5+2*IXTR)        
  460 CONTINUE        
C        
      XPOINT(1) = -1.0        
      XPOINT(2) = +1.0        
      IR = 0        
C        
      DO 490 IX = 1,2        
      XI = XPOINT(IX)        
C        
      DO 490 IE = 1,2        
      ETA = XPOINT(IE)        
C        
      SHPFNC(1) = 0.75*(CONST-XI)*(CONST-ETA)        
      SHPFNC(2) = 0.75*(CONST-XI)*(CONST+ETA)        
      SHPFNC(3) = 0.75*(CONST+XI)*(CONST-ETA)        
      SHPFNC(4) = 0.75*(CONST+XI)*(CONST+ETA)        
C        
      LI = IR*IXTR        
      IR = IR + 1        
C        
      DO 480 IS = 1,4        
      LK = (IS-1)*2*IXTR + IZ1        
C        
      DO 470 IT = 1,IXTR        
      TST(LI+IT) = TST(LI+IT) + SHPFNC(IS)*TSTR(LK+IT)        
  470 CONTINUE        
  480 CONTINUE        
  490 CONTINUE        
C        
      J1 = 0        
      DO 500 IS = 1,4        
      J2 = (IS-1)*2*IXTR + IZ1        
      DO 500 JS = 1,IXTR        
      J1 = J1 + 1        
      J2 = J2 + 1        
  500 TSTR(J2) = TST(J1)        
C        
C     CHANGE THE SIGNS BACK, IF NECESSARY        
C        
      IF (OPRQST .LT. 0) GO TO 520        
      IF (.NOT.SNRVRY) GO TO 510        
      TSTR(IZ1+4) = -TSTR(IZ1+4)        
      TSTR(IZ1+4+4*IXTR) = -TSTR(IZ1+4+4*IXTR)        
  510 IF (.NOT.SNRVRX) GO TO 520        
      TSTR(IZ1+5) = -TSTR(IZ1+5)        
      TSTR(IZ1+5+2*IXTR) = -TSTR(IZ1+5+2*IXTR)        
  520 CONTINUE        
  530 IZ1 = IZ1 + IXTR        
  540 CONTINUE        
C        
C     STAGE 4 - CALCULATION OF OUTPUT STRESSES        
C     ========================================        
C        
      IF (OPRQST .EQ. 0) GO TO 740        
C        
      ISIG    = 0        
      IG2A    = 0        
      STRX(1) = 0.0        
      STRX(2) = 0.0        
      STRY(1) = 0.0        
      STRY(2) = 0.0        
      STRS(1) = 0.0        
      STRS(2) = 0.0        
      DO 730 INPLAN = 1,5        
      INPLN1 = INPLAN        
      IF (INPLAN .EQ. 2) INPLN1 = 4        
      IF (INPLAN .EQ. 3) INPLN1 = 2        
      IF (INPLAN .EQ. 4) INPLN1 = 3        
C        
      ISTRES = (INPLN1-1)*17 + 2        
C        
      IDPONT = IGRID(INPLAN)        
      IF (INTGS) IDPONT = INPLN1        
      IF (INTGS .AND. INPLAN.EQ.5) IDPONT = CENTER        
      NSTRES(ISTRES) = IDPONT        
      THICK = THIKNS(INPLAN)        
C        
      DO 720 IZ = 1,2        
      IF (IZ .EQ. 2) ISTRES = ISTRES + 8        
      FIBRE = Z1(INPLAN)        
      IF (IZ .EQ. 2) FIBRE = Z2(INPLAN)        
      STRES(ISTRES+1) = FIBRE        
C        
C     EVALUATE STRESSES AT THIS FIBRE DISTANCE        
C        
      DO 550 I = 1,3        
      SIGMA(I) = (0.5-FIBRE/THICK)*TSTR(ISIG+I) + (0.5+FIBRE/THICK)     
     1           *TSTR(ISIG+I+5)        
  550 CONTINUE        
C        
C     IF TEMPERATURES ARE PRESENT, CORRECT STRESSES FOR THERMAL        
C     STRESSES ASSOCIATED WITH THE DATA RELATED TO FIBRE DISTANCES.     
C        
      IF (LDTEMP .EQ. -1) GO TO 610        
C        
C     IF NO BENDING, TREAT IT LIKE GRID POINT TEMPERATURES        
C        
      IF (.NOT.BENDNG) GO TO 610        
      IF (TEMPP1) GO TO 560        
      IF (TEMPP2) GO TO 570        
      GO TO 610        
C        
  560 TSUBI = STEMP(2+IZ)        
C     IF (IZ .EQ. 2) TSUBI = STEMP(4)        
      IF (ABS(TSUBI) .LT. EPSS) GO TO 610        
      TSUBI = TSUBI - TPRIME*FIBRE        
      GO TO 590        
C        
  570 TSUBI = STEMP(4+IZ)        
C     IF (IZ .EQ. 2) TSUBI = STEMP(6)        
      IF (ABS(TSUBI) .LT. EPSS) GO TO 610        
      DO 580 IST = 1,3        
  580 SIGMA(IST) = SIGMA(IST) - STEMP(IST+1)*FIBRE/REALI(INPLAN)        
  590 TSUBI = TSUBI - TBAR        
      DO 600 ITS = 1,3        
      SIGMA(ITS) = SIGMA(ITS) - TSUBI*G2ALFB(IG2A+ITS)        
  600 CONTINUE        
C        
C     AVERAGE THE VALUES FROM OTHER 4 POINTS FOR THE CENTER POINT       
C        
  610 IF (INPLAN .EQ. 5) GO TO 620        
      STRX(IZ) = STRX(IZ) + 0.25*SIGMA(1)        
      STRY(IZ) = STRY(IZ) + 0.25*SIGMA(2)        
      STRS(IZ) = STRS(IZ) + 0.25*SIGMA(3)        
      GO TO 630        
  620 SIGMA(1) = STRX(IZ)        
      SIGMA(2) = STRY(IZ)        
      SIGMA(3) = STRS(IZ)        
  630 DO 640 IS = 1,3        
  640 STRES(ISTRES+1+IS) = SIGMA(IS)        
C        
C     CALCULATE PRINCIPAL STRESSES        
C        
      SIGAVG = 0.5*(SIGMA(1) + SIGMA(2))        
      PROJ   = 0.5*(SIGMA(1) - SIGMA(2))        
      TAUMAX = PROJ*PROJ + SIGMA(3)*SIGMA(3)        
      IF (ABS(TAUMAX) .LE. EPSS) GO TO 650        
      TAUMAX = SQRT(TAUMAX)        
      GO TO 660        
  650 TAUMAX = 0.0        
C        
C     PRINCIPAL ANGLE        
C        
  660 TXY2 = SIGMA(3)*2.0        
      PROJ = PROJ*2.0        
      IF (ABS(TXY2).LE.EPSA .AND. ABS(PROJ).LE.EPSA) GO TO 670        
      STRES(ISTRES+5) = 28.647890*ATAN2(TXY2,PROJ)        
      GO TO 680        
  670 STRES(ISTRES+5) = 0.0        
  680 SIGMA1 = SIGAVG + TAUMAX        
      SIGMA2 = SIGAVG - TAUMAX        
      STRES(ISTRES+6) = SIGMA1        
      STRES(ISTRES+7) = SIGMA2        
C        
C     OUTPUT VON MISES YIELD STRESS IF ASKED FOR BY THE USER        
C        
      IF (VONMS) GO TO 690        
      STRES(ISTRES+8) = TAUMAX        
      GO TO 720        
C        
  690 SIGYP = SIGMA1*SIGMA1 + SIGMA2*SIGMA2 - SIGMA1*SIGMA2        
      IF (ABS(SIGYP) .LE. EPSS) GO TO 700        
      SIGYP = SQRT(SIGYP)        
      GO TO 710        
  700 SIGYP = 0.0        
  710 STRES(ISTRES+8) = SIGYP        
C        
  720 IG2A = IG2A + 3        
  730 ISIG = ISIG + 10        
C        
C     STAGE 5 - ELEMENT FORCE OUTPUT        
C     ==============================        
C        
  740 IF (LAYER) GO TO 750        
      IF (OPRQST .LT. 0) GO TO 790        
C        
  750 CONTINUE        
      ISIG   = 0        
      VXCNTR = 0.0        
      VYCNTR = 0.0        
      FXCNTR = 0.0        
      FYCNTR = 0.0        
      FXYCNT = 0.0        
      DO 780 INPLAN = 1,5        
      INPLN1 = INPLAN        
      IF (INPLAN .EQ. 2) INPLN1 = 4        
      IF (INPLAN .EQ. 3) INPLN1 = 2        
      IF (INPLAN .EQ. 4) INPLN1 = 3        
      THICK = THIKNS(INPLAN)        
C        
      IFORCE = (INPLN1-1)*9 + 2        
C        
      IDPONT = IGRID(INPLAN)        
      IF (INTGS) IDPONT = INPLN1        
      IF (INTGS .AND. INPLAN.EQ.5) IDPONT = CENTER        
      NFORS(IFORCE) = IDPONT        
C        
C     CALCULATE FORCES AT MID-SURFACE LEVEL        
C        
      DO 760 IFOR = 1,3        
      FORSUL(IFORCE+IFOR  )=(TSTR(ISIG+IFOR)+TSTR(ISIG+IFOR+5))*THICK/2.
      FORSUL(IFORCE+IFOR+3)=(TSTR(ISIG+IFOR)-TSTR(ISIG+IFOR+5))*        
     1                       REALI(INPLAN)/THICK        
  760 CONTINUE        
C        
C     INTERCHANGE 7 AND 8 POSITIONS TO BE COMPATIBLE WITH THE        
C     OUTPUT FORMAT OF VX AND VY (WE HAVE CALCULATED VY AND VX)        
C        
      IF (INPLAN .EQ. 5) GO TO 770        
      FORSUL(IFORCE+7) = (TSTR(ISIG+5) + TSTR(ISIG+10))*THICK*0.5       
      FORSUL(IFORCE+8) = (TSTR(ISIG+4) + TSTR(ISIG+ 9))*THICK*0.5       
C        
C     SUBSTITUTE THE AVERAGE OF CORNER (OR INTEGRATION) POINT        
C     MEMBRANE AND SHEAR FORCES FOR THE CENTER POINT        
C        
      FXCNTR = FXCNTR + FORSUL(IFORCE+1)*0.25        
      FYCNTR = FYCNTR + FORSUL(IFORCE+2)*0.25        
      FXYCNT = FXYCNT + FORSUL(IFORCE+3)*0.25        
      VXCNTR = VXCNTR + FORSUL(IFORCE+7)*0.25        
      VYCNTR = VYCNTR + FORSUL(IFORCE+8)*0.25        
      GO TO 780        
  770 CONTINUE        
      FORSUL(IFORCE+1) = FXCNTR        
      FORSUL(IFORCE+2) = FYCNTR        
      FORSUL(IFORCE+3) = FXYCNT        
      FORSUL(IFORCE+7) = VXCNTR        
      FORSUL(IFORCE+8) = VYCNTR        
C        
  780 ISIG = ISIG + 10        
C        
C     DO NOT WRITE TO PHIOUT IF LAYER STRESSES ARE REQUESTED        
C     BECAUSE PHIOUT NEEDS TO BE INTACT        
      IF (LAYER) GO TO 900        
C        
C     STAGE 7 - SHIPPING OF NORMAL STRESSES        
C     =====================================        
C        
C     STORE THE STRESSES WHERE THE HIGHER LEVEL ROUTINES EXPECT        
C     TO FIND THEM.        
C     BUT FIRST, MOVE THE CENTER POINT STRESSES TO THE TOP.        
C        
      IF (OPRQST .EQ. 0) GO TO 840        
  790 NPHI(101) = NSTRES(1)        
      DO 800 I = 3,18        
      I99 = I + 99        
  800 NPHI(I99) = NSTRES(I+68)        
C        
C     DEBUG PRINTOUT        
C        
      IF (DEBUG) WRITE (NOUT,810) (STRES(I),I=71,86)        
  810 FORMAT (' SQUD42 - STRESSES', (/1X,8E13.5))        
C        
      DO 830 I = 19,86        
      I99 = I + 99        
  830 NPHI(I99) = NSTRES(I-17)        
C        
C     STORE FORCES IN THEIR APPROPRIATE LOCATION        
C        
      IF (OPRQST .LT. 0) RETURN        
  840 NPHI(201) = NFORS(1)        
      DO 850 I = 3,10        
      I199 = I + 199        
  850 NPHI(I199) = NFORS(I+36)        
C        
C     DEBUG PRINTOUT        
C        
      IF (DEBUG) WRITE (NOUT,860) (FORSUL(I),I=39,46)        
  860 FORMAT (' SQUD42 - FORCES', (/1X,8E13.5))        
C        
      DO 870 I = 11,46        
      I199 = I + 199        
  870 NPHI(I199) = NFORS(I-9)        
C        
C     PROCESSING FOR NORMAL STRESS REQUEST COMPLETED        
C        
      GO TO 2100        
C        
C     ELEMENT LAYER STRESS CALCULATION        
C        
C     CHECK STRESS AND FORCE OUTPUT REQUEST        
C        
  900 IF ((KFORCE.NE.0 .OR. KSTRS.NE.0) .AND. .NOT.COMPOS) GO TO 2220   
C        
C     WRITE FORCE RESULTANTS TO OEF1L IF REQUESTED        
C         1.    10*ELEMENT ID + DEVICE CODE (FDEST)        
C        2-9.   FORCE RESULTANTS        
C               FX, FY, FXY, MX, MY, MXY, VX, VY        
C        
      IF (KFORCE .EQ.  0) GO TO 910        
      ELEMID = 10*ELID + FDEST        
      IF (LDTEMP .NE. -1) GO TO 910        
      CALL WRITE (OEF1L,ELEMID,1,0)        
      CALL WRITE (OEF1L,FORSUL(39),8,0)        
C        
C 910 IF (KSTRS .EQ. 0) RETURN        
  910 IF (KSTRS.EQ.0 .AND. LDTEMP.EQ.-1) RETURN        
      ELEMID = 10*ELID + SDEST        
C        
C     LOCATE PID BY CARRYING OUT A SEQUENTIAL SEARCH        
C     OF THE PCOMPS DATA BLOCK, AND ALSO DETERMINE        
C     THE TYPE OF 'PCOMP' BULK DATA ENTRY.        
C        
C     SET POINTER LPCOMP        
C        
      LPCOMP = IPCMP + NPCMP + NPCMP1 + NPCMP2        
C        
C        
C     POINTER DESCRIPITION        
C     --------------------        
C     IPCMP  - LOCATION OF START OF PCOMP DATA IN CORE        
C     NPCMP  - NUMBER OF WORDS OF PCOMP DATA        
C     IPCMP1 - LOCATION OF START OF PCOMP1 DATA IN CORE        
C     NPCMP1 - NUMBER OF WORDS OF PCOMP1 DATA        
C     IPCMP2 - LOCATION OF START OF PCOMP2 DATA IN CORE        
C     NPCMP2 - NUMBER OF WORDS OF PCOMP2 DATA        
C        
C     ITYPE  - TYPE OF PCOMP BULK DATA ENTRY        
C        
C     LAMOPT - LAMINATION GENERATION OPTION        
C            = SYM  (SYMMETRIC)        
C            = MEM  (MEMBRANE )        
C            = SYMMEM  (SYMMETRIC-MEMBRANE)        
C        
C     FTHR   - FAILURE THEORY        
C            = 1    HILL        
C            = 2    HOFFMAN        
C            = 3    TSAI-WU        
C            = 4    MAX-STRESS        
C            = 5    MAX-STRAIN        
C        
C     ULTSTN - ULTIMATE STRENGTH VALUES        
C        
C     SET POINTERS        
C        
      ITYPE = -1        
C        
      PCMP  = .FALSE.        
      PCMP1 = .FALSE.        
      PCMP2 = .FALSE.        
C        
      PCMP  = NPCMP  .GT. 0        
      PCMP1 = NPCMP1 .GT. 0        
      PCMP2 = NPCMP2 .GT. 0        
C        
C     CHECK IF NO 'PCOMP' DATA HAS BEEN READ INTO CORE        
C        
      IF (.NOT.PCMP .AND. .NOT.PCMP1 .AND. .NOT.PCMP2) GO TO 2200       
C        
C     SEARCH FOR PID IN PCOMP DATA        
C        
      IF (.NOT.PCMP) GO TO 960        
C        
      IP = IPCMP        
      IF (INTZ(IP) .EQ. IPID) GO TO 950        
      IPC11 = IPCMP1 - 1        
      DO 930 IP = IPCMP,IPC11        
      IF (INTZ(IP).EQ.-1 .AND. IP.LT.(IPCMP1-1)) GO TO 920        
      GO TO 930        
  920 IF (INTZ(IP+1) .EQ. IPID) GO TO 940        
  930 CONTINUE        
      GO TO 960        
C        
  940 IP = IP + 1        
  950 ITYPE = PCOMP        
      GO TO 1070        
C        
C     SEARCH FOR PID IN PCOMP1 DATA        
C        
  960 IF (.NOT.PCMP1) GO TO 1010        
      IP = IPCMP1        
      IF (INTZ(IP) .EQ. IPID) GO TO 1000        
      IPC21 = IPCMP2 - 1        
      DO 980 IP = IPCMP1,IPC21        
      IF (INTZ(IP).EQ.-1 .AND. IP.LT.(IPCMP2-1)) GO TO 970        
      GO TO 980        
  970 IF (INTZ(IP+1) .EQ. IPID) GO TO 990        
  980 CONTINUE        
      GO TO 1010        
C        
  990 IP = IP + 1        
 1000 ITYPE = PCOMP1        
      GO TO 1070        
C        
C     SEARCH FOR PID IN PCOMP2 DATA        
C        
 1010 IF (.NOT.PCMP2) GO TO 1060        
C        
      IP = IPCMP2        
      IF (INTZ(IP) .EQ. IPID) GO TO 1050        
      LPC11 = LPCOMP - 1        
      DO 1030 IP = IPCMP2,LPC11        
      IF (INTZ(IP).EQ.-1 .AND. IP.LT.(LPCOMP-1)) GO TO 1020        
      GO TO 1030        
 1020 IF (INTZ(IP+1) .EQ. IPID) GO TO 1040        
 1030 CONTINUE        
      GO TO 1060        
C        
 1040 IP = IP + 1        
 1050 ITYPE = PCOMP2        
      GO TO 1070        
C        
C     CHECK IF PID HAS NOT BEEN LOCATED        
C        
 1060 IF (ITYPE .EQ. -1) GO TO 2200        
C        
C     LOCATION OF PID        
C        
 1070 PIDLOC = IP        
      LAMOPT = INTZ(PIDLOC+8)        
C        
C     INTILIZE        
C        
      DO 1080 IR = 1,3        
      STRNT(IR) = 0.0        
      STRNB(IR) = 0.0        
 1080 CONTINUE        
C        
C     CALCULATION OF STRAINS        
C        
C     INTEGRATION DATA IN PHIOUT IS ARRANGED IN ETA,XI INCREASING       
C     SEQUENCE.        
C        
      ISIG   = 1        
      ICOUNT = -(8*NDOF+NNODE+32) + 79 + 9*NNODE        
C        
      DO 1200 INPLAN = 1,5        
      INPLN1 = IPN(INPLAN)        
C        
C     MATCH GRID ID NUMBER WHICH IS IN SIL ORDER        
C        
      IF (INPLAN .EQ. 5) GO TO 1100        
      DO 1090 I = 1,NNODE        
      IF (IORDER(I) .NE. INPLN1) GO TO 1090        
      IGRID(INPLAN) = EXTRNL(I)        
      GO TO 1110        
 1090 CONTINUE        
      GO TO 1110        
C        
 1100 IGRID(INPLAN) = CENTER        
 1110 CONTINUE        
C        
      DO 1190 IZTA = 1,2        
      ZETA = (IZTA*2-3)*CONST        
C        
      ICOUNT = ICOUNT + 8*NDOF + NNODE + 32        
C        
C     FIRST COMPUTE LOCAL STRAINS AT THIS EVALUATION POINT        
C        
C        EPSLN = PHIOUT(KSIG) * DELTA        
C          EPS =        B     *   U        
C          8X1        8XNDOF    NDOFX1        
C        
      KSIG = ICOUNT + NNODE + 33        
      CALL GMMATS (PHIOUT(KSIG),8,NDOF,0, DELTA(1),NDOF,1,0, EPSLN)     
C        
C     TRANSFORM THE STRAINS AT THIS EVALUATION POINT TO THE        
C     MATERIAL COORDINATE SYSTEM        
C        
      DO 1120 IR = 1,9        
 1120 TMI(IR) = PHIOUT(ICOUNT+19+IR)        
C        
C     TOTAL STRAIN AT EVALUATION POINT = MEMBRANE + BENDING        
C        
      DO 1130 IR = 1,3        
 1130 EPSTOT(IR) = EPSLN(IR) + EPSLN(IR+3)        
C        
C     GENERATE TRANS-MATRIX TO TRANSFORM STRAINS FROM I TO M SYSTEM     
C        
      TRANS(1)  = TMI(1)*TMI(1)        
      TRANS(2)  = TMI(2)*TMI(2)        
      TRANS(3)  = TMI(1)*TMI(2)        
      TRANS(4)  = TMI(4)*TMI(4)        
      TRANS(5)  = TMI(5)*TMI(5)        
      TRANS(6)  = TMI(4)*TMI(5)        
      TRANS(7)  = 2.0*TMI(1)*TMI(4)        
      TRANS(8)  = 2.0*TMI(2)*TMI(5)        
      TRANS(9)  = TMI(1)*TMI(5) + TMI(2)*TMI(4)        
C        
C     TRANSFORM TOTAL STRAINS        
C        
      CALL GMMATS (TRANS(1),3,3,0, EPSTOT(1),3,1,0, EPSE(1))        
C        
      IF (INPLAN .EQ. 5) GO TO 1160        
C        
C     AVERAGE THE STRAIN VECTORS OF THE FOUR INTGS POINTS AT EACH       
C     LEVEL TO CALCULATE THE ELEMENT CENTRE STRAIN VECTOR FOR THE       
C     UPPER AND BOTTOM LEVELS.        
C        
      DO 1150 IR = 1,3        
      IF (IZTA .EQ. 2) GO TO 1140        
      STRNB(IR) = STRNB(IR) + 0.25*EPSE(IR)        
      GO TO 1150        
 1140 STRNT(IR) = STRNT(IR) + 0.25*EPSE(IR)        
 1150 CONTINUE        
      GO TO 1190        
C        
C     TOTAL STRAIN VECTORS AT ELEMENT CENTRE        
C        
 1160 DO 1180 IR = 1,3        
      IF (IZTA .EQ. 2) GO TO 1170        
      STRNBC(IR) = EPSE(IR)        
      GO TO 1180        
 1170 STRNTC(IR) = EPSE(IR)        
 1180 CONTINUE        
C        
 1190 CONTINUE        
 1200 CONTINUE        
C        
C     EXTRAPOLATE STRAINS ACROSS ZETA        
C        
      DO 1210 IR = 1,3        
      EPST(IR) = (STRNT(IR)-STRNB(IR))*(+1.0+CONST)/(2.0*CONST)        
     1         +  STRNB(IR)        
      EPSB(IR) = (STRNT(IR)-STRNB(IR))*(-1.0+CONST)/(2.0*CONST)        
     1         +  STRNB(IR)        
 1210 CONTINUE        
C        
C     CALCULATE LAYER STRESSES AND FAILURE INDICES (IF REQUESTED)       
C     AND WRITE TO THE OUTPUT FILE OES1L        
C         1.    10*ELEMENT ID + DEVICE CODE (SDEST)        
C         2.    NLAYER - NUMBER OF LAYERS FOR LAMINATE        
C         3.    TYPE OF FAILURE THEORY SELECTED        
C        
C         4.    PLY ID        
C       5,6,7.  LAYER STRESSES        
C         8.    PLY FAILURE INDEX (FP)        
C         9.    IFLAG (= 1 IF FP.GE.0.999, DEFAULT = 0)        
C       10,11.  INTERLAMINAR SHEAR STRESSES        
C        12.    SHEAR BONDING INDEX (SB)        
C        13.    IFLAG (= 1 IF SB.GE.0.999, DEFAULT = 0)        
C         :     4 - 13 REPEATED FOR THE NUMBER OF LAYERS WITH        
C         :           LAYER STRESS REQUEST        
C      LAST-1.  MAXIMUM FAILURE INDEX OF LAMINATE  (FIMAX)        
C       LAST.   IFLAG (= 1 IF FIMAX.GE.0.999, DEFAULT = 0)        
C        
C      1-LAST.  REPEAT FOR NUMBER OF ELEMENTS        
C        
C       (NOTE - ONLY THE ELEMENT CENTRE VALUES ARE CALCULATED)        
C        
C     == 1.        
C        
      IF (KSTRS .EQ. 1) CALL WRITE (OES1L,ELEMID,1,0)        
C        
C     DETERMINE INTRINSIC LAMINATE PROPERTIES        
C        
C     LAMINATE THICKNESS        
C        
      TLAM = PHIOUT(21)        
C        
C     REFERENCE SURFACE        
C        
      ZREF = -TLAM/2.0        
C        
C     NUMBER OF LAYERS        
C        
      NLAY = INTZ(PIDLOC+1)        
C        
C     FOR PCOMP BULK DATA DETERMINE HOW MANY LAYERS HAVE THE STRESS     
C     OUTPUT REQUEST (SOUTI)        
C     NOTE - FOR PCOMP1 OR PCOMP2 BULK DATA ENTRIES LAYER        
C            STRESSES ARE OUTPUT FOR ALL LAYERS.        
C        
      NLAYER = NLAY        
C        
      IF (ITYPE .NE. PCOMP) GO TO 1230        
C        
      NSTRQT = 0        
      DO 1220 K = 1,NLAY        
      IF (INTZ(PIDLOC+8+4*K) .EQ. 1) NSTRQT = NSTRQT + 1        
 1220 CONTINUE        
      NLAYER = NSTRQT        
C        
C     WRITE TOTAL NUMBER OF LAYERS WITH STRESS REQ TO OES1L        
C        
 1230 IF (LAMOPT.EQ.SYM .OR. LAMOPT.EQ.SYMMEM) NLAYER = 2*NLAYER        
C        
C     == 2.        
C        
      IF (KSTRS .EQ. 1) CALL WRITE (OES1L,NLAYER,1,0)        
C        
C     SET POINTER        
C        
      IF (ITYPE .EQ. PCOMP ) IPOINT = PIDLOC + 8 + 4*NLAY        
      IF (ITYPE .EQ. PCOMP1) IPOINT = PIDLOC + 8 +   NLAY        
      IF (ITYPE .EQ. PCOMP2) IPOINT = PIDLOC + 8 + 2*NLAY        
C        
C     FAILURE THEORY TO BE USED IN COMPUTING FAILURE INDICES        
C        
      FTHR = INTZ(PIDLOC+5)        
C        
C     WRITE TO OUTPUT FILE TYPE OF FAILURE THEORY SELECTED        
C        
C     == 3.        
C        
      IF (KSTRS .EQ. 1) CALL WRITE (OES1L,FTHR,1,0)        
C        
C     SHEAR BONDING STRENGTH        
C        
      SB     = Z(PIDLOC+4)        
      FINDEX = 0.0        
      FBOND  = 0.0        
      FPMAX  = 0.0        
      FBMAX  = 0.0        
      FIMAX  = 0.0        
C        
C     SET TRNFLX IF INTERLAMINAR SHEAR STRESS CALCULATIONS        
C     IS REQUIRED        
C        
      TRNFLX = .FALSE.        
C        
C     TRANSVERSE SHEAR STRESS RESULTANTS QX AND QY        
C        
      V(1) = FORSUL(45)        
      V(2) = FORSUL(46)        
      TRNFLX = V(1).NE.0.0 .AND. V(2).NE.0.0        
      IF (.NOT.TRNFLX) GO TO 1240        
      IF (ITYPE .EQ. PCOMP) ICONTR = IPOINT + 27*NLAY        
      IF (ITYPE.EQ.PCOMP1 .OR. ITYPE.EQ.PCOMP2)        
     1    ICONTR = IPOINT + 25 + 2*NLAY        
C        
C     LAMINATE BENDING INERTIA        
C        
      EI(1)   = Z(ICONTR+1)        
      EI(2)   = Z(ICONTR+2)        
C        
C     LOCATION OF NEUTRAL SURFACE        
C        
      ZBAR(1) = Z(ICONTR+3)        
      ZBAR(2) = Z(ICONTR+4)        
C        
C     INTILIZISE        
C        
 1240 DO 1250 LL = 1,2        
      TRNAR(LL)  = 0.0        
      TRNSHR(LL) = 0.0        
 1250 CONTINUE        
C        
C     ALLOW FOR THE ORIENTATION OF THE MATERIAL AXIS FROM        
C     THE USER DEFINED COORDINATE SYSTEM        
C        
      THETAE = ACOS(PHIOUT(69))        
      THETAE = THETAE*DEGRAD        
C        
C     SWITCH FOR THEMAL EFFECTS        
C        
      IF (LDTEMP .EQ. -1) GO TO 1290        
C        
C     LAMINATE REFERENCE (OR LAMINATION) TEMPERATURE        
C        
      TSUBO = Z(IPOINT+24)        
C        
C     MEAN ELEMENT TEMPERATURE        
C        
      TBAR = TMEAN        
      IF (TEMPP1 .OR. TEMPP2) TBAR = STEMP(1)        
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 1290        
      IF (.NOT.(TEMPP1 .OR. TEMPP2)) GO TO 1290        
      IF (.NOT.TEMPP1) GO TO 1260        
C        
C     TEMPERATURE GRADIENT TPRIME        
C        
      TPRIME = STEMP(2)        
C        
 1260 IF (.NOT.TEMPP2) GO TO 1290        
C        
C     COMPUTE REFERENCE SURFACE STRAINS AND CURVATURES        
C     DUE TO THERMAL MOMENTS        
C        
C     MOMENT OF INERTIA OF LAMINATE        
C        
      MINTR = (TLAM**3)/12.0        
C        
C     DETERMINE ABBD-MATRIX FROM PHIOUT(23-58)        
C        
      ICOUNT = 89 + 9*NNODE        
      DO 1270 LL = 1,3        
      DO 1270 MM = 1,3        
      NN = MM + 6*(LL-1)        
      II = MM + 3*(LL-1)        
      ABBD(LL  ,MM  ) = PHIOUT(NN+22)*TLAM        
      ABBD(LL  ,MM+3) = PHIOUT(ICOUNT+II)*(TLAM*TLAM)/(-6.0*CONST)      
      ABBD(LL+3,MM  ) = PHIOUT(ICOUNT+II)*(TLAM*TLAM)/(-6.0*CONST)      
      ABBD(LL+3,MM+3) = PHIOUT(NN+43)*MINTR        
 1270 CONTINUE        
C        
C     COMPUTE THERMAL REF STRAINS AND CURVATURES        
C                                   -1        
C        EZEROT-VECTOR =  ABBD-MATRIX   X  MTHR-VECTOR        
C        
      MTHER( 1) = 0.0        
      MTHER( 2) = 0.0        
      MTHER( 3) = 0.0        
      MTHER( 4) = STEMP(2)        
      MTHER( 5) = STEMP(3)        
      MTHER( 6) = STEMP(4)        
C        
      CALL INVERS (6,ABBD,6,DUMC,0,DETRM,ISING,INDX)        
C        
      DO 1280 LL = 1,6        
      DO 1280 MM = 1,6        
      NN = MM + 6*(LL-1)        
      STIFF(NN) = ABBD(LL,MM)        
 1280 CONTINUE        
C        
      CALL GMMATS (STIFF(1),6,6,0, MTHER(1),6,1,0, EZEROT(1))        
C        
 1290 CONTINUE        
C        
      DO 1300 LL = 1,6        
 1300 FORSUL(LL) = 0.0        
C        
C     LOOP OVER NLAY        
C        
      DO 1600 K = 1,NLAY        
C        
C     ZSUBI -DISTANCE FROM REFERENCE SURFACE TO MID OF LAYER K        
C        
      ZK1 = ZK        
      IF (K .EQ. 1) ZK1 = ZREF        
      IF (ITYPE .EQ. PCOMP ) ZK = ZK1 + Z(PIDLOC+6+4*K)        
      IF (ITYPE .EQ. PCOMP1) ZK = ZK1 + Z(PIDLOC+7    )        
      IF (ITYPE .EQ. PCOMP2) ZK = ZK1 + Z(PIDLOC+7+2*K)        
C        
      ZSUBI = (ZK+ZK1)/2.0        
C        
C     LAYER THICKNESS        
C        
      TI = ZK - ZK1        
C        
C     CALCULATE STRAIN VECTOR AT STN ZSUBI        
C        
      DO 1400 IR = 1,3        
      EPSLNE(IR) = (.5-ZSUBI/TLAM)*EPSB(IR) + (.5+ZSUBI/TLAM)*EPST(IR)  
 1400 CONTINUE        
C        
C     LAYER ORIENTATION        
C        
      IF (ITYPE .EQ. PCOMP ) THETA = Z(PIDLOC+7+4*K)        
      IF (ITYPE .EQ. PCOMP1) THETA = Z(PIDLOC+8+  K)        
      IF (ITYPE .EQ. PCOMP2) THETA = Z(PIDLOC+8+2*K)        
C        
C     BUILD TRANS-MATRIX TO TRANSFORM LAYER STRAINS FROM MATERIAL       
C     TO FIBRE DIRECTION.        
C        
      THETA = THETA*DEGRAD        
C        
      C   = COS(THETA)        
      C2  = C*C        
      S   = SIN(THETA)        
      S2  = S*S        
C        
      TRANS(1)  = C2        
      TRANS(2)  = S2        
      TRANS(3)  = C*S        
      TRANS(4)  = S2        
      TRANS(5)  = C2        
      TRANS(6)  =-C*S        
      TRANS(7)  =-2.0*C*S        
      TRANS(8)  = 2.0*C*S        
      TRANS(9)  = C2-S2        
C        
C     TRANSFORM STRAINS FROM ELEMENT TO FIBRE COORD SYSTEM        
C        
      CALL GMMATS (TRANS(1),3,3,0, EPSLNE(1),3,1,0, EPSLN(1))        
C        
C     SWITCH FOR TEMPERATURE EFFECTS        
C        
      IF (LDTEMP .EQ. -1) GO TO 1470        
C        
C     CORRECT LAYER STRAIN VECTOR FOR THERMAL EFFECTS        
C        
C     LAYER THERMAL COEFFICIENTS OF EXPANSION ALPHA-VECTOR        
C        
      DO 1410 LL = 1,3        
      ALPHA(LL) = Z(IPOINT+13+LL)        
 1410 CONTINUE        
C        
C     ELEMENT TEMPERATURE        
C        
      DELT = TBAR - TSUBO        
C        
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 1420        
      IF (.NOT.TEMPP1) GO TO 1420        
C        
C     TEMPERATURE GRADIENT TPRIME        
C        
      DELT = DELT + ZSUBI*TPRIME        
C        
 1420 DO 1430 LL = 1,3        
      EPSLNT(LL) = -ALPHA(LL)*DELT        
 1430 CONTINUE        
C        
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 1450        
      IF (.NOT.TEMPP2) GO TO 1450        
C        
C     COMPUTE STRAIN DUE TO THERMAL MOMENTS        
C        
      DO 1440 LL = 1,3        
      EPSLNT(LL) = EPSLNT(LL) + (EZEROT(LL) + ZSUBI*EZEROT(LL+3))       
 1440 CONTINUE        
C        
C     COMBINE MECHANICAL AND THERMAL STRAINS        
C        
 1450 DO 1460 LL = 1,3        
      EPSLN(LL) = EPSLN(LL) + EPSLNT(LL)        
 1460 CONTINUE        
C        
 1470 CONTINUE        
C        
C     CALCULATE STRESS VECTOR STRESL IN FIBRE COORD SYS        
C        
C     STRESL-VECTOR  =  G-MATRIX  X  EPSLN-VECTOR        
C        
      CALL GMMATS (Z(IPOINT+1),3,3,0, EPSLN,3,1,0, STRESL(1))        
C        
C     USE FORCE RESTULANTS CALCULATED PREVIOUSLY        
C     I.E. AT EXTREME FIBER STATIONS EXCEPT FOR THERMAL LOADING CASES   
C        
      IF (LDTEMP .EQ. -1) GO TO 1490        
      IF (KFORCE .EQ.  0) GO TO 1490        
C        
C     TRANSFORM LAYER STRESSES TO ELEMENT AXIS        
C        
      IF (THETAE .GT. 0.0) THETA = THETA + THETAE        
C        
C     BUILD STRESS TRANSFORMATION MATRIX        
C        
      C   = COS(THETA)        
      C2  = C*C        
      S   = SIN(THETA)        
      S2  = S*S        
C        
      TRANS(1)  = C2        
      TRANS(2)  = S2        
      TRANS(3)  =-2.0*C*S        
      TRANS(4)  = S2        
      TRANS(5)  = C2        
      TRANS(6)  = 2.0*C*S        
      TRANS(7)  = C*S        
      TRANS(8)  =-C*S        
      TRANS(9)  = C2-S2        
C        
      CALL GMMATS (TRANS(1),3,3,0, STRESL(1),3,1,0, STRESE(1))        
C        
      DO 1480 IR = 1,3        
      FORSUL(IR) = FORSUL(IR) + STRESE(IR)*TI        
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 1480        
      FORSUL(IR+3) = FORSUL(IR+3) - STRESE(IR)*TI*ZSUBI        
 1480 CONTINUE        
C        
 1490 IF (FTHR .LE. 0) GO TO 1530        
C        
C     WRITE ULTIMATE STRENGTH VALUES TO ULTSTN        
C        
      DO 1500 IR = 1,6        
 1500 ULTSTN(IR) = Z(IPOINT+16+IR)        
C        
C     CALL FTHR TO COMPUTE FAILURE INDEX FOR PLY        
C        
      IF (FTHR .EQ. STRAIN) GO TO 1510        
      CALL FAILUR (FTHR,ULTSTN,STRESL,FINDEX)        
      GO TO 1520        
C        
 1510 CALL FAILUR (FTHR,ULTSTN,EPSLN,FINDEX)        
C        
C     DETERMINE THE MAX FAILURE INDEX        
C        
 1520 IF (ABS(FINDEX) .GE. ABS(FPMAX)) FPMAX = FINDEX        
C        
 1530 CONTINUE        
C        
C     SET POINTERS        
C        
      IF (ITYPE .EQ. PCOMP) ICONTR = IPOINT + 25        
      IF (ITYPE.EQ.PCOMP1 .OR. ITYPE.EQ.PCOMP2)        
     1    ICONTR = IPOINT + 23 + 2*K        
C        
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 1570        
      IF (.NOT.TRNFLX) GO TO 1570        
C        
C     CALCULATE INTERLAMINAR SHEAR STRESSES        
C        
      DO 1540 IR = 1,2        
      TRNAR(IR) = TRNAR(IR) + (Z(ICONTR+IR))*TI*(ZBAR(IR)-ZSUBI)        
 1540 CONTINUE        
C        
C     THE INTERLAMINAR SHEAR STRESSES AT STN ZSUBI        
C        
      DO 1550 IR = 1,2        
      TRNSHR(IR) = V(IR)*TRNAR(IR)/EI(IR)        
 1550 CONTINUE        
C        
C     CALCULATE SHEAR BONDING FAILURE INDEX FB        
C     NOTE- SB IS ALWAYS POSITIVE        
C        
      IF (SB .EQ. 0.0) GO TO 1570        
C        
      DO 1560 IR = 1,2        
      FB(IR) = ABS(TRNSHR(IR))/SB        
 1560 CONTINUE        
C        
      FBOND = FB(1)        
      IF (FB(2) .GT. FB(1)) FBOND = FB(2)        
C        
C     CALCULATE MAX SHEAR BONDING INDEX        
C        
      IF (FBOND .GE. FBMAX) FBMAX = FBOND        
C        
 1570 CONTINUE        
C        
      IF (KSTRS .EQ. 0) GO TO 1590        
C        
C     WRITE TO OUTPUT FILE THE FOLLOWING        
C       4.    PLY (OR LAYER) ID        
C     5,6,7.  LAYER STRESSES        
C       8.    LAYER FAILURE INDEX        
C       9.    IFLAG (= 1 IF FP.GE.0.999, DEFAULT = 0)        
C     10,11.  INTERLAMINAR SHEAR STRESSES        
C      12.    SHEAR BONDING FAILURE INDEX        
C      13.    IFLAG (= 1 IF SB.GE.0.999, DEFAULT = 0)        
C        
C     CHECK LAYER STRESS OUTPUT REQUEST (SOUTI) FOR PCOMP BULK DATA     
C     (NOT SUPPORTED FOR PCOMP1 OR PCOMP2 BULK DATA)        
C        
      IF (ITYPE .NE. PCOMP) GO TO 1580        
      SOUTI = INTZ(PIDLOC+8+4*K)        
      IF (SOUTI .EQ. 0) GO TO 1590        
 1580 PLYID = K        
C        
C     == 4.        
C        
      CALL WRITE (OES1L,PLYID,1,0)        
C        
C     == 5,6,7.        
C        
      CALL WRITE (OES1L,STRESL(1),3,0)        
C        
C     == 8.        
C        
      CALL WRITE (OES1L,FINDEX,1,0)        
C        
C     SET IFLAG        
C        
      IFLAG = 0        
      IF (ABS(FINDEX) .GE. 0.999) IFLAG = 1        
C        
C     == 9.        
C        
      CALL WRITE (OES1L,IFLAG,1,0)        
C        
C     == 10,11.        
C        
      CALL WRITE (OES1L,TRNSHR(1),2,0)        
C        
C     == 12.        
C        
      CALL WRITE (OES1L,FBOND,1,0)        
C        
C     SET IFLAG        
C        
      IFLAG = 0        
      IF (ABS(FBOND) .GE. 0.999) IFLAG = 1        
C        
C     == 13.        
C        
      CALL WRITE (OES1L,IFLAG,1,0)        
C        
C        
C     UPDATE IPOINT FOR PCOMP BULK DATA ENTRY        
C        
 1590 IF (ITYPE.EQ.PCOMP .AND. K.NE.NLAY) IPOINT = IPOINT + 27        
C        
 1600 CONTINUE        
C        
C     FALL HERE IF SYMMETRIC OPTION HAS BEEN EXERCISED        
C        
      IF (LAMOPT.NE.SYM .AND. LAMOPT.NE.SYMMEM) GO TO 2000        
C        
C     LOOP OVER SYMMETRIC LAYERS        
C        
      DO 1900 KK = 1,NLAY        
      K = NLAY + 1 - KK        
C        
C     ZSUBI -DISTANCE FROM REFERENCE SURFACE TO MID OF LAYER K        
C        
      ZK1 = ZK        
      IF (ITYPE .EQ. PCOMP ) ZK = ZK1 + Z(PIDLOC+6+4*K)        
      IF (ITYPE .EQ. PCOMP1) ZK = ZK1 + Z(PIDLOC+7    )        
      IF (ITYPE .EQ. PCOMP2) ZK = ZK1 + Z(PIDLOC+7+2*K)        
C        
      ZSUBI = (ZK+ZK1)/2.0        
C        
C     LAYER THICKNESS        
C        
      TI = ZK - ZK1        
C        
C     CALCULATE STRAIN VECTOR AT STN ZSUBI        
C        
      DO 1700 IR = 1,3        
      EPSLNE(IR) = (.5-ZSUBI/TLAM)*EPSB(IR) + (.5+ZSUBI/TLAM)*EPST(IR)  
 1700 CONTINUE        
C        
C     LAYER ORIENTATION        
C        
      IF (ITYPE .EQ. PCOMP ) THETA = Z(PIDLOC+7+4*K)        
      IF (ITYPE .EQ. PCOMP1) THETA = Z(PIDLOC+8+  K)        
      IF (ITYPE .EQ. PCOMP2) THETA = Z(PIDLOC+8+2*K)        
C        
C     BUILD TRANS-MATRIX TO TRANSFORM LAYER STRAINS FROM MATERIAL       
C     TO FIBRE DIRECTION.        
C        
      THETA = THETA*DEGRAD        
      C   = COS(THETA)        
      C2  = C*C        
      S   = SIN(THETA)        
      S2  = S*S        
C        
      TRANS(1)  = C2        
      TRANS(2)  = S2        
      TRANS(3)  = C*S        
      TRANS(4)  = S2        
      TRANS(5)  = C2        
      TRANS(6)  =-C*S        
      TRANS(7)  =-2.0*C*S        
      TRANS(8)  = 2.0*C*S        
      TRANS(9)  = C2 - S2        
C        
C     TRANSFORM STRAINS FROM MATERIAL TO FIBRE COORD SYSTEM        
C        
      CALL GMMATS (TRANS(1),3,3,0, EPSLNE(1),3,1,0, EPSLN(1))        
C        
C     SWITCH FOR TEMPERATURE EFFECTS        
C        
      IF (LDTEMP .EQ. -1) GO TO 1770        
C        
C     CORRECT LAYER STRAIN VECTOR FOR THERMAL EFFECTS        
C        
C     LAYER THERMAL COEFFICIENTS OF EXPANSION ALPHA-VECTOR        
C        
      DO 1710 LL = 1,3        
      ALPHA(LL) = Z(IPOINT+13+LL)        
 1710 CONTINUE        
C        
C     ELEMENT TEMPERATURE        
C        
      DELT = TBAR - TSUBO        
      IF (LAMOPT .EQ. SYMMEM) GO TO 1720        
      IF (.NOT.TEMPP1) GO TO 1720        
C        
C     TEMPERATURE GRADIENT TPRIME        
C        
      DELT = DELT + ZSUBI*TPRIME        
C        
 1720 DO 1730 LL = 1,3        
      EPSLNT(LL) = -ALPHA(LL)*DELT        
 1730 CONTINUE        
C        
      IF (LAMOPT .EQ. SYMMEM) GO TO 1750        
      IF (.NOT.TEMPP2) GO TO 1750        
C        
C     COMPUTE STRAIN DUE TO THERMAL MOMENTS        
C        
      DO 1740 LL = 1,3        
      EPSLNT(LL) = EPSLNT(LL) + (EZEROT(LL) + ZSUBI*EZEROT(LL+3))       
 1740 CONTINUE        
C        
C     COMBINE MECHANICAL AND THERMAL STRAINS        
C        
 1750 DO 1760 LL = 1,3        
      EPSLN(LL)  = EPSLN(LL) + EPSLNT(LL)        
 1760 CONTINUE        
C        
 1770 CONTINUE        
C        
C     CALCULATE STRESS VECTOR STRESL IN FIBRE COORD SYS        
C        
C     STRESL-VECTOR =  G-MATRIX  X  EPSLN-VECTOR        
C        
      CALL GMMATS (Z(IPOINT+1),3,3,0, EPSLN,3,1,0, STRESL(1))        
C        
C     COMPUTE FORCE RESULTANTS IF REQUESTED        
C        
      IF (LDTEMP .EQ. -1) GO TO 1790        
      IF (KFORCE .EQ.  0) GO TO 1790        
C        
C     TRANSFORM LAYER STRESSES TO ELEMENT AXIS        
C        
      IF (THETAE .GT. 0.0) THETA = THETA + THETAE        
C        
C     BUILD STRESS TRANSFORMATION MATRIX        
C        
      C   = COS(THETA)        
      C2  = C*C        
      S   = SIN(THETA)        
      S2  = S*S        
C        
      TRANS(1)  = C2        
      TRANS(2)  = S2        
      TRANS(3)  =-2.0*C*S        
      TRANS(4)  = S2        
      TRANS(5)  = C2        
      TRANS(6)  = 2.0*C*S        
      TRANS(7)  = C*S        
      TRANS(8)  =-C*S        
      TRANS(9)  = C2 - S2        
C        
      CALL GMMATS (TRANS(1),3,3,0, STRESL(1),3,1,0, STRESE(1))        
C        
      DO 1780 IR = 1,3        
      FORSUL(IR) = FORSUL(IR) + STRESE(IR)*TI        
      IF (LAMOPT .EQ. SYMMEM) GO TO 1780        
      FORSUL(IR+3) = FORSUL(IR+3) - STRESE(IR)*TI*ZSUBI        
 1780 CONTINUE        
C        
 1790 IF (FTHR .LE. 0) GO TO 1830        
C        
C     WRITE ULTIMATE STRENGTH VALUES TO ULTSTN        
C        
      DO 1800 IR = 1,6        
 1800 ULTSTN(IR) = Z(IPOINT+16+IR)        
C        
C     CALL FTHR TO COMPUTE FAILURE INDEX FOR PLY        
C        
      IF (FTHR .EQ. STRAIN) GO TO 1810        
      CALL FAILUR (FTHR,ULTSTN,STRESL,FINDEX)        
      GO TO 1820        
C        
 1810 CALL FAILUR (FTHR,ULTSTN,EPSLN,FINDEX)        
C        
C     DETERMINE THE MAX FAILURE INDEX        
C        
 1820 IF (ABS(FINDEX) .GE. ABS(FPMAX)) FPMAX = FINDEX        
C        
 1830 CONTINUE        
C        
C     SET POINTERS        
C        
      IF (ITYPE .EQ. PCOMP) ICONTR = IPOINT + 25        
      IF (ITYPE.EQ.PCOMP1 .OR. ITYPE.EQ.PCOMP2)        
     1    ICONTR = IPOINT + 23 + 2*K        
C        
      IF (LAMOPT .EQ. SYMMEM) GO TO 1870        
      IF (.NOT.TRNFLX) GO TO 1870        
C        
C     CALCULATE INTERLAMINAR SHEAR STRESSES        
C        
      DO 1840 IR = 1,2        
      TRNAR(IR) = TRNAR(IR) + (Z(ICONTR+IR))*TI*(ZBAR(IR)-ZSUBI)        
 1840 CONTINUE        
C        
C     THE INTERLAMINAR SHEAR STRESSES AT STN ZSUBI        
C        
      DO 1850 IR = 1,2        
      TRNSHR(IR) = V(IR)*TRNAR(IR)/EI(IR)        
 1850 CONTINUE        
C        
C     CALCULATE SHEAR BONDING FAILURE INDEX FB        
C     NOTE- SB IS ALWAYS POSITIVE        
C        
      IF (SB .EQ. 0.0) GO TO 1870        
C        
      DO 1860 IR = 1,2        
      FB(IR) = ABS(TRNSHR(IR))/SB        
 1860 CONTINUE        
C        
      FBOND = FB(1)        
      IF (FB(2) .GT. FB(1)) FBOND = FB(2)        
C        
C     CALCULATE MAX SHEAR BONDING INDEX        
C        
      IF (FBOND .GE. FBMAX) FBMAX = FBOND        
C        
 1870 CONTINUE        
C        
      IF (KSTRS .EQ. 0) GO TO 1890        
C        
C     WRITE TO OUTPUT FILE THE FOLLOWING        
C       4.     PLY (OR LAYER) ID        
C     5,6,7.   LAYER STRESSES        
C       8.     LAYER FAILURE INDEX        
C       9.     IFLAG (= 1 IF FP.GE.0.999, DEFAULT = 0)        
C     10,11.   INTERLAMINAR SHEAR STRESSES        
C      12.     SHEAR BONDING FAILURE INDEX        
C      13.     IFLAG (= 1 IF SB.GE.0.999, DEFAULT = 0)        
C        
C     CHECK LAYER STRESS OUTPUT REQUEST (SOUTI) FOR PCOMP BULK DATA     
C     (NOT SUPPORTED FOR PCOMP1 OR PCOMP2 BULK DATA)        
C        
      IF (ITYPE .NE. PCOMP) GO TO 1880        
      SOUTI = INTZ(PIDLOC+8+4*K)        
      IF (SOUTI .EQ. 0) GO TO 1890        
 1880 PLYID = NLAY + KK        
C        
C     == 4.        
C        
      CALL WRITE (OES1L,PLYID,1,0)        
C        
C     == 5,6,7        
C        
      CALL WRITE (OES1L,STRESL(1),3,0)        
C        
C     == 8.        
C        
      CALL WRITE (OES1L,FINDEX,1,0)        
C        
C     SET IFLAG        
C        
      IFLAG = 0        
      IF (ABS(FINDEX) .GE. 0.999) IFLAG = 1        
C        
C     == 9.        
C        
      CALL WRITE (OES1L,IFLAG,1,0)        
C        
C     == 10,11.        
C        
      CALL WRITE (OES1L,TRNSHR(1),2,0)        
C        
C     == 12.        
C        
      CALL WRITE (OES1L,FBOND,1,0)        
C        
C     SET IFLAG        
C        
      IFLAG = 0        
      IF (ABS(FBOND) .GE. 0.999) IFLAG = 1        
C        
C     == 13.        
C        
      CALL WRITE (OES1L,IFLAG,1,0)        
C        
C     UPDATE IPOINT FOR PCOMP BULK DATA ENTRY        
C        
 1890 IF (ITYPE .EQ. PCOMP) IPOINT = IPOINT - 27        
 1900 CONTINUE        
C        
 2000 IF (FTHR .LE. 0) GO TO 2010        
C        
C     DETERMINE 'FIMAX' THE MAX FAILURE INDEX FOR THE LAMINATE        
C        
      FIMAX = FPMAX        
      IF (FBMAX .GT. ABS(FPMAX)) FIMAX = FBMAX        
C        
C     == LAST-1.        
C        
 2010 IF (KSTRS .EQ. 1) CALL WRITE (OES1L,FIMAX,1,0)        
C        
      IFLAG = 0        
      IF (ABS(FIMAX) .GE. 0.999) IFLAG = 1        
C        
C     == LAST.        
C        
      IF (KSTRS .EQ. 1) CALL WRITE (OES1L,IFLAG,1,0)        
C        
      IF (KFORCE .EQ.  0) GO TO 2100        
      IF (LDTEMP .EQ. -1) GO TO 2100        
      CALL WRITE (OEF1L,ELEMID,1,0)        
      CALL WRITE (OEF1L,FORSUL(1),6,0)        
      CALL WRITE (OEF1L,FORSUL(45),2,0)        
C        
 2100 RETURN        
C        
C     ERROR MESSAGES        
C        
 2200 WRITE  (NOUT,2210) UWM        
 2210 FORMAT (A25,' - NO PCOMP, PCOMP1 OR PCOMP2 DATA AVAILABLE FOR ',  
     1       'LAYER STRESS RECOVERY BY SUBROUTINE SQUD42.')        
      GO TO 2100        
 2220 WRITE  (NOUT,2230) UFM        
 2230 FORMAT (A23,', LAYER STRESS OR FORCE RECOVERY WAS REQUESTED WHILE'
     1,      ' PROBLEM WAS NOT SET UP FOR', /5X,'LAYER COMPUTATION')    
      CALL MESAGE (-61,0,0)        
      END        
