      SUBROUTINE DDR1
C
C     DYNAMIC DATA RECOVERY PART1
C
C     INPUTS  2 UHV,PHIDH
C
C     OUTPUTS 1 UDV
C
C     SCRATCHES  1
C
      INTEGER UHV,PHIDH,UDV,SCR1
      DATA UHV,PHIDH,UDV,SCR1/101,102,201,301/                          
C                                                                       
C     TRANSFPRM TO MODAL DISPLACEMENTS
C
      CALL SSG2B(PHIDH,UHV,0,UDV,0,1,1,SCR1)
      RETURN
      END
