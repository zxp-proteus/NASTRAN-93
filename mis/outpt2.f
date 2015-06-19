      SUBROUTINE OUTPT2        
C        
C     COPY DATA BLOCK(S) ONTO FORTRAN UNIT.        
C        
C     CALL TO THIS MODULE IS        
C        
C     OUTPUT2    IN1,IN2,IN3,IN4,IN5/ /V,N,P1/V,N,P2/V,N,P3/        
C                                      V,N,P4/V,N,P5/V,N,P6 $        
C        
C             P1 = 0, NO ACTION TAKEN BEFORE WRITE        
C                     (DEFAULT P1=0)        
C                =+N, SKIP FORWARD N DATA BLOCKS BEFORE WRITE        
C                =-1, BEFORE WRITE, FORTRAN TAPE IS REWOUND AND A       
C                     HEADER RECORD (RECORD NUMBER 0) ADDED TO TAPE     
C                =-3, THE NAMES OF ALL DATA BLOCKS ON FORTRAN TAPE      
C                     ARE PRINTED AND WRITE OCCURS AT THE END OF TAPE   
C                =-9, WRITE A NULL FILE, ENDFILE AND REWIND FORTRAN     
C                     TAPE.        
C        
C             P2 =    THE FORTRAN UNIT NO. ON WHICH THE DATA BLOCKS WILL
C                     BE WRITTEN. (DEFAULT P2=11).        
C        
C             P3 =    TAPE ID CODE FOR FORTRAN TAPE, AN ALPHANUMERIC    
C                     VARIABLE WHOSE VALUE WILL BE WRITTEN ON A FORTRAN 
C                     TAPE.        
C                     THE WRITING OF THIS ITEM IS DEPENDENT ON THE      
C                     VALUE OF P1 AS FOLLOWS.        
C                          *P1*             *TAPE ID WRITTEN*        
C                           +N                     NO        
C                            0                     NO        
C                           -1                    YES        
C                           -3                     NO (WARNING CHECK)   
C                    (DEFAULT P3 = XXXXXXXX).        
C        
C             P4 = 0, FORTRAN WRITTEN RECORD SIZE IS UNLIMITTED        
C                     (DEFAULT FOR ALL MACHINES, EXECPT IBM)        
C                =-N, MAXIMUM FORTRAN WRITTEN RECORD SIZE IS N TIMES    
C                     THE SYSTEM BUFFER SIZE, N*BUFFSIZE        
C                = N, MAXIMUM FORTRAN WRITTEN RECORD SIZE IS N WORDS.   
C                -    IN ALL CASES, THE MAXIMUM FORTRAN WRITTEN RECORD  
C                     SIZE SHOLD BE .GE. BUFFSIZE, AND .LE. AVAILABLE   
C                     CORE        
C                IBM, IF P4=0, AND SINCE IBM CAN NOT HANDLE UNLIMITED   
C                     RECORD SIZE, RECORD SIZE P4 OF 1024 WORDS IS USED 
C        
C             P5 = 0  FOR NON-SPARSE, AND NON-ZERO FOR SPARSE MATRIX    
C                     OUTPUT        
C                = 0, KEY-WORD RECORD CONTAINS EFFECTIVELY ONE SINGLE   
C                     WORD OF DATA (THIS IS THE ORIGINAL COSMIC/OUTPT2) 
C                = NOT 0, KEY-WORD RECORD CONTAINS 2 WORDS, THUS ALLOW  
C                     SPARSE MATRIX TO BE COPIED OUT.        
C                     FIRST KEY WORD:        
C                        >0, DEFINES THE LENGTH OF NEXT DATA RECORD     
C                        =0, END-OF-FILE        
C                        <0, END-OF-RECORD WITH ANOTHER RECORD TO FOLLOW
C                     SECOND KEY WORD:        
C                        =0, TABLE DATA, OR P5 SPARSE MATRIX OPTION NOT 
C                            REQUESTED        
C                        >0, ROW-BASE FOR NEXT RECORD. FOR EXAMPLE:     
C                            KEYS = 10,200 INDICATE NEXT DATA RECORD IS 
C                            FOR ROW(200+1) THRU ROW(200+10)        
C                            i.e. (ROW(KEY2+J),J=1,KEY1)        
C        
C             P6 = BLANK (DEFAULT)        
C                = *MSC*,    OUTPUT2 WILL ISSUE RECORDS IN MSC/OUTPUT2  
C                            FORMAT WHICH IS SLIGHTLY DIFFERENT FROM    
C                            COSMIC/OUTPUT2.        
C                            (P5 OPTION IS NOT AVAILABLE)        
C        
C     NOTES ABOUT P5        
C             (1) P5 IS IGNORED IN TABLE DATA        
C             (2) POSSIBLY, NON-ZERO ROW ELEMENT MAY START AT 2ND HALF  
C                 OF A COMPLEX WORD        
C             (3) UP TO 3 ZEROS MAY BE IMBEDDED IN NON-ZERO STRING      
C             (4) THE CHOICE OF 2 KEY WORDS IN ONE KEY RECORD OVER 2 KEY
C                 WORDS IN TWO RECORDS (AS IN MSC/NASTRAN), IS NOT TO   
C                 MAKE THE ORIGINAL COSMIC OUTPT2/INPTT2 OBSOLETE.      
C                 (i.e. WE DON'T FOLLOW OTHER PEOPLE BLINDLY SO TO MAKE 
C                 OURSELVES OBSOLETE)        
C             (5) ALTHOUGH OUTPT2 ALWAYS WRITES 2 KEY WORDS OUT IN A    
C                 RECORD. ONE MAY CHOOSE TO READ BACK ONE OR BOTH KEYS. 
C        
C     REVISED  11/90 BY G.CHAN/UNISYS TO INCLUDE P4 AND P5 PARAMETERS   
C     LAST REVISED  2/93 BY G.CHAN    TO INCLUDE P6 PARAMETER        
C        
      IMPLICIT INTEGER (A-Z)        
      LOGICAL         SPARSE,DP        
      CHARACTER*6     MT,MATRIX,TABLE        
      DIMENSION       DX(3),TRL(8),NAME(2),SUBNAM(2),INP(3),NAMEX(2),   
     1                IDHDR(7),IDHDRX(7),P3X(2),TAPCOD(2)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /BLANK / P1,P2,P3(2),P4,P5,P6(2)        
     1       /SYSTEM/ BUFFSZ,NOUT,DUM6(6),NLPP,DUM2(2),LINE,DUM(2),D(3) 
CZZ  2       /ZZOUT2/ X(1)        
     2       /ZZZZZZ/ X(1)        
     3       /MACHIN/ MACH        
      COMMON /UNPAKX/ ITYPE,IROW,NROW,INCR        
      DATA    SUBNAM/ 4HOUTP, 4HT2  /, MATRIX,TABLE /'MATRIX',' TABLE'/ 
      DATA    INP   / 1HT, 1H1, 1H2 /, MSC   / 4HMSC   /        
      DATA    ZERO  , MONE,MTWO,MTRE,MNIN    / 0,-1,-2,-3,-9 /        
      DATA    IDHDR / 4HNAST,4HRAN ,4HFORT,4H TAP,4HE ID,4H COD,4HE - / 
C        
C     CHECK P2 AND P4 PARAMETERS        
C        
      IF (P2.GE.14 .OR. (MACH.LE.4 .AND. MACH.NE.3)) GO TO 20        
      I = P2 - 10        
      IF (I.LT.1 .OR. I.GT.3) GO TO 20        
      J = P2 + 3        
      WRITE  (NOUT,10) UWM,P2,J,INP(I)        
   10 FORMAT (A25,' FROM OUTPUT2 MODULE. UNACCEPTABLE FORTRAN UNIT',I3, 
     1       ' WAS CHANGED TO',I3,' (INP',A1,1H))        
      P2 = J        
C        
   20 IF (P4) 25,30,35        
   25 LREC = -P4*BUFFSZ        
      GO TO 40        
   30 LREC = LCOR        
      IF (MACH  .EQ.   2) LREC = 1024        
      IF (P6(1) .EQ. MSC) LREC = 2*BUFFSZ        
      GO TO 40        
   35 LREC = P4        
   40 IF (LREC .GT.   LCOR) LREC = LCOR        
      IF (LREC .LT. BUFFSZ) LREC = BUFFSZ        
      IF (P4 .NE. 0) WRITE (NOUT,50) UIM,LREC        
   50 FORMAT (A29,' 4116, MAXIMUM FORTRAN RECORD SIZE USED IN OUTPUT2 ',
     1        'WAS',I8,' WORDS')        
      P4 = LREC        
      IF (P6(1) .EQ. MSC) CALL OUTMSC (*1000,*420)        
C        
      SPARSE = .FALSE.        
      IF (P5 .NE. 0) SPARSE = .TRUE.        
      ENDFIL = 0        
      ENDREC = 0        
      LCOR   = KORSZ(X) - BUFFSZ        
      ICRQ   =-LCOR        
      IF (LCOR .LE. 0) GO TO 890        
      INBUF  = LCOR + 1        
      TAPCOD(1) = P3(1)        
      TAPCOD(2) = P3(2)        
      OUT = P2        
      IF (P1 .EQ. MNIN) GO TO 410        
      IF (P1.LT.MTRE .OR. P1.EQ.MTWO) GO TO 810        
C        
      IF (P1 .EQ. MTRE) GO TO 500        
      IF (P1 .LE. ZERO) GO TO 80        
C        
      I = 1        
   60 READ (OUT) KEY        
      KEYX = 2        
      IF (KEY .NE. KEYX) GO TO 900        
      READ (OUT) NAMEX        
      READ (OUT) KEY        
      IF (KEY .GE. 0) GO TO 920        
      ASSIGN 70 TO RET        
      NSKIP = 1        
      GO TO 700        
   70 I = I + 1        
      IF (I .LE. P1) GO TO 60        
C        
   80 IF (P1 .NE. MONE) GO TO 90        
C        
C     REWIND OUTPUT TAPE. (P1 = -1)        
C        
      REWIND OUT        
      KEY = 3        
      WRITE (OUT) KEY,ZERO        
      WRITE (OUT) D        
      KEY = 7        
      WRITE (OUT) KEY,ZERO        
      WRITE (OUT) IDHDR        
      KEY = 2        
      WRITE (OUT) KEY,ZERO        
      WRITE (OUT) P3        
      ENDREC = ENDREC - 1        
      WRITE (OUT) ENDREC,ZERO        
      WRITE (OUT) ENDFIL,ZERO        
      ENDREC = 0        
C        
   90 DO 400 I = 1,5        
      INPUT  = 100 + I        
      TRL(1) = INPUT        
      CALL RDTRL (TRL)        
      IF (TRL(1) .LE. 0) GO TO 400        
      CALL FNAME (INPUT,NAME)        
C        
C     OPEN INPUT DATA BLOCK TO READ WITH REWIND.        
C        
      CALL OPEN (*800,INPUT,X(INBUF),0)        
      CALL SKPREC (INPUT,1)        
      TRL(8) = 1        
      CALL RECTYP (INPUT,IREC1)        
      IF (IREC1 .NE. 0) GO TO 100        
      TRL(8) = 0        
      CALL READ (*100,*100,INPUT,X(1),1,1,NF)        
      CALL RECTYP (INPUT,IREC2)        
      IF (IREC2 .EQ. 0) GO TO 100        
      TRL(8) = 2        
  100 CALL REWIND (INPUT)        
      KEY = 2        
      WRITE (OUT) KEY,ZERO        
      WRITE (OUT) NAME        
      ENDREC = ENDREC - 1        
      WRITE (OUT) ENDREC,ZERO        
      KEY = 8        
      WRITE (OUT) KEY,ZERO        
      WRITE (OUT) TRL        
      ENDREC = ENDREC - 1        
      WRITE (OUT) ENDREC,ZERO        
      INDEX = 0        
C        
C     COPY CONTENTS OF INPUT DATA BLOCK ONTO FILE.        
C     (OR THE HEADER RECORD OF A MATRIX DATA BLOCK)        
C        
C     COMMENTS FROM G.CHAN/UNISYS  2/93        
C     THE WRITES IN LOOP 110 AND 120 SEEM DATA TYPE (S.P. OR D.P.)      
C     INCENSITIVE. THE D.P. DATA IN KELM, MELM AND BELM TABLES SHOULD   
C     WORK OK.        
C        
  110 CALL READ (*310,*120,INPUT,X(1),LREC,0,NF)        
      WRITE (OUT) LREC,ZERO        
      WRITE (OUT) (X(L),L=1,LREC)        
      GO TO 110        
C        
  120 WRITE (OUT) NF,ZERO        
      WRITE (OUT) (X(L),L=1,NF)        
      ENDREC = ENDREC - 1        
      WRITE (OUT) ENDREC,ZERO        
      IF (TRL(8) .EQ. 0) GO TO 110        
      IF (TRL(8) .EQ. 1) GO TO 130        
      IF (INDEX  .GT. 0) GO TO 130        
      INDEX = 1        
      GO TO 110        
C        
C     COPY STRING FORMATTED MATRIX        
C        
  130 IF (TRL(8).EQ.2 .AND. INDEX.EQ.2) GO TO 140        
      INDEX = 2        
      NWDS  = TRL(5)        
      DP    = .FALSE.        
      IF (NWDS.EQ.2 .OR. NWDS.EQ. 4) DP = .TRUE.        
      DSP   = 1        
      IF (DP) DSP = 2        
      IF (NWDS .EQ. 3) NWDS = 2        
C         NWDS=1,SP  -  =2,DP,CS  -  =4,CDP        
C        
      INCR = 1        
      NWDS = TRL(3)*NWDS        
C        
C     CHECK FOR NULL MATRIX        
C        
      IF (TRL(2).EQ.0 .OR. TRL(3).EQ.0) GO TO 310        
C        
C     NWDS HAS NUMBER WORDS NEEDED PER COLUMN        
C        
      ICRQ = NWDS - LCOR        
      IF (NWDS .GT. LCOR) GO TO 890        
      ITYPE = TRL(5)        
      IROW  = 1        
      NROW  = TRL(3)        
      NCOL  = TRL(2)        
      IF (TRL(8) .EQ. 2) NCOL = 1        
  140 DO 300 L = 1,NCOL        
      CALL UNPACK (*180,INPUT,X)        
      IF (SPARSE) GO TO 200        
  150 DO 160 KB = 1,NWDS,LREC        
      KE = KB + LREC - 1        
      IF (KE .GT. NWDS) KE = NWDS        
      KBE = KE - KB + 1        
      WRITE (OUT) KBE,ZERO        
      WRITE (OUT) (X(K),K=KB,KE)        
  160 CONTINUE        
C        
  170 ENDREC = ENDREC - 1        
      WRITE (OUT) ENDREC,ZERO        
      GO TO 300        
  180 IF (SPARSE) GO TO 170        
      DO 190 K = 1,NWDS        
      X(K) = 0        
  190 CONTINUE        
      GO TO 150        
C        
C     SPARSE MASTRIX OUT        
C        
  200 J12 = -1        
      DO 260 J = 1,NWDS,DSP        
      IF (J12  .GE.  +1) GO TO 220        
      IF (X(J) .NE. 0.0) GO TO 210        
      IF (DP) IF (X(J+1)) 210,260,210        
      GO TO 260        
  210 J12 = +1        
      K2  = J - 1        
      GO TO 260        
  220 IF (X(J) .NE. 0.0) GO TO 260        
      IF (DP) IF (X(J+1)) 260,230,260        
  230 IF (J12 .EQ. -1) CALL MESAGE (-37,0,SUBNAM)        
      J12 = J12 + 1        
C        
C     ALLOW UP TO 3 IMBEDDED ZEROS        
C        
      IF (J12 .LE. 3) GO TO 260        
      IF (X(J-1).NE.0.0 .OR. X(J-2).NE. 0.0) GO TO 260        
      J12 = -1        
      K1  = J - K2        
      IF (K1 .GT. LREC) GO TO 240        
      WRITE (OUT) K1,K2        
      WRITE (OUT) (X(K2+K),K=1,K1)        
      GO TO 260        
  240 KE = J        
      KB = K2 + 1        
      DO 250 KK = KB,KE,LREC        
      K2 = KK - 1        
      K1 = K2 + LREC        
      IF (K1 .GT. KE) K1 = KE        
      WRITE (OUT) K1,K2        
      WRITE (OUT) (X(K2+K),K=1,K1)        
  250 CONTINUE        
  260 CONTINUE        
C        
      IF (J12 .EQ. -1) GO TO 290        
      J12 = -1        
      K1  = NWDS - K2        
      IF (K1 .GE. LREC) GO TO 270        
      WRITE (OUT) K1,K2        
      WRITE (OUT) (X(K2+K),K=1,K1)        
      GO TO 290        
  270 KE = NWDS        
      KB = K2 + 1        
      DO 280 KK = KB,KE,LREC        
      K2 = KK - 1        
      K1 = K2 + LREC        
      IF (K1 .GT. KE) K1 = KE        
      WRITE (OUT) K1,K2        
      WRITE (OUT) (X(K2+K),K=1,K1)        
  280 CONTINUE        
C        
  290 ENDREC = ENDREC - 1        
      WRITE (OUT) ENDREC,ZERO        
C        
  300 CONTINUE        
C        
      IF (TRL(8) .EQ. 2) GO TO 110        
C        
C     CLOSE INPUT DATA BLOCK WITH REWIND        
C        
  310 CALL CLOSE (INPUT,1)        
C        
      WRITE (OUT) ENDFIL,ZERO        
      ENDREC = 0        
      CALL PAGE2 (-4)        
      MT = MATRIX        
      IF (TRL(8) .EQ. 0) MT = TABLE        
      WRITE  (NOUT,320) UIM,MT,NAME,OUT,(TRL(II),II=2,7)        
  320 FORMAT (A29,' 4114, ',A6,' DATA BLOCK ',2A4,        
     1       ' WRITTEN ON FORTRAN UNIT',I4, /5X,'TRAILR =',5I6,I9)      
      IF (SPARSE .AND. TRL(8).NE.0) WRITE (NOUT,330)        
  330 FORMAT (1H+,55X,'(SPARSE MATRIX)')        
C        
  400 CONTINUE        
      GO TO 1000        
C        
C     FINAL CALL TO OUTPUT2. (P1 = -9)        
C        
  410 WRITE (OUT) ENDFIL,ZERO        
  420 ENDREC = 0        
      ENDFILE OUT        
      REWIND OUT        
      WRITE  (NOUT,430) UIM        
  430 FORMAT (A29,'. OUTPUT2 MODULE WROTE AN E-O-F RECORD, A SYSTEM ',  
     1       'E-O-F MARK, AND REWOUND THE OUTPUT TAPE. (P1=-9)')        
      GO TO 1000        
C        
C     OBTAIN LIST OF DATA BLOCKS ON FORTRAN TAPE.  (P1 = -3)        
C        
  500 REWIND OUT        
      READ (OUT) KEY        
      KEYX = 3        
      IF (KEY .NE. KEYX) GO TO 900        
      READ (OUT) DX        
      READ (OUT) KEY        
      KEYX = 7        
      IF (KEY .NE. KEYX) GO TO 900        
      READ (OUT) IDHDRX        
      DO 510 KF = 1,7        
      IF (IDHDRX(KF) .NE. IDHDR(KF)) GO TO 830        
  510 CONTINUE        
      READ (OUT) KEY        
      KEYX = 2        
      IF (KEY .NE. KEYX) GO TO 900        
      READ (OUT) P3X        
      IF (P3X(1).NE.P3(1) .OR. P3X(2).NE.P3(2)) GO TO 850        
  520 ASSIGN 530 TO RET        
      NSKIP = 1        
      GO TO 700        
  530 KF = 0        
  540 CALL PAGE1        
      LINE = LINE + 8        
      WRITE  (NOUT,550) OUT        
  550 FORMAT (1H0, 50X, 30HFILE CONTENTS ON FORTRAN UNIT , I2,        
     1            /51X, 32(1H-), ///54X, 4HFILE, 18X, 4HNAME/1H0)       
  560 READ (OUT) KEY        
      IF (KEY) 870,600,570        
  570 READ (OUT) NAMEX        
      ASSIGN 580 TO RET        
      NSKIP = 1        
      GO TO 700        
  580 KF   = KF + 1        
      LINE = LINE + 1        
      WRITE  (NOUT,590) KF,NAMEX        
  590 FORMAT (53X,I5,18X,2A4)        
      IF (LINE-NLPP) 560,540,540        
  600 ASSIGN 90 TO RET        
      NSKIP = -(KF+1)        
      GO TO 700        
C        
C     SIMULATION OF SKPFIL (OUT,NSKIP)        
C        
  700 IF (NSKIP) 720,710,730        
  710 GO TO RET, (70,90,530,580)        
  720 REWIND OUT        
C        
C     NSKIP IS THE NEGATIVE OF THE NUMBER OF FILES TO BE SKIPPED        
C        
      NSKIP = -NSKIP        
  730 DO 770 NS = 1,NSKIP        
  740 READ (OUT) KEY        
      IF (KEY) 740,760,750        
  750 CONTINUE        
C     ICRQ = KEY - LCOR        
C     IF (KEY .GT. LCOR) GO TO 9917        
      READ (OUT) L        
      GO TO 740        
  760 CONTINUE        
  770 CONTINUE        
      GO TO 710        
C        
C        
C     ERRORS        
C        
  800 MM = -1        
      GO TO 950        
C        
  810 WRITE  (NOUT,820) UFM,P1        
  820 FORMAT (A23,' 4120, MODULE OUTPUT2 - ILLEGAL VALUE FOR FIRST ',   
     1       'PARAMETER =',I20)        
      LINE = LINE + 2        
      GO TO 940        
  830 WRITE  (NOUT,840) UFM,(IDHDRX(KF),KF=1,7)        
  840 FORMAT (A23,' 4130, MODULE OUTPUT2 - ILLEGAL TAPE CODE HEADER = ',
     1        7A4)        
      LINE = LINE + 2        
      GO TO 940        
  850 WRITE  (NOUT,860) UWM,P3X,P3        
  860 FORMAT (A25,' 4131, FORTRAN TAPE ID CODE -',2A4,'- DOES NOT MATCH'
     1,       ' THIRD OUTPUT2 DMAP PARAMETER -',2A4,2H-.)        
      LINE = LINE + 2        
      GO TO 520        
  870 WRITE  (NOUT,880) SFM        
  880 FORMAT (A25,' 4115, MODULE OUTPUT2 - SHORT RECORD.')        
      LINE = LINE + 2        
      GO TO 940        
  890 MM = -8        
      INPUT = ICRQ        
      GO TO 950        
  900 WRITE  (NOUT,930) SFM,KEY        
      WRITE  (NOUT,910) KEYX        
  910 FORMAT (10X,17HEXPECTED VALUE = ,I10,1H.)        
      LINE = LINE + 3        
      GO TO 940        
  920 WRITE  (NOUT,930) SFM,KEY        
  930 FORMAT (A25,' 2190, ILLEGAL VALUE FOR KEY =',I10,1H.)        
      LINE = LINE + 2        
      GO TO 940        
C        
  940 MM = -37        
  950 CALL MESAGE (MM,INPUT,SUBNAM)        
C        
 1000 RETURN        
      END        
