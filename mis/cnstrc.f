      SUBROUTINE CNSTRC (GP,ELE,BUF,MAX)        
C        
C     THIS SUBROUTINE BUILDS THE ELSETS FILE        
C     THIS SUBROUTINE IS CALLED ONLY BY DPLTST, WHICH IS THE DRIVER OF  
C     DMAP MODULE PLTSET        
C     THE SUBROUITNE PLTSET OF THE PLOT MODULE HAS NOTHING TO DO WITH   
C     THIS SUBROUTINE        
C        
C     REVISED 10/1990 BY G.CHAN/UNISYS TO INCLUDE OFFSET FOR BAR, TRIA3 
C     AND QUAD4 ELEMENTS        
C        
      INTEGER         AE       ,B1       ,B2       ,B3       ,BUF(1)  , 
     1                BUFSIZ   ,ELE(1)   ,ELID     ,ERR(2)   ,ETYPE   , 
     2                EXGP     ,GP(1)    ,GPT      ,GPTS(32) ,OUTNOR  , 
     3                OUTREW   ,REW      ,SETID    ,SETNUM   ,SIGN    , 
     4                TYPE(50) ,NAME(2)  ,MSG1(14) ,EID(2)   ,OFFSET  , 
     5                BR       ,T3       ,Q4       ,OFF(6)        
      COMMON /BLANK / NGP      ,NSETS    ,SKP1(8)  ,SKP2     ,EXGPID  , 
     1                SKP3(8)  ,MERR     ,SKP4     ,GRID     ,ECT2    , 
     2                SKP5(6)  ,MSET     ,ECT1        
      COMMON /SYSTEM/ BUFSIZ        
      COMMON /NAMES / RD       ,INPREW   ,OUTNOR   ,OUTREW   ,REW     , 
     1                NOREW        
      COMMON /GPTA1 / NTYPS    ,LAST     ,INCR     ,NE(1)        
      EQUIVALENCE     (EID(1)  ,ELID)        
      DATA    NAME  / 4H CNS   ,4HTRC  / ,AE   /    72       /        
      DATA    NMSG1 / 14       /        
      DATA    MSG1  / 4H(33X   ,4H,44H   ,4HNO P   ,4HLOTA   ,4HBLE   , 
     1                4HSTRU   ,4HCTUR   ,4HAL E   ,4HLEME   ,4HNTS   , 
     2                4HEXIS   ,4HT IN   ,4H SET   ,4H,I8)   /        
      DATA    BR, T3, Q4       /2HBR     ,2HT3     ,2HQ4     /        
C        
      B1 = 1        
      B2 = B1 + BUFSIZ        
      B3 = B2 + BUFSIZ        
      CALL GOPEN (MSET,BUF(B3),INPREW)        
      CALL GOPEN (ECT2,BUF(B2),OUTREW)        
C        
      DO 450 SETNUM = 1,NSETS        
      CALL FREAD (MSET,SETID,1,0)        
      DO 10 I = 1,NGP        
      GP(I) = 0        
   10 CONTINUE        
C        
C     READ THE EXPLICIT ELEMENT NUMBERS IN THIS SET.        
C        
      CALL FREAD (MSET,NEL,1,0)        
      IF (NEL .GE. MAX) CALL MESAGE (-8,0,NAME)        
      ELE(NEL+1) = 0        
      CALL FREAD (MSET,ELE,NEL,0)        
C        
C     READ THE ELEMENT TYPES TO BE INCLUDED OR EXCLUDED IN THIS SET.    
C        
      CALL FREAD (MSET,NTYPES,1,0)        
      CALL FREAD (MSET,TYPE,NTYPES,0)        
C        
C     GENERATE AN ECT FOR THE ELEMENTS INCLUDED IN THIS SET.        
C        
      CALL GOPEN (ECT1,BUF(B1),INPREW)        
   20 CALL READ (*300,*300,ECT1,ETYPE,1,0,I)        
C        
C     CHECK WHETHER OR NOT THIS ELEMENT TYPE IS TO BE EXCLUDED.        
C        
      MTYPE = -1        
      LABGP =  1        
      IF (ETYPE .EQ. AE) LABGP = -2        
      IF (NTYPES .EQ. 0) GO TO 50        
      DO 30 I = 1,NTYPES,2        
      IF (-ETYPE .EQ. TYPE(I)) GO TO 40        
   30 CONTINUE        
      GO TO 50        
   40 MTYPE = TYPE(I+1)        
C        
C     THIS ELEMENT TYPE MAY BE INCLUDED AS A TYPE AND/OR SOME OF THEM   
C     MAY BE INCLUDED SPECIFICALLY. READ -NGPPE- = NUMBER OF GRID       
C     POINTS PER ELEMENT FOR THIS TYPE.        
C        
   50 CALL FREAD (ECT1,NGPPE,1,0)        
      IF (NGPPE .LE. 0) GO TO 290        
      IDX    = (ETYPE-1)*INCR        
      NELTYP = 0        
      NE16   = NE(IDX+16)        
      OFFSET = 0        
      IF (NE16 .EQ. BR) OFFSET = 6        
      IF (NE16.EQ.T3 .OR. NE16.EQ.Q4) OFFSET = 1        
C        
C     CHECK WHETHER OR NOT THIS ELEMENT TYPE IS TO BE INCLUDED.        
C        
      IF (NTYPES.EQ.0 .OR. MTYPE.GE.0) GO TO 70        
      DO 60 I = 1,NTYPES,2        
      IF (ETYPE.EQ.TYPE(I) .OR. TYPE(I).EQ.NTYPS+1) GO TO 200        
   60 CONTINUE        
C        
C     NOW CHECK WHETHER OR NOT ANY OF THE ELEMENTS OF THIS TYPE ARE     
C     EXPLICITLY INCLUDED. PUT ALL SUCH ON THE NEW ECT (ECT2).        
C        
   70 CALL READ (*280,*280,ECT1,EID,2,0,I)        
      CALL FREAD (ECT1,GPTS,NGPPE,0)        
      IF (OFFSET .NE. 0) CALL FREAD (ECT1,OFF,OFFSET,0)        
      IF (NEL .LE. 0) GO TO 70        
      M = 0        
      N = 1        
C        
C     FOR TYPES DELETED ONLY SEARCH LIST AFTER TYPE WAS KNOWN TO BE     
C     DELETED (2ND WORD OF TYPE)        
C        
      IF (MTYPE .GT. 0) N = MTYPE        
      IF (N   .GT. NEL) GO TO 110        
   80 CALL INTLST (ELE,N,SIGN,N1,N2)        
      IF (SIGN .LT. 0) GO TO 90        
      IF (ELID.GE.N1 .AND. ELID.LE.N2) M = 1        
      GO TO 100        
   90 IF (ELID.GE.N1 .AND. ELID.LE.N2) M = 0        
  100 IF (N .LE. NEL) GO TO 80        
  110 CONTINUE        
      IF (M      .EQ. 0) GO TO 70        
      IF (NELTYP .NE. 0) GO TO 120        
      CALL WRITE (ECT2,NE(IDX+16),1,0)        
      CALL WRITE (ECT2,NGPPE,1,0)        
  120 CALL WRITE (ECT2,EID,2,0)        
      CALL WRITE (ECT2,GPTS,NGPPE,0)        
      IF (OFFSET .NE. 0) CALL WRITE (ECT2,OFF,OFFSET,0)        
      NELTYP = NELTYP + 1        
      DO 130 I = 1,NGPPE        
      J = GPTS(I)        
      GP(J) = LABGP        
  130 CONTINUE        
C        
C     AERO ELEMENT - CENTER ONLY LABELED        
C        
      IF (ETYPE .EQ. AE) GP(J) = 1        
      GO TO 70        
C        
C     THIS ELEMENT TYPE IS TO BE INCLUDED, EXCEPT THE ONES EXPLICITLY   
C     EXCLUDED        
C        
C     ONLY SEARCH LIST AFTER TYPE WAS INCLUDED        
C        
  200 MTYPE = TYPE(I+1)        
  210 CALL READ (*280,*280,ECT1,EID,2,0,I)        
      CALL FREAD (ECT1,GPTS,NGPPE,0)        
      IF (OFFSET .NE. 0) CALL FREAD (ECT1,OFF,OFFSET,0)        
      IF (NEL .LE. 0) GO TO 250        
      M = 1        
      N = 1        
      IF (MTYPE .GT. 0) N = MTYPE        
      IF (N   .GT. NEL) GO TO 250        
  220 CALL INTLST (ELE,N,SIGN,N1,N2)        
      IF (SIGN .GT. 0) GO TO 230        
      IF (ELID.GE.N1 .AND. ELID.LE.N2) M = 0        
      GO TO 240        
  230 IF (ELID.GE.N1 .AND. ELID.LE.N2) M = 1        
  240 IF (N    .LE. NEL) GO TO 220        
      IF (M    .EQ.   0) GO TO 210        
  250 IF (NELTYP .NE. 0) GO TO 260        
      CALL WRITE (ECT2,NE(IDX+16),1,0)        
      CALL WRITE (ECT2,NGPPE,1,0)        
  260 CALL WRITE (ECT2,EID,2,0)        
      CALL WRITE (ECT2,GPTS,NGPPE,0)        
      IF (OFFSET .NE. 0) CALL WRITE (ECT2,OFF,OFFSET,0)        
      DO 270 I = 1,NGPPE        
      J = GPTS(I)        
      GP(J) = LABGP        
  270 CONTINUE        
C        
C     AERO ELEMENT - CENTER ONLY LABELED        
C        
      IF (ETYPE .EQ. AE) GP(J) = 1        
      NELTYP = NELTYP + 1        
      GO TO 210        
C        
C     END OF NEW ECT FOR THIS ELEMENT TYPE        
C        
  280 IF (NELTYP .GT. 0) CALL WRITE (ECT2,0,1,0)        
      GO TO 20        
C        
C     SKIP THIS ELEMENT TYPE (NON-EXISTENT)        
C        
  290 CALL FREAD (ECT1,0,0,1)        
      GO TO 20        
C        
C     END OF ECT FOR THIS ELEMENT SET        
C        
  300 CALL CLOSE (ECT1,REW)        
      CALL WRITE (ECT2,0,0,1)        
C        
C     FLAG ALL GRID POINTS TO BE EXCLUDED FROM A DEFORMED SHAPE.        
C        
      CALL FREAD (MSET,NGPTS,1,0)        
      IF (NGPTS .GE. MAX) CALL MESAGE (-8,0,NAME)        
      ELE(NGPTS+1) = 0        
      CALL FREAD (MSET,ELE,NGPTS,1)        
      IF (NGPTS .LE. 0) GO TO 400        
      CALL GOPEN (EXGPID,BUF(B1),INPREW)        
      DO 340 GPT = 1,NGP        
      CALL FREAD (EXGPID,EXGP,1,0)        
      CALL FREAD (EXGPID,INGP,1,0)        
      M = 0        
      N = 1        
  310 CALL INTLST (ELE,N,SIGN,N1,N2)        
      IF (SIGN .GT. 0) GO TO 320        
      IF (EXGP.GE.N1 .AND. EXGP.LE.N2) M = INGP        
      GO TO 330        
  320 IF (EXGP.GE.N1 .AND. EXGP.LE.N2) M = 0        
  330 IF (N .LE. NGPTS) GO TO 310        
      IF (M .EQ.     0) GO TO 340        
      IF (GP(M) .NE. -2) GP(M) = -GP(M)        
  340 CONTINUE        
      CALL CLOSE (EXGPID,REW)        
C        
C     GENERATE A GRID POINT LIST FOR THIS SET (CONVERT THE INTERNAL     
C     GRID POINT NUMBERS TO POINTERS TO THE GRID POINTS PECULIAR TO     
C     THIS SET)        
C        
  400 CALL GOPEN (GRID,BUF(B1),OUTNOR)        
      NGPTS = 0        
      DO 410 I = 1,NGP        
      IF (GP(I) .EQ. 0) GO TO 410        
      NGPTS = NGPTS+1        
      GP(I) = ISIGN(NGPTS,GP(I))        
  410 CONTINUE        
      IF (NGPTS .NE. 0) GO TO 420        
      ERR(1) = 1        
      ERR(2) = SETID        
      CALL WRTPRT (MERR,ERR,MSG1,NMSG1)        
C        
  420 CALL WRITE (GRID,NGPTS,1,0)        
      CALL WRITE (GRID,GP,NGP,0)        
      IF (SETNUM .NE. NSETS) CALL CLOSE (GRID,NOREW)        
  450 CONTINUE        
C        
C     ALL DONE. THE SET DEFINITION FILE (MSET) + THE SHORT ECT FILE     
C     (ECT1) WILL NOT BE NEEDED AGAIN.        
C        
      CALL CLSTAB (GRID,REW)        
      CALL CLSTAB (ECT2,REW)        
      CALL CLOSE  (MSET,REW)        
      RETURN        
      END        
