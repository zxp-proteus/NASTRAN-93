      SUBROUTINE COMUGV        
C        
C FOR DDAM/EARTHQUAKE ANALYSES, COMBUGV COMBINES DISPLACEMENT        
C COMPONENTS BY (1)ADDING THE COMPONENTS IN ABS VALUE AND (2)TAKING THE 
C SQUARE ROOT OF THE SUMS OF THE SQUARES. AFTER THIS MODEULE, THE       
C TWO OUTPUT DATA BLOCKS ARE N X NMODES, WHEREAS UGV IS N X (NMODES)(L) 
C MODULE NRLSUM COMBINES STRESSES ACROSS MODES FOR EACH DIRECTION       
C INDIVIDUALLY. THE OUTPUTS OF THIS MODULE HAVE THE DIRECTIONS        
C COMBINED. BUT NRLSUM CAN WORK ON THEM (AFTER CASEGEN AND SDR2) BY     
C SPECIFYING NDIR=1 IN THE DMAP STATEMENT FOR THOSE MODULES.        
C THIS MODULE WILL ALSO COMBINE THE MAXIMUM RESPONSES ACROSS THE MODES  
C BY USING SQRSS TO COME UP WITH ONE RESPONSE VECTOR. THEREFORE THIS    
C MODULE COMBINES COMPONENTS TO GET MAXIMUM RESPONSES BY ADDING (UGVADD)
C AND BY SQRSS (UGVSQR). THEN IT TAKES EACH OF THESE AND TAKES SQRSS    
C ACROSS THE MODES TO GET UGVADC AND UGVSQC, RESPECTIVELY.        
C FINALLY, THE MODULE COMPUTES THE NRL SUMS FOR THE L DIRECTIONS        
C TO USE CASEGEN,SDR2,ETC. ON UGVADC AND UGVSQC, IN CASEGEN,USE        
C LMODES=NDIR=1 IN DMAP STATEMENT. FOR UGVNRL, JUST USE LMODES=1.       
C        
C COMBUGV UGV/UGVADD,UGVSQR,UGVADC,UGVSQC,UGVNRL/V,N,NMODES/V,N,NDIR $  
C        
      INTEGER BUF1,BUF2,BUF3,UGV,UGVADD,UGVSQR,UGVADC,UGVSQC        
      INTEGER UGVNRL        
      INTEGER INDB(2),OUDB(2)        
      DIMENSION NAM(2),MCB(7),MCB1(7),MCB2(7)        
      COMMON/UNPAKX/JOUT,III,NNN,JNCR        
      COMMON/PACKX/IIN,IOUT,II,NN,INCR        
      COMMON/SYSTEM/IBUF        
      COMMON/BLANK/NMODES,NDIR        
CZZ   COMMON/ZZCOMU/Z(1)        
      COMMON/ZZZZZZ/Z(1)        
      DATA UGV,UGVADD,UGVSQR,UGVADC,UGVSQC/101,201,202,203,204/        
      DATA UGVNRL/205/        
      DATA NAM/4HCOMB,4HUGV /        
C        
C OPEN CORE AND BUFFERS        
C        
      LCORE=KORSZ(Z)        
      BUF1=LCORE-IBUF+1        
      BUF2=BUF1-IBUF        
      BUF3=BUF2-IBUF        
      LCORE=BUF3-1        
      IF(LCORE.LE.0)GO TO 1008        
      MCB(1)=UGV        
      CALL RDTRL(MCB)        
      NCOL=MCB(2)        
      NROW=MCB(3)        
      IF(NCOL.NE.NMODES*NDIR)GO TO 1007        
      IF(LCORE.LT.4*NROW)GO TO 1008        
      MCB1(1)=UGVADD        
      MCB1(2)=0        
      MCB1(3)=NROW        
      MCB1(4)=2        
      MCB1(5)=1        
      MCB1(6)=0        
      MCB1(7)=0        
      MCB2(1)=UGVSQR        
      MCB2(2)=0        
      MCB2(3)=NROW        
      MCB2(4)=2        
      MCB2(5)=1        
      MCB2(6)=0        
      MCB2(7)=0        
C        
      JOUT=1        
      III=1        
      NNN=NROW        
      JNCR=1        
      IIN=1        
      IOUT=1        
      II=1        
      NN=NROW        
      INCR=1        
C        
      CALL GOPEN(UGV,Z(BUF1),0)        
      CALL GOPEN(UGVADD,Z(BUF2),1)        
      CALL GOPEN(UGVSQR,Z(BUF3),1)        
C        
C UNPACK NDIR COLUMNS OF UGV WHICH CORRESPOND TO A SINGLE MODE        
C        
      NM1=NMODES-1        
      ND1=NDIR-1        
      DO 120 I=1,NMODES        
C        
C POINTER TO PROPER MODE IN 1ST DIRECTION        
C        
      NSKIP=I-1        
      IF(NSKIP.EQ.0)GO TO 20        
      DO 10 LL=1,NSKIP        
      CALL FWDREC (*1002,UGV)        
   10 CONTINUE        
C        
C UNPACK VECTOR        
C        
   20 CALL UNPACK (*25,UGV,Z(1))        
      GO TO 40        
C        
   25 DO 30 J=1,NROW        
   30 Z(J)=0.        
C        
C SKIP TO NEW DIRECTION, UNPACK, SKIP AND UNAPCK        
C        
   40 IF(ND1.EQ.0)GO TO 100        
      DO 70 J=1,ND1        
      IF(NM1.EQ.0)GO TO 50        
      DO 45 JJ=1,NM1        
      CALL FWDREC (*1002,UGV)        
   45 CONTINUE        
C        
   50 JNROW = J*NROW        
      CALL UNPACK (*55,UGV,Z(JNROW+1))        
      GO TO 70        
   55 DO 60 JJ=1,NROW        
   60 Z(J*NROW+JJ)=0.        
C        
   70 CONTINUE        
C        
C NOW PERFORM EACH OPERATION AND STORE INTO Z(3*NROW+1)        
C        
      DO 80 KK=1,NROW        
      Z(3*NROW+KK)=ABS(Z(KK))+ABS(Z(NROW+KK))+ABS(Z(2*NROW+KK))        
   80 CONTINUE        
      CALL PACK(Z(3*NROW+1),UGVADD,MCB1)        
C        
      DO 90 KK=1,NROW        
      Z(3*NROW+KK)=SQRT(Z(KK)**2+Z(NROW+KK)**2+Z(2*NROW+KK)**2)        
   90 CONTINUE        
      CALL PACK(Z(3*NROW+1),UGVSQR,MCB2)        
      GO TO 110        
C        
C JUST ONE DIRECTION ON UGV- COPY TO DATA BLOCKS        
C        
  100 CALL PACK(Z(1),UGVADD,MCB1)        
      CALL PACK(Z(1),UGVSQR,MCB2)        
C        
C DONE FOR THIS MODE - GET ANOTHER        
C        
  110 CALL REWIND(UGV)        
      CALL FWDREC (*1002,UGV)        
C        
  120 CONTINUE        
C        
      CALL CLOSE(UGVADD,1)        
      CALL CLOSE(UGVSQR,1)        
      CALL WRTTRL(MCB1)        
      CALL WRTTRL(MCB2)        
C        
C NOW COMPUTE NRL SUMS FOR THE L DIRECTIONS        
C        
      MCB1(1)=UGVNRL        
      MCB1(2)=0        
      MCB1(3)=NROW        
      MCB1(4)=2        
      MCB1(5)=1        
      MCB1(6)=0        
      MCB1(7)=0        
      CALL REWIND(UGV)        
      CALL FWDREC (*1002,UGV)        
      CALL GOPEN(UGVNRL,Z(BUF2),1)        
C        
      DO 1240 ND=1,NDIR        
C        
C SET UP VECTOR OF MAXIMUM DISPLACEMENT COMPONENTS AND VECTOR OF SUMS   
C        
      DO 1200 I=1,NROW        
      Z(I)=0.        
 1200 Z(2*NROW+I)=0.        
C        
      DO 1220 I=1,NMODES        
C        
      CALL UNPACK (*1220,UGV,Z(NROW+1))        
C        
C COMPARE TO MAXIMUM COMPONENTS        
C        
      DO 1210 J=1,NROW        
      IF (ABS(Z(NROW+J)).GT.Z(J))Z(J)=ABS(Z(NROW+J))        
      Z(2*NROW+J)=Z(2*NROW+J)+Z(NROW+J)**2        
 1210 CONTINUE        
C        
C GET ANOTHER DISPLACEMENT VECTOR CORRESPONDING TO ANOTHER MODE        
C        
 1220 CONTINUE        
C        
C SUBTRACT THE MAXIMA FROM THE SUMS        
C        
      DO 1230 J=1,NROW        
      Z(2*NROW+J)=Z(2*NROW+J)-Z(J)**2        
C        
C TAKE SQUARE ROOT AND ADD IN THE MAXIMA        
C        
      Z(2*NROW+J)=SQRT(Z(2*NROW+J))+Z(J)        
 1230 CONTINUE        
C        
C PACK RESULTS ANG GET ANOTHER DIRECTION        
C        
      CALL PACK(Z(2*NROW+1),UGVNRL,MCB1)        
 1240 CONTINUE        
C        
      CALL CLOSE(UGV,1)        
      CALL CLOSE(UGVNRL,1)        
      CALL WRTTRL(MCB1)        
C        
C NOW LETS COMBINE RESPONSES OVER THE MODES USING SQRSS. DO FOR BOTH    
C UGVADD AND UGVSQR. THE RESULT WILL BE ONE DISLPACEMENT VECTOR.        
C (BOTH UGVADD AND UGVSQR ARE N X M ( M= NO. OF MODES)        
C        
      INDB(1)=UGVADD        
      INDB(2)=UGVSQR        
      OUDB(1)=UGVADC        
      OUDB(2)=UGVSQC        
C        
      DO 170 I=1,2        
C        
      MCB(1)=INDB(I)        
      CALL RDTRL(MCB)        
      NCOL=MCB(2)        
      NROW=MCB(3)        
      MCB1(1)=OUDB(I)        
      MCB1(2)=0        
      MCB1(3)=NROW        
      MCB1(4)=2        
      MCB1(5)=1        
      MCB1(6)=0        
      MCB1(7)=0        
      IF(NCOL.NE.NMODES)GO TO 1007        
C        
      CALL GOPEN(INDB(I),Z(BUF1),0)        
      CALL GOPEN(OUDB(I),Z(BUF2),1)        
C        
      DO 130 J=1,NROW        
  130 Z(J)=0.        
C        
C UNPACK THE COLUMNS OF INDB AND ACCUMULATE SUMS OF SQUARES        
C        
      DO 150 J=1,NMODES        
      CALL UNPACK (*150,INDB(I),Z(NROW+1))        
C        
      DO 140 K=1,NROW        
  140 Z(K)=Z(K)+Z(NROW+K)**2        
C        
  150 CONTINUE        
C        
      DO 160 K=1,NROW        
  160 Z(K)=SQRT(Z(K))        
C        
      CALL PACK(Z(1),OUDB(I),MCB1)        
C        
      CALL CLOSE(INDB(I),1)        
      CALL CLOSE(OUDB(I),1)        
      CALL WRTTRL(MCB1)        
C        
  170 CONTINUE        
C        
      RETURN        
C        
 1002 CALL MESAGE(-2,UGV,NAM)        
 1007 CALL MESAGE(-7,0,NAM)        
 1008 CALL MESAGE(-8,0,NAM)        
      RETURN        
      END        
