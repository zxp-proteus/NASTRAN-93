      SUBROUTINE QUAD4S        
C        
C     FORMS STIFFNESS AND MASS MATRICES FOR THE QUAD4 PLATE ELEMENT     
C        
C     SINGLE PRECISION VERSION        
C        
C        
C     EST  LISTING        
C        
C     WORD       TYPE         DESCRIPTION        
C     --------------------------------------------------------------    
C       1          I    ELEMENT ID, EID        
C       2 THRU 5   I    SILS, GRIDS 1 THRU 4        
C       6 THRU 9   R    MEMBRANE THICKNESSES T AT GRIDS 1 THRU 4        
C      10          R    MATERIAL PROPERTY ORIENTATION ANGLE, THETA      
C               OR I    COORD. SYSTEM ID (SEE TM ON CQUAD4 CARD)        
C      11          I    TYPE FLAG FOR WORD 10        
C      12          R    GRID ZOFF  (OFFSET)        
C      13          I    MATERIAL ID FOR MEMBRANE, MID1        
C      14          R    ELEMENT THICKNESS, T (MEMBRANE, UNIFORMED)      
C      15          I    MATERIAL ID FOR BENDING, MID2        
C      16          R    BENDING INERTIA FACTOR, I        
C      17          I    MATERIAL ID FOR TRANSVERSE SHEAR, MID3        
C      18          R    TRANSV. SHEAR CORRECTION FACTOR TS/T        
C      19          R    NON-STRUCTURAL MASS, NSM        
C      20 THRU 21  R    Z1, Z2  (STRESS FIBRE DISTANCES)        
C      22          I    MATERIAL ID FOR MEMBRANE-BENDING COUPLING, MID4 
C      23          R    MATERIAL ANGLE OF ROTATION, THETA        
C               OR I    COORD. SYSTEM ID (SEE MCSID ON PSHELL CARD)     
C      24          I    TYPE FLAG FOR WORD 23        
C      25          I    INTEGRATION ORDER        
C      26          R    STRESS ANGLE OF ROTATION, THETA        
C               OR I    COORD. SYSTEM ID (SEE SCSID ON PSHELL CARD)     
C      27          I    TYPE FLAG FOR WORD 26        
C      28          R    ZOFF1 (OFFSET)  OVERRIDDEN BY EST(12)        
C      29 THRU 44  I/R  CID,X,Y,Z - GRIDS 1 THRU 4        
C      45          R    ELEMENT TEMPERATURE        
C        
C        
      LOGICAL         HEAT,MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH,BADJAC,   
     1                ANIS,NOCSUB,NOGO        
      INTEGER         NEST(45),IEGPDT(4,4),CPMASS,FLAGS,NOUT,ELTYPE,    
     1                ELID,ESTID,SIL(4),KSIL(4),KCID(4),DICT(9),        
     2                IGPDT(4,4),IGPTH(4),NAM(2),MID(4),TYPE,NECPT(4),  
     3                ROWFLG,NOTRAN(4),HSIL(8),HORDER(8)        
      REAL            TSFACT,EPSI,EPST,EPS,GPTH(4),MATOUT,EGPDT(4,4),   
     1                GSUBE,BGPDM(3,4),GPNORM(4,4),BGPDT(4,4),ADAMP,    
     2                MATSET,NSM,EPNORM(4,4),KHEAT,HTCP,SINMAT,COSMAT,  
     3                ECPT(4),SAVE(20)        
      REAL            AMGG(1),AKGG,DGPTH(4),BMAT1(384),XYBMAT(96),ZETA, 
     1                MOMINR,VOL,VOLI,TH,AREA,AREA2,DETJ,PTINT(2),      
     2                EPS1,XI,ETA,ZTA,HZTA,THK,XMASSO,V(3,3),        
     3                COEFF,XMTMP(16),XMASS(16),TMPMAS(9),JACOB(3,3),   
     4                TMPSHP(4),TMPTHK(4),DSHPTP(8),PSITRN(9),PHI(9),   
     5                SHP(4),DSHP(8),TGRID(4,4),COLSTF(144),TRANS(36),  
     6                TRANS1(36),COLTMP(144),AVGTHK,TEMP        
      REAL            AA,BB,CC,X31,Y31,X42,Y42,EXI,EXJ,UGPDM(3,4),      
     1                CENT(3),CENTE(3),TBM(9),TEB(9),TEM(9),TUB(9),     
     2                TUM(9),TEU(9),TBG(9),GGE(9),GGU(9)        
      REAL            RHO,TS,TSI,REALI,RHOX,THETAM,XM,YM,U(9),A,B,      
     1                ASPECT,THLEN,XA(4),YB(4),GT(9),GI(36),ENORX,ENORY,
     2                GNORX,GNORY,NUNORX,NUNORY,DSUB,DSUB4,PSIINX,      
     3                PSIINY,TSMFX,TSMFY,CURVTR(3,4),CURVE(3),SINEAX,   
     4                SINEAY,W1,PI,TWOPI,RADDEG,DEGRAD,HTFLX(12),DETERM,
     5                HTCAP(16),HTCON(16),DVOL,DHEAT,WEITC,BTERMS(32)   
      REAL            ZC(4),UEV,ANGLEI,EDGEL,EDGSHR,UNV,VNT(3,4),ASPCTX,
     1                ASPCTY,GFOUR(10,10),DFOUR(7,7),BFOUR(240),CSUBB4, 
     2                CSUBX,CSUBY,CSUBT,CSUBTX,CSUBTY,SFCTR1,SFCTR2,    
     3                SFCTX1,SFCTX2,SFCTY1,SFCTY2,OFFSET,CONST,EIX,EIY, 
     4                TGX,TGY        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
C        
C     ICORE = FIRST WORD OF OPEN CORE        
C     JCORE = NEXT AVAILABLE LOCATION IN OPEN CORE.        
C     NCORE = CURRENT LAST AVAILABLE LOCATION IN OPEN CORE        
C        
      COMMON /EMGPRM/ ICORE,JCORE,NCORE,ICSTM,NCSTM,IMAT,NMAT,IHMAT,    
     1                NHMAT,IDIT,NDIT,ICONG,NCONG,LCONG,ANYCON,FLAGS(3),
     2                PRECIS,ERROR,HEAT,CPMASS,LCSTM,LMAT,LHMAT,        
     3                KFLAGS(3),L38        
      COMMON /EMGEST/ EST(45)        
      COMMON /EMGDIC/ ELTYPE,LDICT,NLOCS,ELID,ESTID        
      COMMON /SYSTEM/ SYS(100)        
      COMMON /MATIN / MATID,INFLAG,ELTEMP,DUMMY,SINMAT,COSMAT        
      COMMON /MATOUT/ MATOUT(25)        
      COMMON /HMTOUT/ KHEAT(7),TYPE        
CZZ   COMMON /ZZEMGX/ AKGG(1)        
      COMMON /ZZZZZZ/ AKGG(1)        
      COMMON /Q4DT  / DETJ,HZTA,PSITRN,NNODE,BADJAC,N1        
      COMMON /TERMS / MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH        
      COMMON /Q4COMS/ ANGLEI(4),EDGSHR(3,4),EDGEL(4),UNV(3,4),        
     1                UEV(3,4),ROWFLG,IORDER(4)        
      COMMON /CONDAS/ PI,TWOPI,RADDEG,DEGRAD        
      COMMON /COMJAC/ XI,ETA,ZETA,DETERM,DUM2,LTYPFL        
      COMMON /CJACOB/ TH,VI(3),VJ(3),VN(3)        
      COMMON /TRPLM / NDOF,IBOT,IPTX1,IPTX2,IPTY1,IPTY2        
      EQUIVALENCE     (SYS(01)   ,SYSBUF  ), (SYS(02) ,NOUT      ),     
     1                (SYS(03)   ,NOGO    ), (SYS(55) ,IPREC     )      
C     EQUIVALENCE     (SYS(48)   ,ICSUB4  ), (SYS(49) ,ICSUBB    ),     
C    1                (SYS(50)   ,ICSUBT  ), (SYS(75) ,ICSUB8    )      
      EQUIVALENCE     (FLAGS(1)  ,KGG1    ), (FLAGS(2),MGG1      ),     
     1                (ADAMP     ,DICT(5) ), (IGPTH(1),GPTH(1)   ),     
     2                (EST(1)    ,NEST(1) ), (INT     ,NEST(25)  ),     
     3                (BGPDT(1,1),EST(29) ), (GPTH(1) ,EST(6)    ),     
     4                (ELTH      ,EST(14) ), (SIL(1)  ,NEST(2)   ),     
     5                (ZOFF      ,EST(12) ), (ZOFF1   ,EST(28)   ),     
     6                (AMGG(1)   ,AKGG(1) ), (NECPT(1),ECPT(1)   ),     
     7                (HTCP      ,KHEAT(4)), (HTFLX(1),TMPMAS(1) ),     
     8                (HTCAP(1)  ,XMASS(1)), (HTCON(1),XMTMP(1)  ),     
     9                (NSM       ,EST(19) ), (MATSET  ,MATOUT(25)),     
     O                (IEGPDT(1,1),EGPDT(1,1)),        
     1                (IGPDT(1,1) ,BGPDT(1,1))        
      DATA    EPS1  / 1.0E-7 /        
      DATA    CONST / 0.57735026918962/        
      DATA    NAM   / 4HQUAD,4H4S     /        
C        
      ELID   = NEST(1)        
      LTYPFL = 1        
      OFFSET = ZOFF        
      IF (ZOFF .EQ. 0.0) OFFSET = ZOFF1        
C        
C     CHECK FOR SUFFICIENT OPEN CORE FOR ELEMENT STIFFNESS        
C        
      JCORED = JCORE        
      NCORED = NCORE- 1        
      IF (JCORED+576.LE.NCORED .OR. HEAT .OR. KGG1.EQ.0) GO TO 10       
      GO TO 1730        
C        
C     COPY THE SILS AND BGPDT DATA INTO SAVE ARRAY SINCE THE DATA       
C     WILL BE REORDERED BASED ON INCREASING SILS.        
C        
   10 J = 1        
      DO 15 I = 1,20        
      SAVE(I) = EST(I+J)        
      IF (I .EQ. 4) J = 24        
   15 CONTINUE        
C        
      NNODE = 4        
      N1    = 4        
      NODESQ= NNODE*NNODE        
      NDOF  = NNODE*6        
      NDOF3 = NNODE*3        
      ND2   = NDOF*2        
      ND3   = NDOF*3        
      ND4   = NDOF*4        
      ND5   = NDOF*5        
      ND6   = NDOF*6        
      ND7   = NDOF*7        
C        
C     FILL IN ARRAY GGU WITH THE COORDINATES OF GRID POINTS        
C     1, 2 AND 4. THIS ARRAY WILL BE USED LATER TO DEFINE        
C     THE USER COORDINATE SYSTEM WHILE CALCULATING        
C     TRANSFORMATIONS INVOLVING THIS COORDINATE SYSTEM.        
C        
      DO 20 I = 1,3        
      II = (I-1)*3        
      IJ = I        
      IF (IJ .EQ. 3) IJ = 4        
      DO 20 J = 1,3        
      JJ = J + 1        
   20 GGU(II+J) = BGPDT(JJ,IJ)        
      CALL BETRNS (TUB,GGU,0,ELID)        
C        
C     STORE INCOMING BGPDT FOR LUMPED MASS AND ELEMENT C.S.        
C        
      DO 30 I = 1,3        
      I1 = I + 1        
      DO 30 J = 1,4        
   30 BGPDM(I,J) = BGPDT(I1,J)        
C        
C     TRANSFORM BGPDM FROM BASIC TO USER C.S.        
C        
      DO 40 I = 1,3        
      IP = (I-1)*3        
      DO 40 J = 1,4        
      UGPDM(I,J) = 0.0        
      DO 40 K = 1,3        
      KK = IP + K        
   40 UGPDM(I,J) = UGPDM(I,J) + TUB(KK)*((BGPDM(K,J)) - GGU(K))        
C        
C        
C     THE ORIGIN OF THE ELEMENT C.S. IS IN THE MIDDLE OF THE ELEMENT    
C        
      DO 50 J = 1,3        
      CENT(J) = 0.0        
      DO 50 I = 1,4        
   50 CENT(J) = CENT(J) + UGPDM(J,I)/NNODE        
C        
C     STORE THE CORNER NODE DIFF. IN THE USER C.S.        
C        
      X31 = UGPDM(1,3) - UGPDM(1,1)        
      Y31 = UGPDM(2,3) - UGPDM(2,1)        
      X42 = UGPDM(1,4) - UGPDM(1,2)        
      Y42 = UGPDM(2,4) - UGPDM(2,2)        
      AA  = SQRT(X31*X31 + Y31*Y31)        
      BB  = SQRT(X42*X42 + Y42*Y42)        
      IF (AA.EQ.0.0 .OR. BB.EQ.0.0) GO TO 1700        
C        
C     NORMALIZE XIJ'S        
C        
      X31 = X31/AA        
      Y31 = Y31/AA        
      X42 = X42/BB        
      Y42 = Y42/BB        
      EXI = X31 - X42        
      EXJ = Y31 - Y42        
C        
C     STORE GGE ARRAY, THE OFFSET BETWEEN ELEMENT C.S. AND USER C.S.    
C        
      GGE(1) = CENT(1)        
      GGE(2) = CENT(2)        
      GGE(3) = CENT(3)        
C        
      GGE(4) = GGE(1) + EXI        
      GGE(5) = GGE(2) + EXJ        
      GGE(6) = GGE(3)        
C        
      GGE(7) = GGE(1) - EXJ        
      GGE(8) = GGE(2) + EXI        
      GGE(9) = GGE(3)        
C        
C     THE ARRAY IORDER STORES THE ELEMENT NODE ID IN        
C     INCREASING SIL ORDER.        
C        
C     IORDER(1) = NODE WITH LOWEST  SIL NUMBER        
C     IORDER(4) = NODE WITH HIGHEST SIL NUMBER        
C        
C     ELEMENT NODE NUMBER IS THE INTEGER FROM THE NODE        
C     LIST  G1,G2,G3,G4 .  THAT IS, THE 'I' PART        
C     OF THE 'GI' AS THEY ARE LISTED ON THE CONNECTIVITY        
C     BULK DATA CARD DESCRIPTION.        
C        
      DO 60 I = 1,4        
      IORDER(I) = 0        
      HORDER(I) = 0        
      KSIL(I) = SIL(I)        
      HSIL(I) = SIL(I)        
   60 CONTINUE        
C        
      DO 80 I = 1,4        
      ITEMP = 1        
      ISIL  = KSIL(1)        
      DO 70 J = 2,4        
      IF (ISIL .LE. KSIL(J)) GO TO 70        
      ITEMP = J        
      ISIL  = KSIL(J)        
   70 CONTINUE        
      IORDER(I) = ITEMP        
      HORDER(I) = ITEMP        
      KSIL(ITEMP) = 99999999        
   80 CONTINUE        
C        
C     ADJUST EST DATA        
C        
C     USE THE POINTERS IN IORDER TO COMPLETELY REORDER THE        
C     GEOMETRY DATA INTO INCREASING SIL ORDER.        
C     DON'T WORRY!! IORDER ALSO KEEPS TRACK OF WHICH SHAPE        
C     FUNCTIONS GO WITH WHICH GEOMETRIC PARAMETERS!        
C        
      DO 100 I = 1,4        
      KSIL(I) = SIL(I)        
      TMPTHK(I) = GPTH(I)        
      KCID(I) = IGPDT(1,I)        
      DO 90 J = 2,4        
      TGRID(J,I) = BGPDT(J,I)        
   90 CONTINUE        
  100 CONTINUE        
      DO 120 I = 1,4        
      IPOINT = IORDER(I)        
      SIL(I) = KSIL(IPOINT)        
      GPTH(I)= TMPTHK(IPOINT)        
      IGPDT(1,I) = KCID(IPOINT)        
      DO 110 J = 2,4        
      BGPDT(J,I) = TGRID(J,IPOINT)        
  110 CONTINUE        
  120 CONTINUE        
C        
C     COMPUTE NODE NORMALS        
C        
      CALL Q4NRMS (BGPDT,GPNORM,IORDER,IFLAG)        
      IF (IFLAG .EQ. 0) GO TO 130        
      GO TO 1700        
C        
C     DETERMINE NODAL THICKNESSES        
C        
  130 AVGTHK = 0.0        
      DO 160 I = 1,NNODE        
      IORD = IORDER(I)        
      DO 140 IC = 1,3        
  140 CURVTR(IC,IORD) = GPNORM(IC+1,I)        
C        
      IF (GPTH(I) .EQ. 0.0) GPTH(I) = ELTH        
      IF (NEST(13).EQ.0 .AND. ELTH.EQ.0.) GPTH(I) = 1.0E-14        
      IF (GPTH(I) .GT. 0.0) GO TO 150        
      WRITE (NOUT,2010) UFM,ELID        
      NOGO =.TRUE.        
      GO TO 1710        
  150 DGPTH(I) = GPTH(I)        
      AVGTHK = AVGTHK + DGPTH(I)/NNODE        
  160 CONTINUE        
C        
C     NEST(13) = MID1 ID FOR MEMBRANE        
C     NEST(15) = MID2 ID FOR BENDING        
C     NEST(17) = MID3 ID FOR TRANSVERSE SHEAR        
C     NEST(22) = MID4 ID FOR MEMBRANE-BENDING COUPLING        
C                MID4 MUST BE BLANK UNLESS MID1 AND MID2 ARE NON-ZERO   
C                MID4 ID MUST NOT EQUAL MID1 OR MID2 ID        
C     (WHEN LAYER COMPOSITE IS USED, MID ID IS RAISED TO ID*100000000)  
C      EST(14) = MEMBRANE THICKNESS, T        
C      EST(16) = BENDING STIFFNESS PARAMETER, 12I/T**3        
C      EST(18) = TRNASVERSE SHEAR  PARAMETER, TS/T        
C        
C     0.8333333 = 5.0/6.0        
C        
      MOMINR = 0.0        
      TSFACT = .8333333        
      NOCSUB = .FALSE.        
      IF (NEST(15) .NE.  0) MOMINR = EST(16)        
      IF (NEST(17) .NE.  0) TS = EST(18)        
      IF ( EST(18) .EQ. 0.) TS = .8333333        
C        
C     FIX FOR LAMINATED COMPOSITE WITH MEMBRANE BEHAVIOUR ONLY.        
C     REQUIRED TO PREVENT ZERO DIVIDE ERRORS.        
C        
      IF (NEST(15).EQ.0 .AND. NEST(13).GT.100000000) TS = .8333333      
C        
C     SET LOGICAL NOCSUB IF EITHER MOMINR OR TS ARE NOT DEFAULT        
C     VALUES. THIS WILL BE USED TO OVERRIDE ALL CSUBB COMPUTATIONS.     
C     I.E. DEFAULT VALUES OF UNITY ARE USED.        
C        
      EPSI = ABS(MOMINR - 1.0)        
      EPST = ABS(TS  - TSFACT)        
      EPS  = .05        
C     NOCSUB = EPSI.GT.EPS .OR. EPST.GT.EPS        
      IF (NEST(13) .GT. 100000000) NOCSUB = .FALSE.        
C        
C     THE COORDINATES OF THE ELEMENT GRID POINTS HAVE TO BE        
C     TRANSFORMED FROM THE BASIC C.S. TO THE ELEMENT C.S.        
C        
C     SET IDENTT FLAG TO 1 IF TEB IS AN IDENTITY MATRIX        
C        
      CALL BETRNS (TEU,GGE,0,ELID)        
      CALL GMMATS (TEU,3,3,0,TUB ,3,3,0,TEB  )        
      CALL GMMATS (TUB,3,3,1,CENT,3,1,0,CENTE)        
      IDENTT = 0        
      IF (TEB(1).EQ.1.0 .AND. TEB(5).EQ.1.0 .AND. TEB(9).EQ.1.0 .AND.   
     1    TEB(2).EQ.0.0 .AND. TEB(3).EQ.0.0 .AND. TEB(4).EQ.0.0 .AND.   
     2    TEB(6).EQ.0.0 .AND. TEB(7).EQ.0.0 .AND. TEB(8).EQ.0.0        
     3    ) IDENTT = 1        
      IP = -3        
      DO 170 II = 2,4        
      IP = IP + 3        
      DO 170 J = 1,NNODE        
      EPNORM(II,J) = 0.0        
      EGPDT(II,J)  = 0.0        
      DO 170 K = 1,3        
      KK = IP + K        
      K1 = K + 1        
      CC = BGPDT(K1,J) - GGU(K) - CENTE(K)        
      EPNORM(II,J) = EPNORM(II,J) + TEB(KK)*GPNORM(K1,J)        
  170 EGPDT(II,J)  = EGPDT(II,J)  + (TEB(KK)*CC)        
C        
C     BEGIN INITIALIZING MATERIAL VARIABLES        
C        
C     SET INFLAG = 12 SO THAT SUBROUTINE MAT WILL SEARCH FOR-        
C     ISOTROPIC MATERIAL PROPERTIES AMONG THE MAT1 CARDS,        
C     ORTHOTROPIC MATERIAL PROPERTIES AMONG THE MAT8 CARDS, AND        
C     ANISOTROPIC MATERIAL PROPERTIES AMONG THE MAT2 CARDS.        
C        
      INFLAG = 12        
      RHO    = 0.0        
      ELTEMP = EST(45)        
      MID(1) = NEST(13)        
      MID(2) = NEST(15)        
      MID(3) = NEST(17)        
      MID(4) = NEST(22)        
      MEMBRN = MID(1).GT.0        
      BENDNG = MID(2).GT.0 .AND. MOMINR.GT.0.0        
      SHRFLX = MID(3).GT.0        
      MBCOUP = MID(4).GT.0        
C        
C     FIGURE OUT PATH OF THE TRIPLE MULTIPLY AND THE NO. OF ROWS        
C     IN B-MATRIX        
C        
C     NORPTH = MID(1).EQ.MID(2).AND.MID(1).EQ.MID(3).AND.MID(4).EQ.0    
C    1        .AND. ABS(MOMINR-1.0).LE.EPS1        
      NORPTH = .FALSE.        
C        
C     DETERMINE FACTORS TO BE USED IN CSUBB CALCULATIONS        
C        
C     IF (.NOT.BENDNG) GO TO 290        
      DO 210 I = 1,4        
      DO 200 J = 1,NNODE        
      JO = IORDER(J)        
      IF (I .NE. JO) GO TO 200        
      XA(I) = EGPDT(2,J)        
      YB(I) = EGPDT(3,J)        
      ZC(I) = EGPDT(4,J)        
      VNT(1,I) = EPNORM(2,J)        
      VNT(2,I) = EPNORM(3,J)        
      VNT(3,I) = EPNORM(4,J)        
  200 CONTINUE        
  210 CONTINUE        
C        
      A = 0.5*ABS(XA(2)+XA(3)-XA(1)-XA(4))        
      B = 0.5*ABS(YB(4)+YB(3)-YB(1)-YB(2))        
      IF (A .GT. B) ASPECT = B/A        
      IF (A .LE. B) ASPECT = A/B        
      THLEN = AVGTHK/A        
      IF (A .LT. B) THLEN = AVGTHK/B        
C        
C     TORSION-RELATED SHEAR CORRECTION FOR 4-NODE-        
C     PRELIMINARY FACTORS        
C        
      ASPCTX = A/B        
      ASPCTY = B/A        
      CSUBB4 = 1.6        
C     IF (ICSUBB .NE. 0) CSUBB4 = SYS(49)        
      CSUBT  = 71.0*ASPECT*(1.60/CSUBB4)*(1.0+415.0*ASPECT*THLEN**2)    
      CSUBTX = CSUBT*ASPCTX**2        
      CSUBTY = CSUBT*ASPCTY**2        
C        
      I  = 2        
      J  = 2        
      JJ = 3        
      SINEAX = 0.0        
      SINEAY = 0.0        
  220 CALL SAXB (CURVTR(1,I-1),CURVTR(1,I),CURVE)        
      CC = CURVE(1)*CURVE(1) + CURVE(2)*CURVE(2) + CURVE(3)*CURVE(3)    
      IF (CC .LT. EPS1) GO TO 230        
      CC = 0.5*SQRT(CC)        
  230 SINEAX = SINEAX + CC        
      IF (I .NE. 2) GO TO 240        
      I  = 4        
      GO TO 220        
C        
  240 CALL SAXB (CURVTR(1,J),CURVTR(1,JJ),CURVE)        
      CC = CURVE(1)*CURVE(1) + CURVE(2)*CURVE(2) + CURVE(3)*CURVE(3)    
      IF (CC .LT. EPS1) GO TO 250        
      CC = 0.5*SQRT(CC)        
  250 SINEAY = SINEAY + CC        
      IF (J .NE. 2) GO TO 260        
      J  = 1        
      JJ = 4        
      GO TO 240        
  260 CC = 28.0        
      SINEAX =CC*SINEAX + 1.0        
      SINEAY =CC*SINEAY + 1.0        
      IF (SINEAX .GT. SINEAY) SINEAY = SINEAX        
      IF (SINEAY .GT. SINEAX) SINEAX = SINEAY        
C        
C     IRREGULAR 4-NODE CODE-  GEOMETRIC VARIABLES        
C        
C     CALCULATE AND NORMALIZE- UNIT EDGE VECTORS,UNIT NORMAL VECTORS    
C        
      DO 270 I = 1,4        
      J = I + 1        
      IF (J .EQ. 5) J = 1        
      UEV(1,I) = XA(J) - XA(I)        
      UEV(2,I) = YB(J) - YB(I)        
      UEV(3,I) = ZC(J) - ZC(I)        
      UNV(1,I) = (VNT(1,J) + VNT(1,I))*0.50        
      UNV(2,I) = (VNT(2,J) + VNT(2,I))*0.50        
      UNV(3,I) = (VNT(3,J) + VNT(3,I))*0.50        
      CC = UEV(1,I)**2 + UEV(2,I)**2 + UEV(3,I)**2        
      IF (CC .EQ.  0.0) GO TO 1700        
      IF (CC .GE. EPS1) CC = SQRT(CC)        
      EDGEL(I) = CC        
      UEV(1,I) = UEV(1,I)/CC        
      UEV(2,I) = UEV(2,I)/CC        
      UEV(3,I) = UEV(3,I)/CC        
      CC = UNV(1,I)**2 + UNV(2,I)**2 + UNV(3,I)**2        
      IF (CC .EQ.  0.0) GO TO 1700        
      IF (CC .GE. EPS1) CC = SQRT(CC)        
      UNV(1,I) = UNV(1,I)/CC        
      UNV(2,I) = UNV(2,I)/CC        
      UNV(3,I) = UNV(3,I)/CC        
  270 CONTINUE        
C        
C     CALCULATE INTERNAL NODAL ANGLES        
C        
      DO 280 I = 1,4        
      J = I - 1        
      IF (J .EQ. 0) J = 4        
      ANGLEI(I) =-UEV(1,I)*UEV(1,J)-UEV(2,I)*UEV(2,J)-UEV(3,I)*UEV(3,J) 
      IF (ABS(ANGLEI(I)) .LT. EPS1) ANGLEI(I) = 0.0        
  280 CONTINUE        
C 290 CONTINUE        
C        
C     SET THE INTEGRATION POINTS        
C        
      PTINT(1)  = -CONST        
      PTINT(2)  =  CONST        
C     JZTA = 2        
C     IF (.NOT.BENDNG) PTINTZ(1) = 0.0        
C     IF (.NOT.BENDNG) JZTA = 1        
      IF (HEAT) GO TO 1790        
C        
C     TRIPLE LOOP TO SAVE THE LAST 2 ROWS OF B-MATRIX AT 2X2X2        
C     INTEGRATION POINTS FOR LATER MANIPULATION.        
C        
      IF (KGG1 .EQ. 0) GO TO 400        
C     IF (.NOT.BENDNG) GO TO 360        
      I  = 1        
      KPT= 1        
C        
      DO 350 IXSI = 1,2        
      XI = PTINT(IXSI)        
C        
      DO 350 IETA = 1,2        
      ETA = PTINT(IETA)        
C        
      CALL Q4SHPS (XI,ETA,SHP,DSHP)        
C        
C     IRREGULAR 4-NODE CODE-  CALCULATION OF NODAL EDGE SHEARS        
C                             AT THIS INTEGRATION POINT        
C        
      DO 310 IJ = 1,4        
      II = IJ - 1        
      IF (II .EQ. 0) II = 4        
      IK = IJ + 1        
      IF (IK .EQ. 5) IK = 1        
      AA = SHP(IJ)        
      BB = SHP(IK)        
C        
      DO 300 IS = 1,3        
      EDGSHR(IS,IJ)=(UEV(IS,IJ) + ANGLEI(IJ)*UEV(IS,II))*AA/        
     1              (1.0-ANGLEI(IJ)*ANGLEI(IJ))        
     2             +(UEV(IS,IJ) + ANGLEI(IK)*UEV(IS,IK))*BB/        
     3              (1.0-ANGLEI(IK)*ANGLEI(IK))        
  300 CONTINUE        
  310 CONTINUE        
C        
C     SORT THE SHAPE FUNCTIONS AND THEIR DERIVATIVES INTO SIL ORDER.    
C        
      DO 320 IS = 1,4        
      TMPSHP(IS  ) =  SHP(IS  )        
      DSHPTP(IS  ) = DSHP(IS  )        
  320 DSHPTP(IS+4) = DSHP(IS+4)        
      DO 330 IS = 1,4        
      KK = IORDER(IS)        
      SHP (IS  ) = TMPSHP(KK  )        
      DSHP(IS  ) = DSHPTP(KK  )        
  330 DSHP(IS+4) = DSHPTP(KK+4)        
C        
      DO 340 IZTA = 1,2        
      ZTA = PTINT(IZTA)        
C        
C     COMPUTE THE JACOBIAN AT THIS GAUSS POINT,        
C     ITS INVERSE AND ITS DETERMINANT.        
C        
      HZTA = ZTA/2.0        
      CALL JACOBS (ELID,SHP,DSHP,DGPTH,EGPDT,EPNORM,JACOB)        
      IF (BADJAC) GO TO 1710        
C        
C     COMPUTE PSI TRANSPOSE X JACOBIAN INVERSE.        
C     HERE IS THE PLACE WHERE THE INVERSE JACOBIAN IS FLAGED TO BE      
C     TRANSPOSED BECAUSE OF OPPOSITE MATRIX LOADING CONVENTION        
C     BETWEEN INVER AND GMMAT.        
C        
      CALL GMMATS (PSITRN,3,3,0,JACOB,3,3,1,PHI)        
C        
C     CALL Q4BMGS TO GET B MATRIX        
C     SET THE ROW FLAG TO 1. IT SIGNALS SAVING THE LAST 2 ROWS.        
C        
      ROWFLG = 1        
      CALL Q4BMGS (DSHP,DGPTH,EGPDT,EPNORM,PHI,BMAT1(KPT))        
  340 KPT = KPT + ND2        
  350 CONTINUE        
C        
C     IN PLANE SHEAR REDUCTION        
C        
C     IF (.NOT.MEMBRN) GO TO 400        
C 360 CONTINUE        
      XI  = 0.0        
      ETA = 0.0        
      KPT = 1        
      KPNT= ND2        
C     IF (NORPTH) KPNT = NDOF        
C        
      CALL Q4SHPS (XI,ETA,SHP,DSHP)        
C        
C     SORT THE SHAPE FUNCTIONS AND THEIR DERIVATIVES INTO SIL ORDER.    
C        
      DO 370 I = 1,4        
      TMPSHP(I  ) =  SHP(I  )        
      DSHPTP(I  ) = DSHP(I  )        
  370 DSHPTP(I+4) = DSHP(I+4)        
      DO 380 I = 1,4        
      KK = IORDER(I)        
      SHP (I  ) = TMPSHP(KK  )        
      DSHP(I  ) = DSHPTP(KK  )        
  380 DSHP(I+4) = DSHPTP(KK+4)        
C        
C     DO 390 IZTA = 1,JZTA        
      DO 390 IZTA = 1,2        
      ZTA  = PTINT(IZTA)        
      HZTA = ZTA/2.0        
      CALL JACOBS (ELID,SHP,DSHP,DGPTH,EGPDT,EPNORM,JACOB)        
      IF (BADJAC) GO TO 1710        
C        
      CALL GMMATS (PSITRN,3,3,0,JACOB,3,3,1,PHI)        
C        
C     CALL Q4BMGS TO GET B-MATRIX        
C     SET THE ROW FLAG TO 2. IT WILL SAVE THE 3RD ROW OF B-MATRIX AT    
C     THE TWO INTEGRATION POINTS.        
C        
      ROWFLG = 2        
      CALL Q4BMGS (DSHP,DGPTH,EGPDT,EPNORM,PHI,XYBMAT(KPT))        
  390 KPT = KPT + KPNT        
C        
C     SET THE ARRAY OF LENGTH 4 TO BE USED IN CALLING TRANSS.        
C     NOTE THAT THE FIRST WORD IS THE COORDINATE SYSTEM ID WHICH        
C     WILL BE SET IN POSITION LATER.        
C        
  400 DO 410 IEC = 2,4        
  410 ECPT(IEC) = 0.0        
C        
C     FETCH MATERIAL PROPERTIES        
C        
C        
C     EACH MATERIAL PROPERTY MATRIX G HAS TO BE TRANSFORMED FROM        
C     THE MATERIAL COORDINATE SYSTEM TO THE ELEMENT COORDINATE        
C     SYSTEM. THESE STEPS ARE TO BE FOLLOWED-        
C        
C     1- IF MCSID HAS BEEN SPECIFIED, SUBROUTINE TRANSS IS CALLED       
C        TO CALCULATE TBM-MATRIX (MATERIAL TO BASIC TRANSFORMATION).    
C        TBM-MATRIX IS THEN PREMULTIPLIED BY TEB-MATRIX TO OBTAIN       
C        TEM-MATRIX.        
C        THEN USING THE PROJECTION OF X-AXIS, AN ANGLE IS CALCULATED    
C        UPON WHICH STEP 2 IS TAKEN.        
C        
C     2- IF THETAM HAS BEEN SPECIFIED, SUBROUTINE ANGTRS IS CALLED      
C        TO CALCULATE TEM-MATRIX (MATERIAL TO ELEMENT TRANSFORMATION).  
C        
C                         T        
C     3-           G  =  U   G   U        
C                   E         M        
C        
C        
      IF (NEST(11) .EQ. 0) GO TO 470        
      MCSID = NEST(10)        
C        
C     CALCULATE TEM-MATRIX USING MCSID        
C        
  420 IF (MCSID .GT. 0) GO TO 440        
      DO 430 I = 1,9        
  430 TEM(I) = TEB(I)        
      GO TO 450        
  440 NECPT(1) = MCSID        
      CALL TRANSS (ECPT,TBM)        
C        
C     MULTIPLY TEB AND TBM MATRICES        
C        
      CALL GMMATS (TEB,3,3,0,TBM,3,3,0,TEM)        
C        
C     CALCULATE THETAM FROM THE PROJECTION OF THE X-AXIS OF THE        
C     MATERIAL C.S. ON TO THE XY PLANE OF THE ELEMENT C.S.        
C        
  450 CONTINUE        
      XM = TEM(1)        
      YM = TEM(4)        
      IF (ABS(XM).GT.EPS1 .OR. ABS(YM).GT.EPS1) GO TO 460        
      NEST(2) = MCSID        
      J = 231        
      GO TO 1720        
  460 THETAM = ATAN2(YM,XM)        
      GO TO 480        
C        
C     CALCULATE TEM-MATRIX USING THETAM        
C        
  470 THETAM = EST(10)*DEGRAD        
      IF (THETAM .EQ. 0.0) GO TO 490        
  480 CALL ANGTRS (THETAM,1,TUM)        
      CALL GMMATS (TEU,3,3,0,TUM,3,3,0,TEM)        
      GO TO 510        
C        
C     DEFAULT IS CHOSEN, LOOK FOR VALUES OF MCSID AND/OR THETAM        
C     ON THE PSHELL CARD.        
C        
  490 IF (NEST(24) .EQ. 0) GO TO 500        
      MCSID = NEST(23)        
      GO TO 420        
C        
  500 THETAM = EST(23)*DEGRAD        
      GO TO 480        
C        
  510 CONTINUE        
      IF (HEAT) GO TO 1810        
C        
      DO 600 M = 1,36        
  600 GI(M)  = 0.0        
      SINMAT = 0.0        
      COSMAT = 0.0        
      IGOBK  = 0        
C        
C     BEGIN M-LOOP TO FETCH PROPERTIES FOR EACH MATERIAL ID        
C        
      M = 0        
  610 M = M + 1        
      IF (M .GT. 4) GO TO 790        
      IF (M.EQ.4 .AND. IGOBK.EQ.1) GO TO 800        
      MATID = MID(M)        
      IF (MATID.EQ.0 .AND. M.NE.3) GO TO 610        
      IF (MATID.EQ.0 .AND. M.EQ.3 .AND. .NOT.BENDNG) GO TO 610        
      IF (MATID.EQ.0 .AND. M.EQ.3 .AND. BENDNG) MATID = MID(2)        
C        
      IF (M-1) 640,630,620        
  620 IF (MATID.EQ.MID(M-1) .AND. IGOBK.EQ.0) GO TO 640        
  630 CALL MAT (ELID)        
  640 CONTINUE        
C        
      IF (MEMBRN .AND. M.EQ.1) RHO=MATOUT(7)        
      RHOX = RHO        
      IF (RHO .EQ. 0.0) RHOX = 1.0        
      IF (KGG1 .EQ.  0) GO TO 610        
C        
      IF (MEMBRN .AND. M.NE.1 .OR. .NOT.MEMBRN .AND. M.NE.2) GO TO 650  
      GSUBE = MATOUT(12)        
      IF (MATSET .EQ. 8.) GSUBE = MATOUT(16)        
  650 CONTINUE        
C        
      IF (M.EQ.2 .AND. NORPTH) GO TO 670        
      COEFF  = 1.0        
      LPOINT = (M-1)*9 + 1        
C        
      CALL Q4GMGS (M,COEFF,GI(LPOINT))        
C        
      IF (M .GT. 0) GO TO 670        
      IF (.NOT.SHRFLX .AND. BENDNG) GO TO 660        
      NEST(2) = MATID        
      J = 232        
      GO TO 1720        
C        
  660 M = -M        
C 670 IF (.NOT.BENDNG) GO TO 760        
  670 CONTINUE        
      MTYPE = IFIX(MATSET+.05) - 2        
      IF (NOCSUB) GO TO 760        
      GO TO (760,680,720,760), M        
C        
  680 IF (MTYPE) 690,700,710        
  690 ENORX = MATOUT(16)        
      ENORY = MATOUT(16)        
      GO TO 760        
  700 ENORX = MATOUT(1)        
      ENORY = MATOUT(4)        
      GO TO 760        
  710 ENORX = MATOUT(1)        
      ENORY = MATOUT(3)        
      GO TO 760        
C        
  720 IF (MTYPE) 730,740,750        
  730 GNORX = MATOUT(6)        
      GNORY = MATOUT(6)        
      GO TO 760        
C        
  740 GNORX = MATOUT(1)        
      GNORY = MATOUT(4)        
      GO TO 760        
C        
  750 GNORX = MATOUT(6)        
      GNORY = MATOUT(5)        
      IF (GNORX .EQ. 0.0) GNORX = MATOUT(4)        
      IF (GNORY .EQ. 0.0) GNORY = MATOUT(4)        
  760 CONTINUE        
C        
C        
C     IF (MATSET .EQ. 1.0) GO TO 610        
      IF (M .EQ. 3) GO TO 770        
      U(1) = TEM(1)*TEM(1)        
      U(2) = TEM(4)*TEM(4)        
      U(3) = TEM(1)*TEM(4)        
      U(4) = TEM(2)*TEM(2)        
      U(5) = TEM(5)*TEM(5)        
      U(6) = TEM(2)*TEM(5)        
      U(7) = TEM(1)*TEM(2)*2.0        
      U(8) = TEM(4)*TEM(5)*2.0        
      U(9) = TEM(1)*TEM(5) + TEM(2)*TEM(4)        
      L = 3        
      GO TO 780        
C        
  770 U(1) = TEM(5)*TEM(9) + TEM(6)*TEM(8)        
      U(2) = TEM(2)*TEM(9) + TEM(8)*TEM(3)        
      U(3) = TEM(4)*TEM(9) + TEM(7)*TEM(6)        
      U(4) = TEM(1)*TEM(9) + TEM(3)*TEM(7)        
      L=2        
C        
  780 CALL GMMATS (U(1),L,L,1,GI(LPOINT),L,L,0,GT(1))        
      CALL GMMATS (GT(1),L,L,0,U(1),L,L,0,GI(LPOINT))        
      GO TO 610        
C        
C     END OF M-LOOP        
C        
  790 CONTINUE        
      IF (MID(3) .LT. 100000000) GO TO 800        
      IF (GI(19).NE.0.0 .OR. GI(20).NE.0.0 .OR. GI(21).NE.0.0 .OR.      
     1    GI(22).NE.0.0) GO TO 800        
      IGOBK = 1        
      M = 2        
      MID(3) = MID(2)        
      GO TO 610        
  800 CONTINUE        
C        
      NOCSUB = ENORX.EQ.0.0 .OR. ENORY.EQ.0.0 .OR.        
     1         GNORX.EQ.0.0 .OR. GNORY.EQ.0.0 .OR.        
     2         MOMINR.EQ.0.0        
C        
      MATTYP = IFIX(MATSET+.05)        
C        
C     IF MGG1 IS NON-ZERO AND RHO IS GREATER THAN 0.0,        
C     THEN COMPUTE THE MASS MATRIX.        
C        
      IF (MGG1 .EQ. 0) GO TO 810        
      IF (JCORED+144 .LE. NCORED) GO TO 810        
      GO TO 1730        
  810 CONTINUE        
C        
      LIMIT = JCORED + NDOF*NDOF        
      DO 820 I = JCORED,LIMIT        
  820 AKGG(I)  = 0.0        
      DO 830 I = 1,NODESQ        
      XMASS(I) = 0.0        
  830 XMTMP(I) = 0.0        
      AREA = 0.0        
      VOL  = 0.0        
C        
C        
C     HERE BEGINS THE TRIPLE LOOP ON STATEMENTS 1310 AND 1300 TO        
C     GAUSS INTEGRATE FOR THE ELEMENT MASS AND STIFFNESS MATRICES.      
C     -----------------------------------------------------------       
C        
      DO 1310 IXSI = 1,2        
      XI = PTINT(IXSI)        
      DO 1310 IETA = 1,2        
      ETA = PTINT(IETA)        
      CALL Q4SHPS (XI,ETA,SHP,DSHP)        
C        
C     SORT THE SHAPE FUNCTIONS AND THEIR DERIVATIVES INTO SIL ORDER.    
C        
      DO 900 I = 1,4        
      TMPSHP(I  ) =  SHP(I  )        
      DSHPTP(I  ) = DSHP(I  )        
  900 DSHPTP(I+4) = DSHP(I+4)        
      DO 910 I = 1,4        
      KK = IORDER(I)        
      SHP (I  ) = TMPSHP(KK  )        
      DSHP(I  ) = DSHPTP(KK  )        
  910 DSHP(I+4) = DSHPTP(KK+4)        
      CALL GMMATS (SHP,1,NNODE,0,DGPTH,1,NNODE,1,THK)        
      REALI = MOMINR*THK*THK*THK/12.0        
C     REALI =        THK*THK*THK/12.0        
      TSI   = TS*THK        
C        
C     SKIP MASS CALCULATIONS IF NOT REQUESTED        
C        
      IF (NSM  .NE. 0.) GO TO 920        
      IF (MGG1 .EQ. 0 ) GO TO 1020        
      IF (RHO  .EQ. 0.) GO TO 1020        
      IF (RHO  .GT. 0.) GO TO 920        
      WRITE (NOUT,2030) UWM,RHO,MID(1),NEST(1)        
C     NOGO =.TRUE.        
C     GO TO 1710        
  920 CONTINUE        
C        
C     COMPUTE S AND T VECTORS AT THE MID-SURFACE        
C     FOR MASS CALCULATIONS ONLY.        
C        
      DO 930 I = 1,2        
      IPOINT = 4*(I-1)        
      DO 930 J = 1,3        
      V(I,J) = 0.0        
      DO 930 K = 1,NNODE        
      KTEMP = K + IPOINT        
      JTEMP = J + 1        
      V(I,J)= V(I,J) + DSHP(KTEMP)*BGPDT(JTEMP,K)        
  930 CONTINUE        
C        
C     COMPUTE S CROSS T AT THE MID-SURFACE FOR MASS CALCULATIONS.       
C        
      V(3,1) = V(1,2)*V(2,3) - V(2,2)*V(1,3)        
      V(3,2) = V(1,3)*V(2,1) - V(2,3)*V(1,1)        
      V(3,3) = V(1,1)*V(2,2) - V(2,1)*V(1,2)        
      AREA2  = V(3,1)*V(3,1) + V(3,2)*V(3,2) + V(3,3)*V(3,3)        
C        
C     AREA2 = NORM OF S CROSS T IS THE AREA OF THE ELEMENT        
C     AS COMPUTED AT THIS GAUSS POINT.        
C        
      IF (AREA2 .LT. EPS1) GO TO 1700        
C        
      AREA2 = SQRT(AREA2)        
      AREA  = AREA + AREA2        
      VOLI  = AREA2*THK        
      VOL   = VOL + VOLI        
C        
      IF (MGG1   .EQ. 0) GO TO 1020        
      IF (CPMASS .GT. 0) GO TO 1000        
      I4 = 1        
      DO 960 J4 = 1,NNODE        
      XMASS(I4) = XMASS(I4) + VOLI*RHOX*SHP(J4)        
  960 I4 = I4 + NNODE + 1        
      GO TO 1020        
C        
C     COMPUTE CONSISTENT MASS MATRIX        
C        
C     COMPUTE THE CONTRIBUTION TO THE MASS MATRIX        
C     FROM THIS INTEGRATION POINT.        
C        
 1000 CALL GMMATS (SHP,1,NNODE,1,SHP,1,NNODE,0,XMTMP)        
C        
C     ADD MASS CONTRIBUTION FROM THIS INTEGRATION POINT        
C     TO THE ELEMENT MASS MATRIX.        
C        
      DO 1010 I = 1,NODESQ        
 1010 XMASS(I) = XMASS(I) + VOLI*RHOX*XMTMP(I)        
C        
 1020 IF (KGG1 .EQ. 0) GO TO 1330        
C        
C     BEGIN STIFFNESS COMPUTATIONS        
C        
C     SET DEFAULT VALUES OF CSUBB FACTORS        
C        
      SFCTY1 = 1.0        
      SFCTY2 = 1.0        
      SFCTX1 = 1.0        
      SFCTX2 = 1.0        
      TSMFX  = 1.0        
      TSMFY  = 1.0        
      IF (NOCSUB) GO TO 1090        
      IF (.NOT.BENDNG) GO TO 1090        
C     NUNORX = MOMINR*ENORX/(2.0*GNORX) - 1.0        
C     NUNORY = MOMINR*ENORY/(2.0*GNORY) - 1.0        
C        
C     NOTE- THE ABOVE EXPRESSIONS FOR NUNORX AND NUNORY WERE MODIFIED   
C           BY G.CHAN/UNISYS    1988        
C        
      EIX = MOMINR*ENORX        
      EIY = MOMINR*ENORY        
      TGX = 2.0*GNORX        
      TGY = 2.0*GNORY        
      NUNORX = EIX/TGX - 1.0        
      NUNORY = EIY/TGY - 1.0        
      IF (EIX .GT. TGX) NUNORX = 1.0 - TGX/EIX        
      IF (EIY .GT. TGY) NUNORY = 1.0 - TGY/EIY        
      IF (NUNORX .GT. 0.999999) NUNORX = 0.999999        
      IF (NUNORY .GT. 0.999999) NUNORY = 0.999999        
C     IF (NUNORX .GT. .49) NUNORX = 0.49        
C     IF (NUNORY .GT. .49) NUNORY = 0.49        
      CC = ASPECT        
C        
C     NOTE- THE FOLLOWING 2 FORMULATIONS WERE PUT IN ON 4/30/85 IN      
C           CONJUNCTION WITH THE OUT-OF-PLANE SHEAR CORRECTION A LA     
C           HUGHES. THE FLEXIBLE SOLUTION PROVIDES MORE ACCURATE        
C           RESULTS FOR PLATES, ALTHOUGH IT MIGHT CONVERGE SLOWLY.      
C           THE STIFFER SOLUTION (COMMENTED OUT) IS O.K. FOR PLATES     
C           AND SHOULD HAVE A BETTER CONVERGENCE.        
C        
C           THEY WERE MODIFIED ON 5/3/85        
C        
C        
C     4-NODE CSUBB FORMULATION AS OF 5/3/85 (FLEXIBLE SOLUTION)        
C     REPLACES THE ONE COMMENTED OUT IMMEDIATELY ABOVE        
C        
      W1 = 1.0 + 4400.0*THLEN*THLEN*THLEN*THLEN        
      IF (CC .LT. 0.2) GO TO 1030        
      DSUB4 = (18.375-11.875*CC)*W1        
      GO TO 1040        
 1030 DSUB4 = (159.85*CC-15.97)*W1        
C        
C     4-NODE CSUBB FORMULATION AS OF 5/3/85 (STIFFER SOLUTION)        
C        
C     W1 = 1.0 + 2.5*THLEN + 1.04*THLEN**5        
C     IF (CC .LT. 0.2) GO TO 1030        
C     DSUB4 = 18.0*W1        
C     GO TO 1040        
C1030 DSUB4 = (179.85*CC-17.97)*W1        
 1040 IF (DSUB4 .LT.   0.01) DSUB4 = 0.01        
      IF (DSUB4 .GT. 2000.0) DSUB4 = 2000.0        
      DSUB  = DSUB4        
      COEFT = CONST        
      AX    = A        
      IF (ETA .LT. 0.0) AX = A + COEFT*(XA(2)-XA(1)-A)        
      IF (ETA .GT. 0.0) AX = A + COEFT*(XA(3)-XA(4)-A)        
      PSIINX = 20.0*DSUB*REALI*SINEAX*(1.0+ASPECT*ASPECT)/        
     1         (TSI*(1.0-NUNORX)*AX*AX)        
      DSUB  = DSUB4        
      COEFT = CONST        
      BY    = B        
      IF (XI .LT. 0.0) BY = B + COEFT*(YB(4)-YB(1)-B)        
      IF (XI .GT. 0.0) BY = B + COEFT*(YB(3)-YB(2)-B)        
      PSIINY = 20.0*DSUB*REALI*SINEAY*(1.0+ASPECT*ASPECT)/        
     1         (TSI*(1.0-NUNORY)*BY*BY)        
      IF (.NOT.SHRFLX) GO TO 1050        
      TSMFX = PSIINX/(1.0+PSIINX)        
      TSMFY = PSIINY/(1.0+PSIINY)        
      GO TO 1060        
 1050 TSMFX = PSIINX        
      TSMFY = PSIINY        
      GO TO 1060        
C        
 1060 CONTINUE        
      IF (TSMFX .LE. 0.0) TSMFX = EPS1        
      IF (TSMFY .LE. 0.0) TSMFY = EPS1        
C        
C     FILL IN THE 7X7 MATERIAL PROPERTY MATRIX D FOR NORPTH        
C        
      IF (.NOT.NORPTH) GO TO 1090        
      DO 1070 IG = 1,7        
      DO 1070 JG = 1,7        
 1070 DFOUR(IG,JG) = 0.0        
C        
      DO 1080 IG = 1,3        
      IG1 = (IG-1)*3        
      DO 1080 JG = 1,3        
      JG1 = JG + IG1        
 1080 DFOUR(IG,JG) = GI(JG1)        
      GO TO 1150        
C        
C     FILL IN THE 10X10 G-MATRIX WHEN MID4 IS NOT PRESENT        
C        
 1090 DO 1100 IG = 1,10        
      DO 1100 JG = 1,10        
 1100 GFOUR(IG,JG) = 0.0        
      IF (MBCOUP) GO TO 1150        
C        
      IF (.NOT.MEMBRN) GO TO 1120        
      DO 1110 IG = 1,3        
      IG1 = (IG-1)*3        
      DO 1110 JG = 1,3        
      JG1 = JG + IG1        
 1110 GFOUR(IG,JG) = GI(JG1)        
C        
 1120 IF (.NOT.BENDNG) GO TO 1250        
      DO 1130 IG = 4,6        
      IG2 = (IG-2)*3        
      DO 1130 JG = 4,6        
      JG2 = JG + IG2        
 1130 GFOUR(IG,JG) = GI(JG2)*MOMINR        
C        
      IF (.NOT.MEMBRN) GO TO 1150        
      DO 1140 IG = 1,3        
      IG1 = (IG-1)*3        
      KG  = IG + 3        
      DO 1140 JG = 1,3        
      JG1 = JG + IG1        
      LG  = JG + 3        
      GFOUR(IG,LG) = GI(JG1)        
 1140 GFOUR(KG,JG) = GI(JG1)        
 1150 CONTINUE        
C        
C     IRREGULAR 4-NODE CODE-  CALCULATION OF NODAL EDGE SHEARS        
C                             AT THIS INTEGRATION POINT        
C        
      DO 1210 IJ = 1,4        
      II = IJ - 1        
      IF (II .EQ. 0) II = 4        
      IK = IJ + 1        
      IF (IK .EQ. 5) IK = 1        
C        
      DO 1160 IR = 1,4        
      IF (IJ .NE. IORDER(IR)) GO TO 1160        
      IOJ = IR        
      GO TO 1170        
 1160 CONTINUE        
 1170 DO 1180 IR = 1,4        
      IF (IK .NE. IORDER(IR)) GO TO 1180        
      IOK = IR        
      GO TO 1190        
 1180 CONTINUE        
 1190 AA = SHP(IOJ)        
      BB = SHP(IOK)        
C        
      DO 1200 IS = 1,3        
      EDGSHR(IS,IJ) = (UEV(IS,IJ)+ANGLEI(IJ)*UEV(IS,II))*AA/        
     1                (1.0-ANGLEI(IJ)*ANGLEI(IJ))        
     2              + (UEV(IS,IJ)+ANGLEI(IK)*UEV(IS,IK))*BB/        
     3                (1.0-ANGLEI(IK)*ANGLEI(IK))        
 1200 CONTINUE        
 1210 CONTINUE        
C        
C     TORSION-RELATED SHEAR CORRECTION FOR 4-NODE-        
C     SET-UP OF EXPANDED SHEAR MATERIAL PROPERTY MATRICES (G OR D)      
C        
      CSUBX  = 20.0*REALI/(TSI*(1.0-NUNORX)*A*A)        
      CSUBY  = 20.0*REALI/(TSI*(1.0-NUNORY)*B*B)        
      SFCTR1 = CSUBB4*CSUBX        
      SFCTR2 = CSUBTX*CSUBX        
      IF (.NOT.SHRFLX) GO TO 1220        
      SFCTR1 = SFCTR1/(1.0+SFCTR1)        
      SFCTR2 = SFCTR2/(1.0+SFCTR2)        
 1220 CONTINUE        
      SFCTX1 = SFCTR1 + SFCTR2        
      SFCTX2 = SFCTR1 - SFCTR2        
      SFCTR1 = CSUBB4*CSUBY        
      SFCTR2 = CSUBTY*CSUBY        
      IF (.NOT.SHRFLX) GO TO 1230        
      SFCTR1 = SFCTR1/(1.0+SFCTR1)        
      SFCTR2 = SFCTR2/(1.0+SFCTR2)        
 1230 CONTINUE        
      SFCTY1 = SFCTR1 + SFCTR2        
      SFCTY2 = SFCTR1 - SFCTR2        
C        
C     FILL IN THE EXPANDED MATERIAL PROPERTY MATRIX        
C        
      IF (NORPTH) GO TO 1240        
      GFOUR( 7, 7) = 0.25*SFCTY1*TS*GI(19)        
      GFOUR( 8, 8) = 0.25*SFCTY1*TS*GI(19)        
      GFOUR( 8, 7) = 0.25*SFCTY2*TS*GI(19)        
      GFOUR( 7, 8) = GFOUR(8,7)        
      GFOUR( 9, 9) = 0.25*SFCTX1*TS*GI(22)        
      GFOUR(10,10) = 0.25*SFCTX1*TS*GI(22)        
      GFOUR(10, 9) = 0.25*SFCTX2*TS*GI(22)        
      GFOUR( 9,10) = GFOUR(10,9)        
      GFOUR( 7, 9) = SQRT(TSMFX*TSMFY)*TS*GI(20)        
      GFOUR( 9, 7) = GFOUR(7,9)        
      GO TO 1250        
C        
 1240 DFOUR(4,4) = 0.25*SFCTY1*TS*GI(19)        
      DFOUR(5,5) = 0.25*SFCTY1*TS*GI(19)        
      DFOUR(5,4) = 0.25*SFCTY2*TS*GI(19)        
      DFOUR(4,5) = DFOUR(5,4)        
      DFOUR(6,6) = 0.25*SFCTX1*TS*GI(22)        
      DFOUR(7,7) = 0.25*SFCTX1*TS*GI(22)        
      DFOUR(7,6) = 0.25*SFCTX2*TS*GI(22)        
      DFOUR(6,7) = DFOUR(7,6)        
      DFOUR(4,6) = SQRT(TSMFX*TSMFY)*TS*GI(20)        
      DFOUR(6,4) = DFOUR(4,6)        
 1250 CONTINUE        
C        
C     DO 1300 IZTA = 1,JZTA        
      DO 1300 IZTA = 1,2        
      ZTA  = PTINT(IZTA)        
      IBOT = (IZTA-1)*ND2        
C        
      HZTA = ZTA/2.0        
C        
C     TORSION-RELATED SHEAR CORRECTION FOR 4-NODE-        
C     SET-UP OF POINTERS TO THE SAVED B-MATRIX        
C        
      IPTX1 = ((IXSI-1)*2+IETA-1)*2*ND2 + IBOT        
      IPTX2 = ((IXSI-1)*2+2-IETA)*2*ND2 + IBOT        
      IPTY1 = ((IXSI-1)*2+IETA-1)*2*ND2 + IBOT        
      IPTY2 = ((2-IXSI)*2+IETA-1)*2*ND2 + IBOT        
C     IF (NORPTH) IBOT = IBOT/2        
C        
C     FILL IN THE 10X10 G-MATRIX IF MID4 IS PRESENT        
C        
      IF (.NOT.MBCOUP) GO TO 1290        
      DO 1260 IG = 1,3        
      IG1 = (IG-1)*3        
      DO 1260 JG = 1,3        
      JG1 = JG  + IG1        
      JG4 = JG1 + 27        
 1260 GFOUR(IG,JG) = GI(JG1)        
C        
      DO 1270 IG = 4,6        
      IG2 = (IG-2)*3        
      DO 1270 JG = 4,6        
      JG2 = JG  + IG2        
      JG4 = JG2 + 18        
 1270 GFOUR(IG,JG) = GI(JG2)*MOMINR        
C        
      DO 1280 IG = 1,3        
      IG4 = (IG+8)*3        
      KG  = IG + 3        
      DO 1280 JG = 1,3        
      JG4 = JG  + IG4        
      JG1 = JG4 - 27        
      LG  = JG  + 3        
      GFOUR(IG,LG) =-GI(JG4)*ZTA*6.0+GI(JG1)        
 1280 GFOUR(KG,JG) =-GI(JG4)*ZTA*6.0+GI(JG1)        
 1290 CONTINUE        
C        
C     COMPUTE THE JACOBIAN AT THIS GAUSS POINT,        
C     ITS INVERSE AND ITS DETERMINANT.        
C        
      CALL JACOBS (ELID,SHP,DSHP,DGPTH,EGPDT,EPNORM,JACOB)        
      IF (BADJAC) GO TO 1710        
C        
C     COMPUTE PSI TRANSPOSE X JACOBIAN INVERSE.        
C     HERE IS THE PLACE WHERE THE INVERSE JACOBIAN IS FLAGED TO BE      
C     TRANSPOSED BECAUSE OF OPPOSITE MATRIX LOADING CONVENTION        
C     BETWEEN INVER AND GMMAT.        
C        
      CALL GMMATS (PSITRN,3,3,0,JACOB,3,3,1,PHI)        
C        
C     CALL Q4BMGS TO GET B-MATRIX.  SET THE ROW FLAG TO 3.        
C     IT WILL RETURN THE FIRST 6 ROWS OF B-MATRIX.        
C        
      ROWFLG = 3        
      CALL Q4BMGS (DSHP,DGPTH,EGPDT,EPNORM,PHI,BFOUR(1))        
C        
C     SET-UP OF B-MATRIX AND TRIPLE MULTIPLY        
C        
      CALL TRPLMS (GFOUR,DFOUR,BFOUR,BMAT1,XYBMAT,MATTYP,JCORED,DETJ)   
 1300 CONTINUE        
 1310 CONTINUE        
C        
C     EQUALIZE THE OFF-DIAGONAL TERMS TO GUARANTEE PERFECT SYMMETRIC    
C     MATRIX IF NO DAMPING INVOLVED        
C        
      IF (GSUBE .NE. 0.0) GO TO 1330        
      IJ = JCORED - 1        
      NDOFM1 = NDOF - 1        
      DO 1320 II = 1,NDOFM1        
      IP1 = II + 1        
      IM1 =(II-1)*NDOF + IJ        
      DO 1320 JJ = IP1,NDOF        
      I = IM1 + JJ        
      J = (JJ-1)*NDOF + II + IJ        
      TEMP = (AKGG(I) + AKGG(J))*.5        
      IF (ABS(TEMP) .LT. 1.0E-17) TEMP = 0.0        
      AKGG(I) = TEMP        
      AKGG(J) = TEMP        
 1320 CONTINUE        
C        
C     END OF STIFFNESS LOOP        
C        
C     ADD NON-STRUCTURAL MASS        
C        
 1330 CONTINUE        
      IF (MGG1 .EQ. 0) GO TO 1410        
      IF (RHO.EQ.0.0 .AND. NSM.EQ.0.0) GO TO 1410        
C     IF (CPMASS .GT. 0) GO TO 1410        
      IF (NSM  .EQ. 0.0) GO TO 1410        
      IF (VOL.EQ.0. .OR. RHOX.EQ.0.) WRITE (NOUT,2060) SFM,ELID,AREA,   
     1                               VOL,RHOX,MGG1,KGG1        
      FACTOR = (VOL*RHO+NSM*AREA)/(VOL*RHOX)        
      DO 1400 I = 1,NODESQ        
 1400 XMASS(I) = XMASS(I)*FACTOR        
 1410 CONTINUE        
C        
C     PICK UP THE GLOBAL TO BASIC TRANSFORMATIONS FROM THE CSTM.        
C        
      DO 1412 I = 1,36        
 1412 TRANS(I) = 0.0        
C     DO 1414 I = 2,8        
C1414 TRANS1(I) = 0.0        
C     TRANS1(1) = 1.0        
C     TRANS1(5) = 1.0        
C     TRANS1(9) = 1.0        
C        
      DO 1450 I = 1,NNODE        
      NOTRAN(I) = 0        
      IPOINT = 9*(I-1) + 1        
      IF (IGPDT(1,I) .LE. 0) GO TO 1420        
      IGPTH(1) = IGPDT(1,I)        
      GPTH(2)  = BGPDT(2,I)        
      GPTH(3)  = BGPDT(3,I)        
      GPTH(4)  = BGPDT(4,I)        
C        
C     NOTE THAT THE 6X6 TRANSFORMATION WHICH WILL BE USED LATER        
C     IN THE TRIPLE MULTIPLICATION TO TRANSFORM THE ELEMENT        
C     STIFFNESS MATRIX FROM BASIC TO GLOBAL COORDINATES, IS BUILT       
C     UPON THE 3X3 TRANSFORMATION FROM GLOBAL TO BASIC TBG-MATRIX.      
C     THIS IS DUE TO THE DIFFERENCE IN TRANSFORMATION OF ARRAYS        
C     AND MATRICES.        
C        
      CALL TRANSS (GPTH,TBG)        
      CALL GMMATS (TEB,3,3,0,TBG,3,3,0,TRANS(IPOINT))        
      GO TO 1450        
C        
 1420 IF (IDENTT.NE.1 .OR. OFFSET.NE.0.0) GO TO 1430        
      NOTRAN(I) = 1        
      GO TO 1450        
C        
 1430 DO 1440 J = 1,9        
 1440 TRANS(IPOINT+J-1) = TEB(J)        
 1450 CONTINUE        
C        
C        
C     HERE WE SHIP OUT THE STIFFNESS AND DAMPING MATRICES.        
C     ---------------------------------------------------        
C        
      IF (KGG1 .EQ. 0) GO TO 1600        
C        
C     SET UP I-LOOP TO DUMP OUT BASIC TO GLOBAL TRANSFORMED, NODAL      
C     PARTITIONED (6 D.O.F. PER NODE) COLUMNS OF THE ELEMENT STIFFNESS. 
C        
C     THIS MEANS WE ARE SENDING TO EMGOUT 6 COLUMNS OF THE ELEMENT      
C     STIFFNESS MATRIX AT TIME.  EACH BUNCH OF 6 COLUMNS CORRESPOND     
C     TO ONE PARTICULAR NODE OF THE ELEMENT. FOR THE MASS MATRIX, WE    
C     ONLY SEND 3 COLUMNS PER NODE TO EMGOUT SINCE THE OTHER 3 D.O.F.   
C     ARE ZERO ANYWAY.  THE CODE WORD (DICT(4)) TELLS EMGOUT WHICH      
C     COLUMNS ARE THE NON ZERO ONES THAT WE ARE SENDING. (SEE SECTION   
C     6.8.3.5.1 OF THE PROGRAMMER MANUAL)        
C        
C        
      DICT(1) = ESTID        
      DICT(2) = 1        
      DICT(3) = NDOF        
      DICT(4) = 63        
      NPART   = NDOF*6        
      DO 1560 I = 1,NNODE        
      IBEGIN = 6*(I-1) + JCORED - 1        
C        
C     DUMP AN UNTRANSFORMED NODAL COLUMN PARTITION.        
C        
      DO 1500 J = 1,NDOF        
      KPOINT = NDOF*(J-1) + IBEGIN        
      LPOINT = 6*(J-1)        
      DO 1500 K = 1,6        
 1500 COLSTF(LPOINT+K) = AKGG(KPOINT+K)        
      IF (NOTRAN(I) .EQ. 1) GO TO 1515        
C        
C     THIS COLUMN PARTITION NEEDS TO BE TRANSFORMED TO GLOBAL        
C     COORDINATES. (SEE PAGE 2.3-43 OF THE PROGRAMMER)        
C        
C     LOAD THE 6X6 TRANSFORMATION        
C        
      CALL TLDRS (OFFSET,I,TRANS,TRANS1)        
C        
C     TRANSFORM THE NODAL COLUMN PARTITION.        
C        
      CALL GMMATS (COLSTF,NDOF,6,0,TRANS1,6,6,0,COLTMP)        
      DO 1510 II = 1,NPART        
 1510 COLSTF(II) = COLTMP(II)        
C        
C     NOW TRANSFORM THE ROWS OF THIS PARTITION.        
C        
 1515 DO 1530 M = 1,NNODE        
      IF (NOTRAN(M) .EQ. 1) GO TO 1530        
      MPOINT = 36*(M-1) + 1        
C        
C     LOAD THE 6X6 TRANSFORMATION        
C        
      CALL TLDRS (OFFSET,M,TRANS,TRANS1)        
C        
C     TRANSFORM THE 6 ROWS FOR THIS SUBPARTITION        
C        
      CALL GMMATS (TRANS1,6,6,1,COLSTF(MPOINT),6,6,0,COLTMP)        
      IIPNT = MPOINT - 1        
      DO 1520 II = 1,36        
 1520 COLSTF(IIPNT+II) = COLTMP(II)        
 1530 CONTINUE        
C        
C     HERE WE MUST CHANGE FROM THE ROW LOADING CONVENTION        
C     FOR GMMATS TO THE COLUMN LOADING CONVENTION FOR EMGOUT.        
C        
      DO 1550 II = 1,6        
      IPOINT = NDOF*(II-1)        
      DO 1550 JJ = 1,NDOF        
      JPOINT = 6*(JJ-1)        
      COLTMP(IPOINT+JJ) = COLSTF(JPOINT+II)        
 1550 CONTINUE        
C        
C     DUMP THE TRANSFORMED NODAL COLUMN PARTITION        
C        
      IEOE = 0        
      IF (I .EQ. NNODE) IEOE = 1        
      ADAMP = GSUBE        
C        
C     INTEGER 1 IN THE NEXT TO LAST FORMAL PARAMETER OF        
C     EMGOUT MEANS WE ARE SENDING STIFFNESS DATA.        
C        
      CALL EMGOUT (COLTMP,COLTMP,NPART,IEOE,DICT,1,IPREC)        
 1560 CONTINUE        
C        
C        
C     HERE WE SHIP OUT THE MASS MATRIX.        
C     --------------------------------        
C        
 1600 IF (MGG1 .EQ. 0) GO TO 1710        
C        
      NDOF  = NNODE*3        
      NPART = NDOF*3        
      DICT(3) = NDOF        
      DICT(4) = 7        
      ADAMP = 0.0        
C        
C     SET UP I-LOOP TO PROCESS AND DUMP THE NODAL COLUMN PARTITIONS.    
C        
      DO 1690 I = 1,NNODE        
      DO 1610 IJK = 1,NPART        
 1610 AMGG(JCORED-1+IJK) = 0.0        
C        
C     SET UP J-LOOP TO LOAD THE UNTRANSFORMED NODAL COLUMN PARTITION.   
C        
      DO 1620 J = 1,NNODE        
      IPOINT = 9*(J-1) + JCORED        
      JPOINT = IPOINT  + 4        
      KPOINT = IPOINT  + 8        
      IFROM  = NNODE*(J-1) + I        
      XMASSO = XMASS(IFROM)        
      AMGG(IPOINT) = XMASSO        
      AMGG(JPOINT) = XMASSO        
      AMGG(KPOINT) = XMASSO        
 1620 CONTINUE        
      IF (NOTRAN(I) .EQ. 1) GO TO 1670        
C        
C     THIS COLUMN PARTITION NEEDS TO BE TRANSFORMED        
C     TO GLOBAL COORDINATES.        
C        
      DO 1640 M = 1,NNODE        
      MPOINT = 9*(M-1) + JCORED        
      CALL GMMATS (AMGG(MPOINT),3,3,0,TRANS(9*I-8),3,3,0,TMPMAS)        
      IICORE = MPOINT - 1        
      DO 1630 K = 1,9        
 1630 AMGG(IICORE+K) = TMPMAS(K)        
 1640 CONTINUE        
C        
C     SET UP M-LOOP TO TRANSFORM THE NODAL ROW PARTITIONS        
C     OF THIS NODAL COLUMN PARTITION.        
C        
      DO 1660 M = 1,NNODE        
      MPOINT = 9*(M-1) + JCORED        
C        
C     TRANSFORM THE 3 ROWS FOR THIS SUBPARTITION.  THIS IS CORRECT      
C     (3 ROWS).  REMEMBER THAT FOR THE MASS MATIIX FOR THIS ELEMENT     
C     THERE ARE NO MASS MOMENT OF INERTIA TERMS.  THIS GIVES THREE      
C     ROWS OF ZERO TERMS INTERSPERSED BETWEEN 3 ROWS OF NONZERO        
C     TRANSLATIONAL MASS TERMS FOR EACH NODE.        
C        
      CALL GMMATS (TRANS(9*M-8),3,3,1,AMGG(MPOINT),3,3,0,TMPMAS)        
      IICORE = MPOINT - 1        
      DO 1650 K = 1,9        
 1650 AMGG(IICORE+K) = TMPMAS(K)        
 1660 CONTINUE        
C        
C     HERE WE MUST CHANGE FROM THE ROW LOADING CONVENTION        
C     FOR GMMATS TO THE COLUMN LOADING CONVENTION FOR EMGOUT.        
C        
 1670 DO 1680 II = 1,3        
      IPOINT = NDOF*(II-1)        
      DO 1680 JJ = 1,NDOF        
      JPOINT = 3*(JJ-1) + JCORED - 1        
 1680 COLTMP(IPOINT+JJ) = AMGG(JPOINT+II)        
C        
C     DUMP THIS TRANSFORMED MASS NODAL COLUMN PARTITION.        
C        
      IEOE = 0        
      IF (I .EQ. NNODE) IEOE = 1        
C        
C     INTEGER 2 IN THE NEXT TO LAST FORMAL PARAMETER OF        
C     EMGOUT MEANS WE ARE SENDING MASS DATA.        
C        
      CALL EMGOUT (COLTMP,COLTMP,NPART,IEOE,DICT,2,IPREC)        
 1690 CONTINUE        
      GO TO 1710        
C        
 1700 J = 230        
      GO TO 1720        
C        
 1710 CONTINUE        
      RETURN        
C        
 1720 CALL MESAGE (30,J,NEST)        
      IF (L38 .EQ. 1) CALL MESAGE (-61,0,0)        
      NOGO = .TRUE.        
      GO TO 1710        
 1730 CALL MESAGE (-30,234,NAM)        
C        
C        
C     HEAT FLOW OPTION STARTS HERE.        
C        
C     WE NEED TO RESTORE THE ORIGIANL ORDER OF SILS AND BGPDT DATA      
C        
 1790 J = 1        
      DO 1800 I = 1,20        
      EST(I+J) = SAVE(I)        
      IF (I .EQ. 4) J = 24        
 1800 CONTINUE        
C        
      INFLAG = 2        
      COSMAT = 1.0        
      SINMAT = 0.0        
      MATID  = NEST(13)        
      CALL HMAT (ELID)        
      GI(1) = KHEAT(1)        
      GI(2) = KHEAT(2)        
      GI(3) = GI(2)        
      GI(4) = KHEAT(3)        
      ANIS  = TYPE.NE.4 .AND. TYPE.NE.-1        
C     OMMENT . ANIS = .FALSE. MEANS ISOTROPIC THERMAL CONDUCTIVITY.     
      IF (ANIS) GO TO 400        
      GO TO 1820        
 1810 CONTINUE        
      TEM(3) = TEM(4)        
      TEM(4) = TEM(5)        
      CALL GMMATS (TEM,2,2,0,GI,2,2,0,GT)        
      CALL GMMATS (GT,2,2,0,TEM,2,2,1,GI)        
 1820 CONTINUE        
      DO 1830 I = 1,16        
      HTCON(I) = 0.0        
      HTCAP(I) = 0.0        
 1830 CONTINUE        
      DO 1840 I = 5,8        
      HSIL(I) = 0        
 1840 HORDER(I) = 0        
C        
      DO 1890 IXSI = 1,2        
      XI = PTINT(IXSI)        
      DO 1890 IETA = 1,2        
      ETA = PTINT(IETA)        
C        
      DO 1870 IZTA = 1,2        
      ZETA = PTINT(IZTA)        
C        
      CALL TERMSS (NNODE,DGPTH,EPNORM,EGPDT,HORDER,HSIL,BTERMS)        
      DVOL = DETERM        
C        
      DO 1850 I = 1,4        
 1850 ECPT(I) = GI(I)*DVOL        
      WEITC = DVOL*HTCP        
C        
      IP = 1        
      DO 1860 I = 1,NNODE        
      IDN = I + NNODE        
      HTFLX(IP+1) = ECPT(3)*BTERMS(I) + ECPT(4)*BTERMS(IDN)        
      HTFLX(IP  ) = ECPT(1)*BTERMS(I) + ECPT(2)*BTERMS(IDN)        
 1860 IP = IP + 2        
      CALL GMMATS (BTERMS,2,NNODE,-1,HTFLX,NNODE,2,1,HTCON)        
C        
 1870 CONTINUE        
      IF (HTCP .EQ. 0.0) GO TO 1890        
      IP = 0        
      DO 1880 I = 1,NNODE        
      DHEAT = WEITC*SHP(I)        
      DO 1880 J = 1,NNODE        
      IP = IP + 1        
      HTCAP(IP) = HTCAP(IP) + DHEAT*SHP(J)        
 1880 CONTINUE        
 1890 CONTINUE        
      DICT(1) = ESTID        
      DICT(2) = 1        
      DICT(3) = NNODE        
      DICT(4) = 1        
      IF (HTCP .EQ. 0.0) GO TO 1900        
      ADAMP = 1.0        
      CALL EMGOUT (HTCAP,HTCAP,NODESQ,1,DICT,3,IPREC)        
 1900 CONTINUE        
      ADAMP = 0.0        
      CALL EMGOUT (HTCON,HTCON,NODESQ,1,DICT,1,IPREC)        
      GO TO 1710        
C        
 2010 FORMAT (A23,', THE ELEMENT THICKNESS FOR QUAD4 EID =',I9,        
     1       ' IS NOT COMPLETELY DEFINED.')        
 2030 FORMAT (A25,', RHO = ',1PD12.4,' IS ILLEGAL FROM MATERIAL ID =',  
     1       I9,' FOR QUAD4 EID =',I9)        
 2060 FORMAT (A25,', ZERO VOLUME OR DENSITY FOR QUAD4 ELEMENT ID =',I9, 
     1       ', AREA,VOL,RHO=',3E12.3, /70X,'MGG1,KGG1=',2I8)        
      END        
