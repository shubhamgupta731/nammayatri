{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.TripDetailsScreen.View where

import Common.Types.App
import Screens.TripDetailsScreen.ComponentConfig
import Animation as Anim
import Common.Types.App (LazyCheck(..))
import Components.GenericHeader as GenericHeader
import Components.PrimaryButton as PrimaryButton
import Components.SourceToDestination as SourceToDestination
import Data.Maybe (fromMaybe, isJust)
import Effect (Effect)
import Engineering.Helpers.Commons as EHC
import Font.Size as FontSize
import Font.Style as FontStyle
import Helpers.Utils (fetchImage, FetchImageFrom(..), getVehicleVariantImage)
import Language.Strings (getString)
import Language.Types (STR(..))
import MerchantConfig.Utils (Merchant(..), getMerchant, getValueFromConfig)
import Prelude (Unit, const, map, not, show, unit, ($), (&&), (*), (/), (<<<), (<>), (==), (||))
import Prelude (show, (<>))
import PrestoDOM (Gravity(..), Length(..), Margin(..), Orientation(..), Padding(..), PrestoDOM, Screen, Visibility(..), afterRender, alignParentBottom, background, color, cornerRadius, editText, fontStyle, frameLayout, gravity, height, hint, horizontalScrollView, imageUrl, imageView, imageWithFallback, linearLayout, margin, onBackPressed, onChange, onClick, orientation, padding, pattern, relativeLayout, scrollBarX, scrollView, stroke, text, textSize, textView, visibility, weight, width)
import PrestoDOM.Animation as PrestoAnim
import Screens.TripDetailsScreen.Controller (Action(..), ScreenOutput, eval)
import Screens.Types as ST
import Styles.Colors as Color
import Common.Styles.Colors as Colors

screen :: ST.TripDetailsScreenState -> Screen Action ST.TripDetailsScreenState ScreenOutput 
screen initialState = 
  { initialState
  , view
  , name : "TripDetailsScreen"
  , globalEvents : []
  , eval
  }

view
  :: forall w 
  . (Action -> Effect Unit) -> ST.TripDetailsScreenState -> PrestoDOM (Effect Unit) w 
view push state =
  Anim.screenAnimation $
  relativeLayout
  [ height MATCH_PARENT
  , width MATCH_PARENT
  , orientation VERTICAL
  , background Color.white900
  , onBackPressed push (const BackPressed)
  , afterRender push (const AfterRender)
  ][linearLayout
      [ height MATCH_PARENT
      , width MATCH_PARENT
      , orientation VERTICAL
      ][  GenericHeader.view (push <<< GenericHeaderActionController) (genericHeaderConfig state)
        , scrollView
          [ height MATCH_PARENT
            , width MATCH_PARENT
            , orientation VERTICAL
          ][ 
            linearLayout
              [ height MATCH_PARENT
              , width MATCH_PARENT
              , orientation VERTICAL
              ][ 
                scrollView
                  [ width MATCH_PARENT
                  , height WRAP_CONTENT
                  , visibility if state.props.issueReported then GONE else VISIBLE
                  ][  linearLayout
                      [ height WRAP_CONTENT
                      , width MATCH_PARENT
                      , orientation VERTICAL
                      , background Color.blue600
                      , padding (Padding 16 16 16 16)
                      ][ tripDetailsView state
                      , separatorView 
                      , tagView state $ tagList state
                      , tripDataView push state
                      , separatorView 
                      , SourceToDestination.view (push <<< SourceToDestinationActionController) (sourceToDestinationConfig state)
                      ]
                    ]
                , linearLayout
                [ width MATCH_PARENT
                , height WRAP_CONTENT
                , visibility if state.props.issueReported then GONE else VISIBLE
                ][  linearLayout
                    [ height WRAP_CONTENT
                    , width MATCH_PARENT
                    , padding (Padding 16 16 16 16)
                    , orientation VERTICAL
                    ][ reportIssueView state push
                      , linearLayout
                    [ height WRAP_CONTENT
                    , width MATCH_PARENT
                    , orientation VERTICAL
                    , padding $ PaddingVertical 10 10
                    ][ linearLayout
                       [ height WRAP_CONTENT
                       , width MATCH_PARENT
                       , orientation HORIZONTAL
                       , onClick push (const HelpAndSupport)
                        ][ imageView
                          [ imageWithFallback $ fetchImage FF_ASSET "ny_ic_support"
                          , height $ V 17
                          , width $ V 20
                          , margin $ MarginRight 7
                          ]
                          , textView
                          ([ text (getString HELP_AND_SUPPORT)
                           , color Color.black800
                           , weight 1.0
                           ] <> FontStyle.body1 TypoGraphy
                          )
                          , imageView
                          [ width $ V 18
                          , height $ V 18
                          , imageWithFallback $ fetchImage FF_ASSET "ny_ic_chevron_right_grey"
                          ]
                        ]
                      ]
                    ]
                  ]
                , issueReportedView state push
              ]
            ]
        ]
      
   
    , linearLayout
      [ height WRAP_CONTENT
      , width MATCH_PARENT
      , margin (MarginTop 16)
      , gravity BOTTOM
      , visibility if state.props.reportIssue then VISIBLE else GONE
      , alignParentBottom "true,-1"
      ][PrimaryButton.view (push <<< PrimaryButtonActionController state ) (primaryButtonConfig state)]
    ]


tagView :: forall w. ST.TripDetailsScreenState -> (Array ST.Tag) -> PrestoDOM (Effect Unit) w 
tagView state config =
  horizontalScrollView 
  [ width MATCH_PARENT
  , height WRAP_CONTENT
  , margin $ MarginVertical 0 15
  , visibility if anyTag then VISIBLE else GONE
  , scrollBarX false
  ][linearLayout
    [ width MATCH_PARENT
    , height WRAP_CONTENT
    ](map (\item ->
      linearLayout
      [ width WRAP_CONTENT
      , height WRAP_CONTENT
      , cornerRadius 26.0
      , background item.background
      , visibility if item.visibility then VISIBLE else GONE
      , padding $ Padding 12 5 12 5
      , margin $ MarginRight 5
      ][  imageView
          [ imageWithFallback $ fetchImage FF_ASSET item.image
          , height $ V 16
          , width $ V 16
          ]
        , textView $
          [ width WRAP_CONTENT
          , height WRAP_CONTENT
          , text item.text
          , color item.textColor
          , margin $ MarginLeft 5
          ] <> FontStyle.tags TypoGraphy
      ]) config)
  ]
  where 
  anyTag = isJust state.data.customerExtraFee || state.data.purpleTagVisibility || state.data.gotoTagVisibility || state.data.spLocTagVisibility


tagList :: ST.TripDetailsScreenState -> Array ST.Tag
tagList state = [
  {background : Colors.yellow200, image : "ny_ic_tip_icon", visibility : isJust state.data.customerExtraFee, text : "₹" <> (show (fromMaybe 0 state.data.customerExtraFee)) <> " Tip" , textColor : Color.black900},
  {background : Colors.black200, image : "ny_ic_loc_black", visibility : state.data.gotoTagVisibility, text : getString GO_TO, textColor : Color.black900},
  {background : Colors.purple100, image : "ny_ic_disability_purple", visibility : state.data.purpleTagVisibility, text : getString PURPLE_RIDE, textColor : Color.purple},
  {background : Colors.blue100, image : "ny_ic_star", visibility : state.data.spLocTagVisibility, text : state.data.specialZoneText, textColor : Color.blue800}
]

---------------------- tripDetails ---------------------------

tripDetailsView ::  forall w . ST.TripDetailsScreenState -> PrestoDOM (Effect Unit) w
tripDetailsView state =
  linearLayout
  [ height $ V 40
  , width MATCH_PARENT
  , orientation HORIZONTAL
  , gravity CENTER_VERTICAL
  ][  frameLayout
      [ height MATCH_PARENT
      , width WRAP_CONTENT
      , orientation HORIZONTAL
      , gravity CENTER_VERTICAL
      ][ imageView
          [ imageWithFallback $ getVehicleImage state
          , width (V 36)
          , height (V 36)
          ]
        ]
    , linearLayout 
      [ height MATCH_PARENT
      , width WRAP_CONTENT
      , orientation VERTICAL
      , gravity CENTER_VERTICAL
      , margin (MarginLeft 10)
      ][ linearLayout
          [ height WRAP_CONTENT
          , width WRAP_CONTENT
          , orientation HORIZONTAL
          , gravity CENTER_VERTICAL
          ][  textView $
              [ text state.data.date
              , color Color.black800
              ] <> FontStyle.body1 TypoGraphy
            , textView
              [ background Color.greyishBlue
              , cornerRadius 2.5
              , margin (Margin 5 0 5 0)
              , height (V 5)
              , width (V 5)
              ] 
            , textView $
              [ text state.data.time
              , color Color.black800
              ] <> FontStyle.body1 TypoGraphy
            ]
        ]
    , linearLayout
      [ height WRAP_CONTENT
      , width MATCH_PARENT
      , gravity RIGHT
      , orientation VERTICAL
      ][  textView $
          [ text $ (getValueFromConfig "currency") <> ( show state.data.totalAmount)
          , color Color.black
          ] <> FontStyle.body14 TypoGraphy
        , textView $
          [ text $ getString(PAID)<> "  " <> if state.data.paymentMode == ST.CASH then (getString BY_CASH) else (getString ONLINE_)
          , color Color.greyDarker
          ] <> FontStyle.body16 TypoGraphy
        ]
    ]

------------------- separator -------------------
separatorView ::  forall w . PrestoDOM (Effect Unit) w
separatorView =
  linearLayout
  [ height (V 1)
  , width MATCH_PARENT
  , margin (Margin 0 16 0 16)
  , background Color.lightGreyShade
  ][]

tripDataView ::  forall w . (Action -> Effect Unit) ->  ST.TripDetailsScreenState -> PrestoDOM (Effect Unit) w
tripDataView push state = 
  linearLayout
  [ height WRAP_CONTENT
  , width MATCH_PARENT
  , orientation VERTICAL
  , gravity CENTER_VERTICAL
  ][  linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , orientation HORIZONTAL
        , gravity CENTER_VERTICAL
        ][ linearLayout
            [ height WRAP_CONTENT
            , width WRAP_CONTENT
            , orientation VERTICAL
            , weight 0.75
            ][ textView $
                [ text (getString TRIP_ID)
                , color Color.black700
                , margin (MarginBottom 4) 
                ] <> FontStyle.body5 TypoGraphy
              , linearLayout
                [ height WRAP_CONTENT
                , width WRAP_CONTENT
                , orientation HORIZONTAL
                , onClick push (const Copy)
                ][ textView $
                    [ text state.data.tripId
                    , width WRAP_CONTENT
                    , color Color.black900
                    ] <> FontStyle.body14 TypoGraphy
                  , imageView
                    [ imageWithFallback $ fetchImage FF_COMMON_ASSET "ny_ic_copy"
                    , height (V 15)
                    , width (V 13)
                    , margin (Margin 10 5 0 0)
                    
                    ]

                ]
              
            ]
          , linearLayout
            [ height WRAP_CONTENT
            , width WRAP_CONTENT
            , orientation VERTICAL
            , weight 0.25
            ][ textView $
                [ text (getString RIDER)
                , color Color.black700
                , margin (MarginBottom 4) 
                ] <> FontStyle.body5 TypoGraphy
              , textView $
                [ text state.data.rider
                , color Color.black900
                ] <> FontStyle.body14 TypoGraphy
            ]
        ] 
    , linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , orientation HORIZONTAL
        , gravity CENTER_VERTICAL
        , margin (MarginTop 20)
        , visibility if state.data.status == "CANCELLED" then GONE else VISIBLE
        ][ linearLayout
            [ height WRAP_CONTENT
            , width WRAP_CONTENT
            , orientation VERTICAL
            , weight 0.865
            ][ textView $
                [ text (getString DISTANCE)
                , color Color.black700
                , margin (MarginBottom 4) 
                ] <> FontStyle.body5 TypoGraphy
              , textView $
                [ text (state.data.distance <> " km")
                , color Color.black900
                ] <> FontStyle.body14 TypoGraphy
            ]
          , linearLayout
            [ height WRAP_CONTENT
            , width WRAP_CONTENT
            , orientation VERTICAL
            , weight 0.135
            , visibility GONE
            ][ textView $
                [ text (getString TIME_TAKEN)
                , color Color.black700
                , margin (MarginBottom 4)
                ] <> FontStyle.body5 TypoGraphy
              , textView $
                [ text state.data.timeTaken
                , color Color.black900
                ] <> FontStyle.body14 TypoGraphy
            ]
        ] 
  ]


----------------- report Isssue ----------------
reportIssueView ::  forall w . ST.TripDetailsScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
reportIssueView state push = 
  linearLayout
    [ orientation VERTICAL
    , width MATCH_PARENT
    , height WRAP_CONTENT
    , visibility GONE
    ][  linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , gravity CENTER_VERTICAL
        , orientation HORIZONTAL
        , margin (MarginBottom 16)
        , onClick push $ const ReportIssue 
        ][  textView
            ([ text (getString REPORT_AN_ISSUE)
            , color Color.darkCharcoal
            ] <> FontStyle.body1 TypoGraphy)
          , linearLayout
            [ height WRAP_CONTENT
            , width MATCH_PARENT
            , gravity RIGHT
            ][  imageView
                [ imageWithFallback $ fetchImage FF_COMMON_ASSET $ if state.props.reportIssue then "ny_ic_chevron_up" else "ny_ic_chevron_down"
                , height $ V 5
                , width $ V 10 
                ]
              ] 
          ]
          , PrestoAnim.animationSet[
            Anim.fadeIn state.props.reportIssue
          , Anim.fadeOut $ not state.props.reportIssue
          ] $ scrollView
              [ height WRAP_CONTENT
              , width MATCH_PARENT
              ][  linearLayout
                [ width MATCH_PARENT
                , height WRAP_CONTENT
                , orientation VERTICAL
                , visibility if state.props.reportIssue then VISIBLE else GONE
                ][ linearLayout 
                   [ width MATCH_PARENT
                   , height $ V 120
                   , orientation HORIZONTAL
                   , cornerRadius 5.0
                   , padding ( Padding 2 2 2 2)
                   , gravity LEFT
                   , stroke "1,#E4E4E4"
                   , margin (MarginBottom 75)
                   ][  editText
                       [ height WRAP_CONTENT
                       , width WRAP_CONTENT
                       , weight 1.0
                       , textSize FontSize.a_14
                       , padding (Padding 14 14 14 14)
                       , color Color.black800
                       , background Color.white900
                       , fontStyle $ FontStyle.bold LanguageStyle
                       , text ""
                       , hint "You can describe the issue you faced here"
                       , pattern "[A-Za-z0-9 ]*,255"
                       , onChange push $ MessageTextChanged
                       ]
                     ]  
                ]
        ]
    ]   

-------------------------- issueReportedView -----------------------

issueReportedView ::  forall w . ST.TripDetailsScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
issueReportedView state push = 
  linearLayout
  [ height MATCH_PARENT
  , width MATCH_PARENT
  , orientation VERTICAL
  , gravity CENTER
  , visibility if state.props.issueReported then VISIBLE else GONE
  ][ linearLayout[
    height $ V (2 * (EHC.screenHeight unit )/3)
    , width MATCH_PARENT
    , gravity CENTER
    , orientation VERTICAL
  ][ imageView
      [ imageWithFallback $ fetchImage FF_ASSET "ny_ic_greetings"
      , height $ V 81
      , width $ V 135
      , margin (MarginBottom 32)
      ]
    , textView $
      [ text (getString THANK_YOU_FOR_WRITING_TO_US)
      , color Color.black900
      , margin (MarginBottom 12)
      ] <> FontStyle.h1 TypoGraphy
    , textView $ 
      [ text (getString WE_HAVE_RECIEVED_YOUR_ISSUE)
      , margin (Margin 42 0 42 0)
      , gravity CENTER
      , color Color.blackLightGrey
      ] <> FontStyle.body3 TypoGraphy]
  ]

getVehicleImage :: ST.TripDetailsScreenState -> String
getVehicleImage state = case getMerchant FunctionCall of
                          YATRI       -> case state.data.vehicleType of
                                          "AUTO_RICKSHAW" -> fetchImage FF_ASSET "ny_ic_auto1"
                                          _               -> fetchImage FF_ASSET "ic_vehicle_front"
                          YATRISATHI -> getVehicleVariantImage state.data.vehicleType
                          _           -> fetchImage FF_ASSET  "ic_vehicle_front"