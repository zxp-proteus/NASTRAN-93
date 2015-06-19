      SUBROUTINE RCOVSS        
C        
C     THIS ROUTINE GENERATES THE STATIC SOLUTION ITEM FOR RIGID FORMATS 
C     1 AND 2        
C        
      INTEGER         DRY        ,STEP       ,FSS        ,RFNO       ,  
     1                SYSBUF     ,IZ(5)      ,RD         ,RDREW      ,  
     2                WRT        ,WRTREW     ,REW        ,EOFNRW     ,  
     3                LOD(4)     ,SOLN       ,EQSS       ,LOADC(2)   ,  
     4                SRD        ,SWRT       ,EOG        ,EOI        ,  
     5                CASESS     ,GEOM4      ,SCR1       ,RC         ,  
     6                BUF1       ,BUF2       ,BUF3       ,CC(2)      ,  
     7                FILE       ,NAME(2)    ,CASECC(2)        
      REAL            CLOD(4)        
      CHARACTER       UFM*23     ,UWM*25        
      COMMON /XMSSG / UFM        ,UWM        
      COMMON /BLANK / DRY        ,LOOP       ,STEP       ,FSS(2)     ,  
     1                RFNO       ,NEIGV      ,LUI        ,UINMS(2,5) ,  
     2                NOSORT     ,UTHRES     ,PTHRES     ,QTHRES        
      COMMON /RCOVCR/ ICORE      ,LCORE      ,BUF1       ,BUF2       ,  
     1                BUF3       ,BUF4       ,SOF1       ,SOF2       ,  
     2                SOF3        
      COMMON /RCOVCM/ MRECVR     ,UA         ,PA         ,QA         ,  
     1                IOPT       ,RSS(2)     ,ENERGY     ,UIMPRO     ,  
     2                RANGE(2)   ,IREQ       ,LREQ       ,LBASIC        
      COMMON /SYSTEM/ SYSBUF     ,NOUT        
CZZ   COMMON /ZZRCAX/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /NAMES / RD         ,RDREW      ,WRT        ,WRTREW     ,  
     1                REW        ,NOREW      ,EOFNRW        
      EQUIVALENCE     (Z(1),IZ(1)), (LOD(1),CLOD(1))        
      DATA    NAME  / 4HRCOV,4HSS   /        
      DATA    SOLN  , EQSS, LODS / 4HSOLN,4HEQSS,4HLODS /        
      DATA    CASESS, GEOM4,SCR1 / 101,102,301 /        
      DATA    LOADC / 500  ,5    /        
      DATA    SRD   , SWRT, EOG,EOI / 1,2,2,3  /        
      DATA    CASECC/ 4HCASE,4HCC   /        
C        
C     CREATE SOLN FOR RIGID FORMAT 1 OR 2        
C        
C     GET NUMBER OF BASIC SUBSTRUCTURES (NS) FROM EQSS AND CREATE       
C     GROUP 0 OF SOLN AT TOP OF OPEN CORE        
C        
      CALL SFETCH (FSS,EQSS,SRD,RC)        
      IF (RC .EQ. 1) GO TO 110        
      CALL SMSG (RC-2,EQSS,FSS)        
      GO TO 440        
  110 CALL SUREAD (Z,2,NWDS,RC)        
      CALL SUREAD (NS,1,NWDS,RC)        
      IF (LCORE .LT. 3*NS+5) GO TO 9008        
      CALL SUREAD (Z,1,NWDS,RC)        
      IZ(1) = FSS(1)        
      IZ(2) = FSS(2)        
      IZ(3) = RFNO        
      IZ(4) = NS        
C        
C     GET SUBSTRUCTURE NAMES FROM EQSS        
C        
      DO 120 I = 1,NS        
      CALL SUREAD (Z(3*I+3),2,NWDS,RC)        
  120 CONTINUE        
C        
C     COUNT NUMBER OF SUBCASES (NC) ON CASECC        
C        
      CALL GOPEN (CASESS,Z(BUF2),RDREW)        
      NSKIP = 1        
  130 CALL FREAD (CASESS,CC,2,1)        
      NSKIP = NSKIP + 1        
      IF (CC(1) .NE. CASECC(1)) GO TO 130        
      IF (CC(2) .NE. CASECC(2)) GO TO 130        
      NC = 0        
  140 CALL FWDREC (*150,CASESS)        
      NC = NC + 1        
      GO TO 140        
  150 CALL REWIND (CASESS)        
      IZ(5) = NC        
C        
C     GET NUMBER OF LOAD VECTORS FOR EACH SUBSTRUCTURE FROM LODS        
C        
      CALL SFETCH (FSS,LODS,SRD,RC)        
      IF (RC .EQ. 1) GO TO 160        
      CALL SMSG (RC-2,LODS,FSS)        
      GO TO 9200        
  160 J = 1        
      CALL SJUMP (J)        
      DO 170 I = 1,NS        
      CALL SUREAD (Z(3*I+5),1,NWDS,RC)        
  170 CALL SJUMP (J)        
C        
C     SOLN GROUP 0 COMPLETE.  WRITE IT ON SCR1        
C        
      J = 3        
      CALL GOPEN (SCR1,Z(BUF3),WRTREW)        
      CALL WRITE (SCR1,Z,3*NS+5,1)        
C        
C     COMPRESS SUBSTRUCTURE NAMES AT TOP OF OPEN CORE        
C        
      DO 180 I = 1,NS        
      IZ(2*I-1) = IZ(3*I+3)        
  180 IZ(2*I  ) = IZ(3*I+4)        
C        
C     PREPARE TO LOOP OVER ALL SUBCASES        
C        
      ICASE = 2*NS + 1        
      ILODS = ICASE + 166        
      IF (ILODS .GT. LCORE) GO TO 9008        
      LODSIN= 0        
      NLODS = ILODS - 1        
      FILE  = CASESS        
      DO 190 I = 1,NSKIP        
  190 CALL FWDREC (*9002,CASESS)        
      NOLDC = 1        
      CALL PRELOC (*195,Z(BUF1),GEOM4)        
      CALL LOCATE (*195,Z(BUF1),LOADC,I)        
      NOLDC = 0        
C        
C     BEGIN SUBCASE LOOP.  FOR EACH SUBCASE, BUILD ONE GROUP OF SOLN    
C        
  195 DO 390 ISC = 1,NC        
      CALL FREAD (CASESS,Z(ICASE),166,0)        
      NLDS = 0        
      IF (IZ(ICASE+15) .NE. 0) GO TO 310        
      FILE = CASESS        
      CALL FWDREC (*9002,CASESS)        
      FILE = GEOM4        
C        
C     PROCESS REGULAR SUBCASE.  IF LODS ITEM NOT IN CORE, GET IT.       
C        
      IF (IZ(ICASE+3) .EQ. 0) GO TO 300        
      IF (NOLDC  .EQ. 1) GO TO 300        
      IF (LODSIN .EQ. 1) GO TO 205        
      CALL SFETCH (FSS,LODS,SRD,RC)        
      I = 1        
      CALL SJUMP (I)        
      I = ILODS        
      DO 200 J = 1,NS        
      CALL SUREAD (Z(I),1,NWDS,RC)        
      NLODS = I+IZ(I)        
      IF (NLODS .GT. LCORE) GO TO 9008        
      CALL SUREAD (Z(I+1),-1,NWDS,RC)        
      I = NLODS + 1        
  200 CONTINUE        
      LODSIN = 1        
C        
C     LODS ITEM IN CORE.  FIND MATCH ON LOADC CARD WITH LOAD SET ID     
C     FROM CASECC        
C        
  205 JSOLN = NLODS + 2        
  210 CALL READ (*9002,*300,GEOM4,LOD,2,0,NWDS)        
      IF (LOD(1) .EQ. IZ(ICASE+3)) GO TO 230        
  220 CALL FREAD (GEOM4,LOD,4,0)        
      IF (LOD(4) .EQ. -1) GO TO 210        
      GO TO 220        
C        
C     FOUND MATCH ON LOADC CARD        
C        
  230 SFAC = CLOD(2)        
C        
C     LOOP OVER BASIC SUBSTRUCTURES ON THE LOADC CARD        
C        
  240 CALL FREAD (GEOM4,LOD,4,0)        
      IF (LOD(4)  .EQ.    -1) GO TO 290        
      IF (JSOLN+1 .GT. LCORE) GO TO 9008        
C        
C     FIND BASIC SUBSTRUCTURE NUMBER BY MATCHING ITS NAME WITH THOSE    
C     FROM EQSS.  THEN DETERMINE LOAD VECTOR NUMBER BY MATCHING THE     
C     BASIC SUBSTRUCTURE LOAD SET ID WITH THOSE IN LODS DATA IN CORE.   
C        
      DO 245 I = 1,NS        
      IF (LOD(1) .NE. IZ(2*I-1)) GO TO 245        
      K = I        
      IF (LOD(2) .EQ. IZ(2*I)) GO TO 250        
  245 CONTINUE        
      WRITE (NOUT,6315) UWM,LOD(1),LOD(2),LOD(3),FSS        
  250 N = 0        
      I = ILODS        
      J = 1        
  260 IF (J .EQ. K) GO TO 265        
      N = N + IZ(I)        
      I = I + IZ(I) + 1        
      J = J + 1        
      GO TO 260        
  265 J = IZ(I)        
      DO 270 K = 1,J        
      N = N + 1        
      IF (IZ(I+K) .EQ. LOD(3)) GO TO 280        
  270 CONTINUE        
      WRITE (NOUT,6316) UWM,LOD(3),LOD(1),LOD(2),FSS        
C        
C     BUILD SOLN GROUP IN OPEN CORE FOLLOWING LODS DATA        
C        
  280 IZ(JSOLN ) = N        
      Z(JSOLN+1) = SFAC*CLOD(4)        
      JSOLN = JSOLN + 2        
      NLDS  = NLDS  + 1        
      GO TO 240        
  290 IZ(NLODS+1) = NLDS        
      JSOLN = NLODS + 1        
      GO TO 385        
C        
C     NO LOADS FOR THIS SUBCASE        
C        
  300 NLDS = 0        
      GO TO 290        
C        
C     PROCESS SYMCOM OR SUBCOM SUBCASE        
C        
C     READ SYMSEQ OR SUBSEQ INTO OPEN CORE AT ISEQ        
C        
  310 LCC   = IZ(ICASE+165)        
      LSKIP = 167 - LCC        
      CALL FREAD (CASESS,0,LSKIP,0)        
      CALL FREAD (CASESS,LSEM,1,0)        
  320 IF (LSEM+NLODS .LT. LCORE) GO TO 340        
      IF (LODSIN .EQ. 0) GO TO 9008        
C        
C     SHORT OF CORE.  WIPE OUT LODS DATA AND RE-USE SPACE        
C        
  330 LODSIN = 0        
      NLODS  = ILODS - 1        
      GO TO 320        
  340 ISEQ = NLODS + 1        
      CALL FREAD (CASESS,Z(ISEQ),LSEM,1)        
C        
C     READ THE PREVIOUS LSEM GROUPS OF SOLN INTO OPEN CORE FOLLOWING SEQ
C        
      JSOLN = ISEQ + LSEM        
      K = JSOLN + 1        
      CALL CLOSE (SCR1,EOFNRW)        
      FILE = SCR1        
      CALL OPEN (*9001,SCR1,Z(BUF3),RD)        
      NREC = 1        
      NLDS = 0        
      DO 380 I = 1,LSEM        
  342 DO 344 J = 1,NREC        
  344 CALL BCKREC (SCR1)        
      CALL FREAD (SCR1,N,1,0)        
      NREC = 2        
      IF (N .LT. 0) GO TO 342        
      IF (K+2*N-1 .LT. LCORE) GO TO 360        
      IF (LODSIN .EQ. 0) GO TO 9008        
C        
C     SHORT OF CORE.  REPOSITION CASESS, WIPE OUT LODS DATA, AND TRY    
C     AGAIN        
C        
      CALL BCKREC (CASESS)        
      CALL FREAD (CASESS,0,-166,0)        
      GO TO 330        
  360 CALL FREAD (SCR1,Z(K),2*N,1)        
C        
C     SCALE LOAD FACTORS BY SYMSEQ OR SUBSEQ FACTORS        
C        
      DO 370 J = 1,N        
  370 Z(K+2*J-1) = Z(ISEQ+LSEM-I)*Z(K+2*J-1)        
      K = K + 2*N        
      NLDS = NLDS + N        
  380 CONTINUE        
      IZ(JSOLN) = -NLDS        
C        
C     COMBINATION GROUP COMPLETE.  REPOSITION SCR1        
C        
      FILE = SCR1        
  381 CALL FWDREC (*382,SCR1)        
      GO TO 381        
  382 CALL SKPFIL (SCR1,-1)        
      CALL CLOSE (SCR1,NOREW)        
      CALL OPEN (*9001,SCR1,Z(BUF3),WRT)        
C        
C     GROUP COMPLETE IN CORE.  SORT ON LOAD VECTOR NUMBERS        
C        
  385 CALL SORT (0,0,2,1,Z(JSOLN+1),2*NLDS)        
C        
C     WRITE GROUP ON SCR1 AND POSITION GEOM4 TO BEGINNING OF LOADC CARDS
C        
      CALL WRITE (SCR1,Z(JSOLN),2*NLDS+1,1)        
      IF (NOLDC .EQ. 1) GO TO 390        
      CALL BCKREC (GEOM4)        
      CALL FREAD (GEOM4,0,-3,0)        
C        
C     END OF LOOP OVER SUBCASES        
C        
  390 CONTINUE        
      CALL CLOSE (CASESS,REW)        
      CALL CLOSE (GEOM4,REW)        
      CALL CLOSE (SCR1,REW)        
C        
C     COPY SOLN FROM SCR1 TO SOF        
C        
      CALL GOPEN (SCR1,Z(BUF1),RDREW)        
      RC = 3        
      CALL SFETCH (FSS,SOLN,SWRT,RC)        
  392 CALL READ (*396,*394,SCR1,Z,LCORE,1,NWDS)        
      GO TO 9008        
  394 CALL SUWRT (Z,NWDS,EOG)        
      GO TO 392        
  396 CALL CLOSE (SCR1,REW)        
C        
C     FINISH        
C        
      CALL SUWRT (0,0,EOI)        
  440 CONTINUE        
      RETURN        
C        
C     DIAGNOSTICS        
C        
 6315 FORMAT (A25,' 6315, RCOVR MODULE IS UNABLE TO FIND SUBSTRUCTURE ',
     1       2A4,' AMONG THOSE ON EQSS.' /32X,'LOAD SET',I9,        
     2       ' FOR THAT SUBSTRUCTURE WILL BE IGNORED IN CREATING', /32X,
     3       'THE SOLN ITEM FOR FINAL SOLUTION STRUCTURE ',2A4)        
 6316 FORMAT (A25,' 6316, RCOVR MODULE IS UNABLE TO FIND LOAD SET',I9,  
     1       ' FOR SUBSTRUCTURE ',2A4, /32X,'AMONG THOSE ON LODS.  ',   
     2       'IT WILL BE IGNORED IN CREATING THE SOLN ITEM FOR FINAL',  
     3       /32X,'SOLUTION STRUCTURE ',2A4)        
C        
 9001 N = 1        
      GO TO 9100        
 9002 N = 2        
      GO TO 9100        
 9008 N = 8        
 9100 CALL MESAGE (N,FILE,NAME)        
 9200 CALL SOFCLS        
      IOPT = -1        
      CALL CLOSE (CASESS,REW)        
      CALL CLOSE (GEOM4,REW)        
      CALL CLOSE (SCR1,REW)        
C        
      RETURN        
      END        
