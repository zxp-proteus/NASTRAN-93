      SUBROUTINE XFLDEF (NAME1,NAME2,NOFIND)        
C        
C     THE PURPOSE OF THIS ROUTINE IS TO TURN ON ALL OSCAR ENTRY EXECUTE 
C     FLAGS NECESSARY TO DEFINE FILE .        
C        
C                 DESCRIPTION OF ARGUMENTS        
C     NAM1,NAM2 = NAME OF FILE TO BE DEFINED.        
C     NOFIND    = INDICATES TO CALLING PROGRAM WHETHER OR NOT FILE WAS  
C                 FOUND.        
C        
      EXTERNAL        ANDF,ORF,COMPLF        
      INTEGER         NAME1(1),NAME2(1),SOL,OSCAR(1),OS(5),OSPNT,OSBOT, 
     1                FMED(1),FMEDTP,FNM(1),FNMTP,FMDMSK,TWO,OP,PTDTP,  
     2                PTDBOT,PTDIC(1),AND,OR,ANDF,ORF,COMPLF,START,     
     3                REUSE,REGEN        
      COMMON /XMDMSK/ NMSKCD,NMSKFL,NMSKRF,FMDMSK(7)        
      COMMON /XGPID / ICST,IUNST,IMST,IHAPP,IDSAPP,IDMAPP,XGPID1(5),    
     1                NOFLGS        
      COMMON /SYSTEM/ BS,OP,NOGO,DUM(78),ICPFLG        
      COMMON /XOLDPT/ PTDTP,PTDBOT,LPTDIC,NRLFL,SEQNO        
      COMMON /XGPIC / ICOLD,ISLSH,IEQUL,NBLANK,NXEQUI,        
C                  ** CONTROL CARD NAMES **        
     1                NDIAG,NSOL,NDMAP,NESTM1,NESTM2,NEXIT,        
C                  ** DMAP CARD NAMES **        
     2                NBEGIN,NEND,NJUMP,NCOND,NREPT,NTIME,NSAVE,        
     3                NOUTPT,NCHKPT,NPURGE,NEQUIV,        
     4                NCPW,NBPC,NWPC,        
     5                MASKHI,MASKLO,ISGNON,NOSGN,IALLON,MASKS(1)        
CZZ   COMMON /ZZXGPI/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /XGPI4 / IRTURN,INSERT,ISEQN,DMPCNT,        
     1                IDMPNT,DMPPNT,BCDCNT,LENGTH,ICRDTP,ICHAR, NEWCRD, 
     2                MODIDX,LDMAP,ISAVDW,DMAP(1)        
      COMMON /XGPI5 / IAPP,START,IEXIT(2),SOL,SUBSET,IFLAG,IESTIM,      
     1                ICFTOP,ICFPNT,LCTLFL,ICTLFL(1)        
      COMMON /XGPI6 / MEDTP,FNMTP,CNMTP,MEDPNT,LMED        
      COMMON /TWO   / TWO(4)        
      EQUIVALENCE     (CORE(1),OS(1),LOSCAR),(OSPRC,OS(2)),        
     1                (OSBOT,OS(3)),(IOSPNT,OS(4)),        
     2                (OS(5),OSCAR(1),FNM(1),FMED(1),PTDIC(1)),        
     3                (MEDTP,FMEDTP),(TWO(4),REUSE)        
      DATA    NXCHKP/ 4HXCHK/, IFIRST / 0 /        
C        
      AND(I,J) = ANDF(I,J)        
      OR(I,J)  = ORF(I,J)        
C        
      NAM1 = NAME1(1)        
      NAM2 = NAME2(1)        
C        
C     SCAN OPTDIC FOR FILE NAME        
C        
      REGEN  = NOFIND        
      NOFIND = 1        
      IF(PTDBOT .LT. PTDTP)  GO TO 200        
      DO 100 II = PTDTP,PTDBOT,3        
      I = PTDBOT + PTDTP - II        
      IF (PTDIC(I).EQ.NAM1 .AND. PTDIC(I+1).EQ.NAM2) GO TO 110        
  100 CONTINUE        
      GO TO 200        
C        
C     FILE IS IN PTDIC - SET REUSE FLAG FOR ALL EQUIVALENCED FILES      
C        
  110 IF (PTDIC(I+2) .GE. 0) GO TO 130        
      DO 120 J = PTDTP,PTDBOT,3        
      IF (AND(PTDIC(J+2),NOFLGS) .EQ. AND(PTDIC(I+2),NOFLGS))        
     1    PTDIC(J+2) = OR(PTDIC(J+2),REUSE)        
  120 CONTINUE        
  130 PTDIC(I+2) = OR(PTDIC(I+2),REUSE)        
      NOFIND = 0        
      GO TO 1000        
C        
C     FILE NOT IN PTDIC - CHECK FNM TABLE IF RESTART IS MODIFIED AND    
C     APPROACH IS NOT DMAP        
C        
  200 IF (START.EQ.ICST .OR. IAPP.EQ.IDMAPP) GO TO 1000        
      IF (REGEN .LT. 0)  GO TO 1000        
      J = FNMTP + 1        
      K = FNMTP + FNM(FNMTP)*3 - 2        
      DO 210 I = J,K,3        
      IF (NAM1.EQ.FNM(I) .AND. NAM2.EQ.FNM(I+1)) GO TO 220        
  210 CONTINUE        
      GO TO 1000        
C        
C     FILE IS IN FNM TABLE - CHECK FOR TABLE ERROR        
C        
  220 IF (FNM(I+2) .LE. 0)  GO TO 900        
C        
C     CLEAR ALL THE MASK WORDS        
C        
      K = FMED(FMEDTP+1)        
      DO 230 L = 1, K        
      FMDMSK(L) = 0        
  230 CONTINUE        
C        
C     SET BIT IN FMDMSK FOR FILE REGENERATION        
C        
      L = ((FNM(I+2)-1)/31) + 1        
      K = FNM(I+2) - 31*(L-1) + 1        
      FMDMSK(L) = OR(FMDMSK(L),TWO(K))        
C        
C     USE FMDMSK AND FMED TABLE TO TURN ON OSCAR EXECUTE FLAGS        
C        
      K  = FMED(FMEDTP+1)        
      J1 = FMEDTP + 2        
      J2 = J1 + FMED(FMEDTP)*FMED(FMEDTP+1) - K        
      INDEX = 0        
      OSPNT = 1        
      DO 350 J = J1,J2,K        
      DO 310 K1 = 1,K        
      JJ = J + K1 - 1        
      IF (AND(FMED(JJ),FMDMSK(K1)) .NE. 0)  GO TO 330        
  310 CONTINUE        
      GO TO 350        
C        
C     NON-ZERO ENTRY FOUND - COMPUTE DMAP SEQUENCE NUMBER FOR FMED ENTRY
C        
  330 N = ((J-J1)/K) + 1        
      IF (AND(OSCAR(IOSPNT+5),NOSGN) .LT. N) GO TO 1000        
C        
C     SET EXECUTINON FLAG FOR ALL OSCAR ENTRIES WITH SAME DMAP SEQ      
C     NUMBER        
C        
  335 IF (AND(OSCAR(OSPNT+5),NOSGN) - N) 345,340,350        
  340 IF (OSCAR(OSPNT+5).LT.0 .OR. (OSCAR(OSPNT+3).EQ.NXCHKP .AND.      
     1    ICPFLG.EQ.0)) GO TO 345        
      IF (IFIRST .EQ. 1) GO TO 342        
      IFIRST = 1        
      CALL PAGE1        
      CALL XGPIMW (12,0,0,0)        
  342 IF (INDEX .EQ. 1) GO TO 344        
      INDEX = 1        
      CALL XGPIMW (3,NAM1,NAM2,0)        
  344 CALL XGPIMW (4,0,0,OSCAR(OSPNT))        
      NOFIND = -1        
      OSCAR(OSPNT+5) = ORF(OSCAR(OSPNT+5),ISGNON)        
  345 IF (OSPNT .GE. OSBOT) GO TO 350        
      OSPNT = OSPNT + OSCAR(OSPNT)        
      GO TO 335        
  350 CONTINUE        
C        
C     MAKE SURE SOME MODULES WERE TURNED ON        
C        
      IF (NOFIND .NE. -1)  GO TO 900        
C        
C     NEGATE FNM TABLE ENTRY FOR THIS FILE        
C        
      FNM(I+2) = -FNM(I+2)        
C        
C     TURN OFF REUSE FLAGS IN PTDIC        
C        
      IF (PTDBOT.LE.PTDTP .OR. IFLAG.NE.0) GO TO 1000        
      J = COMPLF(REUSE)        
      DO 360 I = PTDTP,PTDBOT,3        
      PTDIC(I+2) = ANDF(J,PTDIC(I+2))        
  360 CONTINUE        
      GO TO 1000        
C        
C     D I A G N O S T I C    M E S S A G E S        
C        
C     MED OR FILE TABLE INCORRECT FOR REGENERATING FILE        
C        
  900 CALL XGPIDG (41,NAM1,NAM2,FNM(I+2))        
      NOFIND =-1        
      NOGO   = 2        
 1000 RETURN        
      END        
