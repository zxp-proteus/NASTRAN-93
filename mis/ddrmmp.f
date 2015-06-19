      SUBROUTINE DDRMMP(*,Z,NCORE,LUSED,IXYTYP,ICASE,BUFF,ANYXY)        
C*****        
C  BUILD LIST OF POINTS IN SORT FOR WHICH XYCDB OUTPUT REQUESTS EXIST        
C  OF FILE TYPE -IXYTYP- AND OF SUBCASE 0 AND SUBCASE -ICASE-.        
C*****        
      INTEGER Z(1), LOC(6), BUFF(1), XYCDB        
C        
      LOGICAL ANYXY        
C/////        
      COMMON/SYSTEM/ SYSBUF, IOUT        
      COMMON/NAMES / RD, RDREW, WRT, WRTREW, CLSREW, CLS        
      COMMON/DDRMC1/ DUMMY(362), IERROR        
C/////        
C        
      DATA XYCDB/ 108 /, NOEOR / 0 /        
C        
      LUSED = 0        
      ANYXY = .FALSE.        
      CALL OPEN(*100,XYCDB,BUFF,RDREW)        
      CALL FWDREC(*300,XYCDB)        
      CALL FWDREC(*300,XYCDB)        
C        
C     FIND ENTRIES IN SUBCASE 0 OF THIS TYPE IF ANY.        
C        
    5 CALL READ(*300,*300,XYCDB,LOC,6,NOEOR,NWDS)        
      IF( LOC(1) ) 10,10,20        
   10 IF( LOC(2) .NE. IXYTYP ) GO TO 5        
C        
C     SAVE ID IN TABLE        
C        
      IF( LUSED ) 11,11,12        
C        
C      ADD TO LIST IF NOT A REPEAT ID        
C        
   12 IF( LOC(3) .EQ. Z(LUSED) ) GO TO 5        
   11 LUSED = LUSED + 1        
      IF( LUSED .GT. NCORE ) GO TO 1000        
      Z(LUSED) = LOC(3)        
      GO TO 5        
C        
C     FIND ENTRIES IN SUBCASE -ICASE- OF THIS TYPE IF ANY EXIST.        
C        
   15 CALL READ(*300,*300,XYCDB,LOC,6,NOEOR,NWDS)        
   20 IF( LOC(1) - ICASE ) 15, 30, 300        
   30 IF( LOC(2) - IXYTYP ) 15, 40, 300        
   40 LUSED = LUSED + 1        
      IF( LUSED .GT. NCORE ) GO TO 1000        
      Z(LUSED) = LOC(3)        
      GO TO 15        
C        
C     LIST IS NOW COMPLETE THUS SORT IT, AND REMOVE REPEATED IDS.        
C        
  300 CALL CLOSE( XYCDB, CLSREW )        
      IF( LUSED ) 100,100,301        
  301 CALL SORT( 0, 0, 1, 1, Z(1), LUSED )        
      ANYXY = .TRUE.        
C        
      J = 1        
      IF( LUSED .EQ. 1 ) GO TO 305        
      DO 303 I = 2,LUSED        
      IF( Z(I) .EQ. Z(J) ) GO TO 303        
      J = J + 1        
      Z(J) = Z(I)        
  303 CONTINUE        
C        
  305 LUSED = J        
  100 RETURN        
C        
C     INSUFFICIENT CORE ALTERNATE RETURN.        
C        
 1000 IERROR = 859        
      RETURN 1        
      END        
