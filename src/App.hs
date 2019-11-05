{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeOperators #-}

module App where

import Control.Monad.IO.Class
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import System.IO
import System.Process

-- * api

type BalanceApi =
  "balance" :> Capture "account" String :> Get '[PlainText] String

itemApi :: Proxy BalanceApi
itemApi = Proxy

-- * app

run :: IO ()
run = do
  let port = 3000
      settings =
        setPort port $
        setBeforeMainLoop (hPutStrLn stderr ("listening on port " ++ show port)) $
        defaultSettings
  runSettings settings =<< mkApp

mkApp :: IO Application
mkApp = return $ serve itemApi server

server :: Server BalanceApi
server =
  getAccountBalance

getAccountBalance :: String -> Handler Balance
getAccountBalance = \ case
  "test" -> return exampleBalance
  name -> liftIO $ readProcess "bash" ["balance", name] ""

exampleBalance :: Balance
exampleBalance = "100.0"

type Balance = String
