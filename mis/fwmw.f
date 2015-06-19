      SUBROUTINE FWMW (ND,NE,SGS,CGS,IRB,A0,ARB,XBLE,XBTE,YB,ZB,XS,     
     1                 YS,ZS,NAS,NASB,KR,BETA2,CBAR,AVR,FWZ,FWY)        
C        
C     CALCULATES THE EFFECT OF A DOUBLET PLUS ANY CONTRIBUTIONS DUE TO  
C     IMAGES, SYMMETRY AND GROUND EFFECT ON BODY        
C        
      COMPLEX   FWZ,FWY        
      DIMENSION YB(1),ZB(1),NASB(1),AVR(1),ARB(1)        
C        
C     ND        SYMMETRY FLAG        
C     NE        GROUND EFFECTS FLAG        
C     SGS       SINE   OF SENDING POINT DIHEDRAL ANGLE        
C     CGS       COSINE OF SENDING POINT DIHEDRAL ANGLE        
C     IRB       NUMBER OF THE RECEIVING BODY        
C     A0        RADIUS OF THE BODY        
C     ARB       ARRAY OF RATIOS OF BODY AXIS        
C     XBLE      LEADING  EDGE COORDINATE OF SLENDER BODY ELEMENT        
C     XBTE      TRAILING EDGE COORDINATE OF SLENDER BODY ELEMENT        
C     YB        ARRAY CONTAINING THE Y-COORDINATES OF THE BODIES        
C     ZB        ARRAY CONTAINING THE Y-COORDINATES OF THE BODIES        
C     XS        1/4-CHORD  X-COORDINATE  OF SLENDER BODY ELEMENT        
C     YS        Y-COORDINATE OF SENDING POINT        
C     ZS        Z COORDINATE OF THE SENDING POINT        
C     NAS       NUMBER OF ASSOCIATED BODIES        
C     NASB      ARRAY CONTAINING THE ASSOCIATED BODY NOS.        
C     KR        REDUCED FREQUENCY        
C     BETA2     = 1 - MACH**2        
C     CBAR      REFERENCE CHARD LENGTH        
C     AVR       ARRAY OF BODY RADII        
C     FWZ       OUTPUT Z-FORCE        
C     FWY       OUTPUT Y FORCE        
C        
      FWZ  = CMPLX(0.0,0.0)        
      FWY  = CMPLX(0.0,0.0)        
C        
      DMMY = 0.0        
      INFL = 1        
C        
C     ARG-R  ARGUMENTS        
C        
      DYB  = YB(IRB)        
      DZB  = ZB(IRB)        
      DA   = A0        
      DELEPS = 1.0        
      C    = CGS        
      S    =-SGS        
      DY   = YS        
      DZ   = ZS        
      ITYPE= 1        
      K    = 1        
      ASSIGN 100 TO IRET1        
      GO TO 2000        
  100 SY   = 1.0        
      SZ   = 1.0        
      SG   = SGS        
      ASSIGN 200 TO IRET1        
      GO TO 5000        
  200 CONTINUE        
C        
C     CHECK SYMMETRY FLAG. BRANCH IF EQUAL TO ZERO        
C        
      IF (ND .EQ. 0) GO TO 700        
C        
C     PORTION FOR SYMMETRIC CALCULATIONS        
C        
      DELEPS = ND        
      C    = CGS        
      S    = SGS        
      DY   =-YS        
      DZ   = ZS        
      ITYPE= 1        
      K    = 2        
      ASSIGN 300 TO IRET1        
      GO TO 2000        
  300 CONTINUE        
      SY   =-1.0        
      SZ   = 1.0        
      SG   =-SGS        
      ASSIGN 400 TO IRET1        
      GO TO 5000        
  400 CONTINUE        
C        
C     CHECK GROUND EFFECTS FLAG. SKIP IF ZERO        
C        
      IF (NE .EQ. 0) GO TO 7000        
C        
C     PORTION FOR COMBINATION OF SYMMETRY AND GROUND EFFECTS        
C        
      ITYPE = 1        
      K     = 3        
      DELEPS= ND*NE        
      C     = CGS        
      S     =-SGS        
      DY    =-YS        
      DZ    =-ZS        
      ASSIGN 500 TO IRET1        
      GO TO 2000        
  500 CONTINUE        
      SY    =-1.0        
      SG    = SGS        
      SZ    =-1.0        
      ASSIGN 600 TO IRET1        
      GO TO 5000        
  600 CONTINUE        
      GO TO 800        
C        
C     SKIP GROUND EFFECTS CALCULATIONS IF FLAG IS ZERO        
C        
  700 IF (NE .EQ. 0) GO TO 7000        
C        
C     PORTION FOR GROUND EFFECTS ONLY        
C        
  800 CONTINUE        
      DELEPS = NE        
      DY   = YS        
      DZ   =-ZS        
      C    = CGS        
      S    = SGS        
      ITYPE= 1        
      K    = 4        
      ASSIGN 900 TO IRET1        
      GO TO 2000        
  900 CONTINUE        
      SY   = 1.0        
      SZ   =-1.0        
      SG   =-SGS        
      ASSIGN 1000 TO IRET1        
      GO TO 5000        
 1000 CONTINUE        
      RETURN        
C        
C     CALCULATION OF EFFECTIVE FORCES        
C        
 2000 CONTINUE        
      RHO2 = (DY-DYB)**2 + (DZ-DZB)**2        
      RHO  = SQRT(RHO2)        
      B    = AVR(IRB)*ARB(IRB)        
      RHODB= RHO/B        
      F    = 1.0        
      IF (RHO .LE. B) GO TO 2020        
      F    = RHODB/(ARB(IRB)*(RHODB-1.0)+1.0)        
2020  CONTINUE        
      ZBAR = (DZ-DZB)/(F*ARB(IRB)) + DZB        
      CALL FZY2 (XS,XBLE,XBTE,DY,ZBAR,DYB,DZB,DA,BETA2,CBAR,KR,DFZZR,   
     1           DFZZI,DFZYR,DFZYI,DFYZR,DFYZI,DFYYR,DFYYI)        
C        
      FWZR = C*DFZZR + S*DFZYR        
      FWZI = C*DFZZI + S*DFZYI        
      FWZ  = FWZ + DELEPS*CMPLX(FWZR,FWZI)        
      FWYR = C*DFYZR + S*DFYYR        
      FWYI = C*DFYZI + S*DFYYI        
      FWY  = FWY + DELEPS*CMPLX(FWYR,FWYI)        
 2060 GO TO (3000,6000), ITYPE        
 3000 GO TO IRET1, (100,200,300,400,500,600,800,900,1000)        
C        
C     CALCULATION LOOP FOR ASSOCIATED BODIES        
C        
 5000 IF (NAS .LE. 0) GO TO 3000        
      I = 1        
      ITYPE = 2        
 5100 IB = NASB(I)        
C        
C     CHECK TO SEE IF THE ASSOCIATED BODY IS THE RECEIVING BODY.        
C        
      IF (IB .NE. IRB) GO TO 5800        
C        
C     IF IT IS DETERMINE IF THE SENDING POINT IS OUTSIDE OR INSIDE THE  
C     BODY.        
C        
      GO TO (5600,5500,5400,5300), K        
 5300 IF (DYB .NE. 0.0) GO TO 5800        
      GO TO 5800        
 5400 IF (DYB .NE. 0.0) GO TO 5800        
 5500 IF (DZB .NE. 0.0) GO TO 5800        
 5600 CONTINUE        
 5800 CONTINUE        
      ETA   = SY*YS        
      ZETA  = SZ*ZS        
      ZBI   = SZ*ZB(IB)        
      YBI   = SY*YB(IB)        
      DARIB = ARB(IB)        
      DAIB  = AVR(IB)        
      CALL SUBI (DAIB,ZBI,YBI,DARIB,ETA,ZETA,CGS,SG,DMMY,DMMY,DMMY,DY,  
     1           DZ,DMMY,DMMY,DMMY,DMMY,S,C,INFL,IOUTFL)        
      IF (IOUTFL) 2000,2060,2000        
 6000 I = I + 1        
      IF (I - NAS) 5100,5100,3000        
 7000 RETURN        
      END        
