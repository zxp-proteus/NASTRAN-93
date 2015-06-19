      SUBROUTINE TRAIL        
C        
C     MODULE TO INTERROGATE OR ALTER ANY VALUE OF A 6 WORD MATRIX       
C     OR TABLE TRAILER        
C        
C     DMAP CALL        
C        
C        TRAILER  DB / /*OPT*/WORD/S,N,VALUE $        
C        
C     INPUT DATA BLOCKS        
C        
C        DB - DATA BLOCK FOR WHICH TRAILER IS TO BE ALTERED OR READ     
C        
C     PARAMETERS        
C        
C        OPT   - BCD,INPUT.        
C                RETURN - VALUE OF SPECIFIED TRAILER WORD IS TO        
C                         BE RETURNED        
C                STORE  - VALUE OF SPECIFIED TRAILER WORD IS TO        
C                         CHANGED        
C        WORD  - INTEGER,INPUT. DESIRED WORD OF TRAILER        
C        VALUE - INTEGER,INPUT OR OUTPUT. LOCATION WHERE VALUED WILL    
C                RETURNED OR FROM WHICH REPLACEMENT VALUE WILL BE       
C                TAKEN.  RETURNED NEGATIVE IF DB IS PURGED.        
C        
C     FOR MATRIX DATA BLOCKS, THE TRAILER POSITIONS ARE AS FOLLOWS      
C        
C        WORD 1 - NUMBER OF COLUMNS        
C        WORD 2 - MUNBER OF ROWS        
C        WORD 3 - MATRIX FORM        
C        WORD 4 - TYPE OF ELEMENTS        
C        WORD 5 - MAXIMUM NUMBER OF NON-ZERO WORDS IN ANY ONE COLUMN    
C        WORD 6 - MATRIX DENSITY * 100        
C        
      EXTERNAL        LSHIFT  ,ANDF    ,ORF        
      INTEGER         DB      ,OPT     ,WORD     ,VALUE    ,STORE(2) ,  
     1                MCB(7)  ,FIAT    ,FIST     ,RETURN(2),MODNAM(2),  
     2                ORF     ,ANDF        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /XFIAT / FIAT(2)        
      COMMON /XFIST / FIST(2)        
      COMMON /BLANK / OPT(2)  ,WORD    ,VALUE        
      COMMON /SYSTEM/ IBUF    ,NOUT    ,DUM21(21),ICFIAT        
      DATA    STORE / 4HSTOR  ,4HE    /        
      DATA    RETURN/ 4HRETU  ,4HRN   /        
      DATA    MODNAM/ 4HTRAI  ,4HLER  /        
C        
C     GET TRAILER        
C        
      DB = 101        
      MCB(1) = DB        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LE. 0) GO TO 70        
C        
C     TEST ILLEGAL PARAMETER VALUES AND BRANCH ON OPT        
C        
      IF (WORD.LT.1 .OR. WORD.GT.6) GO TO 100        
      IF (OPT(1).EQ.RETURN(1) .AND. OPT(2).EQ.RETURN(2)) GO TO 10       
      IF (OPT(1).EQ.STORE(1)  .AND. OPT(2).EQ.STORE(2) ) GO TO 20       
      GO TO 300        
C        
C     RETURN OPTION        
C        
   10 VALUE = MCB(WORD+1)        
      RETURN        
C        
C     STORE OPTION        
C        
C     SEARCH FIST FOR THE FILE        
C        
   20 N = FIST(2)*2 + 1        
      DO 30 I = 3,N,2        
      IF (FIST(I) .NE. DB) GO TO 30        
      INDEX = FIST(I+1) + 1        
      GO TO 40        
   30 CONTINUE        
      GO TO 70        
C        
C     PACK THE TRAILER INFORMATION INTO THE REQUESTED WORD.        
C     MAKE SURE THE NUMBER IS POSITIVE AND .LE. 16 BITS IF ICFIAT=8     
C        
   40 IF (VALUE  .LT.  0) GO TO 200        
      IF (ICFIAT .EQ. 11) GO TO 60        
      IF (VALUE .GT. 65535) GO TO 200        
      IW = (WORD+1)/2 + 2        
      IF (WORD .EQ. (WORD/2*2)) GO TO 50        
C        
C     WORD IS ODD        
C        
      MASK = 65535        
      FIAT(INDEX+IW) = ORF(ANDF(FIAT(INDEX+IW),MASK),LSHIFT(VALUE,16))  
      RETURN        
C        
C     WORD IS EVEN        
C        
   50 MASK = LSHIFT(65535,16)        
      FIAT(INDEX+IW) = ORF(ANDF(FIAT(INDEX+IW),MASK),VALUE)        
      RETURN        
C        
C     ICFIAT = 11, TRAILER WORDS ARE NOT PACKED        
C        
   60 IW = 2        
      IF (WORD .GE. 4) IW = 4        
      FIAT(INDEX+IW+WORD) = VALUE        
      RETURN        
C        
C     PURGED DATA BLOCK        
C        
   70 VALUE = -1        
      RETURN        
C        
C     ERROR CONDITIONS        
C        
  100 WRITE  (NOUT,110) UFM,WORD        
  110 FORMAT (A23,' 2202.  PARAMETER, WORD, HAS ILLEGAL VALUE OF',I9)   
      GO TO 500        
C        
  200 WRITE  (6,210) UFM,VALUE        
  210 FORMAT (A23,' 2202.  PARAMETER, VALUE, HAS ILLEGAL VALUE OF',I9)  
      GO TO 500        
C        
  300 WRITE  (NOUT,310) UFM,OPT        
  310 FORMAT (A23,' 2202.  PARAMETER, OPT, HAS ILLEGAL VALUE OF ',2A4)  
C        
  500 CALL MESAGE (-37,0,MODNAM)        
      RETURN        
      END        
