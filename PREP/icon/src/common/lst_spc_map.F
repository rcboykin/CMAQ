
!------------------------------------------------------------------------!
!  The Community Multiscale Air Quality (CMAQ) system software is in     !
!  continuous development by various groups and is based on information  !
!  from these groups: Federal Government employees, contractors working  !
!  within a United States Government contract, and non-Federal sources   !
!  including research institutions.  These groups give the Government    !
!  permission to use, prepare derivative works of, and distribute copies !
!  of their work in the CMAQ system to the public and to permit others   !
!  to do so.  The United States Environmental Protection Agency          !
!  therefore grants similar permission to use the CMAQ system software,  !
!  but users are requested to provide copies of derivative works or      !
!  products designed to operate in the CMAQ system to the United States  !
!  Government without restrictions as to use by others.  Software        !
!  that is used with the CMAQ system but distributed under the GNU       !
!  General Public License or the GNU Lesser General Public License is    !
!  subject to their copyright restrictions.                              !
!------------------------------------------------------------------------!


C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /project/yoj/arc/ICON/src/common/lst_spc_map.F,v 1.2 2011/10/21 16:41:52 yoj Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%


      SUBROUTINE LST_SPC_MAP( LOGUNIT, NSPCS_IN, NSPCS_OUT,  
     &                        SPMAP, NML_IC_NAME,
     &                        INFL_SP_NAME, SPNAME_OUT )

C***********************************************************************
 
C  Function:  To list a table showing the relationship between species
C             on the CTM conc file(s) and the species on the output IC
C             file(s) 
              
C  Preconditions: None
  
C  Key Subroutines/Functions Called: None
 
C  Revision History: Prototype created by Jerry Gipson, January, 1998
C    06 Jun 11 J.Young: Replaced I/O API include files with UTILIO_DEFN
C    13 Jun 11 J.Young: Convert for Namelist redesign
C    21 May 12 J.Young: Replaced IC_PARMS include file with an F90 module
 
C***********************************************************************

      USE UTILIO_DEFN
      USE CGRID_SPCS     ! CGRID mechanism species
      USE IC_PARMS       ! ICON parameters

      IMPLICIT NONE     

C Include Files:

C Arguments:
      INTEGER :: LOGUNIT      ! Ouput log unit number
      INTEGER :: NSPCS_IN     ! Total no. of species in input file
      INTEGER :: NSPCS_OUT    ! Number of IC species on output file(s)
      INTEGER :: SPMAP( * )   ! Map of output species to input species
      CHARACTER( 16 ) :: NML_IC_NAME( * )  ! List of all species names in CGRID_SPCS
      CHARACTER( 16 ) :: INFL_SP_NAME( * ) ! List of species on the input file
      CHARACTER( 16 ) :: SPNAME_OUT( * )   ! Output file species names

C Parameters: None

C External Functions:
      INTEGER FINDEX      ! Finds the index of a number in a list 

C Local Variables:
      CHARACTER( 16 ) :: BLANK = ' '    ! Blank chars
      CHARACTER( 16 ) :: PNAME = 'LST_SPC_MAP'  ! Procedure Name
      CHARACTER( 16 ) :: SUROUT         ! *.NML surrogate name
      CHARACTER( 96 ) :: MSG = ' '

!     CHARACTER( 16 ) :: IC_SP_NF( NSPCSD ) ! IC species for which ICs not computed 
      CHARACTER( 16 ), ALLOCATABLE :: IC_SP_NF( : ) ! IC species for which ICs not computed 

      CHARACTER( 16 ) :: INFL_SP_NF( MX_INFL_SP )  ! Input file species not
                                                   ! referenced in computing ICs
      INTEGER NSPCS       ! Total number of Namelist species
      INTEGER I, N, SPC   ! Loop indices
      INTEGER NSP         ! species counter
      INTEGER SPC_INDX    ! IC species index
      INTEGER SUR_INDX    ! IC Surrogate name index
      INTEGER ALST        ! Allocate status

      LOGICAL LFOUND           ! Flag for name found in list
!     LOGICAL :: LUSED( NSPCSD )  ! Flag for NML species being used
      LOGICAL, ALLOCATABLE :: LUSED( : )  ! Flag for NML species being used
   
C***********************************************************************

      NSPCS = N_GC_SPC + N_AE_SPC + N_NR_SPC + N_TR_SPC

      ALLOCATE( IC_SP_NF( NSPCS ), LUSED( NSPCS ), STAT = ALST )
      IF ( ALST .NE. 0 ) THEN
         MSG = 'Error allocating IC_SP_NF or LUSED'
         CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT2 )
      END IF

      DO N = 1, NSPCS
         LUSED( N ) = .FALSE.
         IC_SP_NF = BLANK
      END DO

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  List species table
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
C gas-phase species section

      WRITE( LOGUNIT, 92040 )

      DO N = 1, NSPCS_OUT

         SPC_INDX = INDEX1( SPNAME_OUT( N ), N_GC_SPC, GC_SPC ) 
         SUR_INDX = INDEX1( SPNAME_OUT( N ), N_GC_ICBC, GC_ICBC )

         IF ( SUR_INDX .NE. 0 ) THEN 
            SPC_INDX = GC_ICBC_MAP( SUR_INDX ) 
         ELSE
            SUR_INDX = FINDEX( SPC_INDX, N_GC_ICBC, GC_ICBC_MAP )
         END IF

         IF ( SPC_INDX .NE. 0 .OR. SUR_INDX .NE. 0 ) THEN
            LUSED( SPC_INDX ) = .TRUE.
            IF ( SUR_INDX .NE. 0 ) THEN
               SUROUT = GC_ICBC( SUR_INDX )
            ELSE
               SUROUT = BLANK
            END IF
 
            WRITE( LOGUNIT, 92060 ) GC_SPC( SPC_INDX ), SUROUT,
     &                              INFL_SP_NAME( SPMAP( N ) )
         END IF

      END DO

C aerosol map
      DO N = 1, NSPCS_OUT

         SPC_INDX = INDEX1( SPNAME_OUT( N ), N_AE_SPC, AE_SPC ) 
         SUR_INDX = INDEX1( SPNAME_OUT( N ), N_AE_ICBC, AE_ICBC )

         IF ( SUR_INDX .NE. 0 ) THEN 
            SPC_INDX = AE_ICBC_MAP( SUR_INDX ) 
         ELSE
            SUR_INDX = FINDEX( SPC_INDX, N_AE_ICBC, AE_ICBC_MAP )
         END IF

         IF ( SPC_INDX .NE. 0 .OR. SUR_INDX .NE. 0) THEN
            LUSED( SPC_INDX + N_GC_SPC ) = .TRUE.
            IF ( SUR_INDX .NE. 0 ) THEN
               SUROUT = AE_ICBC( SUR_INDX )
            ELSE
               SUROUT = BLANK
            END IF
            WRITE( LOGUNIT, 92060 ) AE_SPC( SPC_INDX ), SUROUT,
     &                              INFL_SP_NAME( SPMAP ( N ) )
         END IF

      END DO

C nonreactive species map
      DO N = 1, NSPCS_OUT

         SPC_INDX = INDEX1( SPNAME_OUT( N ), N_NR_SPC, NR_SPC ) 
         SUR_INDX = INDEX1( SPNAME_OUT( N ), N_NR_ICBC, NR_ICBC )

         IF ( SUR_INDX .NE. 0 ) THEN 
            SPC_INDX = NR_ICBC_MAP( SUR_INDX ) 
         ELSE
            SUR_INDX = FINDEX( SPC_INDX, N_NR_ICBC, NR_ICBC_MAP )
         END IF

         IF ( SPC_INDX .NE. 0 .OR. SUR_INDX .NE. 0) THEN
            LUSED( SPC_INDX + N_GC_SPC + N_AE_SPC) = .TRUE.
            IF ( SUR_INDX .NE. 0 ) THEN
               SUROUT = NR_ICBC( SUR_INDX )
            ELSE
               SUROUT = BLANK
            END IF
            WRITE( LOGUNIT, 92060 ) NR_SPC( SPC_INDX ), SUROUT,
     &                              INFL_SP_NAME( SPMAP ( N ) )
         END IF

      END DO

C tracer map
      DO N = 1, NSPCS_OUT

         SPC_INDX = INDEX1( SPNAME_OUT( N ), N_TR_SPC, TR_SPC ) 
         SUR_INDX = INDEX1( SPNAME_OUT( N ), N_TR_ICBC, TR_ICBC )

         IF ( SUR_INDX .NE. 0 ) THEN 
            SPC_INDX = TR_ICBC_MAP( SUR_INDX ) 
         ELSE
            SUR_INDX = FINDEX( SPC_INDX, N_TR_ICBC, TR_ICBC_MAP )
         END IF

         IF ( SPC_INDX .NE. 0 .OR. SUR_INDX .NE. 0 ) THEN
            LUSED( SPC_INDX + N_GC_SPC + N_AE_SPC + N_NR_SPC ) = .TRUE.
            IF ( SUR_INDX .NE. 0 ) THEN
               SUROUT = TR_ICBC( SUR_INDX )
            ELSE
               SUROUT = BLANK
            END IF
            WRITE( LOGUNIT, 92060 ) TR_SPC( SPC_INDX ), SUROUT,
     &                              INFL_SP_NAME( SPMAP ( N ) )
         END IF

      END DO

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Report on *.NML species with no ICs and input file species not referenced
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
C list *.NML species with no IC output
      NSP = 0
      DO N = 1, NSPCS

         IF ( .NOT. LUSED( N ) ) THEN
            NSP = NSP + 1
            IC_SP_NF( NSP ) = NML_IC_NAME( N )
         END IF
      END DO

      IF ( NSP .GT. 0 ) THEN
         WRITE( LOGUNIT, 92080 ) NSP
         WRITE( LOGUNIT, 92100 ) ( IC_SP_NF( N ), N = 1, NSP )
      END IF
         
C list surrogate species not found on the input file
      NSP = 0
      DO N = 1, N_GC_ICBC
         SUR_INDX = INDEX1( GC_ICBC( N ), NSPCS_OUT, SPNAME_OUT )
         IF ( SUR_INDX .EQ. 0 ) THEN
            NSP = NSP + 1
            IC_SP_NF( NSP ) = GC_ICBC( N )
         END IF
      END DO
 
      DO N = 1, N_AE_ICBC
         SUR_INDX = INDEX1( AE_ICBC( N ), NSPCS_OUT, SPNAME_OUT )
         IF ( SUR_INDX .EQ. 0 ) THEN
            NSP = NSP + 1
            IC_SP_NF( NSP ) = AE_ICBC( N )
         END IF
      END DO
              
      DO N = 1, N_NR_ICBC
         SUR_INDX = INDEX1( NR_ICBC( N ), NSPCS_OUT, SPNAME_OUT )
         IF ( SUR_INDX .EQ. 0 ) THEN
            NSP = NSP + 1
            IC_SP_NF( NSP ) = NR_ICBC( N )
         END IF
      END DO

      DO N = 1, N_TR_ICBC
         SUR_INDX = INDEX1( TR_ICBC( N ), NSPCS_OUT, SPNAME_OUT )
         IF ( SUR_INDX .EQ. 0 ) THEN
            NSP = NSP + 1
            IC_SP_NF( NSP ) = TR_ICBC( N )
         END IF
      END DO

      IF ( NSP .GT. 0 ) THEN
         WRITE( LOGUNIT, 92120 ) NSP
         WRITE( LOGUNIT, 92100 ) ( IC_SP_NF( N ), N = 1, NSP )
      END IF

C list input file species not referenced
      NSP = 0
      DO N = 1, NSPCS_IN

         LFOUND = .FALSE.

         DO I = 1, NSPCS_OUT
            IF ( INFL_SP_NAME( N ) .EQ. INFL_SP_NAME( SPMAP ( I ) ) )
     &         LFOUND = .TRUE.
         END DO
            
         IF ( .NOT. LFOUND ) THEN
            NSP = NSP + 1
            INFL_SP_NF( NSP ) = INFL_SP_NAME( N )
         END IF

      END DO

      IF ( NSP .GT. 0 ) THEN
         WRITE( LOGUNIT, 92140 ) NSP
         WRITE( LOGUNIT, 92100 ) ( INFL_SP_NF( N ), N = 1, NSP )
      END IF

      WRITE( LOGUNIT, 92160 )

      RETURN

C************************* FORMAT STATEMENTS ***************************

92040 FORMAT(  / 5X, 'Species Map for Initial Concentrations' 
     &        // 5X, 'NML Species', 7X, 'NML Surrogate',
     &           5X, 'Input File Species Used' )

92060 FORMAT(    5X, A16, 2X, A16, 2X, A16 )

92080 FORMAT(  / 5X, 'WARNING: The following', I4, ' *.NML species could not be '
     &               'mapped to a species '
     &         /14X, 'in the input file: ICs were not generated for them.' )

!2100 FORMAT(   15X, 4( A, 2X ) )
92100 FORMAT( ( 15X, A, 3( 2X, A ) ) )

92120 FORMAT(  / 5X, 'WARNING: The following', I4, ' *.NML surrogate species ',
     &               'could not be found in the input file.'
     &         / 5X, '         ICs were generated only when the *.NML',
     &               ' species could be mapped to an input species.' )

92140 FORMAT(  / 5X, 'WARNING: The following', I4, ' species in the input file ',
     &               'were not referenced:' )

92160 FORMAT(  / 5X, 'NOTE: All scale factors will be applied in the ',
     &               'CTM.' )

      END
