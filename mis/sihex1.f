      SUBROUTINE SIHEX1 (TYPE,STRSPT,NIP)        
C        
C     PHASE 1 STRESS ROUTINE FOR IHEX1, IHEX2, AND IHEX3 ELEMENTS       
C        
C     TYPE = 1    IHEX1        
C     TYPE = 2    IHEX2        
C     TYPE = 3    IHEX3        
C        
C     THE EST ENTRIES ARE        
C        
C     NAME  ---------INDEX---------   DESCRIPTION        
C            IHEX1   IHEX2   IHEX3        
C        
C     EID        1       1       1    ELEMENT ID NO.        
C     SIL      2-9    2-21    2-33    SCALAR INDEX LIST        
C     MID       10      22      34    MATERIAL ID NO.        
C     CID       11      23      35    MATERIAL COORD. SYSTEM ID NO.     
C     NIP       12      24      36    NO. INTEGRATION POINTS PER EDGE   
C     MAXAR     13      25      37    MAX ASPECT RATIO        
C     ALFA      14      26      38    MAX ANGLE FOR NORMALS        
C     BETA      15      27      39    MAX ANGLE FOR MIDSIDE POINTS      
C     BGPDT  16-47  28-107  40-167    BASIC GRID POINT DATA        
C     GPT    48-55 108-127 168-199    GRID POINT TEMPERATURES        
C        
C     PHIOUT (ESTA) CONTAINS THE FOLLOWING WHERE NGP IS THE NUMBER      
C     OF GRID POINTS        
C        
C     ELEMENT ID        
C     NGP SIL NUMBERS        
C     NGP VALUES OF THE SHAPE FUNCTIONS AT THIS STRESS POINT        
C     REFERENCE TEMPERATURE        
C     6 THERMAL STRESS COEFFICIENTS        
C     NGP, 6 BY 3 MATRICES, RELATING STRESS TO DISPLACEMENTS AT THIS    
C          STRESS POINT (STORED ROW-WISE)        
C        
      LOGICAL         TDEP     ,ANIS       ,RECT       ,MTDEP        
      INTEGER         CID      ,BGPID      ,TYPE       ,IEST(1)    ,    
     1                EID      ,IPHIO(1)   ,STRSPT     ,ITAB(3,64) ,    
     2                IB(46)        
      REAL            NU       ,JACOB      ,DSHPB(3,32),BXYZ(3)    ,    
     1                GAUSS(8) ,S(4)       ,GMAT(36)   ,STORE(18)       
      CHARACTER       UFM*23   ,UWM*25        
      COMMON /XMSSG / UFM      ,UWM        
      COMMON /SYSTEM/ SYSBUF   ,IPRNT      ,JUNK(7)    ,MTEMP        
      COMMON /MATIN / MID      ,INFLAG     ,TEMP        
      COMMON /MATOUT/ E        ,G          ,NU         ,RHO        ,    
     1                ALPHA    ,TREF       ,SPACE(19)  ,MTDEP        
      COMMON /MATISO/ BUFM6(46)        
      COMMON /SDR2X5/ EST(100) ,PHIOUT(649)        
      COMMON /SDR2X6/ CID      ,BGPID(32)  ,EID        ,BGPDT(3,32),    
     1                GPT(32)  ,JACOB(3,3) ,DSHP(3,32) ,DETJ       ,    
     2                D        ,E1         ,E2         ,E3         ,    
     3                T(3,3)   ,NGP        ,SGLOB(18)        
      EQUIVALENCE     (EST(1),IEST(1),DSHPB(1,1)),        
     1                (PHIOUT(1),IPHIO(1)),(EST(97),IDXYZ),        
     2                (EST(98),BXYZ(1))   ,(IB(1),BUFM6(1))        
      DATA    GAUSS/  .57735027, .55555556, .77459667, .88888889 ,      
     1                .34785485, .86113631, .65214515, .33998104 /      
C        
      IF (STRSPT .EQ. 0) STRSPT = STRSPT + 1        
      IF (STRSPT .GT. 1) GO TO 505        
C        
C     MOVE EST DATA INTO /SDR2X6/, /MATIN/, AND PHIOUT        
C        
      EID = IEST(1)        
      NGP = 12*TYPE - 4        
      MID = IEST(NGP+2)        
      CID = IEST(NGP+3)        
      NIP = IEST(NGP+4)        
      IF (NIP .EQ. 0) NIP = TYPE/2 + 2        
C        
C     FOR STRESS COMPUTATION, SET NUMBER OF STRESS POINTS TO 2        
C     NUMBER OF GAUSS POINTS) TO CUT DOWN ON AMOUNT OF INFO ON ESTA     
C        
      NIP = 2        
      L   = 0        
      DO 5 I = 1,NIP        
      DO 5 J = 1,NIP        
      DO 5 K = 1,NIP        
      L   = L + 1        
      ITAB(1,L) = I        
      ITAB(2,L) = J        
      ITAB(3,L) = K        
    5 CONTINUE        
      DO 10 I = 1,NGP        
      GPT(  I) = EST (5*NGP+7+I)        
      BGPID(I) = IEST(NGP+4+4*I)        
      DO 10 J = 1,3        
      BGPDT(J,I) = EST(NGP+4+4*I+J)        
   10 CONTINUE        
      PHIOUT(1) = EST(1)        
      DO 20 I = 1,NGP        
   20 PHIOUT(I+1) = EST(I+1)        
C        
C     FETCH MATERIAL PROPERTIES        
C        
C     CHANGE FOR GENERAL ANISOTROPIC MATERIAL        
C        
C     TEST FOR ANISOTROPIC MATERIAL        
C        
      ANIS   = .FALSE.        
      INFLAG = 10        
C        
C     TEST FOR RECTANGULAR COORDINATE SYSTEM IN WHICH ANISOTROPIC       
C     MATERIAL IS DEFINED        
C        
      RECT = .TRUE.        
      TDEP = .TRUE.        
C        
      DO 60 I = 2,NGP        
      IF (GPT(I) .NE. GPT(1)) GO TO 70        
   60 CONTINUE        
      TDEP = .FALSE.        
   70 TEMP = GPT(1)        
      CALL MAT (EID)        
      IF (IB(46) .EQ. 6) ANIS = .TRUE.        
      TREF = BUFM6(44)        
      IF (.NOT.MTDEP) TDEP = .FALSE.        
C        
C     IF ISOTROPIC, TEMPERATURE INDEPENDENT MATERIAL, COMPUTE CONSTANTS 
C        
      IF (TDEP) GO TO 500        
      IF (ANIS) GO TO 490        
      IF (IB(46) .NE. 0) GO TO 480        
      WRITE  (IPRNT,470) UWM,MID,EID        
  470 FORMAT (A25,' 4005. AN ILLEGAL VALUE OF -NU- HAS BEEN SPECIFIED', 
     1       ' UNDER MATERIAL ID =',I10,' FOR ELEMENT ID =',I10, /32X,  
     2       'NU = 0.333 ASSUMED FOR STRESS COMPUTATION')        
      E1 = 1.5*E        
      E2 = 0.75*E        
      E3 = 0.375*E        
      GO TO 490        
  480 E1 = BUFM6(1)        
      E2 = BUFM6(2)        
      E3 = BUFM6(22)        
      ALPHA = BUFM6(38)        
      GO TO 500        
C        
C     IF MATERIAL IS ANISOTROPIC, DEFINED IN A RECTANGULAR        
C     COORDINATE SYSTEM, AND NOT TEMPERATURE DEPENDENT, TRANSFORM       
C     IT TO THE BASIC SYSTEM.        
C        
  490 IF (.NOT.RECT) GO TO 500        
C        
C     ADD CODE TO TRANSFORM GENERAL ANISOTROPIC MATERIAL        
C     TO BASIC COORDINATE SYSTEM HERE.        
C        
      DO 491 IJK = 1,36        
  491 GMAT(IJK) = BUFM6(IJK)        
C        
C     INITIALIZATION TO FIND GAUSS POINT COORDINATES        
C        
  505 CONTINUE        
  500 NIPM1 = NIP - 1        
      GO TO (510,520,530), NIPM1        
  510 S(1) = GAUSS(1)        
      S(2) =-GAUSS(1)        
      GO TO  540        
  520 S(1) = GAUSS(3)        
      S(2) = 0.        
      S(3) =-GAUSS(3)        
      GO TO  540        
  530 S(1) = GAUSS(6)        
      S(2) = GAUSS(8)        
      S(3) =-GAUSS(8)        
      S(4) =-GAUSS(6)        
  540 IF (STRSPT .EQ. NIP**3+1) GO TO 541        
      L = ITAB(1,STRSPT)        
      X = S(L)        
      L = ITAB(2,STRSPT)        
      Y = S(L)        
      L = ITAB(3,STRSPT)        
      Z = S(L)        
      GO TO 542        
  541 X = 0.        
      Y = 0.        
      Z = 0.        
  542 CONTINUE        
C        
C     GENERATE SHAPE FUNCTIONS AND JACOBIAN MATRIX INVERSE        
C        
      CALL IHEXSS (TYPE,PHIOUT(NGP+2),DSHP,JACOB,DETJ,EID,X,Y,Z,BGPDT)  
      IF (DETJ .NE. 0.0) GO TO 605        
C        
C     FALL HERE IF JACOBIAN MATRIX SINGULAR (BAD ELEMENT)        
C        
      J = NGP*19 + 7        
      DO 600 I = 1,J        
  600 PHIOUT(NGP+1+I) = 0.0        
      RETURN        
C        
C     COMPUTE STRAIN-DISPLACEMENT RELATIONS        
C        
C     REVERSE CALLING SEQUENCE SINCE MATRICES ARE COLUMN STORED        
C        
  605 CALL GMMATS (DSHP,NGP,3,0,JACOB,3,3,0,DSHPB)        
C        
C     IF MATERIAL IS TEMPERATURE DEPENDENT, MUST COMPUTE TEMPERATURE    
C     AT THIS STRESS POINT AND FETCH MATERIAL PROPERTIES AGAIN        
C        
      IF (.NOT.TDEP) GO TO 620        
      TEMP = 0.0        
      DO 610 J = 1,NGP        
  610 TEMP = TEMP + GPT(J)*PHIOUT(NGP+1+J)        
      CALL MAT (EID)        
      IF (ANIS) GO TO 630        
      IF (IB(46) .NE. 0) GO TO 615        
      WRITE (IPRNT,470) UWM,MID,EID        
      E1 = 1.5*E        
      E2 = 0.75*E        
      E3 = 0.375*E        
      GO TO 640        
  615 E1 = BUFM6(1)        
      E2 = BUFM6(2)        
      E3 = BUFM6(22)        
      ALPHA = BUFM6(38)        
      GO TO 640        
C        
C     IF MATERIAL IS ANISOTROPIC AND NOT DEFINED IN RECTANGJLAR        
C     COORDINATE SYSTEM, TRANSFORM IT TO BASIC COORDINATE SYSTEM AT     
C     THIS STRESS POINT.        
C        
C        
C     IN THIS VERSION, ANISOTROPIC PROPERTIES MUST BE RECTANGULAR       
C     JUST STORE G MATRIX        
C     ===========================================================       
C        
C     THIS CODE MUST BE COMPLETED WHEN GENERAL ANISOTROPIC MATERIAL IS  
C     ADDED.        
C        
  620 IF (.NOT.ANIS) GO TO 640        
  630 CONTINUE        
      DO 635 IJK = 1,36        
  635 GMAT(IJK) = BUFM6(IJK)        
C        
C     INSERT GLOBAL TO BASIC TRANSFORMATION OPERATIONS HERE FOR        
C     ANISOTROPIC MATERIAL.        
C        
C     MATERIAL HAS BEEN EVALUATED AT THIS STRESS POINT WHEN GET TO HERE 
C        
C     TEMPERATURE TO STRESS VECTOR        
C        
  640 PHIOUT(2*NGP+2) = TREF        
      IF (ANIS) GO TO 660        
C        
C     ISOTROPIC CASE        
C        
      DO 650 J = 1,3        
      PHIOUT(2*NGP+2+J) = -ALPHA*(E1+2.0*E2)        
      PHIOUT(2*NGP+5+J) = 0.0        
  650 CONTINUE        
      GO TO 670        
C        
C     ANISOTROPIC CASE        
C        
C     ADD CODE WHEN ANISOTROPIC MATERIAL BECOMES AVAILABLE        
C        
  660 CONTINUE        
      CALL GMMATS (GMAT,6,6,0,BUFM6(38),6,1,0,PHIOUT(2*NGP+3))        
      DO 661 IJK = 1,6        
      IS = 2*NGP + 2 + IJK        
      PHIOUT(IS) = -PHIOUT(IS)        
  661 CONTINUE        
C        
C     DISPLACEMENT TO STRESS MATRICES        
C        
  670 DO 840 I = 1,NGP        
      IS = 2*NGP + 8 + 18*(I-1)        
C        
C     ROW-STORED        
C        
      IF (ANIS) GO TO 680        
C        
C     ISOTROPIC CASE        
C        
      PHIOUT(IS+ 1) = E1*DSHPB(1,I)        
      PHIOUT(IS+ 2) = E2*DSHPB(2,I)        
      PHIOUT(IS+ 3) = E2*DSHPB(3,I)        
      PHIOUT(IS+ 4) = E2*DSHPB(1,I)        
      PHIOUT(IS+ 5) = E1*DSHPB(2,I)        
      PHIOUT(IS+ 6) = E2*DSHPB(3,I)        
      PHIOUT(IS+ 7) = E2*DSHPB(1,I)        
      PHIOUT(IS+ 8) = E2*DSHPB(2,I)        
      PHIOUT(IS+ 9) = E1*DSHPB(3,I)        
      PHIOUT(IS+10) = E3*DSHPB(2,I)        
      PHIOUT(IS+11) = E3*DSHPB(1,I)        
      PHIOUT(IS+14) = E3*DSHPB(3,I)        
      PHIOUT(IS+15) = E3*DSHPB(2,I)        
      PHIOUT(IS+16) = E3*DSHPB(3,I)        
      PHIOUT(IS+18) = E3*DSHPB(1,I)        
      PHIOUT(IS+12) = 0.0        
      PHIOUT(IS+13) = 0.0        
      PHIOUT(IS+17) = 0.0        
      GO TO 690        
C        
C     ANISOTROPIC CASE        
C        
C     ADD CODE WHEN GENERAL ANISOTROPIC MATERIAL BECOMES AVAILABLE      
C        
  680 CONTINUE        
      DO 681 IJK = 1,18        
  681 STORE(IJK) = 0.        
      STORE( 1) = DSHPB(1,I)        
      STORE( 5) = DSHPB(2,I)        
      STORE( 9) = DSHPB(3,I)        
      STORE(10) = DSHPB(2,I)        
      STORE(11) = DSHPB(1,I)        
      STORE(14) = DSHPB(3,I)        
      STORE(15) = DSHPB(2,I)        
      STORE(16) = DSHPB(3,I)        
      STORE(18) = DSHPB(1,I)        
C        
      CALL GMMATS (GMAT(1),6,6,0,STORE(1),6,3,0,PHIOUT(IS+1))        
C        
C     POST-MULTIPLY BY GLOBAL TO BASIC TRANSFORMATION MATRIX,        
C     IF NECESSARY        
C        
  690 IF (BGPID(I) .EQ. 0) GO TO 840        
      IDXYZ = BGPID(I)        
      DO 820 K = 1,3        
  820 BXYZ(K) = BGPDT(K,I)        
C        
C     FETCH TRANSFORMATION AND USE IT        
C        
      CALL TRANSS (IDXYZ,T)        
      CALL GMMATS (PHIOUT(IS+1),6,3,0,T,3,3,0,SGLOB)        
      DO 830 J = 1,18        
  830 PHIOUT(IS+J) = SGLOB(J)        
  840 CONTINUE        
      IPHIO(20*NGP+9) = NIP        
      NWDNOW = 20*NGP + 9        
      NWDISO = 649 - NWDNOW        
      IF (NWDISO .EQ. 0) RETURN        
      DO 850 I = 1,NWDISO        
      ISUB = NWDNOW + I        
  850 PHIOUT(ISUB) = 0.        
      RETURN        
      END        
