      SUBROUTINE CRSUB (NAME,I)        
C        
C     THE SUBROUTINE CREATES AN ENTRY FOR THE SUBSTRUCTURE NAME IN THE  
C     DIT THE OUTPUT PARAMETER I INDICATES THAT THE SUBSTRUCTURE NAME   
C     IS THE ITH SUBSTRUCTURE IN THE DIT.        
C        
      LOGICAL         DITUP        
      INTEGER         BUF,DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL        
      DIMENSION       NAME(2),IEMPTY(2),NMSBR(2)        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,        
     1                IODUM(8),MDIDUM(4),NXTDUM(15),DITUP        
      DATA    IEMPTY/ 2*4H    /        
      DATA    INDSBR/ 1 /, NMSBR /4HCRSU,4HB   /        
C        
      CALL CHKOPN (NMSBR(1))        
      IF (DITSIZ .EQ. DITNSB*2) GO TO 10        
C        
C     THERE IS AN EMPTY INTERNAL DIRECTORY SPACE IN THE MDI.        
C        
      CALL FDSUB (IEMPTY(1),I)        
      IF (I .NE. -1) GO TO 20        
      GO TO 30        
C        
C     NO INTERNAL EMPTY SPACE IN THE MDI.  DIRECTORY FOR THE NEW        
C     SUBSTRUCTURE        
C        
   10 DITSIZ = DITSIZ + 2        
      I = DITSIZ/2        
C        
C     UPDATE DIT.        
C        
   20 DITNSB = DITNSB + 1        
      CALL FDIT (I,JDIT)        
      BUF(JDIT  ) = NAME(1)        
      BUF(JDIT+1) = NAME(2)        
      DITUP = .TRUE.        
      RETURN        
C        
C     ERROR MESSAGES.        
C        
   30 CALL ERRMKN (INDSBR,5)        
      RETURN        
      END        
