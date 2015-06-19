      SUBROUTINE SGENA (TYPE,BUF,MCB,IFILE,ICODE,IEXTRA,OFILE,OCODE,    
     1                  OEXTRA)        
C        
C     THIS ROUTINE READS SUBSTRUCTURING CONSTRAINT AND DYNAMIC PROPERTY 
C     CARDS AND CONVERTS THEM TO NASTRAN FORMAT        
C        
C     INPUTS -        
C        
C     TYPE   - BCD CARD NAME        
C     BUF    - GINO BUFFER FOR INPUT FILE        
C     MCB    - MATRIX CONTROL BLOCK FOR INPUT FILE        
C     IFILE  - INPUT FILE NAME        
C     ICODE  - LOCATE CODE FOR INPUT CARD TYPE        
C     IEXTRA - NUMBER OF EXTRA WORDS (AFTER GRID) TO BE READ        
C     OFILE  - OUTPUT FILE NAME        
C     OCODE  - LOCATE CODE FOR OUTPUT CARD TYPE        
C     OEXTRA - NUMBER OF EXTRA WORDS (AFTER GRID) TO BE WRITTEN        
C        
      EXTERNAL        ANDF,COMPLF,ORF        
      INTEGER         TYPE(2),BUF(1),MCB(7),ICODE(4),OFILE,OCODE(4),    
     1                OEXTRA,Z,SYSBUF,OUTT,TWO,SUBNAM(2),CARD(20),COMP, 
     2                CIN(6),CODE,CEXIST(6),ANDF,COMPLF,ORF        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /BLANK / IDRY,NAME(2)        
      COMMON /SGENCM/ NONO,NSS,IPTR        
CZZ   COMMON /ZZSGEN/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYSBUF,OUTT        
      COMMON /TWO   / TWO(32)        
      DATA    SUBNAM/ 4HSGEN,4HA    /        
C        
C     LOCATE CARDS ON FILE        
C        
      CALL LOCATE (*200,BUF(1),ICODE(1),ICD)        
      ICODE(4) = 1        
C        
C     WRITE HEADER RECORD ON OUTPUT FILE        
C        
      CALL WRITE (OFILE,ICODE(1),3,0)        
C        
C     READ SID AND SUBSTRUCTURING NAME FROM CARD        
C        
   10 CALL READ (*1002,*150,IFILE,CARD,3,0,NWDS)        
      CARD(4) = CARD(1)        
      N = 6 + OEXTRA        
      DO 20 I = 5,N        
   20 CARD(I) = 0        
C        
C     FIND SUBSTRUCTURE        
C        
      DO 30 I = 1,NSS        
      INAM = 2*I + 3        
      IF (Z(INAM).EQ.CARD(2) .AND. Z(INAM+1).EQ.CARD(3)) GO TO 50       
   30 CONTINUE        
C        
C     SUBSTRUCTURE NOT FOUND - SKIP OVER DATA        
C        
      CALL PAGE2 (-4)        
      WRITE (OUTT,63290) UWM,(CARD(J),J=2,3),TYPE,NAME        
   40 CALL FREAD (IFILE,CARD,2+IEXTRA,0)        
      IF (CARD(1)) 10,40,40        
C        
C     FOUND SUBSTRUCTURE NAME        
C        
   50 IPT  = IPTR + I - 1        
      IGRD = Z(IPT)        
      NGRD = (Z(IPT+1) - Z(IPT))/3        
C        
C     PROCESS GRID-COMPONENT PAIRS        
C        
   60 CALL FREAD (IFILE,CARD(5),2+IEXTRA,0)        
      IGRID = CARD(5)        
      IF (IGRID .EQ. -1) GO TO 10        
      IF (IGRID .EQ.  0) GO TO 60        
      COMP = CARD(6)        
      IF (COMP .EQ. 0) COMP = 1        
      CARD(6) = 0        
      CALL BISLOC (*80,IGRID,Z(IGRD),3,NGRD,IGR)        
      IG = IGR + IGRD - 1        
      NPRO = 0        
   70 IF (Z(IG-3) .NE. Z(IG)) GO TO 90        
      IF (IG .LE. IGRD) GO TO 90        
      IG = IG - 3        
      GO TO 70        
C        
C     BAD GRID        
C        
   80 NONO = 1        
      CALL PAGE2 (-3)        
      WRITE (OUTT,60220) UFM,(CARD(J),J=2,3),IGRID,COMP,TYPE,NAME       
      GO TO 60        
C        
C     SPLIT COMPONENTS        
C        
   90 CALL SPLT10 (COMP,CIN,NCIN)        
  100 CODE = Z(IG+2)        
      IF (CODE .EQ. 0) CODE = 1        
      ISIL = Z(IG+1)        
      CALL DECODE (CODE,CEXIST,NC)        
C        
C     FIND ACTUAL REMAINING COMPONENTS AND WRITE CONVERTED DATA TO      
C     OUTPUT FILE        
C        
      DO 120 J  = 1,NC        
      DO 120 JG = 1,NCIN        
      IF (CIN(JG)-CEXIST(J)-1) 120,110,120        
  110 NPRO = NPRO + 1        
      CARD(5) = ISIL + J - 1        
      CALL WRITE (OFILE,CARD(4),3+OEXTRA,0)        
  120 CONTINUE        
      IF (NPRO .GE. NCIN) GO TO 60        
      IF (Z(IG+3) .NE. Z(IG)) GO TO 80        
      IF ((IG+3) .GE. (IGRD+3*NGRD)) GO TO 80        
      IG = IG + 3        
      GO TO 100        
C        
C     FINISH PROCESSING CARDS BY CLOSING OUTPUT FILE RECORD        
C        
  150 CALL WRITE (OFILE,0,0,1)        
C        
C     TURN OFF TRAILER FOR INPUT CARD TYPE        
C        
      J = (ICODE(2) - 1)/16        
      I = ICODE(2) - 16*J        
      MCB(J+2) = ANDF(COMPLF(TWO(I+16)),MCB(J+2))        
C        
C     TURN ON TRAILER FOR OUTPUT CARD TYPE        
C        
      J = (OCODE(2) - 1)/16        
      I = OCODE(2) - 16*J        
      MCB(J+2) = ORF(TWO(I+16),MCB(J+2))        
C        
C     RETURN        
C        
  200 RETURN        
C        
C     ERRORS        
C        
 1002 CALL MESAGE (-2,IFILE,SUBNAM)        
      RETURN        
60220 FORMAT (A23,' 6022, SUBSTRUCTURE ',2A4,', GRID POINT',I9,        
     1       ', COMPONENTS',I9,1H, /30X,'REFERENCED ON ',2A4,        
     2       ' CARD, DO NOT EXIST ON SOLUTION STRUCTURE ',2A4)        
63290 FORMAT (A25,' 6329, SUBSTRUCTURE ',2A4,' REFERENCED ON ',2A4,     
     1       ' CARD', /30X,'IS NOT A COMPONENT BASIC SUBSTRUCTURE OF ', 
     2       'SOLUTION STRUCTURE ',2A4,/30X,'THIS CARD WILL BE IGNORED')
      END        
