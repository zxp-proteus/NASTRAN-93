      SUBROUTINE INVERT( IA,IB,SCR1)        
C        
C     DRIVER  FOR  INVTR        
C        
C     INVERTS  LOWER OR UPPER TRIANGLE  IA  ONTO  IB        
C        
C     SCR1 WILL BE USED  ONLY IF  IA  IS AN  UPPER  TRIANGLE        
C        
      INTEGER  FA,FB,SCRFIL,PREC,SCR1,NAME(2)        
C        
      COMMON /INVTRX/ FA(7),FB(7),SCRFIL,NX,PREC        
CZZ   COMMON / ZZINVT/ Z(1)        
      COMMON / ZZZZZZ/ Z(1)        
C        
      DATA NAME /4HINVE,4HRT  /        
C        
C     FILL  MATRIX  CONTROL  BLOCKS  FOR  A  AND  B        
C        
      FA(1) = IA        
      CALL RDTRL(FA)        
      FB(1) = IA        
      CALL RDTRL(FB)        
      FB(1) = IB        
      SCRFIL = SCR1        
      PREC = FA(5)        
      NX  =  KORSZ(Z)        
      CALL INVTR(*50,Z,Z)        
      CALL WRTTRL(FB)        
      RETURN        
C        
C     SINGULAR  MATRIX        
C        
   50 CALL MESAGE(-5,FA,NAME)        
      GO TO 50        
      END        
