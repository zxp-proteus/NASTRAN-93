      SUBROUTINE OFPCC1 (IX, L1, L2, L3, L4, L5, IPOINT)
C*****
C     SETS HEADER LINE FORMATS FOR COMPLEX ELEMENT STRESSES IN
C     MATERIAL COORDINATE SYSTEM  --  SORT 1 OUTPUT
C*****
      DIMENSION IDATA(48)
C
      DATA IDATA/3951,104, 139, 125, 0, 432, 3977,104, 139, 126, 0, 432,
     *           3951,104, 140, 125, 0, 432, 3977,104, 140, 126, 0, 432,
     *           3951,104, 135, 125, 0, 432, 3977,104, 135, 126, 0, 432,
     *           3951,104, 134, 125, 0, 432, 3977,104, 134, 126, 0, 432/
C                                                                       
      IX = IDATA(IPOINT  )
      L1 = IDATA(IPOINT+1)
      L2 = IDATA(IPOINT+2)
      L3 = IDATA(IPOINT+3)
      L4 = IDATA(IPOINT+4)
      L5 = IDATA(IPOINT+5)
C
      RETURN
      END
