      SUBROUTINE OFP1C (LINE)        
C        
C     THIS SUBROUTINE WAS FORMED ONLY TO REDUCE THE SIZE OF OFP1 FOR    
C     COMPILATION PURPOSES.  IT IS CALLED ONLY BY OFP1.        
C     THIS ROUTINE WAS PART OF OFP1B BEFORE.        
C        
      COMMON /SYSTEM/ IBUF,L        
CZZ   COMMON /ZZOFPX/ L123(1)        
      COMMON /ZZZZZZ/ L123(1)        
C        
C        
      IF (LINE .GT. 466) GO TO 100        
      LOCAL = LINE - 380        
      GO TO (381,382,383,384,385,386,387,388,389,390,        
     1       391,392,393,394,395,396,397,398,399,400,        
     2       401,402,403,404,405,406,407,408,409,410,        
     3       411,412,413,414,415,416,417,418,419,420,        
     4       421,422,423,424,425,426,427,428,429,430,        
     5       431,432,433,434,435,436,437,438,439,440,        
     6       441,442,443,444,445,446,447,448,449,450,        
     7       451,452,453,454,455,456,457,458,459,460,        
     8       461,462,463,464,465,466), LOCAL        
C        
  100 WRITE  (L,110) LINE        
  110 FORMAT ('0*** OFP ERROR/OFP1C,  LINE=',I9)        
      CALL MESAGE (-61,0,0)        
C        
  381 WRITE (L,881)        
      GO TO 1000        
  382 WRITE (L,882)        
      GO TO 1000        
  383 WRITE (L,883)        
      GO TO 1000        
  384 WRITE (L,884)        
      GO TO 1000        
  385 WRITE (L,885)        
      GO TO 1000        
  386 WRITE (L,886)        
      GO TO 1000        
  387 WRITE (L,887)        
      GO TO 1000        
  388 WRITE (L,888)        
      GO TO 1000        
  389 WRITE (L,889)        
      GO TO 1000        
  390 WRITE (L,890)        
      GO TO 1000        
  391 WRITE (L,891)        
      GO TO 1000        
  392 WRITE (L,892)        
      GO TO 1000        
  393 WRITE (L,893)        
      GO TO 1000        
  394 WRITE (L,894)        
      GO TO 1000        
  395 WRITE (L,895)        
      GO TO 1000        
  396 WRITE (L,896)        
      GO TO 1000        
  397 WRITE (L,897)        
      GO TO 1000        
  398 WRITE (L,898)        
      GO TO 1000        
  399 WRITE (L,899)        
      GO TO 1000        
  400 WRITE (L,900)        
      GO TO 1000        
  401 WRITE (L,901)        
      GO TO 1000        
  402 WRITE (L,902)        
      GO TO 1000        
  403 WRITE (L,903)        
      GO TO 1000        
  404 WRITE (L,904)        
      GO TO 1000        
  405 WRITE (L,905)        
      GO TO 1000        
  406 WRITE (L,906)        
      GO TO 1000        
  407 WRITE (L,907)        
      GO TO 1000        
  408 WRITE (L,908)        
      GO TO 1000        
  409 WRITE (L,909)        
      GO TO 1000        
  410 WRITE (L,910)        
      GO TO 1000        
  411 WRITE (L,911)        
      GO TO 1000        
  412 WRITE (L,912)        
      GO TO 1000        
  413 WRITE (L,913)        
      GO TO 1000        
  414 WRITE (L,914)        
      GO TO 1000        
  415 WRITE (L,915)        
      GO TO 1000        
  416 WRITE (L,916)        
      GO TO 1000        
  417 WRITE (L,917)        
      GO TO 1000        
  418 WRITE (L,918)        
      GO TO 1000        
  419 WRITE (L,919)        
      GO TO 1000        
  420 WRITE (L,920)        
      GO TO 1000        
  421 WRITE (L,921)        
      GO TO 1000        
  422 WRITE (L,922)        
      GO TO 1000        
  423 WRITE (L,923)        
      GO TO 1000        
  424 WRITE (L,924)        
      GO TO 1000        
  425 WRITE (L,925)        
      GO TO 1000        
  426 WRITE (L,926)        
      GO TO 1000        
  427 WRITE (L,927)        
      GO TO 1000        
  428 WRITE (L,928)        
      GO TO 1000        
  429 WRITE (L,929)        
      GO TO 1000        
  430 WRITE (L,930)        
      GO TO 1000        
  431 WRITE (L,931)        
      GO TO 1000        
  432 WRITE (L,932)        
      GO TO 1000        
  433 WRITE (L,933)        
      GO TO 1000        
  434 WRITE (L,934)        
      GO TO 1000        
  435 WRITE (L,935)        
      GO TO 1000        
  436 WRITE (L,936)        
      GO TO 1000        
  437 WRITE (L,937)        
      GO TO 1000        
  438 WRITE (L,938)        
      GO TO 1000        
  439 WRITE (L,939)        
      GO TO 1000        
  440 WRITE (L,940)        
      GO TO 1000        
  441 WRITE (L,941)        
      GO TO 1000        
  442 WRITE (L,942)        
      GO TO 1000        
  443 WRITE (L,943)        
      GO TO 1000        
  444 WRITE (L,944)        
      GO TO 1000        
  445 WRITE (L,945)        
      GO TO 1000        
  446 WRITE (L,946)        
      GO TO 1000        
  447 WRITE (L,947)        
      GO TO 1000        
  448 WRITE (L,948)        
      GO TO 1000        
  449 WRITE (L,949)        
      GO TO 1000        
  450 WRITE (L,950)        
      GO TO 1000        
  451 WRITE (L,951)        
      GO TO 1000        
  452 WRITE (L,952)        
      GO TO 1000        
  453 WRITE (L,953)        
      GO TO 1000        
  454 WRITE (L,954)        
      GO TO 1000        
  455 WRITE (L,955)        
      GO TO 1000        
  456 WRITE (L,956)        
      GO TO 1000        
  457 WRITE (L,957)        
      GO TO 1000        
  458 WRITE (L,958)        
      GO TO 1000        
  459 WRITE (L,959)        
      GO TO 1000        
  460 WRITE (L,960)        
      GO TO 1000        
  461 WRITE (L,961)        
      GO TO 1000        
  462 WRITE (L,962)        
      GO TO 1000        
  463 WRITE (L,963)        
      GO TO 1000        
  464 WRITE (L,964)        
      GO TO 1000        
  465 WRITE (L,965)        
      GO TO 1000        
  466 WRITE (L,966)        
      GO TO 1000        
 1000 RETURN        
C        
C     ******************************************************************
C        
  881 FORMAT (4X,'S T R A I N S / C U R V A T U R E S   I N   G E N E ',
     1       'R A L   Q U A D R I L A T E R A L   E L E M E N T S',6X,  
     2       '( C Q U A D 2 )')        
  882 FORMAT (4X,'S T R A I N S / C U R V A T U R E S   I N   G E N E ',
     1       'R A L   Q U A D R I L A T E R A L   E L E M E N T S',6X,  
     2       '( C Q U A D 1 )')        
  883 FORMAT (2X,7HELEMENT,24X,37HSTRNS./CURVS. IN ELEMENT COORD SYSTEM,
     1       6X,38HPRIN. STRNS./CURVS. (ZERO SHEAR/TWIST),7X,7HMAXIMUM) 
  884 FORMAT (4X,3HID.,6X,15HID./OUTPUT CODE,5X,8HNORMAL-X,7X,        
     1       8HNORMAL-Y,6X,8HSHEAR-XY,7X,5HANGLE,9X,5HMAJOR,11X,5HMINOR,
     3       7X,11HSHEAR/TWIST)        
  885 FORMAT (2X,7HELEMENT,4X,16HMAT. COORD. SYS.,4X,'STRNS./CURVS. ',  
     1       ' IN MATERIAL COORD SYSTEM',5X,        
     2       38HPRIN. STRNS./CURVS. (ZERO SHEAR/TWIST),7X,7HMAXIMUM)    
  886 FORMAT (33X,'S T R A I N S / C U R V A T U R E S   A T   G R I D',
     1       '   P O I N T S')        
  887 FORMAT (2X,7H POINT ,4X,16HMAT. COORD. SYS.,6X,        
     1       33HSTRESSES INMATERIAL COORD SYSTEM , 12X,        
     2       31HPRINCIPAL STRESSES (ZERO SHEAR), 12X,3HMAX)        
  888 FORMAT (2X,7H POINT ,4X,16HMAT. COORD. SYS.,4X,        
     1       38HSTRNS./CURVS. IN MATERIAL COORD SYSTEM, 5X,        
     2       38HPRIN. STRNS./CURVS. (ZERO SHEAR/TWIST), 7X,7HMAXIMUM)   
  889 FORMAT (50X,30H(IN ELEMENT COORDINATE SYSTEM),/)        
  890 FORMAT (50X,31H(IN MATERIAL COORDINATE SYSTEM),/)        
  891 FORMAT (4X,3HID.,26X,8HNORMAL-X, 7X,8HNORMAL-Y, 6X,8HSHEAR-XY,    
     1       7X,5HANGLE, 9X,5HMAJOR, 11X,5HMINOR, 7X,11HSHEAR/TWIST)    
  892 FORMAT (4X,'C O M P L E X   F O R C E S   I N   A X I S - S Y M ',
     1       'M E T R I C   T R I A N G U L A R   R I N G   E L E M E ',
     2       'N T S   (CTRIAAX)',/)        
  893 FORMAT (2X,'C O M P L E X   S T R E S S E S   I N   A X I S - S ',
     1       'Y M M E T R I C   T R I A N G U L A R   R I N G   E L E ',
     2       'M E N T S   (CTRIAAX)',/)        
  894 FORMAT (3X,'C O M P L E X   F O R C E S   I N   A X I S - S Y M ',
     1       'M E T R I C   T R A P E Z O I D A L   R I N G   E L E M ',
     2       'E N T S   (CTRAPAX)',/)        
  895 FORMAT (' C O M P L E X   S T R E S S E S   I N   A X I S - S Y ',
     1       ' M M E T R I C   T R A P E Z O I D A L   R I N G   E L E',
     2       ' M E N T S   (CTRAPAX)',/)        
  896 FORMAT (3X,'SUBCASE   HARMONIC    POINT',12X,'RADIAL',12X,        
     1       'CIRCUMFERENTIAL',12X,'AXIAL',16X,'CHARGE', /14X,        
     2       'NUMBER     ANGLE',13X,'(R)',17X,'(THETA-T)',16X,'(Z)')    
  897 FORMAT (' SUBCASE   HARMONIC    POINT    RADIAL      AXIAL     ', 
     1       'CIRCUM.     SHEAR      SHEAR      SHEAR      F L U X   ', 
     2       'D E N S I T I E S', /11X,'NUMBER      ANGLE     (R)',9X,  
     3       '(Z)     (THETA-T)    (ZR)       (RT)       (ZT)',8X,      
     4       '(R)        (Z)        (T)')        
  898 FORMAT ('   FREQUENCY  HARMONIC    POINT            RADIAL',12X,  
     1       'CIRCUMFERENTIAL',12X,'AXIAL',16X,'CHARGE', /14X,        
     2       'NUMBER     ANGLE',13X,'(R)',17X,'(THETA-T)',16X,'(Z)')    
  899 FORMAT (' FREQUENCY HARMONIC    POINT    RADIAL      AXIAL     ', 
     1       'CIRCUM.     SHEAR      SHEAR      SHEAR      F L U X   ', 
     2       'D E N S I T I E S', /10X,'NUMBER      ANGLE     (R)',9X,  
     3       '(Z)     (THETA-T)    (ZR)       (RT)       (ZT)',8X,      
     4       '(R)        (Z)        (T)')        
  900 FORMAT (4X,'TIME     HARMONIC    POINT            RADIAL',12X,    
     1       'CIRCUMFERENTIAL',12X,'AXIAL',16X,'CHARGE', /14X,        
     2       'NUMBER     ANGLE',13X,'(R)',17X,'(THETA-T)',16X,'(Z)')    
  901 FORMAT (2X,'TIME     HARMONIC    POINT    RADIAL      AXIAL     ',
     1       'CIRCUM.     SHEAR      SHEAR      SHEAR      F L U X   ', 
     2       'D E N S I T I E S', /11X,'NUMBER      ANGLE     (R)',9X,  
     3       '(Z)     (THETA-T)    (ZR)       (RT)       (ZT)',8X,      
     4       '(R)        (Z)        (T)')        
  902 FORMAT (5X,4HTIME,7X,8HHARMONIC,8X,2HT1,13X,2HT2,13X,2HT3,13X,    
     1       2HR1,13X,2HR2,13X,2HR3)        
  903 FORMAT (4X,7HSUBCASE,5X,8HHARMONIC,8X,2HT1,13X,2HT2,13X,2HT3,     
     1       13X,2HR1,13X,2HR2,13X,2HR3)        
  904 FORMAT (3X,9HFREQUENCY,4X,8HHARMONIC,8X,2HT1,13X,2HT2,13X,2HT3,   
     1       13X,2HR1,13X,2HR2,13X,2HR3)        
  905 FORMAT (19X,'F I N I T E   E L E M E N T   M A G N E T I C   F I',
     1       ' E L D   A N D   I N D U C T I O N',/)        
  906 FORMAT (4X,'ELEMENT-ID   EL-TYPE         X-FIELD',10X,'Y-FIELD',  
     1       10X,'Z-FIELD        X-INDUCTION      Y-INDUCTION',6X,      
     2       'Z-INDUCTION')        
  907 FORMAT (28X,'G R I D   P O I N T   S T R E S S E S   F O R   I S',
     1       ' 2 D 8   E L E M E N T S',/)        
  908 FORMAT (2X,7HELEMENT,3X,5HNO.OF,4X,5HNO.OF,7X,4HGRID,3X,6HCOORD.) 
  909 FORMAT (4X,3HID.,4X,9HGRID PTS.,1X,8HSTRESSES,3X,5HPOINT,2X,      
     1       7HSYS ID.,5X,5HSIG-X,8X,5HSIG-Y,8X,6HTAU-XY)        
  910 FORMAT (12X,5HNO.OF,4X,5HNO.OF,13X,6HCOORD.)        
  911 FORMAT (4X,4HTIME,3X,9HGRID PTS.,1X,8HSTRESSES,2X,7HGRID PT,1X,   
     1       7HSYS ID.,5X,5HSIG-X,8X,5HSIG-Y,8X,6HTAU-XY)        
  912 FORMAT (20X,'C O M P L E X   G R I D   P O I N T   S T R E S S E',
     1       ' S   F O R   I S 2 D 8   E L E M E N T S',/)        
  913 FORMAT (2X,7HELEMENT,3X,5HNO.OF,4X,5HNO.OF,13X,6HCOORD.,/4X,3HID.,
     1       4X,9HGRID PTS.,1X,8HSTRESSES,2X,7HGRID PT,1X,7HSYS ID.,11X,
     2       5HSIG-X,22X,5HSIG-Y,22X,6HTAU-XY)        
  914 FORMAT (12X,5HNO.OF,4X,5HNO.OF,13X,6HCOORD., /1X,9HFREQUENCY,1X,  
     1       9HGRID PTS.,1X,8HSTRESSES,2X,7HGRID PT,1X,7HSYS ID.,11X,   
     2       5HSIG-X,22X,5HSIG-Y,22X,6HTAU-XY)        
  915 FORMAT (12X,5HNO.OF,4X,5HNO.OF,13X,6HCOORD., /2X,7HSUBCASE,2X,    
     1       9HGRID PTS.,1X,8HSTRESSES,2X,7HGRID PT,1X,7HSYS ID.,5X,    
     2       5HSIG-X,8X,5HSIG-Y,8X,6HTAU-XY)        
  916 FORMAT (26X,'F O R C E S    I N    C U R V E D    B E A M    E L',
     1       ' E M E N T S',8X,'( C E L B O W )',/)        
  917 FORMAT (5X,7HELEMENT,11X,16H-BENDING MOMENT-,21X,7H-SHEAR-,18X,   
     1       13H-AXIAL FORCE-,7X,8H-TORQUE-)        
  918 FORMAT (7X,3HID.,7X,13HPLANE-1 END-A,2X,13HPLANE-2 END-A,5X,      
     1       13HPLANE-1 END-A,2X,13HPLANE-2 END-A,13X,5HEND-A,13X,      
     2       5HEND-A)        
  919 FORMAT (25X,5HEND-B,10X,5HEND-B,13X,5HEND-B,28X,5HEND-B,13X,      
     1       5HEND-B)        
  920 FORMAT (26X,'S T R E S S E S    I N    C U R V E D    B E A M   ',
     1       ' E L E M E N T S',8X,'( C E L B O W )',/)        
  921 FORMAT (23X,16H-BENDING MOMENT-,21X,7H-SHEAR-,18X,        
     1       13H-AXIAL FORCE-,7X,8H-TORQUE-)        
  922 FORMAT (4X,4HTIME,9X,13HPLANE-1 END-A,2X,13HPLANE-2 END-A,5X,     
     1       13HPLANE-1 END-A,8X,7HPLANE-2,13X,5HEND-A,13X,5HEND-A,     
     2       /25X,5HEND-B,10X,5HEND-B,13X,5HEND-B,28X,5HEND-B,13X,      
     3       5HEND-B)        
  923 FORMAT (6X,7HSUBCASE,4X,13HPLANE-1 END-A,2X,13HPLANE-2 END-A,5X,  
     1       13HPLANE-1 END-A,2X,13HPLANE-2 END-A,13X,5HEND-A,13X,      
     2       5HEND-A, /25X,5HEND-B,10X,5HEND-B,13X,5HEND-B,28X,5HEND-B, 
     3       13X,5HEND-B)        
  924 FORMAT (19X,'C O M P L E X   F O R C E S   I N   C U R V E D   ', 
     1       'B E A M   E L E M E N T S   ( C E L B O W )',/)        
  925 FORMAT (7X,9HFREQUENCY,21X,14HBENDING-MOMENT,19X,11HSHEAR-FORCE,  
     1       22X,5HAXIAL,10X,6HTORQUE, /35X,7HPLANE 1,8X,7HPLANE 2,11X, 
     2       7HPLANE 1,8X,7HPLANE 2,13X,5HFORCE)        
  926 FORMAT (18X,'C O M P L E X   S T R E S S E S   I N   C U R V E D',
     1       '   B E A M   E L E M E N T S   ( C E L B O W )',/)        
  927 FORMAT (7X,9HELEMENT  ,21X,14HBENDING-MOMENT,19X,11HSHEAR-FORCE,  
     1       22X,5HAXIAL,10X,6HTORQUE, /35X,7HPLANE 1,8X,7HPLANE 2,11X, 
     2       7HPLANE 1,8X,7HPLANE 2,13X,5HFORCE)        
  928 FORMAT (23X,'F O R C E S   I N   F L U I D   H E X A H E D R A L',
     1       '   E L E M E N T S   ( C F H E X 2 )',/)        
  929 FORMAT (23X,'F O R C E S   I N   F L U I D   H E X A H E D R A L',
     1       '   E L E M E N T S   ( C F H E X 1 )',/)        
  930 FORMAT (19X,'F O R C E S   I N   F L U I D   T E T R A H E D R A',
     1       ' L   E L E M E N T S   ( C F T E T R A )',/)        
  931 FORMAT (26X,'F O R C E S   I N   F L U I D   W E D G E   E L E M',
     1       ' E N T S    ( C F W E D G E )',/)        
  932 FORMAT (24X,'P O W E R   C O N V E C T E D   B Y   F T U B E   ', 
     1       'E L E M E N T S   ( C F T U B E )',/)        
  933 FORMAT (47X,4HTIME,26X,5HPOWER)        
  934 FORMAT (45X,10HELEMENT-ID ,22X,5HPOWER)        
  935 FORMAT (2X,7HELEMENT,3X,16HMAT. COORD. SYS.,30X,        
     1       42H- STRESSES IN MATERIAL COORDINATE SYSTEM -, /4X,        
     2       3HID., 5X,16HID./OUTPUT CODED, 14X,8HNORMAL-X, 26X,        
     3       8HNORAML-Y, 25X,8HSHEAR-XY )        
  936 FORMAT (16X,16HMAT. COORD. SYS., 30X,        
     1       42H- STRESSES IN MATERIAL COORDINATE SYSTEM -, /4X,        
     2       9HFREQUENCY, 3X,15HID./OUTPUT CODE,        
     3       14X,8HNORAML-X, 26X,8HNORMAL-Y, 25X,8HSHEAR-XY )        
  937 FORMAT (50X, 29H(IN STRESS COORDINATE SYSTEM),/)        
  938 FORMAT (2X,7HELEMENT,6X,5HFIBRE,15X,'STRESSES IN STRESS COORD. ', 
     1       'SYSTEM',13X,31HPRINCIPAL STRESSES (ZERO SHEAR),12X,3HMAX) 
  939 FORMAT (4X,3HID.,7X,8HDISTANCE,11X,8HNORMAL-X,7X,8HNORMAL-Y,6X,   
     1       8HSHEAR-XY,7X,5HANGLE,9X,5HMAJOR,11X,5HMINOR,10X,5HSHEAR)  
  940 FORMAT (20X,'F O R C E S   I N   G E N E R A L   Q U A D R I ',   
     1       'L A T E R A L   E L E M E N T S     ( Q U A D 4 )',/)     
  941 FORMAT (6X,'ELEMENT',12X,'- MEMBRANE  FORCES -',22X,'- BENDING',  
     1       '   MOMENTS -',11X,'- TRANSVERSE SHEAR FORCES -')        
  942 FORMAT (8X,'ID',10X,2HFX,12X,2HFY,12X,3HFXY,11X,2HMX,12X,2HMY,    
     1       12X,3HMXY,11X,2HVX,12X,2HVY)        
  943 FORMAT (19X,5HFIBRE,11X,32HSTRESSES IN STRESS COORD. SYSTEM,13X,  
     1       31HPRINCIPAL STRESSES (ZERO SHEAR),10X,7HMAXIMUM, /7X,     
     2       4HTIME,7X,8HDISTANCE,7X,8HNORMAL-X,7X,8HNORMAL-Y,6X,       
     3       8HSHEAR-XY,7X,5HANGLE,9X,5HMAJOR,11X,5HMINOR,10X,5HSHEAR)  
  944 FORMAT (19X, 5HFIBRE, 11X, 32HSTRESSES IN STRESS COORD. SYSTEM,   
     1       13X, 31HPRINCIPAL STRESSES (ZERO SHEAR), 10X, 7HMAXIMUM,   
     2       /5X, 7HSUBCASE, 6X, 8HDISTANCE, 7X, 8HNORMAL-X, 7X,        
     3       8HNORMAL-Y, 6X, 8HSHEAR-XY, 7X, 5HANGLE, 9X, 5HMAJOR,      
     4       11X, 5HMINOR, 10X, 5HSHEAR)        
  945 FORMAT (6X,' TIME  ',18X,'- MEMBRANE  FORCES -',22X,'- BENDING',  
     1       '   MOMENTS -',11X,'- TRANSVERSE SHEAR FORCES -')        
  946 FORMAT (26X,2HFX,12X,2HFY,12X,3HFXY,11X,2HMX,12X,2HMY,12X,3HMXY,  
     1       11X,2HVX,12X,2HVY)        
  947 FORMAT (6X,'SUBCASE',18X,'- MEMBRANE  FORCES -',22X,'- BENDING',  
     1       '   MOMENTS -',11X,'- TRANSVERSE SHEAR FORCES -')        
  948 FORMAT (6X,'C O M P L E X   S T R E S S E S   I N   G E N E R A ',
     1       'L   Q U A D R I L I A T E R A L   E L E M E N T S   ',    
     2       '( C Q U A D 4 )')        
  949 FORMAT (9H  ELEMENT,7X,5HFIBRE,38X,'- STRESSES IN STRESS COORDI', 
     1       'NATE SYSTEM -', /4X,3HID.,8X,8HDISTANCE,18X,8HNORMAL-X,   
     2       26X,8HNORMAL-Y,25X,8HSHEAR-XY)        
  950 FORMAT (20X,5HFIBRE,38X,'- STRESSES IN STRESS COORDINATE SYSTEM -'
     1,      /4X,9HFREQUENCY,6X,8HDISTANCE,18X,8HNORMAL-X,26X,        
     2       8HNORMAL-Y,25X,8HSHEAR-XY)        
  951 FORMAT (6X,7HELEMENT,15X,6HCENTER,22X,7HEDGE  1,14X,7HEDGE  2,14X,
     1       7HEDGE  3,14X,7HEDGE  4, /8X,3HID.,9X,'R ------- PHI ----',
     2       '-- Z',4X,4(8X,13HS ------- PHI))        
  952 FORMAT (28X,6HCENTER,22X,7HEDGE  1,14X,7HEDGE  2,14X,7HEDGE  3,   
     1       14X,7HEDGE 4, /7X,4HTIME,9X,22HR ------- PHI ------ Z,4X,  
     2       4(8X,13HS ------- PHI))        
  953 FORMAT (29X,6HCENTER,21X,7HEDGE  1,14X,7HEDGE  2, 14X,7HEDGE  3,  
     1       14X,7HEDGE  4,/4X,9HFREQUENCY,7X,22HR ------- PHI ------ Z,
     2       4X,4(8X,13HS ------- PHI))        
  954 FORMAT (9X,'C O M P L E X   S T R E S S E S   I N   T R I A N G ',
     1       'U L A R   M E M B R A N E   E L E M E N T S   ',        
     2       '( C T R I M 6 )')        
  955 FORMAT (11X,'C O M P L E X   F O R C E S   I N   T R I A N G U L',
     1     ' A R   M E M B R A N E   E L E M E N T S   ( C T R I M 6 )')
  956 FORMAT (9X,'C O M P L E X   S T R E S S E S   I N   T R I A N G ',
     1       'U L A R   B E N D I N G   E L E M E N T S   ',        
     2       '( C T R P L T 1 )')        
  957 FORMAT (11X,'C O M P L E X   F O R C E S   I N   T R I A N G U L',
     1     ' A R   B E N D I N G   E L E M E N T S   ( C T R P L T 1 )')
  958 FORMAT (12X,'C O M P L E X   S T R E S S E S   I N   T R I A N G',
     1       ' U L A R   S H E L L   E L E M E N T S   ( C T R S H L )')
  959 FORMAT (14X,'C O M P L E X   F O R C E S   I N   T R I A N G U L',
     1       ' A R   S H E L L   E L E M E N T S   ( C T R S H L )')    
  960 FORMAT (9X,'C O M P L E X   F O R C E S   I N   G E N E R A L   ',
     1       'Q U A D R I L A T E R A L   E L E M E N T S   ',        
     2       '( C Q U A D 4 )')        
  961 FORMAT (3X,'FREQUENCY',14X,'- MEMBRANE  FORCES -',23X,'- BENDING',
     1       '   MOMENTS -',10X,'- TRANSVERSE SHEAR FORCES -',        
     2       /22X,2HFX,12X,2HFY,11X,3HFXY,13X,2HMX,12X,2HMY,11X,3HMXY,  
     3       13X,2HVX,12X,2HVY)        
  962 FORMAT (16X,4HGRID,11X,35HSTRESSES IN BASIC COORDINATE SYSTEM,13X,
     1       12HDIR. COSINES, /3X,9HFREQUENCY,3X,5HPOINT,5X,8HNORMAL-X, 
     2       9X,8HNORMAL-Y,9X,8HNORMAL-Z,9X,8HSHEAR-XY,9X,8HSHEAR-YZ,9X,
     3       8HSHEAR-ZX)        
  963 FORMAT (22X,'F O R C E S   I N   G E N E R A L   T R I A N G ',   
     1       'U L A R   E L E M E N T S     ( C T R I A 3 )',/)        
  964 FORMAT (12X,'C O M P L E X   F O R C E S   I N   G E N E R A L  ',
     1       ' T R I A N G U L A R   E L E M E N T S   ( C T R I A 3 )')
  965 FORMAT (21X,'S T R E S S E S   I N   G E N E R A L   T R I A N G',
     1       ' U L A R   E L E M E N T S',6X,'( C T R I A 3 )')        
  966 FORMAT (9X,'C O M P L E X   S T R E S S E S   I N   G E N E R A ',
     1       'L   T R I A N G U L A R   E L E M E N T S   ',        
     2       '( C T R I A 3 )')        
C        
      END        
