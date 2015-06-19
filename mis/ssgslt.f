      SUBROUTINE SSGSLT (SLT,NEWSLT,EST)        
C        
C     THIS SUBROUTINE OF THE SSG1 MODULE COPIES THE SLT TO ANOTHER      
C     FILE.  IN THE COPYING PROCESS ANY -QVOL-, -QBDY1-, -QBDY2-, OR    
C     -QVECT- EXTERNAL LOAD TYPE DATA FOUND WILL BE ALTERED SO AS TO    
C     REPLACE THEIR ELEMENT ID REFERENCES WITH THE APPROPRIATE SILS, AND
C     MISC. CONSTANTS.  THE EXTERNAL LOADS WILL BE PREPARED AS USUAL FOR
C     THESE AND OTHER LOAD CARD TYPES VIA SUBROUTINE EXTERN.        
C        
      IMPLICIT INTEGER (A-Z)        
      LOGICAL         ANY,NOGO,BGCORE,BGOPEN        
      REAL            AREA,HC1,HC2,HC3,Q0,PIOVR4,XX,YY,ZZ,        
     1                RBUF(50),RZ(1),RECPT(100)        
      INTEGER         MCB(7),ECPT(100),BUF(50),SUBR(2),TYPE(25,4)       
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /BLANK / NROWSP        
      COMMON /GPTA1 / NELEM,LAST,INCR,NE(1)        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /NAMES / RD,RDREW,WRT,WRTREW,CLSREW,CLS        
CZZ   COMMON /ZZSSA1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (KSYSTM(1),SYSBUF  ), (KSYSTM(2),OUTPT  ),        
     1                (ECPT(1)  ,RECPT(1)), (BUF(1)   ,RBUF(1)),        
     2                (Z(1)     ,RZ(1)   )        
      DATA    SUBR  / 4HSSGS,4HLT    /    , NOEOR,EOR/ 0, 1 /        
      DATA    BGPDT / 102/        
      DATA    PIOVR4/ 0.7853981634E0 /        
      DATA    CBAR  / 34 /        
      DATA    CROD  /  1 /        
      DATA    CONROD/ 10 /        
      DATA    CTUBE /  3 /        
      DATA    CTRMEM/  9 /        
      DATA    CTRIA1/  6 /        
      DATA    CTRIA2/ 17 /        
      DATA    CQDMEM/ 16 /        
      DATA    CQDMM1/ 62 /        
      DATA    CQDMM2/ 63 /        
      DATA    CQUAD4/ 64 /        
      DATA    CTRIA3/ 83 /        
      DATA    CQUAD1/ 19 /        
      DATA    CQUAD2/ 18 /        
      DATA    CTRIRG/ 36 /        
      DATA    CTRPRG/ 37 /        
      DATA    CTETRA/ 39 /        
      DATA    CWEDGE/ 40 /        
      DATA    CHEXA1/ 41 /        
      DATA    CHEXA2/ 42 /        
      DATA    CHBDY / 52 /        
      DATA    CIHEX1/ 65 /        
      DATA    CIHEX2/ 66 /        
      DATA    CIHEX3/ 67 /        
C        
      DATA    NTYPES/ 25 /        
C        
C          SLT            NEWSLT         FLAG FOR       DATA        
C          WORDS-IN       WORDS-OUT      SPEC-PROC      CORE-LOCAT      
C          ==========     ==========     ==========     ==========      
C     FORCE        
      DATA TYPE( 1,1)/ 6/,TYPE( 1,2)/ 6/,TYPE( 1,3)/ 0/,TYPE( 1,4)/ 0/  
C     MOMENT        
      DATA TYPE( 2,1)/ 6/,TYPE( 2,2)/ 6/,TYPE( 2,3)/ 0/,TYPE( 2,4)/ 0/  
C     FORCE1        
      DATA TYPE( 3,1)/ 4/,TYPE( 3,2)/ 4/,TYPE( 3,3)/ 0/,TYPE( 3,4)/ 0/  
C     MOMNT1        
      DATA TYPE( 4,1)/ 4/,TYPE( 4,2)/ 4/,TYPE( 4,3)/ 0/,TYPE( 4,4)/ 0/  
C     FORCE2        
      DATA TYPE( 5,1)/ 6/,TYPE( 5,2)/ 6/,TYPE( 5,3)/ 0/,TYPE( 5,4)/ 0/  
C     MOMNT2        
      DATA TYPE( 6,1)/ 6/,TYPE( 6,2)/ 6/,TYPE( 6,3)/ 0/,TYPE( 6,4)/ 0/  
C     SLOAD        
      DATA TYPE( 7,1)/ 2/,TYPE( 7,2)/ 2/,TYPE( 7,3)/ 0/,TYPE( 7,4)/ 0/  
C     GRAV        
      DATA TYPE( 8,1)/ 5/,TYPE( 8,2)/ 5/,TYPE( 8,3)/ 0/,TYPE( 8,4)/ 0/  
C     PLOAD        
      DATA TYPE( 9,1)/ 5/,TYPE( 9,2)/ 5/,TYPE( 9,3)/ 0/,TYPE( 9,4)/ 0/  
C     RFORCE        
      DATA TYPE(10,1)/ 6/,TYPE(10,2)/ 6/,TYPE(10,3)/ 0/,TYPE(10,4)/ 0/  
C     PRESAX        
      DATA TYPE(11,1)/ 6/,TYPE(11,2)/ 6/,TYPE(11,3)/ 0/,TYPE(11,4)/ 0/  
C     QHBDY        
      DATA TYPE(12,1)/ 7/,TYPE(12,2)/ 7/,TYPE(12,3)/ 0/,TYPE(12,4)/ 0/  
C     QVOL        
      DATA TYPE(13,1)/ 2/,TYPE(13,2)/12/,TYPE(13,3)/ 1/,TYPE(13,4)/ 0/  
C     QBDY1        
      DATA TYPE(14,1)/ 2/,TYPE(14,2)/10/,TYPE(14,3)/ 1/,TYPE(14,4)/ 0/  
C     QBDY2        
      DATA TYPE(15,1)/ 5/,TYPE(15,2)/10/,TYPE(15,3)/ 1/,TYPE(15,4)/ 0/  
C     QVECT        
      DATA TYPE(16,1)/ 5/,TYPE(16,2)/19/,TYPE(16,3)/ 1/,TYPE(16,4)/ 0/  
C     PLOAD3        
      DATA TYPE(17,1)/38/,TYPE(17,2)/38/,TYPE(17,3)/ 0/,TYPE(17,4)/ 0/  
C     PLOAD1        
      DATA TYPE(18,1)/ 7/,TYPE(18,2)/ 7/,TYPE(18,3)/ 0/,TYPE(18,4)/ 0/  
C     PLOADX        
      DATA TYPE(19,1)/ 5/,TYPE(19,2)/ 5/,TYPE(19,3)/ 0/,TYPE(19,4)/ 0/  
C     SPCFLD  (WORDS OUT IS A DUMMY VALUE-IT WILL REALLY BE 3*NROWSP)   
      DATA TYPE(20,1)/ 5/,TYPE(20,2)/ 4/,TYPE(20,3)/ 0/,TYPE(20,4)/ 0/  
C     CEMLOOP        
      DATA TYPE(21,1)/12/,TYPE(21,2)/12/,TYPE(21,3)/ 0/,TYPE(21,4)/ 0/  
C     GEMLOOP  ,BOTH INPUT AND OUTPUT ARE DUMMY.        
      DATA TYPE(22,1)/ 5/,TYPE(22,2)/ 4/,TYPE(22,3)/ 0/,TYPE(22,4)/ 0/  
C     MDIPOLE (OUTPUT VALUE IS A DUMMY)        
      DATA TYPE(23,1)/ 9/,TYPE(23,2)/ 5/,TYPE(23,3)/ 0/,TYPE(23,4)/ 0/  
C     REMFLUX    (OUTPUT VALUE IS A DUMMY)        
      DATA TYPE(24,1)/ 5/,TYPE(24,2)/ 5/,TYPE(24,3)/ 0/,TYPE(24,4)/ 0/  
C     PLOAD4        
      DATA TYPE(25,1)/11/,TYPE(25,2)/11/,TYPE(25,3)/ 0/,TYPE(25,4)/ 0/  
C        
C                     SLT                         NEWSLT        
C     CARD=TYPE       WORDS IN                    WORDS OUT        
C     =========       ========                    =========        
C        
C     QVOL=13         1 = QV                      1 = NUM-POINTS(1 TO 8)
C                     2 = ELEMENT ID              2 = ELEMENT ID        
C                                                 3 THRU 10 = 8 SILS    
C                                                 11 = COEFICIENT       
C                                                 12 = TYPE 1 = 1 DIMEN 
C                                                           2 = 2 DIMEN 
C                                                           3 = BELL-EL 
C                                                           4 = SOLID   
C        
C     QBDY1=14        1 = Q0                      1 = TYPE (1 TO 5)     
C                     2 = ELEMENT ID              2 = ELEMENT ID        
C                                                 3 THRU  6 = 4 SILS    
C                                                 7 THRU 10 = 4 COEFS.  
C        
C     QBDY2=15        1 = ELEMENT ID              1 = ELEMENT ID        
C                     2 = Q01                     2 = TYPE (1 TO 5)     
C                     3 = Q02                     3 THRU  6 = 4 SILS    
C                     4 = Q03                     7 THRU 10 = 4 COEFS.  
C                     5 = Q04        
C        
C     QVECT=16        1 = Q0                      1 THRU 4 = 4 SILS     
C                     2 = E1                      5 = ELEMENT ID        
C                     3 = E2                      6 = TYPE (1 TO 5)     
C                     4 = E3                      7 THRU 10 = 4 COEFS.  
C                     5 = ELEMENT ID              11 = E1        
C                                                 12 = E2        
C                                                 13 = E3        
C                                                 14 THRU 16 = V1 VECTOR
C                                                 17 THRU 19 = V2 VECTOR
C        
C        
C        
C     SPCFLD=20       1 = CID                     1 THRU 3*NROWSP=      
C                     2 = HCX                     TOTAL HC VALUES AT    
C                     3 = HCY                     THE GRID POINTS       
C                     4 = HCZ        
C                     5 = GRID ID OR -1        
C        
C        
C     CEMLOOP=21                                  SAME AS FOR        
C     GEMLOOP=22                                  SPCFLD        
C        
C        
C        
C     MDIPOLE=23      1  =CID                     SAME AS        
C                     2-4=LOCATION OF DIPOLE      SPCFLD        
C                     5-7=DIPOLE MOMENT        
C                     8  =MIN. DISTANCE        
C                     9  =MAX. DISTANCE        
C        
C     REMFLUX=24      SAME INPUT AS               1 THRU 3*(NO. OF      
C                     SPCFLD EXCEPT               ELEMENTS)= TOTAL      
C                     WORD 5 IS ELEMENT ID        REMANENT FLUX DENSITY 
C                                                 FOR EACH ELEMNT IN    
C                                                 ORDER ON EST        
C        
C     THE ELEMENT ID MUST REMAIN IN THE SAME LOCATION ON OUTPUT.        
C        
C        
C     SET UP CORE AND BUFFERS. (PG BUFFER IS OPEN IN SSG1)        
C        
      BGCORE=.FALSE.        
      BGOPEN=.FALSE.        
      NOGO  = .FALSE.        
      BUF1  = KORSZ(Z) - 2*SYSBUF - 2        
      BUF2  = BUF1 - SYSBUF - 2        
      BUF3  = BUF2 - SYSBUF - 2        
      CORE  = BUF3 - 1        
      IF (CORE .LT. 100) CALL MESAGE (-8,0,SUBR)        
C        
C     OPEN SLT, AND NEWSLT.  COPY HEADER RECORD ACROSS.        
C        
      CALL OPEN (*650,SLT,Z(BUF1),RDREW)        
      CALL OPEN (*660,NEWSLT,Z(BUF2),WRTREW)        
      CALL READ (*670,*10,SLT,Z,CORE,EOR,IWORDS)        
      CALL MESAGE (-8,0,SUBR)        
   10 CALL FNAME (NEWSLT,Z)        
      CALL WRITE (NEWSLT,Z,IWORDS,EOR)        
C        
C     READ TRAILER OF SLT AND GET COUNT OF LOAD SET RECORDS.        
C        
      MCB(1) = SLT        
      CALL RDTRL (MCB)        
      NRECS  = MCB(2)        
      MCB(1) = NEWSLT        
      CALL WRTTRL (MCB)        
C        
C     PROCESSING OF LOAD SET RECORDS IF ANY.        
C        
      IF (NRECS) 620,620,20        
   20 I = 1        
   21 CONTINUE        
      ANY  = .FALSE.        
      NCORE= NRECS+2        
      IFIRST = 0        
C        
C     ZERO OUT EXISTANCE FLAGS        
C        
      DO 25 K = 1,NTYPES        
      TYPE(K,4) = 0        
   25 CONTINUE        
C        
C     READ CARD TYPE AND COUNT OF CARDS        
C        
   30 CALL READ (*670,*110,SLT,BUF,2,NOEOR,IWORDS)        
   35 CONTINUE        
      ITYPE  = BUF(1)        
      ENTRYS = BUF(2)        
C        
C     CHECK FOR KNOWN TYPE        
C        
      IF (ITYPE.LE.NTYPES .AND. ITYPE.GT.0) GO TO 50        
      WRITE  (OUTPT,40) SFM,ITYPE        
   40 FORMAT (A25,' 3094, SLT LOAD TYPE',I9,' IS NOT RECOGNIZED.')      
      CALL MESAGE (-61,0,SUBR)        
C        
C     CHECK FOR SPECIAL PROCESSING.        
C        
   50 INCNT = TYPE(ITYPE,1)        
C        
C     IF TYPE IS CEMLOOP,SPCFLD,MDIPOLE, OR GEMLOOP,GO TO 800 FOR       
C     SPECIAL PROCESSING. GO TO 1000 FOR REMFLUX PROCESSING        
C        
      IF (ITYPE.GE.20 .AND. ITYPE.LE.23) GO TO 800        
      IF (ITYPE .EQ. 24) GO TO 1000        
      OUTCNT = TYPE(ITYPE,2)        
      IFLAG  = TYPE(ITYPE,3)        
C        
      IF (IFLAG) 90,90,60        
C        
C     OK BRING DATA INTO CORE.        
C        
   60 JCORE = NCORE + 1        
      TYPE(ITYPE,4) = JCORE        
      Z(JCORE  ) = ITYPE        
      Z(JCORE+1) = ENTRYS        
      JCORE = JCORE + 2        
      NCORE = JCORE + ENTRYS*OUTCNT - 1        
      IF (NCORE .GT. CORE) CALL MESAGE (-8,0,SUBR)        
      DO 70 J = JCORE,NCORE        
      Z(J) = 1        
   70 CONTINUE        
      KCORE = JCORE        
C        
C     READ IN THE LOAD ENTRIES.        
C        
      DO 80 J = JCORE,NCORE,OUTCNT        
      CALL FREAD (SLT,Z(J),INCNT,0)        
   80 CONTINUE        
      ID = 2        
      IF (ITYPE .EQ. 15) ID = 1        
      IF (ITYPE .EQ. 16) ID = 5        
      CALL SORT (0,0,OUTCNT,ID,Z(KCORE),NCORE-KCORE+1)        
      ANY = .TRUE.        
      GO TO 30        
C        
C     NO SPECIAL PROCESSING OF THIS LOAD TYPE THUS JUST COPY IT ACROSS. 
C        
   90 CALL WRITE (NEWSLT,BUF,2,NOEOR)        
      DO 100 J = 1,ENTRYS        
      CALL FREAD (SLT,BUF,INCNT,0)        
      CALL WRITE (NEWSLT,BUF,OUTCNT,NOEOR)        
  100 CONTINUE        
      GO TO 30        
C        
C     ALL DATA NOW IN CORE FOR THIS LOAD SET.        
C        
  110 IF (.NOT. ANY) GO TO 600        
C        
C     THE EST IS NOW PROCESSED FOR ELEMENT TYPES CHECKED BELOW.        
C        
      CALL GOPEN (EST,Z(BUF3),RDREW)        
C        
C     READ ELEMENT TYPE        
C        
  120 CALL READ (*500,*690,EST,ELTYPE,1,NOEOR,IWORDS)        
      IF (ELTYPE .EQ. CBAR  ) GO TO 140        
      IF (ELTYPE .EQ. CROD  ) GO TO 150        
      IF (ELTYPE .EQ. CONROD) GO TO 150        
      IF (ELTYPE .EQ. CTUBE ) GO TO 160        
      IF (ELTYPE .EQ. CTRMEM) GO TO 170        
      IF (ELTYPE .EQ. CTRIA1) GO TO 180        
      IF (ELTYPE .EQ. CTRIA2) GO TO 170        
      IF (ELTYPE .EQ. CTRIA3) GO TO 175        
      IF (ELTYPE .EQ. CQDMEM) GO TO 190        
      IF (ELTYPE .EQ. CQDMM1) GO TO 190        
      IF (ELTYPE .EQ. CQDMM2) GO TO 190        
      IF (ELTYPE .EQ. CQUAD1) GO TO 200        
      IF (ELTYPE .EQ. CQUAD2) GO TO 190        
      IF (ELTYPE .EQ. CQUAD4) GO TO 195        
      IF (ELTYPE .EQ. CTRIRG) GO TO 210        
      IF (ELTYPE .EQ. CTRPRG) GO TO 220        
      IF (ELTYPE .EQ. CTETRA) GO TO 230        
      IF (ELTYPE .EQ. CWEDGE) GO TO 240        
      IF (ELTYPE .EQ. CHEXA1) GO TO 250        
      IF (ELTYPE .EQ. CHEXA2) GO TO 250        
      IF (ELTYPE .EQ. CIHEX1) GO TO 252        
      IF (ELTYPE .EQ. CIHEX2) GO TO 254        
      IF (ELTYPE .EQ. CIHEX3) GO TO 256        
      IF (ELTYPE .EQ. CHBDY ) GO TO 360        
  130 CALL FWDREC (*700,EST)        
      GO TO 120        
C        
C     BAR        
C        
  140 ESTWDS = 42        
      GRID1  = 2        
      POINTS = 2        
      IAREA  = 17        
      ITYPE  = 1        
      GO TO 260        
C        
C     ROD AND CONROD        
C        
  150 ESTWDS = 17        
      GRID1  = 2        
      POINTS = 2        
      IAREA  = 5        
      ITYPE  = 1        
      GO TO 260        
C        
C     TUBE        
C        
  160 ESTWDS = 16        
      GRID1  = 2        
      POINTS = 2        
      IAREA  = 5        
      ITYPE  = 1        
      GO TO 260        
C        
C     TRMEM AND TRIA2        
C        
  170 ESTWDS = 21        
      GRID1  = 2        
      POINTS = 3        
      IAREA  = 7        
      ITYPE  = 2        
      GO TO 260        
C        
C     TRIA3        
C        
  175 ESTWDS = 39        
      GRID1  = 2        
      POINTS = 3        
      IAREA  = 7        
      ITYPE  = 2        
      GO TO 260        
C        
C     TRIA1        
C        
  180 ESTWDS = 27        
      GRID1  = 2        
      POINTS = 3        
      IAREA  = 7        
      ITYPE  = 2        
      GO TO 260        
C        
C     QDMEM AND QUAD2        
C        
  190 ESTWDS = 26        
      GRID1  = 2        
      POINTS = 4        
      IAREA  = 8        
      ITYPE  = 2        
      GO TO 260        
C        
C     QUAD4        
C        
  195 ESTWDS = 45        
      GRID1  = 2        
      POINTS = 4        
      IAREA  = 8        
      ITYPE  = 2        
      GO TO 260        
C        
C     QUAD1        
C        
  200 ESTWDS = 32        
      GRID1  = 2        
      POINTS = 4        
      IAREA  = 8        
      ITYPE  = 2        
      GO TO 260        
C        
C     TRIRG        
C        
  210 ESTWDS = 19        
      GRID1  = 2        
      POINTS = 3        
      IAREA  = 0        
      ITYPE  = 3        
      GO TO 260        
C        
C     TRAPRG        
C        
  220 ESTWDS = 24        
      GRID1  = 2        
      POINTS = 4        
      IAREA  = 0        
      ITYPE  = 3        
      GO TO 260        
C        
C     TETRA        
C        
  230 ESTWDS = 23        
      GRID1  = 3        
      POINTS = 4        
      IAREA  = 0        
      ITYPE  = 4        
      GO TO 260        
C        
C     WEDGE        
C        
  240 ESTWDS = 33        
      GRID1  = 3        
      POINTS = 6        
      IAREA  = 0        
      ITYPE  = 4        
      GO TO 260        
C        
C     HEXA1 AND HEXA2        
C        
  250 ESTWDS = 43        
      GRID1  = 3        
      POINTS = 8        
      IAREA  = 0        
      ITYPE  = 4        
      GO TO 260        
C        
C     IHEX1        
C        
  252 ESTWDS = 55        
      GRID1  = 3        
      POINTS = 8        
      IAREA  = 0        
      ITYPE  = 4        
      GO TO 260        
C        
C     IHEX2 AND IHEX3 ARE NOT IMPLEMENTED DUE TO        
C        1. ECPT ARRAY TOO SMALL IN THIS ROUTINE        
C        2. QVOL ROUTINE CAN NOT HANDLE SOLID ELEMENTS HAVING MORE THAN 
C           8 GRID POINTS        
C        
C     IHEX2        
C        
  254 ESTWDS = 127        
      GRID1  = 3        
      POINTS = 20        
      IAREA  = 0        
      ITYPE  = 4        
C     GO TO 260        
      GO TO 130        
C        
C     IHEX3        
C        
  256 ESTWDS = 199        
      GRID1  = 3        
      POINTS = 32        
      IAREA  = 0        
      ITYPE  = 4        
C     GO TO 260        
      GO TO 130        
C        
C     MISC. ELEMENTS OF EST FILE.  DO QVOL REFERENCES.        
C        
  260 IF (TYPE(13,4) .EQ. 0) GO TO 130        
      IDQVOL = TYPE(13,4) + 3        
      ENTRYS = Z(IDQVOL-2)        
      IWORDS = 12        
      J1 = IDQVOL        
      J2 = J1 + ENTRYS*IWORDS        
      IDPTR = 2        
      ASSIGN 280 TO IRETRN        
  270 CALL READ (*700,*120,EST,ECPT,ESTWDS,NOEOR,IFLAG)        
C        
C     LOOK FOR THIS ELEMENT ID AMONG QVOL DATA.        
C        
      CALL BISLOC (*270,ECPT(1),Z(IDQVOL),12,ENTRYS,JPOINT)        
C        
C     MATCH FOUND ON ID. COMPUTE ZERO POINTER TO ZERO WORD OF QVOL ENTRY
C        
      INDEX = IDQVOL + JPOINT - 3        
      GO TO 710        
C        
C     IF COEFICIENT IS NOT AN INTEGER 1 ENTRY HAS BEEN ALTERED BEFORE.  
C        
  280 DO 350 INDEX = K1,K2,IWORDS        
      IF (Z(INDEX+11) .EQ. 1) GO TO 300        
      WRITE  (OUTPT,290) UWM,ELTYPE,ECPT(1),Z(I+2)        
  290 FORMAT (A25,' 3095, ELEMENT TYPE',I9,' WITH ID =',I9,        
     1       ', REFERENCED BY A QVOL CARD IN LOAD SET',I9,1H,, /5X,     
     2       'IS NOT BEING USED FOR INTERNAL HEAT GENERATION IN THIS ', 
     3       'LOAD SET BECAUSE ANOTHER ELEMENT TYPE WITH THE SAME ID',  
     4       /5X,'HAS ALREADY BEEN USED.')        
      GO TO 350        
C        
C     ALTER ENTRY IN PLACE (NOTE THE CONVERSION TABLE ABOVE)        
C        
C     GET AREA FACTOR FROM ECPT AND REVISE ENTRY.        
C        
  300 IF (IAREA .EQ. 0) GO TO 310        
      AREA = RECPT(IAREA)        
      IF (ELTYPE.EQ.CTUBE) AREA = PIOVR4*(AREA**2-(AREA-2.*RECPT(6))**2)
      GO TO 320        
  310 AREA = 1.0        
  320 I1 = INDEX + 3        
      I2 = INDEX + 10        
      DO 330 J = I1,I2        
      Z(J) = 0        
  330 CONTINUE        
      I2 = I1 + POINTS - 1        
      IGRID = GRID1        
      DO 340 J = I1,I2        
      Z(J)  = ECPT(IGRID)        
      IGRID = IGRID+1        
  340 CONTINUE        
      RZ(INDEX+11) = RZ(INDEX+1)*AREA        
      Z(INDEX + 1) = POINTS        
      Z(INDEX +12) = ITYPE        
  350 CONTINUE        
      GO TO 270        
C        
C     HBDY ELEMENTS OF EST FILE.  DO QBDY1, QBDY2, AND QVECT REFERENCES.
C        
C        
C     BUF(3) IS SET TO 0 AS A FLAG TO TELL IF HBDY HAS BEEN CALLED FOR  
C     THIS ELEMENT.        
C        
  360 IF (TYPE(14,4)+TYPE(15,4)+TYPE(16,4) .EQ. 0) GO TO 130        
      IDBDY1 = TYPE(14,4) + 3        
      IDBDY2 = TYPE(15,4) + 2        
      IDQVEC = TYPE(16,4) + 6        
      QBDY1S = Z(IDBDY1-2)        
      QBDY2S = Z(IDBDY2-1)        
      QVECTS = Z(IDQVEC-5)        
      ESTWDS = 53        
C        
C     READ AN HBDY ELEMENT ECPT FROM THE EST.        
C        
  370 CALL READ (*700,*120,EST,ECPT,ESTWDS,NOEOR,IFLAG)        
C        
C     LOOK FOR ID AMONG QBDY1 DATA        
C        
      IF (TYPE(14,4) .EQ. 0) GO TO 410        
      IWORDS = 10        
      J1 = IDBDY1        
      J2 = J1 + QBDY1S*IWORDS        
      IDPTR = 2        
      ASSIGN 380 TO IRETRN        
      CALL BISLOC (*410,ECPT(1),Z(IDBDY1),10,QBDY1S,JPOINT)        
C        
C     MATCH FOUND.  CHECK FOR PREVIOUS REFERENCE.        
C        
      INDEX = IDBDY1 + JPOINT - 3        
      GO TO 710        
  380 DO 400 INDEX = K1,K2,IWORDS        
      IF (Z(INDEX+10) .EQ. 1) GO TO 390        
      WRITE  (OUTPT,382) UFM,ECPT(1)        
  382 FORMAT (A23,' 2362, CHBDY CARDS WITH DUPLICATE IDS FOUND IN EST,',
     1       ' CHBDY ID NUMBER =',I9)        
      NOGO = .TRUE.        
      GO TO 650        
C        
C     ALTER ENTRY FOR OUTPUT.  GET AREA FACTORS FOR HBDY ELEMENT.       
C        
  390 CALL HBDY (ECPT,ECPT,2,RBUF,BUF)        
      Z(INDEX +3) = BUF(3)        
      Z(INDEX +4) = BUF(4)        
      Z(INDEX +5) = BUF(5)        
      Z(INDEX +6) = BUF(6)        
      RZ(INDEX+7) = RBUF(7)*RZ(INDEX+1)        
      RZ(INDEX+8) = RBUF(8)*RZ(INDEX+1)        
      RZ(INDEX+9) = RBUF(9)*RZ(INDEX+1)        
      RZ(INDEX+10)= RBUF(10)*RZ(INDEX+1)        
      Z(INDEX +1) = ECPT(2)        
  400 CONTINUE        
C        
C     LOOK FOR ID AMONG QBDY2 DATA.        
C        
  410 IF (TYPE(15,4) .EQ. 0) GO TO 450        
      IWORDS = 10        
      J1 = IDBDY2        
      J2 = J1 + QBDY2S*IWORDS        
      IDPTR = 1        
      ASSIGN 420 TO IRETRN        
      CALL BISLOC (*450,ECPT(1),Z(IDBDY2),10,QBDY2S,JPOINT)        
C        
C     MATCH FOUND.  CHECK FOR PREVIOUS REFERENCE.        
C        
      INDEX = IDBDY2 + JPOINT - 2        
      GO TO 710        
  420 DO 440 INDEX = K1,K2,IWORDS        
      IF (Z(INDEX+10) .EQ. 1) GO TO 430        
      WRITE (OUTPT,382) UFM,ECPT(1)        
      NOGO = .TRUE.        
      GO TO 650        
C        
C     ALTER ENTRY FOR OUTPUT.  GET AREA FACTORS FOR HBDY ELEMENT.       
C        
  430 CALL HBDY (ECPT,ECPT,2,RBUF,BUF)        
      RZ(INDEX+7) = RBUF(7)*RZ(INDEX+2)        
      RZ(INDEX+8) = RBUF(8)*RZ(INDEX+3)        
      RZ(INDEX+9) = RBUF(9)*RZ(INDEX+4)        
      RZ(INDEX+10)= RBUF(10)*RZ(INDEX+5)        
      Z(INDEX +3) = BUF(3)        
      Z(INDEX +4) = BUF(4)        
      Z(INDEX +5) = BUF(5)        
      Z(INDEX +6) = BUF(6)        
      Z(INDEX +2) = ECPT(2)        
  440 CONTINUE        
C        
C     LOOK FOR ID AMONG QVECT DATA        
C        
  450 IF (TYPE(16,4) .EQ. 0) GO TO 490        
      IWORDS = 19        
      J1 = IDQVEC        
      J2 = J1 + QVECTS*IWORDS        
      IDPTR = 5        
      ASSIGN 460 TO IRETRN        
      CALL BISLOC (*490,ECPT(1),Z(IDQVEC),19,QVECTS,JPOINT)        
C        
C     MATCH FOUND.  CHECK FOR PREVIOUS REFERENCE.        
C        
      INDEX = IDQVEC + JPOINT - 6        
      GO TO 710        
  460 DO 480 INDEX = K1,K2,IWORDS        
      IF (Z(INDEX+19) .EQ. 1) GO TO 470        
      WRITE (OUTPT,382) UFM,ECPT(1)        
      NOGO = .TRUE.        
      GO TO 650        
C        
C     ALTER ENTRY FOR OUTPUT.  GET AREA FACTORS FOR HBDY ELEMENT.       
C        
  470 CALL HBDY (ECPT,ECPT,3,RBUF,BUF)        
      RZ(INDEX+11) = RZ(INDEX+2)        
      RZ(INDEX+12) = RZ(INDEX+3)        
      RZ(INDEX+13) = RZ(INDEX+4)        
      RZ(INDEX+14) = RBUF(11)        
      RZ(INDEX+15) = RBUF(12)        
      RZ(INDEX+16) = RBUF(13)        
      RZ(INDEX+17) = RBUF(14)        
      RZ(INDEX+18) = RBUF(15)        
      RZ(INDEX+19) = RBUF(16)        
      Q0           = RZ(INDEX+1)        
      Z(INDEX + 1) = BUF(3)        
      Z(INDEX + 2) = BUF(4)        
      Z(INDEX + 3) = BUF(5)        
      Z(INDEX + 4) = BUF(6)        
      Z(INDEX + 6) = ECPT(2)        
      RZ(INDEX+ 7) = RBUF(7)*Q0        
      RZ(INDEX+ 8) = RBUF(8)*Q0        
      RZ(INDEX+ 9) = RBUF(9)*Q0        
      RZ(INDEX+10) = RBUF(10)*Q0        
  480 CONTINUE        
  490 GO TO 370        
C        
C     EST HAS BEEN PASSED FOR ALL ELEMENTS.  NOW OUTPUT DATA TO NEWSLT. 
C        
  500 CALL CLOSE (EST,CLSREW)        
      DO 590 J = 13,16        
      JCORE = TYPE(J,4)        
      IF (JCORE) 590,590,510        
  510 NWORDS = Z(JCORE+1)*TYPE(J,2) + 2        
C        
C     INSURE THAT ALL ENTRYS WERE MODIFIED.        
C     CHECK WORD 7 FOR NO INTEGER 1 IN TYPES 14,15, AND 16.        
C     CHECK WORD 11 FOR NO INTEGER 1 IN TYPE 13.        
C        
      K = 8        
      IF (J .EQ. 13) K = 12        
      I1 = JCORE + K        
      I2 = I1 + NWORDS - 3        
      OUTCNT = TYPE(J,2)        
      DO 580 L = I1,I2,OUTCNT        
      IF (Z(L) .NE. 1) GO TO 580        
      K = J - 12        
      GO TO (520,530,540,550), K        
  520 ID = L - 9        
      GO TO 560        
  530 ID = L - 5        
      GO TO 560        
  540 ID = L - 6        
      GO TO 560        
  550 ID = L - 2        
      GO TO 560        
  560 WRITE  (OUTPT,570) UFM,Z(ID)        
  570 FORMAT (A23,' 3096, ELEMENT ID =',I9,' AS REFERENCED ON A QVOL, ',
     1       'QBDY1, QBDY2, OR QVECT LOAD CARD,', /5X,'COULD NOT BE ',  
     2       'FOUND AMONG ACCEPTABLE ELEMENTS FOR THAT LOAD TYPE.')     
      NOGO = .TRUE.        
  580 CONTINUE        
      CALL WRITE (NEWSLT,Z(JCORE),NWORDS,NOEOR)        
  590 CONTINUE        
C        
C     COMPLETE THIS LOAD SET RECORD ON -NEWSLT-.        
C        
  600 CALL WRITE (NEWSLT,0,0,EOR)        
      I = I+1        
      IF (I .LE. NRECS) GO TO 21        
C        
C     COPY BALANCE OF DATA ON -SLT- TO -NEWSLT- WHATEVER IT BE.        
C        
  620 CALL READ (*640,*630,SLT,Z,CORE,NOEOR,IWORDS)        
      CALL WRITE (NEWSLT,Z,CORE,NOEOR)        
      GO TO 620        
  630 CALL WRITE (NEWSLT,Z,IWORDS,EOR)        
      GO TO 620        
C        
C     NEWSLT IS COMPLETE.        
C        
  640 CALL CLOSE (SLT,CLSREW)        
      CALL CLOSE (NEWSLT,CLSREW)        
  650 IF (NOGO) CALL MESAGE (-61,0,SUBR)        
      RETURN        
C        
C     FATAL FILE ERRORS        
C        
  660 CALL MESAGE (-1,NEWSLT,SUBR)        
  670 CALL MESAGE (-2,SLT   ,SUBR)        
  690 CALL MESAGE (-3,EST   ,SUBR)        
  700 CALL MESAGE (-2,EST   ,SUBR)        
  701 CALL MESAGE (-2,BGPDT ,SUBR)        
      RETURN        
C        
C     INTERNAL ROUTINE TO FIND THE START AND END OF ENTRYS HAVING THE   
C     SAME ID IN A GIVEN CARD-TYPE SET.        
C        
C        
C     BACK UP TO FIRST ENTRY OF THIS ID.        
C        
  710 JINDEX = INDEX + IDPTR - IWORDS        
  720 IF (JINDEX .LT. J1) GO TO 730        
      IF (Z(JINDEX) .NE. ECPT(1)) GO TO 730        
      JINDEX = JINDEX - IWORDS        
      GO TO 720        
  730 K1 = JINDEX + IWORDS - IDPTR        
C        
C     FIND LAST ENTRY OF THIS ID.        
C        
      JINDEX = K1 + IWORDS + IDPTR        
  740 IF (JINDEX .GE. J2) GO TO 750        
      IF (Z(JINDEX) .NE. ECPT(1)) GO TO 750        
      JINDEX = JINDEX + IWORDS        
      GO TO 740        
  750 K2 = JINDEX - IWORDS - IDPTR        
      GO TO IRETRN, (280,380,420,460)        
C        
C     SPECIAL PROCESSING FOR SPCFLD,CEMLOOP,MDIPOLE, AND GEMLOOP. SET UP
C     A VECTOR FOR ALL BUT SPCFLD CARDS, COMPUTE FIELD AT EACH POINT    
C     IN BGPDT. WHEN FINISHED, ALL THE E AND M CARD TYPES WILL BE       
C     ACCUMULATED INTO ONE SPCFLD-LIKE CARD WITH FIELD VALUSS AT EACH   
C     POINT        
C        
  800 IF (IFIRST .EQ. 1) GO TO 811        
      IFIRST = 1        
      JCORE1 = NCORE+1        
      JCOREN = NCORE+3*NROWSP        
      IF (JCOREN.GT.CORE) CALL MESAGE (-8,0,SUBR)        
C        
      DO 810 J1 = JCORE1,JCOREN        
  810 RZ(J1) = 0.        
C        
C     ALL E AND M CARDS WILL BE COMBINED INTO ONE LOGICAL CARD OF       
C     TYPE=20, 3*NROWSP VALUES HCX,HCY,HCZ AT EACH POINT IN THE MODEL.  
C     FOR CEMLOOP AND GEMLOOP, WE MUST PICK UP BGPDT FOREACH POINT AND  
C     COMPUTE FIELD FOR EACH LOOP        
C *** 10/1/80 WE MUST ALSO FIND HC AT INTEGRATION POINTS AND CENTROIDS. 
C     SO ALSO COPY SLT INFO TO NEWSLT FOR USE IN EANDM        
C        
C        
C     1ST OCCURRENCE OF A CARD TYPE. CHECK ON TYPE        
C        
  811 JTYPE = ITYPE-19        
      GO TO (812,840,840,840), JTYPE        
C        
C     SPCFLD        
C        
  812 BUF(1) = 20        
      BUF(2) = 1        
      CALL WRITE (NEWSLT,BUF,2,0)        
      DO 830 J1 = 1,ENTRYS        
C        
C     READ ONE SPCFLD CARD        
C        
      CALL FREAD (SLT,BUF,5,0)        
      IF (BUF(5).NE.-1) GO TO 825        
C        
C     BUF(1)=CID WHICH IS ASSUMED TO BE 0 FOR NOW        
C        
C     ALL GRIDS GET HC        
C        
      DO 820 J2 = JCORE1,JCOREN,3        
      RZ(J2  ) = RZ(J2  )+RBUF(2)        
      RZ(J2+1) = RZ(J2+1)+RBUF(3)        
      RZ(J2+2) = RZ(J2+2)+RBUF(4)        
  820 CONTINUE        
      GO TO 830        
C        
  825 ISUB = NCORE+3*BUF(5)-2        
      RZ(ISUB  ) = RZ(ISUB  )+RBUF(2)        
      RZ(ISUB+1) = RZ(ISUB+1)+RBUF(3)        
      RZ(ISUB+2) = RZ(ISUB+2)+RBUF(4)        
  830 CONTINUE        
C        
C     DONE WITH ALL SPCFLD CARDS IN THIS LOAD SET. CHECK FOR OTHER CARD 
C     TYPES IN THIS LOAD SET        
C        
      CALL WRITE (NEWSLT,RZ(JCORE1),3*NROWSP,0)        
      GO TO 910        
C        
C     CEMLOOP,GEMLOOP, OR MDIPOLE        
C     CHECK FOR ENOUGH CORE TO READ IN BGPDT. IF NOT, READ ONE POINT AT 
C     A TIME        
C        
  840 IF (BGOPEN) GO TO 850        
C        
C     IF MODCOM(9) IS NOT SET TO NONZERO, THEN WE WILL NOT COMPUTE HCFLD
C     AT GRID POINTS FOR COILS, ETC.(ONLY SPCFLD) SINCE IT TAKES TIME   
C     AND IS NOT NEEDED IN ANY SUBSEQUENT COMPUTATION. (ONLY SPCFLD INFO
C     IS NEEDED LATER. ALL OTHER HC INFO IS COMPUTED LATER) IF MODCOM(9)
C     IS SET TO NONZERO, HCFLD IS COMPUTED AT THE POINTS FOR ALL LOAD   
C     TYPES AND CAN BE PRINTED FOR INFORMATIONAL PURPOSES IF DESIRED.   
C        
      IF (KSYSTM(65) .EQ. 0) GO TO 850        
      CALL GOPEN (BGPDT,Z(BUF3),0)        
      MCB(1) = BGPDT        
      CALL RDTRL (MCB)        
      NPTS   = MCB(2)        
      BGCORE = .TRUE.        
      BGOPEN = .TRUE.        
      IF (JCOREN+4*NPTS.GT.CORE) BGCORE=.FALSE.        
      NEXT = JCOREN+4*NPTS        
      IF (.NOT.BGCORE) NEXT=JCOREN        
      IF (BGCORE) CALL FREAD (BGPDT,Z(JCOREN+1),4*NPTS,0)        
  850 CONTINUE        
      CALL WRITE (NEWSLT,BUF,2,0)        
C        
      DO 900 J1 = 1,ENTRYS        
C        
C     READ CEMLOOP, GEMLOOP, OR MDIPOLE ENTRY        
C        
      IWORDS = 12        
      IF (ITYPE .EQ. 22) IWORDS = 48        
      IF (ITYPE .EQ. 23) IWORDS = 9        
      CALL FREAD (SLT,BUF,IWORDS,0)        
      CALL WRITE (NEWSLT,BUF,IWORDS,0)        
      IF (KSYSTM(65) .EQ. 0) GO TO 900        
C        
C        
C     DO THIS LOOP FOR ALL POINTS        
C        
      DO 890 KK = 1,NPTS        
      IF (BGCORE) GO TO 880        
      CALL FREAD (BGPDT,BUF,4,0)        
      IF (BUF(1) .EQ. -1) GO TO 890        
      XX = RBUF(2)        
      YY = RBUF(3)        
      ZZ = RBUF(4)        
      GO TO 885        
  880 JCOR = JCOREN+4*KK        
      IF (Z(JCOR-3) .EQ. -1) GO TO 890        
      XX = RZ(JCOR-2)        
      YY = RZ(JCOR-1)        
      ZZ = RZ(JCOR )        
  885 IF (ITYPE .EQ. 21) GO TO 886        
      IF (ITYPE .EQ. 23) GO TO 888        
      CALL GELOOP (RBUF,BUF,XX,YY,ZZ,HC1,HC2,HC3)        
      GO TO 887        
  886 CALL AXLOOP (RBUF,BUF,XX,YY,ZZ,HC1,HC2,HC3)        
      GO TO 887        
  888 CALL DIPOLE (RBUF,BUF,XX,YY,ZZ,HC1,HC2,HC3)        
  887 ISUB = NCORE+3*KK-2        
      RZ(ISUB  ) = RZ(ISUB  )+HC1        
      RZ(ISUB+1) = RZ(ISUB+1)+HC2        
      RZ(ISUB+2) = RZ(ISUB+2)+HC3        
C        
C     GO BACK FOR ANOTHER POINT        
C        
  890 CONTINUE        
      IF (BGCORE) GO TO 900        
      CALL REWIND (BGPDT)        
      CALL FWDREC (*701,BGPDT)        
C        
C     GET ANOTHER LOOP OR DIPOLE        
C        
  900 CONTINUE        
C        
C     CHECK IF NEXT CARD TYPE IS 21 ,22, OR 23. CARD TYPES ON SLT ARE   
C     IN INCREASING CARD TYPE). IF SO, STAY HERE. OTHERWISE, WRITE OUT  
C     ALL CARD TYPES GENERATING AN SPCFLD-TYPE CARD AND GOING ONTO      
C     HCFLDS MUST HAVE CONSECUTIVE TYPE NUMBERS FOR THIS SPECIAL        
C     PROCESSING THE GENERATED SPCFLD AND GO BACK TO NORMAL PROCESSING  
C        
  910 CALL READ (*670,*920,SLT,BUF,2,NOEOR,IWORDS)        
      ITYPE  = BUF(1)        
      ENTRYS = BUF(2)        
      IF (BUF(1).GE.20 .AND. BUF(1).LE.23) GO TO 811        
      IEOR = 0        
      GO TO 930        
  920 IEOR = 1        
  930 BUF(1) =-20        
      BUF(2) = 1        
      CALL WRITE (NEWSLT,BUF,2,0)        
      CALL WRITE (NEWSLT,RZ(JCORE1),3*NROWSP,0)        
      IF (BGOPEN) CALL CLOSE (BGPDT,1)        
      IF (IEOR .EQ. 1) GO TO 110        
      GO TO 35        
C        
C     REMFLUX PROCESSING. CREATE A VECTOR OF ORDER 3N,N=NUMBER OF       
C     ELEMENTS IN MODEL,N IS 1ST TRAILER WORD OF EST. THE VECTOR        
C     CONTAINS TOTAL BX,BY,BZ FROM ALL REMFLUX CARDS FOR EACH ELEMENT   
C     IN THE ORDER OF ELEMENTS ON EST        
C        
 1000 CALL GOPEN (EST,Z(BUF3),0)        
      MCB(1) = EST        
      CALL RDTRL (MCB)        
      NEL    = MCB(2)        
      JCORE1 = NCORE+1        
      JCOREN = NCORE+3*NEL        
      JCOREX = JCOREN+5*ENTRYS        
      IF (JCOREX .GT. CORE) CALL MESAGE (-8,0,SUBR)        
C        
      NELS = 0        
      DO 1010 J1 = JCORE1,JCOREN        
 1010 RZ(J1) = 0.        
C        
C     READ ALL REMFLUX CARDS        
C        
      CALL FREAD (SLT,RZ(JCOREN+1),5*ENTRYS,0)        
C        
 1020 CALL READ (*1050,*690,EST,ELTYPE,1,0,IWORDS)        
      IDX = (ELTYPE-1)*INCR        
      ESTWDS = NE(IDX+12)        
 1025 CALL READ (*700,*1020,EST,ELID,1,0,IWORDS)        
      NELS = NELS+1        
      ISUB = NCORE+3*NELS-2        
      CALL FREAD (EST,DUM,-ESTWDS+1,0)        
C        
C     CHECK FOR THIS ELID AMONG THE REMFLUX CARDS        
C        
      DO 1040 J1 = 1,ENTRYS        
      ISUB1 = JCOREN+5*J1        
      IF (Z(ISUB1) .EQ.   -1) GO TO 1030        
      IF (ELID .NE. Z(ISUB1)) GO TO 1040        
C        
C     MATCH-STORE THIS PERM MAG        
C        
 1030 RZ(ISUB  ) = RZ(ISUB  )+RZ(ISUB1-3)        
      RZ(ISUB+1) = RZ(ISUB+1)+RZ(ISUB1-2)        
      RZ(ISUB+2) = RZ(ISUB+2)+RZ(ISUB1-1)        
 1040 CONTINUE        
C        
C     READ ANOTHER ELEMENT ID        
C        
      GO TO 1025        
C        
C     EST EXHAUSTED        
C        
 1050 CALL CLOSE (EST,1)        
      BUF(1) = 24        
      BUF(2) = 1        
      CALL WRITE (NEWSLT,BUF,2,0)        
      CALL WRITE (NEWSLT,RZ(JCORE1),3*NEL,0)        
      GO TO 30        
      END        
