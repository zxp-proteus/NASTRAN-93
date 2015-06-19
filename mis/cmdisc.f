      SUBROUTINE CMDISC        
C        
C     THIS SUBROUTINE DETERMINES THE DISCONNECTED DEGREES OF FREEDOM    
C     AND GENERATES  DISCONNECTION ENTRIES  WHICH ARE MERGED WITH THE   
C     CONNECTION ENTRIES        
C        
      EXTERNAL        ORF        
      INTEGER         SCSFIL,Z,SCORE,COMBO,IPTR(7),SCCONN,BUF3,CE(9),   
     1                ORF,SCDISC,DE(9),AAA(2),SCR1,SCR2,BUF2,OUTT       
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,SCTOC,      
     1                GEOM4,CASECC        
      COMMON /CMB002/ BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,LCORE,INPT,OUTT    
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB        
      COMMON /CMB004/ TDAT(6),NIPNEW        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      DATA    AAA   / 4HCMDI,4HSC   /        
C        
C        
      NWD = NPSUB+2        
      ISVCOR = SCORE        
      ITOT = 0        
      ILEN = LCORE        
      NN = 0        
      KK = SCORE        
      CALL OPEN (*200,SCSFIL,Z(BUF3),0)        
C        
C     LOOP ON THE NUMBER OF PSEUDO STRUCTURES READING THE SIL,C TABLE   
C     INTO CORE FOR EACH.  THE ARRAY IPTR(I) POINTS TO THE START OF     
C     THE I-TH TABLE IN CORE        
C        
      DO 40 I = 1,NPSUB        
      NCSUB = COMBO(I,5)        
C        
C     FIND SIL, C TABLE        
C        
      DO 10 J = 1,NCSUB        
      CALL FWDREC (*210,SCSFIL)        
   10 CONTINUE        
      KK = KK + NN        
      IPTR(I) = KK        
      CALL READ (*210,*20,SCSFIL,Z(KK),LCORE,1,NN)        
      GO TO 220        
C        
C     ZERO OUT SIL VALUES, LOCATION WILL STORE CNEW        
C        
   20 DO 30 J = 1,NN,2        
      Z(KK+J-1) = 0        
   30 CONTINUE        
      LCORE = LCORE - NN        
      ITOT  = ITOT + NN        
      CALL SKPFIL (SCSFIL,1)        
   40 CONTINUE        
      CALL CLOSE (SCSFIL,1)        
C        
C     ALL EQSS HAVE BEEN PROCESSED, NOW SCAN THE CONNECTION ENTRIES     
C     AND GET CNEW VALUES.        
C        
      CALL OPEN (*200,SCCONN,Z(BUF3),0)        
C        
C     READ AND PROCESS CONNECTION ENTRIES ONE AT A TIME        
C        
   50 CALL READ (*80,*60,SCCONN,CE,10,1,NN)        
   60 DO 70 I = 1,NPSUB        
      IF (CE(2+I) .EQ. 0) GO TO 70        
C        
C     TRANSLATE CODED IP TO ACTUAL IP, COMPUTE LOCATION IN OPEN CORE    
C     AND UPDATE CNEW        
C        
      IP = CE(2+I) - 1000000*(CE(2+I)/1000000)        
      LOC = IPTR(I) + 2*IP - 2        
      Z(LOC) = ORF(Z(LOC),CE(1))        
   70 CONTINUE        
      GO TO 50        
C        
C     ALL CONNECTIONS HAVE BEEN ACCOUNTED FOR,NOW DETERMINE DISCONN.    
C        
   80 CONTINUE        
      SCDISC = SCR1        
      IF (SCR1 .EQ. SCCONN) SCDISC = SCR2        
      CALL OPEN (*200,SCDISC,Z(BUF2),1)        
      DO 130 I = 1,NPSUB        
      IF (I .LT. NPSUB) LEN = IPTR(I+1) - IPTR(I)        
      IF (I .EQ. NPSUB) LEN = ITOT - IPTR(I)        
      ISTRT = IPTR(I)        
      DO 120 J = 1,LEN,2        
      DO 90 KDH = 1,9        
      DE(KDH) = 0        
   90 CONTINUE        
      IP  = J/2 + 1        
      LOC = ISTRT + J - 1        
C        
C     POINT IS TOTALLY DISCONNECTED        
C        
      IF (Z(LOC) .EQ. Z(LOC+1)) GO TO 120        
      IF (Z(LOC) .NE. 0) GO TO 100        
C        
C     POINT IS TOTALLY CONNECTED        
C        
      DE(1) = Z(LOC+1)        
      DE(2) = 2**I        
      DE(2+I) = IP        
      GO TO 110        
C        
C     POINT IS PARTIALLY DISCONNECTED        
C        
  100 DE(1) = Z(LOC+1) - Z(LOC)        
      DE(2) = 2**I        
      DE(2+I) = IP        
  110 CALL WRITE (SCDISC,DE,NWD,1)        
  120 CONTINUE        
  130 CONTINUE        
      CALL EOF (SCDISC)        
      CALL CLOSE (SCDISC,1)        
      KK = SCORE        
      LCORE = ILEN        
      CALL OPEN (*200,SCDISC,Z(BUF2),0)        
      CALL REWIND (SCCONN)        
      ID = 1        
  140 CALL READ (*150,*160,SCDISC,Z(KK),LCORE,1,NNN)        
      GO TO 220        
  150 ID = 2        
      CALL READ (*170,*160,SCCONN,Z(KK),LCORE,1,NNN)        
      GO TO 220        
  160 KK = KK + NWD        
      LCORE = LCORE - NWD        
      IF (LCORE .LT. NWD) GO TO 220        
      IF (ID .EQ. 1) GO TO 140        
      GO TO 150        
  170 CALL CLOSE (SCCONN,1)        
      CALL CLOSE (SCDISC,1)        
      CALL OPEN (*200,SCCONN,Z(BUF3),1)        
      LEN = KK - SCORE        
      NIPNEW = LEN/NWD        
      DO 180 I = 1,LEN,NWD        
      Z(SCORE+I) = IABS(Z(SCORE+I))        
  180 CONTINUE        
      CALL SORT (0,0,NWD,2,Z(SCORE),LEN)        
      DO 190 I = 1,LEN,NWD        
      CALL WRITE (SCCONN,Z(SCORE+I-1),NWD,1)        
  190 CONTINUE        
      CALL EOF (SCCONN)        
      CALL CLOSE (SCCONN,1)        
      CALL CLOSE (SCDISC,1)        
      SCORE = ISVCOR        
      LCORE = ILEN        
      RETURN        
C        
  200 IMSG = -1        
      GO TO 230        
  210 IMSG = -2        
      GO TO 230        
  220 IMSG = -8        
  230 CALL MESAGE (IMSG,IFILE,AAA)        
      RETURN        
      END        
