      SUBROUTINE FBS21 (BLOCK,Y,YN,NWDS)        
C        
C     FBS2 EXECUTES THE FORWARD/BACKWARD PASS FOR FBS IN RSP        
C                                                        ===        
C        
      INTEGER          BLOCK(20),DBL,BUF(3),SUBNAM(2),BEGN,END        
      REAL             Y(1),YN(1)        
      DOUBLE PRECISION LJJ,L        
      CHARACTER        UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG /  UFM,UWM,UIM,SFM        
      COMMON /SYSTEM/  SYSBUF,NOUT        
CZZ   COMMON /XNSTRN/  L(1)        
      COMMON /ZZZZZZ/  L(1)        
      COMMON /FBSX  /  DBL, N        
      DATA    SUBNAM,  BEGN, END /4HFBS2, 4H1   , 4HBEGN, 4HEND /       
C        
      BUF(1) = SUBNAM(1)        
      BUF(2) = SUBNAM(2)        
      BUF(3) = BEGN        
      CALL CONMSG (BUF,3,0)        
      NBRITM = NWDS/2        
      NBRVEC = (LOCFX(YN) - LOCFX(Y))/NWDS + 1        
      LAST = 1 + (NBRVEC-1)*NBRITM        
      DO 38 J=1,N        
C        
C     MAKE 1ST STRING CALL FOR COLUMN AND SAVE DIAGONAL ELEMENT        
C        
      BLOCK(8) = -1        
      CALL GETSTR (*81,BLOCK)        
      IF (BLOCK(4) .NE. J) GO TO 81        
      JSTR = BLOCK(5)        
      LJJ  = L(JSTR)        
      IF (BLOCK(6) .EQ. 1) GO TO 20        
      NSTR = JSTR + BLOCK(6) - 1        
      JSTR = JSTR + 1        
      BLOCK(4) = BLOCK(4) + 1        
C        
C     PROCESS CURRENT STRING IN TRIANGULAR FACTOR AGAINST EACH        
C     LOAD VECTOR IN CORE -- Y(I,K) = Y(I,K) + L(I,J)*Y(J,K)        
C        
   10 DO 18 K = 1,LAST,NBRITM        
      YJK = Y(J+K-1)        
      IK  = BLOCK(4) + K - 1        
      DO 16 IJ = JSTR,NSTR        
      Y(IK) = Y(IK) + L(IJ)*YJK        
      IK = IK + 1        
   16 CONTINUE        
   18 CONTINUE        
C        
C     GET NEXT STRING IN TRIANGULAR FACTOR        
C        
   20 CALL ENDGET (BLOCK)        
      CALL GETSTR (*30,BLOCK)        
      JSTR = BLOCK(5)        
      NSTR = JSTR + BLOCK(6) - 1        
      GO TO 10        
C        
C     END-OF-COLUMN ON TRIANGULAR FACTOR -- DIVIDE BY DIAGONAL        
C        
   30 DO 34 K = 1,LAST,NBRITM        
      Y(J+K-1) = Y(J+K-1)/LJJ        
   34 CONTINUE        
   38 CONTINUE        
C        
C     INITIALIZE FOR BACKWARD PASS BY SKIPPING THE NTH COLUMN        
C        
      IF (N .EQ. 1) GO TO 65        
      CALL BCKREC (BLOCK)        
      J = N - 1        
C        
C     GET A STRING IN CURRENT COLUMN. IF STRING INCLUDES DIAGONAL,      
C     ADJUST STRING TO SKIP IT.        
C        
   40 BLOCK(8) = -1        
   42 CALL GETSTB (*60,BLOCK)        
      IF (BLOCK(4)-BLOCK(6)+1 .EQ. J) BLOCK(6) = BLOCK(6) - 1        
      IF (BLOCK(6) .EQ. 0) GO TO 59        
      NTERMS = BLOCK(6)        
C        
C     PROCESS CURRENT STRING IN TRIANGULAR FACTOR AGAINST EACH        
C     LOAD VECTOR IN CORE -- Y(J,K) = Y(J,K) + L(J,I)*Y(I,K)        
C        
      DO 58 K = 1,LAST,NBRITM        
      JI = BLOCK(5)        
      IK = BLOCK(4) + K - 1        
      JK = J + K - 1        
      DO 56 II = 1,NTERMS        
      Y(JK) = Y(JK) + L(JI)*Y(IK)        
      JI = JI - 1        
      IK = IK - 1        
   56 CONTINUE        
   58 CONTINUE        
C        
C     TERMINATE CURRENT STRING AND GET NEXT STRING        
C        
   59 CALL ENDGTB (BLOCK)        
      GO TO 42        
C        
C     END-OF-COLUMN -- TEST FOR COMPLETION        
C        
   60 IF (J .NE. 1) GO TO 70        
   65 BUF(3) = END        
      CALL CONMSG (BUF,3,0)        
      RETURN        
C        
   70 J = J - 1        
      GO TO 40        
C        
C     FATAL ERROR MESSAGE        
C        
   81 WRITE  (NOUT,82) SFM,SUBNAM        
   82 FORMAT (A25,' 2149, SUBROUTINE ',2A4,/5X,'FIRST ELEMENT OF A COL',
     1     'UMN OF LOWER TRIANGULAR MATRIX IS NOT THE DIAGONAL ELEMENT')
      CALL MESAGE (-61,0,0)        
      RETURN        
      END        
