      SUBROUTINE OUTPT4        
C        
C     COPY MATRIX DATA BLOCKS ONTO A FORTRAN TAPE, BINARY OR ASCII      
C     FORMATS, IN DENSE MATRIX FORM (FROM FIRST TO LAST NON-ZERO TERMS  
C     OF COLUMNS), OR IN SPARSE FORM (BY STRINGS)        
C        
C     A LOGICAL OUTPUT RECORD, WHICH CAN BE ONE OR MORE PHYSICAL RECORES
C     BEGINS WITH 3 INTEGER WORD THEN AN ARRAY OF DATA        
C        
C     FIRST  INTEGER WORD = LOGICAL RECORD NUMBER, OR COLUMN NUMBER     
C     SECOND INTEGER WORD = ROW POSITION OF 1ST NONZERO TERM IN COLUMN  
C                         = 0, SPARSE MATRIX (BINARY ONLY)        
C                       .LT.0, SPARSE MATRIX ROW POSITION (ASCII ONLY)  
C     THIRD  INTEGER WORD = NW, LENGTH OF ARRAY DATA THAT FOLLOW        
C                           NW IS BASED ON S.P. WORD COUNT (BINARY ONLY)
C                           NW IS DATA PRECISION TYPE DEPENDENT (ASCII) 
C        
C     OUTPUT4 DOES NOT HANDLE TABLE DATA BLOCK, EXECPT 6 SPECIAL TABLES 
C     KELM, MELM, BELM, KDICT, MDICT, AND BDICT.        
C        
C        
C     OUTPUT4   IN1,IN2,IN3,IN4,IN5 // V,N,P1 / V,N,P2 / V,N,P3  $      
C        
C     PARAMETERS P1, P2 AND P3 ARE INTEGERS        
C        
C     P1 = 0, NO ACTION TAKEN BEFORE WRITE (DEFAULT)        
C        =-1, REWIND TAPE BEFORE WRITE        
C        =-2, AT END, WRITE E-O-F MARK AND REWIND TAPE        
C        =-3, BOTH -1 AND -2        
C        =-9, NOT AVAILABLE        
C        
C     P2 = N, FORTRAN OUTPUT UNIT N (N = 11,...,24)        
C        =-N, MATRIX WILL BE WRITTEN OUT IN SPARSE FORMAT ONTO UNIT N.  
C        
C     P3 = 1, FILE OUTPUT IN FORTRAN BINARY FORMAT (UNFORMATTED)        
C        = 2, FILE OUTPUT IN BCD FORMAT (ASCII, FORMATTED)        
C          .  NO MIXED INTEGERS AND REAL NUMBERS IN A FORMATTED RECORD. 
C             THE RECORD LENGTH IS LESS THAN 132 BYTES.        
C          .  IF INPUT MATRIX TO BE COPIED OUT IS IN S.P., INTEGERS ARE 
C             WRITTEN OUT IN I13, AND S.P.REAL DATA IN 10E13.6.        
C          .  IF INPUT MATRIX TO BE COPIED OUT IS IN D.P., INTEGERS ARE 
C             WRITTEN OUT IN I16, AND D.P.REAL DATA IN 8D16.9.        
C        = 3, FORMATS I16 AHD 8E16.9 ARE USED TO COPY INTEGERS AND S.P. 
C             REAL DATA OUT TO OUTPUT TAPE. P3=3 IS USED ONLY FOR       
C             MACHINE WITH LONG WORDS (60 OR MORE BITS PER WORD)        
C        
C     THESE OUTPUT FORMATS CAN BE CHANGED EASILY BY ALTERING FORMATS    
C     40, 50, 60 AND 370. MAKE SURE AN OUTPUT LINE DOES NOT EXCEED 132  
C     COLUMNS. OTHERWISE, IT WOULD BE FOLDED IN PRINTOUT OR SCREEN      
C     LISTING.        
C        
C     WRITTEN BY G.CHAN/UNISYS  3/93        
C        
      LOGICAL          SPARSE,BO,SP,DP,CP        
      INTEGER          P1,P2,P3,BUF1,D,ZERO,TRL(8),NAME(2),NONE(2),     
     1                 IX(3),BLOCK(20),INP(13),SUB(2),TAB1(6),TAB2(6)   
      REAL             XNS(1)        
      DOUBLE PRECISION DX(1),DXNS(1)        
      CHARACTER*6      DNS,SPA,DS        
      CHARACTER*11     FMD,UNF,FM        
      CHARACTER        UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG /  UFM,UWM,UIM        
      COMMON /BLANK /  P1,P2,P3        
      COMMON /SYSTEM/  IBUFF,NOUT,DUM1(6),NLPP,DUM2(2),LINE,DUM3(2),    
     1                 D(3),DUM22(22),NBPW        
      COMMON /MACHIN/  MACH        
      COMMON /UNPAKX/  ITU,II,JJ,INCR        
      COMMON /TYPE  /  PRC(2),NWD(4)        
CZZ   COMMON /ZZOUT4/  X(1)        
      COMMON /ZZZZZZ/  X(1)        
CZZ   COMMON /XNSTRN/  XNS        
      EQUIVALENCE      (X(1),XNS(1))        
      EQUIVALENCE      (X(1),IX(1),DX(1)),(XNS(1),DXNS(1)),(NM1,NAME(1))
      DATA    INP   /  4HUT1 ,4HUT2 ,4HUT3 ,4HINPT,4HINP1,4HINP2,4HINP3,
     1                 4HINP4,4HINP5,4HINP6,4HINP7,4HINP8,4HINP9/       
      DATA    TAB1  /  4HKELM,4HMELM,4HBELM,4HKDIC,4HMDIC,4HBDIC/,      
     1        TAB2  /  4HHKEL,4HHMEL,4HHBEL,4HHKDI,4HHMDI,4HHBDI/       
      DATA    DNS   ,  SPA  / 'DENSE ', 'SPARSE' /  RZERO,ZERO  / 0.,0 /
      DATA    FMD   ,  UNF  / 'FORMATTED  ','UNFORMATTED' /        
      DATA    NONE  ,  SUB  / 4H (NO,4HNE) ,4HOUTP,4HT4   /        
C        
      SPARSE = P2.LT.0        
      P2   = IABS(P2)        
      IF (P2.LE.10 .OR. P2.GT.24) GO TO 500        
      BO   = P3.NE.1        
      II   = 1        
      INCR = 1        
      LCOR = KORSZ(X(1))        
      BUF1 = LCOR - IBUFF        
C        
      FM = UNF        
      IF (BO) FM = FMD        
      OPEN (UNIT=P2,STATUS='NEW',ACCESS='SEQUENTIAL',FORM=FM,ERR=500)   
      IF (P1.EQ.-1 .OR. P1.EQ.-3) REWIND P2        
C        
      DO 400 IPT = 1,5        
      NDICT = 0        
      INPUT = 100 + IPT        
      TRL(1)= INPUT        
      CALL RDTRL (TRL(1))        
      IF (TRL(1) .LE. 0) GO TO 400        
      CALL FNAME (INPUT,NAME)        
      IF (NM1.EQ.NONE(1) .AND. NAME(2).EQ.NONE(2)) GO TO 400        
      IF (TRL(7).EQ.0 .AND. TRL(8).EQ.0) GO TO 250        
      IF (TRL(4).LT.1 .OR.  TRL(4).GT.8) GO TO 250        
      NC   = TRL(2)        
      NR   = TRL(3)        
      ITU  = TRL(5)        
      IF (NC.EQ.0 .OR. NR.EQ.0 .OR. (ITU.LT.1 .OR. ITU.GT.4)) GO TO 250 
      NWDS = NWD(ITU)        
      IF (NR*NWDS .GE. BUF1) CALL MESAGE (-8,LCOR,SUB)        
      DP   = ITU.EQ.2 .OR. ITU.EQ.4        
      SP   = .NOT.DP        
      CP   = SP .AND. P3.EQ.3 .AND. NBPW.GE.60        
      IF (CP) SP = .FALSE.        
      IF (BO .AND. SPARSE .AND. NC.GT.2000) WRITE (NOUT,10) UWM        
   10 FORMAT (A25,' FROM OUTPUT4 MODULE. ON ASCII TAPE AND SPARSE ',    
     1       'MATRIX OUTPUT, EACH STRING OF DATA IS WRITTEN OUT TO THE',
     2   /5X,'OUTPUT TAPE AS A FORTRAN FORMATTED REDORD. FATAL ERROR',  
     3       ' COULD OCCUR WHEN NO. OF RECORDS EXCEED SYSTEM I/O LIMIT')
C        
C     OPEN INPUT DATA BLOCK TO READ WITH REWIND        
C        
      CALL OPEN (*520,INPUT,X(BUF1),0)        
      CALL FWDREC (*520,INPUT)        
C        
      BLOCK(1) = INPUT        
C        
C     WRITE TRAILER RECORD ON OUTPUT TAPE.        
C     SET FORM (TRL(4)) TO NEGATIVE IF ASCII RECORDS IS REQUESTED       
C        
      K = -TRL(4)        
      IF (.NOT.BO) WRITE (P2   ) NC,NR,TRL(4),ITU,NAME        
      IF (     BO) WRITE (P2,20) NC,NR,K     ,ITU,NAME        
   20 FORMAT (1X,4I13,5X,2A4)        
C        
      IF (SPARSE) GO TO 100        
C        
C     DENSE MATRIX OUTPUT -        
C     WRITE THE MATRIX COLUMNS FROM FIRST TO LAST NON-ZERO TERMS        
C        
   30 DO 80 K = 1,NC        
      II = 0        
      CALL UNPACK (*40,INPUT,X)        
      JJ = (JJ-II+1)*NWDS        
      IF (BO) GO TO 40        
C        
      WRITE (P2) K,II,JJ,(X(L),L=1,JJ)        
      GO TO 80        
C        
   40 M = JJ/2        
      IF (SP) WRITE (P2,50) K,II,JJ,( X(L),L=1,JJ)        
      IF (CP) WRITE (P2,60) K,II,JJ,( X(L),L=1,JJ)        
      IF (DP) WRITE (P2,70) K,II,JJ,(DX(L),L=1,M )        
   50 FORMAT (1X,3I13,/,(1X,10E13.6))        
   60 FORMAT (1X,3I16,/,(1X, 8E16.9))        
   70 FORMAT (1X,3I16,/,(1X, 8D16.9))        
C        
   80 CONTINUE        
C        
      GO TO 210        
C        
C     SPARSE MATRIX OUPUT -        
C     WRITE A RECORD FOR EACH MATRIX COLUMN, IN PACKED STRINGS DATA     
C     IF MATRIX IS NOT WRITTEN IN STRINGS, SEND THE MATRIX TO THE DENSE 
C     MATRIX METHOD        
C        
  100 CALL RECTYP (INPUT,K)        
      IF (K .NE. 0) GO TO 110        
      CALL REWIND (INPUT)        
      CALL FWDREC (*520,INPUT)        
      GO TO 30        
C        
C     BLOCK(2) = STRING TYPE, 1,2,3 OR 4        
C     BLOCK(4) = FIRST ROW POSITION ON A MATRIX COLUMN        
C     BLOCK(5) = POINTER TO STRING IN XNS ARRAY        
C     BLOCK(6) = NO. OF TERMS IN STRING        
C        
  110 NWORDS   = NWD(ITU)        
      NWORD1   = NWORDS - 1        
      DO 200 K = 1,NC        
      BLOCK(8) = -1        
      NW = 0        
  120 CALL GETSTR (*150,BLOCK)        
      IF (BO) GO TO 160        
      LN = BLOCK(6)*NWORDS        
      J1 = BLOCK(5)*NWORDS - NWORD1        
      J2 = J1 + LN - 1        
C        
      NW = NW + 1        
      IX(NW) = BLOCK(4) + 65536*BLOCK(6)        
      L  = 1        
      DO 130 J = J1,J2        
      X(L+NW) = XNS(J)        
  130 L  = L + 1        
      NW = NW + LN        
      IF (NW .GE. BUF1) CALL MESAGE (-8,LCOR,SUB)        
  140 CALL ENDGET (BLOCK)        
      GO TO 120        
  150 IF (NW .GT. 0) WRITE (P2) K,ZERO,NW,(X(J),J=1,NW)        
      GO TO 200        
C        
C     NOTE - FOR THE BCD OUTPUT RECORD, THE 2ND INTEGER WORD, ZERO      
C     BEFORE, IS REPLACED BY THE NEGATIVE OF THE ROW POSITION (IN A     
C     MATRIX COLUMN).        
C     DOUBLE THE POINTER TO THE STRING IN XNS ARRAY, J1, IF DATA TYPE IS
C     COMPLEX, BUT NOT THE LENGTH LN.        
C        
  160 LN = BLOCK(6)        
      J1 = BLOCK(5)        
      IF (BLOCK(2) .GE. 3) J1 = J1*2        
      J2 = J1 + LN - 1        
      MROW = -BLOCK(4)        
C        
C                   ZERO REPLACED   EXACT LENGTH OF XNS, OR DXNS        
C                               /   /        
      IF (SP) WRITE (P2,50) K,MROW,LN,( XNS(J),J=J1,J2)        
      IF (CP) WRITE (P2,60) K,MROW,LN,( XNS(J),J=J1,J2)        
      IF (DP) WRITE (P2,70) K,MROW,LN,(DXNS(J),J=J1,J2)        
      GO TO 140        
C        
  200 CONTINUE        
C        
C     WRITE AN EXTRA NCOL+1 COLUMN RECORD OUT TO P2, AND AT LEAST ONE   
C     VALUE OF ZERO        
C        
  210 M  = 1        
      K  = NC + 1        
      IF (BO) GO TO 220        
      WRITE (P2) K,M,M,RZERO        
      GO TO 230        
  220 IF (SP) WRITE (P2,50) K,M,M,RZERO        
      IF (CP .OR. DP) WRITE (P2,60) K,M,M,RZERO        
  230 DS = DNS        
      IF (SPARSE) DS = SPA        
      WRITE  (NOUT,240) UIM,NAME,P2,INP(P2-10),FM,DS,(TRL(L),L=2,7)     
  240 FORMAT (A29,' FROM OUTPUT4 MODULE. DATA BLOCK ',2A4,' WAS WRITTEN'
     1,       ' OUT TO FORTRAN TAPE',I3,' (',A4,')', /5X,'IN ',A11,     
     2        ' RECORDS. ',A6,' MATRIX FORM.  TRAILER =',5I6,I9)        
      GO TO 280        
C        
C     INPUT FILE IS A TABLE DATA BLOCK        
C     ONLY 6 SPECIAL TABLES ARE ALLOWED        
C        
  250 DO 260 I = 1,6        
      IF (NM1.EQ.TAB1(I) .OR. NM1.EQ.TAB2(I)) GO TO 290        
  260 CONTINUE        
      IF (BO) WRITE (P2,270) UWM,INPUT,NAME,(TRL(J),J=2,7)        
      WRITE  (NOUT,270) UWM,INPUT,NAME,(TRL(J),J=2,7)        
  270 FORMAT (A25,'. INPUT DATA BLOCK',I5,2H, ,2A4,', IS A TABLE OR A ',
     1       'NULL MATRIX. OUTPUT4 MODULE HANDLES ONLY MATRICES', /5X,  
     2       'TRAILER =',6I6)        
  280 CALL CLOSE (INPUT,1)        
      GO TO 400        
C        
C     KELM, MELM AND BELM (AND HKELM, HMELM AND HBELM) TALBES        
C        
  290 IF (SPARSE) WRITE (NOUT,300) UWM,NAME,P2,P3        
  300 FORMAT (A25,'. PARAMETER P2 FOR SPARSE MATRIX IS MEANINGLESS FOR',
     1       ' THE ',2A8,' INPUT FILE.   P2,P3 =',2I4,/)        
      CALL OPEN (*520,INPUT,X(BUF1),0)        
      CALL FWDREC (*520,INPUT)        
      K = -TRL(4)        
      IF (.NOT.BO) WRITE (P2   ) NC,NR,TRL(4),ITU,NAME        
      IF (     BO) WRITE (P2,20) NC,NR,K     ,ITU,NAME        
      J = 1        
      K = 0        
      IF (I .GE. 4) GO TO 310        
      DP = TRL(2).EQ.2        
      SP = .NOT.DP        
      CP = SP .AND. P3.EQ.3 .AND. NBPW.GE.60        
      IF (CP) SP = .FALSE.        
  310 K = K + 1        
      CALL READ (*380,*320,INPUT,X,BUF1-1,1,M)        
      CALL MESAGE (-8,0,SUB)        
  320 IF (I .GE. 4) GO TO 350        
      IF (BO) GO TO 330        
      WRITE (P2) K,J,M,(X(L),L=1,M)        
      GO TO 310        
C        
  330 IF (DP) GO TO 340        
      IF (SP) WRITE (P2,50) K,J,M,( X(L),L=1,M)        
      IF (CP) WRITE (P2,60) K,J,M,( X(L),L=1,M)        
      GO TO 310        
  340 M = M/2        
      WRITE (P2,70) K,J,M,(DX(L),L=1,M)        
      GO TO 310        
C        
C     KDICT, MDICT AND BDICT (AND HKDICT, HMDICT AND HBDICT) TABLES.    
C     INTEGERIZE THE DAMPING CONSTANT (BY 10**8) BEFORE OUTPUT THE ARRAY
C        
  350 NDICT = IX(3) + 5        
      DO 360 I = 8,M,NDICT        
      IX(I) = IFIX(X(I)*100000000.)        
  360 CONTINUE        
      IF (.NOT.BO) WRITE (P2) K,J,M,(IX(L),L=1,M)        
      IF (BO .AND. .NOT.CP) WRITE (P2,370) K,J,M,(IX(L),L=1,M)        
      IF (BO .AND.      CP) WRITE (P2,375) K,J,M,(IX(L),L=1,M)        
  370 FORMAT (1X,3I13,/,(1X,10I13))        
  375 FORMAT (1X,3I13,/,(1X, 8I16))        
      GO TO 310        
C        
  380 IF (.NOT.BO) WRITE (P2) K,J,J,ZERO        
      IF (BO .AND. .NOT.CP) WRITE (P2,370) K,J,J,ZERO        
      IF (BO .AND.      CP) WRITE (P2,375) K,J,J,ZERO        
      IF (NDICT .NE. 0) WRITE  (NOUT,390) UIM,NAME,INP(P2-10)        
  390 FORMAT (A29,'. THE DAMPING CONSTANT TERMS FROM ',2A4,' WERE ',    
     1       'MULTIPLIED BY 10**8, AND INTEGERIZED', /5X,        
     2       'BEFORE WRITING OUT TO ',A4,' OUTPUT FILE')        
      GO TO 280        
C        
  400 CONTINUE        
C        
      IF (P1.NE.-2 .AND. P1.NE.-3) GO TO 600        
      ENDFILE P2        
      REWIND  P2        
      CLOSE (UNIT=P2)        
      GO TO 600        
C        
C     ERRORS        
C        
  500 WRITE  (NOUT,510) UFM,P2        
  510 FORMAT (A23,'. CANNOT OPEN OUTPUT FORTRAN FILE. UNIT =',I4)       
      GO TO  540        
  520 WRITE  (NOUT,530) UWM,INPUT        
  530 FORMAT (A25,'. OUTPT4 CANNOT OPEN INPUT DATA BLOCK',I5)        
C        
  540 CALL MESAGE (-37,0,SUB)        
  600 RETURN        
      END        
