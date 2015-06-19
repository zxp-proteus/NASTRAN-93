      SUBROUTINE DMFGR (A,M,N,EPS,IRANK,IROW,ICOL)        
C        
C     DMFGR CALCULATES THE RANK AND LINEARLY INDEPENDENT ROWS AND       
C     COLUMNS OF A M BY N MATRIX.  IT EXPRESSES A SUBMATRIX OF        
C     MAXIMAL RANK AS A PRODUCT OF TRIANGULAR FACTORS, NONBASIC ROWS    
C     IN TERMS OF BASIC ONES AND BASIC VARIABLES IN TERMS OF FREE ONES  
C        
C     DIMENSIONED DUMMY VARIABLES        
C        
      DIMENSION A(1),IROW(1),ICOL(1)        
      DOUBLE PRECISION A,PIV,HOLD,SAVE        
C        
C     TEST OF SPECIFIED DIMENSIONS        
C        
      IF (M) 20,20,10        
   10 IF (N) 20,20,40        
   20 IRANK = -1        
   30 RETURN        
C        
C     RETURN IN CASE OF FORMAL ERRORS        
C        
C     INITIALIZE COLUMN INDEX VECTOR        
C     SEARCH FIRST PIVOT ELEMENT        
C        
   40 IRANK = 0        
      PIV = 0.D0        
      JJ  = 0        
      DO 60 J = 1,N        
      ICOL(J) = J        
      DO 60 I = 1,M        
      JJ  = JJ + 1        
      HOLD = A(JJ)        
      IF (DABS(PIV)-DABS(HOLD)) 50,60,60        
   50 PIV = HOLD        
      IR  = I        
      IC  = J        
   60 CONTINUE        
C        
C     INITIALIZE ROW INDEX VECTOR        
C        
      DO 70 I = 1,M        
   70 IROW(I) = I        
C        
C     SET UP INTERNAL TOLERANCE        
C        
      TOL = ABS(EPS*SNGL(PIV))        
C        
C     INITIALIZE ELIMINATION LOOP        
C        
      NM = N*M        
      DO 210 NCOL = M,NM,M        
C        
C     TEST FOR FEASIBILITY OF PIVOT ELEMENT        
C        
      IF (ABS(SNGL(PIV))-TOL) 220,220,90        
C        
C     UPDATE RANK        
C        
   90 IRANK = IRANK + 1        
C        
C     INTERCHANGE ROWS IF NECESSARY        
C        
      JJ = IR - IRANK        
      IF (JJ) 120,120,100        
  100 DO 110 J = IRANK,NM,M        
      I  = J + JJ        
      SAVE = A(J)        
      A(J) = A(I)        
  110 A(I) = SAVE        
C        
C     UPDATE ROW INDEX VECTOR        
C        
      JJ = IROW(IR)        
      IROW(IR) = IROW(IRANK)        
      IROW(IRANK) = JJ        
C        
C     INTERCHANGE COLUMNS IF NECESSARY        
C        
  120 JJ = (IC-IRANK)*M        
      IF (JJ) 150,150,130        
  130 KK = NCOL        
      DO 140 J = 1,M        
      I  = KK + JJ        
      SAVE  = A(KK)        
      A(KK) = A(I)        
      KK = KK - 1        
  140 A(I) = SAVE        
C        
C     UPDATE COLUMN INDEX VECTOR        
C        
      JJ = ICOL(IC)        
      ICOL(IC) = ICOL(IRANK)        
      ICOL(IRANK) = JJ        
  150 KK = IRANK + 1        
      MM = IRANK - M        
      LL = NCOL  + MM        
C        
C     TEST FOR LAST ROW        
C        
      IF (MM) 160,270,270        
C        
C     TRANSFORM CURRENT SUBMATRIX AND SEARCH NEXT PIVOT        
C        
  160 JJ   = LL        
      SAVE = PIV        
      PIV  = 0.D0        
      DO 200 J = KK,M        
      JJ   = JJ + 1        
      HOLD = A(JJ)/SAVE        
      A(JJ)= HOLD        
      L    = J - IRANK        
C        
C     TEST FOR LAST COLUMN        
C        
      IF (IRANK-N) 170,200,200        
  170 II = JJ        
      DO 190 I = KK,N        
      II = II + M        
      MM = II - L        
      A(II) = A(II) - HOLD*A(MM)        
      IF (DABS(A(II))-DABS(PIV)) 190,190,180        
  180 PIV = A(II)        
      IR  = J        
      IC  = I        
  190 CONTINUE        
  200 CONTINUE        
  210 CONTINUE        
C        
C     SET UP MATRIX EXPRESSING ROW DEPENDENCIES        
C        
  220 IF (IRANK-1) 30,270,230        
  230 IR = LL        
      DO 260 J = 2,IRANK        
      II = J - 1        
      IR = IR - M        
      JJ = LL        
      DO 250 I = KK,M        
      HOLD = 0.D0        
      JJ = JJ + 1        
      MM = JJ        
      IC = IR        
      DO 240 L = 1,II        
      HOLD = HOLD + A(MM)*A(IC)        
      IC = IC - 1        
  240 MM = MM - M        
  250 A(MM) = A(MM) - HOLD        
  260 CONTINUE        
C        
C     TEST FOR COLUMN REGULARITY        
C        
  270 IF (N-IRANK) 30,30,280        
C        
C     SET UP MATRIX EXPRESSING BASIC VARIABLES IN TERMS OF FREE        
C     PARAMETERS (HOMOGENEOUS SOLUTION).        
C        
  280 IR = LL        
      KK = LL + M        
      DO 320 J = 1,IRANK        
      DO 310 I = KK,NM,M        
      JJ = IR        
      LL = I        
      HOLD = 0.D0        
      II = J        
  290 II = II - 1        
      IF (II) 310,310,300        
  300 HOLD = HOLD - A(JJ)*A(LL)        
      JJ = JJ - M        
      LL = LL - 1        
      GO TO 290        
  310 A(LL) = (HOLD-A(LL))/A(JJ)        
  320 IR = IR - 1        
      RETURN        
      END        
