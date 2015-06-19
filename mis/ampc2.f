      SUBROUTINE AMPC2 (INP,OUTP,SCRF)        
C        
C     THE PURPOSE OF THIS ROUTINE IS TO COPY SCR5 ONTO THE BOTTOM OF    
C     OUTPUT        
C        
      INTEGER         OUTP,SCRF,SYSBUF,MCBI(7),MCBO(7)        
      COMMON /PACKX / IT1,IT2,II,JJ,INCR        
      COMMON /UNPAKX/ IT3,II1,JJ1,INCR1        
      COMMON /SYSTEM/ SYSBUF        
C     COMMON /ZZAMPC/ IZ(1)        
CZZ   COMMON /ZZAMPX/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      COMMON /TYPE  / ISK(2),IWORD(4)        
C        
C        
      MCBI(1) = INP        
      CALL RDTRL (MCBI)        
      MCBO(1) = OUTP        
      CALL RDTRL (MCBO)        
C        
C     IS THIS THE FIRST ENTRY        
C        
      IF (MCBO(2) .NE. 0) GO TO 10        
C        
C     SWITCH SCRATCH FILES        
C        
      CALL FILSWI (INP,OUTP)        
      RETURN        
C        
C     MUST DO COPY        
C        
   10 CALL FILSWI (OUTP,SCRF)        
      IBUF1 = KORSZ(IZ) - SYSBUF + 1        
      IBUF2 = IBUF1 - SYSBUF        
      IBUF3 = IBUF2 - SYSBUF        
      CALL GOPEN (INP,IZ(IBUF1),0)        
      CALL GOPEN (SCRF,IZ(IBUF2),0)        
      CALL GOPEN (OUTP,IZ(IBUF2),1)        
      NCOL  = MCBI(2)        
      NROWO = MCBI(3) + MCBO(3)        
      IT1   = MCBI(5)        
      IT2   = IT1        
      IT3   = IT1        
      INCR  = 1        
      INCR1 = 1        
      NTERM = NROWO*IWORD(IT1)        
      II    = 1        
      JJ    = NROWO        
      NROWIS= MCBO(3)*IWORD(IT1) + 1        
      II1   = 1        
      NRI   = MCBI(3)        
      NRO   = MCBO(3)        
      MCBO(2) = 0        
      MCBO(6) = 0        
      MCBO(7) = 0        
      MCBO(3) = NROWO        
      DO 20 I = 1,NCOL        
      DO 30 J = 1,NTERM        
      IZ(J) = 0        
   30 CONTINUE        
      JJ1 = NRO        
      CALL UNPACK (*40,SCRF,IZ)        
   40 CONTINUE        
      JJ1 = NRI        
      CALL UNPACK (*50,INP,IZ(NROWIS))        
   50 CALL PACK (IZ,OUTP,MCBO)        
   20 CONTINUE        
      CALL CLOSE (SCRF,1)        
      CALL CLOSE (INP,1)        
      CALL CLOSE (OUTP,1)        
      CALL WRTTRL (MCBO)        
      RETURN        
      END        
