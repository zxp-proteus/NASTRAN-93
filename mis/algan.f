      SUBROUTINE ALGAN        
C        
      REAL            IX,IY,IXY,IPX,IPY,IXN,IYN,IXYN,IXD,IYD        
      DIMENSION       RLES(21),TCS(21),TES(21),ZZS(21),PERSPT(21),      
     1                ALPB(10,21),BLOCK(10,21),EPSLON(10,21),CCORD(21), 
     2                YS(21,70),YP(21,70),XP(21,70),XS(21,70),ZS(21,70),
     3                ZQ(21),TQ(21),BLAFOR(10,21),XCAMB(21,10),        
     4                THARR(21,10),TITLE(18),IDATA(24),RDATA(6)        
      COMMON /SYSTEM/ KSYSTM(90),LPUNCH        
      COMMON /UD3PRT/ IPRTC,ISTRML,IPGEOM        
      COMMON /UDSTR2/ NBLDES,STAG(21),CHORDD(21)        
      COMMON /CONTRL/ NANAL,NAERO,NARBIT,LOG1,LOG2,LOG3,LOG4,LOG5,LOG6  
      COMMON /UD3ANC/ EPZ(80,4),R(10,21),ZOUT(21),SS(100),X(100),       
     1                YPRIME(100),YSEMI(21,31),XSEMI(21,31),ZP(21,70),  
     2                ZSEMI(21,31),TITLE2(18),XHERE(10),XTEMP(100),     
     3                RAD(100),TEMP1(21),TEMP2(21),TEMP3(21),TEMP4(21), 
     4                ZR(21),B1(21),B2(21),PP(21),QQ(21),ZZ(21),RLE(21),
     5                TC(21),TE(21),CORD(21),DELX(21),DELY(21),S(21),   
     6                BS(21),XSEMJ(21,31),YSEMJ(21,31),ZSEMJ(21,31),    
     7                XSTA(21,10),RSTA(21,10),KPTS(21),SIGMA(100),      
     8                TANPHI(10,21),ZCAMB(21,10),YCAMB(21,10),        
     9                IFANGS(10),THETA(21,10),ALPHA(21,10)        
      EQUIVALENCE     (TITLE(1),TITLE2(1))        
C        
      PI = 4.0*ATAN(1.0)        
      C1 = 180.0/PI        
      CALL FREAD (LOG1,TITLE2,18,1)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,120) TITLE2        
 120  FORMAT (1H1,31X,'PROGRAM ALG - COMPRESSOR DESIGN - ANALYTIC MEAN',
     1       'LINE BLADE SECTION', /32X,65(1H*), //10X,5HTITLE,25X,1H=, 
     2       18A4)        
      CALL FREAD (LOG1,IDATA,17,1)        
      NLINES = IDATA(1)        
      NSTNS  = IDATA(2)        
      NZ     = IDATA(3)        
      NSPEC  = IDATA(4)        
      NPOINT = IDATA(5)        
      NBLADE = IDATA(6)        
      ISTAK  = IDATA(7)        
      IPUNCH = IDATA(8)        
      ISECN  = IDATA(9)        
      IFCORD = IDATA(10)        
      IFPLOT = IDATA(11)        
      IPRINT = IDATA(12)        
      ISPLIT = IDATA(13)        
      INAST  = IDATA(14)        
      IRLE   = IDATA(15)        
      IRTE   = IDATA(16)        
      NSIGN  = IDATA(17)        
      NBLDES = NBLADE        
      IF (IPRTC .EQ. 0) IPRINT = 3        
      IF (INAST.EQ.0 .AND. IPGEOM.NE.-1) INAST = -4        
      IF (IPRTC .EQ. 1) WRITE (LOG2,140) NLINES,NSTNS,NZ,NSPEC,NPOINT,  
     1    NBLADE,ISTAK,IPUNCH,ISECN,IFCORD,IFPLOT,IPRINT,ISPLIT,INAST,  
     2    IRLE,IRTE,NSIGN        
 140  FORMAT (10X,24HNUMBER OF STREAMSURFACES,6X,1H=,I3, /10X,18HNUMBER 
     1OF STATIONS,12X,1H=,I3, /10X,27HNUMBER OF CONSTANT-Z PLANES,3X,1H=
     2,I3, /10X,27HNUMBER OF BLADE DATA POINTS,3X,1H=,I3, /10X,31HNUMBER
     3 OF POINTS ON SURFACES  =,I3, /10X,29HNUMBER OF BLADES IN BLADE RO
     4W,1X,1H=,I3, /10X,5HISTAK,25X,1H=,I3, /10X,6HIPUNCH,24X,1H=,I3, /1
     50X,5HISECN,25X,1H=,I3,/,10X,6HIFCORD,24X,1H=,I3, /10X,6HIFPLOT,24X
     6,1H=,I3, /10X,6HIPRINT,24X,1H=,I3, /10X,6HISPLIT,24X,1H=,I3, /10X,
     75HINAST,25X,1H=,I3, /10X,4HIRLE,26X,1H=,I3, /10X,4HIRTE,26X,1H=,I3
     8, /10X,5HNSIGN,25X,1H=,I3)        
      CALL FREAD (LOG1,RDATA,5,1)        
      ZINNER = RDATA(1)        
      ZOUTER = RDATA(2)        
      SCALE  = RDATA(3)        
      STACKX = RDATA(4)        
      PLTSZE = RDATA(5)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,160) ZINNER,ZOUTER,SCALE,STACKX,    
     1                                   PLTSZE        
 160  FORMAT (/10X,6HZINNER,24X,1H=,F8.4, /10X,6HZOUTER,24X,1H=,F8.4, / 
     110X,5HSCALE,25X,1H=,F8.4, /10X,6HSTACKX,24X,1H=,F8.4, /10X,6HPLTSZ
     2E,24X,1H=,F8.4, //20X,36HSTREAMSURFACE GEOMETRY SPECIFICATION)    
      LNCT = 30        
      DO 300 I = 1,NSTNS        
      CALL FREAD (LOG1,IDATA,2,1)        
      KPTS(I)   = IDATA(1)        
      IFANGS(I) = IDATA(2)        
      KPT = KPTS(I)        
      DO 165 K = 1,KPT        
      CALL FREAD (LOG1,RDATA,2,1)        
      XSTA(K,I) = RDATA(1)        
 165  RSTA(K,I) = RDATA(2)        
      IF (KPTS(I) .GE. 2) GO TO 170        
      KPTS(I) = 2        
      XSTA(2,I) = XSTA(1,I)        
      RSTA(2,I) = RSTA(1,I) + 1.0        
 170  DO 180 J = 1,NLINES        
      CALL FREAD (LOG1,RDATA,2,1)        
      R(I,J)      = RDATA(1)        
 180  BLAFOR(I,J) = RDATA(2)        
      IDUM = KPTS(I)        
      IF (NLINES .GT. IDUM) IDUM = NLINES        
      IF (LNCT .LE. 54-IDUM) GO TO 210        
      IF (IPRTC .NE. 0) WRITE (LOG2,200)        
 200  FORMAT (1H1)        
      LNCT = 2        
 210  LNCT = LNCT + IDUM + 7        
      IF (INAST .NE. 0) GO TO 240        
      IF (IPRTC .EQ. 1)  WRITE (LOG2,220) I,KPTS(I),I,IFANGS(I)        
 220  FORMAT (/10X,'COMPUTING STATION',I3,5X,'NUMBER OF DESCRIBING ',   
     1        'POINTS=',I3,6X,7HIFANGS(,I2,2H)=,I3, //6X,'DESCRIPTION', 
     2        9X,'STREAMLINE',5X,5HRADII,/6X,1HX,9X,1HR,11X,6HNUMBER,//)
      DO 230 K = 1,IDUM        
      IF (IPRTC.EQ.1 .AND. K.LE.KPTS(I).AND.K.LE.NLINES)        
     1    WRITE (LOG2,260) XSTA(K,I),RSTA(K,I),K,R(I,K)        
      IF (IPRTC.EQ.1 .AND. K.LE.KPTS(I).AND.K.GT.NLINES)        
     1    WRITE (LOG2,270) XSTA(K,I),RSTA(K,I)        
      IF (IPRTC.EQ.1 .AND. K.GT.KPTS(I).AND.K.LE.NLINES)        
     1    WRITE (LOG2,280) K,R(I,K)        
 230  CONTINUE        
      IF (INAST .EQ. 0) GO TO 300        
 240  IF (IPRTC .EQ. 1) WRITE (LOG2,290) I,KPTS(I),I,IFANGS(I)        
      DO 250 K = 1,IDUM        
      IF (IPRTC.EQ.1 .AND. K.LE.KPTS(I).AND.K.LE.NLINES)        
     1    WRITE (LOG2,260) XSTA(K,I),RSTA(K,I),K,R(I,K),BLAFOR(I,K)     
      IF (IPRTC.EQ.1 .AND. K.LE.KPTS(I).AND.K.GT.NLINES)        
     1    WRITE (LOG2,270) XSTA(K,I),RSTA(K,I)        
      IF (IPRTC.EQ.1 .AND. K.GT.KPTS(I).AND.K.LE.NLINES)        
     1    WRITE (LOG2,280) K,R(I,K),BLAFOR(I,K)        
 250  CONTINUE        
 260  FORMAT (3X,F8.4,2X,F8.4,8X,I2,9X,F8.4,9X,F8.4)        
 270  FORMAT (3X,F8.4,2X,F8.4)        
 280  FORMAT (29X,I2,9X,F8.4,9X,F8.4)        
 290  FORMAT (/10X,'COMPUTING STATION',I3,5X,'NUMBER OF DESCRIBING ',   
     1       'POINTS=',I3,6X,7HIFANGS(,I2,2H)=,I3, //6X,'DESCRIPTION',  
     2       9X,'STREAMLINE',5X,5HRADII,9X,'DELTA PRESSURE', /6X,1HX,   
     3       9X,1HR,11X,6HNUMBER, //)        
 300  CONTINUE        
      SQ = 0.0        
      SB = 0.0        
      IF (ISECN.EQ.1 .OR. ISECN.EQ.3) GO TO 340        
      DO 305 ISBS = 1,NSPEC        
      S(ISBS)  = 0.0        
 305  BS(ISBS) = 0.0        
      IF (LNCT .LE. 54-NSPEC) GO TO 310        
      IF (IPRTC .NE. 0) WRITE (LOG2,200)        
      LNCT = 1        
 310  LNCT = LNCT + NSPEC + 6        
      DO 315 J = 1,NSPEC        
      CALL FREAD (LOG1,RDATA,6,1)        
      ZR(J)  = RDATA(1)        
      B1(J)  = RDATA(2)        
      B2(J)  = RDATA(3)        
      PP(J)  = RDATA(4)        
      QQ(J)  = RDATA(5)        
      RLE(J) = RDATA(6)        
      CALL FREAD (LOG1,RDATA,6,1)        
      TC(J)   = RDATA(1)        
      TE(J)   = RDATA(2)        
      ZZ(J)   = RDATA(3)        
      CORD(J) = RDATA(4)        
      DELX(J) = RDATA(5)        
 315  DELY(J) = RDATA(6)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,330) (ZR(J),B1(J),B2(J),PP(J),QQ(J),
     1    RLE(J),TC(J),TE(J),ZZ(J),CORD(J),DELX(J),DELY(J),J=1,NSPEC)   
 330  FORMAT (/20X,'SECTION GEOMETRY SPECIFICATION', //10X,'STREAMLINE',
     1       '  INLET',5X,6HOUTLET,4X,6HY2 LE/,4X,6HY2 TE/,3X,48HLE RADI
     2US MAX THICK TE THICK  POINT OF  CHORD OR,3X,7HX STACK,3X,7HY STAC
     3K, /11X,6HNUMBER,5X,5HANGLE,5X,5HANGLE,3X,19HMAX VALUE MAX VALUE,3
     4X,6H/CHORD,4X,6H/CHORD,3X,8H/2*CHORD,2X,18HMAX THICK AXIAL CD,4X,6
     5HOFFSET,4X,6HOFFSET, //,(10X,F7.2,3X,F8.3,F10.3,2F10.4,3F10.5,    
     62F10.4,F11.6,F10.6))        
      GO TO 390        
 340  IF (LNCT .LE. 50-2*NSPEC) GO TO 350        
      IF (IPRTC .NE. 0) WRITE (LOG2,200)        
      LNCT = 1        
 350  LNCT = LNCT + 10 + 2*NSPEC        
      DO 360 J = 1,NSPEC        
      CALL FREAD (LOG1,RDATA,6,1)        
      ZR(J)  = RDATA(1)        
      B1(J)  = RDATA(2)        
      B2(J)  = RDATA(3)        
      PP(J)  = RDATA(4)        
      QQ(J)  = RDATA(5)        
      RLE(J) = RDATA(6)        
      CALL FREAD (LOG1,RDATA,6,1)        
      TC(J)   = RDATA(1)        
      TE(J)   = RDATA(2)        
      ZZ(J)   = RDATA(3)        
      CORD(J) = RDATA(4)        
      DELX(J) = RDATA(5)        
      DELY(J) = RDATA(6)        
      CALL FREAD (LOG1,RDATA,2,1)        
      S(J)  = RDATA(1)        
 360  BS(J) = RDATA(2)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,330) (ZR(J),B1(J),B2(J),PP(J),QQ(J),
     1    RLE(J),TC(J),TE(J),ZZ(J),CORD(J),DELX(J),DELY(J),J=1,NSPEC)   
      IF (IPRTC.EQ.1 .AND. ISECN.EQ.1) WRITE (LOG2,370) (ZR(J),S(J),    
     1    BS(J),J=1,NSPEC)        
 370  FORMAT (/10X,'STREAMLINE  INFLECTION  INFLECTION', /11X,'NUMBER', 
     1       8X,5HPOINT,7X,5HANGLE, //,(10X,F7.2,F14.5,F11.3))        
      IF (IPRTC.EQ.1 .AND. ISECN.EQ.3) WRITE (LOG2,380) (ZR(J),S(J),    
     1    BS(J),J=1,NSPEC)        
 380  FORMAT (/10X,'STREAMLINE  TRANSITION  DEL ANGLE', /11X,'NUMBER',  
     1       8X,5HPOINT,6X,7HFROM LE, //,(10X,F7.2,F14.5,F11.3))        
 390  IF (ISPLIT .EQ. 0) GO TO 430        
      DO 400 J = 1,NSPEC        
      CALL FREAD (LOG1,RDATA,5,1)        
      RLES(J)   = RDATA(1)        
      TCS(J)    = RDATA(2)        
      TES(J)    = RDATA(3)        
      ZZS(J)    = RDATA(4)        
 400  PERSPT(J) = RDATA(5)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,410)        
 410  FORMAT (/20X,13HSPLITTER DATA, //10X,10HSTREAMLINE,2X,47HLE RADIUS
     1 MAX THICK TE THICK  POINT OF PER CENT, /11X,6HNUMBER,7X,6H/CHORD,
     2 4X,6H/CHORD,3X,8H/2*CHORD,2X,9HMAX THICK,2X,8HSPLITTER, /)       
      IF (IPRTC .EQ. 1) WRITE (LOG2,420) (ZR(J),RLES(J),TCS(J),TES(J),  
     1    ZZS(J),PERSPT(J),J=1,NSPEC)        
 420  FORMAT (10X,F7.2,3X,F8.3,F10.3,3F10.4)        
 430  CONTINUE        
C     IF (IFPLOT .EQ. 4) CALL PLOT (0.0,-PLTSZE,-3)        
      IF (IFPLOT.EQ.0 .OR. IFPLOT.EQ.4) GO TO 440        
      IKDUM = 0        
      IF (B1(1) .LT. 0.0) IKDUM = 1        
      IF (IFPLOT.EQ.1 .OR. IFPLOT.EQ.3) CALL ALG17 (ISTAK,PLTSZE,1,     
     1    TITLE,IKDUM,IFPLOT)        
 440  NDUM  = NPOINT        
      IIDUM = ISECN        
      DO 870 J = 1,NLINES        
      NPOINT = NDUM        
      ISECN  = IIDUM        
      DO 450 I = 1,NSTNS        
      KPT = KPTS(I)        
 450  CALL ALG15 (RSTA(1,I),XSTA(1,I),KPT,R(I,J),XHERE(I),1,0)        
      X(1)   = XHERE(1)        
      X(100) = XHERE(NSTNS)        
      AX = (X(100)-X(1))/99.0        
      DO 460 I = 2,99        
 460  X(I) = X(I-1) + AX        
      CALL ALG14 (XHERE,R(1,J),NSTNS,X,XDUM,YPRIME,100,1)        
      CALL ALG14 (XHERE,R(1,J),NSTNS,XHERE,XDUM,TANPHI(1,J),NSTNS,1)    
      SS(1) = 0.0        
      DO 470 I = 2,100        
 470  SS(I) = SS(I-1) + AX*SQRT(1.0+((YPRIME(I)+YPRIME(I-1))/2.0)**2)   
      XJ = J        
      CALL ALG15 (ZR,B1,NSPEC,XJ,BETA1,1,0)        
      CALL ALG15 (ZR,B2,NSPEC,XJ,BETA2,1,0)        
      CALL ALG15 (ZR,PP,NSPEC,XJ,P,1,0)        
      CALL ALG15 (ZR,QQ,NSPEC,XJ,Q,1,0)        
      CALL ALG15 (ZR,RLE,NSPEC,XJ,YZERO,1,0)        
      CALL ALG15 (ZR,TC,NSPEC,XJ,T,1,0)        
      CALL ALG15 (ZR,TE,NSPEC,XJ,YONE,1,0)        
      CALL ALG15 (ZR,DELX,NSPEC,XJ,XDEL,1,0)        
      CALL ALG15 (ZR,DELY,NSPEC,XJ,YDEL,1,0)        
      CALL ALG15 (ZR,ZZ,NSPEC,XJ,Z,1,0)        
      CALL ALG15 (ZR,CORD,NSPEC,XJ,CHD,1,0)        
      IF (ISECN.EQ.0 .OR. ISECN.EQ.2) GO TO 480        
      CALL ALG15 (ZR,S,NSPEC,XJ,SQ,1,0)        
      CALL ALG15 (ZR,BS,NSPEC,XJ,SB,1,0)        
 480  IF (ISPLIT .EQ. 0) GO TO 490        
      CALL ALG15 (ZR,RLES,NSPEC,XJ,YZEROS,1,1)        
      CALL ALG15 (ZR,TCS,NSPEC,XJ,TS,1,1)        
      CALL ALG15 (ZR,TES,NSPEC,XJ,YONES,1,1)        
      CALL ALG15 (ZR,ZZS,NSPEC,XJ,ZSPMXT,1,1)        
      CALL ALG15 (ZR,PERSPT,NSPEC,XJ,PERSPJ,1,1)        
 490  CALL ALG15 (X,SS,100,STACKX,BX,1,1)        
      CALL ALG13 (J,YS,YP,XS,XP,YSEMI,XSEMI,LOG1,LOG2,NPOINT,IPRINT,    
     1     BETA1,BETA2,P,Q,YZERO,T,YONE,XDEL,YDEL,Z,CHD,LNCT,IFCORD,SQ, 
     2     SB,ISECN,XSEMJ,YSEMJ,ISTAK,XHERE,X,SS,NSTNS,R,XTEMP,YPRIME,  
     3     RAD,EPZ,BX,SIGMA,CCORD,ISPLIT,YZEROS,TS,YONES,ZSPMXT,PERSPJ, 
     4     INAST,IRLE,IRTE,THARR)        
      CALL ALG15 (X,SS,100,STACKX,BX,1,1)        
      DO 500 I = 1,100        
      X(I)  = X(I) - STACKX        
 500  SS(I) = SS(I)- BX        
      DO 510 I = 1,NSTNS        
 510  XHERE(I) = XHERE(I) - STACKX        
      IF (IFPLOT.EQ.0 .OR. IFPLOT.EQ.2 .OR. IFPLOT.EQ.4) GO TO 570      
      XPLOT = XS(J,1)*SCALE        
      YPLOT = YS(J,1)*SCALE        
C     CALL PLOT (XPLOT,YPLOT,3)        
      DO 520 I = 2,NPOINT        
      XPLOT = XS(J,I)*SCALE        
      YPLOT = YS(J,I)*SCALE        
C520  CALL PLOT (XPLOT,YPLOT,2)        
 520  CONTINUE        
      IF (ISECN .NE. 2) GO TO 540        
      DO 530 I = 2,30        
      XPLOT = XSEMJ(J,I)*SCALE        
      YPLOT = YSEMJ(J,I)*SCALE        
C530  CALL PLOT (XPLOT,YPLOT,2)        
 530  CONTINUE        
 540  DO 550 II = 1,NPOINT        
      I = NPOINT - II + 1        
      XPLOT = XP(J,I)*SCALE        
      YPLOT = YP(J,I)*SCALE        
C550  CALL PLOT (XPLOT,YPLOT,2)        
 550  CONTINUE        
      DO 560 I = 2,30        
      XPLOT = XSEMI(J,I)*SCALE        
      YPLOT = YSEMI(J,I)*SCALE        
C560  CALL PLOT (XPLOT,YPLOT,2)        
 560  CONTINUE        
      XPLOT = XS(J,1)*SCALE        
      YPLOT = YS(J,1)*SCALE        
C     CALL PLOT (XPLOT,YPLOT,2)        
 570  IJDUM = 0        
      DO 580 I = 1,NSTNS        
      IF (IFANGS(I).GE.1) IJDUM = 1        
 580  CONTINUE        
      IF (IJDUM.EQ.0 .AND. INAST.EQ.0) GO TO 600        
      CALL ALG15 (SS,X,100,XTEMP,XTEMP,100,1)        
      DO 590 I = 1,NSTNS        
      CALL ALG15 (XTEMP,SIGMA,100,XHERE(I),THETA(J,I),1,1)        
      CALL ALG15 (XTEMP,YPRIME,100,XHERE(I),ALPHA(J,I),1,1)        
      ZCAMB(J,I) = R(I,J)*COS(THETA(J,I))        
      XCAMB(J,I) = XHERE(I)        
 590  YCAMB(J,I) = R(I,J)*SIN(THETA(J,I))        
 600  DO 610 I = 1,NPOINT        
 610  XTEMP(I) = XS(J,I)        
      CALL ALG15 (SS,X,100,XTEMP,XTEMP,NPOINT,1)        
      CALL ALG15 (XHERE,R(1,J),NSTNS,XTEMP,RAD,NPOINT,0)        
      K = 1        
      DO 620 I = 1,NPOINT        
      EPS = EPZ(I,K)        
      ZS(J,I) = RAD(I)*COS(EPS)        
      YS(J,I) = RAD(I)*SIN(EPS)        
 620  XS(J,I) = XTEMP(I)        
      DO 630 I = 1,NPOINT        
 630  XTEMP(I) = XP(J,I)        
      CALL ALG15 (SS,X,100,XTEMP,XTEMP,NPOINT,1)        
      CALL ALG15 (XHERE,R(1,J),NSTNS,XTEMP,RAD,NPOINT,0)        
      K = 2        
      DO 640 I = 1,NPOINT        
      EPS = EPZ(I,K)        
      ZP(J,I) = RAD(I)*COS(EPS)        
      YP(J,I) = RAD(I)*SIN(EPS)        
 640  XP(J,I) = XTEMP(I)        
      DO 650 I = 1,31        
 650  XTEMP(I) = XSEMI(J,I)        
      CALL ALG15 (SS,X,100,XTEMP,XTEMP,31,1)        
      CALL ALG15 (XHERE,R(1,J),NSTNS,XTEMP,RAD,31,0)        
      K = 3        
      DO 660 I = 1,31        
      EPS = EPZ(I,K)        
      ZSEMI(J,I) = RAD(I)*COS(EPS)        
      YSEMI(J,I) = RAD(I)*SIN(EPS)        
 660  XSEMI(J,I) = XTEMP(I)        
      IF (ISECN .NE. 2) GO TO 690        
      DO 670 I = 1,31        
 670  XTEMP(I) = XSEMJ(J,I)        
      CALL ALG15 (SS,X,100,XTEMP,XTEMP,31,1)        
      CALL ALG15 (XHERE,R(1,J),NSTNS,XTEMP,RAD,31,0)        
      K = 4        
      DO 680 I = 1,31        
      EPS = EPZ(I,K)        
      ZSEMJ(J,I) = RAD(I)*COS(EPS)        
      YSEMJ(J,I) = RAD(I)*SIN(EPS)        
 680  XSEMJ(J,I) = XTEMP(I)        
 690  IF (IPRINT .GE. 2) GO TO 870        
      IF (LNCT  .LE. 50) GO TO 700        
      IF (IPRTC .NE.  1) WRITE (LOG2,200)        
      LNCT = 1        
 700  LNCT = LNCT + 5        
      IF (IPRTC .EQ. 1) WRITE (LOG2,710) J        
 710  FORMAT (/10X,38HCARTESIAN COORDINATES ON STREAMSURFACE,I3, //10X, 
     1       8HPOINT NO,5X,2HZ1,12X,2HX1,12X,2HY1,16X,2HZ2,12X,2HX2,    
     2       12X,2HY2, /)        
      I = 1        
 720  IF (IPRTC .EQ. 1) WRITE (LOG2,730) I,ZS(J,I),XS(J,I),YS(J,I),     
     1    ZP(J,I),XP(J,I),YP(J,I)        
 730  FORMAT (10X,I5,3X,1P,3E14.5,4X,1P,3E14.5)        
      I = I + 1        
      LNCT = LNCT + 1        
      IF (I .GT. NPOINT) GO TO 750        
      IF (LNCT .LE.  59) GO TO 720        
      IF (IPRTC .EQ.  1) WRITE (LOG2,740)        
 740  FORMAT (1H1,9X,8HPOINT NO,5X,2HZ1,12X,2HX1,12X,2HY1,16X,2HZ2,12X, 
     1        2HX2,12X,2HY2, /)        
      LNCT = 2        
      GO TO 720        
 750  IF (LNCT .LE. 50) GO TO 760        
      IF (IPRTC .NE. 0) WRITE (LOG2,200)        
      LNCT = 1        
 760  LNCT = LNCT + 3        
      IF (ISECN .NE. 2) GO TO 770        
      GO TO 820        
 770  IF (IPRTC .EQ. 1) WRITE (LOG2,780)        
 780  FORMAT (/10X,8HPOINT NO,4X,5HZSEMI,9X,5HXSEMI,9X,5HYSEMI, /)      
 790  FORMAT (/10X,8HPOINT NO,4X,5HZSEMI,9X,5HXSEMI,9X,5HYSEMI,13X,     
     15HZSEMJ,9X,5HXSEMJ,9X,5HYSEMJ, /)        
      I = 1        
 800  IF (IPRTC .EQ. 1) WRITE (LOG2,810) I,ZSEMI(J,I),XSEMI(J,I),       
     1    YSEMI(J,I)        
 810  FORMAT (10X,I5,3X,1P,3E14.5)        
      GO TO 850        
 820  IF (IPRTC .EQ. 1) WRITE (LOG2,790)        
      I = 1        
 830  IF (IPRTC .EQ. 1) WRITE (LOG2,840) I,ZSEMI(J,I),XSEMI(J,I),       
     1                  YSEMI(J,I),ZSEMJ(J,I),XSEMJ(J,I),YSEMJ(J,I)     
 840  FORMAT (10X,I5,3X,1P,3E14.5,4X,1P,3E14.5)        
 850  I = I + 1        
      LNCT = LNCT + 1        
      IF (I .GT. 31) GO TO 870        
      IF (LNCT.LE.59 .AND. ISECN.EQ.2) GO TO 830        
      IF (ISECN .NE. 2) GO TO 860        
      IF (IPRTC .NE. 0) WRITE (LOG2,200)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,790)        
      LNCT = 4        
      GO TO 830        
 860  IF (LNCT .LE. 59) GO TO 800        
      IF (IPRTC .NE. 0) WRITE (LOG2,200)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,780)        
      LNCT = 4        
      GO TO 800        
 870  CONTINUE        
      IF (IPRINT .EQ. 1) GO TO 1030        
      VOL = 0.0        
      DO 880 J = 2,NLINES        
      VOL = VOL + (((XS(J,1)-XP(J,1))**2+(YS(J,1)-YP(J,1))**2) +        
     1      ((XS(J-1,1)-XP(J-1,1))**2 + (YS(J-1,1)-YP(J-1,1))**2))*     
     2      (ZS(J,1)+ZP(J,1)-ZS(J-1,1) - ZP(J-1,1))*PI/32.0        
      DO 880 I = 2,NPOINT        
 880  VOL = VOL + ((SQRT((XS(J,I)-XP(J,I))**2+(YS(J,I)-YP(J,I))**2) +   
     1      SQRT((XS(J,I-1)-XP(J,I-1))**2+(YS(J,I-1)-YP(J,I-1))**2))*   
     2      (SQRT((XS(J,I-1)-XS(J,I))**2+(YS(J,I-1)-YS(J,I))**2) +      
     3      SQRT((XP(J,I-1)-XP(J,I))**2+(YP(J,I-1)-YP(J,I))**2)) +      
     4      (SQRT((XS(J-1,I)-XP(J-1,I))**2+(YS(J-1,I)-YP(J-1,I))**2) +  
     5      SQRT((XS(J-1,I-1)-XP(J-1,I-1))**2+(YS(J-1,I-1)-YP(J-1,I-1)) 
     6      **2))*(SQRT((XS(J-1,I-1)-XS(J-1,I))**2+(YS(J-1,I-1)-        
     7      YS(J-1,I))**2)+SQRT((XP(J-1,I-1)-XP(J-1,I))**2+(YP(J-1,I-1)-
     8      YP(J-1,I))**2)))*(ZS(J,I)+ZS(J,I-1)+ZP(J,I)+ZP(J,I-1)-      
     9      ZS(J-1,I)-ZS(J-1,I-1)-ZP(J-1,I)-ZP(J-1,I-1))/32.0        
      IF (LNCT .LE. 56) GO TO 890        
      LNCT = 1        
      IF (IPRTC .NE. 0) WRITE (LOG2,200)        
 890  LNCT = LNCT + 4        
      IF (IPRTC .EQ. 1) WRITE (LOG2,900) VOL        
 900  FORMAT (//40X,25HVOLUME OF BLADE SECTION =,1P,E11.4, /40X,36(1H*))
      IF (IJDUM  .EQ. 0) GO TO 1030        
      IF (IPRINT .NE. 3) WRITE (LOG2,200)        
      IF (IPRINT .EQ. 3) WRITE (LOG2,910)        
 910  FORMAT (//)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,920)        
 920  FORMAT (1H1,42X,43HBLADE CALCULATIONS FOR AERODYNAMIC ANALYSIS,   
     1        /43X,43(1H*))        
      IDUM = 7        
      LNCT = LNCT + 4        
      IF (IPRINT .NE. 3) LNCT = 3        
      DO 1020 I = 1,NSTNS        
      IF (IFANGS(I).EQ.0 .OR. (ISPLIT.GE.1 .AND. IFANGS(I).EQ.1))       
     1    GO TO 1020        
      DO 940 J = 1,NLINES        
      CALL ALG15 (RSTA(1,I),XSTA(1,I),KPTS(I),R(I,J),XDUM,1,0)        
      CALL ALG14 (RSTA(1,I),XSTA(1,I),KPTS(I),R(I,J),XDUM,ZQ(J),1,1)    
      DO 930 K = 1,NPOINT        
      SS(K)  = XS(J,K)        
      RAD(K) = YS(J,K)        
      XTEMP(K) = XP(J,K)        
 930  X(K) = YP(J,K)        
      XDUM = XDUM - STACKX        
      CALL ALG15 (SS,RAD,NPOINT,XDUM,YY1,1,1)        
      CALL ALG15 (XTEMP,X,NPOINT,XDUM,YY2,1,1)        
      W1 = YY1/R(I,J)        
      W2 = YY2/R(I,J)        
      TQ(J) = ABS(ATAN(W1/SQRT(1.-W1**2))-ATAN(W2/SQRT(1.-W2**2)))/     
     1        (2.*PI)*FLOAT(NBLADE)        
 940  CONTINUE        
      CALL ALG14 (ZCAMB(1,I),YCAMB(1,I),NLINES,ZCAMB(1,I),XDUM,RLE,     
     1            NLINES,1)        
      IF (LNCT+IDUM+NLINES .LE. 59) GO TO 950        
      IF (IPRTC .NE. 0) WRITE (LOG2,200)        
      LNCT = 2        
 950  LNCT = LNCT + IDUM + NLINES        
      IF (IPRTC .EQ. 1) WRITE (LOG2,960) I,NLINES        
 960  FORMAT (///48X,8HSTATION ,I2,5X,17HNUMBER OF RADII= ,I2,  //36X,6H
     1RADIUS,5X,7HSECTION,6X,4HLEAN,9X,5HBLADE,7X,5HTHETA, /48X,5HANGLE,
     26X,5HANGLE,7X,8HBLOCKAGE, /)        
      DO 1000 J = 1,NLINES        
      EPS = (THETA(J,I)-ATAN(RLE(J)))*C1        
      ALPHB = ALPHA(J,I)        
      ALP = (ATAN((TANPHI(I,J)*TAN(EPS/C1)+ALPHB*SQRT(1.+TANPHI(I,J)**2)
     1      )/(1.-TANPHI(I,J)*ZQ(J))))*C1        
      ALPB(I,J) = ALP        
      EPSLON(I,J) = ATAN(TAN(EPS/C1)/SQRT(1.0+ZQ(J)**2))*C1        
      IF (ISPLIT .LT. 1) GO TO 990        
      CALL FREAD (LOG1,RDATA,4,1)        
      XB = RDATA(4)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,980) XB,I,J        
 980  FORMAT(90X,14HADDIT. BLOCK =,F7.5,3H I=,I2,3H J=,I2)        
      TQ(J) = TQ(J) + XB        
 990  IF (IPRTC .EQ.1) WRITE (LOG2,1010) R(I,J),ALP,EPS,TQ(J),THETA(J,I)
 1000 BLOCK(I,J) = TQ(J)        
 1010 FORMAT (30X,5F12.4)        
 1020 CONTINUE        
 1030 IF (IFPLOT.LT.2 .OR. IFPLOT.EQ.4) GO TO 1040        
      CALL ALG17 (ISTAK,PLTSZE,2,TITLE,IKDUM,IFPLOT)        
 1040 IF (IPRINT.EQ.1 .OR. IPRINT.EQ.3) GO TO 1060        
      LNCT = 2        
      IF (IPRTC .EQ. 1) WRITE (LOG2,1050)        
 1050 FORMAT (1H1,27X,74HBLADE SURFACE GEOMETRY IN CARTESIAN COORDINATES
     1 AT SPECIFIED VALUES OF  Z , /28X,18(4H****),2H**)        
 1060 IF (IPRINT.EQ.1 .AND. IFPLOT.LE.1) GO TO 1470        
      XZ = NZ - 1        
      DZ = (ZOUTER-ZINNER)/XZ        
      ZOUT(1) = ZINNER        
      DO 1070 J = 3,NZ        
 1070 ZOUT(J-1) = ZOUT(J-2) + DZ        
      ZOUT(NZ) = ZOUTER        
      DO 1080 I = 1,NPOINT        
      CALL ALG15 (ZS(1,I),XS(1,I),NLINES,ZOUT,TEMP1,NZ,0)        
      CALL ALG15 (ZS(1,I),YS(1,I),NLINES,ZOUT,TEMP2,NZ,0)        
      CALL ALG15 (ZP(1,I),XP(1,I),NLINES,ZOUT,TEMP3,NZ,0)        
      CALL ALG15 (ZP(1,I),YP(1,I),NLINES,ZOUT,TEMP4,NZ,0)        
      DO 1080 J = 1,NZ        
      XS(J,I) = TEMP1(J)        
      YS(J,I) = TEMP2(J)        
      XP(J,I) = TEMP3(J)        
 1080 YP(J,I) = TEMP4(J)        
      DO 1090 I = 1,31        
      CALL ALG15 (ZSEMI(1,I),XSEMI(1,I),NLINES,ZOUT,TEMP1,NZ,0)        
      CALL ALG15 (ZSEMI(1,I),YSEMI(1,I),NLINES,ZOUT,TEMP2,NZ,0)        
      DO 1090 J = 1,NZ        
      XSEMI(J,I) = TEMP1(J)        
 1090 YSEMI(J,I) = TEMP2(J)        
      IF (ISECN .NE. 2) GO TO 1110        
      DO 1100 I = 1,31        
      CALL ALG15 (ZSEMJ(1,I),XSEMJ(1,I),NLINES,ZOUT,TEMP1,NZ,0)        
      CALL ALG15 (ZSEMJ(1,I),YSEMJ(1,I),NLINES,ZOUT,TEMP2,NZ,0)        
      DO 1100 J = 1,NZ        
      XSEMJ(J,I) = TEMP1(J)        
 1100 YSEMJ(J,I) = TEMP2(J)        
 1110 DO 1460 J = 1,NZ        
      RD = SQRT((XS(J,1)-XP(J,1))**2+(YS(J,1)-YP(J,1))**2)/2.0        
      AREA = PI*RD**2/2.0        
      BETA1 = ATAN((YS(J,2)+YP(J,2)-YS(J,1)-YP(J,1))/(XS(J,2)+XP(J,2)-  
     1        XS(J,1)-XP(J,1)))        
      XINT = AREA*((XP(J,1)+XS(J,1))/2.0-COS(BETA1)*4.0/(3.0*PI)*RD)    
      YINT = AREA*((YP(J,1)+YS(J,1))/2.0-SIN(BETA1)*4.0/(3.0*PI)*RD)    
      IF (ISECN .NE. 2) GO TO 1120        
      N1 = NPOINT        
      N  = N1        
      N2 = N1 - 1        
      BETA2 = ATAN((YS(J,N1)+YP(J,N1)-YS(J,N2)-YP(J,N2))/(XS(J,N1)+     
     1        XP(J,N1)-XS(J,N2)-XP(J,N2)))        
      XINT = XINT + AREA*((XP(J,N)+XS(J,N))/2.+COS(BETA2)*4./(3.*PI)*RD)
      YINT = YINT + AREA*((YP(J,N)+YS(J,N))/2.+SIN(BETA2)*4./(3.*PI)*RD)
      AREA = 2.*AREA        
 1120 DO 1130 I = 2,NPOINT        
      DELA = (SQRT((XS(J,I)-XP(J,I))**2+(YS(J,I)-YP(J,I))**2)+        
     1        SQRT((XS(J,I-1)-XP(J,I-1))**2+(YS(J,I-1)-YP(J,I-1))**2))* 
     2        (SQRT((XS(J,I-1)-XS(J,I))**2+(YS(J,I-1)-YS(J,I))**2)+     
     3        SQRT((XP(J,I-1)-XP(J,I))**2+(YP(J,I-1)-YP(J,I))**2))/4.0  
      AREA = AREA + DELA        
      XINT = XINT + DELA*(XS(J,I)+XS(J,I-1)+XP(J,I)+XP(J,I-1))/4.0      
 1130 YINT = YINT + DELA*(YS(J,I)+YS(J,I-1)+YP(J,I)+YP(J,I-1))/4.0      
      YINT = YINT/AREA        
      XINT = XINT/AREA        
      X1   = (XS(J,1)+XP(J,1))/2.        
      Y1   = (YS(J,1)+YP(J,1))/2.        
      T1   = SQRT((XS(J,1)-XP(J,1))**2+(YS(J,1)-YP(J,1))**2)        
      F    = 0.        
      U    = 0.        
      DO 1140 I = 2,NPOINT        
      T2   = SQRT((XS(J,I)-XP(J,I))**2+(YS(J,I)-YP(J,I))**2)        
      X2   = (XS(J,I)+XP(J,I))/2.        
      Y2   = (YS(J,I)+YP(J,I))/2.        
      DELU = SQRT((X2-X1)**2+(Y2-Y1)**2)        
      U    = U + DELU        
      TAV3 = (T1**3+T2**3)/2.        
      F    = F + TAV3*DELU        
      X1   = X2        
      Y1   = Y2        
 1140 T1   = T2        
      TORCON = ((1./3.)*F)/(1.+(4./3.)*F/AREA/U**2)        
      IX   = 0.0        
      IY   = 0.0        
      IXY  = 0.0        
      DO 1150 I = 2,NPOINT        
      XD   = (SQRT((XS(J,I-1)-XP(J,I-1))**2+(YS(J,I-1)-YP(J,I-1))**2)+  
     1        SQRT((XS(J,I)-XP(J,I))**2+(YS(J,I)-YP(J,I))**2))/2.0      
      YD   = (SQRT((XS(J,I)-XS(J,I-1))**2+(YS(J,I)-YS(J,I-1))**2)+      
     1        SQRT((XP(J,I)-XP(J,I-1))**2+(YP(J,I)-YP(J,I-1))**2))/2.0  
      IXD  = YD*YD*YD*XD/12.0        
      IYD  = XD*XD*XD*YD/12.0        
      ANG  = ATAN((YS(J,I)+YP(J,I)-YS(J,I-1)-YP(J,I-1))/(XP(J,I)+XS(J,I)
     1       -XP(J,I-1)-XS(J,I-1)))        
      COSANG = COS(2.0*ANG)        
      IXN  = (IXD+IYD+(IXD-IYD)*COSANG)/2.0        
      IYN  = (IXD+IYD-(IXD-IYD)*COSANG)/2.0        
      IXYN = 0.0        
      IF (ANG .NE. 0.0) IXYN = ((IXN-IYN)*COSANG-IXD+IYD)/        
     1                         (2.0*SIN(2.0*ANG))        
      DELA = XD*YD        
      YMN  = (YS(J,I)+YS(J,I-1)+YP(J,I)+YP(J,I-1))/4.0-YINT        
      XMN  = (XS(J,I)+XS(J,I-1)+XP(J,I)+XP(J,I-1))/4.0-XINT        
      IX   = IX + IXN + DELA*YMN*YMN        
      IY   = IY + IYN + DELA*XMN*XMN        
 1150 IXY  = IXY+ IXYN+ DELA*YMN*XMN        
      ANG  = ATAN(2.0*IXY/(IY-IX))        
      IPX  = (IX+IY)/2.0+(IX-IY)/2.0*COS(ANG)-IXY*SIN(ANG)        
      IPY  = (IX+IY)/2.0-(IX-IY)/2.0*COS(ANG)+IXY*SIN(ANG)        
      ANG  = ANG/2.0*C1        
      IF (IPRINT.EQ.1 .OR. IPRINT.EQ.3) GO TO 1320        
      IF (LNCT .LE. 45) GO TO 1160        
      IF (IPRTC .NE. 0) WRITE (LOG2,200)        
      LNCT = 1        
 1160 LNCT = LNCT + 16        
      IF (IPRTC .EQ. 1) WRITE (LOG2,1170) J,ZOUT(J),AREA,XINT,YINT,IX,  
     1    IY,IXY,IPX,ANG,IPY,ANG        
 1170 FORMAT (/50X,14HSECTION NUMBER,I3,3X,5H Z  =,F9.4, /50X,    34H***
     1*******************************, ///20X,18HSECTION PROPERTIES,7X,1
     22HSECTION AREA,26X,1H=,1P,E12.4,//45X,20HLOCATION OF CENTROID,11X,
     34HXBAR,3X,1H=,E12.4, /45X,22HRELATIVE TO STACK AXIS,9X,4HYBAR,3X,1
     4H=,E12.4, //45X,22HSECOND MOMENTS OF AREA,9X,2HIX,5X,1H=,E12.4, /4
     55X,14HABOUT CENTROID,17X,2HIY,5X,1H=,E12.4, /76X,3HIXY,4X,1H=,E12.
     64, //45X,24HPRINCIPAL SECOND MOMENTS,7X,3HIPX,4X,1H=,E12.4,4H (AT,
     70P,F7.2,21H DEGREES TO  X  AXIS),/45X,22HOF AREA ABOUT CENTROID,9X
     8,3HIPY,4X,1H=,1P,E12.4,4H (AT,0P,F7.2,21H DEGREES TO  Y  AXIS))   
      IF (IPRTC .EQ. 1) WRITE (LOG2,1180) TORCON        
 1180 FORMAT (/45X,18HTORSIONAL CONSTANT,20X,1H=,1P,E12.4, /)        
      LNCT = LNCT + 3        
      IF (LNCT .LE. 50) GO TO 1190        
      IF(IPRTC .NE.  0) WRITE (LOG2,200)        
      LNCT = 1        
 1190 LNCT = LNCT + 5        
      IF (IPRTC .EQ. 1) WRITE (LOG2,1200)        
 1200 FORMAT (/20X,19HSECTION COORDINATES, /)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,1210)        
 1210 FORMAT (31X,8HPOINT NO,5X,2HX1,12X,2HY1,16X,2HX2,12X,2HY2, /)     
      DO 1220 I = 1,NPOINT        
      LNCT = LNCT + 1        
      IF (LNCT .LE. 60) GO TO 1220        
      LNCT = 4        
      IF (IPRTC .NE. 0) WRITE (LOG2,200)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,1210)        
 1220 IF (IPRTC .EQ. 1) WRITE (LOG2,1230) I,XS(J,I),YS(J,I),XP(J,I),    
     1                                    YP(J,I)        
 1230 FORMAT (31X,I5,3X,1P,2E14.5,4X,1P,2E14.5)        
      IF (LNCT.LE.55) GO TO 1240        
      LNCT = 1        
      IF (IPRTC .NE. 0) WRITE (LOG2,200)        
 1240 LNCT = LNCT + 3        
      IF (IPRTC.EQ.1 .AND. ISECN.EQ.2) WRITE (LOG2,1260)        
      IF (ISECN .EQ. 2) GO TO 1270        
      IF (IPRTC .EQ. 1) WRITE (LOG2,1250)        
 1250 FORMAT (/31X,8HPOINT NO,5X,5HXSEMI,9X,5HYSEMI, /)        
 1260 FORMAT (/31X,8HPOINT NO,5X,5HXSEMI,9X,5HYSEMI,12X,5HXSEMJ,9X,     
     1        5HYSEMJ, /)        
 1270 DO 1300 I = 1,31        
      LNCT = LNCT + 1        
      IF (LNCT .LE. 60) GO TO 1290        
      IF (IPRTC .NE. 0) WRITE (LOG2,200)        
      IF (IPRTC.EQ.1 .AND. ISECN.EQ.2) WRITE (LOG2,1260)        
      IF (ISECN .EQ. 2) GO TO 1280        
      IF (IPRTC .EQ. 1) WRITE (LOG2,1250)        
 1280 LNCT = 4        
 1290 IF (IPRTC.EQ.1 .AND. ISECN.EQ.2) WRITE (LOG2,1230) I,XSEMI(J,I),  
     1    YSEMI(J,I),XSEMJ(J,I),YSEMJ(J,I)        
      IF (ISECN .EQ. 2) GO TO 1300        
      IF (IPRTC .EQ. 1) WRITE (LOG2,1310) I,XSEMI(J,I),YSEMI(J,I)       
 1300 CONTINUE        
 1310 FORMAT (31X,I5,3X,1P,2E14.5)        
 1320 IF (IFPLOT .LT. 2) GO TO 1460        
      IF (IFPLOT .EQ. 4) GO TO 1380        
      XPLOT = XS(J,1)*SCALE        
      YPLOT = YS(J,1)*SCALE        
C     CALL PLOT (XPLOT,YPLOT,3)        
      DO 1330 I = 2,NPOINT        
      XPLOT = XS(J,I)*SCALE        
      YPLOT = YS(J,I)*SCALE        
C1330 CALL PLOT (XPLOT,YPLOT,2)        
 1330 CONTINUE        
      IF (ISECN .NE. 2) GO TO 1350        
      DO 1340 I = 2,30        
      XPLOT = XSEMJ(J,I)*SCALE        
      YPLOT = YSEMJ(J,I)*SCALE        
C1340 CALL PLOT (XPLOT,YPLOT,2)        
 1340 CONTINUE        
 1350 DO 1360 II = 1,NPOINT        
      I = NPOINT + 1 - II        
      XPLOT = XP(J,I)*SCALE        
      YPLOT = YP(J,I)*SCALE        
C1360 CALL PLOT (XPLOT,YPLOT,2)        
 1360 CONTINUE        
      DO 1370 I = 2,30        
      XPLOT = XSEMI(J,I)*SCALE        
      YPLOT = YSEMI(J,I)*SCALE        
C1370 CALL PLOT (XPLOT,YPLOT,2)        
 1370 CONTINUE        
      XPLOT = XS(J,1)*SCALE        
      YPLOT = YS(J,1)*SCALE        
C     CALL PLOT (XPLOT,YPLOT,2)        
      GO TO 1460        
C1380 CALL SYMBOL (19.9,2.0,0.175,22HCARTESIAN SECTION NO. ,0.0,22)     
 1380 CONTINUE        
      XJ = J        
C     CALL NUMBER (23.75,2.0,0.175,XJ,0.0,-1)        
C     CALL SYMBOL (20.6,1.0,0.175,10HSTAGGER = ,0.0,10)        
      STAGER = ATAN((YS(J,NPOINT)+YP(J,NPOINT)-YS(J,1)-YP(J,1))/        
     1         (XS(J,NPOINT)+XP(J,NPOINT)-XS(J,1)-XP(J,1)))*C1        
C     CALL NUMBER (22.35,1.0,0.175,STAGER,0.0,3)        
C     CALL PLOT (22.0,5.25,-3)        
      XSIGN  = FLOAT(NSIGN)        
      SINSTG = SIN(STAGER/C1)        
      COSSTG = COS(STAGER/C1)        
      YPLOT  = 4.75        
      XPLOT  = 4.75*SINSTG/COSSTG        
      IF (ABS(XPLOT) .LE. 22.0) GO TO 1390        
      XPLOT  = 22.0        
      YPLOT  =-22.0/SINSTG*COSSTG        
C1390 CALL PLOT (XPLOT,YPLOT,3)        
 1390 CONTINUE        
      XPLOT = -XPLOT        
      YPLOT = -YPLOT        
C     CALL PLOT (XPLOT,YPLOT,2)        
      XPLOT = 22.0        
      YPLOT =-22.0*SINSTG/COSSTG        
      IF (ABS(YPLOT) .LE. 4.75) GO TO 1400        
      YPLOT =-4.75        
      XPLOT = 4.75/SINSTG*COSSTG        
C1400 CALL PLOT (XPLOT,YPLOT,3)        
 1400 CONTINUE        
      XPLOT = -XPLOT        
      YPLOT = -YPLOT        
C     CALL PLOT (XPLOT,YPLOT,2)        
      XPLOT = SCALE*(XS(J,1)*COSSTG+YS(J,1)*SINSTG)        
      YPLOT = SCALE*(YS(J,1)*COSSTG-XS(J,1)*SINSTG)        
C     CALL PLOT (XPLOT,YPLOT,3)        
      DO 1410 I = 2,NPOINT        
      XPLOT = SCALE*(XS(J,I)*COSSTG+YS(J,I)*SINSTG)        
      YPLOT = SCALE*(YS(J,I)*COSSTG-XS(J,I)*SINSTG)        
C1410 CALL PLOT (XPLOT,YPLOT,2)        
 1410 CONTINUE        
      IF (ISECN.NE.2) GO TO 1430        
      DO 1420 I = 2,30        
      XPLOT = SCALE*(XSEMJ(J,I)*COSSTG+YSEMJ(J,I)*SINSTG)        
      YPLOT = SCALE*(YSEMJ(J,I)*COSSTG-XSEMJ(J,I)*SINSTG)        
C1420 CALL PLOT (XPLOT,YPLOT,2)        
 1420 CONTINUE        
 1430 DO 1440 II = 1,NPOINT        
      I = NPOINT + 1 - II        
      XPLOT = SCALE*(XP(J,I)*COSSTG+YP(J,I)*SINSTG)        
      YPLOT = SCALE*(YP(J,I)*COSSTG-XP(J,I)*SINSTG)        
C1440 CALL PLOT (XPLOT,YPLOT,2)        
 1440 CONTINUE        
      DO 1450 I = 2,30        
      XPLOT = SCALE*(XSEMI(J,I)*COSSTG+YSEMI(J,I)*SINSTG)        
      YPLOT = SCALE*(YSEMI(J,I)*COSSTG-XSEMI(J,I)*SINSTG)        
C1450 CALL PLOT (XPLOT,YPLOT,2)        
 1450 CONTINUE        
      XPLOT = SCALE*(XS(J,1)*COSSTG+YS(J,1)*SINSTG)        
      YPLOT = SCALE*(YS(J,1)*COSSTG-XS(J,1)*SINSTG)        
C     CALL PLOT (XPLOT,YPLOT,2)        
C     CALL PLOT (23.0,-5.25,-3)        
 1460 CONTINUE        
 1470 CONTINUE        
      IF (INAST .EQ. 0) GO TO 1580        
      XSIGN = FLOAT(NSIGN)        
      WRITE  (LOG2,1471)        
 1471 FORMAT (1H0,10X,34HNASTRAN COMPRESSOR BLADE BULK DATA , /10X,     
     1        36(1H*), //)        
      IF (IPGEOM .EQ. 1) GO TO 1562        
      WRITE  (LOG2,1472)        
 1472 FORMAT (11X,30H*** CTRIA2 AND PTRIA2 DATA ***, /)        
      NSTAD = IRTE - IRLE + 1        
      JLOOP = 0        
      NELEM = 0        
      NSTRD = NLINES - 1        
      IRT   = IRTE - 1        
      NT    = 1995        
      DO 1520 J = 1,NSTRD        
      DO 1510 I = IRLE,IRT        
      NELEM = NELEM + 1        
      IGRD1 = I - 1 + JLOOP        
      IGRD3 = IGRD1 + NSTAD        
      IGRD2 = IGRD1 + NSTAD + 1        
      NT    = NT + 5        
      WRITE (LPUNCH,1530) NELEM,NT,IGRD1,IGRD2,IGRD3        
      WRITE (LOG2,1531) NELEM,NT,IGRD1,IGRD2,IGRD3        
      IF (ABS(FLOAT(INAST)) .GT. 3.5) GO TO 1480        
      THCK = (THARR(J,I)+THARR(J+1,I)+THARR(J+1,I+1))/3.        
      PRES =-XSIGN*(BLAFOR(I,J)+BLAFOR(I,J+1)+BLAFOR(I+1,J+1))/3.       
      GO TO 1490        
 1480 THCK = (THARR(J,I)+THARR(J+1,I)+THARR(J+1,I+1)+THARR(J,I+1))/4.   
      PRES =-XSIGN*(BLAFOR(I,J)+BLAFOR(I,J+1)+BLAFOR(I+1,J+1)+        
     1       BLAFOR(I+1,J))/4.        
 1490 WRITE (LPUNCH,1540) NT,THCK        
      WRITE (LOG2,1541)   NT,THCK        
      IF (INAST .GT. 0) WRITE (LPUNCH,1550) PRES,NELEM        
      IF (INAST .GT. 0) WRITE (LOG2,1551)   PRES,NELEM        
      NELEM = NELEM + 1        
      IGRD3 = IGRD2        
      IGRD2 = IGRD1 + 1        
      IF (ABS(FLOAT(INAST)) .GT. 3.5) GO TO 1500        
      NT   = NT + 5        
      THCK = (THARR(J,I)+THARR(J,I+1)+THARR(J+1,I+1))/3.        
      PRES = -XSIGN*(BLAFOR(I,J)+BLAFOR(I+1,J)+BLAFOR(I+1,J+1))/3.      
      WRITE (LPUNCH,1540) NT,THCK        
      WRITE (LOG2,1541)   NT,THCK        
 1500 WRITE (LPUNCH,1530) NELEM,NT,IGRD1,IGRD2,IGRD3        
      WRITE (LOG2,1531)   NELEM,NT,IGRD1,IGRD2,IGRD3        
      IF (INAST .GT. 0) WRITE (LPUNCH,1550) PRES,NELEM        
      IF (INAST .GT. 0) WRITE (LOG2,1551)   PRES,NELEM        
 1510 CONTINUE        
 1520 JLOOP = JLOOP + NSTAD        
 1530 FORMAT (6HCTRIA2,7X,I3,4X,I4,3(5X,I3))        
 1531 FORMAT (1X,6HCTRIA2,7X,I3,4X,I4,3(5X,I3))        
 1540 FORMAT (6HPTRIA2,6X,I4,7X,1H1,F8.4,6X,2H0.)        
 1541 FORMAT (1X,6HPTRIA2,6X,I4,7X,1H1,F8.4,6X,2H0.)        
 1550 FORMAT (6HPLOAD2,8X,2H60,F8.4,5X,I3)        
 1551 FORMAT (1X,6HPLOAD2,8X,2H60,F8.4,5X,I3)        
 1560 FORMAT (4HGRID,9X,I3,8X,3F8.4)        
 1561 FORMAT (1X,4HGRID,9X,I3,8X,3F8.4)        
 1562 CONTINUE        
      WRITE  (LOG2,1563)        
 1563 FORMAT (1H0,10X,29H*** BLADE GRID POINT DATA *** ,/)        
      JD = 0        
      DO 1570 J = 1,NLINES        
      DO 1570 I = IRLE,IRTE        
      JD = JD + 1        
      YCAMB(J,I) = -XSIGN*YCAMB(J,I)        
      WRITE (LOG2,1561) JD,XCAMB(J,I),YCAMB(J,I),ZCAMB(J,I)        
 1570 WRITE (LPUNCH,1560) JD,XCAMB(J,I),YCAMB(J,I),ZCAMB(J,I)        
      IF (ISTRML.EQ.-1 .OR. ISTRML.EQ.2) GO TO 1580        
      WRITE  (LOG2,1571)        
 1571 FORMAT (1H0,10X,27H*** BLADE STREAML1 DATA ***,/)        
      NSTAD  = IRTE - IRLE + 1        
      NSTAD1 = NSTAD - 1        
      DO 1572 J = 1,NLINES        
      ND1 = (J-1)*NSTAD + 1        
      ND2 = ND1 + NSTAD1        
      WRITE  (LPUNCH, 1573) J,ND1,ND2        
 1572 WRITE  (LOG2,1574) J,ND1,ND2        
 1573 FORMAT (8HSTREAML1,I8,I8,8H THRU   ,I8)        
 1574 FORMAT (1X,8HSTREAML1,I8,I8,8H THRU   ,I8)        
 1580 CONTINUE        
      IF (NAERO.EQ.1 .OR. IPUNCH.EQ.1) CALL ALG19 (LOG1,LOG2,LOG3,LOG5, 
     1    NLINES,NSPEC,KPTS,RSTA,XSTA,R,ZR,B1,B2,TC,PI,C1,NBLADE,CCORD, 
     2    BLOCK,ALPB,EPSLON,IFANGS,IPUNCH,NAERO)        
C     IF (IFPLOT .NE. 0) CALL PLOT (0.0,0.0,-3)        
      RETURN        
      END        
