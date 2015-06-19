      SUBROUTINE DPZY(   KB,IZ,I,J1,J2,IFIRST,ILAST,YB,ZB,        
     1          AVR,ARB,TH1A,TH2A,NT121,NT122,NBARAY,NCARAY,        
     * NZYKB,DPZ,DPY)        
C   ***   GENERATES ROWS OF THE SUBMATRICES  DPZ  AND DPY  USING        
C         SUBROUTINE  SUBP        
      INTEGER Z        
      COMPLEX SUM,DPZ(1),DPY(1)        
      DIMENSION YB(1),ZB(1),AVR(1),ARB(1),TH1A(1),TH2A(1),NT121(1)      
      DIMENSION NT122(1),NBARAY(1),NCARAY(1)        
      COMMON /DLBDY/ NJ1,NK1,NP,NB,NTP,NBZ,NBY,NTZ,NTY,NT0,NTZS,NTYS,   
     *   INC,INS,INB,INAS,IZIN,IYIN,INBEA1,INBEA2,INSBEA,IZB,IYB,       
     *   IAVR,IARB,INFL,IXLE,IXTE,INT121,INT122,IZS,IYS,ICS,IEE,ISG,    
     *   ICG,IXIJ,IA,IDELX,IXIC,IXLAM,IA0,IXIS1,IXIS2,IA0P,IRIA        
     *  ,INASB,IFLA1,IFLA2,ITH1A,ITH2A,        
     *   ECORE,NEXT,SCR1,SCR2,SCR3,SCR4,SCR5        
CZZ   COMMON /ZZDAMB / Z(1)        
      COMMON /ZZZZZZ / Z(1)        
      PI   = 3.1415926        
      IX1    = 1        
      IZ   = IZ+1        
C  IZ  IS THE BODY-ELEMENT NUMBER FOR BODY  KB  --  IZ RUNS FROM  1     
C  THROUGH  NBE-SUB-KB        
      IX2 = NT122(KB)        
      IF (IZ.GE.IFIRST.AND.IZ.LE.ILAST)  IX2=NT121(KB)        
      DO  100  IX=IX1,IX2        
      L    = 1        
      KSP = 0        
C  L IS THE PANEL NUMBER ASSOCIATED WITH SENDING   POINT  J        
      LS   = 1        
C  LS IS THE STRIP NUMBER ASSOCIATED WITH SENDING   POINT  J        
      NBXS = NBARAY(L)        
      NC1  = NCARAY(L)        
      NBCUM= NC1        
      IXP1 = IX+1        
      IF (IXP1.GT.IX2)  IXP1=IX1        
      IXM1 = IX-1        
      IF (IXM1.EQ.0)   IXM1=IX2        
      IF (IZ.GE.IFIRST.AND.IZ.LE.ILAST)  GO TO  30        
      THETA= TH2A(IX)        
      THP1 = TH2A(IXP1)        
      THM1 = TH2A(IXM1)        
      GO TO  40        
   30 CONTINUE        
      THETA = TH1A(IX)        
      THP1 = TH1A(IXP1)        
      THM1 = TH1A(IXM1)        
   40 CONTINUE        
      IF (IX.EQ.IX1)  THM1=THM1-2.0*PI        
      IF (IX.EQ.IX2)  THP1=THP1+2.0*PI        
      DELTH= 0.5*(THP1 - THM1)        
      YREC = YB(KB)+AVR(KB)*COS(THETA)        
      ZREC = ZB(KB)+AVR(KB)*ARB(KB)*SIN(THETA)        
      RHO  = SQRT(1.0+(ARB(KB)**2 - 1.0) * (COS(THETA))**2)        
      SGR  = -ARB(KB)*COS(THETA)/RHO        
      CGR  = SIN(THETA)/RHO        
      SMULT= SIN(THETA) * RHO / PI        
      CMULT= COS(THETA) * RHO / PI        
      DO  90  J=J1,J2        
      CALL SUBPB(I,L,LS,J,SGR,CGR,YREC,ZREC,SUM,Z(IXIC),Z(IDELX),Z(IEE) 
     * ,Z(IXLAM),Z(ISG),Z(ICG),Z(IYS),Z(IZS),Z(INAS),Z(INASB+KSP),      
     * Z(IAVR),Z(IZB),Z(IYB),Z(IARB),Z(IXLE),Z(IXTE),Z(IA),NB)        
      GO TO  (50,50,60),  NZYKB        
   50 CONTINUE        
      DPZ(J) = DPZ(J) + SUM * SMULT * DELTH        
      IF (NZYKB.EQ.1)  GO TO 70        
   60 CONTINUE        
      DPY(J) = DPY(J) + SUM * CMULT * DELTH        
   70 CONTINUE        
      IF (J.EQ.J2)  GO TO  90        
      IF (J.LT.NBXS)   GO TO  80        
      KSP = KSP + Z(INAS+L-1)        
      L    = L+1        
      NC1  = NCARAY(L)        
      NBXS = NBARAY(L)        
   80 CONTINUE        
      IF (J.LT.NBCUM)  GO TO  90        
      LS   = LS+1        
      NBCUM= NBCUM+NC1        
   90 CONTINUE        
  100 CONTINUE        
      RETURN        
      END        
