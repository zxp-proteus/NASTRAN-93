      SUBROUTINE TRIA3D        
C        
C     DOUBLE PRECISION ROUTINE TO FORM STIFFNESS, MASS, AND DAMPING     
C     MATRICES FOR THE CTRIA3 ELEMENT        
C        
C                 EST  LISTING        
C        
C        WORD     TYP       DESCRIPTION        
C     ----------------------------------------------------------------  
C     ECT:        
C         1        I   ELEMENT ID, EID        
C         2-4      I   SIL LIST, GRIDS 1,2,3        
C         5-7      R   MEMBRANE THICKNESSES T, AT GRIDS 1,2,3        
C         8        R   MATERIAL PROPERTY ORIENTAION ANGLE, THETA        
C               OR I   COORD. SYSTEM ID (SEE TM ON CTRIA3 CARD)        
C         9        I   TYPE FLAG FOR WORD 8        
C        10        R   GRID OFFSET, ZOFF        
C    EPT:        
C        11        I   MATERIAL ID FOR MEMBRANE, MID1        
C        12        R   ELEMENT THICKNESS,T (MEMBRANE, UNIFORMED)        
C        13        I   MATERIAL ID FOR BENDING, MID2        
C        14        R   MOMENT OF INERTIA FACTOR, I (BENDING)        
C        15        I   MATERIAL ID FOR TRANSVERSE SHEAR, MID3        
C        16        R   TRANSV. SHEAR CORRECTION FACTOR, TS/T        
C        17        R   NON-STRUCTURAL MASS, NSM        
C        18-19     R   STRESS FIBER DISTANCES, Z1,Z2        
C        20        I   MATERIAL ID FOR MEMBRANE-BENDING COUPLING, MID4  
C        21        R   MATERIAL ANGLE OF ROTATION, THETA        
C               OR I   COORD. SYSTEM ID (SEE MCSID ON PSHELL CARD)      
C                      (DEFAULT FOR WORD 8)        
C        22        I   TYPE FLAG FOR WORD 21 (DEFAULT FOR WORD 9)       
C        23        I   INTEGRATION ORDER FLAG        
C        24        R   STRESS ANGLE OF RATATION, THETA        
C               OR I   COORD. SYSTEM ID (SEE SCSID ON PSHELL CARD)      
C        25        I   TYPE FLAG FOR WORD 24        
C        26        R   OFFSET, ZOFF1 (DEFAULT FOR WORD 10)        
C    BGPDT:        
C        27-38   I/R   CID,X,Y,Z  FOR GRIDS 1,2,3        
C    ETT:        
C        39        I   ELEMENT TEMPERATURE        
C        
C        
      LOGICAL          HEAT,NOALFA,NEEDK,NEEDM,SHEART,        
     1                 MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH        
      INTEGER          SYSBUF,NOUT,NOGO,PREC,HUNMEG,NEST(39),NAME(2),   
     1                 NECPT(4),DICT(11),IGPDT(4,3),ELID,ESTID,DMAT,    
     2                 SIL(3),IORDER(3),CPMASS,MID(4),TYPE,INDEX(3,3)   
      REAL             BGPDT(4,3),GPTH(3),NSM,ECPT(4),KHEAT,HTCP        
      DOUBLE PRECISION AMGG(1),AKGG(1),ALPHA(1),THETAM,CENTE(3),        
     1                 DGPTH(3),EGPDT(4,3),EPNORM(4,3),GPNORM(4,3),     
     2                 AREA,WTSTIF,WTMASS,RHO,XMASS(9),XMASSO,LX,LY,    
     3                 EPS,OFFSET,SHPT(3),WEIGHT,G(9,9),GI(36),K11,K22, 
     4                 JOK,JOG,ZZ(9),AIC(18),EGNOR(4),EDGLEN(3),        
     5                 BMTRX(54),BMATRX(162),BTERMS(6),BMAT1(486),      
     6                 AVGTHK,MOMINR,TS,TH,REALI,TSI,TSM,BDUM(3),       
     7                 DETERM,DETJAC,TBG(9),TEB(9),TEM(9),TEU(9),       
     8                 TUB(9),TUM(9),TOTTRN(324),TRANSK(324),TRANS(27), 
     9                 TMPTRN(36),HTFLX(18),HTCAP(36),HTCON(36),        
     O                 DHEAT,WEITC,DVOL        
      COMMON /SYSTEM/  SYSBUF,NOUT,NOGO,IDUM(51),PREC        
      COMMON /MATIN /  MATID,INFLAG,ELTEMP,DUMMY,SINMAT,COSMAT        
      COMMON /HMTOUT/  KHEAT(7),TYPE        
      COMMON /TERMS /  MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH        
      COMMON /EMGPRM/  ICORE,JCORE,NCORE,ICSTM,NCSTM,IMAT,NMAT,IHMAT,   
     1                 NHMAT,IDIT,NDIT,ICONG,NCONG,LCONG,ANYCON,        
     2                 KGG1,MGG1,IBGG1,PRECIS,ERROR,HEAT,CPMASS,        
     3                 DUMM6(6),L38        
      COMMON /EMGEST/  EST(39)        
      COMMON /EMGDIC/  ELTYPE,LDICT,NLOCS,ELID,ESTID        
CZZ   COMMON /ZZEMGX/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      EQUIVALENCE      (EST( 1),NEST(1)), (EST( 2),SIL(1)),        
     1                 (EST( 5),GPTH(1)), (EST(10),ZOFF),        
     2                 (EST(12),ELTH)   , (EST(17),NSM),        
     3                 (EST(23),INT)    , (EST(26),ZOFF1),        
     4                 (EST(27),BGPDT(1,1),IGPDT(1,1)),        
     5                 (EST(39),TEMPEL) , (DICT(5),ADAMP),        
     6                 (NECPT(1),ECPT(1)),(Z(1),AMGG(1),AKGG(1)),       
     7                 (KHEAT(4),HTCP)  , (HTCAP(1),XMASS(1))        
      DATA     HUNMEG, EPS / 100000000, 1.0D-7 /        
      DATA     NAME  , KMAT, MMAT, DMAT / 4HCTRI,4HA3  , 1, 2, 3 /      
C        
C     INITIALIZE        
C        
      ELID   = NEST(1)        
      NNODE  = 3        
      MOMINR = 0.0D0        
      TS     = 0.0D0        
      WEIGHT = 1.0D0/6.0D0        
      ELTEMP = TEMPEL        
      NEEDK  = KGG1.NE.0 .OR. IBGG1.NE.0        
      NOALFA = .TRUE.        
      SHEART = .TRUE.        
      IEOE   = 1        
      OFFSET = ZOFF        
      IF (ZOFF .EQ. 0.0) OFFSET = ZOFF1        
C        
C     CHECK FOR SUFFICIENT OPEN CORE FOR ELEMENT STIFFNESS        
C        
C     OPEN CORE BEGINS AT JCORE        
C     OPEN CORE ENDS   AT NCORE        
C     LENGTH OF AVAILABLE WORDS = (NCORE-JCORE-1)/PREC        
C        
      JCORED = JCORE/PREC + 1        
      LENGTH = (NCORE-JCORE-1)/PREC        
      IF (LENGTH.LT.324 .AND. (.NOT.HEAT .AND. NEEDK)) GO TO 1100       
C        
C     SET UP THE ELEMENT FORMULATION        
C        
      CALL T3SETD (IERR,SIL,IGPDT,ELTH,GPTH,DGPTH,EGPDT,GPNORM,EPNORM,  
     1             IORDER,TEB,TUB,CENTE,AVGTHK,LX,LY,EDGLEN,ELID)       
      IF (IERR .NE. 0) GO TO 1110        
      CALL GMMATD (TEB,3,3,0, TUB,3,3,1, TEU)        
      AREA = LX*LY/2.0D0        
C        
C     SET THE NUMBER OF DOF'S        
C        
      NNOD2 = NNODE*NNODE        
      NDOF  = NNODE*6        
      NPART = NDOF*NDOF        
      ND2   = NDOF*2        
      ND6   = NDOF*6        
      ND7   = NDOF*7        
      ND8   = NDOF*8        
      ND9   = NDOF*9        
      JEND  = JCORED + NPART - 1        
C        
C     OBTAIN MATERIAL INFORMATION        
C        
C     PASS THE LOCATION OF THE ELEMENT CENTER FOR MATERIAL        
C     TRANSFORMATIONS.        
C        
      DO 100 IEC = 2,4        
      ECPT(IEC) = CENTE(IEC-1)        
  100 CONTINUE        
C        
C     SET MATERIAL FLAGS        
C     5.0D0/6.0D0 = 0.833333333D0        
C        
      IF (NEST(13) .NE.   0) MOMINR = EST(14)        
      IF (NEST(13) .NE.   0) TS = EST(16)        
      IF ( EST(16) .EQ. 0.0) TS = 0.833333333D0        
      IF (NEST(13).EQ.0 .AND. NEST(11).GT.HUNMEG) TS = 0.833333333D0    
C        
      MID(1) = NEST(11)        
      MID(2) = NEST(13)        
      MID(3) = NEST(15)        
      MID(4) = NEST(20)        
C        
      MEMBRN = MID(1).GT.0        
      BENDNG = MID(2).GT.0 .AND. MOMINR.GT.0.0D0        
      SHRFLX = MID(3).GT.0        
      MBCOUP = MID(4).GT.0        
      NORPTH = MID(1).EQ.MID(2) .AND. MID(1).EQ.MID(3) .AND. MID(4).EQ.0
     1         .AND. DABS(MOMINR-1.0D0).LE.EPS        
C        
C     SET UP TRANSFORMATION MATRIX FROM MATERIAL TO ELEMENT COORD.SYSTEM
C        
      CALL SHCSGD (*1120,NEST(9),NEST(8),NEST(8),NEST(21),NEST(20),     
     1             NEST(20),NECPT,TUB,MCSID,THETAM,TUM)        
C        
C     BRANCH ON FORMULATION TYPE.        
C        
      IF (HEAT) GO TO 800        
C        
C     FETCH MATERIAL PROPERTIES        
C        
      CALL GMMATD (TEU,3,3,0,TUM,3,3,0,TEM)        
      CALL SHGMGD (*1130,ELID,TEM,MID,TS,NOALFA,GI,RHO,GSUBE,TSUB0,     
     1             EGNOR,ALPHA)        
C        
C     TURN OFF THE COUPLING FLAG WHEN MID4 IS PRESENT WITH ALL        
C     CALCULATED ZERO TERMS.        
C        
      IF (.NOT.MBCOUP) GO TO 120        
      DO 110 I = 28,36        
      IF (DABS(GI(I)) .GT. EPS) GO TO 120        
  110 CONTINUE        
      MBCOUP = .FALSE.        
C        
C     GET THE GEOMETRY CORRECTION TERMS        
C        
  120 IF (.NOT.BENDNG) GO TO 130        
      CALL T3GEMD (IERR,EGPDT,IORDER,GI(10),GI(19),LX,LY,EDGLEN,SHRFLX, 
     1             AIC,JOG,JOK,K11,K22)        
      IF (IERR .NE. 0) GO TO 1110        
C        
C     REDUCED INTEGRATION LOOP FOR STIFFNESS        
C        
  130 IF (.NOT.NEEDK .OR. INT.NE.0) GO TO 160        
C        
C     DETERMINE THE AVERAGE B-MATRIX FOR OUT-OF-PLANE SHEAR        
C        
      DO 140 IPT = 1,3        
      KPT = (IPT-1)*ND9 + 1        
      CALL T3BMGD (IERR,SHEART,IPT,IORDER,EGPDT,DGPTH,AIC,TH,DETJAC,    
     1             SHPT,BTERMS,BMAT1(KPT))        
      IF (IERR .NE. 0) GO TO 1110        
  140 CONTINUE        
C        
      DO 150 I = 1,NDOF        
      BMTRX(I     ) = BMAT1(I+ND6) +BMAT1(I+ND6+ND9) +BMAT1(I+ND6+2*ND9)
      BMTRX(I+NDOF) = BMAT1(I+ND7) +BMAT1(I+ND7+ND9) +BMAT1(I+ND7+2*ND9)
      BMTRX(I+ND2 ) = BMAT1(I+ND8) +BMAT1(I+ND8+ND9) +BMAT1(I+ND8+2*ND9)
  150 CONTINUE        
C        
C     INITIALIZE FOR THE MAIN INTEGRATION LOOP        
C        
  160 NEEDM = MGG1.NE.0 .AND. (NSM.GT.0.0 .OR. RHO.GT.0.0D0)        
      IF (.NOT.NEEDK .AND. .NOT.NEEDM) GO TO 200        
      DO 170 I = JCORED,JEND        
      AKGG(I) = 0.0D0        
  170 CONTINUE        
C        
      DO 180 I = 1,9        
      XMASS(I) = 0.0D0        
  180 CONTINUE        
C        
C     MAIN INTEGRATION LOOP        
C        
  200 DO 500 IPT = 1,3        
C        
      CALL T3BMGD (IERR,SHEART,IPT,IORDER,EGPDT,DGPTH,AIC,TH,DETJAC,    
     1             SHPT,BTERMS,BMATRX)        
      IF (IERR .NE. 0) GO TO 1110        
C        
C     PERFORM STIFFNESS CALCULATIONS IF REQUIRED        
C        
      IF (.NOT.NEEDK) GO TO 400        
      WTSTIF = DETJAC*WEIGHT        
      REALI  = MOMINR*TH*TH*TH/12.0D0        
      TSI = TS*TH        
C        
      IF (INT .NE. 0) GO TO 220        
      DO 210 IX = 1,NDOF        
      BMATRX(IX+ND6) = BMTRX(IX     )        
      BMATRX(IX+ND7) = BMTRX(IX+NDOF)        
      BMATRX(IX+ND8) = BMTRX(IX+ND2 )        
  210 CONTINUE        
C        
C     FILL IN THE 9X9 G-MATRIX        
C        
  220 DO 240 IG = 1,81        
  240 G(IG,1) = 0.0D0        
C        
      IF (.NOT.MEMBRN) GO TO 270        
      DO 260 IG = 1,3        
      IG1 = (IG-1)*3        
      DO 250 JG = 1,3        
      G(IG,JG) = GI(IG1+JG)*TH*WTSTIF        
  250 CONTINUE        
  260 CONTINUE        
C        
  270 IF (.NOT.BENDNG) GO TO 340        
      DO 290 IG = 4,6        
      IG2 = (IG-2)*3        
      DO 280 JG = 4,6        
      G(IG,JG) = GI(IG2+JG)*REALI*WTSTIF        
  280 CONTINUE        
  290 CONTINUE        
C        
      TSM   = 1.0D0/(2.0D0*12.0D0*REALI)        
      ZZ(1) = (JOG/TSI)* GI(22) + TSM*JOK*K22        
      ZZ(2) =-(JOG/TSI)*(GI(20) + GI(21))/2.0D0        
      ZZ(3) = 0.0D0        
      ZZ(4) = ZZ(2)        
      ZZ(5) = (JOG/TSI)* GI(19) + TSM*JOK*K11        
      ZZ(6) = 0.0D0        
      ZZ(7) = 0.0D0        
      ZZ(8) = 0.0D0        
      ZZ(9) = (JOG/TSI)*(GI(22) + GI(19))/2.0D0        
     1      + TSM*12.0D0*AREA/DSQRT(GI(10)*GI(14))        
      CALL INVERD (3,ZZ,3,BDUM,0,DETERM,ISING,INDEX)        
      IF (ISING .NE. 1) GO TO 1110        
C        
      DO 310 IG = 7,9        
      IG3 = (IG-7)*3        
      DO 300 JG = 7,9        
      G(IG,JG) = ZZ(IG3+JG-6)*WTSTIF        
  300 CONTINUE        
  310 CONTINUE        
C        
      IF (.NOT.MBCOUP) GO TO 340        
      DO 330 IG = 1,3        
      IG4 = (IG+8)*3        
      DO 320 JG = 1,3        
      G(IG,JG+3) = GI(IG4+JG)*TH*TH*WTSTIF        
      G(IG+3,JG) = G(IG,JG+3)        
  320 CONTINUE        
  330 CONTINUE        
C        
C     COMPUTE THE CONTRIBUTION TO THE STIFFNESS MATRIX FROM THIS        
C     INTEGRATION POINT.        
C        
  340 CALL T3BGBD (9,NDOF,G,BMATRX,AKGG(JCORED))        
C        
C        
C     END OF STIFFNESS CALCULATIONS.        
C     SKIP MASS CALCULATIONS IF NOT REQUIRED        
C        
C        
  400 IF (.NOT.NEEDM) GO TO 500        
      WTMASS = (RHO*TH+NSM)*DETJAC*WEIGHT        
      IF (CPMASS .LE. 0) GO TO 430        
C        
C     CONSISTENT MASS FORMULATION (OPTION)        
C        
      DO 420 I = 1,NNODE        
      II = (I-1)*NNODE        
      DO 410 J = 1,NNODE        
      XMASS(II+J) = XMASS(II+J) + SHPT(I)*SHPT(J)*WTMASS        
  410 CONTINUE        
  420 CONTINUE        
      GO TO 500        
C        
C     LUMPED MASS FORMULATION (DEFAULT)        
C        
  430 I3 = 1        
      DO 440 I = 1,NNODE        
      XMASS(I3) = XMASS(I3) + SHPT(I)*WTMASS        
      I3 = I3 + 1 + NNODE        
  440 CONTINUE        
C        
C     END OF MAIN INTEGRATION LOOP        
C        
  500 CONTINUE        
C        
C     PICK UP THE ELEMENT TO GLOBAL TRANSFORMATION FOR EACH NODE.       
C        
      DO 510 I = 1,NNODE        
      IPOINT = 9*(I-1) + 1        
      CALL TRANSD (IGPDT(1,I),TBG)        
      CALL GMMATD (TEB,3,3,0, TBG,3,3,0, TRANS(IPOINT))        
  510 CONTINUE        
C        
C     SHIP OUT THE STIFFNESS AND DAMPING MATRICES        
C        
      IF (.NOT.NEEDK) GO TO 600        
C        
      DICT(1) = ESTID        
      DICT(2) = 1        
      DICT(3) = NDOF        
      DICT(4) = 63        
      ADAMP   = GSUBE        
C        
C     BUILD THE 18X18 TRANSFORMATION MATRIX FOR ONE-SHOT MULTIPLY       
C        
      DO 520 I = 1,NPART        
      TRANSK(I) = 0.0D0        
      TOTTRN(I) = 0.0D0        
  520 CONTINUE        
C        
      NDOF66 = 6*NDOF + 6        
      II = 1        
      DO 550 I = 1,NPART,NDOF66        
      CALL TLDRD (OFFSET,II,TRANS,TMPTRN)        
      DO 540 JJ = 1,36,6        
      J  = JJ - 1        
      KK = I - 1 + J*NNODE        
      DO 530 K = 1,6        
      TOTTRN(KK+K) = TMPTRN(J+K)        
  530 CONTINUE        
  540 CONTINUE        
  550 II = II + 1        
C        
C     PERFORM THE TRIPLE MULTIPLY.        
C        
      CALL MPYA3D (TOTTRN,AKGG(JCORED),NDOF,6,TRANSK)        
C        
      CALL EMGOUT (TRANSK,TRANSK,NPART,IEOE,DICT,KMAT,PREC)        
C        
C     SHIP OUT THE MASS MATRIX        
C        
  600 IF (.NOT.NEEDM) GO TO 730        
      NDOF    = NNODE*3        
      NPART   = NDOF*NDOF        
      DICT(2) = 1        
      DICT(3) = NDOF        
      DICT(4) = 7        
      ADAMP   = 0.0        
      JEND    = JCORED + NPART - 1        
C        
C     ZERO OUT THE POSITIONS, THEN LOOP ON I AND J TO LOAD THE MASS     
C     MATRIX.        
C        
      DO 610 IJK = JCORED,JEND        
      AMGG(IJK) = 0.0D0        
  610 CONTINUE        
C        
      NDOFP1 = NDOF + 1        
C     DO 640 I  = 0,NNOD2-1,NNODE        
      DO 640 II = 1,NNOD2  ,NNODE        
      I = II - 1        
      DO 630 J = 1,NNODE        
      XMASSO = XMASS(I+J)        
      IPOINT = (J-1)*3 + I*9 + JCORED        
      JPOINT = IPOINT + 3*NDOF        
      DO 620 K = IPOINT,JPOINT,NDOFP1        
      AMGG(K) = XMASSO        
  620 CONTINUE        
  630 CONTINUE        
  640 CONTINUE        
C        
C     BYPASS TRANSFORMATIONS IF LUMPED MASS.        
C        
      IF (CPMASS .LE. 0) GO TO 700        
C        
C     BUILD THE 9X9 TRANSFORMATION MATRIX FOR ONE-SHOT MULTIPLY        
C        
      DO 650 I = 1,NPART        
      TRANSK(I) = 0.0D0        
      TOTTRN(I) = 0.0D0        
  650 CONTINUE        
C        
      NDOF33 = 3*NDOF + 3        
C     DO 680 I = 0,NPART-1,3*NDOF+3        
      DO 680 I = 1,NPART  ,NDOF33        
      II = ((I-1)/(3*NDOF))*9        
C     DO 670 J  = 0,8,3        
      DO 670 JJ = 1,9,3        
      J  = JJ - 1        
      KK = I - 1 + J*NNODE        
      DO 660 K = 1,3        
      TOTTRN(KK+K) = TRANS(II+J+K)        
  660 CONTINUE        
  670 CONTINUE        
  680 CONTINUE        
C        
C     PERFORM THE TRIPLE MULTIPLY.        
C        
      CALL MPYA3D (TOTTRN,AMGG(JCORED),NDOF,3,TRANSK)        
      GO TO 720        
C        
C     JUST COPY THE LUMPED MASS MATRIX OUT        
C        
  700 II = JCORED        
      DO 710 I = 1,NPART        
      TRANSK(I) = AMGG(II)        
      II = II + 1        
  710 CONTINUE        
C        
  720 CALL EMGOUT (TRANSK,TRANSK,NPART,IEOE,DICT,MMAT,PREC)        
C        
  730 CONTINUE        
      GO TO 1200        
C        
C     HEAT CALCULATIONS        
C        
  800 CONTINUE        
      INFLAG = 2        
      SINMAT = DSIN(THETAM)        
      COSMAT = DCOS(THETAM)        
      MATID  = NEST(11)        
C        
      CALL HMAT (ELID)        
C        
      GI(1) = KHEAT(1)        
      GI(2) = KHEAT(2)        
      GI(3) = GI(2)        
      GI(4) = KHEAT(3)        
C        
      DO 900 I = 1,18        
      HTCON(I) = 0.0D0        
      HTCAP(I) = 0.0D0        
  900 CONTINUE        
C        
C     BEGIN LOOP ON INTEGRATION POINTS        
C        
      DO 950 IPT = 1,3        
      CALL T3BMGD (IERR,SHEART,IPT,IORDER,EGPDT,DGPTH,AIC,TH,DETJAC,    
     1             SHPT,BTERMS,BMATRX)        
      IF (IERR .NE. 0) GO TO 1110        
C        
      DVOL = WEIGHT*DETJAC*TH        
      DO 910 I = 1,4        
      G(I,1) = GI(I)*DVOL        
  910 CONTINUE        
      WEITC = DVOL*HTCP        
C        
      IP = 1        
      DO 920 I = 1,NNODE        
      HTFLX(IP  ) = G(1,1)*BTERMS(I) + G(2,1)*BTERMS(I+NNODE)        
      HTFLX(IP+1) = G(3,1)*BTERMS(I) + G(4,1)*BTERMS(I+NNODE)        
      IP = IP + 2        
  920 CONTINUE        
      CALL GMMATD (BTERMS,2,NNODE,-1, HTFLX,NNODE,2,1, HTCON)        
C        
C     FINISHED WITH HEAT CONDUCTIVITY MATRIX, DO HEAT CAPACITY IF       
C     REQUIRED.        
C        
      IF (HTCP .EQ. 0.0) GO TO 950        
      IP = 1        
      DO 940 I = 1,NNODE        
      DHEAT = WEITC*SHPT(I)        
      DO 930 J = 1,NNODE        
      HTCAP(IP) = HTCAP(IP) + DHEAT*SHPT(J)        
      IP = IP + 1        
  930 CONTINUE        
  940 CONTINUE        
C        
  950 CONTINUE        
C        
C     END OF INTEGRATION LOOP, SHIP OUT THE RESULTS.        
C        
      DICT(1) = ESTID        
      DICT(2) = 1        
      DICT(3) = NNODE        
      DICT(4) = 1        
      IF (WEITC .EQ. 0.0D0) GO TO 1000        
      ADAMP = 1.0        
      CALL EMGOUT (HTCAP,HTCAP,NNOD2,IEOE,DICT,DMAT,PREC)        
 1000 ADAMP = 0.0        
      CALL EMGOUT (HTCON,HTCON,NNOD2,IEOE,DICT,KMAT,PREC)        
C        
      GO TO 1200        
C        
C        
C     FATAL ERRORS        
C        
C     INSUFFICIENT MEMORY IS AVAILABLE        
C        
 1100 CALL MESAGE (-30,228,NAME)        
      GO TO 1140        
C        
C     CTRIA3 ELEMENT HAS ILLEGAL GEOMETRY OR CONNECTIONS        
C        
 1110 J = 224        
      GO TO 1140        
C        
C     THE X-AXIS OF THE MATERIAL COORDINATE SYSTEM HAS NO PROJECTION    
C     ON TO THE PLANE OF CTRIA3 ELEMENT        
C        
 1120 J = 225        
      NEST(2) = MCSID        
      GO TO 1140        
C        
C     ILLEGAL DATA DETECTED ON MATERIAL ID REFERENCED BY CTRIA3 ELEMENT 
C     FOR MID3 APPLICATION        
C        
 1130 J = 226        
      NEST(2) = MID(3)        
C        
 1140 CALL MESAGE (30,J,NEST(1))        
      IF (L38 .EQ. 1) CALL MESAGE (-61,0,0)        
      NOGO = 1        
C        
 1200 CONTINUE        
      RETURN        
      END        
