!------------------------------------------------------------------------------!
!  The Community Multiscale Air Quality (CMAQ) system software is in           !
!  continuous development by various groups and is based on information        !
!  from these groups: Federal Government employees, contractors working        !
!  within a United States Government contract, and non-Federal sources         !
!  including research institutions.  These groups give the Government          !
!  permission to use, prepare derivative works of, and distribute copies       !
!  of their work in the CMAQ system to the public and to permit others         !
!  to do so.  The United States Environmental Protection Agency                !
!  therefore grants similar permission to use the CMAQ system software,        !
!  but users are requested to provide copies of derivative works or            !
!  products designed to operate in the CMAQ system to the United States        !
!  Government without restrictions as to use by others.  Software              !
!  that is used with the CMAQ system but distributed under the GNU             !
!  General Public License or the GNU Lesser General Public License is          !
!  subject to their copyright restrictions.                                    !
!------------------------------------------------------------------------------!

SUBROUTINE init_x

!-------------------------------------------------------------------------------
! Name:     Initialize X arrays.
! Purpose:  Initializes X arrays.
! Revised:  26 Jan 1997  Created for MCIP and generalized CTM.  (D. Byun)
!           04 Feb 1998  Changed include method nonglobal includes.  (D. Byun)
!           30 Apr 1999  Replaced PSTAR with PRSFC.  (D. Byun)
!           19 Sep 2001  Converted to free-form f90.  Removed SDATE and STIME
!                        from routine.  Changed routine name from INITX to
!                        INIT_X.  (T. Otte)
!           14 Jan 2002  Added new dry deposition species, methanol.
!                        (Y. Wu and T. Otte)
!           23 Jan 2002  Changed initialization of X-variables from 0.0 to
!                        BADVAL3 to avoid confusion.  (T. Otte)
!           27 Feb 2002  Renamed XSURF1 as XTEMP1P5 and XSURF2 as XWIND10.
!                        (T. Otte)
!           18 Mar 2003  Removed XJDRATE.  (T. Otte)
!           09 Jun 2003  Added XF2DEF, XSNOCOV, XDELTA, XLSTWET, XRH.  Added
!                        new dry deposition species:  N2O5, NO3, and generic
!                        aldehyde.  (D. Schwede, T. Otte, and J. Pleim)
!                        Removed extraneous variables from output.  (T. Otte)
!           09 Aug 2004  Added XQGRAUP, XWSPD10, XWDIR10, and XT2.  Removed
!                        XFLAGS, XINDEX, and XNAMES.  (T. Otte and D. Schwede)
!           01 Dec 2004  Added XPURB.  (T. Otte)
!           04 Apr 2005  Removed unused variables XREGIME and XRTOLD.  Added
!                        initialization of WRF variables.  Changed XUU and XVV
!                        to XUU_D and XVV_D, and changed XUHAT and XVHAT to
!                        XUU_S and XVV_T.  Added pointer indices for optional
!                        chlorine and mercury species.  Removed XENTRP.  Added
!                        XU10 and XV10.  (T. Otte, S.-B. Kim, G. Sarwar, and
!                        R. Bullock)
!           19 Aug 2005  Removed initialization of XDEPIDX and XVD.  Moved
!                        XDEPSPC to INIT_DEPV.  Removed unused variables XCAPG,
!                        XMMPASS, and XFSOIL.  Removed array XRH and made it a
!                        local scalar in M3DRY.  (T. Otte and W. Hutzell)
!           14 Jul 2006  Removed XDELTA and XLSTWET to be local variables in
!                        M3DRY.  Added XLWMASK.  (T. Otte)
!           30 Jul 2007  Changed XUSTAR and XRADYN to 2D arrays without a
!                        dimension for fractional land use that was required
!                        for RADMdry.  Removed XRBNDY, XCFRACH, XCFRACM,
!                        XCFRACL, XTEMP1P5, and XTEMP10.  Create 2-m
!                        temperature array even if it is not part of input
!                        meteorology.  Changed 2-m temperature from XT2 to
!                        XTEMP2.  Removed internal variables for emissivity
!                        and net radiation.  Removed XF2DEF and XRSTMIN to be
!                        local variables in RESISTCALC.  Added XPSTAR0.  Added
!                        initialization for XDENSAF_REF.  (T. Otte)
!           21 Apr 2008  Added 2-m mixing ratio (XQ2) and turbulent kinetic
!                        energy (XTKE) arrays.  (T. Otte)
!           29 Oct 2009  Added potential vorticity (XPVC), Coriolis (XCORL),
!                        and potential temperature (XTHETA).  Added map-scale
!                        factors squared (on cross points, XMAPC2).  Added
!                        XLATU, XLONU, XMAPU, XLATV, XLONV, and XMAPV.  Allow
!                        output variable PURB to be created with urban model
!                        in WRF.  (T. Otte)
!           14 Dec 2010  Added sea ice.  (T. Otte)
!           11 Aug 2011  Replaced module PARMS3 with I/O API module M3UTILIO.
!                        (T. Otte)
!           07 Sep 2011  Updated disclaimer.  (T. Otte)
!           10 Apr 2015  Added new array XCFRAC3D to pass 3D resolved cloud
!                        fraction to output.  (T. Spero)
!           21 Aug 2015  Changed latent heat flux from QFX to LH.  Fill THETA
!                        and add moisture flux (QFX) for IFMOLACM.  (T. Spero)
!           17 Sep 2015  Changed IFMOLACM to IFMOLPX.  (T. Spero)
!           16 Mar 2018  Added SNOWH to output.  Added XMUHYB to support hybrid
!                        vertical coordinate in WRF output.  Added XLUFRAC2,
!                        XMOSCATIDX, XLAI_MOS, XRA_MOS, XRS_MOS, XTSK_MOS, and
!                        XZNT_MOS to support NOAH Mosaic land-surface model.
!                        Added XZSOIL to define soil layer depths, and added
!                        3D soil arrays, XSOIT3D and XSOIM3D.  Added
!                        XWSPDSFC and XXLAIDYN for Noah.  (T. Spero)
!-------------------------------------------------------------------------------

  USE mcipparm
  USE xvars
  USE m3utilio, ONLY: badval3
  USE metinfo

  IMPLICIT NONE
 
!-------------------------------------------------------------------------------
! Initialize X-arrays.
!-------------------------------------------------------------------------------

  xx3face (:)     = badval3  ;    xx3midl (:)     = badval3

  xalbedo (:,:)   = badval3  ;    xcfract (:,:)   = badval3
  xcldbot (:,:)   = badval3  ;    xcldtop (:,:)   = badval3
  xdenss  (:,:)   = badval3  ;    xdluse  (:,:)   = badval3
  xglw    (:,:)   = badval3  ;    xgsw    (:,:)   = badval3
  xhfx    (:,:)   = badval3  ;    xlai    (:,:)   = badval3
  xlatc   (:,:)   = badval3  ;    xlatd   (:,:)   = badval3
  xlatu   (:,:)   = badval3  ;    xlatv   (:,:)   = badval3
  xlh     (:,:)   = badval3  ;    xlonc   (:,:)   = badval3
  xlond   (:,:)   = badval3  ;    xlonu   (:,:)   = badval3
  xlonv   (:,:)   = badval3  ;    xlwmask (:,:)   = badval3
  xmapc   (:,:)   = badval3  ;    xmapc2  (:,:)   = badval3
  xmapd   (:,:)   = badval3  ;    xmapu   (:,:)   = badval3
  xmapv   (:,:)   = badval3  ;    xmol    (:,:)   = badval3
  xpbl    (:,:)   = badval3  ;    xprsfc  (:,:)   = badval3
  xq2     (:,:)   = badval3  ;    xradyn  (:,:)   = badval3
  xrainc  (:,:)   = badval3  ;    xrainn  (:,:)   = badval3
  xrgrnd  (:,:)   = badval3  ;    xrib    (:,:)   = badval3
  xrstom  (:,:)   = badval3  ;    xseaice (:,:)   = badval3
  xsnocov (:,:)   = badval3  ;    xsnowh  (:,:)   = badval3
  xtemp2  (:,:)   = badval3  ;    xtempg  (:,:)   = badval3
  xtopo   (:,:)   = badval3  ;    xustar  (:,:)   = badval3
  xveg    (:,:)   = badval3  ;    xwbar   (:,:)   = badval3
  xwdir10 (:,:)   = badval3  ;    xwr     (:,:)   = badval3 
  xwspd10 (:,:)   = badval3  ;    xwstar  (:,:)   = badval3
  xzruf   (:,:)   = badval3

  IF ( met_hybrid == 2 ) THEN
    xmuhyb(:,:)   = badval3
  ENDIF

  IF ( ifw10m ) THEN
    xu10  (:,:)   = badval3  ;    xv10    (:,:)   = badval3
  ENDIF

  IF ( ( iflufrc ) .OR. ( met_urban_phys >= 1 ) ) THEN
    xpurb (:,:)   = badval3
  ENDIF

  IF ( lpv > 0 ) THEN
    xcorl (:,:)   = badval3
  ENDIF

  IF ( ifmolpx ) THEN
    xqfx  (:,:)   = badval3
  ENDIF

  IF ( ifsoil ) THEN
    xsltyp(:,:)   = badval3
    xt2a  (:,:)   = badval3
    xtga  (:,:)   = badval3  
    xw2a  (:,:)   = badval3  
    xwga  (:,:)   = badval3
  ENDIF

  IF ( met_model == 1 ) THEN  ! MM5
    xpstar0    (:,:)   = badval3
    xdensaf_ref(:,:,:) = badval3
  ENDIF

  IF ( met_model == 2 ) THEN  ! WRF
    xmu   (:,:)   = badval3
    xgeof (:,:,:) = badval3
  ENDIF

  x3htf   (:,:,:) = badval3  ;    x3htm   (:,:,:) = badval3
  x3jacobf(:,:,:) = badval3  ;    x3jacobm(:,:,:) = badval3
  xcldwtr (:,:,:) = badval3  ;    xdensam (:,:,:) = badval3
  xdenswm (:,:,:) = badval3  ;    xdx3htf (:,:,:) = badval3
  xluse   (:,:,:) = badval3  ;    xpresm  (:,:,:) = badval3
  xqgraup (:,:,:) = badval3  ;    xqice   (:,:,:) = badval3
  xqsnow  (:,:,:) = badval3  ;    xranwtr (:,:,:) = badval3
  xtempm  (:,:,:) = badval3  ;    xuu_d   (:,:,:) = badval3
  xuu_s   (:,:,:) = badval3  ;    xvv_d   (:,:,:) = badval3
  xvv_t   (:,:,:) = badval3  ;    xwhat   (:,:,:) = badval3
  xwvapor (:,:,:) = badval3  ;    xwwind  (:,:,:) = badval3

  IF ( iftke ) THEN
    xtke  (:,:,:) = badval3
  ENDIF

  IF ( lpv > 0 ) THEN
    xpvc  (:,:,:) = badval3
  ENDIF

  IF ( lpv > 0 .OR. ifmolpx ) THEN
    xtheta(:,:,:) = badval3
  ENDIF

  IF ( ifcld3d ) THEN
    xcfrac3d(:,:,:) = badval3
  ENDIF

  IF ( ( ifsoil ) .AND. ( metsoi > 0 ) ) THEN
    xzsoil (:)     = badval3
    xsoit3d(:,:,:) = badval3
    xsoim3d(:,:,:) = badval3
  ENDIF

  IF ( nummosaic > 0 ) THEN
    xlufrac2  (:,:,:) = badval3
    xmoscatidx(:,:,:) = badval3
    xlai_mos  (:,:,:) = badval3
    xra_mos   (:,:,:) = badval3
    xrs_mos   (:,:,:) = badval3
    xtsk_mos  (:,:,:) = badval3
    xznt_mos  (:,:,:) = badval3
    xwspdsfc  (:,:)   = badval3
    xxlaidyn  (:,:)   = badval3
  ENDIF

END SUBROUTINE init_x
