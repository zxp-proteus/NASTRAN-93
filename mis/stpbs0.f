      SUBROUTINE STPBS0(X,NCODE,BJ0,BY0)
C     SUBROUTINE  BES0.  J AND Y BESSEL FUNCTIONS OF ORDER ZERO
C     E. ALBANO, ORGN 3721, EXT 1022, OCT. 1967
C     COMPUTES J0(X)  IF X IS GREATER THAN -3.
C     COMPUTES Y0(X)  IF (X IS GREATER THAN E AND NCODE = 1 ),
C           WHERE
      INTEGER NAME(2)
      DATA NAME /4HSTPB,4HS0  /                                         
      E=0.00001
C                 REF. US DEPT OF COMMERCE HANDBOOK (AMS 55)  PG. 369
      A=ABS(X)
      IF(A-3.) 10,10,100
   10 Z=X*X/9.
      BJ0=1.+Z*(-2.2499997+Z*(1.2656208+Z*(-0.3163866+Z*(0.0444479
     1    +Z*(-0.0039444+Z* 0.00021)))))
      IF(NCODE-1)  15,20,15
   15 RETURN
   20 IF(X-E) 200,25,25
   25 BY0=0.63661977*BJ0*(ALOG(X)-.69314718)+.36746691+Z*(0.60559366+Z*
     1    (-0.74350384+Z*(0.25300117+Z*(-0.04261214+Z*(0.00427916
     2    -0.00024846*Z)))))
      RETURN
  100 IF(X   ) 250,250,110
  110 U=1./SQRT(X)
      Z=3./X
      W=0.79788456+Z*(-0.00000077+Z*(-0.0055274+Z*(-0.00009512+Z*
     1  (0.00137237+Z*(-0.00072805+0.00014476*Z)))))
      T=X-0.78539816+Z*(-0.04166397+Z*(-0.00003954+Z*(0.00262573+Z*
     1  (-0.00054125+Z*(-0.00029333+0.00013558*Z)))))
      UW=U*W
      BJ0=UW*COS(T)
      IF(NCODE-1) 15,120,15
  120 BY0=UW*SIN(T)
 1000 RETURN
  200 CONTINUE
  250 CONTINUE
      CALL MESAGE(-7,0,NAME)
      GO TO 1000
      END
