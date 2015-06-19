      SUBROUTINE EM1D (ELTYPE,ISTART,ITYPE,NCOUNT,IDO,IWORDS,NBDYS,     
     1                 ALL,NELOUT)        
C        
C     COMPUTE LOAD DUE TO MAGNETIC FIELD,  K*A + F = 0        
C     SOLVE FOR -F        
C        
C     USE ELEMENT COORDINATES  FOR  ROD        
C        
C     SET UP COMMON BLOCKS, TABLES        
C        
C     KSYSTM(1) = 1ST POS. OF OPEN CORE        
C     KSYSTM(2) = OUTPUT FILE NO.        
C     KSYSTM(56) NE 0 FOR HEAT TRANSFER OPTION        
C        
C     Z      = OPEN CORE ARRAY        
C     OUTPT  = OUTPUT FILE NO.        
C     NELEMS = NO OF ELEMENTS (TYPES) IN THIS TABLE        
C     LAST   = LOC OF 1ST WORD OF LAST ENTRY(EL) IN TABLE        
C     INCR   = MAX NO WDS ALLOWED IN ANY ENTRY        
C        
C     BUF1   = BUFFER FOR EST        
C     EST    = ELEMENT SUMMARY TABLE(PROG MAN 2.3.56)        
C     SLT    = STAIC LOADS TABLE(2.3.51)        
C     SYSTEM 2.4.13 PROG MANUAL        
C     GPTA1  2.5.6        
C     EST    2.3.56        
C     SLT    2.3.51        
C        
C     ISTART GIVES 1ST POSITION OF HC OR REMFLUX VALUES        
C     ROD IS IN ELEMENT COORDINATES, AS ARE TUBE,CONROD,BAR        
C        
C     X1 = 0.   X2 = X        
C     AREA OF ROD NEEDED TO COMPUTE VOL        
C     VOL  = LENGTH  * A        
C     AREA OF TUBE CONPUTED WT OUTS.DIA.        
C        
C     OPEN FILE EST FOR ELEMENT DATA        
C        
C     INTEGRAL OVER VOL OF (GRADIENT SHAPE FUNC. TIMES GNU TIMES HC)    
C        
C     Z(1)  1ST POSITION OF LOAD        
C     NELEMS = NO OF ELEMENTS        
C     INCR   = MAX NO OF WORDS FOR AN ELEMENT OF THE ES T TABLE        
C     NE(1 AND2) = ELEMENT NAME        
C        
      LOGICAL         ONLYC        
      INTEGER         ELTYPE,ESTWDS,OUTPT,SYSBUF,ALL,SCR6        
      DIMENSION       XN(2),XLOAD(2),NSIL(2),IZ(1),NAM(2),        
     1                NECPT(200),NAME(2),HCX(2),HCY(2),HCZ(2),        
     2                ZI(3),DNDX(2),DNDY(2),DNDZ(2),BUF(50),IBUF(50),   
     3                XLACC(3),XI(2),W(2),SC(5),ISC(5)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ KSYSTM(64)        
CZZ   COMMON /ZZSSA1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /GPTA1 / NELEMS,LAST,INCR,NE(1)        
      COMMON /EMECPT/ ECPT(200)        
      COMMON /MATIN / MATID,INFLAG,ELTEMP        
      COMMON /HMTOUT/ XMAT        
      EQUIVALENCE     (IBUF(1)   ,BUF(1)), (SC(1)  ,ISC(1)  ),        
     1                (KSYSTM(1 ),SYSBUF), (KSYSTM(2),OUTPT ),        
     2                (KSYSTM(56),ITHRML), (ECPT(1),NECPT(1)),        
     3                (Z(1)      ,IZ(1) ), (NSIL(1),NECPT(2))        
      DATA     NAM  / 4H  EM,4H1D  /        
      DATA     SCR6 / 306          /        
C        
C     FROM EST GET ALL NECESSARY ELEMENT INFO        
C        
      ONLYC  = .FALSE.        
      NG     = 3        
      ISC(1) = NECPT(1)        
      ISC(2) = 1        
      XI(1)  = -.5773502692        
      XI(2)  = -XI(1)        
      W(1)   = 1.        
      W(2)   = 1.        
      IDX    = (ELTYPE-1)*INCR        
      ESTWDS = NE(IDX+12)        
      NGRIDS = NE(IDX+10)        
      NAME(1)= NE(IDX+ 1)        
      NAME(2)= NE(IDX+ 2)        
C        
C     CHECK TO SEE IF THIS ELEMENT CONTAINS A GRID POINT ON A PERMBDY   
C     CARD. IF SO, OR IF NO PERMBDY CARD EXISTS, COMPUTE LOADS FOR THE  
C     ELEMENT IF NOT, COMPUTE HC CENTROIDAL VALUE ONLY. (ONLYC=.TRUE.)  
C     THE PERMBDY SILS START AT Z(ISTART-NBDYS-1)        
C        
      IF (NBDYS .EQ. 0) GO TO 20        
C        
      DO 10 I = 1,NGRIDS        
      DO 10 J = 1,NBDYS        
      IF (NSIL(I) .EQ. IZ(ISTART-NBDYS-NELOUT+J-1)) GO TO 20        
   10 CONTINUE        
C        
C     ELEMENT HAS NO GRIDS ON PERMBDY        
C        
      ONLYC = .TRUE.        
      NG    = 1        
   20 CONTINUE        
      IF (ONLYC .AND. ITYPE.EQ.24) RETURN        
C        
C     IF ONLYC=TRUE, CHECK TO SEE IF THE ELEMENT HAD AN ELFORCE REQUEST.
C     IF SO, CONTINUE. IF NOT, JUST WRITE ZEROS TO HCCEN,SCR6) AND      
C     RETURN.        
C        
      IF (.NOT.ONLYC) GO TO 40        
      IF (ALL .EQ. 1) GO TO 40        
      IF (NELOUT .EQ. 0) GO TO 70        
C        
      DO 30 I = 1,NELOUT        
      IF (NECPT(1) .EQ. IZ(ISTART-NELOUT+I-1)) GO TO 40        
   30 CONTINUE        
      GO TO 70        
   40 CONTINUE        
C        
C     1ST CHECK FOR ZERO LOAD        
C        
      IF (ITYPE.NE.20 .AND. ITYPE.NE.24) GO TO 80        
      H1 = 0.        
      H2 = 0.        
      H3 = 0.        
      DO 50 I = 1,2        
      ISUB = ISTART + 3*NSIL(I) - 3        
      IF (ITYPE .EQ. 24) ISUB = ISTART + 3*NCOUNT - 3        
      H1 = H1 + ABS(Z(ISUB  ))        
      H2 = H2 + ABS(Z(ISUB+1))        
      H3 = H3 + ABS(Z(ISUB+2))        
      IF (ITYPE .EQ. 24) GO TO 60        
   50 CONTINUE        
   60 HL = H1 + H2 + H3        
      IF (HL    .NE. 0.) GO TO 80        
      IF (ITYPE .EQ. 24) RETURN        
C        
C     ALL ZEROS-WRITE ON SCR6        
C        
   70 SC(3) = 0.        
      SC(4) = 0.        
      SC(5) = 0.        
      CALL WRITE (SCR6,SC,5,0)        
      RETURN        
C        
   80 CONTINUE        
C        
C     ROD ELTYPE 1        
C     TUBE       3        
C     CONROD    10        
C     BAR       34        
C     OTHERWISE  GET OUT        
C     ONED  SOLVES LOAD DUE TO MAGNETIC FILED        
C        
      PI    = 3.14159        
      INFLAG= 1        
      IF (ELTYPE.NE.1 .AND. ELTYPE.NE.10) GO TO 90        
      MID   = 4        
      ITEMP = 17        
      IX1   = 10        
      IX2   = 14        
      IY1   = 11        
      IY2   = 15        
      IZ1   = 12        
      IZ2   = 16        
      IAR   = 5        
      GO TO 110        
   90 IF (ELTYPE .NE. 3) GO TO 100        
      MID   = 4        
      ITEMP = 16        
      IX1   = 9        
      IX2   = 13        
      IY1   = 10        
      IY2   = 14        
      IZ1   = 11        
      IZ2   = 15        
C        
C     COMPUTE AREA        
C        
      DIA   = ECPT(5)        
      TH    = ECPT(6)        
      RAD   = DIA - 2.*TH        
      ARROD = PI*((DIA/2)**2 - (RAD/2.)**2)        
      GO TO 110        
  100 IF (ELTYPE .NE. 34) GO TO 300        
      MID   = 16        
      ITEMP = 42        
      IX1   = 35        
      IX2   = 39        
      IY1   = 36        
      IY2   = 40        
      IZ1   = 37        
      IZ2   = 41        
      IAR   = 17        
  110 IF (ONLYC) GO TO 120        
      XL    = ECPT(IX2) - ECPT(IX1)        
      YL    = ECPT(IY2) - ECPT(IY1)        
      ZL    = ECPT(IZ2) - ECPT(IZ1)        
      XLEN  = SQRT(XL**2 + YL**2 + ZL**2)        
      XN(1) = -1./XLEN        
      XN(2) =  1./XLEN        
      IF (ELTYPE .NE. 3) ARROD = ECPT(IAR)        
      ELTEMP= ECPT (ITEMP)        
      MATID = NECPT(MID)        
C        
C     ARROD = AREA OF CROSS SECTION OF ROD        
C        
      IF (ITYPE .NE. 24) CALL HMAT (NECPT(1))        
      GNU = XMAT        
      IF (ITYPE .EQ. 24) GNU = 1.        
C        
C     HC   FROM Z(ISTART)        
C     YIELDS X COORD OF HC FOR GRID PT DEFINED BY NSIL        
C        
      VOL = ARROD*XLEN        
C        
C     COMPUTE BASIC TO LOCAL TRANSFORMATION        
C        
      ZI(1) = XL/XLEN        
      ZI(2) = YL/XLEN        
      ZI(3) = ZL/XLEN        
C        
C     PARTIALS OF N W.R.T X-GLOBAL,Y-GLOBAL,Z-GLOBAL        
C        
      DNDX(1) = -ZI(1)/XLEN        
      DNDY(1) = -ZI(2)/XLEN        
      DNDZ(1) = -ZI(3)/XLEN        
      DNDX(2) = -DNDX(1)        
      DNDY(2) = -DNDY(1)        
      DNDZ(2) = -DNDZ(1)        
      CONST   = .5*GNU*VOL        
      IF (ITYPE .EQ. 24)GO TO 250        
  120 CONTINUE        
      JTYPE   = ITYPE - 19        
      XLACC(1)= 0.        
      XLACC(2)= 0.        
      XLACC(3)= 0.        
C        
C     LOOP OVER INTEGRATION POINTS-ASSUME CUBIC VARIATION. SO NEED 2    
C     INTEGRATION POINTS + CENTROID        
C        
      DO 240 NPTS = 1,NG        
      IF (NPTS .NE. NG) GO TO 130        
      XX = .5*(ECPT(IX1) + ECPT(IX2))        
      YY = .5*(ECPT(IY1) + ECPT(IY2))        
      ZZ = .5*(ECPT(IZ1) + ECPT(IZ2))        
C        
C     AVERAGE SPCFLD        
C        
      XLX  = .5        
      XLXP = .5        
      GO TO 140        
C        
C     COMPUTE LOCAL COORDINATE OF SAMPLING POINT        
C        
  130 XLOCAL = .5*XLEN*(1.+XI(NPTS))        
      XLX  = XLOCAL/XLEN        
      XLXP = 1. - XLX        
C        
C     COMPUTE BASIC COORDS FOR XLOCAL        
C        
      XX   = XLXP*ECPT(IX1) + XLX*ECPT(IX2)        
      YY   = XLXP*ECPT(IY1) + XLX*ECPT(IY2)        
      ZZ   = XLXP*ECPT(IZ1) + XLX*ECPT(IZ2)        
  140 AHCX = 0.        
      AHCY = 0.        
      AHCZ = 0.        
C        
C     COMPUTE HC AT THIS POINT DUE TO ALL LOADS OF THIS TYPE        
C        
      DO 220 IJK = 1,IDO        
      IF (ITYPE .EQ. 20) GO TO 160        
      ISUB = ISTART + (IJK-1)*IWORDS - 1        
      DO 150 I = 1,IWORDS        
  150 BUF(I) = Z(ISUB+I)        
      GO TO (160,180,190,200), JTYPE        
C        
C     SPCFLD        
C        
  160 DO 170 I = 1,2        
      IS = ISTART + 3*NSIL(I) -3        
      HCX(I) = Z(IS  )        
      HCY(I) = Z(IS+1)        
  170 HCZ(I) = Z(IS+2)        
C        
C     INTERPOLATE GRID VALUES TO INTEGRATION POINT        
C        
      HC1 = XLXP*HCX(1) + XLX*HCX(2)        
      HC2 = XLXP*HCY(1) + XLX*HCY(2)        
      HC3 = XLXP*HCZ(1) + XLX*HCZ(2)        
      GO TO 210        
  180 CALL AXLOOP (BUF,IBUF,XX,YY,ZZ,HC1,HC2,HC3)        
      GO TO 210        
  190 CALL GELOOP (BUF,IBUF,XX,YY,ZZ,HC1,HC2,HC3)        
      GO TO 210        
  200 CALL DIPOLE (BUF,IBUF,XX,YY,ZZ,HC1,HC2,HC3)        
  210 AHCX  = AHCX + HC1        
      AHCY  = AHCY + HC2        
      AHCZ  = AHCZ + HC3        
  220 CONTINUE        
      IF (NPTS .NE. NG) GO TO 230        
      SC(3) = AHCX        
      SC(4) = AHCY        
      SC(5) = AHCZ        
      CALL WRITE (SCR6,SC,5,0)        
      IF (ONLYC) RETURN        
      GO TO 240        
C        
C     WE HAVE HC AT THIS INTEGRATION POINT. MULT. BY WEIGHT AND        
C     ACCUMULATE        
C        
  230 XLACC(1) = XLACC(1) + AHCX*W(NPTS)        
      XLACC(2) = XLACC(2) + AHCY*W(NPTS)        
      XLACC(3) = XLACC(3) + AHCZ*W(NPTS)        
  240 CONTINUE        
C        
C     MULT. BY CONST AND GRAD N TO GET LOADS        
C        
      XLOAD(1) = CONST*(DNDX(1)*XLACC(1) + DNDY(1)*XLACC(2) +        
     1           DNDZ(1)*XLACC(3))        
      XLOAD(2) = CONST*(DNDX(2)*XLACC(1) + DNDY(2)*XLACC(2) +        
     1           DNDZ(2)*XLACC(3))        
      GO TO 260        
C        
C     REMFLUX        
C        
  250 IS   = ISTART + 3*NCOUNT - 3        
      AHCX = Z(IS  )        
      AHCY = Z(IS+1)        
      AHCZ = Z(IS+2)        
C        
      XLOAD(1) = GNU*VOL*(DNDX(1)*AHCX + DNDY(1)*AHCY + DNDZ(1)*AHCZ)   
      XLOAD(2) = GNU*VOL*(DNDX(2)*AHCX + DNDY(2)*AHCY + DNDZ(2)*AHCZ)   
  260 DO 290 I = 1,2        
      J = NSIL(I)        
C        
C     IF PERMBDY EXISTS AND IF GRID IS NOT ON IT, IGNORE ITS LOAD       
C        
      IF (NBDYS .EQ. 0) GO TO 280        
      DO 270 K = 1,NBDYS        
      IF (J .NE. IZ(ISTART-NBDYS-NELOUT+K-1)) GO TO 270        
      GO TO 280        
  270 CONTINUE        
      GO TO 290        
  280 CONTINUE        
  290 Z(J) = Z(J) - XLOAD(I)        
      RETURN        
C        
  300 WRITE  (OUTPT,310) UFM        
  310 FORMAT (A23,', ELEMENT TYPE ',2A4,' WAS USED IN AN E AND M ',     
     1       'PROBLEM.')        
      CALL MESAGE (-37,0,NAM)        
      RETURN        
      END        
