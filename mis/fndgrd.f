      SUBROUTINE FNDGRD( ISUB , ICOMP , IGRID , IP , IC , N )        
C        
      INTEGER AAA(2),SCSFIL,BUF3,Z,SCORE,IP(6),IC(6)        
      COMMON/CMB001/JUNK(3),SCSFIL        
      COMMON/CMB002/JUNK1(2),BUF3,JUNK2(2),SCORE,LCORE        
      COMMON/CMBFND/  INAM(2),IERR        
CZZ   COMMON/ZZCOMB/Z(1)        
      COMMON/ZZZZZZ/Z(1)        
      DATA AAA/ 4HFNDG,4HRD   /        
      CALL OPEN(*2001,SCSFIL,Z(BUF3),0)        
      NFIL = ISUB-1        
      CALL SKPFIL( SCSFIL , NFIL )        
      NREC = ICOMP - 1        
      IF( NREC .EQ. 0 ) GO TO 3        
      DO 1 I=1,NREC        
      CALL FWDREC(*2002,SCSFIL)        
1     CONTINUE        
3     CALL READ(*2002,*2,SCSFIL,Z(SCORE),LCORE,1,NWD)        
      GO TO 2004        
2     CONTINUE        
      CALL GRIDIP( IGRID , SCORE , NWD , IP , IC , N , Z , LLOC )       
      CALL CLOSE( SCSFIL , 1 )        
      RETURN        
2001  CALL MESAGE( -1 , SCSFIL , AAA )        
2002  CALL MESAGE( -2 , SCSFIL , AAA )        
2004  CALL MESAGE( -8 , SCSFIL , AAA )        
      RETURN        
      END        
