      SUBROUTINE MTRXO (FILE,NAME,ITEM,DUMBUF,ITEST)        
C        
C     COPIES MATRIX ITEM OF SUBSTRUCTURE NAME FROM THE NASTRAN FILE     
C     TO THE SOF        
C     ITEST VALUES RETURNED ARE        
C        1 - ITEM ALREADY EXISTS ON THE SOF        
C        2 - THE ITEM WAS PESUDO WRITTEN        
C        3 - NORMAL RETURN        
C        4 - NAME DOES NOT EXIST        
C        5 - ITEM IS NOT ONE OF THE ALLOWABLE MATIX ITEMS        
C        6 - NASTRAN FILE HAS BEEN PURGED        
C        
      EXTERNAL        LSHIFT,ORF,ANDF        
      LOGICAL         MDIUP        
      INTEGER         NMSBR(2),BUF(1),FILE,TRAIL(7),OLDBUF,NAME(2),     
     1                BLKSIZ,FIRST,ORF,ANDF        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /MACHIN/ MACH,IHALF,JHALF        
      COMMON /SOF   / DITDUM(6),IO,IOPBN,IOLBN,IOMODE,IOPTR,IOSIND,     
     1                IOITCD,IOBLK,SOFDUM(20),MDIUP        
      COMMON /SYSTEM/ NBUF,NOUT        
      COMMON /SYS   / BLKSIZ        
CZZ   COMMON /XNSTRN/ NSTRN        
      COMMON /ZZZZZZ/ NSTRN        
CZZ   COMMON /SOFPTR/ BUF        
      EQUIVALENCE     (BUF(1),NSTRN)        
      DATA    NMSBR / 4HMTRX, 4HO   /        
      DATA    IWRT  / 2 /        
      DATA    IFETCH/ -2/        
      DATA    IDLE  / 0 /        
C        
C     CHECK IF ITEM IS ONE OF THE FOLLOWING ALLOWABLE NAMES.        
C     KMTX, MMTX, PVEC, POVE, UPRT, HORG, UVEC, QVEC, PAPP, POAP, LMTX  
C        
      CALL CHKOPN (NMSBR(1))        
      ITM = ITTYPE(ITEM)        
      IF (ITM  .NE. 1) GO TO 1030        
      IF (FILE .GT. 0) GO TO 20        
C        
C     THE MATRIX ITEM IS TO BE PESUDO WRITTEN        
C        
      ITEST = 2        
      CALL SFETCH (NAME(1),ITEM,IFETCH,ITEST)        
      GO TO 100        
C        
C     CHECK IF NASTRAN FILE HAS BEEN PURGED        
C        
   20 TRAIL(1) = FILE        
      CALL RDTRL (TRAIL)        
      IF (TRAIL(1) .LE. 0) GO TO 1020        
C        
C     OPEN ITEM TO WRITE AND FETCH FIRST BLOCK FOR SOF        
C        
      ITEST = 3        
      CALL SFETCH (NAME(1),ITEM,IFETCH,ITEST)        
      IF (ITEST .NE. 3) GO TO 100        
C        
C     OPEN NASTRAN FILE        
C     MAKE SURE BUFFER IS  DOUBLE WORD ALIGNED.        
C        
      IDISP = LOCFX(BUF(IO-2)) - LOCFX(NSTRN)        
      IF (ANDF(IDISP,1) .NE. 0) IO = IO + 1        
      IOPT = 0        
      CALL OPEN (*1020,FILE,BUF(IO-2),IOPT)        
C        
C     ADJUST SOF BUFFER TO COINCIDE WITH GINO BUFFER        
C        
      OLDBUF = IO        
C        
      IF (MACH.EQ.3 .OR. MACH.EQ.4) GO TO 50        
      IF (BUF(IO-2) .EQ. FILE) GO TO 50        
      IO = IO + 1        
      IF (BUF(IO-2) .NE. FILE) GO TO 1000        
C        
C     BEGIN COPYING DATA TO SOF        
C        
C     FIRST CHECK IF CALL TO OPEN OBTAINED ONLY BLOCK IN FILE        
C        
   50 FIRST = 1        
      CALL RDBLK (*70,FILE,FIRST,LEFT)        
      FIRST = 0        
C        
C     WRITE OUT BLOCK IN BUFFER TO SOF AND OBTAIN A FREE SOF BLOCK      
C        
   60 CALL SOFIO (IWRT,IOPBN,BUF(IO-2))        
      CALL GETBLK (IOPBN,J)        
      IF (J .EQ. -1) GO TO 120        
      IOPBN = J        
      IOLBN = IOLBN + 1        
C        
C     OBTAIN A NEW BLOCK FROM THE GINO FILE        
C        
      CALL RDBLK (*70,FILE,FIRST,LEFT)        
      GO TO 60        
C        
C     THE LAST BUFFER OF THE GINO FILE HAS BEEN FOUND - DETERMINE       
C     IF SUFFICIENT SPACE IN BUFFER REMAINS FOR TRAILER        
C        
   70 CONTINUE        
      IF (LEFT .GE. 6) GO TO 80        
C        
C     INSUFFICIENT SPACE - OBTAIN NEW SOF BLOCK        
C     SET BLOCK NUMBER OF CURRENT BLOCK TO ZERO TO INDICATE TRAILER     
C     IS STORED IN NEXT BLOCK        
C        
      BUF(IO+1) = 0        
      CALL SOFIO (IWRT,IOPBN,BUF(IO-2))        
      CALL GETBLK (IOPBN,J)        
      IF (J .EQ. -1) GO TO 120        
      IOPBN = J        
      IOLBN = IOLBN + 1        
C        
C     STORE TRAILER IN LAST SIX WORDS OF BLOCK        
C     SET BLOCK NUMBER NEGATIVE TO INDICATE LAST BLOCK AND        
C     WRITE OUT FINAL BLOCK TO SOF        
C        
   80 DO 90 I = 2,7        
   90 BUF(IO+BLKSIZ-7+I) = TRAIL(I)        
      BUF(IO+1) = -IOLBN        
      CALL SOFIO (IWRT,IOPBN,BUF(IO-2))        
C        
C     CLOSE FILE AND UPDATE MDI        
C        
      CALL CLOSE (FILE,1)        
      CALL FMDI (IOSIND,IMDI)        
      BUF(IMDI+IOITCD) = ORF(ANDF(IOBLK,JHALF),LSHIFT(IOLBN,IHALF))     
      MDIUP = .TRUE.        
C        
C     RETURN        
C        
      ITEST  = 3        
      IO     = OLDBUF        
      IOMODE = IDLE        
  100 RETURN        
C        
C     THERE ARE NO MORE FREE BLOCKS ON THE SOF.        
C     RETURN THE BLOCKS THAT HAVE BEEN USED SO FAR BY THE ITEM BEING    
C     WRITTEN, CLOSE THE SOF AND ISSUE A FATAL MESSAGE        
C        
  120 CALL RETBLK (IOBLK)        
      CALL SOFCLS        
      GO TO 1010        
C        
C     ERROR RETURNS        
C        
C        
C     BUFFER ALIGNMENT ERROR        
C        
 1000 CALL SOFCLS        
      CALL MESAGE (-8,0,NMSBR)        
      GO TO 100        
C        
C     NO MORE FREE BLOCKS ON THE SOF        
C        
 1010 WRITE  (NOUT,1011) UFM        
 1011 FORMAT (A23,' 6223, THERE ARE NO MORE FREE BLOCKS AVAILABLE ON ', 
     1       'THE SOF.')        
      CALL MESAGE (-37,0,NMSBR)        
C        
C     GINO FILE PURGED        
C        
 1020 ITEST = 6        
      GO TO 100        
C        
C     INVALID ITEM NAME        
C        
 1030 ITEST = 5        
      GO TO 100        
C        
      END        
