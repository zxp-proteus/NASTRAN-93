      SUBROUTINE TMTSLP        
C        
C     TMTSLP TIME TESTS CPU TIMES FOR VARIOUS TYPES OF LOOPS        
C        
C     COMMENT FROM G.CHAN/UNISYS   5/91        
C     BASICALLY THIS ROUTINE IS SAME AS TIMTS2        
C        
C     IF ALL TIMING CONSTANTS ARE ZEROS (OR 0.001) SYSTEM HAS A WRONG   
C     CPUTIM.MDS SUBROUTINE. MOST LIKELY THE CPUTIM.MIS IS BEING USED.  
C        
      INTEGER          SYSBUF,BUF1,BUF2,END,END2,END4,TYPE,ISUBR(2)     
      REAL             B(1),C(1),D(1),E(16)        
      COMPLEX          AC(1),BC(1),CC(1),DC(1),ADNC        
      DOUBLE PRECISION ADND,AD(1),BD(1),CD(1),DD(1)        
      COMMON /MACHIN/  MACH        
      COMMON /NTIME /  NITEMS,TGINO ,TBLDPK,TINTPK,TPACK ,        
     1                 TUNPAK,TGETST,TPUTST,        
     2                 TTLRSP,TTLRDP,TTLCSP,TTLCDP,        
     3                 TLLRSP,TLLRDP,TLLCSP,TLLCDP,TGETSB        
      COMMON /SYSTEM/  SYSBUF,NOUT,SKIP(74),ISY77        
CZZ   COMMON /ZZTMLP/  A(1)        
      COMMON /ZZZZZZ/  A(1)        
      EQUIVALENCE      (A(1),AC(1),AD(1),B(1),BC(1),BD(1),C(1),CC(1),   
     1                 CD(1),D(1),DC(1),DD(1)),    (E(1),TGINO)        
      DATA    ISUBR /  4HTMTS, 4HLP  /        
C        
C     INITIALIZE        
C     DOUBLE N SIZE SINCE VAX (AND UNIX) CLOCK MAY NOT TICK FAST ENOUGH 
C        
      N = 50        
      IF (MACH .GE. 5) N = 100        
      M = N        
C        
      BUF1 = KORSZ(A) - SYSBUF        
      BUF2 = BUF1 - SYSBUF        
      END  = N*M        
      IF (END .GE. BUF1-1) CALL MESAGE (-8,0,ISUBR)        
C        
C     CPU TIME TESTS        
C        
      ASQ  = M + N        
      ADNO = 1/(ASQ*ASQ)        
      ADND = ADNO        
      ADNC = CMPLX(ADNO,ADNO)        
      END2 = END/2        
      END4 = END/4        
      DO 420 TYPE = 1,4        
      GO TO (10,90,170,250), TYPE        
C        
C     REAL CPU TIME TESTS        
C        
   10 CONTINUE        
C        
      IF (M.GT.END .OR. N.GT.END) CALL MESAGE (-8,0,ISUBR)        
      DO 20 I = 1,END        
   20 A(I) = ADNO        
      CALL CPUTIM (T1,T1,1)        
      DO 40 I = 1,N        
      DO 30 J = 1,M        
      D(J) = A(J)*B(J) + C(J)        
   30 CONTINUE        
   40 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      ASSIGN 340 TO IRET        
      GO TO 330        
   50 CONTINUE        
C        
      DO 60 I = 1,END        
   60 A(I) = ADNO        
      CALL CPUTIM (T1,T1,1)        
      DO 80 I = 1,N        
      DO 70 J = 1,M        
      L = I + J - 1        
      D(J) = A(I)*B(L) + C(J)        
   70 CONTINUE        
   80 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      ASSIGN 350 TO IRET        
      GO TO 330        
C        
C     DOUBLE PRECISION TESTS        
C        
   90 CONTINUE        
C        
      IF (M.GT.END2 .OR. N.GT.END2) CALL MESAGE (-8,0,ISUBR)        
      DO 100 I = 1,END2        
  100 AD(I) = ADND        
      CALL CPUTIM (T1,T1,1)        
      DO 120 I = 1,N        
      DO 110 J = 1,M        
      DD(J) = AD(J)*BD(J) + CD(J)        
  110 CONTINUE        
  120 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      ASSIGN 360 TO IRET        
      GO TO 330        
  130 CONTINUE        
C        
      DO 140 I = 1,END2        
  140 AD(I) = ADND        
      CALL CPUTIM (T1,T1,1)        
      DO 160 I = 1,N        
      DO 150 J = 1,M        
      L = I + J - 1        
      DD(J) = AD(I)*BD(L) + CD(J)        
  150 CONTINUE        
  160 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      ASSIGN 370 TO IRET        
      GO TO 330        
C        
C     COMPLEX SINGLE PRECISION TESTS        
C        
  170 CONTINUE        
C        
      IF (M.GT.END2 .OR. N.GT.END2) CALL MESAGE (-8,0,ISUBR)        
      DO 180 I = 1,END2        
  180 AC(I) = ADNC        
      CALL CPUTIM (T1,T1,1)        
      DO 200 I = 1,N        
      DO 190 J = 1,M        
      DC(J) = AC(J)*BC(J) + CC(J)        
  190 CONTINUE        
  200 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      ASSIGN 380 TO IRET        
      GO TO 330        
  210 CONTINUE        
C        
      DO 220 I = 1,END2        
  220 AC(I) = ADNC        
      CALL CPUTIM (T1,T1,1)        
      DO 240 I = 1,N        
      DO 230 J = 1,M        
      L = I + J - 1        
      DC(J) = AC(I)*BC(L) + CC(J)        
  230 CONTINUE        
  240 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      ASSIGN 390 TO IRET        
      GO TO 330        
C        
C     DOUBLE PRECISION COMPLEX TESTS        
C        
  250 CONTINUE        
C        
      IF (M.GT.END4 .OR. N.GT.END4) CALL MESAGE (-8,0,ISUBR)        
      DO 260 I = 1,END2        
  260 AD(I) = ADND        
      CALL CPUTIM (T1,T1,1)        
      DO 280 I = 1,N        
      DO 270 J = 1,M        
C        
C     D(J) AND D(J+1) CALCULATIONS WERE REVERSED        
C     IN ORDER TO COUNTERACT THE ITERATIVE BUILD UP        
C        
      DD(J+1) = AD(J)*BD(J  ) - AD(J+1)*BD(J+1) + CD(J  )        
      DD(J  ) = AD(J)*BD(J+1) + AD(J+1)*BD(J  ) + CD(J+1)        
  270 CONTINUE        
  280 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      ASSIGN 400 TO IRET        
      GO TO 330        
  290 CONTINUE        
C        
      DO 300 I = 1,END2        
  300 AD(I) = ADND        
      CALL CPUTIM (T1,T1,1)        
      DO 320 I = 1,N        
      DO 310 J = 1,M        
      L = I + J - 1        
      DD(J  ) = AD(I)*BD(L  ) - AD(I+1)*BD(L+1) + CD(J  )        
      DD(J+1) = AD(I)*BD(L+1) + AD(I+1)*BD(L  ) + CD(J+1)        
  310 CONTINUE        
  320 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      ASSIGN 410 TO IRET        
C        
C        
C     INTERNAL ROUTINE TO STORE TIMING DATA IN /NTIME/ COMMON BLOCK     
C        
  330 TIME = T2 - T1        
      ITOT = M*N        
      TPEROP = 1.0E6*TIME/ITOT        
      GO TO IRET, (340,350,360,370,380,390,400,410)        
  340 TTLRSP = TPEROP        
      GO TO 50        
  350 TLLRSP = TPEROP        
      GO TO 420        
  360 TTLRDP = TPEROP        
      GO TO 130        
  370 TLLRDP = TPEROP        
      GO TO 420        
  380 TTLCSP = TPEROP        
      GO TO 210        
  390 TLLCSP = TPEROP        
      GO TO 420        
  400 TTLCDP = TPEROP        
      GO TO 290        
  410 TLLCDP = TPEROP        
  420 CONTINUE        
C        
C     MAKE SURE ALL TIME CONTSTANTS ARE OK        
C        
      DO 430 I = 1,NITEMS        
      IF (ISY77.EQ.-3 .AND. E(I).LT.0.001) E(I) = 0.001        
      IF (ISY77.NE.-3 .AND. E(I).LT.1.E-7) E(I) = 1.E-7        
  430 CONTINUE        
      IF (ISY77 .NE. -3) GO TO 460        
      WRITE  (NOUT,440) NITEMS,NITEMS,E        
  440 FORMAT ('0*** NASTRAN SYSTEM MESSAGE. IF THESE',I4,' NEW TIMING', 
     1   ' CONSTANTS ARE HARD-CODED INTO THE LABEL COMMON /NTIME/ OF',  
     2   /5X, 'SUBROUTINE SEMDBD, COMPILE, AND RE-LINKE LINK 1, THE ',  
     3   'COMPUTATIONS OF THESE CONSTANTS IN ALL NASTRAN JOBS WILL',/5X,
     4   'BE ELIMINATED.',  /5X,'OR TO ACCOMPLISH THE SAME RESULT, ',   
     5   'EDIT THE TIM-LINE IN THE NASINFO FILE TO INCLUDE THESE',I4,   
     6   ' NEW',/5X,'TIMING CONSTANTS', //5X,9F8.3, /5X,7F8.3,//)       
      CALL PEXIT        
  460 CALL SSWTCH (35,J)        
      IF (J .NE. 0) CALL TMTSOT        
C        
      RETURN        
      END        
