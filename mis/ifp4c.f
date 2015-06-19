      SUBROUTINE IFP4C (FILE,SCRT,BUF1,BUF2,EOF)        
C        
C     THIS ROUTINE, CALLED BY IFP4, OPENS THE 2 FILES AND COPIES THE    
C     HEADER RECORD FROM -FILE- TO -SCRT-.        
C        
      LOGICAL        EOF        
      INTEGER        FILE,SCRT,BUF1(10),BUF2(10),WORK(10),FLAG,NAME(2), 
     1               NAME2(2),EOR,TRAIL(7)        
      COMMON /NAMES/ RD,RDREW,WRT,WRTREW,CLSREW,CLS        
      DATA    NAME / 4HIFP4,4HC   /, EOR,NOEOR/1,0/        
C        
      TRAIL(1) = FILE        
      DO 50 I = 2,7        
      TRAIL(I) = 0        
   50 CONTINUE        
      CALL RDTRL (TRAIL)        
      DO 70 I = 2,7        
      IF (TRAIL(I)) 60,70,60        
   70 CONTINUE        
      GO TO 1000        
   60 CALL OPEN (*1002,FILE,BUF1,RDREW)        
      EOF = .FALSE.        
      CALL OPEN (*2000,SCRT,BUF2,WRTREW)        
   80 CALL READ (*1001,*100,FILE,WORK,10,NOEOR,FLAG)        
      CALL WRITE (SCRT,WORK,10,NOEOR)        
      GO TO 80        
  100 CALL WRITE (SCRT,WORK,FLAG,EOR)        
      RETURN        
C        
C     FILE IS NULL        
C        
 1000 EOF = .TRUE.        
      CALL OPEN (*2000,SCRT,BUF2,WRTREW)        
      CALL FNAME (FILE,NAME2)        
      CALL WRITE (SCRT,NAME2,2,EOR)        
      RETURN        
C        
 2000 CALL MESAGE (-1,SCRT,NAME)        
 1001 CALL MESAGE (-2,FILE,NAME)        
 1002 CALL MESAGE (-1,FILE,NAME)        
      RETURN        
      END        
