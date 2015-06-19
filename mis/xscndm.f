      SUBROUTINE XSCNDM        
C        
C     THE PURPOSE OF THIS ROUTINE IS TO RETURN TO THE CALLING PROGRAM   
C     THE NEXT BCD OR BINARY ENTRY IN DMAP ARRAY.        
C        
C     IBUFF  = BUFFER AREA WHERE CARD IMAGE IS STORED FOR XRCARD INPUT. 
C     IDLMTR = TABLE OF DELIMITER CHARACTERS        
C     ITYPE  = TABLE FOR CONVERTING NUMBER TYPE TO WORD LENGTH.        
C        
C     LAST REVISED BY G.CHAN/UNISYS, 2/90        
C     REMOVING LVAX AND .NOT.LVAX AND STANDARDIZED ALL BYTE OPERATIONS  
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ORF        
      INTEGER         GNOBUF(1),ITYPE(6),DMPCRD(1),IDLMTR(8),OS(5),     
     1                OSCAR(1)        
      COMMON /SYSTEM/ KSYSTM(100)        
      COMMON /XGPIC / ICOLD,ISLSH,IEQUL,NBLANK,NXEQUI,        
     1                NDIAG,NSOL,NDMAP,NESTM1,NESTM2,NEXIT,        
     2                NBEGIN,NEND,NJUMP,NCOND,NREPT,NTIME,NSAVE,NOUTPT, 
     3                NCHKPT,NPURGE,NEQUIV,NACPW,NBPC,NAWPC,        
     4                MASKHI,MASKLO,ISGNON,NOSGN,IALLON        
      COMMON /XGPIE / NSCR        
CZZ   COMMON /ZZXGPI/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /XGPI4 / IRTURN,INSERT,ISEQN,DMPCNT,        
     1                IDMPNT,DMPPNT,BCDCNT,LENGTH,ICRDTP,ICHAR,NEWCRD,  
     2                MODIDX,LDMAP,ISAVDW,DMAP(1)        
      COMMON /XGPI5 / IAPP,START,ALTER(2)        
      COMMON /XGPI6 / KRUD(6),DIAG14,DIAG17,DIAG4,DIAG25,IFIRST,        
     1                IBUFF(20)        
      COMMON /PASSER/ ISTOPF,MODNAM,KKCOMM        
      EQUIVALENCE     (KSYSTM(3),NOGO),(CORE(1),OS(1),LOSCAR),        
     1                (OS(2),OSPRC),(OS(3),OSBOT),(OS(4),OSPNT),        
     2                (OS(5),OSCAR(1),DMPCRD(1),GNOBUF(1))        
      DATA    ITYPE / 1,1,2,2,2,4/ ,IDLMTR/        
     1        4H$   , 4H/   ,4H=   ,4H,   ,4H(   ,4H)   ,4H    ,4H*   / 
      DATA    NOSCR1/ 4HOSCA/,      NOSCR2/4HR   /        
      DATA    NPT   / 4HNPTP/,      IZERO / 0    /        
      DATA    NWPC  / 18    /,      NCPW  / 4    /        
C        
C *** WARNING - NWPC AFFECTS CODE IN XOSGEN SO BEWARE IF YOU CHANGE IT. 
C        
      KCOMMA = KHRFN1(IZERO,1,IDLMTR(4),1)        
      KBLANK = KHRFN1(IZERO,1,IDLMTR(7),1)        
      KKCOMM = 0        
C        
C     CHECK FOR OSCAR TABLE OVERFLOW        
C        
      IF (OSCAR(OSBOT)+OSBOT .GT. ICRDTP) GO TO 310        
C        
C     CHECK FOR CARD READ ERROR        
C        
      IF (NOGO .EQ. 2) GO TO 340        
C        
C     CHECK FOR NEW CARD NEEDED.        
C        
      IF (NEWCRD .NE. 0) GO TO 200        
      IF (BCDCNT) 330,10,130        
C        
C     BCDCNT = 0, TEST MODE        
C        
   10 IF (MODNAM .EQ. 0) GO TO 90        
      KFL1 = 0        
      ICOM = 0        
      DO 80 KH  = 1,NWPC        
      DO 70 KDH = 1,NCPW        
      NCHAR  = KHRFN1(IZERO,1,IBUFF(KH),KDH)        
      IF (NCHAR-KBLANK) 40,20,40        
   20 IF (KFL1) 30,70,30        
   30 KFL1 = 2        
      GO TO 70        
   40 IF (NCHAR-KCOMMA) 50,60,50        
   50 IF (ICOM.EQ.1 .OR. KFL1.EQ.2) GO TO 90        
      KFL1 = 1        
      GO TO 70        
   60 KFL1 = 2        
      ICOM = ICOM + 1        
      IF (ICOM .NE. 2) GO TO 70        
      KKCOMM = 1        
      GO TO 90        
   70 CONTINUE        
   80 CONTINUE        
   90 IF (DMAP(IDMPNT) .EQ. RSHIFT(IALLON,1)) GO TO 180        
      IF (DMAP(IDMPNT)) 100,110,120        
C        
C     BINARY VALUE - TRANSLATE TYPE INTO LENGTH        
C        
  100 I = IABS(DMAP(IDMPNT))        
      IF (I .GT. 6) GO TO 330        
C        
C     A MISUNDERSTANDING MAKES THE FOLLOWING STATEMENT NECESSARY.       
C        
      DMAP(IDMPNT) = ORF(ISGNON,I)        
      LENGTH = ITYPE(I)        
      DMPPNT = IDMPNT        
      IDMPNT = LENGTH + 1 + IDMPNT        
      IRTURN = 3        
      GO TO 350        
C        
C     CONTINUE MODE - GET NEXT CARD        
C        
  110 NEWCRD = 1        
      GO TO 200        
C        
C     MODE IS BCD, INITIALIZE BCDCNT, DMPPNT, AND CHECK FOR OVERFLOW    
C        
  120 BCDCNT = DMAP(IDMPNT)        
      IDMPNT = IDMPNT + 1        
      IF (2*BCDCNT+IDMPNT .GT. LDMAP) GO TO 330        
C        
C     TEST FOR OPERATOR ENTRY.        
C        
  130 IRTURN = 2        
      IF (DMAP(IDMPNT) .EQ. IALLON) GO TO 150        
  140 DMPPNT = IDMPNT        
      IDMPNT = IDMPNT + 2        
      BCDCNT = BCDCNT - 1        
      GO TO 350        
C        
C     DELIMITER FOUND - CHECK FOR COMPLEX NUMBER        
C        
  150 IRTURN = 1        
C     IF (DMAP(IDMPNT+1) .NE. IDLMTR(5)) GO TO 140        
      IF (KHRFN1(IZERO,1,DMAP(IDMPNT+1),1) .NE.        
     1    KHRFN1(IZERO,1,IDLMTR(5),1)) GO TO 140        
C        
C     LEFT PAREN FOUND - SEE IF TWO NUMBERS FOLLOW        
C        
      IF (DMAP(IDMPNT+2).EQ.-2 .AND. DMAP(IDMPNT+4).EQ.-2) GO TO 160    
      IF (DMAP(IDMPNT+2).NE.-4 .OR.  DMAP(IDMPNT+5).NE.-4) GO TO 140    
C        
C     DOUBLE PRECISION COMPLEX NUMBER FOUND - FORM NUMBER CORRECTLY AND 
C     SET TYPE CODE.        
C        
      DMAP(IDMPNT+5) = DMAP(IDMPNT+4)        
      DMAP(IDMPNT+4) = DMAP(IDMPNT+3)        
      DMAP(IDMPNT+3) = -6        
      GO TO 170        
C        
C     SINGLE PRECISION COMPLEX NUMBER FOUND - FORM NUMBER CORRECTLY     
C        
  160 DMAP(IDMPNT+4) = DMAP(IDMPNT+3)        
      DMAP(IDMPNT+3) = -5        
  170 BCDCNT = 0        
      IDMPNT = IDMPNT + 3        
      GO TO 100        
C        
C     END OF DMAP INSTRUCTION        
C        
  180 IRTURN = 4        
      GO TO 350        
C        
C     GET NEXT CARD IMAGE AND TRANSLATE INTO DMAP ARRAY.        
C        
  200 IBUFCT = 1        
      IBWRD  = 1        
      ICALL  = 0        
C        
C     CHECK FOR INSERT TO BE MADE        
C        
      IF (INSERT.GT.0 .OR. INSERT.EQ.-1) GO TO 210        
      GO TO 250        
C        
C     GET NEXT CARD IMAGE FROM ALTER FILE        
C        
  210 CONTINUE        
      CALL READ (*230,*220,NPT,IBUFF,18,1,L)        
      GO TO 260        
C        
C     NO MORE INSTRUCTIONS TO INSERT FOR THIS ALTER        
C     MOVE NEXT ALTER CONTROL TO ALTER CELLS        
C        
  220 ALTER(1) = IBUFF(1)        
      ALTER(2) = IBUFF(2)        
      GO TO 240        
C        
C     END OF ALTER FILE - SET ALTER CELL INFINITE        
C        
  230 ALTER(1) = 10000        
  240 CONTINUE        
      IF (NEWCRD .GT. 0) GO TO 300        
      GO TO 180        
C        
C     FILL IBUFF WITH CARD IMAGE        
C        
  250 CALL READ (*320,*260,NSCR,IBUFF,NWPC,0,LX)        
C        
C     CHECK INSERT FOR NO PRINT        
C        
  260 IF (INSERT .LT. 0) GO TO 270        
C        
C     PRINTOUT DMAP INSTRUCTION        
C        
      IF (IFIRST .EQ. 0) GO TO 270        
      IF (DIAG17.EQ.0 .AND. (DIAG14.EQ.0 .OR. DIAG14.GE.10)) GO TO 270  
      I = 5        
      IF (NEWCRD .GT. 0) I = 6        
      CALL XGPIMW (I,NWPC,DMPCNT,IBUFF)        
C        
C     CHECK FOR COMMENT CARD        
C        
  270 IF (KHRFN1(IZERO,1,IDLMTR(1),1) .EQ. KHRFN1(IZERO,1,IBUFF(1),1))  
     1    GO TO 200        
C        
C     CONVERT CARD IMAGE        
C        
      CALL XRCARD (DMAP,LDMAP,IBUFF)        
C        
C     CHECK FOR BAD CARD FORMAT        
C        
      IF (DMAP(1) .EQ. 0) GO TO 180        
C        
C     TRANSLATE CARD IMAGE INTO DMAP ARRAY        
C        
      IDMPNT = 1        
      BCDCNT = 0        
      NEWCRD = 0        
      GO TO 10        
C        
C     DIAGNOSTIC MESSAGES -        
C        
C     ERROR IN ALTER DECK - CANNOT FIND LOGICAL END OF CARD        
C        
  300 CALL XGPIDG (40,0,0,0)        
      GO TO 180        
C        
C     OSCAR TABLE OVERFLOW        
C        
  310 CALL XGPIDG (14,NOSCR1,NOSCR2,DMPCNT)        
      CALL XGPIDG (-38,2000,0,0)        
C        
C     THIS DMAP INSTRUCTION NOT FOLLOWED BY END CARD.        
C        
  320 CALL XGPIDG (44,OSPNT,0,0)        
      GO TO 340        
C        
C     CANNOT INTERPRET DMAP CARD        
C        
  330 CALL XGPIDG (34,0,DMPCNT,0)        
C        
C     ABORT - CANNOT CONTINUE COMPILATION        
C        
  340 NOGO   = 2        
      IRTURN = 5        
  350 RETURN        
      END        
