module Screens.TicketBookingScreen.Handler where

import Engineering.Helpers.BackTrack (getState)
import Prelude (bind, pure, discard, ($), (<$>), unit)
import Screens.TicketBookingScreen.Controller (ScreenOutput(..))
import Control.Monad.Except.Trans (lift)
import Control.Transformers.Back.Trans as App
import PrestoDOM.Core.Types.Language.Flow (runScreen)
import ModifyScreenState (modifyScreenState)
import Screens.TicketBookingScreen.View as TicketBookingScreen
import Types.App (FlowBT, GlobalState(..), TICKET_BOOKING_SCREEN_OUTPUT(..), ScreenType(..), TICKET_BOOKING_SCREEN_OUTPUT(..))
import Screens.TicketBookingScreen.ScreenData (initData) as TicketBookingScreenData
import Screens.Types as ST

ticketBookingScreen :: FlowBT String TICKET_BOOKING_SCREEN_OUTPUT
ticketBookingScreen = do
  (GlobalState state) <- getState
  action <- lift $ lift $ runScreen $ TicketBookingScreen.screen state.ticketBookingScreen
  case action of
    GoToHomeScreen updatedState -> do
      modifyScreenState $ TicketBookingScreenStateType (\ticketBookingScreenState -> TicketBookingScreenData.initData {props {currentStage = ST.DescriptionStage}})
      App.BackT $ App.NoBack <$> (pure GO_TO_HOME_SCREEN_FROM_TICKET_BOOKING)
    GoToTicketPayment state -> do
      modifyScreenState $ TicketBookingScreenStateType (\ticketBookingScreenState -> state)
      App.BackT $ App.NoBack <$> (pure (GO_TO_TICKET_PAYMENT state))
    GoToGetBookingInfo updatedState bookingStatus -> do
      modifyScreenState $ TicketBookingScreenStateType (\ticketBookingScreenState -> updatedState)
      App.BackT $ App.BackPoint <$> (pure $ GET_BOOKING_INFO_SCREEN updatedState bookingStatus)
    TryAgain updatedState -> do
      modifyScreenState $ TicketBookingScreenStateType (\_ -> updatedState)
      App.BackT $ App.NoBack <$> (pure $ RESET_SCREEN_STATE)
