      SUBROUTINE READ7 (NR1,OLAMA,OPHIA,NLAMA,NPHIA)        
C        
C     READ7  COPIES NR VECTORS FROM OPHIA TO NPHIA -        
C     IT ALSO PLACES THE EIGENVALUES ON NLAMA        
C     THIS ROUTINE HANDLES BOTH SINGLE AND DOUBLE PRECISION        
C        
      INTEGER          OLAMA,OPHIA,SYSBUF,IX(7),NAME(2),SGLDBL        
      REAL             X(7)        
      DOUBLE PRECISION DCORE(2),DX        
      COMMON /SYSTEM/  SYSBUF        
      COMMON /UNPAKX/  ITB,II,JJ,INCUR        
      COMMON /PACKX /  IT1,IT2,IIP,JJP,INCRP        
CZZ   COMMON /ZZREA1/  CORE(1)        
      COMMON /ZZZZZZ/  CORE(1)        
      EQUIVALENCE      (DCORE(1),CORE(1)) , (X(1),DX)        
      DATA    NAME  /  4HREAD,4H7   /        
C        
C     GET ORGANIZED        
C        
      NR    = NR1        
      LC    = KORSZ(CORE)        
      IBUF1 = LC - SYSBUF + 1        
      IBUF2 = IBUF1 -SYSBUF        
      IBUF3 = IBUF2 -SYSBUF        
      IBUF4 = IBUF3 -SYSBUF        
      IX(1) = OPHIA        
      CALL RDTRL (IX)        
      NROW  = IX(3)        
      II    = 1        
      JJ    = NROW        
      IT1   = IX(5)        
      IT2   = IT1        
      ITB   = IT1        
      DCORE(1) = 0.0D0        
      INCRP = 1        
      ASSIGN 12 TO SGLDBL        
      IF (ITB .EQ. 2) ASSIGN 16 TO SGLDBL        
      INCUR = 1        
C        
C     OPEN OLD FILES        
C        
      CALL GOPEN (OLAMA,CORE(IBUF1),0)        
      CALL FWDREC (*3010,OLAMA)        
      CALL GOPEN (OPHIA,CORE(IBUF2),0)        
C        
C     OPEN NEW FILES TO WRITE        
C        
      CALL GOPEN (NLAMA,CORE(IBUF3),1)        
      CALL GOPEN (NPHIA,CORE(IBUF4),1)        
C        
C     START COPY LOOP        
C        
      CALL MAKMCB (IX,NPHIA,NROW,IX(4),IT2)        
      DO 10 I = 1,NR        
      CALL READ (*3010,*3020,OLAMA,X,7,0,IFL)        
      II = 0        
      CALL UNPACK (*150,OPHIA,DCORE(2))        
      GO TO SGLDBL, (12,16)        
   12 X(1) = SQRT(X(6))        
      DO 14 J = 1,NROW        
   14 CORE(J+2) = CORE(J+2)/X(1)        
      GO TO 20        
   16 DX = SQRT(X(6))        
      DO 18 J = 1,NROW        
   18 DCORE(J+1) = DCORE(J+1)/DX        
   20 IIP = II        
      JJP = JJ        
      CALL PACK (DCORE(2),NPHIA,IX)        
   30 DX = X(3)        
      CALL WRITE (NLAMA,DX,2,1)        
      GO TO 10        
C        
C     NULL COLUMN        
C        
  150 IIP = 1        
      JJP = 1        
      CALL PACK (DCORE,NPHIA,IX)        
      GO TO 30        
   10 CONTINUE        
      CALL CLOSE (OLAMA,1)        
      CALL CLOSE (OPHIA,1)        
      CALL CLOSE (NLAMA,2)        
      CALL CLOSE (NPHIA,1)        
      RETURN        
C        
C     ERRORS        
C        
 3010 NN = -2        
 3012 IFILE = OLAMA        
      CALL MESAGE (NN,IFILE,NAME)        
      RETURN        
 3020 NN = -3        
      GO TO 3012        
      END        
