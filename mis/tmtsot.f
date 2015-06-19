      SUBROUTINE TMTSOT        
C        
C     THIS SUBROUTINE PRINTS THE CONTENTS OF COMMON /NTIME/        
C        
      COMMON /NTIME / NITEMS, TGINO , TBLDPK, TINTPK, TPACK ,        
     1                        TUNPAK, TGETST, TPUTST,        
     2                        TTLRSP, TTLRDP, TTLCSP, TTLCDP,        
     3                        TLLRSP, TLLRDP, TLLCSP, TLLCDP,        
     4                        TGETSB        
      COMMON /SYSTEM/ ISYSBF, NOUT  , DUMMY(74)     , ISY77        
C        
      WRITE (NOUT,2000) NITEMS        
      WRITE (NOUT,2010) TGINO        
      WRITE (NOUT,2020) TBLDPK        
      WRITE (NOUT,2030) TINTPK        
      WRITE (NOUT,2040) TPACK        
      WRITE (NOUT,2050) TUNPAK        
      WRITE (NOUT,2060) TGETST        
      WRITE (NOUT,2070) TPUTST        
      WRITE (NOUT,2080) TTLRSP        
      WRITE (NOUT,2090) TTLRDP        
      WRITE (NOUT,2100) TTLCSP        
      WRITE (NOUT,2110) TTLCDP        
      WRITE (NOUT,2120) TLLRSP        
      WRITE (NOUT,2130) TLLRDP        
      WRITE (NOUT,2140) TLLCSP        
      WRITE (NOUT,2150) TLLCDP        
      WRITE (NOUT,2160) TGETSB        
      IF (ISY77 .NE. -3) WRITE (NOUT,2200)        
      RETURN        
 2000 FORMAT (1H1,23X,        
     1        ' DIAG 35 OUTPUT OF TIMING CONSTANTS IN COMMON /NTIME/'/  
     2            24X,        
     3        ' ----------------------------------------------------'// 
     4        ' NUMBER OF TIMING CONSTANTS IN COMMON /NTIME/   ',       
     5        '                         --- ', I11                   / )
 2010 FORMAT (' READ + WRITE + BACKWARD READ                   ',       
     1        ' (AVERAGE PER WORD     ) --- ', E11.4, ' MICROSECONDS'/ )
 2020 FORMAT (' BLDPK  - PACK   SUCCESSIVE ELEMENTS OF A COLUMN',       
     1        ' (AVERAGE PER WORD     ) --- ', E11.4, ' MICROSECONDS'/ )
 2030 FORMAT (' INTPK  - UNPACK SUCCESSIVE ELEMENTS OF A COLUMN',       
     1        ' (AVERAGE PER WORD     ) --- ', E11.4, ' MICROSECONDS'/ )
 2040 FORMAT (' PACK   - PACK   AN ENTIRE COLUMN               ',       
     1        ' (AVERAGE PER WORD     ) --- ', E11.4, ' MICROSECONDS'/ )
 2050 FORMAT (' UNPACK - UNPACK AN ENTIRE COLUMN               ',       
     1        ' (AVERAGE PER WORD     ) --- ', E11.4, ' MICROSECONDS'/ )
 2060 FORMAT (' GETSTR - FORWARD READ  A STRING OF DATA        ',       
     1        ' (AVERAGE PER WORD     ) --- ', E11.4, ' MICROSECONDS'/ )
 2070 FORMAT (' PUTSTR - WRITE A STRING OF DATA                ',       
     1        ' (AVERAGE PER WORD     ) --- ', E11.4, ' MICROSECONDS'/ )
 2080 FORMAT (' TIGHT-LOOP MULTIPLY - REAL    SINGLE PRECISION ',       
     1        ' (AVERAGE PER OPERATION) --- ', E11.4, ' MICROSECONDS'/ )
 2090 FORMAT (' TIGHT-LOOP MULTIPLY - REAL    DOUBLE PRECISION ',       
     1        ' (AVERAGE PER OPERATION) --- ', E11.4, ' MICROSECONDS'/ )
 2100 FORMAT (' TIGHT-LOOP MULTIPLY - COMPLEX SINGLE PRECISION ',       
     1        ' (AVERAGE PER OPERATION) --- ', E11.4, ' MICROSECONDS'/ )
 2110 FORMAT (' TIGHT-LOOP MULTIPLY - COMPLEX DOUBLE PRECISION ',       
     1        ' (AVERAGE PER OPERATION) --- ', E11.4, ' MICROSECONDS'/ )
 2120 FORMAT (' LOOSE-LOOP MULTIPLY - REAL    SINGLE PRECISION ',       
     1        ' (AVERAGE PER OPERATION) --- ', E11.4, ' MICROSECONDS'/ )
 2130 FORMAT (' LOOSE-LOOP MULTIPLY - REAL    DOUBLE PRECISION ',       
     1        ' (AVERAGE PER OPERATION) --- ', E11.4, ' MICROSECONDS'/ )
 2140 FORMAT (' LOOSE-LOOP MULTIPLY - COMPLEX SINGLE PRECISION ',       
     1        ' (AVERAGE PER OPERATION) --- ', E11.4, ' MICROSECONDS'/ )
 2150 FORMAT (' LOOSE-LOOP MULTIPLY - COMPLEX DOUBLE PRECISION ',       
     1        ' (AVERAGE PER OPERATION) --- ', E11.4, ' MICROSECONDS'/ )
 2160 FORMAT (' GETSTB - BACKWARD READ  A STRING OF DATA       ',       
     1        ' (AVERAGE PER WORD     ) --- ', E11.4, ' MICROSECONDS'/ )
 2200 FORMAT ('0*** NASTRAN INFORMATION MESSAGE, TO INCORPORATE THESE ',
     1        'TIMING CONSTANTS INTO NASTRAN PERMANENTLY', /5X,        
     2        'RE-RUN JOB WITH ''NASTRAN BULKDATA=-3'' FOR MORE ',      
     3        'INSTRUCTIONS',/)        
      END        
