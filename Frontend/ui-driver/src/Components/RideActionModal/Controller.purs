{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Components.RideActionModal.Controller where
import Data.Maybe as Mb
import MerchantConfig.Types (AppConfig)
import MerchantConfig.DefaultConfig as DC
import Screens.Types as ST

data Action = StartRide 
            | EndRide 
            | CancelRide 
            | OnNavigate 
            | CallCustomer 
            | LocationTracking
            | MessageCustomer
            | TimerCallback String String Int
            | WaitingInfo
            | LoadMessages
            | SecondaryTextClick
            | VisuallyImpairedCustomer
            | NoAction

type Config = { 
  startRideActive :: Boolean,
  totalDistance :: String,
  customerName :: String,
  sourceAddress :: AddressConfig,
  destinationAddress :: AddressConfig,
  estimatedRideFare :: Int,
  notifiedCustomer :: Boolean,
  id :: String,
  buttonTimeOut :: Int,
  currentStage :: ST.HomeScreenStage,
  unReadMessages :: Boolean,
  specialLocationTag :: Mb.Maybe String,
  waitTime :: String,
  isChatOpened :: Boolean,
  requestedVehicleVariant :: Mb.Maybe String,
  accessibilityTag :: Mb.Maybe ST.DisabilityType,
  appConfig :: AppConfig,
  gotoTag :: Boolean,
  waitTimeStatus :: ST.TimerStatus
  }

type AddressConfig = {
  titleText :: String,
  detailText :: String
}

config :: Config
config = {
  startRideActive : false,
  totalDistance : "",
  customerName : "",
  sourceAddress : {
    titleText : "",
    detailText : ""
    },
  destinationAddress : {
  titleText : "",
  detailText : ""
  },
  estimatedRideFare : 0,
  notifiedCustomer : true,
  buttonTimeOut : 10,
  waitTime : "__",
  id : "buttonTimer",
  currentStage : ST.RideAccepted,
  unReadMessages : false,
  specialLocationTag : Mb.Nothing,
  isChatOpened : false,
  requestedVehicleVariant : Mb.Nothing,
  accessibilityTag : Mb.Nothing,
  appConfig : DC.config,
  gotoTag : false,
  waitTimeStatus : ST.NoStatus
}