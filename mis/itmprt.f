      SUBROUTINE ITMPRT (NAME,ITEM,NZ,IOPT)        
C        
C     WILL PRINT SOF ITEM - USING  E15.7,I10, OR ALPHA FORMAT        
C        
      INTEGER         SYSBUF,OTPE,TWO1,RC        
      REAL            SUBS(3),ITM,ITEM,NAME,LODS,LOAP        
      DIMENSION       ICORE(4),NAME(2)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /SYSTEM/ SYSBUF,OTPE,INX(6),NLPP,INX1(2),LINE,INX2(26)     
CZZ   COMMON /ZZSOFU/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /TWO   / TWO1(32)        
      COMMON /OUTPUT/ HEAD1(96),HEAD2(96)        
      EQUIVALENCE     (ICORE(1),CORE(1))        
      DATA    OPAREN, CPAREN,EC,EC1,EC2,INTGC,ALPHC,ALPHC1,CONT,UNED,D/ 
     1        4H(1X , 4H)   ,4H,1P,,4HE13.,4H6   ,4H,I13,4H,9X,,4HA4  , 
     2        4HCONT, 4HINUE,4HD   /        
      DATA    BLANK , SUBS,ITM/4H    ,4HSUBS,4HTRUC,4HTURE,4HITEM/      
      DATA    EQSS  / 4HEQSS/, BGSS/4HBGSS/, CSTM/4HCSTM /,        
     1        PLTS  / 4HPLTS/, LODS/4HLODS/, LOAP/4HLOAP /        
C        
C        
C     TEST FOR FORMATED TABLE PRINT        
C        
      IF (IOPT .NE. 2) GO TO 5        
      IF (ITEM .EQ. EQSS) GO TO 2000        
      IF (ITEM .EQ. BGSS) GO TO 2100        
      IF (ITEM .EQ. CSTM) GO TO 2200        
      IF (ITEM .EQ. PLTS) GO TO 2300        
      IF (ITEM .EQ. LODS) GO TO 2400        
      IF (ITEM .EQ. LOAP) GO TO 2500        
    5 CONTINUE        
C        
C     PERFORM UNFORMATED DUMP OF TABLE        
C        
      CALL SFETCH (NAME,ITEM,1,RC)        
      IF (RC .NE. 1) GO TO 190        
      DO 10 I = 1,96        
   10 HEAD2(I) = BLANK        
      DO 15 I = 1,3        
   15 HEAD2( I) = SUBS(I)        
      HEAD2( 5) = NAME(1)        
      HEAD2( 6) = NAME(2)        
      HEAD2( 8) = ITM        
      HEAD2(10) = ITEM        
      CALL PAGE        
      HEAD2(12) = CONT        
      HEAD2(13) = UNED        
      HEAD2(14) = D        
      INUM = NZ/2 - 1        
      NS   = INUM + 1        
      LLEN = 0        
      CORE(1) = OPAREN        
      IREC = 0        
   20 WRITE (OTPE,30)IREC        
      IREC = IREC + 1        
   30 FORMAT ('0GROUP NO.',I4)        
      LINE = LINE + 2        
      IF (LINE .GE. NLPP) CALL PAGE        
      IX   = INUM        
      NRED = 0        
      NP   = INUM - 1        
      IV   = 4        
   40 IX   = IX + 1        
      IOUT = 4        
      NRED = NRED + 1        
      NP   = NP + 1        
      CALL SUREAD (CORE(IX),1,FLAG,RC)        
      IF (RC-2) 45,160,170        
   45 I  = NUMTYP(CORE(IX)) + 1        
      IF (I.EQ.1 .AND. IV.NE.4) I = IV        
      IV = I        
      GO TO (140,140,100,120), I        
C        
C     REAL NUMBER  (1)        
C        
  100 IOUT = 1        
      IF (LLEN+13 .GT. 132) GO TO 160        
  110 CORE(NRED+1) = EC        
      CORE(NRED+2) = EC1        
      CORE(NRED+3) = EC2        
      NRED = NRED + 2        
  111 LLEN = LLEN + 13        
      GO TO 40        
C        
C     ALPHA   (2)        
C        
  120 IOUT = 2        
      IF (LLEN+6 .GT. 132) GO TO 160        
  130 CORE(NRED+1) = ALPHC        
      CORE(NRED+2) = ALPHC1        
      NRED = NRED + 1        
      GO TO 111        
C        
C     INTEGER  (3)        
C        
  140 IOUT = 3        
      IF (LLEN+13 .GT. 132) GO TO 160        
  150 ICORE(NRED+1) = INTGC        
      GO TO 111        
C        
C     BUFFER FULL - END RECORD   PRINT LINE        
C        
  160 CORE(NRED+1) = CPAREN        
      IF (NRED .EQ. 1) WRITE (OTPE,161)        
      IF (NRED .EQ. 1) GO TO 162        
  161 FORMAT ('0END OF GROUP - NULL GROUP')        
      WRITE  (OTPE,CORE) (ICORE(I),I=NS,NP)        
  162 LINE = LINE + 1        
      IF (LINE .GE. NLPP) CALL PAGE        
      LLEN = 0        
      NRED = 1        
      NP   = INUM        
      CORE(INUM+1) = CORE(IX)        
      IX   = INUM + 1        
      GO TO (110,130,150,20), IOUT        
C        
C     END OF ITEM        
C        
  170 WRITE  (OTPE,180)        
  180 FORMAT ('0END OF ITEM')        
  190 RETURN        
C        
C     PERFORM FORMATED LISTING OF TABLE        
C        
C     EQSS TABLE        
C        
 2000 CALL SFETCH (NAME,ITEM,1,RC)        
      IF (RC .NE. 1) RETURN        
      CALL SUREAD (CORE(1),4,NOUT,RC)        
      IF (RC .NE. 1) GO TO 3000        
      NSUB = ICORE(3)        
      CALL SUREAD (CORE(1),NZ,NOUT,RC)        
      IF (RC .NE. 2) GO TO 3000        
      IST  = 1  + NOUT        
      LEFT = NZ - NOUT        
      DO 2010 I = 1,NSUB        
      CALL SUREAD (CORE(IST),LEFT,NOUT,RC)        
      IF (RC.NE.2 .AND. RC.NE.3) GO TO 3000        
      ICOMP = 1 + 2*(I-1)        
      CALL CMIWRT (1,NAME,CORE(ICOMP),IST,NOUT,CORE,ICORE)        
 2010 CONTINUE        
      CALL SUREAD (CORE(IST),LEFT,NOUT,RC)        
      IF (RC.NE.2 .AND. RC.NE.3) GO TO 3000        
      CALL CMIWRT (8,NAME,0,IST,NOUT,CORE,ICORE)        
      RETURN        
C        
C     BGSS TABLE        
C        
 2100 CALL SFETCH (NAME,ITEM,1,RC)        
      IF (RC .NE. 1) RETURN        
      NGRD = 1        
      CALL SJUMP (NGRD)        
      IF (NGRD .LT. 0) GO TO 3000        
      IST = 1        
      CALL SUREAD (CORE(IST),NZ,NOUT,RC)        
      IF (RC.NE.2 .AND. RC.NE.3) GO TO 3000        
      CALL CMIWRT (2,NAME,NAME,IST,NOUT,CORE,ICORE)        
      RETURN        
C        
C     CSTM TABLE        
C        
 2200 CALL SFETCH (NAME,ITEM,1,RC)        
      IF (RC .NE. 1) RETURN        
      NGRD = 1        
      CALL SJUMP (NGRD)        
      IF (NGRD .LT. 0) GO TO 3000        
      IST = 1        
      CALL SUREAD (CORE(IST),NZ,NOUT,RC)        
      IF (RC.NE.2 .OR. RC.NE.3) GO TO 3000        
      CALL CMIWRT (3,NAME,NAME,IST,NOUT,CORE,ICORE)        
      RETURN        
C        
C     PLTS TABLE        
C        
 2300 CALL SFETCH (NAME,ITEM,1,RC)        
      IF (RC .NE. 1) RETURN        
      CALL SUREAD (CORE(1),3,NOUT,RC)        
      IF (RC .NE. 1) GO TO 3000        
      IST = 1        
      CALL SUREAD (CORE(IST),NZ,NOUT,RC)        
      IF (RC.NE.2 .AND. RC.NE.3) GO TO 3000        
      CALL CMIWRT (4,NAME,NAME,IST,NOUT,CORE,ICORE)        
      RETURN        
C        
C     LODS TABLE        
C        
 2400 ICODE = 5        
C        
 2410 CALL SFETCH (NAME,ITEM,1,RC)        
      IF (RC .NE. 1) RETURN        
      CALL SUREAD (CORE(1),4,NOUT,RC)        
      IF (RC .NE. 1) GO TO 3000        
      NSUB = ICORE(4)        
      CALL SUREAD (CORE(1),NZ,NOUT,RC)        
      IF (RC .NE. 2) GO TO 3000        
      IST  = 1  + NOUT        
      LEFT = NZ - NOUT        
      DO 2420 I = 1,NSUB        
      CALL SUREAD (CORE(IST),LEFT,NOUT,RC)        
      IF (RC.NE.2 .AND. RC.NE.3) GO TO 3000        
      ICOMP = 1 + 2*(I-1)        
      CALL CMIWRT (ICODE,NAME,CORE(ICOMP),IST,NOUT,CORE,ICORE)        
      ICODE = 6        
 2420 CONTINUE        
      RETURN        
C        
C     LOAP TABLE        
C        
 2500 ICODE = 7        
      GO TO 2410        
C        
C     INSUFFICIENT CORE OR ILLEGAL ITEM FORMAT - FORCE PHYSICAL DUMP    
C        
 3000 WRITE  (OTPE,3010) UWM,ITEM,NAME        
 3010 FORMAT (A25,' 6231, INSUFFICIENT CORE AVAILABLE OR ILLEGAL ITEM ',
     1       'FORMAT REQUIRES AN UNFORMATED', /31X,        
     2       'DUMP TO BE PERFORM FOR ITEM ',A4,' OF SUBSTRUCTURE ',2A4) 
      GO TO 5        
      END        
