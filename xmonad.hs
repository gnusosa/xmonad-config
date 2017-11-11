import XMonad
import XMonad.Config.Gnome
import XMonad.Layout.PerScreen
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.Tabbed
import XMonad.Layout.Named
import XMonad.Layout.Reflect
import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Layout.BoringWindows
import XMonad.Layout.Decoration
import XMonad.Layout.TwoPane
import XMonad.Layout.ComboP
import XMonad.Layout.ThreeColumns
import XMonad.Hooks.ManageDocks
import XMonad.Layout.WindowNavigation
import qualified Data.Map as M
import qualified XMonad.StackSet as W

addTopBar   = noFrillsDeco shrinkText topBarTheme
mySpacing   = spacing gap
myGaps      = gaps [(U, gap),(D, gap),(L, gap),(R, gap)]

base03  = "#002b36"
base02  = "#073642"
base01  = "#586e75"
base00  = "#657b83"
base0   = "#839496"
base1   = "#93a1a1"
base2   = "#eee8d5"
base3   = "#fdf6e3"
yellow  = "#b58900"
orange  = "#cb4b16"
red     = "#dc322f"
magenta = "#d33682"
violet  = "#6c71c4"
blue    = "#268bd2"
cyan    = "#2aa198"
green       = "#859900"

-- sizes
gap         = 3
topbar      = 5
border      = 0
prompt      = 20
status      = 20

myNormalBorderColor     = "#000000"
myFocusedBorderColor    = active

active      = blue
activeWarn  = red
inactive    = base02
focusColor  = blue
unfocusColor = base02

smallMonResWidth = 1366

myFont      = "-*-terminus-medium-*-*-*-*-160-*-*-*-*-*-*"
topBarTheme = def
    { fontName              = myFont
    , inactiveBorderColor   = base03
    , inactiveColor         = base03
    , inactiveTextColor     = base03
    , activeBorderColor     = active
    , activeColor           = active
    , activeTextColor       = active
    , urgentBorderColor     = red
    , urgentTextColor       = yellow
    , decoHeight            = topbar
    }

myTabTheme = def
    { fontName              = myFont
    , activeColor           = active
    , inactiveColor         = base02
    , activeBorderColor     = active
    , inactiveBorderColor   = base02
    , activeTextColor       = base03
    , inactiveTextColor     = base00
    }


smartTallTabbed = named "Smart Tall-Tabbed"
                  $ avoidStruts
                  $ ifWider smallMonResWidth wideScreen normalScreen
  where
    wideScreen   = combineTwoP (TwoPane 0.03 (3/4))
                   (smartTall)
                   (smartTabbed)
                   (ClassName "Google-chrome")
    normalScreen = combineTwoP (TwoPane 0.03 (2/3))
                   (smartTall)
                   (smartTabbed)
                   (ClassName "Google-chrome")

smartTall = named "Smart Tall"
            $ addTopBar
            $ mySpacing
            $ myGaps
            $ boringAuto
            $ ifWider smallMonResWidth wideScreen normalScreen
  where
    wideScreen = reflectHoriz $ Tall 1 0.03 (2/3)
    normalScreen = Mirror $ Tall 1 0.03 (4/5)

smartTabbed = named "Smart Tabbed"
              $ addTopBar
              $ myGaps
              $ tabbed shrinkText myTabTheme

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList
                                                [
                                                  ((modm,                 xK_Right), sendMessage $ Go R)
                                                , ((modm,                 xK_Left ), sendMessage $ Go L)
                                                , ((modm,                 xK_Up   ), sendMessage $ Go U)
                                                , ((modm,                 xK_Down ), sendMessage $ Go D)
                                                , ((modm .|. controlMask, xK_Right), sendMessage $ Swap R)
                                                , ((modm .|. controlMask, xK_Left ), sendMessage $ Swap L)
                                                , ((modm .|. controlMask, xK_Up   ), sendMessage $ Swap U)
                                                , ((modm .|. controlMask, xK_Down ), sendMessage $ Swap D)
                                                , ((modm .|. controlMask, xK_s ), sendMessage $ SwapWindow)
                                                , ((modm .|. controlMask, xK_w ), windows W.swapUp)
                                                , ((modm .|. controlMask, xK_r ), windows W.swapDown)
                                                ]

myManageHook = composeAll [
                (className =? "Gnome-calendar") --> doShift "1"
                , (className =? "Emacs" <&&> title =? "*Org Agenda( )*") --> doShift "1"
                , (className =? "Google-chrome") --> doShift "2"
                , (className =? "Emacs") --> doShift "3"
                , (className =? "Emacs" <&&> title =? "*Group*") --> doShift "4"
                , (className =? "Gnome-terminal") --> doShift "5"
                -- , (className =? "XEyes") --> doShift "7"
               ]

-- myStartupHook = startup
-- startup = do
--           spawn "gnome-calendar"
--           spawn "emacs"
--           spawn "google-chrome"
--           -- spawn "emacsclient -c -e \'(org-agenda \" \" \" \")\'"
--           -- spawn "emacsclient -c -e \'(gnus)\'"
--           spawn "gnome-terminal"

myLayout = windowNavigation (smartTallTabbed) ||| tiled ||| Mirror tiled ||| Full ||| threeCol ||| threeColMid
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled   = Tall nmaster delta ratio
    threeCol = ThreeCol nmaster delta ratio
    threeColMid = ThreeColMid nmaster delta ratio
    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100


main = xmonad $ gnomeConfig
     {
       workspaces = ["1","2","3","4","5","6","7","8","9"]
     , layoutHook = myLayout
     , modMask = mod4Mask
     , manageHook = myManageHook <+> manageHook gnomeConfig
     , keys = myKeys <+> keys def
     -- , startupHook = myStartupHook
     }
