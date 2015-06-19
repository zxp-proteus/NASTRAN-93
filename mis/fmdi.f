      SUBROUTINE FMDI (I,J)        
C        
C     THE SUBROUTINE FETCHES FROM THE RANDOM ACCESS STORAGE DEVICE THE  
C     BLOCK OF MDI CONTAINING THE I-TH DIRECTORY, AND STORES THAT BLOCK 
C     IN THE ARRAY BUF STARTING AT LOCATION (MDI+1) AND EXTENDING TO    
C     LOCATION (MDI+BLKSIZ).  IT ALSO RETURNS IN J THE (INDEX-1) OF THE 
C     DIRECTORY IN BUF.        
C        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         MDIUP,NEWBLK        
      INTEGER         BUF,MDI,MDIPBN,MDILBN,MDIBL,BLKSIZ,DIRSIZ,        
     1                ANDF,RSHIFT,NMSBR(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /MACHIN/ MACH,IHALF,JHALF        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DITDUM(6),IODUM(8),MDI,MDIPBN,MDILBN,MDIBL,       
     1                NXTDUM(15),DITUP,MDIUP        
      COMMON /SYS   / BLKSIZ,DIRSIZ        
      COMMON /SYSTEM/ NBUFF,NOUT        
      DATA    IRD   , IWRT / 1, 2    /        
      DATA    INDSBR/ 7    /,  NMSBR /4HFMDI,4H    /        
C        
C     NDIR IS THE NUMBER OF DIRECTORIES ON ONE BLOCK OF THE MDI.        
C        
      CALL CHKOPN (NMSBR(1))        
      NDIR = BLKSIZ/DIRSIZ        
C        
C     COMPUTE THE LOGICAL BLOCK NUMBER, AND THE WORD NUMBER WITHIN      
C     BUF IN WHICH THE ITH SUBSTRUCTURE DIRECTORY IS STORED.  STORE THE 
C     BLOCK NUMBER IN IBLOCK, AND THE WORD NUMBER IN J.        
C        
      IBLOCK = I/NDIR        
      IF (I .EQ. IBLOCK*NDIR) GO TO 10        
      IBLOCK = IBLOCK + 1        
   10 J = DIRSIZ*(I-(IBLOCK-1)*NDIR-1) + MDI        
      IF (MDILBN .EQ. IBLOCK) RETURN        
      IF (MDIPBN .EQ. 0) GO TO 20        
      IF (.NOT.MDIUP) GO TO 20        
C        
C     THE MDI BLOCK CURRENTLY IN CORE HAS BEEN UPDATED.  MUST THEREFORE 
C     WRITE IT OUT BEFORE READING IN A NEW BLOCK.        
C        
      CALL SOFIO (IWRT,MDIPBN,BUF(MDI-2))        
      MDIUP = .FALSE.        
C        
C     THE DESIRED MDI BLOCK IS NOT PRESENTLY IN CORE, MUST THEREFORE    
C     FETCH IT.        
C        
   20 NEWBLK = .FALSE.        
C        
C     FIND THE PHYSICAL BLOCK NUMBER OF THE BLOCK ON WHICH THE LOGICAL  
C     BLOCK IBLOCK IS STORED.        
C        
      K = MDIBL        
      ICOUNT = 1        
   30 IF (ICOUNT .EQ. IBLOCK) GO TO 35        
      ICOUNT = ICOUNT + 1        
      CALL FNXT (K,NXTK)        
      IF (MOD(K,2) .EQ. 1) GO TO 32        
      IBL = RSHIFT(BUF(NXTK),IHALF)        
      GO TO 34        
   32 IBL = ANDF(BUF(NXTK),JHALF)        
   34 IF (IBL .EQ. 0) GO TO 60        
      K = IBL        
      GO TO 30        
   35 IF (MDIPBN .EQ. K) GO TO 500        
C        
C     READ THE DESIRED MDI BLOCK INTO CORE.        
C        
      MDIPBN = K        
      MDILBN = IBLOCK        
      IF (NEWBLK) RETURN        
      CALL SOFIO (IRD,MDIPBN,BUF(MDI-2))        
      RETURN        
C        
C     WE NEED A FREE BLOCK FOR THE MDI.        
C        
   60 CALL GETBLK (K,IBL)        
      IF (IBL .EQ. -1) GO TO 1000        
      NEWBLK = .TRUE.        
      K   = IBL        
      MIN = MDI + 1        
      MAX = MDI + BLKSIZ        
      DO 70 LL = MIN,MAX        
      BUF(LL) = 0        
   70 CONTINUE        
      CALL SOFIO (IWRT,K,BUF(MDI-2))        
      GO TO 30        
C        
C     ERROR IN UPDATING EITHER MDIPBN OR MDILBN.        
C        
  500 CALL ERRMKN (INDSBR,6)        
C        
C     ERROR MESSAGES.        
C        
 1000 WRITE  (NOUT,1001) UFM        
 1001 FORMAT (A23,' 6223, SUBROUTINE FMDI - THERE ARE NO MORE FREE ',   
     1       'BLOCKS AVAILABLE ON THE SOF.')        
      CALL SOFCLS        
      CALL MESAGE (-61,0,0)        
      RETURN        
      END        
