      SUBROUTINE CMCOMB (NPS,NENT,NDOF,IC)        
C        
C     THIS SUBROUTINE COMBINES CONNECTION ENTRIES THAT HAVE BEEN SPECIFI
C     ON SEVERAL CONCT OR CONCT1 CARDS.        
C        
      EXTERNAL        ORF        
      LOGICAL         MATCH        
      INTEGER         CE(9),CEID,SCCONN,SCMCON,BUF1,BUF2,SAVCE,ORF,Z,   
     1                SCR2,BUF3,SCORE,COMSET,IO(10),SACONN,AAA(2)       
      DIMENSION       IC(NENT,NPS,NDOF),LIST(32),KROW(6),IERTAB(2000)   
      COMMON /CMB001/ SCR1,SCR2,JUNK(2),SCCONN,SCMCON        
      COMMON /CMB002/ BUF1,BUF2,BUF3,JUNK1(2),SCORE,LCORE        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /BLANK / ISTEP,IDRY        
      DATA    AAA   / 4HCMCO,4HMB   /        
C        
C     CE IS THE CONNECTION ENTRY        
C     KROW(I) IS THE NO. OF ROWS IN THE ITH DOF MATRIX        
C        
      IERSUB = 0        
      ITOMNY = 0        
      IFILE  = SCCONN        
      CALL OPEN (*400,SCCONN,Z(BUF1),0)        
      IFILE = SCMCON        
      CALL OPEN (*400,SCMCON,Z(BUF2),0)        
      NREC  = -1        
      NPSS  = NPS - 1        
      NWORD = NPS + 1        
      IENT  = 0        
      DO 10 I = 1,6        
   10 KROW(I) = 0        
      SAVCE = 0        
   20 CALL READ (*410,*190,SCMCON,CEID,1,0,NNN)        
      NREC  = CEID - SAVCE - 1        
      SAVCE = CEID        
C        
C     GO FIND ENTRY NO. CEID        
C        
      IFILE = SCCONN        
      IF (NREC .EQ. 0) GO TO 40        
      DO 30 I = 1,NREC        
      CALL FWDREC (*420,SCCONN)        
   30 CONTINUE        
C        
C     READ IN CONNECTION ENTRY        
C        
   40 CALL READ (*410,*50,SCCONN,CE,10,1,NNN)        
C        
C     FIND WHICH DOF ARE PRESENT IN CONNECTION ENTRY        
C        
   50 CALL DECODE (CE(1),LIST,NCOMP)        
      DO 180 I = 1,NCOMP        
      ICOMP = LIST(I) + 1        
      IF (KROW(ICOMP) .EQ. 0) GO TO 170        
C        
C     FIND FIRST NON-ZERO ENTRY IN CURRENT CE        
C        
      DO 60 J = 1,NPSS        
      IF (CE(J+2) .EQ. 0) GO TO 60        
      ISUB = J        
      GO TO 70        
   60 CONTINUE        
C        
C     NOW HAVE FOUND FIRST NON-ZERO, SEARCH FOR POSSIBLE        
C     MATCHING ENTRIES IN MATRIX        
C        
   70 NLOOP = KROW(ICOMP)        
      DO 140 J = 1,NLOOP        
      MATCH  = .FALSE.        
      NERSUB = 0        
      DO 110 JJ = ISUB,NPSS        
      IF (IC(J,JJ,ICOMP).EQ.0 .OR. CE(JJ+2).EQ.0) GO TO 110        
      IF (IC(J,JJ,ICOMP)-CE(JJ+2)) 80,100,80        
   80 IF (IERSUB+NERSUB .GT. 2000) ITOMNY = 1        
      IF (IERSUB+NERSUB .GT. 2000) GO TO 90        
      IERTAB(IERSUB+NERSUB+1) = ICOMP        
      IERTAB(IERSUB+NERSUB+2) = JJ        
      IERTAB(IERSUB+NERSUB+3) = IC(J,JJ,ICOMP)        
      IERTAB(IERSUB+NERSUB+4) = CE(JJ+2)        
      NERSUB = NERSUB + 4        
   90 CONTINUE        
      GO TO 110        
  100 MATCH = .TRUE.        
  110 CONTINUE        
      IF (MATCH) IERSUB = IERSUB + NERSUB        
      IF (.NOT.MATCH) GO TO 140        
      DO 130 JJ = ISUB,NPSS        
      IF (CE(JJ+2).NE.0 .AND. IC(J,JJ,ICOMP).NE.0) GO TO 130        
      IC(J,JJ,ICOMP) = IC(J,JJ,ICOMP) + CE(JJ+2)        
  130 CONTINUE        
      IC(J,NPSS+1,ICOMP) = ORF(IC(J,NPSS+1,ICOMP),CE(2))        
      GO TO 180        
  140 CONTINUE        
  150 DO 160 JJ = 1,NPSS        
      IC(NLOOP+1,JJ,ICOMP) = CE(JJ+2)        
  160 CONTINUE        
      IC(NLOOP+1,NPSS+1,ICOMP) = CE(2)        
      KROW(ICOMP) = KROW(ICOMP) + 1        
      GO TO 180        
  170 NLOOP = 0        
      GO TO 150        
  180 CONTINUE        
      GO TO 20        
  190 CONTINUE        
      IF (IERSUB .EQ. 0) GO TO 200        
C        
C     GENERATE ERROR TABLE AND TERMINATE        
C        
      CALL CLOSE (SCCONN,1)        
      CALL CLOSE (SCMCON,1)        
      CALL CMTRCE (IERTAB,IERSUB,ITOMNY)        
      IDRY = -2        
      RETURN        
C        
  200 CONTINUE        
      CALL CLOSE (SCCONN,1)        
      IFILE = SCR2        
      CALL OPEN (*400,SCR2,Z(BUF3),1)        
      DO 240 K = 1,NDOF        
      IROW = KROW(K)        
      IF (IROW) 240,240,210        
  210 DO 230 I = 1,IROW        
      IO(1) = K        
      IO(2) = IC(I,NPS,K)        
      DO 220 J = 1,NPSS        
      IO(J+2) = IC(I,J,K)        
  220 CONTINUE        
      CALL WRITE (SCR2,IO(1),NPS+1,0)        
  230 CONTINUE        
  240 CONTINUE        
      CALL WRITE (SCR2,IO(1),0,1)        
      CALL CLOSE (SCR2,1)        
      CALL OPEN (*400,SCR2,Z(BUF3),0)        
      CALL READ (*410,*250,SCR2,Z(SCORE),LCORE,1,NWD)        
      GO TO 430        
  250 CALL SORT (0,0,NPS+1,2,Z(SCORE),NWD)        
      CALL CLOSE (SCR2,1)        
      CALL OPEN (*400,SCR2,Z(BUF3),1)        
      IFIN = SCORE + NWD - 1        
      IINC = NPS + 1        
      DO 310 I = SCORE,IFIN,IINC        
      IF (Z(I)) 260,310,260        
  260 COMSET = Z(I)        
      IBEG = I + IINC        
      DO 280 J = IBEG,IFIN,IINC        
      IF (Z(J) .EQ. 0) GO TO 280        
      IF (Z(J+1) .GT. Z(I+1)) GO TO 290        
      DO 270 K = 1,NPSS        
      IF (Z(I+K+1) .NE. Z(J+K+1)) GO TO 280        
  270 CONTINUE        
      COMSET = 10*COMSET+Z(J)        
      Z(J) = 0        
  280 CONTINUE        
  290 CALL ENCODE (COMSET)        
      IO(1) = COMSET        
      DO 300 KK = 1,NPS        
      IO(1+KK) = Z(I+KK)        
  300 CONTINUE        
      CALL WRITE (SCR2,IO,NPS+1,1)        
  310 CONTINUE        
      CALL REWIND (SCMCON)        
      IFILE = SCMCON        
      CALL READ (*410,*320,SCMCON,Z(SCORE),LCORE,1,NMCON)        
  320 NCE = 0        
      SACONN = SCCONN        
      CALL OPEN (*400,SCCONN,Z(BUF1),0)        
  330 CALL READ (*360,*340,SCCONN,CE,10,1,NNN)        
  340 NCE = NCE + 1        
      DO 350 I = 1,NMCON        
      IF (NCE .EQ. Z(SCORE+I-1)) GO TO 330        
  350 CONTINUE        
      CALL WRITE (SCR2,CE,NPS+1,1)        
      GO TO 330        
  360 CALL CLOSE (SCMCON,1)        
      CALL CLOSE (SCCONN,1)        
      CALL CLOSE (SCR2,1)        
      SCCONN = SCR2        
      SCR2   = SACONN        
      RETURN        
C        
  400 IMSG = -1        
      GO TO 440        
  410 IMSG = -2        
      GO TO 440        
  420 IMSG = -3        
      GO TO 440        
  430 IMSG = -8        
  440 CALL MESAGE (IMSG,IFILE,AAA)        
      RETURN        
      END        
