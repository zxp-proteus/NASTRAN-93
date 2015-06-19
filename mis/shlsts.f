      SUBROUTINE SHLSTS (ELID,PID,TLAM,EPSUMI,EPSCMI)        
C        
C     TO PERFORM LAYER STRAIN, STRESS AND FORCE CALCULATIONS FOR THE    
C     2-D SHELL ELEMENTS.        
C     ONLY THE ELEMENT CENTER VALUES ARE CONSIDERED        
C        
C     INPUT :        
C           ELID   - ELEMENT ID        
C           PID    - COMPOSITE PROPERTY ID        
C           TLAM   - AVERAGE ELEMENT THICKNESS        
C           EPSUMI - UNCORRECTED STRAINS IN MATERIAL COORD. SYSTEM      
C           EPSCMI - CORRECTED STRAINS IN MATERIAL COORD. SYSTEM        
C          /CONDAS/- TRIGONOMETRIC CONSTATNTS        
C          /OUTREQ/- OUTPUT REQUEST LOGICAL FLAGS        
C        
C     OUTPUT:        
C           OUTPUT DATA ARE WRITTEN DIRECTLY TO EACH APPROPRIATE OUTPUT 
C           FILE - OEF1L, OES1L/OES1AL        
C        
C        
C     LAYER STRESS/STRAIN OUTPUT BLOCK FOR EACH CTRIA3 ELEMENT        
C        
C         1.    10*ELEMENT ID + DEVICE CODE        
C         2.    NLAYER - NUMBER OF OUTPUT LAYERS        
C         3.    TYPE OF FAILURE THEORY SELECTED        
C        
C         4.    LAYER ID        
C        5-7.   LAYER STRESSES/STRAINS        
C         8.    LAYER FAILURE INDEX, FI        
C         9.    IFLAG1 = 1 IF FI.GE.0.999        
C                      = 0 OTHERWISE        
C       10-11.  INTERLAMINAR SHEAR STRESSES/STRAINS        
C        12.    SHEAR BONDING INDEX, FB        
C        13.    IFLAG2 = 1 IF FB.GE.0.999        
C                      = 0 OTHERWISE        
C         :        
C         :     REPEAT 4-13 NLAYER TIMES FOR EACH LAYER        
C        
C       LAST-1. MAXIMUM FAILURE INDEX OF LAMINATE, FIMAX        
C        LAST.  IFLAG3 = 1 IF FIMAX.GE.0.999        
C                      = 0 OTHERWISE        
C        
C        
C     FORCE OUTPUT BLOCK        
C        
C         1.    10*ELEMENT ID + DEVICE CODE        
C        2-9.   FORCE RESULTANTS:        
C                 MEMBRANE        BENDING     TRANSVERSE        
C               -- FORCES --    - MOMENTS -  SHEAR FROCES        
C               FX,  FY, FXY,   MX, MY, MXY,    VX, VY        
C        
C        
      LOGICAL         STRESS,STRAIN,FORCE,STSREQ,STNREQ,FORREQ,STRCUR,  
     1                GRIDS,VONMS,LAYER,GRIDSS,VONMSS,LAYERS,        
     2                TRNFLX,NONMEM,SYMLAY,PCMP,PCMP1,PCMP2        
      INTEGER         ELID,ELEMID,OES1L,OES1AL,OEF1L,PCOMP,PCOMP1,      
     1                PCOMP2,PID,PIDLOC,SYM,SYMMEM,SOUTI,HALF,FTHR,     
     2                STRINF,SDEST,EDEST,FDEST,IZ(1)        
      REAL            STRSLR(3),TRNSRR(2),EPSLR(3),ERNSRR(2),FINDXR,    
     1                FBONDR,FIMAXR,Z        
      REAL            TLAM,EPSUMI(6,1),EPSCMI(6,1),PI,TWOPI,RADDEG,     
     1                DEGRAD,GG(9),ULTSTN(6),TRANS(9),STRESL(3),        
     2                EPSLCM(3),EPSLUM(3),EPSLCF(3),EPSLUF(3),TRNAR(2), 
     3                ERNAR(2),TRNSHR(2),ERNSHR(2),FINDEX,FPMAX,FBOND,  
     4                FBMAX,FIMAX,FB(2),SB,V(2),EI(2),ZBAR(2),        
     5                ZK,ZK1,ZSUBI,ZREF,THETA,C,C2,S,S2,TI        
      COMMON /CONDAS/ PI,TWOPI,RADDEG,DEGRAD        
      COMMON /OUTREQ/ STSREQ,STNREQ,FORREQ,STRCUR,GRIDS,VONMS,LAYER     
     1,               GRIDSS,VONMSS,LAYERS        
      COMMON /SDR2DE/ KSDRDE(200)        
      COMMON /SDR2X2/ DUM1(30),OES1L,OEF1L        
      COMMON /SDR2X7/ DUM2(100),STRES(69),DUM3(31),FORSUL(37),        
     1                DUM4(163),STRIN(69)        
      COMMON /SDR2C1/ IPCMP,NPCMP,IPCMP1,NPCMP1,IPCMP2,NPCMP2        
CZZ   COMMON /ZZSDR2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (Z(1) ,IZ(1)     ),(SDEST,KSDRDE( 26)),        
     1                (FDEST,KSDRDE(33)),(EDEST,KSDRDE(148)),        
     2                (OES1L,OES1AL    )        
      DATA    SYMMEM, MEM, SYM, PCOMP, PCOMP1, PCOMP2, STRINF /        
     1        3     , 2  , 1  , 0    , 1     , 2     , 5      /        
C        
C     INITIALIZE        
C        
      ZREF  =-TLAM/2.0        
      FINDEX= 0.0        
      FBOND = 0.0        
      FPMAX = 0.0        
      FBMAX = 0.0        
      FIMAX = 0.0        
C        
      DO 10 LL = 1,2        
      ERNAR(LL) = 0.0        
      TRNAR(LL) = 0.0        
      ERNSHR(LL)= 0.0        
      TRNSHR(LL)= 0.0        
   10 CONTINUE        
C        
      FORCE  = FORREQ .AND. LAYER        
      STRESS = STSREQ .AND. LAYER        
      STRAIN = STNREQ .AND. LAYERS        
C        
      ITYPE  = -1        
      LPCOMP = IPCMP + NPCMP + NPCMP1 + NPCMP2        
      PCMP   = NPCMP  .GT. 0        
      PCMP1  = NPCMP1 .GT. 0        
      PCMP2  = NPCMP2 .GT. 0        
C        
      IF (.NOT.FORCE) GO TO 20        
C        
C     WRITE FORCE RESULTANTS TO OEF1L IF REQUESTED        
C        
      ELEMID = 10*ELID + FDEST        
      CALL WRITE (OEF1L,ELEMID,1,0)        
      CALL WRITE (OEF1L,FORSUL(3),8,0)        
C        
C     FORCE REQUEST HAS BEEN PROCESSED. IF NO MORE REQUESTS WE ARE DONE.
C     IF NOT, PREPARE FOR OTHER REQUESTS.        
C     ISSUE ERROR IF PCOMPI DATA HAS NOT BEEN READ INTO CORE.        
C        
   20 IF (.NOT.(STRESS .OR. STRAIN)) GO TO 650        
C        
C     START WRITING STRESS/STRAIN OUTPUT TO OES1L/OES1AL        
C     (NOTE - OES1L AND OES1AL ARE SAME FILE IN COSMIC/NASTRAN)        
C        
C     1.  10*ELEMENT ID + DEVICE CODE        
C        
      IF (LPCOMP .EQ. IPCMP) GO TO 600        
      ELEMID = 10*ELID + SDEST        
      IF (STRAIN) ELEMID = 10*ELID + EDEST        
      CALL WRITE (OES1L,ELEMID,1,0)        
C        
C     DETERMINE  IF INTERLAMINAR SHEAR STRESS CALCULATIONS ARE REQUIRED 
C     BY CHECKING THE TRANSVERSE SHEAR STRESS RESULTANTS QX AND QY      
C        
      V(1) = FORSUL( 9)        
      V(2) = FORSUL(10)        
      TRNFLX = V(1).NE.0.0 .OR. V(2).NE.0.0        
C        
C     LOCATE PID BY PERFORMING A SEQUENTIAL SEARCH OF THE PCOMPI DATA   
C     BLOCK WHICH IS IN CORE.        
C        
C     SEARCH FOR PID IN PCOMP DATA        
C        
      IF (.NOT.PCMP) GO TO 40        
      IP = IPCMP        
      IF (IZ(IP) .EQ. PID) GO TO 110        
      IPC11 = IPCMP1 - 1        
      DO 30 IP = IPCMP,IPC11        
      IF (IZ(IP).EQ.-1 .AND. IP.LT.IPC11) IF (IZ(IP+1)-PID) 30,100,30   
   30 CONTINUE        
C        
C     SEARCH FOR PID IN PCOMP1 DATA        
C        
   40 IF (.NOT.PCMP1) GO TO 60        
      IP = IPCMP1        
      IF (IZ(IP) .EQ. PID) GO TO 140        
      IPC21 = IPCMP2 - 1        
      DO 50 IP = IPCMP1,IPC21        
      IF (IZ(IP).EQ.-1 .AND. IP.LT.IPC21) IF (IZ(IP+1)-PID) 50,130,50   
   50 CONTINUE        
C        
C     SEARCH FOR PID IN PCOMP2 DATA        
C        
   60 IF (.NOT.PCMP2) GO TO 600        
      IP = IPCMP2        
      IF (IZ(IP) .EQ. PID) GO TO 160        
      LPC11 = LPCOMP - 1        
      DO 70 IP = IPCMP2,LPC11        
      IF (IZ(IP).EQ.-1 .AND. IP.LT.LPC11) IF (IZ(IP+1)-PID) 70,150,70   
   70 CONTINUE        
C        
C     PID WAS NOT LOCATED; ISSUE ERROR        
C        
      GO TO 600        
C        
C     PID WAS LOCATED; DETERMINE TYPE        
C        
C     FOR PCOMP BULK DATA DETERMINE HOW MANY LAYERS HAVE THE STRESS/    
C     STRAIN OUTPUT REQUEST (SOUTI).        
C     FOR PCOMP1 OR PCOMP2 BULK DATA ENTRIES LAYER STRESSES/STRAINS ARE 
C     OUTPUT FOR ALL LAYERS.        
C        
  100 IP = IP + 1        
  110 ITYPE  = PCOMP        
      PIDLOC = IP        
      NLAY   = IZ(PIDLOC+1)        
      NLAYER = NLAY        
      NSTRQT = 0        
      DO 120 K = 1,NLAY        
      IF (IZ(PIDLOC+8+4*K) .EQ. 1) NSTRQT = NSTRQT + 1        
  120 CONTINUE        
      NLAYER = NSTRQT        
      IPOINT = PIDLOC + 8 + 4*NLAY        
      ICONTR = IPOINT +    27*NLAY        
      GO TO 200        
C        
  130 IP = IP + 1        
  140 ITYPE  = PCOMP1        
      PIDLOC = IP        
      NLAY   = IZ(PIDLOC+1)        
      NLAYER = NLAY        
      IPOINT = PIDLOC +  8 +   NLAY        
      ICONTR = IPOINT + 25 + 2*NLAY        
      GO TO 200        
C        
  150 IP = IP + 1        
  160 ITYPE  = PCOMP2        
      PIDLOC = IP        
      NLAY   = IZ(PIDLOC+1)        
      NLAYER = NLAY        
      IPOINT = PIDLOC +  8 + 2*NLAY        
      ICONTR = IPOINT + 25 + 2*NLAY        
C        
C     DETERMINE GENERAL COMPOSITE PROPERTY VALUES        
C        
C     LAMOPT - LAMINATION GENERATION OPTION        
C            = ALL    = 0 (ALL PLYS SPECIFIED, DEFAULT)        
C            = SYM    = 1 (SYMMETRIC)        
C            = MEM    = 2 (MEMBRANE ONLY)        
C            = SYMMEM = 3 (SYMMETRIC-MEMBRANE)        
C        
C     FTHR   - FAILURE THEORY        
C            = 1    HILL        
C            = 2    HOFFMAN        
C            = 3    TSAI-WU        
C            = 4    MAX-STRESS        
C            = 5    MAX-STRAIN        
C        
C     SB     - SHEAR BONDING STRENGTH        
C        
  200 LAMOPT = IZ(PIDLOC+8)        
      FTHR   = IZ(PIDLOC+5)        
      SB     =  Z(PIDLOC+4)        
      EI(1)  =  Z(ICONTR+1)        
      EI(2)  =  Z(ICONTR+2)        
      ZBAR(1)=  Z(ICONTR+3)        
      ZBAR(2)=  Z(ICONTR+4)        
C        
      NONMEM = LAMOPT.NE.MEM .AND. LAMOPT.NE.SYMMEM        
      SYMLAY = LAMOPT.EQ.SYM .OR.  LAMOPT.EQ.SYMMEM        
      IF (SYMLAY) NLAYER = 2*NLAYER        
      IF (NLAYER .EQ. 0) GO TO 650        
C        
C     CONTINUE TO WRITE LAYER-INDEPENDENT DATA TO OES1L/OES1AL        
C        
C     2.  NLAYER - NUMBER OF LAYERS FOR LAMINATE        
C     3.  TYPE OF FAILURE THEORY SELECTED        
C        
      CALL WRITE (OES1L,NLAYER,1,0)        
      CALL WRITE (OES1L,FTHR,1,0)        
C        
C     START THE LOOP OVER LAYERS        
C        
      ZK = ZREF        
      HALF = 1        
      IF (SYMLAY) HALF = 2        
C        
      DO 450 IHALF = 1,HALF        
      DO 440 KK = 1,NLAY        
      K = KK        
      IF (IHALF .EQ. 2) K = NLAY + 1 - KK        
C        
C     OBTAIN LAYER K INFORMATION        
C     - THE BOUNDARIES        
C     - THE DISTANCE FROM THE REFERENCE SURFACE TO THE MIDDLE OF LAYER  
C     - LAYER THICKNESS        
C     - STRESS OUTPUT REQUEST (SOUTI) FOR PCOMP BULK DATA        
C       (NOT SUPPORTED FOR PCOMP1 OR PCOMP2 BULK DATA)        
C        
      ZK1 = ZK        
      IF (ITYPE .EQ. PCOMP ) ZK = ZK1 + Z(PIDLOC + 6 + 4*K)        
      IF (ITYPE .EQ. PCOMP1) ZK = ZK1 + Z(PIDLOC + 7      )        
      IF (ITYPE .EQ. PCOMP2) ZK = ZK1 + Z(PIDLOC + 7 + 2*K)        
      ZSUBI = (ZK+ZK1)/2.0        
      TI = ZK - ZK1        
      SOUTI = 1        
      IF (ITYPE .EQ. PCOMP) SOUTI = IZ(PIDLOC+8+4*K)        
C        
C     LAYER MATERIAL PROPERTIES        
C        
      DO 210 IGI = 1,9        
      GG(IGI) = Z(IPOINT+IGI)        
  210 CONTINUE        
C        
C     LAYER ULTIMATE STRENGTHS        
C        
      DO 220 IR = 1,6        
      ULTSTN(IR) = Z(IPOINT+16+IR)        
  220 CONTINUE        
C        
C     LAYER ORIENTATION        
C        
      IF (ITYPE .EQ. PCOMP ) THETA = Z(PIDLOC + 7 + 4*K)        
      IF (ITYPE .EQ. PCOMP1) THETA = Z(PIDLOC + 8 +   K)        
      IF (ITYPE .EQ. PCOMP2) THETA = Z(PIDLOC + 8 + 2*K)        
      THETA = THETA*DEGRAD        
C        
C     BUILD THE STRAIN TENSOR TRANSFORMATION TO TRANSFORM        
C     LAYER STRAINS FROM MATERIAL TO FIBER DIRECTION.        
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
      TRANS(9)  = C2 - S2        
C        
C     CALCULATE THE CORRECTED AND UNCORRECTED STRAIN VECTORS AT ZSUBI   
C     IN THE MATERIAL COORD. SYSTEM, THENTRANSFORM STRAINS FROM MATERIAL
C     TO FIBER COORD. SYSTEM AND CALCULATE THE LAYER STRESS VECTOR IN   
C     THE FIBER COORD. SYSTEM        
C        
      DO 300 IR = 1,3        
      EPSLCM(IR) = EPSCMI(IR,1) - ZSUBI*EPSCMI(IR+3,1)        
      EPSLUM(IR) = EPSUMI(IR,1) - ZSUBI*EPSUMI(IR+3,1)        
  300 CONTINUE        
C        
      CALL GMMATS (TRANS(1),3,3,0, EPSLCM(1),3,1,0, EPSLCF(1))        
      CALL GMMATS (TRANS(1),3,3,0, EPSLUM(1),3,1,0, EPSLUF(1))        
      CALL GMMATS (GG(1),3,3,0,    EPSLCF,3,1,0,    STRESL(1))        
C        
      IF (FTHR .LE. 0) GO TO 310        
C        
C     COMPUTE FAILURE INDEX FOR THIS LAYER AND THE MAXIMUM FAILURE INDEX
C        
      IF (FTHR .EQ. STRINF) CALL FAILRS (FTHR,ULTSTN,EPSLUF,FINDEX)     
      IF (FTHR .NE. STRINF) CALL FAILRS (FTHR,ULTSTN,STRESL,FINDEX)     
      IF (ABS(FINDEX) .GE. ABS(FPMAX)) FPMAX = FINDEX        
C        
  310 IF (.NOT.TRNFLX .OR. .NOT.NONMEM) GO TO 350        
C        
C     CALCULATE INTERLAMINAR SHEAR STRESSES AND STRAINS        
C        
      IF (ITYPE .EQ. PCOMP ) ICONTR = IPOINT + 25        
      IF (ITYPE .EQ. PCOMP1) ICONTR = IPOINT + 23 + 2*K        
      IF (ITYPE .EQ. PCOMP2) ICONTR = IPOINT + 23 + 2*K        
      DO 320 IR = 1,2        
      ERNAR(IR) = ERNAR(IR) + TI*(ZBAR(IR)-ZSUBI)        
      TRNAR(IR) = TRNAR(IR) + TI*(ZBAR(IR)-ZSUBI)*Z(ICONTR+IR)        
  320 CONTINUE        
C        
      DO 330 IR = 1,2        
      TRNSHR(IR) = V(IR)*TRNAR(IR)/EI(IR)        
      ERNSHR(IR) = V(IR)*ERNAR(IR)/EI(IR)        
  330 CONTINUE        
C        
      IF (SB .LE. 0.0) GO TO 350        
C        
C     CALCULATE SHEAR BONDING FAILURE INDEX, FB, AND THE MAX SHEAR      
C     BONDING INDEX, FBMAX.        
C        
      DO 340 IR = 1,2        
      FB(IR) = ABS(TRNSHR(IR))/SB        
  340 CONTINUE        
C        
      FBOND = FB(1)        
      IF (FB(2) .GT. FB(1)) FBOND = FB(2)        
      IF (FBOND .GE. FBMAX) FBMAX = FBOND        
C        
  350 IF (SOUTI .EQ. 0) GO TO 430        
C        
C     CONTINUE TO WRITE LAYER-DEPENDENT DATA TO OES1L AND OES1AL        
C        
C       4.   LAYER ID, LYRID        
C     5,6,7. LAYER STRESSES/STRAINS        
C       8.   LAYER FAILURE INDEX, FINDXR        
C       9.   IFLAG1 (=1 IF FINDXR.GE.0.999, DEFAULT=0)        
C     10,11. INTERLAMINAR SHEAR STRESSES/STRAINS        
C      12.   SHEAR BONDING FAILURE INDEX, FBONDR        
C      13.   IFLAG2 (=1 IF FBONDR.GE.0.999, DEFAULT=0)        
C       :    REPEAT 4-13 FOR NUMBER OF LAYER WITH LAYER STRESS/STRAIN   
C       :    REQUEST        
C        
C        
      LYRID = K        
      IF (IHALF .EQ. 2) LYRID = NLAY + KK        
C        
      FINDXR = FINDEX        
      IFLAG1 = 0        
      IF (ABS(FINDEX) .GE. 0.999) IFLAG1 = 1        
C        
      FBONDR = FBOND        
      IFLAG2 = 0        
      IF (ABS(FBOND ) .GE. 0.999) IFLAG2 = 1        
C        
      IF (.NOT.STRESS) GO TO 410        
      DO 400 ISTR = 1,3        
      STRSLR(ISTR) = STRESL(ISTR)        
  400 CONTINUE        
      TRNSRR(1) = TRNSHR(1)        
      TRNSRR(2) = TRNSHR(2)        
      CALL WRITE (OES1L,LYRID,1,0)        
      CALL WRITE (OES1L,STRSLR(1),3,0)        
      CALL WRITE (OES1L,FINDXR,1,0)        
      CALL WRITE (OES1L,IFLAG1,1,0)        
      CALL WRITE (OES1L,TRNSRR(1),2,0)        
      CALL WRITE (OES1L,FBONDR,1,0)        
      CALL WRITE (OES1L,IFLAG2,1,0)        
C        
  410 IF (.NOT.STRAIN) GO TO 430        
      DO 420 ISTR = 1,3        
      EPSLR(ISTR)  = EPSLUF(ISTR)        
  420 CONTINUE        
      ERNSRR(1) = ERNSHR(1)        
      ERNSRR(2) = ERNSHR(2)        
      CALL WRITE (OES1AL,LYRID,1,0)        
      CALL WRITE (OES1AL,EPSLR(1),3,0)        
      CALL WRITE (OES1AL,FINDXR,1,0)        
      CALL WRITE (OES1AL,IFLAG1,1,0)        
      CALL WRITE (OES1AL,ERNSRR(1),2,0)        
      CALL WRITE (OES1AL,FBONDR,1,0)        
      CALL WRITE (OES1AL,IFLAG2,1,0)        
C        
C     UPDATE IPOINT FOR PCOMP BULK DATA ENTRY        
C        
  430 IF (ITYPE .NE. PCOMP) GO TO 440        
      IF (IHALF.EQ.1 .AND. K.NE.NLAY) IPOINT = IPOINT + 27        
      IF (IHALF .EQ. 2) IPOINT = IPOINT - 27        
  440 CONTINUE        
  450 CONTINUE        
C        
C     END OF LOOP OVER LAYERS        
C        
      IF (FTHR .LE. 0) GO TO 500        
C        
C     DETERMINE THE MAXIMUM FAILURE INDEX        
C        
      FIMAX = FPMAX        
      IF (FBMAX .GT. ABS(FPMAX)) FIMAX = FBMAX        
C        
C     CONTINUE TO OUTPUT THE MAXIMUM FAILURE INDEX TO OES1L/OES1AL      
C        
C     LAST-1.  MAXIMUM FAILURE INDEX OF LIMIATE, FIMAXR        
C      LAST.   IFLAG3 (=1 IF FIMAXR.GE.0.999, DEFAULT=0)        
C        
  500 FIMAXR = FIMAX        
      IFLAG3 = 0        
      IF (ABS(FIMAX) .GE. 0.999) IFLAG3 = 1        
C        
      CALL WRITE (OES1L,FIMAXR,1,0)        
      CALL WRITE (OES1L,IFLAG3,1,0)        
      GO TO 650        
C        
C        
C     ERROR MESSAGE        
C        
C     NO PCOMP, PCOMP1, PCOMP2 FOUND        
C        
  600 CALL MESAGE (-30,223,ELID)        
C        
  650 RETURN        
      END        
