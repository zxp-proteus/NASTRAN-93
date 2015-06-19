      SUBROUTINE BSEQGP (NORIG,ILD,JUMP)        
C        
      EXTERNAL        ORF        
      INTEGER         GEOM1,    GEOM2,    SEQGP(3), EOF(3),   SUB(2),   
     1                TWO,      ORF,      OBW,      OP,       RD,       
     2                RDREW,    WRT,      WRTREW,   REW,      GRID(8),  
     3                Z        
      DIMENSION       NORIG(2), ILD(1),   ISYS(100)        
      COMMON /BANDA / IBUF1,    DUM2A(2), NOPCH,    DUM1A,    METHOD,   
     1                ICRIT,    NGPTS,    NSPTS        
      COMMON /BANDB / NBIT,     KORE,     DUM1B,    NGRD        
      COMMON /BANDD / OBW,      NBW,      OP,       NP,       NCM,      
     1                NZERO,    NEL,      NEQ,      NEQR        
      COMMON /BANDS / NN,       MM,       DUM2(2),  NGRID,    DUM3(3),  
     1                MINDEG,   NEDGE        
      COMMON /BANDW / MAXW0,    RMS0,     MAXW1,    RMS1,     I77,      
     1                BRMS0,    BRMS1        
      COMMON /TWO   / TWO(1)        
      COMMON /SYSTEM/ IBUF,     NOUT        
      COMMON /NAMES / RD,       RDREW,    WRT,      WRTREW,   REW,      
     1                NOREW        
      COMMON /GEOMX / GEOM1,    GEOM2        
CZZ   COMMON /ZZBAND/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (IBUF,ISYS(1)),     (NLPP,ISYS(9)),        
     1                (LPCH,ISYS(91)),    (IECHO,ISYS(19))        
      DATA            SUB           ,  EOF    ,  SEQGP          /       
     1                4HSSEQ, 4HGP  ,  3*65535,  5301, 53, 4    /       
C        
C     THIS ROUTINE IS USED ONLY IN BANDIT MODULE        
C        
C     NORIG(I) = ORIGINAL GRID POINT CORRESPONDING TO BANDIT INTERNAL   
C                LABLE I        
C     ILD(I)   = NEW RESEQUENCED LABEL CORRESPONDING TO BANDIT INTERNAL 
C                LABLE I        
C     NN       = NUMBER OF GRID POINTS        
C     NGRD     .LT.0, INSUFF. WORKING CORE, OR SCRATCH ARRAY FOR BANDIT 
C        
      J77 = 0        
      IF (NN.LE.0 .OR. NGRD.LT.0) GO TO 145        
C        
C     PRINT BANDIT SUMMARY.        
C        
      IF (NLPP.LE.48 .AND. METHOD.EQ.0) CALL PAGE1        
      WRITE  (NOUT,10)        
   10 FORMAT (//53X,22H*** BANDIT SUMMARY ***,/,        
     1       /72X,6HBEFORE,5X,5HAFTER)        
C        
      WRITE  (NOUT,20) OBW,NBW,OP,NP,MAXW0,MAXW1        
   20 FORMAT (40X,13HBANDWIDTH (B),15X,2I10,        
     1       /40X,11HPROFILE (P), 17X,2I10,        
     2       /40X,25HMAXIMUM WAVEFRONT (C-MAX),3X,2I10)        
C        
      ANN = FLOAT(NN)        
      AV1 = FLOAT(OP)/ANN        
      AV2 = FLOAT(NP)/ANN        
      WRITE  (NOUT,30) AV1,AV2,RMS0,RMS1,BRMS0,BRMS1,NGPTS        
   30 FORMAT (40X,25HAVERAGE WAVEFRONT (C-AVG),3X,2F10.3,        
     1       /40X,21HRMS WAVEFRONT (C-RMS),7X,2F10.3,        
     2       /40X,21HRMS BANDWITCH (B-RMS),7X,2F10.3,        
     3       /40X,25HNUMBER OF GRID POINTS (N),15X,I8)        
C        
      IF (NSPTS .GT. 0) WRITE (NOUT,35) NSPTS        
   35 FORMAT (40X,23HNUMBER OF SCALAR POINTS,17X,I8)        
C        
      WRITE  (NOUT,40) NEL,NEQR,NEQ        
   40 FORMAT (40X,30HNUMBER OF ELEMENTS (NON-RIGID) ,10X,I8,        
     1       /40X,35HNUMBER OF RIGID ELEMENTS PROCESSED*,5X,I8,        
     2       /40X,35HNUMBER OF MPC  EQUATIONS PROCESSED*,5X,I8)        
C        
      WRITE  (NOUT,50) NCM,MM,MINDEG        
   50 FORMAT (40X,20HNUMBER OF COMPONENTS,20X,I8,        
     1       /40X,20HMAXIMUM NODAL DEGREE,20X,I8,        
     2       /40X,20HMINIMUM NODAL DEGREE,20X,I8)        
C        
      NONZ = 2*NEDGE + NN        
      AN   = NN*NN        
      DEN  = FLOAT(NONZ)*100./AN        
      WRITE  (NOUT,60) NEDGE,DEN,NZERO,KORE        
   60 FORMAT (40X,22HNUMBER OF UNIQUE EDGES,18X,I8,        
     1       /40X,23HMATRIX DENSITY, PERCENT, 16X,F9.3,        
     2       /40X,31HNUMBER OF POINTS OF ZERO DEGREE,9X,I8,        
     3       /40X,16HBANDIT OPEN CORE,24X,I8)        
C        
      IF (ICRIT .EQ. 1) WRITE (NOUT,61)        
      IF (ICRIT .EQ. 2) WRITE (NOUT,62)        
      IF (ICRIT .EQ. 3) WRITE (NOUT,63)        
      IF (ICRIT .EQ. 4) WRITE (NOUT,64)        
   61 FORMAT (40X,10HCRITERION*,25X,13HRMS WAVEFRONT)        
   62 FORMAT (40X,10HCRITERION*,29X,9HBANDWIDTH)        
   63 FORMAT (40X,10HCRITERION*,31X,7HPROFILE)        
   64 FORMAT (40X,10HCRITERION*,25X,13HMAX WAVEFRONT)        
C        
      IF (METHOD .EQ. -1) WRITE (NOUT,66)        
      IF (METHOD .EQ. +1) WRITE (NOUT,67)        
      IF (METHOD .EQ.  0) WRITE (NOUT,68)        
   66 FORMAT (40X,12HMETHOD USED*,34X,2HCM)        
   67 FORMAT (40X,12HMETHOD USED*,33X,3HGPS)        
   68 FORMAT (40X,12HMETHOD USED*,26X,10HCM AND GPS)        
C        
C     WRITE  (NOUT,70)        
C  70 FORMAT (105H0ALL BANDIT STATISTICS USE GRID POINT, RATHER THAN D-O
C    1-F, CONNECTIVITY AND INCLUDE MATRIX DIAGONAL TERMS.)        
      IF (JUMP .EQ. 0) GO TO 90        
      WRITE  (NOUT,75)        
   75 FORMAT (/31X,'(* THESE DEFAULT OPTIONS CAN BE OVERRIDDEN BY THE', 
     1       ' NASTRAN CARD)')        
      WRITE  (NOUT,80)        
   80 FORMAT (//31X,'BANDIT FINDS GRID POINT RE-SEQUENCING NOT ',       
     1       'NECESSARY')        
      GO TO 142        
C        
C     GENERATE SEQGP ARRAY AND OUTPUT SEQGP CARDS        
C        
   90 J = 0        
      DO 100 I = 1,NN        
      Z(J+1) = NORIG(I)        
      Z(J+2) = ILD(I)        
  100 J = J + 2        
      CALL SORT (0,0,2,1,Z(1),J)        
C        
C     CHECK AGAINST ORIGINAL GRID POINT DATA, AND SEE ANY UNUSED GRIDS  
C     (SUCH AS THE THIRD GRID ON CBAR CARD). IF THEY EXIST, BRING THEM  
C     IN, AND RE-SORT TABLE.  (GEOM1 IS READY HERE, SEE BGRID)        
C        
      CALL OPEN (*160,GEOM1,Z(IBUF1),RD)        
      NNX = NN        
      IF (NN .EQ. NGRID) GO TO 106        
      CALL READ (*104,*104,GEOM1,GRID,3,0,K)        
  102 CALL READ (*104,*104,GEOM1,GRID,8,0,K)        
      CALL BISLOC (*103,GRID(1),Z,2,NNX,K)        
      GO TO 102        
  103 NN = NN + 1        
      Z(J+1) = GRID(1)        
      Z(J+2) = NN        
      J = J + 2        
      GO TO 102        
C        
C     DO THE SAME CHECK IF SCALAR POINTS ARE PRESENT        
C        
  104 IF (NSPTS .EQ. 0) GO TO 1045        
      NONZ = J + 2*NSPTS + 2        
      CALL PRELOC (*1045,Z(NONZ),GEOM2)        
      GRID(1) = 5551        
      GRID(2) = 49        
      CALL LOCATE (*1044,Z(NONZ),GRID,K)        
 1042 CALL READ (*1044,*1044,GEOM2,I,1,0,K)        
      CALL BISLOC (*1043,I,Z,2,NNX,K)        
      GO TO 1042        
 1043 NN = NN + 1        
      Z(J+1) = I        
      Z(J+2) = NN        
      J = J + 2        
      GO TO 1042        
 1044 CALL CLOSE (GEOM2,REW)        
 1045 I = NN - NNX        
      IF (I .GT. 0) WRITE (NOUT,105) I        
  105 FORMAT (40X,29HNO. OF NON-ACTIVE GRID POINTS,11X,I8)        
  106 I = (J+7)/8        
      WRITE  (NOUT,107) I        
  107 FORMAT (40X,28HNO. OF SEQGP CARDS GENERATED,12X,I8)        
      WRITE  (NOUT,75)        
      IF (NOPCH .EQ. +9) GO TO 147        
      IF (NNX   .NE. NN) CALL SORT (0,0,2,1,Z(1),J)        
      IF (IECHO .EQ. -1) GO TO 125        
      CALL PAGE1        
      WRITE  (NOUT,110)        
  110 FORMAT (//35X,52HS Y S T E M  G E N E R A T E D  S E Q G P  C A R 
     1D S,/)        
      WRITE  (NOUT,120) (Z(I),I=1,J)        
  120 FORMAT (25X,8HSEQGP   ,8I8)        
  121 FORMAT (    8HSEQGP   ,8I8)        
  125 IF (NOPCH .LE. 0) GO TO 130        
      WRITE (LPCH,121) (Z(I),I=1,J)        
  127 J77 = -2        
      GO TO 141        
C        
C     BEEF UP INTERNAL GRID NOS. BY 1000 AS REQUIRED BY NASTRAN        
C        
  130 DO 140 I = 2,J,2        
  140 Z(I) = Z(I)*1000        
C        
C     REWIND AND SKIP FORWARDS TO THE END OF GEOM1 FILE.        
C     OVERWRITE THE OLD SEQGP RECORD IF NECESSARY.        
C     (WARNING - IF SEQGP IS NOT THE VERY LAST ITEM IN GEOM1 FILE, THE  
C      FOLLOWING LOGIC OF INSERTING SEQGP CARDS NEEDS MODIFICATION -    
C      BECAUSE GEOM1 IS IN ALPHA-NUMERIC SORTED ORDER).        
C        
      CALL REWIND (GEOM1)        
      CALL SKPFIL (GEOM1,+1)        
      CALL SKPFIL (GEOM1,-1)        
      CALL BCKREC (GEOM1)        
      CALL READ (*150,*150,GEOM1,NORIG(1),3,1,I)        
      IF (NORIG(1).EQ.SEQGP(1) .AND. NORIG(2).EQ.SEQGP(2))        
     1    CALL BCKREC (GEOM1)        
      CALL CLOSE (GEOM1,NOREW)        
C        
C     ADD SEQGP CARDS TO THE END OF GEOM1 FILE        
C     SET GEOM1 TRAILER, AND CLEAR /SYSTEM/ 76TH WORD        
C        
      CALL OPEN  (*160,GEOM1,Z(IBUF1),WRT)        
      CALL WRITE (GEOM1,SEQGP(1),3,0)        
      CALL WRITE (GEOM1,Z(1),J,1)        
      CALL WRITE (GEOM1,EOF(1),3,1)        
C        
      Z(1) = GEOM1        
      CALL RDTRL (Z(1))        
      I = (SEQGP(2)+31)/16        
      J = SEQGP(2)-I*16 + 48        
      Z(I) = ORF(Z(I),TWO(J))        
      CALL WRTTRL (Z(1))        
  141 CALL CLOSE (GEOM1,REW)        
  142 DO 143 I = 1,KORE        
  143 Z(I) = 0        
  145 ISYS(I77) = J77        
      IF (NGRD .LT. 0) RETURN        
      CALL PAGE2 (-2)        
      WRITE  (NOUT,146)        
  146 FORMAT (1H0,9X,45H**NO ERRORS FOUND - EXECUTE NASTRAN PROGRAM**)  
      RETURN        
C        
C     SPECIAL PUNCH OPTION (BANDTPCH=+9)        
C     TO PUNCH OUT EXTERNAL GRIDS IN RE-SEQUENCED INTERNAL ORDER        
C        
  147 CALL SORT (0,0,2,2,Z(1),J)        
      WRITE  (NOUT,148) (Z(I),I=1,J,2)        
  148 FORMAT (1H1,35X,59HLIST OF EXTERNAL GRID POINTS IN INTERNAL RE-SEQ
     1UENCED ORDER,/4X,31(4H----),/,(/5X,15I8))        
      WRITE  (LPCH,149) (Z(I),I=1,J,2)        
  149 FORMAT (10I7)        
      GO TO 127        
C        
C     FILE ERROR        
C        
  150 K = -2        
      GO TO 170        
  160 K = -1        
  170 CALL MESAGE (K,GEOM1,SUB)        
      RETURN        
      END        
